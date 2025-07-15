# Authors: Arshveer Singh and Ashrit Madamraju
# Description: This file displays the game instructions to the user.

# File: display_instructions.asm

.include "SysCalls.asm"  # Include the file with syscall constants for better readability.

.data
    instructions_msg: .asciiz "\nWelcome to the Math Matching Game!\n" 
    # Message displayed as a welcome greeting to the player.

    game_rules: .asciiz "Rules:\n1. You will be shown a 4x4 grid of hidden cards.\n2. Select two cards at a time to reveal them.\n3. Match expressions with their correct result to clear them.\n4. Try to match all pairs as quickly as possible.\nGood luck!\n\n" 
    # Detailed rules explaining how to play the game.

.text
.globl display_instructions 
# Make the subroutine available globally so it can be used in other files.

display_instructions:
    li $v0, SysPrintString  # Load the system call code for printing a string (defined as SysPrintString in SysCalls.asm).
    
    la $a0, instructions_msg  # Load the address of the welcome message into $a0.
    
    syscall  # Perform the system call to print the welcome message.

    li $v0, SysPrintString  # Load the system call code for printing a string again (SysPrintString).
    
    la $a0, game_rules  # Load the address of the game rules into $a0.
    
    syscall  # Perform the system call to print the game rules.

    jr $ra  # Return to the caller after displaying the instructions.
