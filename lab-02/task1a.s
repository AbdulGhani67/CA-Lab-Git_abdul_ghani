.text
.globl main 
main:

    if (i == j)
    f = g + h;
    else
    f = g - h;
    // code after if/else goes here

    // assuming that variables i to j are in registers x19-x23
    bne x22, x23, Else
    add x19, x20, x21
    beq x0, x0, Exit // unconditional jump
    Else: sub x19, x20, x21

    Exit: // the code after if/else goes here

    li a7, 10
    ecall
