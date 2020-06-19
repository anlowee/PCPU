`include "ctrl_encode_def.v"

module  hazard_detect(  // this unit combine the hazard_detec unit && forwarding unit
    input clk,
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
    input [1:0] IDEXALUSrc,  // used in shamt and RI-type ins
    input [2:0] EXMEMDMRe,
    input [1:0] EXMEMDMWr,
    input [1:0] MEMWBToReg,
    input [3:0] IFIDNPCOp,  // from ctrl_unit
    input [4:0] IFIDRs,  // Ins[25:21]
    input [4:0] IFIDRt,  // Ins[20:16]
    input [31:0] IFIDNPC,  // from NPC, the result of NPC
    input [31:0] IFIDNPCOccur,  // from NPC, the PC when branch occur
    input [31:0] IFIDNPCNotOccur,  // from NPC, equals to PCPLUS4
    input IFIDNPCSrc,  // from control_unit

    output reg [2:0] EXForwardA,
    output reg [2:0] EXForwardB,
    output reg [2:0] EXForwardC,
    output reg [2:0] MEMForward,
    output reg [2:0] IDForwardJumpR,
    output reg [2:0] IDForwardBranchA,
    output reg [2:0] IDForwardBranchB,
    output reg IFIDWr,
    output reg PCWr,
    output reg IFIDRst,
    output reg NPCSrc,
    output reg predict_signal,  // 1-occur, 0-not occur
    output reg IDEXRst  // produce a bubble
);

    reg [1:0] predict_status;  // 2-bits predict status-machine

    assign isBranch = ((IFIDNPCOp == `NPC_BRANCH_BEQ) || (IFIDNPCOp == `NPC_BRANCH_BNE) || 
            (IFIDNPCOp == `NPC_BRANCH_BGEZ) || (IFIDNPCOp == `NPC_BRANCH_BGTZ) || 
            (IFIDNPCOp == `NPC_BRANCH_BLEZ) || (IFIDNPCOp == `NPC_BRANCH_BLTZ));  // is branch ins

    initial begin
        EXForwardA <= `FORWARD_IDEX;
        EXForwardB <= `FORWARD_IDEX;
        EXForwardC <= `FORWARD_IDEX;
        MEMForward <= `FORWARD_EXMEM;
        IDForwardJumpR <= `FORWARD_RF;
        IDForwardBranchA <= `FORWARD_RF;
        IDForwardBranchB <= `FORWARD_RF;
        IFIDWr <= 1'b1;
        PCWr <= 1'b1;
        IFIDRst <= 1'b0;
        IDEXRst <= 1'b0;      
        NPCSrc <= 1'b0;  
        predict_signal <= 1'b0;
        predict_status <= 2'b00;  // p218
    end

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
        if ((IDEXALUSrc != `ALUSRC_SHA) &&  
            EXMEMRFWr && (EXMEMRegDstRTRD != 5'b0) && (EXMEMRegDstRTRD != 5'b11111) && (EXMEMRegDstRTRD == IDEXRs))
            EXForwardA = `FORWARD_EXMEM;
        if ((IDEXALUSrc != `ALUSRC_SHA) && (IDEXALUSrc == `ALUSRC_REG) &&
            (IDEXDMWr == `DMWR_NOP) && EXMEMRFWr && (EXMEMRegDstRTRD != 5'b0) && (EXMEMRegDstRTRD != 5'b11111) && (EXMEMRegDstRTRD == IDEXRt))
            EXForwardB = `FORWARD_EXMEM;
        if ((IDEXALUSrc == `ALUSRC_SHA) && 
            (IDEXDMWr == `DMWR_NOP) && EXMEMRFWr && (EXMEMRegDstRTRD != 5'b0) && (EXMEMRegDstRTRD != 5'b11111) && (EXMEMRegDstRTRD == IDEXRt))
            EXForwardA = `FORWARD_EXMEM;
        if ((IDEXALUSrc == `ALUSRC_SHA) && (IDEXALUSrc == `ALUSRC_REG) &&
            (IDEXDMWr == `DMWR_NOP) && EXMEMRFWr && (EXMEMRegDstRTRD != 5'b0) && (EXMEMRegDstRTRD != 5'b11111) && (EXMEMRegDstRTRD == IDEXRs))
            EXForwardB = `FORWARD_EXMEM;
        if (((IDEXDMWr == `DMWR_SW) || (IDEXDMWr == `DMWR_SB) || (IDEXDMWr == `DMWR_SH))
            && (EXMEMRFWr && (EXMEMRegDstRTRD != 5'b0) && (EXMEMRegDstRTRD != 5'b11111) && (EXMEMRegDstRTRD == IDEXRt)))    
            EXForwardC = `FORWARD_EXMEM;
        if ((IDEXALUSrc != `ALUSRC_SHA) && 
            MEMWBRFWr && (MEMWBRegDstRTRD != 0) && 
            !(EXMEMRFWr && (EXMEMRegDstRTRD != 5'b0) && (EXMEMRegDstRTRD != 5'b11111) && (EXMEMRegDstRTRD == IDEXRs))
            && (MEMWBRFWr && (MEMWBRegDstRTRD != 5'b0) && (MEMWBRegDstRTRD != 5'b11111) && (MEMWBRegDstRTRD == IDEXRs)))
            EXForwardA = `FORWARD_MEMWB;
        if ((IDEXALUSrc != `ALUSRC_SHA) && (IDEXALUSrc == `ALUSRC_REG) &&
            (IDEXDMWr == `DMWR_NOP) && MEMWBRFWr && (MEMWBRegDstRTRD != 0) && 
            !(EXMEMRFWr && (EXMEMRegDstRTRD != 5'b0) && (EXMEMRegDstRTRD != 5'b11111) && (EXMEMRegDstRTRD == IDEXRt))
            && (MEMWBRFWr && (MEMWBRegDstRTRD != 5'b0) && (MEMWBRegDstRTRD != 5'b11111) && (MEMWBRegDstRTRD == IDEXRt)))
            EXForwardB = `FORWARD_MEMWB;
        if ((IDEXALUSrc == `ALUSRC_SHA) && 
            (IDEXDMWr == `DMWR_NOP) && MEMWBRFWr && (MEMWBRegDstRTRD != 0) && 
            !(EXMEMRFWr && (EXMEMRegDstRTRD != 5'b0) && (EXMEMRegDstRTRD != 5'b11111) && (EXMEMRegDstRTRD == IDEXRt))
            && (MEMWBRFWr && (MEMWBRegDstRTRD != 5'b0) && (MEMWBRegDstRTRD != 5'b11111) && (MEMWBRegDstRTRD == IDEXRt)))
            EXForwardA = `FORWARD_MEMWB;
        if ((IDEXALUSrc == `ALUSRC_SHA) && (IDEXALUSrc == `ALUSRC_REG) &&
            (IDEXDMWr == `DMWR_NOP) && MEMWBRFWr && (MEMWBRegDstRTRD != 0) && 
            !(EXMEMRFWr && (EXMEMRegDstRTRD != 5'b0) && (EXMEMRegDstRTRD != 5'b11111) && (EXMEMRegDstRTRD == IDEXRt))
            && (MEMWBRFWr && (MEMWBRegDstRTRD != 5'b0) && (MEMWBRegDstRTRD != 5'b11111) && (MEMWBRegDstRTRD == IDEXRs)))
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
        if ((IFIDNPCOp == `NPC_JUMPR) && EXMEMRFWr && (EXMEMRegDstRTRD == 5'b11111) && (EXMEMRegDstRTRD == IFIDRs))  // jalr/jr
            IDForwardJumpR = `FORWARD_EXMEM_PCPLUS4;  // jal $2  jr $31
        if ((IFIDNPCOp == `NPC_JUMPR) && EXMEMRFWr && (EXMEMRegDstRTRD != 5'b0) && 
            (EXMEMRegDstRTRD != 5'b11111) && (EXMEMRegDstRTRD == IFIDRs))
            IDForwardJumpR = `FORWARD_EXMEM;  // add $2, $1, $3  jr $2
        if (EXMEMRFWr && (EXMEMRegDstRTRD != 5'b0) && (EXMEMRegDstRTRD != 5'b11111) && (EXMEMRegDstRTRD == IFIDRs))
            IDForwardBranchA = `FORWARD_EXMEM;
        if (EXMEMRFWr && (EXMEMRegDstRTRD != 5'b0) && (EXMEMRegDstRTRD != 5'b11111) && (EXMEMRegDstRTRD == IFIDRt))
            IDForwardBranchB = `FORWARD_EXMEM;
    end

    always @(negedge clk) begin
        // eg. add jal
        if ((IFIDNPCOp == `NPC_JUMPR)
            && ((IDEXRFWr && (IDEXRegDstRTRD != 5'b0) && (IDEXRegDstRTRD != 5'b11111) && 
            ((IDEXRegDstRTRD == IFIDRs) || (IDEXRegDstRTRD == IFIDRt))))) begin
            //$display("1");
            IFIDWr <= 1'b0;
            PCWr <= 1'b0;
            IFIDRst <= 1'b0;
            IDEXRst <= 1'b1;
            NPCSrc <= IFIDNPCSrc;
        end 
        else
        // eg lw nop jal
        if ((IFIDNPCOp == `NPC_JUMPR) &&
            (((EXMEMDMRe == `DMRE_LW) || (EXMEMDMRe == `DMRE_LB) || (EXMEMDMRe == `DMRE_LH)
            || (EXMEMDMRe == `DMRE_LBU) || (EXMEMDMRe == `DMRE_LHU)) && 
            ((EXMEMRegDstRTRD == IFIDRs) || (EXMEMRegDstRTRD == IFIDRt)))) begin
            //$display("2");
            IFIDWr <= 1'b0;
            PCWr <= 1'b0;
            IFIDRst <= 1'b0;
            IDEXRst <= 1'b1;
            NPCSrc <= IFIDNPCSrc;
        end
        else
        // eg. jal any ins
        if ((IFIDNPCOp == `NPC_JUMPR) || (IFIDNPCOp == `NPC_JUMP)) begin
            //$display("3");
            IFIDWr <= 1'b0;
            PCWr <= 1'b1;
            IFIDRst <= 1'b1;
            IDEXRst <= 1'b0;
            NPCSrc <= IFIDNPCSrc;    
        end
        else
        // handle prediction
        if (isBranch) begin
            // check stall first
            if ((IDEXRFWr && (IDEXRegDstRTRD != 5'b0) && (IDEXRegDstRTRD != 5'b11111) && 
            ((IDEXRegDstRTRD == IFIDRs) || (IDEXRegDstRTRD == IFIDRt)))) begin
                IFIDWr <= 1'b0;
                PCWr <= 1'b0;
                IFIDRst <= 1'b0;
                IDEXRst <= 1'b1;
                NPCSrc <= IFIDNPCSrc;
            end
            else 
            if ((((EXMEMDMRe == `DMRE_LW) || (EXMEMDMRe == `DMRE_LB) || (EXMEMDMRe == `DMRE_LH)
                || (EXMEMDMRe == `DMRE_LBU) || (EXMEMDMRe == `DMRE_LHU)) && 
                ((EXMEMRegDstRTRD == IFIDRs) || (EXMEMRegDstRTRD == IFIDRt)))) begin
                IFIDWr <= 1'b0;
                PCWr <= 1'b0;
                IFIDRst <= 1'b0;
                IDEXRst <= 1'b1;
                NPCSrc <= IFIDNPCSrc;
            end
            else begin
                case (predict_status)
                    2'b00: begin
                        if (IFIDNPC == IFIDNPCNotOccur)
                            predict_status <= 2'b00;
                        else
                        if (IFIDNPC == IFIDNPCOccur)
                            predict_status <= 2'b01;
                        predict_signal <= 1'b0;
                    end
                    2'b01: begin
                        //$display("here");
                        if (IFIDNPC == IFIDNPCNotOccur) begin 
                            predict_status <= 2'b00;
                            predict_signal <= 1'b0;
                        end
                        else
                        if (IFIDNPC == IFIDNPCOccur) begin
                            predict_status <= 2'b10;
                            predict_signal <= 1'b1;
                        end
                    end
                    2'b10: begin
                        if (IFIDNPC == IFIDNPCNotOccur) begin
                            predict_status <= 2'b01;
                            predict_signal <= 1'b0;
                        end
                        else
                        if (IFIDNPC == IFIDNPCOccur) begin
                            predict_status <= 2'b11;
                            predict_signal <= 1'b1;
                        end
                    end
                    2'b11: begin
                        if (IFIDNPC == IFIDNPCNotOccur)
                            predict_status <= 2'b10;
                        else
                        if (IFIDNPC == IFIDNPCOccur)
                            predict_status <= 2'b11;  
                        predict_signal <= 1'b1;                  
                    end
                    default: predict_status <= 2'b00;
                endcase
                // predict failed
                if (((((predict_status == 2'b00) || (predict_status == 2'b01)) && (IFIDNPC != IFIDNPCNotOccur)) ||
                    (((predict_status == 2'b10) || (predict_status == 2'b11)) && (IFIDNPC != IFIDNPCOccur)))) begin
                    IFIDWr <= 1'b0;
                    PCWr <= 1'b1;
                    IFIDRst <= 1'b1;
                    IDEXRst <= 1'b0;
                    NPCSrc <= IFIDNPCSrc;
                end
                else
                // predict correctly
                if (((((predict_status == 2'b00) || (predict_status == 2'b01)) && (IFIDNPC == IFIDNPCNotOccur)) ||
                    (((predict_status == 2'b10) || (predict_status == 2'b11)) && (IFIDNPC == IFIDNPCOccur)))) begin
                    IFIDWr <= 1'b1;
                    PCWr <= 1'b1;
                    IFIDRst <= 1'b0;
                    IDEXRst <= 1'b0;
                    NPCSrc <= 1'b0;  // if correct, do not send the NPC result to PC again
                end
                else  begin
                    IFIDWr <= 1'b1;
                    PCWr <= 1'b1;
                    IFIDRst <= 1'b0;
                    IDEXRst <= 1'b0;
                    NPCSrc <= IFIDNPCSrc;
                end
            end
        end
        else
        // stall
        // eg. lw add
        if ((IDEXDMRe == `DMRE_LW) || (IDEXDMRe == `DMRE_LB) || 
        (IDEXDMRe == `DMRE_LH) || (IDEXDMRe == `DMRE_LBU) || (IDEXDMRe == `DMRE_LHU)
            && ((IDEXRt == IFIDRs) || (IDEXRt == IFIDRt))) begin
            //$display("4");
            IFIDWr <= 1'b0;
            PCWr <= 1'b0;
            IFIDRst <= 1'b0;
            IDEXRst <= 1'b1;
            NPCSrc <= IFIDNPCSrc;
        end
        else begin 
            //$display("5");
            IFIDWr <= 1'b1;
            PCWr <= 1'b1;
            IFIDRst <= 1'b0;
            IDEXRst <= 1'b0;
            NPCSrc <= IFIDNPCSrc;
        end
    end

endmodule