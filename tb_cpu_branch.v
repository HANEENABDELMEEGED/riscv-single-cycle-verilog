`timescale 1ns/1ps
module tb_cpu_branch;

    reg clk = 0;
    reg rst = 1;

    wire [31:0] pc, instr;

    cpu_branch dut(
        .clk(clk),
        .rst(rst),
        .pc(pc),
        .instr(instr)
    );

    always #5 clk = ~clk;

    initial begin
        #12 rst = 0;

        // enough cycles for 5 instructions
        #200;

        $display("x3=%0d", dut.u_rf.regs[3]);
        if (dut.u_rf.regs[3] !== 64'd222) $fatal(1, "Branch failed: x3 should be 222");

        $display("CPU_BRANCH TEST PASSED ✅");
        $finish;
    end

endmodule
