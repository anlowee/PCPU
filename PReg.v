`include "ctrl_encode_def.v"

module IFIDReg(
    input clk,
    input [31:0] InstructionIn,
    input [9:0] PCIn,
    input IFIDWr,
    output [31:0] PCOut,
    output [31:0] InstructionOut
);

    reg [31:0] PCOut_r;
    reg [31:0] InstructionOut_r;

    always @(posedge clk) begin
        if (IFIDWr) begin
            PCOut_r <= PCIn;
            InstructionOut_r <= InstructionIn;
        end
    end 

    assign PCOut = {22'b0, PCOut_r};
    assign InstructionOut = InstructionOut_r;

endmodule

module IDEXReg(
    input [31:0] ReadData1In,
    input [31:0] ReadData2In,
    
    input [31:0] ShamtIn, 
    input [31:0] ImmIn,
    
    input [4:0] RsIn,  // 25:21
    input [4:0] RtIn,  // 20:16
    input [4:0] RdIn,  // 15:11
    
    // signal
    // WB signal
    input RFWrIn,
    input [1:0] ToRegIn,    
    //EX signal
    input [1:0] RegDstIn,
    input [1:0] ALUSrcIn,
    input EXTOpIn,
    input ALUSrc0In,
    input [4:0] ALUOpIn,
    // MEM signal
    input [1:0] DMWrIn,
    input [2:0] DMReIn,

    
    output [31:0] ReadData1Out,
    output [31:0] ReadData2Out,
    output [31:0] ShamtOut,
    output [31:0] ImmOut,
    output [4:0] RsOut,
    output [4:0] RtOut,
    output [4:0] RdOut,

    // signal
    // WB signal
    output RFWrOut,
    output [1:0] ToRegOut,
    //EX signal
    output [1:0] RegDstOut,
    output [1:0] ALUSrcOut,
    output EXTOpOut,
    output ALUSrc0Out,
    output [4:0] ALUOpOut,
    // MEM signal
    output [1:0] DMWrOut,
    output [2:0] DMReOut
);

    reg [31:0] ReadData1Out_r;
    reg [31:0] ReadData2Out_r;
    reg [31:0] ShamtOut_r;
    reg [31:0] ImmOut_r;
    reg [4:0] RsOut_r;
    reg [4:0] RtOut_r;
    reg [4:0] RdOut_r;

    reg RFWrOut_r;
    reg [1:0] ToRegOut_r;

    reg [1:0] RegDstOut_r;
    reg [1:0] ALUSrcOut_r;
    reg EXTOpOut_r;
    reg ALUSrc0Out_r;
    reg [4:0] ALUOpOut_r;

    reg [1:0] DMWrOut_r;
    reg [2:0] DMReOut_r;

    assign ReadData1Out = ReadData1Out_r;
    assign ReadData2Out = ReadData2Out_r;
    assign ShamtOut = ShamtOut_r;
    assign ImmOut = ImmOut_r;
    assign RsOut = RsOut_r;
    assign RtOut = RtOut_r;
    assign RdOut = RdOut_r;
    
    assign RFWrOut = RFWrOut_r;
    assign ToRegOut = ToRegOut_r;    

    assign RegDstOut = RegDstOut_r;    
    assign ALUSrcOut = ALUSrcOut_r;
    assign EXTOpOut = EXTOpOut_r;
    assign ALUSrc0Out = ALUSrc0Out_r;
    assign ALUOpOut = ALUOpOut_r;

    assign DMWrOut = DMWrOut_r;
    assign DMReOut = DMReOut_r;

    always @(*) begin
        ReadData1Out_r <= ReadData1In;
        ReadData2Out_r <= ReadData2In;
        ShamtOut_r <= ShamtIn;
        ImmOut_r <= ImmIn;
        RsOut_r <= RsIn;
        RtOut_r <= RtIn;
        RdOut_r <= RdIn;

        RFWrOut_r <= RFWrIn;
        ToRegOut_r <= ToRegIn;

        RegDstOut_r <= RegDstIn;
        ALUSrcOut_r <= ALUSrcIn;
        EXTOpOut_r <= EXTOpIn;
        ALUSrc0Out_r <= ALUSrc0In;
        ALUOpOut_r <= ALUOpIn;

        DMWrOut_r <= DMWrIn;
        DMReOut_r <= DMReIn;
    end 

endmodule

module EXMEMReg(
    input [31:0] ALUResultIn,
    input [31:0] ReadData2In,  // used for S-type ins in MEM stage
    input [4:0] RegDst_RTRDIn,  // rt or rd determined by RegDst from previous stage

    // signal
    // WB signal
    input RFWrIn,
    input [1:0] ToRegIn,  
    // MEM signal
    input [1:0] DMWrIn,
    input [2:0] DMReIn,

    output [31:0] ALUResultOut,
    output [31:0] ReadData2Out,
    output [4:0] RegDst_RTRDOut,

    //signal
    // WB signal
    output RFWrOut,
    output [1:0] ToRegOut,
    // MEM signal
    output [1:0] DMWrOut,
    output [2:0] DMReOut
);

    reg [31:0] ALUResultOut_r;
    reg [31:0] ReadData2Out_r;
    reg [4:0] RegDst_RTRDOut_r;

    reg RFWrOut_r;
    reg [1:0] ToRegOut_r;

    reg [1:0] DMWrOut_r;
    reg [2:0] DMReOut_r;

    assign ALUResultOut = ALUResultOut_r;
    assign ReadData2Out = ReadData2Out_r;
    assign RegDst_RTRDOut = RegDst_RTRDOut_r;

    assign RFWrOut = RFWrOut_r;
    assign ToRegOut = ToRegOut_r;     

    assign DMWrOut = DMWrOut_r;
    assign DMReOut = DMReOut_r;   

    always @(*) begin
        ALUResultOut_r <= ALUResultIn;
        ReadData2Out_r <= ReadData2In;
        RegDst_RTRDOut_r <= RegDst_RTRDIn;

        RFWrOut_r <= RFWrIn;
        ToRegOut_r <= ToRegIn;    

        DMWrOut_r <= DMWrIn;
        DMReOut_r <= DMReIn;    
    end

endmodule

module MEMWBReg(
    input [31:0] DataOutIn,  // Data read from DM
    input [31:0] ALUResultIn,
    input [4:0] RegDst_RTRDIn,

    // WB signal
    input RFWrIn,
    input [1:0] ToRegIn,  

    output [31:0] DataOutOut,
    output [31:0] ALUResultOut,
    output [4:0] RegDst_RTRDOut,

    // WB signal
    output RFWrOut,
    output [1:0] ToRegOut
);

    reg [31:0] DataOutOut_r;
    reg [31:0] ALUResultOut_r;
    reg [4:0] RegDst_RTRDOut_r;

    reg RFWrOut_r;
    reg [1:0] ToRegOut_r;    

    assign DataOutOut = DataOutOut_r;
    assign ALUResultOut = ALUResultOut_r;
    assign RegDst_RTRDOut = RegDst_RTRDOut_r;

    assign RFWrOut = RFWrOut_r;
    assign ToRegOut = ToRegOut_r;     

    always @(*) begin
        DataOutOut_r <= DataOutIn;
        ALUResultOut_r <= ALUResultIn;
        RegDst_RTRDOut_r <= RegDst_RTRDIn;

        RFWrOut_r <= RFWrIn;
        ToRegOut_r <= ToRegIn;     
    end

endmodule