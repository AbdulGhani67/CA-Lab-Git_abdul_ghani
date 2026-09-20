.data
src: .asciiz "Hello, RISC-V!"
dst: .word 0, 0, 0, 0, 0, 0, 0, 0   # 32-byte destination buffer
nl:  .asciiz "\n"

.text
main:
    la   x10, dst           # x = destination
    la   x11, src           # y = source
    jal  x1, strcpy
    la   x11, dst           # print copied string
    li   x10, 4
    ecall
    la   x11, nl
    li   x10, 4
    ecall
    li   x10, 10
    ecall

strcpy:
    addi sp, sp, -16        # adjust stack
    sw   x19, 0(sp)         # save x19
    add  x19, x0, x0        # i = 0
L1:
    add  x5, x19, x11       # x5 = &y[i]
    lbu  x6, 0(x5)          # x6 = y[i]
    add  x7, x19, x10       # x7 = &x[i]
    sb   x6, 0(x7)          # x[i] = y[i]
    beq  x6, x0, L2         # if y[i] == '\0', exit loop
    addi x19, x19, 1        # i += 1
    jal  x0, L1
L2:
    lw   x19, 0(sp)         # restore x19
    addi sp, sp, 16         # pop stack
    jalr x0, 0(x1)          # return
