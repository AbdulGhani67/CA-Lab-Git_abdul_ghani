`timescale 1ns / 1ps

// Task 1 testbench: ProgramCounter + pcAdder + branchAdder + mux2 + immGen
module PCUpdate_tb;
    reg         clk = 0;
    reg         rst = 0;
    reg         PCSrc = 0;
    reg  [31:0] instruction = 32'd0;
    wire [31:0] PC, PC_next, PC_plus4, branch_target, imm;
    integer     errors = 0;

    // PC update datapath
    ProgramCounter pc_reg (.clk(clk), .rst(rst), .PC_in(PC_next), .PC_out(PC));
    pcAdder        pc_add (.PC(PC), .PC_plus4(PC_plus4));
    branchAdder    br_add (.PC(PC), .imm(imm), .branch_target(branch_target));
    mux2           pc_mux (.in0(PC_plus4), .in1(branch_target), .sel(PCSrc), .out(PC_next));
    immGen         imm_gen (.instruction(instruction), .imm(imm));

    always #5 clk = ~clk;     // rising edges at 5, 15, 25, ...

    task check_pc(input [8*12:1] name, input [31:0] expected);
        begin
            if (PC === expected) $display("%s passed: PC = %0d", name, PC);
            else begin
                $display("%s failed: PC = %0d, expected %0d", name, PC, expected);
                errors = errors + 1;
            end
        end
    endtask

    task check_imm(input [8*12:1] name, input [31:0] inst, input [31:0] expected);
        begin
            instruction = inst; #1;
            if (imm === expected) $display("%s passed: imm = %0d", name, $signed(imm));
            else begin
                $display("%s failed: imm = %0d, expected %0d", name, $signed(imm), $signed(expected));
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        // reset
        rst = 1; #12; rst = 0;
        check_pc("reset", 0);

        // PCSrc = 0, PC goes up by 4 every clock
        #10; check_pc("PC+4 (1)", 4);
        #10; check_pc("PC+4 (2)", 8);
        #10; check_pc("PC+4 (3)", 12);

        // beq x0, x0, +16 taken, PC = 12 + 16 = 28
        instruction = 32'h00000863;
        PCSrc = 1;
        #10; check_pc("branch +16", 28);

        // beq x0, x0, -8 taken, PC = 28 - 8 = 20
        instruction = 32'hfe000ce3;
        #10; check_pc("branch -8", 20);

        // PCSrc back to 0, sequential again
        PCSrc = 0;
        #10; check_pc("PC+4 (4)", 24);

        // immediates, I and S are the real value, B and J are offset / 2
        check_imm("addi -5", 32'hffb00093, -5);      // addi x1, x0, -5
        check_imm("addi 2047", 32'h7ff00093, 2047);  // addi x1, x0, 2047
        check_imm("lw 8", 32'h00812083, 8);          // lw x1, 8(x2)
        check_imm("sw -4", 32'hfe112e23, -4);        // sw x1, -4(x2)
        check_imm("sw 100", 32'h06112223, 100);      // sw x1, 100(x2)
        check_imm("beq +16", 32'h00000863, 8);       // beq x0, x0, +16
        check_imm("beq -8", 32'hfe000ce3, -4);       // beq x0, x0, -8
        check_imm("jalr 0", 32'h00008067, 0);        // jalr x0, 0(ra)
        check_imm("jal +12", 32'h00c000ef, 6);       // jal ra, +12
        check_imm("jal -28", 32'hfe5ff06f, -14);     // jal x0, -28 (j)
        check_imm("R-type", 32'h002081b3, 0);        // add x3, x1, x2

        // reset in the middle of running
        rst = 1; #2; rst = 0;
        check_pc("reset again", 0);

        $display("errors = %0d", errors);
        $finish;
    end
endmodule
