.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 93.
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 94.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 95.
# ==============================================================================
write_matrix:

    # Prologue
    addi sp, sp, -40  # increased stack space for s6 and temporary values
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)  # save s6 for file descriptor
    sw ra, 28(sp)
    # stack slots 32 and 36 will be used for row/col values

    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3

    # open the file
    mv a1, s0
    li a2, 1 # write
    jal fopen

    li t0, -1
    beq a0, t0, open_error
    
    mv s6, a0  # save file descriptor

    # write the row and col to the file
    mv a1, s6  # use file descriptor instead of filename
    sw s2, 32(sp)    # store row count on stack
    addi a2, sp, 32  # address of row count on stack
    li a3, 1
    li a4, 4
    jal fwrite

    li t0, 0
    beq a0, t0, write_error


    mv a1, s6  # use file descriptor instead of filename
    sw s3, 36(sp)    # store column count on stack
    addi a2, sp, 36  # address of column count on stack
    li a3, 1
    li a4, 4
    jal fwrite

    li t0, 0
    beq a0, t0, write_error

    li s4, 0
    mul s5, s2, s3

loop_start:
    mv a1, s6  # use file descriptor instead of filename

    slli t0, s4, 2
    add t0, s1, t0
    mv a2, t0 

    li a3, 1  # write one element at a time
    li a4, 4
    jal fwrite

    li t0, 0
    beq a0, t0, write_error

    addi s4, s4, 1
    blt s4, s5, loop_start

    # flush the file
    mv a0, s6  # use file descriptor instead of filename
    jal fflush
    bne a0, x0, flush_error 

    # close the file
    mv a0, s6  # use file descriptor instead of filename
    jal fclose
    blt a0, zero, close_error 

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)  # restore s6
    lw ra, 28(sp)
    addi sp, sp, 40  # restore stack pointer

    ret

open_error:
    li a0, 93
    jal exit2

write_error:
    li a0, 94
    jal exit2

flush_error:  # added missing flush_error label
    li a0, 95
    jal exit2

close_error:
    li a0, 95
    jal exit2
