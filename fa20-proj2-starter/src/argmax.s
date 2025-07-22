.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:

    # Prologue
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp) # used to store the index of max value
    sw s1, 8(sp) # used to store the value of the max

    blez a1, exit_error

    j loop_start

loop_start:
    addi t0, x0, 0 # t0 = 0
    addi s0, x0, 0 # max_value_index = 0
    lui s1, 0x80000 # set the max value is INT_MIN
    j loop_continue

loop_continue:
    beq t0, a1, loop_end
    slli t1, t0, 2 # t1 = t0 << 2
    add t2, a0, t1
    lw t3, 0(t2) # t3 = a0[t0]

    slt t4, t3, s1 # if t3 < s1 , then t4 will be 1
    beq t4, x0, exchange_max

    addi t0, t0, 1
    j loop_continue

loop_end:
    # Epilogue
    mv a0, s0
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12

    ret

exchange_max: 
    add s0, x0, t0
    add s1, x0, t3
    addi t0, t0, 1
    
    j loop_continue

exit_error:
    li a1, 77
    jal exit2