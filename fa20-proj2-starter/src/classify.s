.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    # Check if argc is 5
    addi t0, x0, 5
    bne a0, t0, exit_89

    # =====================================
    # Prologue
    # =====================================
    addi sp, sp, -76
    sw ra, 0(sp)
    sw s0, 4(sp)              # s0: argv (command line arguments array)
    sw s1, 8(sp)              # s1: print_classification (print flag)
    sw s2, 12(sp)             # s2: m0 matrix pointer
    sw s3, 16(sp)             # s3: m0 rows
    sw s4, 20(sp)             # s4: m0 columns
    sw s5, 24(sp)             # s5: m1 matrix pointer  
    sw s6, 28(sp)             # s6: m1 rows
    sw s7, 32(sp)             # s7: m1 columns
    sw s8, 36(sp)             # s8: input matrix pointer
    sw s9, 40(sp)             # s9: input rows
    sw s10, 44(sp)            # s10: input columns
    sw s11, 48(sp)            # s11: D1 matrix pointer (temporary)
    # Reserve extra space for matrix dimensions

    # =====================================
    # LOAD MATRICES
    # =====================================

    # Save arguments
    mv s0, a1
    mv s1, a2                 # Note: a2 might not be set in some tests, but we'll use it as is

    # Load pretrained m0
    lw a0, 4(s0)              # a0 = argv[1] (M0_PATH)
    addi a1, sp, 52           # a1 = address for rows
    addi a2, sp, 56           # a2 = address for columns

    jal read_matrix

    mv s2, a0                 # Save m0 matrix pointer
    lw s3, 52(sp)             # Load m0 rows
    lw s4, 56(sp)             # Load m0 columns

    # Load pretrained m1
    lw a0, 8(s0)              # a0 = argv[2] (M1_PATH)
    addi a1, sp, 60           # a1 = address for rows
    addi a2, sp, 64           # a2 = address for columns

    jal read_matrix

    mv s5, a0                 # Save m1 matrix pointer
    lw s6, 60(sp)             # Load m1 rows
    lw s7, 64(sp)             # Load m1 columns

    # Load input matrix
    lw a0, 12(s0)             # a0 = argv[3] (INPUT_PATH)
    addi a1, sp, 68           # a1 = address for rows
    addi a2, sp, 72           # a2 = address for columns

    jal read_matrix

    mv s8, a0                 # Save input matrix pointer
    lw s9, 68(sp)             # Load input rows
    lw s10, 72(sp)            # Load input columns

    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    # Allocate space for D1 = m0 * input
    mv t0, s3                 # t0 = m0_rows
    mv t1, s10                # t1 = input_cols
    mul t0, t0, t1            # t0 = m0_rows * input_cols (total elements)
    slli t0, t0, 2            # t0 = total elements * 4 (bytes)
    mv a0, t0                 # a0 = bytes to allocate
    
    jal malloc

    beq a0, x0, malloc_error

    mv s11, a0                # Save D1 matrix pointer

    # Perform first matrix multiplication: D1 = m0 * input
    mv a0, s2                 # a0 = m0 matrix pointer
    mv a1, s3                 # a1 = m0_rows
    mv a2, s4                 # a2 = m0_cols  
    mv a3, s8                 # a3 = input matrix pointer
    mv a4, s9                 # a4 = input_rows
    mv a5, s10                # a5 = input_cols
    mv a6, s11                # a6 = D1 result matrix pointer

    jal matmul

    # Apply ReLU to D1
    mv a0, s11                # a0 = D1 matrix pointer
    mul a1, s3, s10           # a1 = total elements in D1

    jal relu

    # Allocate space for D2 = m1 * ReLU(D1)
    # Calculate D2 matrix size: m1_rows × input_cols × 4 bytes
    mv t0, s6                 # t0 = m1_rows  
    mv t1, s10                # t1 = input_cols
    mul t0, t0, t1            # t0 = m1_rows × input_cols (total elements)
    slli t0, t0, 2            # t0 = total elements × 4 (bytes)
    mv a0, t0                 # a0 = bytes to allocate

    # Allocate D2 memory
    jal malloc

    # Check if malloc succeeded
    beq a0, x0, malloc_error

    # Save D2 matrix pointer on stack
    sw a0, 52(sp)             # Store D2 pointer at stack offset 52

    # Perform second matrix multiplication: D2 = m1 * ReLU(D1)
    mv a0, s5                 # a0 = m1 matrix pointer
    mv a1, s6                 # a1 = m1_rows
    mv a2, s7                 # a2 = m1_cols
    mv a3, s11                # a3 = ReLU(D1) matrix pointer 
    mv a4, s3                 # a4 = ReLU(D1)_rows (= m0_rows)
    mv a5, s10                # a5 = ReLU(D1)_cols (= input_cols)
    lw a6, 52(sp)             # a6 = D2 result matrix pointer (load from stack)

    jal matmul                # Execute second matrix multiplication

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    lw a0, 16(s0)             # a0 = argv[4] (OUTPUT_PATH)
    lw a1, 52(sp)             # a1 = D2 matrix pointer (load from stack)
    mv a2, s6                 # a2 = output matrix rows (m1_rows)
    mv a3, s10                # a3 = output matrix columns (input_cols)

    jal write_matrix

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax to find classification
    lw a0, 52(sp)             # a0 = D2 matrix pointer (load from stack)
    mul a1, s6, s10           # a1 = total elements in D2
    
    jal argmax

    # Save classification result on stack
    sw a0, 56(sp)             # Store classification result at stack offset 56

    # Print classification if required (s1 was print_classification, now contains result)
    beq s1, x0, print_result  # If original print_classification == 0, print the result

    j cleanup                 # Don't print, jump to cleanup

print_result:
    lw a1, 56(sp)             # a1 = classification result (load from stack) - print_int expects value in a1
    jal print_int             # Print classification result
    
    # Print newline character
    li a1, 10                 # ASCII code 10 = '\n' - print_char expects char in a1
    jal print_char            # Print newline

cleanup:
    # Free allocated memory
    mv a0, s2                 # Free m0
    jal free

    mv a0, s5                 # Free m1
    jal free

    mv a0, s8                 # Free input
    jal free

    mv a0, s11                # Free D1
    jal free

    lw a0, 52(sp)             # Free D2 (load from stack)
    jal free

    # Restore return value
    lw a0, 56(sp)             # Reset return value to classification result (load from stack)

    # =====================================
    # Epilogue - restore registers
    # =====================================
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    lw s9, 40(sp)
    lw s10, 44(sp)
    lw s11, 48(sp)
    addi sp, sp, 76

    ret

# =====================================
# Error handling
# =====================================
exit_89:
    li a0, 89
    jal exit2

malloc_error:
    li a0, 88
    jal exit2