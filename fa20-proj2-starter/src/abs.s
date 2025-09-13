.globl abs

.text
# =================================================================
# FUNCTION: Given an int return its absolute value.
# Arguments:
# 	a0 (int) is input integer
# Returns:
#	a0 (int) the absolute value of the input
# =================================================================
abs:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    # Check if input is negative (MSB = 1)
    bltz a0, minus # if a0 < 0, jump to minus
    
    # If positive, restore stack and return
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

minus:
    # Negate the value: a0 = -a0
    sub a0, x0, a0
    
    # Epilogue
    lw ra, 0(sp)
    addi sp, sp, 4
    ret