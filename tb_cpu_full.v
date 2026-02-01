`timescale 1ns/1ps
module tb_cpu_full;

    reg clk = 0;
    reg rst = 1;

    wire [31:0] pc, instr;

    cpu_full dut(
        .clk(clk),
        .rst(rst),
        .pc(pc),
        .instr(instr)
    );

    always #5 clk = ~clk;

    initial begin
        #12 rst = 0;

        // enough cycles for ~7 instructions
        #400;

        $display("x2=%0d x3=%0d x4=%0d",
                 dut.u_rf.regs[2], dut.u_rf.regs[3], dut.u_rf.regs[4]);

        if (dut.u_rf.regs[4] !== 64'd222) $fatal(1, "LD/SD or BEQ failed: x4 should be 222");

        $display("CPU_FULL (LD/SD/BEQ) TEST PASSED ✅");
        $finish;
    end

endmodule
