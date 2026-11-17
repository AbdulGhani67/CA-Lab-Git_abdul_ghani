`timescale 1ns / 1ps

module instructionMemory_tb;
    reg  [31:0] PC = 0;
    wire [31:0] instruction;
    reg  [31:0] expected [0:35];
    integer     i;
    integer     errors = 0;

    instructionMemory im(
        .instAddress(PC), .instruction(instruction)
    );

    initial begin
        // machine code of fsm.s from the assembler
        expected[ 0] = 32'h1fc00113;   // li sp, 0x1FC
        expected[ 1] = 32'h20000413;   // li s0, 0x200
        expected[ 2] = 32'h30000913;   // li s2, 0x300
        expected[ 3] = 32'h00042023;   // sw x0, 0(s0)
        expected[ 4] = 32'h00000493;   // li s1, 0
        expected[ 5] = 32'h00092283;   // lw t0, 0(s2)
        expected[ 6] = 32'hfe028ce3;   // beq t0, x0, wait_state
        expected[ 7] = 32'h00100493;   // li s1, 1
        expected[ 8] = 32'h00028533;   // add a0, t0, x0
        expected[ 9] = 32'h00c000ef;   // jal ra, countdown
        expected[10] = 32'h00042023;   // sw x0, 0(s0)
        expected[11] = 32'hfe5ff06f;   // j wait_state
        expected[12] = 32'hff810113;   // addi sp, sp, -8
        expected[13] = 32'h00112223;   // sw ra, 4(sp)
        expected[14] = 32'h01312023;   // sw s3, 0(sp)
        expected[15] = 32'h000509b3;   // add s3, a0, x0
        expected[16] = 32'h01342023;   // sw s3, 0(s0)
        expected[17] = 32'h00098a63;   // beq s3, x0, count_done
        expected[18] = 32'h020000ef;   // jal ra, delay
        expected[19] = 32'h00051663;   // bne a0, x0, count_done
        expected[20] = 32'hfff98993;   // addi s3, s3, -1
        expected[21] = 32'hfedff06f;   // j count_loop
        expected[22] = 32'h00012983;   // lw s3, 0(sp)
        expected[23] = 32'h00412083;   // lw ra, 4(sp)
        expected[24] = 32'h00810113;   // addi sp, sp, 8
        expected[25] = 32'h00008067;   // jalr x0, 0(ra)
        expected[26] = 32'h00262337;   // lui t1, 0x262 (li t1, 2500000)
        expected[27] = 32'h5a030313;   // addi t1, t1, 0x5a0 (li t1, 2500000)
        expected[28] = 32'h00492383;   // lw t2, 4(s2)
        expected[29] = 32'h00039a63;   // bne t2, x0, delay_reset
        expected[30] = 32'hfff30313;   // addi t1, t1, -1
        expected[31] = 32'hfe031ae3;   // bne t1, x0, delay_loop
        expected[32] = 32'h00000513;   // li a0, 0
        expected[33] = 32'h00008067;   // jalr x0, 0(ra)
        expected[34] = 32'h00100513;   // li a0, 1
        expected[35] = 32'h00008067;   // jalr x0, 0(ra)

        // go through the program like PC = PC + 4, one instruction every 10 ns
        for (i = 0; i < 36; i = i + 1) begin
            #5;     // let the instruction settle, then check it
            if (instruction === expected[i]) $display("PC = %h passed: instruction = %h", PC, instruction);
            else begin
                $display("PC = %h failed: instruction = %h, expected %h", PC, instruction, expected[i]);
                errors = errors + 1;
            end
            #5;
            PC = PC + 4;
        end

        // past the end of the program the memory should be empty
        #5;
        if (instruction !== 32'h00000000) errors = errors + 1;
        $display("errors = %0d", errors);
        $finish;
    end

endmodule
