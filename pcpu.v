`include "ctrl_encode_def.v"

module pcpu(
    input clk,
    input rst);

    // PC
    wire [31:0] pc;
    wire [31:0] npc;

    // ctrl_unit
    wire [1:0] RegDst;
    wire [1:0] ToReg;
    wire [1:0] ALUSrc;
    wire ALUSrc0;
    wire RFWr;
    wire EXTOp;
    wire NPCRegRs;
    wire NPCSrc;
    wire [3:0] NPCOp;
    wire [4:0] ALUOp;
    wire [1:0] DMWr;
    wire [2:0] DMRe;

    // RF
    wire [31:0] RFDataOut1;
    wire [31:0] RFDataOut2;
    
    //ALU
    wire [31:0] ALUResult;
    wire Zero;
    wire Gez;
    wire Overflow;

    // DM
    wire [31:0] DMDataIn;
    wire [31:0] DMDataOut;

    // EXT
    wire [31:0] EXTOut;
    wire [31:0] EXTShamtOut;

    // mux
    wire [4:0] A3;  // write reg
    wire [31:0] ALUSrcMux0Out;
    wire [31:0] ALUSrcMuxOut;
    wire [31:0] EXForwardingMuxCOut;
    wire [31:0] IDForwardingMuxJumpROut;
    wire [31:0] IDForwardingMuxBranchAOut;
    wire [31:0] IDForwardingMuxBranchBOut;
    wire [31:0] NPCRegRsMuxOut;
    wire [31:0] A;  // alu num1
    wire [31:0] B;  // alu num2

    // hazard_detect
    wire [2:0] EXForwardA;
    wire [2:0] EXForwardB;
    wire [2:0] EXForwardC;
    wire [2:0] MEMForward;
    wire [2:0] IDForwardJumpR;
    wire [2:0] IDForwardBranchA;
    wire [2:0] IDForwardBranchB;
    wire IFIDWr;
    wire PCWr;
    wire IFIDRst;
    wire IDEXRst;  // rst

    // NPC
    wire [31:0] NPCOut;
    wire [31:0] pcplus4;
    wire [31:0] NPCPCIn;

    // IFIDReg
    wire [31:0] IM2IFIDRegIns;
    wire [31:0] IFIDReg2IDIns;    

    // IDEXReg
    wire [31:0] IDEXReg2EXRD1;
    wire [31:0] IDEXReg2EXRD2;
    wire [31:0] IDEXReg2EXPCPLUS4;
    wire [3:0] IDEXReg2EXNPCOp;
    wire [31:0] IDEXReg2EXShamt;
    wire [31:0] IDEXReg2EXImm;
    wire [4:0] IDEXReg2EXRs;
    wire [4:0] IDEXReg2EXRt;
    wire [4:0] IDEXReg2EXRegDstRTRD;
    wire IDEXReg2EXRFWr;
    wire [1:0] IDEXReg2EXToReg;
    wire [1:0] IDEXReg2EXALUSrc;
    wire IDEXReg2EXEXTOp;
    wire IDEXReg2EXALUSrc0;
    wire [4:0] IDEXReg2EXALUOp;
    wire [1:0] IDEXReg2EXDMWr;
    wire [2:0] IDEXReg2EXDMRe;

    // EXMEMReg
    wire [31:0] EXMEMReg2MEMALUResult;
    wire [31:0] EXMEMReg2MEMDataIn;
    wire [4:0] EXMEMReg2MEMRegDstRTRD;
    wire [31:0] EXMEMReg2MEMPCPLUS4;
    wire EXMEMReg2MEMRFWr;
    wire [1:0] EXMEMReg2MEMToReg;
    wire [1:0] EXMEMReg2MEMDMWr;
    wire [2:0] EXMEMReg2MEMDMRe;

    // MEMWBReg
    wire [31:0] MEMWBReg2WBRFWD;
    wire [4:0] MEMWBReg2WBRegDstRTRD;
    wire MEMWBReg2WBRFWr;
    wire [1:0] MEMWBReg2WBToReg;

    // instants of each module

    //----------------------IF STAGE----------------------
    NPCMux NPCMux(
        .JBNPC(NPCOut),
        .PC(pc),
        .NPCSrc(NPCSrc),

        .NPC(npc)
    );

    PC PC(
        .clk(clk),
        .rst(rst),
        .PCWr(PCWr),
        .NPC(npc),

        .PC(pc)
    );

    IM IM(.PC(pc[9:0]), .Instruction(IM2IFIDRegIns));

    IFIDReg IFIDReg(
        .clk(clk),
        .rst(IFIDRst),
        .InstructionIn(IM2IFIDRegIns),
        .PCIn(pc),
        .IFIDWr(IFIDWr),

        .PCOut(NPCPCIn),
        .InstructionOut(IFIDReg2IDIns)
    );

    //----------------------ID STAGE----------------------    
    
    ctrl_unit ctrl_unit(
        .op(IFIDReg2IDIns[31:26]),
        .funct(IFIDReg2IDIns[5:0]),
        .bgez_bltz(IFIDReg2IDIns[20:16]),

        .RegDst(RegDst),
        .ToReg(ToReg),
        .ALUSrc(ALUSrc),
        .ALUSrc0(ALUSrc0),
        .RFWr(RFWr),
        .NPCRegRs(NPCRegRs),
        .NPCSrc(NPCSrc),
        .NPCOp(NPCOp),
        .ALUOp(ALUOp),
        .DMWr(DMWr),
        .DMRe(DMRe),
        .EXTOp(EXTOp)
    );

    hazard_detect hazard_detect(
        .EXMEMRFWr(EXMEMReg2MEMRFWr),
        .IDEXRFWr(IDEXReg2EXRFWr),
        .IDEXRegDstRTRD(IDEXReg2EXRegDstRTRD),
        .EXMEMRegDstRTRD(EXMEMReg2MEMRegDstRTRD),
        .IDEXRs(IDEXReg2EXRs),
        .IDEXRt(IDEXReg2EXRt),
        .MEMWBRFWr(MEMWBReg2WBRFWr),
        .MEMWBRegDstRTRD(MEMWBReg2WBRegDstRTRD),
        .IDEXDMRe(IDEXReg2EXDMRe),
        .IDEXDMWr(IDEXReg2EXDMWr),
        .IDEXNPCOp(IDEXReg2EXNPCOp),
        .IDEXALUSrc(IDEXReg2EXALUSrc),
        .EXMEMDMRe(EXMEMReg2MEMDMRe),
        .EXMEMDMWr(EXMEMReg2MEMDMWr),
        .MEMWBToReg(MEMWBReg2WBToReg),
        .IFIDNPCOp(NPCOp),
        .IFIDRs(IFIDReg2IDIns[25:21]),
        .IFIDRt(IFIDReg2IDIns[20:16]),

        .EXForwardA(EXForwardA),
        .EXForwardB(EXForwardB),
        .EXForwardC(EXForwardC),
        .MEMForward(MEMForward),
        .IDForwardJumpR(IDForwardJumpR),
        .IDForwardBranchA(IDForwardBranchA),
        .IDForwardBranchB(IDForwardBranchB),
        .IFIDWr(IFIDWr),
        .PCWr(PCWr),
        .IFIDRst(IFIDRst),
        .IDEXRst(IDEXRst)
    );

    RF RF(
        .clk(clk),
        .rst(rst),
        .RFWr(MEMWBReg2WBRFWr),
        .A1(IFIDReg2IDIns[25:21]),
        .A2(IFIDReg2IDIns[20:16]),
        .A3(MEMWBReg2WBRegDstRTRD),
        .WD(MEMWBReg2WBRFWD),

        .RD1(RFDataOut1),
        .RD2(RFDataOut2)
    );    

    IDForwardingMuxJumpR IDForwardingMuxJumpR(
        .EXMEMALUResultOut(EXMEMReg2MEMALUResult),
        .EXMEMPCPLUS4Out(EXMEMReg2MEMPCPLUS4),
        .RD1(RFDataOut1),
        .IDForwardJumpR(IDForwardJumpR),

        .RegRs(IDForwardingMuxJumpROut)
    );

    IDForwardingMuxBranchA IDForwardingMuxBranchA(
        .EXMEMALUResultOut(EXMEMReg2MEMALUResult),
        .RD1(RFDataOut1),
        .IDForwardBranchA(IDForwardBranchA),

        .RegRs(IDForwardingMuxBranchAOut)
    );

    IDForwardingMuxBranchB IDForwardingMuxBranchB(
        .EXMEMALUResultOut(EXMEMReg2MEMALUResult),
        .RD2(RFDataOut2),
        .IDForwardBranchB(IDForwardBranchB),

        .RegRt(IDForwardingMuxBranchBOut)
    );

    NPCRegRsMux NPCRegRsMux(
        .JumpRRegRs(IDForwardingMuxJumpROut),
        .BranchRegRs(IDForwardingMuxBranchAOut),
        .NPCRegRs(NPCRegRs),

        .RegRs(NPCRegRsMuxOut)
    );

    NPC NPC(
        .PC(NPCPCIn),
        .NPCOp(NPCOp),
        .IMM(IFIDReg2IDIns[25:0]),
        .RegRs(NPCRegRsMuxOut),
        .RegRt(IDForwardingMuxBranchBOut),

        .NPC(NPCOut),
        .PCPLUS4(pcplus4)
    );

    EXT EXTImm(
        .Imm16(IFIDReg2IDIns[15:0]),
        .EXTOp(EXTOp),

        .Imm32(EXTOut)
    );

    EXT_Shamt EXTSha(
        .Imm5(IFIDReg2IDIns[10:6]),
        .EXTOp(EXTOp),
        
        .Imm32(EXTShamtOut)
    );

    IDEXReg IDEXReg(
        .clk(clk),
        .rst(IDEXRst),
        .ReadData1In(RFDataOut1),
        .ReadData2In(RFDataOut2),
        .PCPLUS4In(pcplus4),
        .NPCOpIn(NPCOp),
        .ShamtIn(EXTShamtOut),
        .ImmIn(EXTOut),
        .RegDstIn(RegDst),
        .RsIn(IFIDReg2IDIns[25:21]),
        .RtIn(IFIDReg2IDIns[20:16]),
        .RdIn(IFIDReg2IDIns[15:11]),
        .RFWrIn(RFWr),
        .ToRegIn(ToReg),
        .ALUSrcIn(ALUSrc),
        .EXTOpIn(EXTOp),
        .ALUSrc0In(ALUSrc0),
        .ALUOpIn(ALUOp),
        .DMWrIn(DMWr),
        .DMReIn(DMRe),

        .ReadData1Out(IDEXReg2EXRD1),
        .ReadData2Out(IDEXReg2EXRD2),
        .PCPLUS4Out(IDEXReg2EXPCPLUS4),
        .NPCOpOut(IDEXReg2EXNPCOp),
        .ShamtOut(IDEXReg2EXShamt),
        .ImmOut(IDEXReg2EXImm),
        .RsOut(IDEXReg2EXRs),
        .RtOut(IDEXReg2EXRt),
        .RegDst_RTRDOut(IDEXReg2EXRegDstRTRD),
        .RFWrOut(IDEXReg2EXRFWr),
        .ToRegOut(IDEXReg2EXToReg),
        .ALUSrcOut(IDEXReg2EXALUSrc),
        .EXTOpOut(IDEXReg2EXEXTOp),
        .ALUSrc0Out(IDEXReg2EXALUSrc0),
        .ALUOpOut(IDEXReg2EXALUOp),
        .DMWrOut(IDEXReg2EXDMWr),
        .DMReOut(IDEXReg2EXDMRe)
    );

    //----------------------EX STAGE----------------------

    ALUSrcMux0 ALUSrcMux0(
        .RD1(IDEXReg2EXRD1),
        .RD2(IDEXReg2EXRD2),
        .ALUSrc0(IDEXReg2EXALUSrc0),

        .ALUSrc0Out(ALUSrcMux0Out)
    );

    ALUSrcMux ALUSrcMux(
        .RD2(IDEXReg2EXRD2),
        .Imm32(IDEXReg2EXImm),
        .ShamtImm32(IDEXReg2EXShamt),
        .ALUSrc(IDEXReg2EXALUSrc),

        .ALUSrcOut(ALUSrcMuxOut)
    );

    EXForwardingMuxA EXForwardingMuxA(
        .ALUSrc0Out(ALUSrcMux0Out),
        .EXMEMALUResultOut(EXMEMReg2MEMALUResult),
        .MEMWBRFWDOut(MEMWBReg2WBRFWD),
        .EXForwardA(EXForwardA),

        .A(A)
    );

    EXForwardingMuxB EXForwardingMuxB(
        .ALUSrcOut(ALUSrcMuxOut),
        .EXMEMALUResultOut(EXMEMReg2MEMALUResult), 
        .MEMWBRFWDOut(MEMWBReg2WBRFWD),
        .EXForwardB(EXForwardB),

        .B(B)
    );

    EXForwardingMuxC EXForwardingMuxC(
        .RD2(IDEXReg2EXRD2),
        .EXMEMALUResultOut(EXMEMReg2MEMALUResult),
        .MEMWBRFWDOut(MEMWBReg2WBRFWD),
        .EXForwardC(EXForwardC),

        .DataInIn(EXForwardingMuxCOut)
    );

    alu alu(
        .A(A),
        .B(B),
        .ALUOp(IDEXReg2EXALUOp),

        .C(ALUResult),
        .Zero(Zero),  // useless
        .Overflow(Overflow),  // useless
        .Gez(Gez)  // useless
    );

    EXMEMReg EXMEMReg(
        .clk(clk),
        .ALUResultIn(ALUResult),
        .DataInIn(EXForwardingMuxCOut),
        .RegDst_RTRDIn(IDEXReg2EXRegDstRTRD),
        .PCPLUS4In(IDEXReg2EXPCPLUS4),
        .RFWrIn(IDEXReg2EXRFWr),
        .ToRegIn(IDEXReg2EXToReg),
        .DMWrIn(IDEXReg2EXDMWr),
        .DMReIn(IDEXReg2EXDMRe),

        .ALUResultOut(EXMEMReg2MEMALUResult),
        .DataInOut(EXMEMReg2MEMDataIn),
        .RegDst_RTRDOut(EXMEMReg2MEMRegDstRTRD),
        .PCPLUS4Out(EXMEMReg2MEMPCPLUS4),
        .RFWrOut(EXMEMReg2MEMRFWr),
        .ToRegOut(EXMEMReg2MEMToReg),
        .DMWrOut(EXMEMReg2MEMDMWr),
        .DMReOut(EXMEMReg2MEMDMRe)
    );

    //----------------------MEM STAGE----------------------    

    MEMForwardingMux MEMForwardingMux(
        .DataInOut(EXMEMReg2MEMDataIn),
        .MEMWBRFWDOut(MEMWBReg2WBRFWD),
        .MEMForward(MEMForward),

        .DataIn(DMDataIn)
    );

    DM DM(
        .clk(clk),
        .DMWr(EXMEMReg2MEMDMWr),
        .DMRe(EXMEMReg2MEMDMRe),
        .Addr(EXMEMReg2MEMALUResult[9:0]),
        .DataIn(DMDataIn),

        .DataOut(DMDataOut)
    );

    MEMWBReg MEMWBReg(
        .clk(clk),
        .DataOutIn(DMDataOut),
        .ALUResultIn(EXMEMReg2MEMALUResult),
        .RegDst_RTRDIn(EXMEMReg2MEMRegDstRTRD),
        .PCPLUS4In(EXMEMReg2MEMPCPLUS4),
        .RFWrIn(EXMEMReg2MEMRFWr),
        .ToRegIn(EXMEMReg2MEMToReg),

        .RFWDOut(MEMWBReg2WBRFWD),
        .RegDst_RTRDOut(MEMWBReg2WBRegDstRTRD),
        .RFWrOut(MEMWBReg2WBRFWr),
        .ToRegOut(MEMWBReg2WBToReg)
    );

    //----------------------WB STAGE----------------------    
    // RF

endmodule