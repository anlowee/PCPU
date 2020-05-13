module IM(PC, Instruction);  // 8-bits PC, not 32 bits

    input   [9:0] PC;
    output  [31:0] Instruction;

    reg [7:0] InstrctionMem[1023:0];
    reg [31:0] InstrctionMemReadTemp[253:0];
    reg [31:0] curIns;
    integer i, Addr;

    initial begin
        Addr = 32'b0;
        $readmemh("D:\\GitHub\\SCPU\\test.dat", InstrctionMemReadTemp);
        for (i = 0; i < 254; i = i + 1) begin
            curIns = InstrctionMemReadTemp[i];
            InstrctionMem[Addr] = curIns[31:24];
            InstrctionMem[Addr + 1] = curIns[23:16];
            InstrctionMem[Addr + 2] = curIns[15:8];
            InstrctionMem[Addr + 3] = curIns[7:0];
            Addr = Addr + 4;
        end
    end

    assign Instruction = {InstrctionMem[PC], InstrctionMem[PC + 1], InstrctionMem[PC + 2], InstrctionMem[PC + 3]};

endmodule
