`timescale 1ns / 1ps

// PC + 4, address of the next instruction in order
module pcAdder(
    input  [31:0] PC,
    output [31:0] PC_plus4
);

    assign PC_plus4 = PC + 32'd4;

endmodule
