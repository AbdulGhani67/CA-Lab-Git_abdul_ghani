# Task 1:
.text
main:
    addi x10, x0, 12        # a = 12 -> x10 (first argument)
    addi x11, x0, 30        # b = 30 -> x11 (second argument)
    jal  x1, sum            # call sum(a, b); return address saved in x1
    addi x11, x10, 0        # result returned in x10, move to x11 for printing
    li   x10, 1             # ecall 1 = print integer in x11
    ecall                   # prints 42
    j    exit

sum:
    add  x10, x10, x11      # x10 = a + b (return value goes in x10)
    jalr x0, 0(x1)          # return to caller

exit:
    li   x10, 10            # ecall 10 = exit
    ecall
