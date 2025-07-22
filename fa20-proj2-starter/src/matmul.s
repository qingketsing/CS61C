.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 72.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 73.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 74.
# =======================================================
matmul:

    # Error checks
    blez a1, exit_72
    blez a2, exit_72
    blez a4, exit_73
    blez a5, exit_73
    bne a2, a4, exit_74

    # Prologue - 保存更多寄存器
    addi sp, sp, -48
    sw ra, 0(sp)
    sw s0, 4(sp)    # 保存 i
    sw s1, 8(sp)    # 保存 j  
    sw s2, 12(sp)   # 保存临时变量
    sw s3, 16(sp)   # 保存临时变量
    sw s4, 20(sp)   # 保存原始参数
    sw s5, 24(sp)
    sw s6, 28(sp) 
    sw s7, 32(sp)
    sw s8, 36(sp)
    sw s9, 40(sp)
    sw s10, 44(sp)  # 保存 a6 (结果矩阵指针)

    j outer_loop_start

outer_loop_start:
    li s0, 0 # i = 0
    
    # 保存原始参数到 s 寄存器
    mv s4, a0   # s4 = m0 指针
    mv s5, a1   # s5 = m0 行数  
    mv s6, a2   # s6 = m0 列数
    mv s7, a3   # s7 = m1 指针
    mv s8, a4   # s8 = m1 行数
    mv s9, a5   # s9 = m1 列数
    mv s10, a6  # s10 = 结果矩阵指针
    # a6 (结果矩阵指针) 保持不变
    
    j outer_loop_continue

outer_loop_continue:
    bge s0, s5, outer_loop_end  # 使用 s5 (m0行数)
    li s1, 0 # j = 0
    
    j inner_loop_start


inner_loop_start:
    bge s1, s9, inner_loop_end 

    mul s2, s0, s6      # s2 = i * m0_width 
    slli s2, s2, 2      # s2 = i * m0_width * 4 (每个int是4字节)
    add s2, s4, s2      # s2 = m0 + i * m0_width * 4 (m0第i行的地址)

    slli s3, s1, 2      # s3 = j * 4
    add s3, s7, s3      # s3 = m1 + j * 4 (m1第j列的起始地址)

    
    mv a0, s2           # a0 = m0第i行的地址
    mv a1, s3           # a1 = m1第j列的地址  
    mv a2, s6           # a2 = 向量长度 (m0的宽度)
    li a3, 1            # a3 = m0的stride (连续访问)
    mv a4, s9           # a4 = m1的stride (每次跳过一行，即m1的宽度)
    
    jal dot             # 调用点积函数

    mul t0, s0, s9      # t0 = i * d_width (d的宽度 = m1的宽度)
    add t0, t0, s1      # t0 = i * d_width + j
    slli t0, t0, 2      # t0 = (i * d_width + j) * 4
    add t0, s10, t0     # t0 = d + (i * d_width + j) * 4
    sw a0, 0(t0)        # 存储点积结果到 d[i][j]

inner_loop_continue: 
    addi s1, s1, 1 # j++
    
    j inner_loop_start


inner_loop_end:
   addi s0, s0, 1
   j outer_loop_continue

outer_loop_end:
    # Epilogue
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
    addi sp, sp, 48
    ret

exit_72:
    li a1, 72
    jal exit2

exit_73:
    li a1, 73
    jal exit2

exit_74:
    li a1, 74
    jal exit2