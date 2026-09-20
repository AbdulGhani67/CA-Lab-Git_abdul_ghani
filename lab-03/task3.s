.data
arr: .word 1, 2, 3, 4, 5
sp1: .asciiz " "
nl:  .asciiz "\n"

.text
main:
    la   x10, arr           # v = &arr[0]
    addi x11, x0, 2         # k = 2 -> swaps arr[2] and arr[3]
    jal  x1, swap

    la   x5, arr            # print the array (expected: 1 2 4 3 5)
    addi x6, x0, 5          # element count
print_loop:
    beq  x6, x0, done
    lw   x11, 0(x5)
    li   x10, 1
    ecall
    la   x11, sp1
    li   x10, 4
    ecall
    addi x5, x5, 4
    addi x6, x6, -1
    j    print_loop
done:
    la   x11, nl
    li   x10, 4
    ecall
    li   x10, 10
    ecall

swap:
    slli x6, x11, 2         # x6 = k * 4 (word offset)
    add  x6, x10, x6        # x6 = &v[k]
    lw   x5, 0(x6)          # temp = v[k]
    lw   x7, 4(x6)          # x7 = v[k+1]
    sw   x7, 0(x6)          # v[k] = v[k+1]
    sw   x5, 4(x6)          # v[k+1] = temp
    jalr x0, 0(x1)          # return
