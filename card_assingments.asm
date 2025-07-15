# Authors: Arshveer Singh and Ashrit Madamraju
# Description: This file assigns a card in the grid its appropriate value

# File: card_assignments.asm

.include "SysCalls.asm"  # Include the file with named syscall constants

.data
    .align 2
    # Expressions stored as strings
    expr1: .asciiz "3*5"   # Result: 15
    expr2: .asciiz "4*2"   # Result: 8
    expr3: .asciiz "6*3"   # Result: 18
    expr4: .asciiz "2*9"   # Result: 18
    expr5: .asciiz "7*2"   # Result: 14
    expr6: .asciiz "5*5"   # Result: 25
    expr7: .asciiz "8*2"   # Result: 16
    expr8: .asciiz "3*6"   # Result: 18

    # Results stored as strings
    res1: .asciiz "15"
    res2: .asciiz "8"
    res3: .asciiz "18"
    res4: .asciiz "18"
    res5: .asciiz "14"
    res6: .asciiz "25"
    res7: .asciiz "16"
    res8: .asciiz "18"

    # 4x4 grid to store expression/result addresses
    .align 2
    grid_expressions: .word 0:16   # Placeholder addresses for expressions/results

    # 4x4 grid storing numerical results for matching
    .align 2
    grid_results: .word   15, 8,  18, 18,    # Row 1: Results for expr1-4
                         14, 25, 16, 18,    # Row 2: Results for expr5-8
                         15, 8,  18, 18,    # Row 3: Matching results for row 1
                         14, 25, 16, 18     # Row 4: Matching results for row 2

.text
.globl init_card_assignments
.globl get_expression
.globl get_result

# Initializes the card assignments by storing the addresses of expressions and results in the grid
init_card_assignments:
    # Save return address to stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Base address of the expressions grid
    la $t0, grid_expressions

    # Initialize first row with expr1-4
    la $t1, expr1
    sw $t1, 0($t0)        # Store address of expr1
    la $t1, expr2
    sw $t1, 4($t0)        # Store address of expr2
    la $t1, expr3
    sw $t1, 8($t0)        # Store address of expr3
    la $t1, expr4
    sw $t1, 12($t0)       # Store address of expr4

    # Initialize second row with expr5-8
    la $t1, expr5
    sw $t1, 16($t0)       # Store address of expr5
    la $t1, expr6
    sw $t1, 20($t0)       # Store address of expr6
    la $t1, expr7
    sw $t1, 24($t0)       # Store address of expr7
    la $t1, expr8
    sw $t1, 28($t0)       # Store address of expr8

    # Initialize third row with res1-4
    la $t1, res1
    sw $t1, 32($t0)       # Store address of res1
    la $t1, res2
    sw $t1, 36($t0)       # Store address of res2
    la $t1, res3
    sw $t1, 40($t0)       # Store address of res3
    la $t1, res4
    sw $t1, 44($t0)       # Store address of res4

    # Initialize fourth row with res5-8
    la $t1, res5
    sw $t1, 48($t0)       # Store address of res5
    la $t1, res6
    sw $t1, 52($t0)       # Store address of res6
    la $t1, res7
    sw $t1, 56($t0)       # Store address of res7
    la $t1, res8
    sw $t1, 60($t0)       # Store address of res8

    # Restore return address from stack
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra                # Return to caller

# Retrieves the expression or result string for a given index
get_expression:
    # Input: $a0 = index (0-15)
    # Output: $v0 = address of expression/result string

    # Check if the index is out of bounds
    bltz $a0, expr_error  # If index < 0, jump to expr_error
    li $t0, 15
    bgt $a0, $t0, expr_error # If index > 15, jump to expr_error

    # Load address of the expression from the grid
    la $t0, grid_expressions
    sll $t1, $a0, 2       # Calculate offset: index * 4
    add $t0, $t0, $t1     # Add offset to base address
    lw $v0, 0($t0)        # Load the address of the expression/result
    jr $ra                # Return to caller

expr_error:
    la $v0, expr1         # Return expr1's address as a default
    jr $ra                # Return to caller

# Retrieves the numerical result for a given index
get_result:
    # Input: $a0 = index (0-15)
    # Output: $v0 = numerical result

    # Check if the index is out of bounds
    bltz $a0, result_error  # If index < 0, jump to result_error
    li $t0, 15
    bgt $a0, $t0, result_error # If index > 15, jump to result_error

    # Load numerical result from the grid
    la $t0, grid_results
    sll $t1, $a0, 2       # Calculate offset: index * 4
    add $t0, $t0, $t1     # Add offset to base address
    lw $v0, 0($t0)        # Load the result
    jr $ra                # Return to caller

result_error:
    li $v0, -1            # Return -1 to indicate an error
    jr $ra                # Return to caller
