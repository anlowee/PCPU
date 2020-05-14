`include "ctrl_encode_def.v"

module ALUSrcMux(
    input [31:0] RD2, Imm32, ShamtImm32,
    input [1:0] ALUSrc,
    output reg [31:0] ALUSrcOut);

    always @(*) begin
        case (ALUSrc) 
            `ALUSRC_REG:    ALUSrcOut <= RD2;
            `ALUSRC_IMM:    ALUSrcOut <= Imm32;
            `ALUSRC_SHA:    ALUSrcOut <= ShamtImm32;
            `ALUSRC_ZERO:   ALUSrcOut <= 32'b0;
            default:    ALUSrcOut <= 32'b0;
        endcase
    end

endmodule

module ALUSrcMux0(
    input [31:0] RD1, RD2,
    input ALUSrc0,
    output reg [31:0] ALUSrc0Out
);

    always @(*) begin
        case (ALUSrc0)
            1'b0:   ALUSrc0Out <= RD1;
            1'b1:   ALUSrc0Out <= RD2;
            default:    ALUSrc0Out <= RD1;
        endcase
    end

endmodule

module NPCMux(
    input [31:0] JBNPC, PC,
    input NPCSrc,  // 0-PCPLUS4, 1-JBNPC(from NPC)
    output reg [31:0] NPC);

    always @(*) begin
        case (NPCSrc)
            1'b0:   NPC <= PC + 4;
            1'b1:   NPC <= JBNPC;
            default:    NPC <= PC + 4;
        endcase        
    end

endmodule

module EXForwardingMuxA(
    input [31:0] ALUSrc0Out, EXMEMALUResultOut, MEMWBRFWDOut,
    input [2:0] EXForwardA,
    output reg [31:0] A  // ALU operator A
);

    always @(*) begin
        case (EXForwardA)
            `FORWARD_IDEX:  A <= ALUSrc0Out;
            `FORWARD_EXMEM: A <= EXMEMALUResultOut;
            `FORWARD_MEMWB: A <= MEMWBRFWDOut;  
            default: A <= ALUSrc0Out;
        endcase
    end

endmodule

module EXForwardingMuxB(
    input [31:0] ALUSrcOut, EXMEMALUResultOut, MEMWBRFWDOut,
    input [2:0] EXForwardB,
    output reg [31:0] B  // ALU operator B
);

    always @(*) begin
        case (EXForwardB)
            `FORWARD_IDEX:  B <= ALUSrcOut;
            `FORWARD_EXMEM: B <= EXMEMALUResultOut;
            `FORWARD_MEMWB: B <= MEMWBRFWDOut;  
            default: B <= ALUSrcOut;
        endcase
    end

endmodule

module EXForwardingMuxC(
    input [31:0] RD2, EXMEMALUResultOut, MEMWBRFWDOut,
    input [2:0] EXForwardC,
    output reg [31:0] DataInIn  // used in EX/MEM register
);

    always @(*) begin
        case (EXForwardC)
            `FORWARD_IDEX:  DataInIn <= RD2;
            `FORWARD_EXMEM: DataInIn <= EXMEMALUResultOut;
            `FORWARD_MEMWB: DataInIn <= MEMWBRFWDOut;
            default: DataInIn <= RD2;
        endcase
    end

endmodule

module MEMForwardingMux(
    input [31:0] DataInOut, MEMWBRFWDOut,
    input [2:0] MEMForward,
    output reg [31:0] DataIn  // DM's DataIn
);

    always @(*) begin
        case (MEMForward)
            `FORWARD_EXMEM: DataIn <= DataInOut;
            `FORWARD_MEMWB: DataIn <= MEMWBRFWDOut;
            default: DataIn <= DataInOut;
        endcase
    end

endmodule

module IDForwardingMuxJumpR(
    input [31:0] EXMEMALUResultOut, EXMEMPCPLUS4Out, RD1,
    input [2:0] IDForwardJumpR,
    output reg [31:0] RegRs
);

    always @(*) begin
        case (IDForwardJumpR)
            `FORWARD_EXMEM_PCPLUS4:  RegRs <= EXMEMPCPLUS4Out;
            `FORWARD_EXMEM: RegRs <= EXMEMALUResultOut;
            `FORWARD_RF: RegRs <= RD1;
            default: RegRs <= RD1;
        endcase
    end

endmodule

module IDForwardingMuxBranchA(
    input [31:0] EXMEMALUResultOut, RD1, 
    input [2:0] IDForwardBranchA,
    output reg [31:0] RegRs
);

    always @(*) begin
        case (IDForwardBranchA)
            `FORWARD_EXMEM: RegRs <= EXMEMALUResultOut;
            `FORWARD_RF: RegRs <= RD1;
            default: RegRs <= RD1;
        endcase
    end

endmodule

module IDForwardingMuxBranchB(
    input [31:0] EXMEMALUResultOut, RD2,
    input [2:0] IDForwardBranchB,
    output reg [31:0] RegRt
);

    always @(*) begin
        case (IDForwardBranchB)
            `FORWARD_EXMEM: RegRt <= EXMEMALUResultOut;
            `FORWARD_RF: RegRt <= RD2;
            default: RegRt <= RD2;
        endcase
    end

endmodule

module NPCRegRsMux(
    input [31:0] JumpRRegRs, BranchRegRs,
    input NPCRegRs,  // determine jalr/jr or branch ins rs into NPC, 0-branch, 1-jr
    output reg [31:0] RegRs
);

    always @(*) begin
        case (NPCRegRs)
            1'b0: RegRs <= BranchRegRs;
            1'b1: RegRs <= JumpRRegRs;
            default: RegRs <= BranchRegRs;
        endcase
    end

endmodule