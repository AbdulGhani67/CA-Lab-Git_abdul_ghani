`timescale 1ns / 1ps

// holds the address of the current instruction
// takes the next PC on every rising clock edge, reset sends it back to 0
module ProgramCounter(
    input             clk,
    input             rst,
    input      [31:0] PC_in,       // next PC from the mux
    output reg [31:0] PC_out       // current PC
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            PC_out <= 32'd0;
        else
            PC_out <= PC_in;
    end

endmodule
