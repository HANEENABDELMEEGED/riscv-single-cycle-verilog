`timescale 1ns/1ps
module tb_cpu_isa;

  reg clk = 0;
  reg rst = 1;

  always #5 clk = ~clk;

  wire [31:0] pc, instr;

  cpu_full dut(
    .clk(clk),
    .rst(rst),
    .pc(pc),
    .instr(instr)
  );

  task check64(input [63:0] got, input [63:0] exp, input [255:0] name);
    begin
      if (got !== exp) begin
        $display("FAIL %s got=%0d (0x%h) exp=%0d (0x%h)", name, got, got, exp, exp);
        $fatal(1);
      end else begin
        $display("PASS %s = %0d (0x%h)", name, got, got);
      end
    end
  endtask

  initial begin
    #20 rst = 0;

    // enough time to execute all instructions then it loops forever (00000063)
    #800;

    // Expected results for your isa_test program
    check64(dut.u_rf.regs[1],  64'd5,   "x1");
    check64(dut.u_rf.regs[2],  64'd12,  "x2");
    check64(dut.u_rf.regs[3],  64'd17,  "x3 add");
    check64(dut.u_rf.regs[4],  64'd7,   "x4 sub");
    check64(dut.u_rf.regs[5],  64'd4,   "x5 and");
    check64(dut.u_rf.regs[6],  64'd13,  "x6 or");
    check64(dut.u_rf.regs[7],  64'd9,   "x7 xor");
    check64(dut.u_rf.regs[8],  64'd20,  "x8 slli");
    check64(dut.u_rf.regs[9],  64'd6,   "x9 srli");
    check64(dut.u_rf.regs[10], 64'd40,  "x10 sll");
    check64(dut.u_rf.regs[12], 64'd1,   "x12 srl");
    check64(dut.u_rf.regs[13], 64'd4,   "x13 andi");
    check64(dut.u_rf.regs[14], 64'd13,  "x14 ori");
    check64(dut.u_rf.regs[15], 64'd10,  "x15 xori");
    check64(dut.u_rf.regs[16], 64'd17,  "x16 ld");
    check64(dut.u_rf.regs[17], 64'd222, "x17 branch result");

    $display("ISA FULL TEST PASSED");
    $finish;
  end

endmodule
