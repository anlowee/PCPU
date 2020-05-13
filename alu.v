`include "ctrl_encode_def.v"

module alu(A, B, ALUOp, C, Zero, Overflow, Gez);
           
   input  signed [31:0] A, B;
   input         [4:0]  ALUOp;
   output signed [31:0] C;
   output reg    Overflow;
   output Gez;
   output Zero;
   
   reg [31:0] C;
   reg [32:0] temp;
   integer    i;
       
   always @( * ) begin
      case ( ALUOp )
         `ALU_NOP:  C = A;  // NOP
         `ALU_ADD: begin
            temp = {1'b0, A} + {1'b0, B};
            C = A + B;  // ADD/ADDI
            Overflow = temp[32] ^ A[31] ^ B[31] ^ C[31]; 
         end
         `ALU_ADDU: C = A + B;  // ADDU/ADDIU
         `ALU_SUB: begin
            temp = {1'b0, A} - {1'b0, B};
            C = A - B;  // SUB/SUBI
            Overflow = temp[32] ^ A[31] ^ B[31] ^ C[31];
         end 
         `ALU_NOR:  C = ~(A | B);  // NOR
         `ALU_SLL:  C = A << B;  // SLL
         `ALU_SLLV: C = B << {27'b0, A[4:0]};  // SLLV
         `ALU_SRA:  C = A >>> B;  // SRA
         `ALU_SRAV: C = B >>> {27'b0, A[4:0]};  // SRAV
         `ALU_SRL:  C = A >> B;  // SRL
         `ALU_SRLV: C = B >> {27'b0, A[4:0]};  // SRLV
         `ALU_XOR:  C = A ^ B;  // XOR 
         `ALU_SUBU: C = A - B;  // SUBU
         `ALU_AND:  C = A & B;  // AND/ANDI
         `ALU_OR:   C = A | B;  // OR/ORI
         `ALU_LUI:  C = {B[15:0], 16'b0000_0000_0000_0000};  // LUI
         `ALU_SLT:  C = (A < B) ? 32'd1 : 32'd0;  // SLT/SLTI
         `ALU_SLTU: C = ({1'b0, A} < {1'b0, B}) ? 32'd1 : 32'd0;  // SLTU
         default:   C = A;  // Undefined
      endcase
   end // end always
   
   assign Zero = (C == 32'b0);
   assign Gez = (~C[31]);

endmodule
    
