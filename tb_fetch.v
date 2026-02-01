`timescale 1ns/1ps
module tb_fetch;
    reg clk = 0;
    reg rst = 1;
    wire [31:0] pc;
    wire [31:0] instr;

    fetch_top dut(.clk(clk), .rst(rst), .pc(pc), .instr(instr));

    always #5 clk = ~clk;

    initial begin
        #12 rst = 0;
        #100 $finish;
    end

    always @(posedge clk)
        $display("t=%0t  pc=%h  instr=%h", $time, pc, instr);
endmodule
