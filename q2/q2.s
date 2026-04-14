.globl main

.section .rodata
fmt_space: .string "%d "
fmt_nl:    .string "\n"
fmt_err:   .string "Usage: ./q2 <integers>\n"

.text
main:
    # prologue
    addi sp, sp, -64
    sd ra, 56(sp)
    sd s0, 48(sp) # n
    sd s1, 40(sp) # arr pointer
    sd s2, 32(sp) # result pointer
    sd s3, 24(sp) # stack pointer
    sd s4, 16(sp) # stack size
    sd s5, 8(sp)  # loop counter i
    sd s6, 0(sp)  # argv pointer

    # calculate n = argc - 1
    addi s0, a0, -1
    blez s0, end_no_args  # if n <= 0, go to end

    # save argv
    mv s6, a1

    # calculate size n * 4
    slli t0, s0, 2
    
    # a0 = n * 4 for malloc(arr)
    mv a0, t0
    call malloc
    mv s1, a0

    # malloc(result)
    slli t0, s0, 2
    mv a0, t0
    call malloc
    mv s2, a0

    # malloc(stack)
    slli t0, s0, 2
    mv a0, t0
    call malloc
    mv s3, a0

    # Parsing arguments
    li s5, 1             # i = 1
parse_loop:
    bgt s5, s0, parse_end # if i > n, end parse
    
    # a0 = argv[i]
    slli t0, s5, 3       # i * 8 (pointers are 8 bytes)
    add t1, s6, t0       # argv + i * 8
    ld a0, 0(t1)         # load string pointer
    
    call atoi
    
    # arr[i - 1] = returned value
    addi t0, s5, -1      # i - 1
    slli t0, t0, 2       # (i - 1) * 4
    add t1, s1, t0       # arr + (i - 1) * 4
    sw a0, 0(t1)         # store int
    
    addi s5, s5, 1
    j parse_loop
    
parse_end:
    # Core Logic
    # stack_size (s4) = 0
    li s4, 0
    
    # loop i (s5) = n - 1 down to 0
    addi s5, s0, -1
logic_loop:
    bltz s5, logic_end   # if i < 0, end loop

    # Curr val index computation
    slli t6, s5, 2       # t6 = i * 4
    add t1, s1, t6       # t1 = arr + curr_idx
    lw t2, 0(t1)         # t2 = arr[i]

inner_while:
    blez s4, inner_end   # if stack_size <= 0, break loop
    
    # read stack top index
    addi t0, s4, -1      # stack_size - 1
    slli t0, t0, 2       # (stack_size - 1) * 4
    add t0, s3, t0       # stack + ...
    lw t3, 0(t0)         # t3 = stack[stack_size - 1]
    
    # read arr[top_idx]
    slli t4, t3, 2       # t3 * 4
    add t4, s1, t4       # arr + top_idx * 4
    lw t5, 0(t4)         # val_at_top = arr[top_idx]
    
    bgt t5, t2, inner_end # if val_at_top > curr_val, break loop
    
    # else, pop stack
    addi s4, s4, -1
    j inner_while

inner_end:
    # Compute result address for i
    slli t6, s5, 2       # i * 4
    add t6, s2, t6       # t6 = result + i * 4
    
    bgtz s4, has_greater
    
    # no greater element
    li t4, -1
    sw t4, 0(t6)
    j push_stack
    
has_greater:
    # result[i] = stack top index
    addi t0, s4, -1      # stack_size - 1
    slli t0, t0, 2
    add t0, s3, t0
    lw t3, 0(t0)         # top_idx
    sw t3, 0(t6)
    
push_stack:
    # stack[stack_size] = i
    slli t0, s4, 2       # stack_size * 4
    add t0, s3, t0       # stack + stack_size * 4
    sw s5, 0(t0)         # store i
    
    addi s4, s4, 1       # stack_size++
    
    addi s5, s5, -1
    j logic_loop

logic_end:
    # Output phase
    li s5, 0             # i = 0
out_loop:
    bge s5, s0, out_end  # if i >= n, end output
    
    la a0, fmt_space     # format "%d "
    slli t0, s5, 2
    add t0, s2, t0
    lw a1, 0(t0)         # result[i]
    call printf
    
    addi s5, s5, 1
    j out_loop
    
out_end:
    la a0, fmt_nl
    call printf
    j end_prog

end_no_args:
    la a0, fmt_err
    call printf

end_prog:
    # free memory
    mv a0, s1
    call free
    mv a0, s2
    call free
    mv a0, s3
    call free

    li a0, 0
    # epilogue
    ld s6, 0(sp)
    ld s5, 8(sp)
    ld s4, 16(sp)
    ld s3, 24(sp)
    ld s2, 32(sp)
    ld s1, 40(sp)
    ld s0, 48(sp)
    ld ra, 56(sp)
    addi sp, sp, 64
    ret
