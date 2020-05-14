module PC( clk, rst, NPC, PC, PCWr );

  input              clk;
  input              rst;
  input              PCWr;  // default as 1
  input       [31:0] NPC;  // from NPCMux
  output reg  [31:0] PC;

  always @(posedge clk, posedge rst)
    if (PCWr) begin 
      if (rst) 
        PC <= 32'h0000_0000;
  //      PC <= 32'h0000_3000;
      else
        PC <= NPC;
    end
      
endmodule

