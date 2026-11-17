`timescale 1ns / 1ps

// 256 byte instruction memory, holds the Lab 10 FSM program (fsm.s)
// each instruction is 4 bytes stored little endian, so PC goes 0, 4, 8, ...
module instructionMemory#(
    parameter OPERAND_LENGTH = 31
    )(
    input [OPERAND_LENGTH:0] instAddress,
    output reg [31:0] instruction
);

    reg [7:0] memory [0:255];
    integer i;

    // clear the memory, then load the machine code of fsm.s from fsm.mem
    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 8'h00;
        $readmemh("fsm.mem", memory, 0, 143);   // 36 instructions = 144 bytes
    end

    // read 4 bytes starting at instAddress, lowest byte is at the lowest address
    always @(*) begin
        instruction = {memory[instAddress + 3], memory[instAddress + 2],
                       memory[instAddress + 1], memory[instAddress]};
    end

endmodule
