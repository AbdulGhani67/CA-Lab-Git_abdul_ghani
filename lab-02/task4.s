.data
D: .space 256

.text
.globl main
main:

    # Variables mapping: a in x5, b in x6, i in x7, j in x29, D base in x10
    li x5, 3      # a = 3
    li x6, 4      # b = 4
    la x10, D

    li x7, 0 # i = 0

    OuterLoop:
    bge x7, x5, OuterExit
    li x29, 0 # j = 0

    InnerLoop:
    bge x29, x6, InnerExit
    slli x11, x29, 4 # Byte offset for D[4*j]
    add x11, x10, x11 # Absolute address of D[4*j]
    add x12, x7, x29 # Compute i + j
    sw x12, 0(x11) # D[4*j] = i + j
    addi x29, x29, 1 # j++
    j InnerLoop

    InnerExit:
    addi x7, x7, 1 # i++
    j OuterLoop

    OuterExit:

    li a7, 10
    ecall
