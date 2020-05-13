
module EXT( Imm16, EXTOp, Imm32 );
    
   input  [15:0] Imm16;
   input         EXTOp;
   output [31:0] Imm32;
   
   assign Imm32 = (EXTOp) ? {{16{Imm16[15]}}, Imm16} : {16'd0, Imm16}; // signed-extension or zero extension
       
endmodule


module EXT_Shamt( Imm5, EXTOp, Imm32 );
    
   input  [4:0] Imm5;
   input         EXTOp;
   output [31:0] Imm32;
   
   assign Imm32 = (EXTOp) ? {{27{Imm5[4]}}, Imm5} : {27'd0, Imm5}; // signed-extension or zero extension
       
endmodule