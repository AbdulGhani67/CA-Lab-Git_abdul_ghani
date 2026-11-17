`timescale 1ns / 1ps

// single cycle RISC-V processor
// instructions: add, sub, sll, srl, and, or, xor, addi, lw, sw, beq, bne, jal, jalr
// runs the Lab 10 FSM program (fsm.s) from the instruction memory
//
// center button = processor reset, up button = FSM reset (read by the program at 0x304)
// switches = count, leds = count going down
// the board clock is 100 MHz, the processor runs at 1 MHz (project requirement)
module TopLevelProcessor #(
    parameter DEBOUNCE_MAX = 1_000_000,
    parameter CLK_DIV      = 50           // 100 MHz / (2 x 50) = 1 MHz
)(
    input         clk,
    input         pbin,           // processor reset (center button)
    input         pbnext,         // FSM reset (up button)
    input  [15:0] physical_sw,
    output [15:0] physical_leds
);

    // ---------------- buttons and clock ----------------
    wire rst, fsm_reset;
    debouncer #(.DEBOUNCE_MAX(DEBOUNCE_MAX)) db_rst  (.clk(clk), .pbin(pbin),   .pbout(rst));
    debouncer #(.DEBOUNCE_MAX(DEBOUNCE_MAX)) db_next (.clk(clk), .pbin(pbnext), .pbout(fsm_reset));

    // clock divider, cpu_clk flips every CLK_DIV board clocks
    reg [6:0] div_count = 7'd0;
    reg       cpu_clk   = 1'b0;
    always @(posedge clk) begin
        if (div_count == CLK_DIV - 1) begin
            div_count <= 7'd0;
            cpu_clk   <= ~cpu_clk;
        end
        else
            div_count <= div_count + 1;
    end

    // ---------------- wires ----------------
    wire [31:0] PC, PC_next, PC_plus4, branch_target, PC_branch, jalr_target;
    wire [31:0] instruction, imm;
    wire [31:0] ReadData1, ReadData2, ALU_B, ALUResult, MemReadData, ResultData, WriteBack;
    wire        Zero, PCSrc;

    wire        RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, Jump, Jalr;
    wire [1:0]  ALUOp;
    wire [3:0]  ALUCtrl;

    // ---------------- fetch: PC, PC + 4, branch target ----------------
    ProgramCounter pc_reg (.clk(cpu_clk), .rst(rst), .PC_in(PC_next), .PC_out(PC));

    pcAdder pc_add (.PC(PC), .PC_plus4(PC_plus4));

    branchAdder br_add (.PC(PC), .imm(imm), .branch_target(branch_target));

    // PCSrc = 1 for jal, a taken beq or a taken bne
    BranchControl br_ctrl (
        .Branch(Branch), .Jump(Jump), .funct3(instruction[14:12]), .Zero(Zero), .PCSrc(PCSrc)
    );

    mux2 pc_mux (.in0(PC_plus4), .in1(branch_target), .sel(PCSrc), .out(PC_branch));

    // jalr jumps to rs1 + imm (from the alu) with bit 0 cleared
    assign jalr_target = {ALUResult[31:1], 1'b0};

    mux2 jalr_mux (.in0(PC_branch), .in1(jalr_target), .sel(Jalr), .out(PC_next));

    instructionMemory imem (.instAddress(PC), .instruction(instruction));

    // ---------------- decode: control, registers, immediate ----------------
    MainControl main_ctrl (
        .opcode(instruction[6:0]), .RegWrite(RegWrite), .ALUSrc(ALUSrc), .MemRead(MemRead),
        .MemWrite(MemWrite), .MemtoReg(MemtoReg), .Branch(Branch), .Jump(Jump), .Jalr(Jalr),
        .ALUOp(ALUOp)
    );

    ALUControl alu_ctrl (
        .ALUOp(ALUOp), .funct3(instruction[14:12]), .funct7(instruction[31:25]),
        .ALUControl(ALUCtrl)
    );

    RegisterFile rf (
        .clk(cpu_clk), .rst(rst), .WriteEnable(RegWrite),
        .rs1(instruction[19:15]), .rs2(instruction[24:20]), .rd(instruction[11:7]),
        .WriteData(WriteBack), .ReadData1(ReadData1), .ReadData2(ReadData2)
    );

    immGen imm_gen (.instruction(instruction), .imm(imm));

    // ---------------- execute: ALU ----------------
    // second ALU input is rs2 for R-type and branches, the immediate for addi, lw, sw, jalr
    mux2 alu_mux (.in0(ReadData2), .in1(imm), .sel(ALUSrc), .out(ALU_B));

    ALU alu (.A(ReadData1), .B(ALU_B), .ALUControl(ALUCtrl), .ALUResult(ALUResult), .Zero(Zero));

    // ---------------- memory: data memory, leds, switches, button ----------------
    addressDecoderTop mem_sys (
        .clk(cpu_clk), .rst(rst), .address(ALUResult),
        .readEnable(MemRead), .writeEnable(MemWrite),
        .writeData(ReadData2), .switches(physical_sw), .button(fsm_reset),
        .readData(MemReadData), .leds(physical_leds)
    );

    // ---------------- write back ----------------
    // memory data for lw, PC + 4 for jal and jalr, otherwise the alu result
    mux2 wb_mux   (.in0(ALUResult),  .in1(MemReadData), .sel(MemtoReg),     .out(ResultData));
    mux2 link_mux (.in0(ResultData), .in1(PC_plus4),    .sel(Jump | Jalr),  .out(WriteBack));

endmodule
