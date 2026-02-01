`timescale 1ns/1ps
module tb_control;

    reg  [31:0] instr;
    wire RegWrite, MemRead, MemWrite, ALUSrc, MemToReg, Branch;
    wire [3:0] ALUCtrl;

    control dut(
        .instr(instr),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .MemToReg(MemToReg),
        .Branch(Branch),
        .ALUCtrl(ALUCtrl)
    );

    // ---------------------------
    // Instruction builders
    // ---------------------------
    function [31:0] make_R(
        input [6:0] funct7,
        input [4:0] rs2,
        input [4:0] rs1,
        input [2:0] funct3,
        input [4:0] rd
    );
        make_R = {funct7, rs2, rs1, funct3, rd, 7'b0110011};
    endfunction

    function [31:0] make_I(
        input [11:0] imm12,
        input [4:0]  rs1,
        input [2:0]  funct3,
        input [4:0]  rd,
        input [6:0]  opcode
    );
        make_I = {imm12, rs1, funct3, rd, opcode};
    endfunction

    function [31:0] make_S(
        input [11:0] imm12,
        input [4:0]  rs2,
        input [4:0]  rs1,
        input [2:0]  funct3
    );
        make_S = {imm12[11:5], rs2, rs1, funct3, imm12[4:0], 7'b0100011};
    endfunction

    function [31:0] make_B(
        input [12:0] imm13,     // includes bit0=0 already
        input [4:0]  rs2,
        input [4:0]  rs1,
        input [2:0]  funct3
    );
        make_B = {imm13[12], imm13[10:5], rs2, rs1, funct3, imm13[4:1], imm13[11], 7'b1100011};
    endfunction

    // ---------------------------
    // X-safe per-signal checker
    // ---------------------------
    task expect_sig(
        input        expRW,
        input        expMR,
        input        expMW,
        input        expAS,
        input        expM2R,
        input        expBR,
        input [3:0]  expALU,
        input [127:0] msg
    );
        begin
            #1; // allow combinational settle
            if (RegWrite !== expRW) begin
                $display("FAIL: %s (RegWrite) got=%b exp=%b", msg, RegWrite, expRW); $fatal;
            end
            if (MemRead  !== expMR) begin
                $display("FAIL: %s (MemRead)  got=%b exp=%b", msg, MemRead, expMR); $fatal;
            end
            if (MemWrite !== expMW) begin
                $display("FAIL: %s (MemWrite) got=%b exp=%b", msg, MemWrite, expMW); $fatal;
            end
            if (ALUSrc   !== expAS) begin
                $display("FAIL: %s (ALUSrc)   got=%b exp=%b", msg, ALUSrc, expAS); $fatal;
            end
            if (MemToReg !== expM2R) begin
                $display("FAIL: %s (MemToReg) got=%b exp=%b", msg, MemToReg, expM2R); $fatal;
            end
            if (Branch   !== expBR) begin
                $display("FAIL: %s (Branch)   got=%b exp=%b", msg, Branch, expBR); $fatal;
            end
            if (ALUCtrl  !== expALU) begin
                $display("FAIL: %s (ALUCtrl)  got=%b exp=%b", msg, ALUCtrl, expALU); $fatal;
            end

            $display("PASS: %s", msg);
        end
    endtask

    initial begin
        // 1) R-type add
        instr = make_R(7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3);
        expect_sig(1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,4'd0, "R add control");

        // 2) R-type sub
        instr = make_R(7'b0100000, 5'd2, 5'd1, 3'b000, 5'd3);
        expect_sig(1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,4'd1, "R sub control");

        // 3) I-type addi
        instr = make_I(12'd5, 5'd0, 3'b000, 5'd1, 7'b0010011);
        expect_sig(1'b1,1'b0,1'b0,1'b1,1'b0,1'b0,4'd0, "I addi control");

        // 4) I-type andi
        instr = make_I(12'd1, 5'd2, 3'b111, 5'd1, 7'b0010011);
        expect_sig(1'b1,1'b0,1'b0,1'b1,1'b0,1'b0,4'd2, "I andi control");

        // 5) slli
        instr = {7'b0000000, 6'd3, 5'd9, 3'b001, 5'd4, 7'b0010011};
        expect_sig(1'b1,1'b0,1'b0,1'b1,1'b0,1'b0,4'd5, "I slli control");

        // 6) ld
        instr = make_I(12'd0, 5'd0, 3'b011, 5'd1, 7'b0000011);
        expect_sig(1'b1,1'b1,1'b0,1'b1,1'b1,1'b0,4'd0, "ld control");

        // 7) sd
        instr = make_S(12'd0, 5'd3, 5'd0, 3'b011);
        expect_sig(1'b0,1'b0,1'b1,1'b1,1'b0,1'b0,4'd0, "sd control");

        // 8) beq
        instr = make_B(13'd16, 5'd2, 5'd1, 3'b000);
        expect_sig(1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,4'd1, "beq control");

        $display("CONTROL TEST PASSED ✅");
        #10;
        $finish;
    end

endmodule
