`timescale 1ns/1ps
module tb_immgen;

    reg  [31:0] instr;
    wire [63:0] imm;

    immgen dut(.instr(instr), .imm(imm));

    // Helper tasks to build instructions (so we don’t depend on guessing hex)
    function [31:0] make_I(input [11:0] imm12, input [4:0] rs1, input [2:0] funct3,
                          input [4:0] rd, input [6:0] opcode);
        make_I = {imm12, rs1, funct3, rd, opcode};
    endfunction

    function [31:0] make_S(input [11:0] imm12, input [4:0] rs2, input [4:0] rs1,
                          input [2:0] funct3, input [6:0] opcode);
        make_S = {imm12[11:5], rs2, rs1, funct3, imm12[4:0], opcode};
    endfunction

    function [31:0] make_B(input [12:0] imm13, input [4:0] rs2, input [4:0] rs1,
                          input [2:0] funct3, input [6:0] opcode);
        // imm13 is already shifted form including bit0=0
        make_B = {imm13[12], imm13[10:5], rs2, rs1, funct3, imm13[4:1], imm13[11], opcode};
    endfunction

    task expect_imm(input [63:0] exp, input [127:0] msg);
        begin
            #1;
            if (imm !== exp) begin
                $display("FAIL: %s  got=%h exp=%h", msg, imm, exp);
                $fatal;
            end else begin
                $display("PASS: %s", msg);
            end
        end
    endtask

    initial begin
        // 1) addi x1, x0, 5  (I-type)
        instr = make_I(12'd5, 5'd0, 3'b000, 5'd1, 7'b0010011);
        expect_imm(64'd5, "I-type addi imm=5");

        // 2) andi x1, x2, -1  (I-type sign extension check)
        instr = make_I(12'hFFF, 5'd2, 3'b111, 5'd1, 7'b0010011);
        expect_imm(64'hFFFFFFFFFFFFFFFF, "I-type sign-ext imm=-1");

        // 3) slli x4, x9, 3  (OP-IMM shift)
        // opcode=0010011, funct3=001, shamt=3 in instr[25:20]
        instr = {7'b0000000, 6'd3, 5'd9, 3'b001, 5'd4, 7'b0010011};
        expect_imm(64'd3, "slli imm(shamt)=3");

        // 4) srli x4, x9, 4  (OP-IMM shift)
        instr = {7'b0000000, 6'd4, 5'd9, 3'b101, 5'd4, 7'b0010011};
        expect_imm(64'd4, "srli imm(shamt)=4");

        // 5) sd x3, 0(x0) (S-type)
        // opcode=0100011, funct3=011 for SD, imm=0
        instr = make_S(12'd0, 5'd3, 5'd0, 3'b011, 7'b0100011);
        expect_imm(64'd0, "S-type sd imm=0");

        // 6) beq x1, x2, +16 (B-type). Branch offsets are multiples of 2, so bit0=0.
        // imm13 = 16 (0b0000000010000) includes the 0 LSB already.
        instr = make_B(13'd16, 5'd2, 5'd1, 3'b000, 7'b1100011);
        expect_imm(64'd16, "B-type beq imm=+16");

        // 7) beq x1, x2, -4 (B-type negative sign-extension check)
        // -4 as 13-bit signed (bit0=0): 0b1_1111_1111_1100
        instr = make_B(13'h1FFC, 5'd2, 5'd1, 3'b000, 7'b1100011);
        expect_imm(64'hFFFFFFFFFFFFFFFC, "B-type beq imm=-4");

        $display("IMMGEN TEST PASSED ✅");
        #10;
        $finish;
    end
endmodule
