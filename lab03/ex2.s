.globl main

.data
source:
    .word   3
    .word   1
    .word   4
    .word   1
    .word   5
    .word   9
    .word   0
dest:
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0

.text
fun:
    addi t0, a0, 1 # a0 is x 
    sub t1, x0, a0 # t1 = -x
    mul a0, t0, t1 # a0 = x * (-x)
    jr ra # jump and return to ra

main:
    # BEGIN PROLOGUE
    addi sp, sp, -20
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw ra, 16(sp) # return address
    # END PROLOGUE
    addi t0, x0, 0 # t0 = 0  (representing k)
    addi s0, x0, 0 # s0 = 0 (sum of results)
    la s1, source # load address of source to s1
    la s2, dest # load address of dest to s2
loop:
    slli s3, t0, 2 # s3 = t0 * 4 (word offset)
    add t1, s1, s3 #  t1 = address of source[t0]
    lw t2, 0(t1) # load source[t0] into t2
    beq t2, x0, exit # if source[t0] == 0, exit loop
    add a0, x0, t2 # a0 = t2
    addi sp, sp, -8 # allocate space on stack
    sw t0, 0(sp) # save t0 (k)
    sw t2, 4(sp) # save t2 (x)
    jal fun # call fun
    lw t0, 0(sp) # t0 = k (restore)
    lw t2, 4(sp) # t2 = x (restore)
    addi sp, sp, 8 # deallocate stack space
    add t2, x0, a0 # t2 = result of fun(x)
    add t3, s2, s3 # t3 = address of dest[t0]
    sw t2, 0(t3)  # store result in dest[t0]
    add s0, s0, t2 # add result to sum
    addi t0, t0, 1 # increment k
    jal x0, loop # jump to loop
exit:
    add a0, x0, s0 # a0 = sum of results
    # BEGIN EPILOGUE
    lw s0, 0(sp) # restore s0
    lw s1, 4(sp) # restore s1
    lw s2, 8(sp) # restore s2
    lw s3, 12(sp) # restore s3
    lw ra, 16(sp) # restore return address
    addi sp, sp, 20 # deallocate stack space
    # END EPILOGUE
    jr ra # return to caller
