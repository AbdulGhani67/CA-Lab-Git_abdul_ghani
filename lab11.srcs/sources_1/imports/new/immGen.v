`timescale 1ns / 1ps

// makes the 32 bit sign extended immediate from the instruction
//   I-type (addi, lw, jalr) : inst[31:20]
//   S-type (sw)             : inst[31:25], inst[11:7]
//   B-type (beq, bne)       : inst[31], inst[7], inst[30:25], inst[11:8]    (this is imm[12:1])
//   J-type (jal)            : inst[31], inst[19:12], inst[20], inst[30:21]  (this is imm[20:1])
// for B and J bit 0 is always 0, so it is left out and branchAdder shifts left by 1
// inst[31] is always the sign bit, so it is copied into the upper bits
module immGen(
    input      [31:0] instruction,
    output reg [31:0] imm
);

    wire [6:0] opcode = instruction[6:0];

    always @(*) begin
        case (opcode)
            7'b0010011,                         // addi
            7'b0000011,                         // lw
            7'b1100111:                         // jalr
                imm = {{20{instruction[31]}}, instruction[31:20]};
            7'b0100011:                         // sw
                imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            7'b1100011:                         // beq, bne
                imm = {{20{instruction[31]}}, instruction[31], instruction[7],
                       instruction[30:25], instruction[11:8]};
            7'b1101111:                         // jal
                imm = {{12{instruction[31]}}, instruction[31], instruction[19:12],
                       instruction[20], instruction[30:21]};
            default:
                imm = 32'd0;                    // R-type has no immediate
        endcase
    end

endmodule
