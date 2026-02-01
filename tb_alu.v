`timescale 1ns/1ps
module tb_alu;

    reg  [63:0] a, b;
    reg  [3:0]  alu_ctrl;
    wire [63:0] y;
    wire        zero;

    alu dut(.a(a), .b(b), .alu_ctrl(alu_ctrl), .y(y), .zero(zero));

    task expect64(input [63:0] exp, input [127:0] msg);
        begin
            #1;
            if (y !== exp) begin
                $display("FAIL: %s  got=%h exp=%h", msg, y, exp);
                $fatal;
            end else begin
                $display("PASS: %s", msg);
            end
        end
    endtask

    initial begin
        // ADD
        a = 64'd5; b = 64'd7; alu_ctrl = 4'd0; expect64(64'd12, "ADD 5+7");

        // SUB
        a = 64'd10; b = 64'd3; alu_ctrl = 4'd1; expect64(64'd7, "SUB 10-3");

        // AND
        a = 64'hF0F0; b = 64'h0FF0; alu_ctrl = 4'd2; expect64(64'h00F0, "AND");

        // OR
        a = 64'hF0F0; b = 64'h0FF0; alu_ctrl = 4'd3; expect64(64'hFFF0, "OR");

        // XOR
        a = 64'hAAAA; b = 64'h0F0F; alu_ctrl = 4'd4; expect64(64'hA5A5, "XOR");

        // SLL (shift by b[5:0])
        a = 64'h1; b = 64'd3; alu_ctrl = 4'd5; expect64(64'h8, "SLL 1<<3");

        // SRL
        a = 64'h40; b = 64'd3; alu_ctrl = 4'd6; expect64(64'h8, "SRL 0x40>>3");

        // ZERO flag check (SUB equal)
        a = 64'd9; b = 64'd9; alu_ctrl = 4'd1;
        #1;
        if (zero !== 1'b1) $fatal("ZERO flag should be 1 when result is 0");

        $display("ALU TEST PASSED ✅");
        #10;
        $finish;
    end
endmodule
