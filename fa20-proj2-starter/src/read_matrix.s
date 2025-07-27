.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -24
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)    # for matrix pointer
    sw s4, 16(sp)    # for byte count
    sw ra, 20(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2
	
    # open the file 
    mv a1, a0
    li a2, 0
    jal fopen

    li t0, -1
    beq a0, t0, open_fail

    # let the s0 became a0 again
    mv s0, a0

    # read file's cols and rows
    mv a1, s0
    mv a2, s1
    addi a3, x0, 4
    jal fread
    li t0, 4
    bne a0, t0, read_fail

    mv a1, s0
    mv a2, s2
    addi a3, x0, 4
    jal fread
    li t0, 4
    bne a0, t0, read_fail

    # read matrix part
    lw t0, 0(s1)
    lw t1, 0(s2)
    mul t2, t0, t1
    slli t2, t2, 2    # t2 = total bytes needed
    mv s4, t2         # save byte count in s4
    
    mv a0, t2
    jal malloc
    beq a0, x0, malloc_fail
    
    # save matrix pointer in s3 (saved register)
    mv s3, a0

    # read part
    mv a1, s0
    mv a2, s3         # use matrix pointer
    mv a3, s4         # use total bytes from s4
    jal fread
    bne a0, s4, read_fail

    # close file 
    mv a1, s0
    jal fclose

    li t0, -1
    beq a0, t0, close_fail
    
    # Set return value to matrix pointer
    mv a0, s3
    
    # Epilogue

    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw ra, 20(sp)
    addi sp, sp, 24

    ret

open_fail:
    li a1, 90
    jal exit2

read_fail:
    li a1, 91
    jal exit2

close_fail:
    li a1, 92
    jal exit2

malloc_fail:
    li a1, 88
    jal exit2