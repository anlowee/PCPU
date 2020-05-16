`include "ctrl_encode_def.v"

module IFIDReg(
    input clk,
    input rst,
    input [31:0] InstructionIn,
    input [31:0] PCIn,
    input IFIDWr,
    output reg [31:0] PCOut,
    output reg [31:0] InstructionOut
);

    always @(posedge clk) begin
        if (rst) begin
            PCOut <= {32{1'b1}};
            InstructionOut <= {32{1'b1}};
        end
        else
        if (IFIDWr) begin
            PCOut <= PCIn;
            InstructionOut <= InstructionIn;
        end
    end 

endmodule

module IDEXReg(
    input clk,
    input rst,
    input [31:0] ReadData1In,
    input [31:0] ReadData2In,
    input [31:0] PCPLUS4In,
    input [3:0] NPCOpIn,
    
    input [31:0] ShamtIn, 
    input [31:0] ImmIn,
    
    input [1:0] RegDstIn,  // op code, used to distinct R or I ins
    input [4:0] RsIn,  // 25:21
    input [4:0] RtIn,  // 20:16
    input [4:0] RdIn,  // 15:11
    
    // signal
    // WB signal
    input RFWrIn,
    input [1:0] ToRegIn,    
    //EX signal
    input [1:0] ALUSrcIn,
    input EXTOpIn,
    input ALUSrc0In,
    input [4:0] ALUOpIn,
    // MEM signal
    input [1:0] DMWrIn,
    input [2:0] DMReIn,

    
    output reg [31:0] ReadData1Out,
    output reg [31:0] ReadData2Out,
    output reg [31:0] PCPLUS4Out,
    output reg [3:0] NPCOpOut,

    output reg [31:0] ShamtOut,
    output reg [31:0] ImmOut,

    output reg [4:0] RsOut,
    output reg [4:0] RtOut,
    output reg [4:0] RegDst_RTRDOut,

    // signal
    // WB signal
    output reg RFWrOut,
    output reg [1:0] ToRegOut,
    //EX signal
    output reg [1:0] ALUSrcOut,
    output reg EXTOpOut,
    output reg ALUSrc0Out,
    output reg [4:0] ALUOpOut,
    // MEM signal
    output reg [1:0] DMWrOut,
    output reg [2:0] DMReOut
);

    always @(posedge clk) begin
        if (rst) begin
            ReadData1Out <= 32'b0;
            ReadData2Out <= 32'b0;
            PCPLUS4Out <= 32'b0;
            NPCOpOut <= `NPC_NOP;

            ShamtOut <= 32'b0;
            ImmOut <= 32'b0;

            RsOut <= 5'b0;
            RtOut <= 5'b0;
            RegDst_RTRDOut <= 5'b0;

            RFWrOut <= 1'b0;
            ToRegOut <= `DM2REG;  // x

            ALUSrcOut <= `ALUSRC_ZERO;
            EXTOpOut <= 1'b0;
            ALUSrc0Out <= `ALUSRC_ZERO;
            ALUOpOut <= `ALU_NOP;

            DMWrOut <= `DMWR_NOP;
            DMReOut <= `DMRE_NOP;
        end
        else begin
            case (DMReIn) 
                `DMRE_LW, `DMRE_LB, `DMRE_LH, `DMRE_LBU, `DMRE_LHU: RegDst_RTRDOut <= RtIn;
                `DMRE_NOP: begin
                    case (RegDstIn) 
                        `RD_RT: RegDst_RTRDOut <= RtIn;
                        `RD_RD: RegDst_RTRDOut <= RdIn;
                        `RD_RA: RegDst_RTRDOut <= 5'b11111;
                        default: RegDst_RTRDOut <= RtIn;
                    endcase
                end
                default: RegDst_RTRDOut <= RtIn;
            endcase
            ReadData1Out <= ReadData1In;
            ReadData2Out <= ReadData2In;
            PCPLUS4Out <= PCPLUS4In;
            NPCOpOut <= NPCOpIn;

            ShamtOut <= ShamtIn;
            ImmOut <= ImmIn;

            RsOut <= RsIn;
            RtOut <= RtIn;

            RFWrOut <= RFWrIn;
            ToRegOut <= ToRegIn;

            ALUSrcOut <= ALUSrcIn;
            EXTOpOut <= EXTOpIn;
            ALUSrc0Out <= ALUSrc0In;
            ALUOpOut <= ALUOpIn;

            DMWrOut <= DMWrIn;
            DMReOut <= DMReIn;
        end
    end 

endmodule

module EXMEMReg(
    input clk,
    input [31:0] ALUResultIn,
    input [31:0] DataInIn,  // used for S-type ins in MEM stage, connected with EXForwadingMuxB output B
    input [4:0] RegDst_RTRDIn,  // rt or rd determined by RegDst from previous stage
    input [31:0] PCPLUS4In,
    // signal
    // WB signal
    input RFWrIn,
    input [1:0] ToRegIn,  
    // MEM signal
    input [1:0] DMWrIn,
    input [2:0] DMReIn,

    output reg [31:0] ALUResultOut,
    output reg [31:0] DataInOut,
    output reg [4:0] RegDst_RTRDOut,
    output reg [31:0] PCPLUS4Out,

    //signal
    // WB signal
    output reg RFWrOut,
    output reg [1:0] ToRegOut,
    // MEM signal
    output reg [1:0] DMWrOut,
    output reg [2:0] DMReOut
); 

    always @(posedge clk) begin
        ALUResultOut <= ALUResultIn;
        DataInOut <= DataInIn;
        RegDst_RTRDOut <= RegDst_RTRDIn;
        PCPLUS4Out <= PCPLUS4In;

        RFWrOut <= RFWrIn;
        ToRegOut <= ToRegIn;    

        DMWrOut <= DMWrIn;
        DMReOut <= DMReIn;    
    end

endmodule

module MEMWBReg(
    input clk,
    input [31:0] DataOutIn,  // Data read from DM
    input [31:0] ALUResultIn,
    input [4:0] RegDst_RTRDIn,
    input [31:0] PCPLUS4In,

    // WB signal
    input RFWrIn,
    input [1:0] ToRegIn,  

    output reg [31:0] RFWDOut,  // replace ToRegMux
    output reg [4:0] RegDst_RTRDOut,

    // WB signal
    output reg RFWrOut,
    output reg [1:0] ToRegOut  // handle the lw sw hazard(MEM2MEM forward)
);

    always @(posedge clk) begin
        case (ToRegIn)
            `DM2REG:    RFWDOut <= DataOutIn;   
            `ALU2REG:   RFWDOut <= ALUResultIn;
            `NPC2REG:   RFWDOut <= PCPLUS4In;
            default:    RFWDOut <= 32'b0;
        endcase
        RegDst_RTRDOut <= RegDst_RTRDIn;

        RFWrOut <= RFWrIn; 
        ToRegOut <= ToRegIn;    
    end

endmodule