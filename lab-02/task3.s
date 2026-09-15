.text
.globl main
main:

    li x5, 0x200

    li x22, 0 # i = 0
    li x6, 10 # Upper bound limit

    Loop1:
    bge x22, x6, Exit1
    slli x7, x22, 2 # Offset = i * 4
    add x7, x7, x5 # Address of a[i]
    sw x22, 0(x7) # a[i] = i
    addi x22, x22, 1 # i++
    j Loop1
    Exit1:

    li x22, 0 # i = 0
    li x23, 0 # sum = 0

    Loop2:
    bge x22, x6, Exit2
    slli x7, x22, 2 # Offset = i * 4
    add x7, x7, x5 # Address of a[i]
    lw x28, 0(x7) # Load a[i] into temporary register x28
    add x23, x23, x28 # sum = sum + a[i]
    addi x22, x22, 1 # i++
    j Loop2
    Exit2:

    li a7, 10
    ecall
