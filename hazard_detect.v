`include "ctrl_encode_def.v"

module  hazard_detect(  // this unit combine the hazard_detec unit && forwarding unit
    input EXMEMRFWr,
    input IDEXRFWr,
    input [4:0] IDEXRegDstRTRD,
    input [4:0] EXMEMRegDstRTRD,
    input [4:0] IDEXRs,
    input [4:0] IDEXRt,
    input MEMWBRFWr,
    input [4:0] MEMWBRegDstRTRD,
    input [2:0] IDEXDMRe,
    input [1:0] IDEXDMWr,
    input [3:0] IDEXNPCOp,  // from IDEX reg
    input [2:0] EXMEMDMRe,
    input [1:0] EXMEMDMWr,
    input [1:0] MEMWBToReg,
    input [3:0] IFIDNPCOp,  // from ctrl_unit
    input [4:0] IFIDRs,  // Ins[25:21]
    input [4:0] IFIDRt,  // Ins[20:16]

    output reg [2:0] EXForwardA,
    output reg [2:0] EXForwardB,
    output reg [2:0] EXForwardC,
    output reg [2:0] MEMForward,
    output reg [2:0] IDForwardJumpR,
    output reg [2:0] IDForwardBranchA,
    output reg [2:0] IDForwardBranchB,
    output reg IFIDWr,
    output reg PCWr,
    output reg rst  // produce a bubble
);

    always @(*) begin
        // forward
        EXForwardA = `FORWARD_IDEX;
        EXForwardB = `FORWARD_IDEX;
        EXForwardC = `FORWARD_IDEX;
        MEMForward = `FORWARD_EXMEM;
        IDForwardJumpR = `FORWARD_RF;
        IDForwardBranchA = `FORWARD_RF;
        IDForwardBranchB = `FORWARD_RF;

        // EX forward
        if (EXMEMRFWr && (EXMEMRegDstRTRD != 5'b0) && (EXMEMRegDstRTRD != 5'b11111) && (EXMEMRegDstRTRD == IDEXRs))
            EXForwardA = `FORWARD_EXMEM;
        if (EXMEMRFWr && (EXMEMRegDstRTRD != 5'b0) && (EXMEMRegDstRTRD != 5'b11111) && (EXMEMRegDstRTRD == IDEXRt))
            EXForwardB = `FORWARD_EXMEM;
        if (((IDEXDMWr == `DMWR_SW) || (IDEXDMWr == `DMWR_SB) || (IDEXDMWr == `DMWR_SH))
            && (EXMEMRFWr && (EXMEMRegDstRTRD != 5'b0) && (EXMEMRegDstRTRD != 5'b11111) && (EXMEMRegDstRTRD == IDEXRt)))    
            EXForwardC = `FORWARD_EXMEM;
        if (MEMWBRFWr && (MEMWBRegDstRTRD != 0) && 
            !(EXMEMRFWr && (EXMEMRegDstRTRD != 5'b0) && (EXMEMRegDstRTRD != 5'b11111) && (EXMEMRegDstRTRD == IDEXRs))
            && (MEMWBRFWr && (MEMWBRegDstRTRD != 5'b0) && (MEMWBRegDstRTRD != 5'b11111) && (MEMWBRegDstRTRD == IDEXRs)))
            EXForwardA = `FORWARD_MEMWB;
        if (MEMWBRFWr && (MEMWBRegDstRTRD != 0) && 
            !(EXMEMRFWr && (EXMEMRegDstRTRD != 5'b0) && (EXMEMRegDstRTRD != 5'b11111) && (EXMEMRegDstRTRD == IDEXRt))
            && (MEMWBRFWr && (MEMWBRegDstRTRD != 5'b0) && (MEMWBRegDstRTRD != 5'b11111) && (MEMWBRegDstRTRD == IDEXRt)))
            EXForwardB = `FORWARD_MEMWB;
        if (((IDEXDMWr == `DMWR_SW) || (IDEXDMWr == `DMWR_SB) || (IDEXDMWr == `DMWR_SH)) && 
            !(EXMEMRFWr && (EXMEMRegDstRTRD != 5'b0) && (EXMEMRegDstRTRD != 5'b11111) && (EXMEMRegDstRTRD == IDEXRt))
            && (MEMWBRFWr && (MEMWBRegDstRTRD != 5'b0) && (MEMWBRegDstRTRD != 5'b11111) && (MEMWBRegDstRTRD == IDEXRt)))
            EXForwardC = `FORWARD_MEMWB;
        
        // MEM forward
        if ((MEMWBToReg == `DM2REG) &&
            ((IDEXDMWr == `DMWR_SW) || (IDEXDMWr == `DMWR_SB) || (IDEXDMWr == `DMWR_SH)) &&
            (MEMWBRFWr && (MEMWBRegDstRTRD != 5'b0) && (MEMWBRegDstRTRD != 5'b11111) && (MEMWBRegDstRTRD == IDEXRt)))
            MEMForward = `FORWARD_MEMWB;

        // ID forward
        if (EXMEMRFWr && (EXMEMRegDstRTRD == 5'b11111) && (EXMEMRegDstRTRD == IFIDRs))  // jalr/jr
            IDForwardJumpR = `FORWARD_EXMEM_PCPLUS4;
        if (EXMEMRFWr && (EXMEMRegDstRTRD != 5'b0) && (EXMEMRegDstRTRD != 5'b11111) && (EXMEMRegDstRTRD == IDEXRs))
            IDForwardBranchA = `FORWARD_EXMEM;
        if (EXMEMRFWr && (EXMEMRegDstRTRD != 5'b0) && (EXMEMRegDstRTRD != 5'b11111) && (EXMEMRegDstRTRD == IDEXRt))
            IDForwardBranchB = `FORWARD_EXMEM;


        // stall
        IFIDWr = 1'b1;
        PCWr = 1'b1;
        rst = 1'b0;
        // eg. lw add
        if ((IDEXDMRe == `DMRE_LW) || (IDEXDMRe == `DMRE_LB) || 
        (IDEXDMRe == `DMRE_LH) || (IDEXDMRe == `DMRE_LBU) || (IDEXDMRe == `DMRE_LHU)
            && ((IDEXRt == IFIDRs) || (IDEXRt == IFIDRt))) begin
            IFIDWr = 1'b0;
            PCWr = 1'b0;
            rst = 1'b1;
        end
        // eg. add beq
        if (((IFIDNPCOp == `NPC_BRANCH_BEQ) || (IFIDNPCOp == `NPC_BRANCH_BNE) || 
        (IFIDNPCOp == `NPC_BRANCH_BGEZ) || (IFIDNPCOp == `NPC_BRANCH_BGTZ) || 
        (IFIDNPCOp == `NPC_BRANCH_BLEZ) || (IFIDNPCOp == `NPC_BRANCH_BLTZ)) && 
        (IDEXRFWr && (IDEXRegDstRTRD != 5'b0) && (IDEXRegDstRTRD != 5'b11111) && 
        ((IDEXRegDstRTRD == IFIDRs) || (IDEXRegDstRTRD == IFIDRt)))) begin
            IFIDWr = 1'b0;
            PCWr = 1'b0;
            rst = 1'b1;
        end
        // eg. lw nop beq
        if (((IFIDNPCOp == `NPC_BRANCH_BEQ) || (IFIDNPCOp == `NPC_BRANCH_BNE) || 
        (IFIDNPCOp == `NPC_BRANCH_BGEZ) || (IFIDNPCOp == `NPC_BRANCH_BGTZ) || 
        (IFIDNPCOp == `NPC_BRANCH_BLEZ) || (IFIDNPCOp == `NPC_BRANCH_BLTZ)) && 
        (((EXMEMDMRe == `DMRE_LW) || (EXMEMDMRe == `DMRE_LB) || (EXMEMDMRe == `DMRE_LH)
         || (EXMEMDMRe == `DMRE_LBU) || (EXMEMDMRe == `DMRE_LHU)) && 
        ((EXMEMRegDstRTRD == IFIDRs) || (EXMEMRegDstRTRD == IFIDRt)))) begin
            IFIDWr = 1'b0;
            PCWr = 1'b0;
            rst = 1'b1;
        end
        // eg. jal A; any ins(without prediction)
        if ((IDEXNPCOp == `NPC_JUMPR) || (IDEXNPCOp == `NPC_JUMP) ||
            (IFIDNPCOp == `NPC_BRANCH_BEQ) || (IFIDNPCOp == `NPC_BRANCH_BNE) || 
            (IFIDNPCOp == `NPC_BRANCH_BGEZ) || (IFIDNPCOp == `NPC_BRANCH_BGTZ) || 
            (IFIDNPCOp == `NPC_BRANCH_BLEZ) || (IFIDNPCOp == `NPC_BRANCH_BLTZ)) begin
            IFIDWr = 1'b0;
            PCWr = 1'b0;
            rst = 1'b1;
        end
    end

endmodule