`timescale 1ns / 1ps

// decides if the next PC is the branch / jal target
//   beq (funct3 000) : taken when rs1 - rs2 == 0, so Zero = 1
//   bne (funct3 001) : taken when Zero = 0
//   jal              : always taken
module BranchControl(
    input        Branch,
    input        Jump,
    input  [2:0] funct3,
    input        Zero,
    output reg   PCSrc
);

    always @(*) begin
        if (Jump)
            PCSrc = 1'b1;
        else if (Branch) begin
            case (funct3)
                3'b000:  PCSrc = Zero;      // beq
                3'b001:  PCSrc = ~Zero;     // bne
                default: PCSrc = 1'b0;      // other branches not supported
            endcase
        end
        else
            PCSrc = 1'b0;
    end

endmodule
