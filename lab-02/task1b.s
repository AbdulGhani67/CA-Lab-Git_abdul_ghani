.text
.globl main 
main:

    while (save[i] == k)
    i += 1;

    // assuming i and k in x22 and x24, and the base address of save in x25
    Loop: slli x10, x22, 3 // Temp reg x10 = i * 8
    add x10, x10, x25 // x10 = address of save[i]
    ld x9, 0(x10) // Temp reg x9 = save[i]
    bne x9, x24, Exit // go to Exit if save[i] != k
    addi x22, x22, 1 // i = i + 1
    beq x0, x0, Loop // go to Loop
    Exit:

    li a7, 10
    ecall
