`include "ctrl_encode_def.v"

module DM(clk, Addr, DMRe, DMWr, DataIn, DataOut);  // 8-bits PC, not 32 bits

    input clk;
    input   [1:0] DMWr;
    input   [2:0] DMRe;
    input   [9:0] Addr;
    input   [31:0] DataIn;
    output reg [31:0] DataOut;

    reg [7:0] DataMem[1023:0];
   
   always @(posedge clk) begin
      case (DMWr)
         `DMWR_SW:   begin
            DataMem[Addr] <= DataIn[7:0];
            DataMem[Addr + 1] <= DataIn[15:8];
            DataMem[Addr + 2] <= DataIn[23:16];
            DataMem[Addr + 3] <= DataIn[31:24];
         end
         `DMWR_SH:   begin
            DataMem[Addr] <= DataIn[7:0];
            DataMem[Addr + 1] <= DataIn[15:8];
         end
         `DMWR_SB:   begin
            DataMem[Addr] <= DataIn[7:0];
         end
         `DMWR_NOP:  begin
            DataMem[Addr] <= DataMem[Addr];
         end
         default:    begin
            DataMem[Addr] <= DataMem[Addr];
         end
      endcase
   end

   always @(DMRe, Addr) begin
      case (DMRe) 
         `DMRE_LW:   begin
            DataOut <= {DataMem[Addr + 3], DataMem[Addr + 2], DataMem[Addr + 1], DataMem[Addr]};
         end
         `DMRE_LH:   begin
            DataOut <= {{16{DataMem[Addr + 1][7]}}, DataMem[Addr + 1], DataMem[Addr]};
         end
         `DMRE_LHU:  begin
            DataOut <= {16'b0, DataMem[Addr + 1], DataMem[Addr]};
         end
         `DMRE_LB:   begin
            DataOut <= {{24{DataMem[Addr][7]}}, DataMem[Addr]};
         end
         `DMRE_LBU:  begin
            DataOut <= {24'b0, DataMem[Addr]};
         end
         `DMRE_NOP:  begin
            DataOut <= 32'b0;
         end
         default:    begin
            DataOut <= 32'b0;
         end
      endcase
   end

endmodule

