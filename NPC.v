`include "ctrl_encode_def.v"

module NPC(PC, NPCOp, RegRs, RegRt, IMM, NPC, PCPLUS4);  // next pc module
    
   input  [31:0] PC;        // pc
   input  [3:0]  NPCOp;     // next pc operation
   input  [25:0] IMM;       // immediate
   input  [31:0] RegRs;       // rs data read from RF, used in jalr and jr
   input  [31:0] RegRt;     // rt data read from RF, used in beq
   output reg [31:0] NPC;   // next pc
   output [31:0] PCPLUS4;  // used to store PC + 4 into %ra
   
   assign PCPLUS4 = PC + 4; // pc + 4
   
   always @(*) begin
      case (NPCOp)
          `NPC_PLUS4:  NPC = PCPLUS4;
          `NPC_BRANCH_BEQ:    begin
            NPC = (RegRs == RegRt) ? PCPLUS4 + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4;
          end
          `NPC_BRANCH_BGEZ:   begin
            NPC = (~RegRs[31]) ? PCPLUS4 + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4;
          end
          `NPC_BRANCH_BGTZ:   begin
            NPC = (~RegRs[31] & ~(RegRs == 32'b0)) ? PCPLUS4 + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4;
          end
          `NPC_BRANCH_BLEZ:   begin
            NPC = ((RegRs == 32'b0) | RegRs[31]) ? PCPLUS4 + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4;
          end
          `NPC_BRANCH_BLTZ:   begin
            NPC = (RegRs[31]) ? PCPLUS4 + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4;
          end
          `NPC_BRANCH_BNE:    begin
            NPC = (~(RegRs == RegRt)) ? PCPLUS4 + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4;
          end
          `NPC_JUMP:   NPC = {PCPLUS4[31:28], IMM[25:0], 2'b00};
          `NPC_JUMPR:  NPC = RegRs;
          `NPC_NOP:   NPC = PC;
          default:     NPC = PC;
      endcase
   end // end always
   
endmodule
