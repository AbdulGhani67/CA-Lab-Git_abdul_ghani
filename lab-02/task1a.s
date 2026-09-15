.text
.globl main
main:

    # if (i == j)
    # f = g + h;
    # else
    # f = g - h;

    # assuming that variables f to j are in registers x19-x23
    li x20, 5          # g = 5
    li x21, 3          # h = 3
    li x22, 7          # i = 7
    li x23, 7          # j = 7  (set to 8 to test the else branch)

    bne x22, x23, Else
    add x19, x20, x21
    beq x0, x0, Exit        # unconditional jump
    Else: sub x19, x20, x21

    Exit:                   # the code after if/else goes here

    li a7, 10
    ecall
