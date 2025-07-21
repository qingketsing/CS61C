.globl factorial

.data
n: .word 8

.text
main:
    la t0, n # load address of n into t0
    lw a0, 0(t0) # load n into a0 , a0 = 8
    jal ra, factorial

    addi a1, a0, 0 # move result to a1
    addi a0, x0, 1 
    ecall # Print Result

    addi a1, x0, '\n'
    addi a0, x0, 11
    ecall # Print newline

    addi a0, x0, 10
    ecall # Exit

factorial:
    addi t0, a0, -1
    # base case
    beq a0, x0, exit
    beq t0, x0, exit # if n == 0, exit
    
    # stack operation
    addi sp, sp, -8
    sw ra, 0(sp)
    sw a0, 4(sp)

    # recursive part
    addi a0, a0, -1
    jal ra, factorial

    # stack operation
    lw t0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 8

    # calculate part
    mul a0, t0, a0
    jr ra

exit:
    addi a0, x0, 1
    jr ra