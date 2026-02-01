`timescale 1ns/1ps
module tb_regfile;

    reg clk = 0;
    reg rst = 1;

    reg we;
    reg [4:0] rs1, rs2, rd;
    reg [63:0] wd;
    wire [63:0] rd1, rd2;

    regfile dut(
        .clk(clk), .rst(rst),
        .we(we),
        .rs1(rs1), .rs2(rs2),
        .rd(rd), .wd(wd),
        .rd1(rd1), .rd2(rd2)
    );

    always #5 clk = ~clk;

    initial begin
        // init
        we = 0; rs1 = 0; rs2 = 0; rd = 0; wd = 0;

        // reset for 2 cycles
        #12 rst = 0;

        // Write x1 = 5
        @(negedge clk);
        we = 1; rd = 5'd1; wd = 64'd5;
        @(posedge clk);  // write happens here

        // Write x2 = 7
        @(negedge clk);
        rd = 5'd2; wd = 64'd7;
        @(posedge clk);

        // Try writing x0 = 999 (should be ignored)
        @(negedge clk);
        rd = 5'd0; wd = 64'd999;
        @(posedge clk);

        // Asynchronous reads check
        we = 0;
        rs1 = 5'd1; rs2 = 5'd2; #1;
        $display("Read x1=%0d x2=%0d", rd1, rd2);

        if (rd1 !== 64'd5)  $fatal("x1 wrong!");
        if (rd2 !== 64'd7)  $fatal("x2 wrong!");

        rs1 = 5'd0; #1;
        $display("Read x0=%0d", rd1);
        if (rd1 !== 64'd0)  $fatal("x0 not zero!");

        $display("REGFILE TEST PASSED ✅");
        #20;
        $finish;
    end
endmodule
