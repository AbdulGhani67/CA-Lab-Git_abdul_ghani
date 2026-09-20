# Task 2: long leaf_example(g, h, i, j) { f = (g + h) - (i + j); return f; }
# g,h,i,j -> x10,x11,x12,x13 ; f -> x20 ; temporaries -> x18, x19
.text
main:
    addi x10, x0, 10        # g = 10
    addi x11, x0, 5         # h = 5
    addi x12, x0, 4         # i = 4
    addi x13, x0, 3         # j = 3  -> expected f = (10+5)-(4+3) = 8
    jal  x1, leaf_example
    addi x11, x10, 0        # print returned value
    li   x10, 1
    ecall
    li   x10, 10            # exit
    ecall
 
leaf_example:
    addi sp, sp, -16        # allocate stack frame (3 words used, 16 for alignment)
    sw   x18, 0(sp)         # save x18
    sw   x19, 4(sp)         # save x19
    sw   x20, 8(sp)         # save x20
    add  x18, x10, x11      # x18 = g + h
    add  x19, x12, x13      # x19 = i + j
    sub  x20, x18, x19      # f = x18 - x19
    addi x10, x20, 0        # return value f -> x10
    lw   x20, 8(sp)         # restore x20
    lw   x19, 4(sp)         # restore x19
    lw   x18, 0(sp)         # restore x18
    addi sp, sp, 16         # free stack frame
    jalr x0, 0(x1)          # return
 