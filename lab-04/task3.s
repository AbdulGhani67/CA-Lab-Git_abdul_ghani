.data
arr:    .word 5, 2, 9, 1, 7, 3, 8, 4      # test array (8 words)
.text
main:
    la   s0, arr             # s0 = &arr[0]  (saved regs survive the calls)
    addi s1, x0, 8           # s1 = len = 8

    addi a0, s0, 0           # print the array BEFORE sorting
    addi a1, s1, 0
    jal  ra, print_array

    addi a0, s0, 0           # a = x10
    addi a1, s1, 0           # len = x11
    jal  ra, bubble          # sort in place

    addi a0, s0, 0           # print the array AFTER sorting
    addi a1, s1, 0
    jal  ra, print_array

    addi a0, x0, 10          # exit
    ecall

bubble:
    beq  a0, x0, b_done      # if (a == NULL) return
    beq  a1, x0, b_done      # if (len == 0) return
    addi t0, x0, 0           # i = 0
outer:
    bgeu t0, a1, b_done      # while (i < len)   (unsigned compare)
    slli t2, t0, 2           # t2 = i*4
    add  t2, a0, t2          # t2 = &a[i]  (computed once per outer pass)
    lw   t3, 0(t2)           # t3 = a[i]   (kept in a register)
    addi t1, t0, 0           # j = i
inner:
    bgeu t1, a1, next_i      # while (j < len)
    slli t4, t1, 2           # t4 = j*4
    add  t4, a0, t4          # t4 = &a[j]
    lw   t5, 0(t4)           # t5 = a[j]
    bge  t3, t5, no_swap     # if !(a[i] < a[j]) skip the swap
    sw   t5, 0(t2)           # a[i] = a[j]
    sw   t3, 0(t4)           # a[j] = old a[i]   (temp is t3)
    addi t3, t5, 0           # a[i] register copy now holds new a[i]
no_swap:
    addi t1, t1, 1           # j++
    jal  x0, inner
next_i:
    addi t0, t0, 1           # i++
    jal  x0, outer
b_done:
    jalr x0, 0(ra)           # return

print_array:
    addi t0, a0, 0           # t0 = pointer
    addi t1, a1, 0           # t1 = elements left
pa_loop:
    beq  t1, x0, pa_done
    lw   a1, 0(t0)           # a1 = element
    addi a0, x0, 1           # ecall 1 = print int
    ecall
    addi a1, x0, 32          # ' '
    addi a0, x0, 11          # ecall 11 = print char
    ecall
    addi t0, t0, 4           # next element
    addi t1, t1, -1
    jal  x0, pa_loop
pa_done:
    addi a1, x0, 10          # newline
    addi a0, x0, 11
    ecall
    jalr x0, 0(ra)