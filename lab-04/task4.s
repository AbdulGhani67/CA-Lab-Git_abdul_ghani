.data
data:   .word 12, -7, 45, 3, 28, 19, -15, 33     # 8 signed words
lbl_s:  .string "Sum = "
lbl_M:  .string "Max = "
lbl_m:  .string "Min = "
lbl_a:  .string "Avg = "
nl:     .string "\n"

.text
main:
    addi s0, x0, 111         # marker values in saved regs: after 'analyze' returns,
    addi s1, x0, 222         # step and check s0/s1/s2 are STILL 111/222/333
    addi s2, x0, 333         # (proves the callee saved & restored them)
    la   a0, data
    addi a1, x0, 8           # len = 8
    jal  ra, analyze         # returns a0=sum a1=max a2=min a3=avg
    addi s0, a0, 0           # keep all four results in saved regs
    addi s1, a1, 0
    addi s2, a2, 0
    addi s3, a3, 0

    la   a0, lbl_s           # print "Sum = <sum>"
    addi a1, s0, 0
    jal  ra, print_line
    la   a0, lbl_M
    addi a1, s1, 0
    jal  ra, print_line
    la   a0, lbl_m
    addi a1, s2, 0
    jal  ra, print_line
    la   a0, lbl_a
    addi a1, s3, 0
    jal  ra, print_line

    addi a0, x0, 10          # exit
    ecall

analyze:
    addi sp, sp, -32         # frame: ra + s0..s4 (6 words) -> 32 bytes
    sw   ra, 28(sp)
    sw   s0, 24(sp)
    sw   s1, 20(sp)
    sw   s2, 16(sp)
    sw   s3, 12(sp)
    sw   s4, 8(sp)

    addi s0, a0, 0           # s0 = base  (a0/a1 get clobbered by calls)
    addi s1, a1, 0           # s1 = len

    addi a0, s0, 0
    addi a1, s1, 0
    jal  ra, sum_array       # a0 = sum
    addi s2, a0, 0           # s2 = sum

    addi a0, s0, 0
    addi a1, s1, 0
    jal  ra, max_array
    addi s3, a0, 0           # s3 = max

    addi a0, s0, 0
    addi a1, s1, 0
    jal  ra, min_array
    addi s4, a0, 0           # s4 = min

    div  a3, s2, s1          # a3 = sum / len (integer average)
    addi a0, s2, 0           # return values: a0=sum
    addi a1, s3, 0           #                a1=max
    addi a2, s4, 0           #                a2=min

    lw   s4, 8(sp)           # restore in reverse order
    lw   s3, 12(sp)
    lw   s2, 16(sp)
    lw   s1, 20(sp)
    lw   s0, 24(sp)
    lw   ra, 28(sp)
    addi sp, sp, 32          # release frame
    jalr x0, 0(ra)

sum_array:                   # a0=base a1=len -> a0=sum
    addi t0, x0, 0           # sum = 0
    addi t1, x0, 0           # i = 0
sa_loop:
    bge  t1, a1, sa_end
    slli t2, t1, 2
    add  t2, a0, t2
    lw   t3, 0(t2)
    add  t0, t0, t3
    addi t1, t1, 1
    jal  x0, sa_loop
sa_end:
    addi a0, t0, 0
    jalr x0, 0(ra)

max_array:                   # a0=base a1=len -> a0=max
    lw   t0, 0(a0)           # max = a[0]
    addi t1, x0, 1           # i = 1
mx_loop:
    bge  t1, a1, mx_end
    slli t2, t1, 2
    add  t2, a0, t2
    lw   t3, 0(t2)
    bge  t0, t3, mx_skip     # if max >= a[i] skip
    addi t0, t3, 0           # max = a[i]
mx_skip:
    addi t1, t1, 1
    jal  x0, mx_loop
mx_end:
    addi a0, t0, 0
    jalr x0, 0(ra)

min_array:                   # a0=base a1=len -> a0=min
    lw   t0, 0(a0)           # min = a[0]
    addi t1, x0, 1
mn_loop:
    bge  t1, a1, mn_end
    slli t2, t1, 2
    add  t2, a0, t2
    lw   t3, 0(t2)
    bge  t3, t0, mn_skip     # if a[i] >= min skip
    addi t0, t3, 0           # min = a[i]
mn_skip:
    addi t1, t1, 1
    jal  x0, mn_loop
mn_end:
    addi a0, t0, 0
    jalr x0, 0(ra)

print_line:                  # a0 = label address, a1 = integer
    addi t0, a1, 0           # ecall clobbers a0/a1 -> keep value in t0
    addi a1, a0, 0           # a1 = string address
    addi a0, x0, 4           # ecall 4 = print string
    ecall
    addi a1, t0, 0           # a1 = value
    addi a0, x0, 1           # ecall 1 = print int
    ecall
    la   a1, nl              # newline
    addi a0, x0, 4
    ecall
    jalr x0, 0(ra)