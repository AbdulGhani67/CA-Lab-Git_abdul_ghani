`timescale 1ns / 1ps

// Task 2 testbench: runs the Lab 10 FSM program (fsm.s) on the whole processor
// switches = 3, the leds should show 3, 2, 1, 0, then the FSM reset and processor reset are tested
module TopLevelProcessor_tb;
    reg         clk = 0;
    reg         pbin = 0;
    reg         pbnext = 0;
    reg  [15:0] physical_sw = 16'd0;
    wire [15:0] physical_leds;
    integer     errors = 0;
    integer     t;

    // CLK_DIV = 1 so cpu_clk is clk / 2 (20 ns), makes the simulation shorter
    TopLevelProcessor #(.DEBOUNCE_MAX(2), .CLK_DIV(1)) uut (
        .clk(clk), .pbin(pbin), .pbnext(pbnext),
        .physical_sw(physical_sw), .physical_leds(physical_leds)
    );

    always #5 clk = ~clk;

    // waits until the leds show the value (gives up after 3000 clocks)
    task wait_leds(input [15:0] value);
        begin
            t = 0;
            while (physical_leds !== value && t < 3000) begin
                @(posedge clk); t = t + 1;
            end
            if (physical_leds === value)
                $display("leds = %0d passed at %0d ns (PC = %h)", physical_leds, $time, uut.PC);
            else begin
                $display("leds = %0d failed, expected %0d", physical_leds, value);
                errors = errors + 1;
            end
        end
    endtask

    task check(input [8*20:1] name, input [31:0] value, input [31:0] expected);
        begin
            if (value === expected) $display("%s passed: %h", name, value);
            else begin
                $display("%s failed: %h, expected %h", name, value, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        // make the delay 2^2 loops instead of 2^18 so the simulation does not take forever
        // (changes li t2, 18 at address 0x6C to li t2, 2)
        // #1 so this happens after the instruction memory has loaded fsm.mem
        #1;
        uut.imem.memory[8'h6E] = 8'h20;
        uut.imem.memory[8'h6F] = 8'h00;

        // processor reset
        pbin = 1; #99; pbin = 0;

        // switches = 0, program should sit in wait_state with leds = 0
        #600;
        check("sp",                 uut.rf.regs[2],  32'h1FC);
        check("s0 (leds addr)",     uut.rf.regs[8],  32'h200);
        check("s2 (switches addr)", uut.rf.regs[18], 32'h300);
        check("s1 (state = wait)",  uut.rf.regs[9],  32'd0);
        check("leds in wait",       physical_leds,   16'd0);

        // switches = 3, countdown is called with jal
        physical_sw = 16'd3;
        wait_leds(3);
        check("s1 (state = count)", uut.rf.regs[9],  32'd1);
        check("sp after push",      uut.rf.regs[2],  32'h1F4);
        check("ra on the stack",    uut.mem_sys.dmem.mem[126], 32'h28);   // 0x1F8 / 4 = word 126
        wait_leds(2);
        wait_leds(1);
        physical_sw = 16'd0;       // so it waits after reaching 0
        wait_leds(0);
        #600;
        check("sp after pop",       uut.rf.regs[2],  32'h1FC);
        check("back in wait",       uut.rf.regs[9],  32'd0);
        check("leds stay 0",        physical_leds,   16'd0);

        // start again with 5, press the FSM reset (up button) in the middle
        physical_sw = 16'd5;
        wait_leds(5);
        wait_leds(4);
        physical_sw = 16'd0;
        pbnext = 1;
        wait_leds(0);
        pbnext = 0; #600;
        check("FSM reset -> wait",  uut.rf.regs[9],  32'd0);
        check("sp after reset",     uut.rf.regs[2],  32'h1FC);

        // start again with 7, press the processor reset (center button)
        physical_sw = 16'd7;
        wait_leds(7);
        physical_sw = 16'd0;
        pbin = 1; #100;
        check("PC on reset",        uut.PC,          32'd0);
        check("leds on reset",      physical_leds,   16'd0);
        pbin = 0; #600;
        check("leds after reset",   physical_leds,   16'd0);

        $display("errors = %0d", errors);
        $finish;
    end
endmodule
