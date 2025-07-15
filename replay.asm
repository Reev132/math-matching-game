# Authors: Arshveer Singh and Ashrit Madamraju
# Description: This file handles asking the user if they would like to play again and validates the input.

# File: replay.asm

.include "SysCalls.asm" # Include the file with syscall constants.

.data
    replay_prompt: .asciiz "\nWould you like to play again? (y/n): "
    # Prompt asking if the user wants to replay the game.

    invalid_input_msg: .asciiz "Invalid input. Please enter 'y' or 'n'.\n"
    # Message displayed when the user enters invalid input.

.text
.globl ask_replay

ask_replay:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)

replay_loop:
    # Print replay prompt
    li $v0, SysPrintString              # Load the system call code for printing a string
    la $a0, replay_prompt               # Load the address of the replay_prompt string
    syscall # System call runs            Perform syscall to print the replay prompt

    # Read character input
    li $v0, SysReadChar                 # Load the system call code for reading a character (12)
    syscall # System call runs          # Perform syscall to read a single character

    # Check for valid input
    beq $v0, 'y', replay_yes            # If input is 'y', jump to replay_yes
    beq $v0, 'Y', replay_yes            # If input is 'Y', jump to replay_yes
    beq $v0, 'n', replay_no             # If input is 'n', jump to replay_no
    beq $v0, 'N', replay_no             # If input is 'N', jump to replay_no
    
    # Invalid input
    li $v0, SysPrintString             # Load the system call code for printing a string (4)
    la $a0, invalid_input_msg          # Load the address of the invalid_input_msg string
    syscall # System call runs         # Perform syscall to print the invalid input message
    j replay_loop                      # Jump back to replay_loop to prompt again

replay_yes:
    li $v0, 1                          # Return 1 for yes (indicating to replay)
    j replay_end                       # Jump to replay_end to exit

replay_no:
    li $v0, 0                          # Return 0 for no (indicating not to replay)

replay_end:
    # Restore return address
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra                              # Return to caller
