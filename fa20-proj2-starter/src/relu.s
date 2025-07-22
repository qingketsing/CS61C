.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    # Prologue
    addi sp, sp, -4
    sw ra, 0(sp)

    blez a1, error_exit

    j loop_start

loop_start:
    addi t0, x0, 0 # first, we assign t0 is used to represent index and arrange it as 0
    j loop_continue

loop_continue:
    beq t0, a1, loop_end # if the t0 equal to a1, then we jump to loop_end
    slli t1, t0, 2 # t1 = t0 << 2; get the memory position of the number
    add t2, a0, t1 
    lw t3, 0(t2) # t3 = a0[t0]
    
    bltz t3, set_zero

    sw t3, 0(t2)
    addi t0, t0, 1
    j loop_continue

loop_end:

    lw ra, 0(sp)
    addi sp, sp, 4
    
	ret
    
set_zero:
    addi t3, x0, 0
    sw t3, 0(t2)
    addi t0, t0, 1
    j loop_continue

error_exit:
    li a1, 78
    jal exit2