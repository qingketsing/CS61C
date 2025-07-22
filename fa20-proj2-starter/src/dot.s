.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 75.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 76.
# =======================================================
dot:
    addi sp, sp, -8
    sw s0, 0(sp) # s0 is used to return the value of dot
    sw ra, 4(sp) # return address

    # error_cases : a2 <= 0 
    blez a2, error_case_1
    # error_cases : a3 <= 0 or a4 <= 0
    blez a3, error_case_2
    blez a4, error_case_2

    j loop_start

error_case_1:
    li a1 75
    jal exit2

error_case_2:
    li a1 76
    jal exit2

loop_start:
    addi t0, x0, 0 # index is zero
    addi s0, x0, 0 # dot_product is zero

    j loop_continue

loop_continue:
    beq t0, a2, loop_end

    mul t1, t0, a3
    slli t1, t1, 2
    add t2, a0, t1

    mul t3, t0, a4
    slli t3, t3, 2
    add t4, a1, t3

    lw t5, 0(t2)
    lw t6, 0(t4)

    mul t1, t5, t6
    add s0, s0, t1

    addi t0, t0, 1

    j loop_continue

loop_end:

    mv a0, s0
    lw s0, 0(sp)
    lw ra, 4(sp)
    addi sp, sp, 8
    ret 
