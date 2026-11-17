.text
.globl main

main:

    li sp, 0x1FC     # stack pointer at the top of data memory
    li s0, 0x200     # leds address
    li s2, 0x300     # switches address, reset button is at 0x304
    sw x0, 0(s0)     # leds = 0

wait_state:
    li s1, 0         # state = wait
    lw t0, 0(s2)     # t0 = switches
    beq t0, x0, wait_state   # if switches == 0, keep waiting

    li s1, 1         # state = count
    add a0, t0, x0   # a0 = switches value, passed to countdown
    jal ra, countdown

    sw x0, 0(s0)     # leds = 0 after countdown or reset
    j wait_state     # go back to wait state


countdown:

    addi sp, sp, -8  # stack allocation for 2 registers
    sw ra, 4(sp)     # saves ra
    sw s3, 0(sp)     # saves s3

    add s3, a0, x0   # count = a0

count_loop:
    sw s3, 0(s0)     # leds = count
    beq s3, x0, count_done   # if count == 0, exit

    jal ra, delay    # wait about 1 second
    bne a0, x0, count_done   # if reset was pressed, exit

    addi s3, s3, -1  # count--
    j count_loop     # jump back to the loop

count_done:
    lw s3, 0(sp)     # restore s3
    lw ra, 4(sp)     # restore ra
    addi sp, sp, 8   # pop the stack
    jalr x0, 0(ra)   # return


delay:

    li t1, 2500000   # 2500000 loops x 4 instructions = 10M cycles = 1 sec at 10 MHz

delay_loop:
    lw t2, 4(s2)     # t2 = reset button
    bne t2, x0, delay_reset  # if reset is pressed, exit
    addi t1, t1, -1  # t1--
    bne t1, x0, delay_loop   # loop until t1 == 0

    li a0, 0         # return 0, reset not pressed
    jalr x0, 0(ra)   # return

delay_reset:
    li a0, 1         # return 1, reset pressed
    jalr x0, 0(ra)   # return
