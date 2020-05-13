`include "ctrl_encode_def.v"

module RegDstMux(
    input [4:0] rt, rd,
    input [1:0] RegDst,
    output reg [4:0] A3);

    always @(*) begin
        case (RegDst)
            `RD_RT: A3 <= rt;
            `RD_RD: A3 <= rd;
            `RD_RA: A3 <= 5'b11111;
            default:    A3 <= rt;
        endcase
    end

endmodule

module ALUSrcMux(
    input [31:0] RD2, Imm32, ShamtImm32,
    input [1:0] ALUSrc,
    output reg [31:0] B);

    always @(*) begin
        case (ALUSrc) 
            `ALUSRC_REG:    B <= RD2;
            `ALUSRC_IMM:    B <= Imm32;
            `ALUSRC_SHA:    B <= ShamtImm32;
            `ALUSRC_ZERO:   B <= 32'b0;
            default:    B <= 32'b0;
        endcase
    end

endmodule

module ToRegMux(
    input [31:0] DataOut, PCPLUS4, ALUResult,
    input [1:0] ToReg,
    output reg [31:0] RFWD);

    always @(*) begin
        case (ToReg) 
            `DM2REG:    RFWD <= DataOut;   
            `ALU2REG:   RFWD <= ALUResult;
            `NPC2REG:   RFWD <= PCPLUS4;
            default:    RFWD <= 32'b0;
        endcase
    end

endmodule

module ALUSrcMux0(
    input [31:0] RD1, RD2,
    input ALUSrc0,
    output reg [31:0] A
);

    always @(*) begin
        case (ALUSrc0)
            1'b0:   A <= RD1;
            1'b1:   A <= RD2;
            default:    A <= RD1;
        endcase
    end

endmodule