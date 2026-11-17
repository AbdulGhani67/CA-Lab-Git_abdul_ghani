`timescale 1ns / 1ps

// branch / jal target = PC + (imm << 1)
// immGen gives imm[12:1] for branches and imm[20:1] for jal, so shifting by 1 puts the 0 back at bit 0
module branchAdder(
    input  [31:0] PC,
    input  [31:0] imm,
    output [31:0] branch_target
);

    assign branch_target = PC + (imm << 1);

endmodule
