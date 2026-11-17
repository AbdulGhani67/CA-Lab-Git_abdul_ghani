`timescale 1ns / 1ps

// 128 x 32 data memory (byte addresses 0 - 511)
// changed from Lab 8: the read is not clocked anymore, because in a single cycle
// processor lw has to get its data in the same clock cycle
module DataMemory(
    input         clk,
    input  [31:0] address,
    input  [31:0] writedata,
    input         memwrite,       // 1 = write
    output [31:0] readdata
);

    // register declaration
    reg [31:0] mem [0:127];
    integer i;

    // start with every location at 0
    initial begin
        for (i = 0; i < 128; i = i + 1)
            mem[i] = 32'd0;
    end

    // address is a byte address, so address[8:2] picks the word
    // write happens on the clock edge
    always @(posedge clk) begin
        if (memwrite == 1'b1)
            mem[address[8:2]] <= writedata;
    end

    // read straight away
    assign readdata = mem[address[8:2]];

endmodule
