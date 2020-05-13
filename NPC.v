`include "ctrl_encode_def.v"

module NPC(PC, NPCOp, Reg, IMM, NPC, Zero, Gez, PCPLUS4);  // next pc module
    
   input Zero;  // ALU output: is equal to zero 
   input Gez;   // ALU output: is greater/equal to zero
   input  [31:0] PC;        // pc
   input  [3:0]  NPCOp;     // next pc operation
   input  [25:0] IMM;       // immediate
   input  [31:0] Reg;       // data read from RF, used in jalr and jr
   output reg [31:0] NPC;   // next pc
   output [31:0] PCPLUS4;  // used to store PC + 4 into %ra
   
   assign PCPLUS4 = PC + 4; // pc + 4
   
   always @(*) begin
      case (NPCOp)
          `NPC_PLUS4:  NPC = PCPLUS4;
          `NPC_BRANCH_BEQ:    begin
            NPC = (Zero) ? PCPLUS4 + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4;
          end
          `NPC_BRANCH_BGEZ:   begin
            NPC = (Gez) ? PCPLUS4 + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4;
          end
          `NPC_BRANCH_BGTZ:   begin
            NPC = (Gez & ~Zero) ? PCPLUS4 + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4;
          end
          `NPC_BRANCH_BLEZ:   begin
            NPC = (Zero | ~Gez) ? PCPLUS4 + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4;
          end
          `NPC_BRANCH_BLTZ:   begin
            NPC = (~Gez) ? PCPLUS4 + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4;
          end
          `NPC_BRANCH_BNE:    begin
            NPC = (~Zero) ? PCPLUS4 + {{14{IMM[15]}}, IMM[15:0], 2'b00} : PCPLUS4;
          end
          `NPC_JUMP:   NPC = {PCPLUS4[31:28], IMM[25:0], 2'b00};
          `NPC_JUMPR:  NPC = Reg;
          `NPC_NOP:   NPC = PC;
          default:     NPC = PC;
      endcase
   end // end always
   
endmodule
