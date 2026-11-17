`timescale 1ns / 1ps

// Memory system that the processor talks to (from Lab 8)
//   0x000 - 0x1FF : data memory
//   0x200 - 0x2FF : leds
//   0x300 - 0x3FF : switches (0x300), reset button of the FSM program (0x304)
module addressDecoderTop(
    input         clk, rst,
    input  [31:0] address,
    input         readEnable, writeEnable,
    input  [31:0] writeData,
    input  [15:0] switches,
    input         button,         // up button, read at 0x304

    output [31:0] readData,
    output [15:0] leds
);

    wire        DataMemWrite, DataMemRead, LEDWrite, SwitchReadEnable;
    wire [31:0] memReadData;
    wire [31:0] switchReadData;

    // only the lower 10 bits of the address are used
    AddressDecoder decoder (
        .address(address[9:0]), .readEnable(readEnable), .writeEnable(writeEnable),
        .DataMemWrite(DataMemWrite), .DataMemRead(DataMemRead),
        .LEDWrite(LEDWrite), .SwitchReadEnable(SwitchReadEnable)
    );

    DataMemory dmem (
        .clk(clk), .address(address),
        .writedata(writeData), .memwrite(DataMemWrite), .readdata(memReadData)
    );

    // the "switches" module is the LED writer (names are swapped from Lab 5)
    switches led_if (
        .clk(clk), .rst(rst),
        .writeData(writeData), .writeEnable(LEDWrite), .readEnable(1'b0),
        .memAddress(address[31:2]), .readData(), .leds(leds)
    );

    // the "leds" module is the switch reader (names are swapped from Lab 5)
    leds sw_if (
        .clk(clk), .rst(rst), .btns(16'd0),
        .writeData(32'd0), .writeEnable(1'b0), .readEnable(SwitchReadEnable),
        .memAddress(address[31:2]), .switches(switches), .readData(switchReadData)
    );

    // in the switch range, address bit 2 picks the switches (0x300) or the button (0x304)
    wire [31:0] inputData = address[2] ? {31'd0, button} : switchReadData;

    // send back data from whichever device was read, 0 otherwise
    // both reads are not clocked, so lw gets the data in the same cycle
    assign readData = DataMemRead      ? memReadData :
                      SwitchReadEnable ? inputData   :
                      32'd0;

endmodule
