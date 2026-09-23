.data
msg:    .string "Triangular number = "

.text
main:                        # ---- wrapper ----
    addi a0, x0, 10          # num = 10  (change to test other values)
    jal  ra, ntri            # a0 = ntri(10)
    addi s0, a0, 0           # keep result (ecall overwrites a0)

    la   a1, msg             # a1 = address of the string
    addi a0, x0, 4           # ecall 4 = print string
    ecall
    addi a1, s0, 0           # a1 = result
    addi a0, x0, 1           # ecall 1 = print integer
    ecall                    # prints 55
    addi a0, x0, 10          # ecall 10 = exit
    ecall

ntri:
    addi sp, sp, -16         # frame (16-byte aligned, as required by the manual)
    sw   ra, 12(sp)          # save return address
    sw   a0, 8(sp)           # save num (caller's copy needed after the call)

    addi t0, x0, 1           # t0 = 1
    blt  t0, a0, recurse     # if (1 < num) -> recursive case

    addi a0, x0, 1           # base case: return 1
    addi sp, sp, 16          # pop frame
    jalr x0, 0(ra)           # return

recurse:
    addi a0, a0, -1          # argument = num - 1
    jal  ra, ntri            # a0 = ntri(num-1)

    lw   t1, 8(sp)           # restore original num
    add  a0, a0, t1          # result = ntri(num-1) + num
    lw   ra, 12(sp)          # restore return address
    addi sp, sp, 16          # pop frame
    jalr x0, 0(ra)           # return