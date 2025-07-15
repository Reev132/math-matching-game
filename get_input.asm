# Authors: Arshveer Singh and Ashrit Madamraju
# Description: This file handles user input for row and column selection, ensuring the input is valid.

# File: get_input.asm

.include "SysCalls.asm" # Include the file with syscall constants for better readability.

.text
.globl get_input

get_input:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)

input_loop:
    # Prompt for row
    li $v0, SysPrintString              # Load the system call code for printing a string (4)
    la $a0, prompt_row                 # Load address of prompt_row
    syscall # System call runs                       # Perform syscall to print the row prompt

    # Read row input
    li $v0, SysReadInt                 # Load the system call code for reading an integer (5)
    syscall # System call runs                       # Perform syscall to read the integer input
    move $t0, $v0                      # Store row input in $t0

    # Prompt for column
    li $v0, SysPrintString              # Load the system call code for printing a string (4)
    la $a0, prompt_column              # Load address of prompt_column
    syscall # System call runs                       # Perform syscall to print the column prompt

    # Read column input
    li $v0, SysReadInt                 # Load the system call code for reading an integer (5)
    syscall # System call runs                       # Perform syscall to read the integer input
    move $t1, $v0                      # Store column input in $t1

    # Validate row and column
    li $t2, 1                          # Lower bound check (1)
    li $t3, 4                          # Upper bound check (4)

    # Check if row is valid
    blt $t0, $t2, invalid_input        # If row < 1, jump to invalid_input
    bgt $t0, $t3, invalid_input        # If row > 4, jump to invalid_input

    # Check if column is valid
    blt $t1, $t2, invalid_input        # If column < 1, jump to invalid_input
    bgt $t1, $t3, invalid_input        # If column > 4, jump to invalid_input

    # Return values
    move $v0, $t0                      # Return row in $v0
    move $v1, $t1                      # Return column in $v1

    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

invalid_input:
    # Print error message
    li $v0, SysPrintString             # Load the system call code for printing a string (4)
    la $a0, error_message              # Load address of error_message
    syscall # System call runs                      # Perform syscall to print the error message

    # Jump back to input loop to ask for valid input again
    j input_loop

.data
    prompt_row: .asciiz "Enter row number: "
    # Message prompting the user to enter a row number.

    prompt_column: .asciiz "Enter column number: "
    # Message prompting the user to enter a column number.

    error_message: .asciiz "Invalid coordinate. Please enter a number between 1 and 4.\n"
    # Error message displayed when the user inputs invalid coordinates.
