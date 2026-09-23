.text
main:
    addi x10, x0, 5          # n = 5
    jal  x1, fact            # call fact(5)
    addi x11, x10, 0         # move result to x11 for printing
    addi x10, x0, 1          # ecall 1 = print integer
    ecall                    # prints 120
    addi x10, x0, 10         # ecall 10 = exit
    ecall

fact:                        # NO stack frame: leaf procedure, uses only temporaries
    addi x5, x0, 1           # acc = 1  (x5 = t0)
loop:
    bge  x0, x10, done       # if (0 >= n) i.e. n <= 0 -> exit loop
    mul  x5, x5, x10         # acc = acc * n
    addi x10, x10, -1        # n = n - 1
    jal  x0, loop            # jump back (x0 = no link, plain jump)
done:
    addi x10, x5, 0          # return value = acc  (in x10)
    jalr x0, 0(x1)           # return; x1 was never overwritten