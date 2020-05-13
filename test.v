module test;
	reg clk;
	reg rst;

	scpu scpu(clk, rst);
	
	initial 
	begin
		clk = 1;
		rst = 0;
		#10;
		rst = 1;
		#10;
		rst = 0;
	end

	always
		#(10) clk = ~clk;
endmodule