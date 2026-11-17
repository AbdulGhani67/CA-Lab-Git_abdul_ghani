`timescale 1ns / 1ps

// 32 bit 2 to 1 mux, sel = 0 gives in0, sel = 1 gives in1
// used for the next PC, the ALU second input and the write back data
module mux2(
    input  [31:0] in0,
    input  [31:0] in1,
    input         sel,
    output [31:0] out
);

    assign out = sel ? in1 : in0;

endmodule
