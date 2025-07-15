# Authors: Arshveer Singh and Ashrit Madamraju
# Description: This file displays the grid

# File: display_grid.asm

.include "SysCalls.asm"

.data
    row_labels: .asciiz "      1       2        3      4\n"  # Labels for grid columns
    row_separator: .asciiz " +-----+-----+-----+-----+-----+\n"  # Separator between rows
    row_start: .asciiz " |"  # Row start (separator before first cell in a row)
    cell_space: .asciiz " "  # Space to be printed before content in each cell
    row_mid: .asciiz "|"  # Middle separator between columns
    row_end: .asciiz "|\n"  # End of row (right edge)
    hidden_card: .asciiz "  *  "  # Placeholder for hidden card

.text
.globl display_grid

display_grid:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Print row labels
    li $v0, SysPrintString  # Syscall to print string
    la $a0, row_labels
    syscall # System call runs

    # Print top separator
    li $v0, SysPrintString  # Syscall to print string
    la $a0, row_separator
    syscall # System call runs

    # Initialize row counter
    li $t0, 0  # Row counter (0-3)

row_loop:
    # Print row number
    li $v0, SysPrintInt  # Syscall to print integer
    addi $a0, $t0, 1  # Print row number (1-4)
    syscall # System call runs

    # Print row start
    li $v0, SysPrintString  # Syscall to print string
    la $a0, row_start
    syscall # System call runs

    # Initialize column counter
    li $t1, 0  # Column counter (0-3)

col_loop:
    # Calculate index into display_board
    mul $t2, $t0, 4  # row * 4
    add $t2, $t2, $t1  # + column
    sll $t2, $t2, 2  # Multiply by 4 (word size)
    la $t3, display_board
    add $t3, $t3, $t2
    lw $t4, 0($t3)  # Load expression address

    # Print space before content
    li $v0, SysPrintString  # Syscall to print string
    la $a0, cell_space
    syscall # System call runs

    # Print cell content
    beqz $t4, print_hidden  # If address is 0, print hidden card

    # Print expression
    li $v0, SysPrintString  # Syscall to print string
    move $a0, $t4
    syscall # System call runs
    j after_print

print_hidden:
    li $v0, SysPrintString  # Syscall to print string
    la $a0, hidden_card
    syscall # System call runs

after_print:
    # Print space after content
    li $v0, SysPrintString  # Syscall to print string
    la $a0, cell_space
    syscall # System call runs

    # Print cell separator
    li $v0, SysPrintString  # Syscall to print string
    la $a0, row_mid
    syscall # System call runs

    # Increment column counter and continue if not done
    addi $t1, $t1, 1
    blt $t1, 4, col_loop

    # Print row end
    li $v0, SysPrintString  # Syscall to print string
    la $a0, row_end
    syscall # System call runs

    # Print row separator
    li $v0, SysPrintString  # Syscall to print string
    la $a0, row_separator
    syscall # System call runs

    # Increment row counter and continue if not done
    addi $t0, $t0, 1
    blt $t0, 4, row_loop

    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
