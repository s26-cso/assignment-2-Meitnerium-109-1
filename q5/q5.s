.globl main

.section .rodata
file_name: .string "input.txt"
file_mode: .string "r"
out_yes:   .string "Yes\n"
out_no:    .string "No\n"
err_msg:   .string "File open error\n"

.text
main:
    # Prologue
    addi sp, sp, -48
    sd ra, 40(sp)
    sd s0, 32(sp) # FILE *
    sd s1, 24(sp) # length (n)
    sd s2, 16(sp) # left index
    sd s3, 8(sp)  # right index

    # fopen("input.txt", "r")
    la a0, file_name
    la a1, file_mode
    call fopen
    
    # if FILE * == NULL, error
    beqz a0, err_open
    mv s0, a0

    # fseek(s0, 0, SEEK_END)
    mv a0, s0
    li a1, 0
    li a2, 2 # SEEK_END
    call fseek

    # ftell(s0)
    mv a0, s0
    call ftell
    mv s1, a0 # length is in s1

    # Initialize pointers
    li s2, 0       # L = 0
    addi s3, s1, -1 # R = length - 1

check_loop:
    # if L >= R, success
    bge s2, s3, success_match

    # fseek(s0, L, SEEK_SET)
    mv a0, s0
    mv a1, s2
    li a2, 0 # SEEK_SET
    call fseek

    # fgetc(s0)
    mv a0, s0
    call fgetc
    
    # save left char to stack
    sd a0, 0(sp)

    # fseek(s0, R, SEEK_SET)
    mv a0, s0
    mv a1, s3
    li a2, 0 # SEEK_SET
    call fseek

    # fgetc(s0)
    mv a0, s0
    call fgetc
    
    # Compare
    ld t4, 0(sp)   # reload left char
    bne t4, a0, fail_match

    # L++, R--
    addi s2, s2, 1
    addi s3, s3, -1
    j check_loop

success_match:
    la a0, out_yes
    call printf
    j cleanup

fail_match:
    la a0, out_no
    call printf

cleanup:
    mv a0, s0
    call fclose
    li a0, 0
    j end_prog

err_open:
    la a0, err_msg
    call printf
    li a0, 1

end_prog:
    # Epilogue
    ld ra, 40(sp)
    ld s0, 32(sp)
    ld s1, 24(sp)
    ld s2, 16(sp)
    ld s3, 8(sp)
    addi sp, sp, 48
    ret
