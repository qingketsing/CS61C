.data
.word 2, 4, 6, 8
n: .word 9 # number of Fibonacci terms to compute

.text
main:
    add t0, x0, x0 # t0 = 0
    addi t1, x0, 1 # t1 = 1
    la t3, n # load address of n
    lw t3, 0(t3)
fib:
    beq t3, x0, finish # if n == 0 -> finish
    add t2, t1, t0 # t2 = t1 + t0
    mv t0, t1 # t0 = t1
    mv t1, t2 # t1 = t2
    addi t3, t3, -1 # t3 = t3 - 1
    j fib # repeat loop
finish:
    addi a0, x0, 1 # a0 = 1 
    addi a1, t0, 0 # a1 = t0 
    ecall # print integer ecall
    addi a0, x0, 10 # a0 = 10 (exit code)
    ecall # terminate ecall
