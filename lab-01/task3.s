.text
.globl main
main:
    li x10, 5           # a = 5
    add x11, x0, x0     # b = 0 + 0
    addi x10, x11, 32   # a = b + 32

    add x5, x10, x11    # x5 = a + b
    addi x12, x5, -5    # d = (a + b) - 5

    sub x5, x10, x12    # x5 = a - d
    sub x6, x11, x10    # x6 = b - a
    add x5, x5, x6      # x5 = (a - d) + (b - a)
    add x13, x5, x12    # e = (((a - d) + (b - a)) + d)

    add x5, x10, x11    # x5 = a + b
    add x5, x5, x12     # x5 = a + b + d
    add x13, x5, x13    # e = a + b + d + e

end:
    j end               # Infinite loop to halt program