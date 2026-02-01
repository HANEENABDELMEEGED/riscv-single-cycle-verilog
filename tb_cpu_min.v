`timescale 1ns/1ps
module tb_cpu_min;

    reg clk = 0;
    reg rst = 1;

    wire [31:0] pc, instr;
    wire RegWrite, ALUSrc;
    wire [3:0]  ALUCtrl;
    wire [63:0] alu_y, rs1_val, rs2_val, wb_data;

    cpu_min dut(
        .clk(clk),
        .rst(rst),
        .pc(pc),
        .instr(instr),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .ALUCtrl(ALUCtrl),
        .alu_y(alu_y),
        .rs1_val(rs1_val),
        .rs2_val(rs2_val),
        .wb_data(wb_data)
    );

    always #5 clk = ~clk;

    initial begin
        // reset
        #12 rst = 0;

        // run enough cycles for 3 instructions
        #100;

        // Check register values directly from regfile array (works in simulation)
        $display("x1=%0d x2=%0d x3=%0d",
                 dut.u_rf.regs[1], dut.u_rf.regs[2], dut.u_rf.regs[3]);

        if (dut.u_rf.regs[1] !== 64'd5)  $fatal("x1 should be 5");
        if (dut.u_rf.regs[2] !== 64'd7)  $fatal("x2 should be 7");
        if (dut.u_rf.regs[3] !== 64'd12) $fatal("x3 should be 12");

        $display("CPU_MIN TEST PASSED ✅");
        $finish;
    end

endmodule
