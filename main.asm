# Authors: Arshveer Singh and Ashrit Madamraju
# Description: This file handles the logic of the game as the player progresses through

# File: main.asm

.include "SysCalls.asm"  # Include system call definitions for named syscall 

.data
    .globl unmatched_cards
    unmatched_cards: .word 16  # Initialize unmatched card count to 16

    .globl display_board
    .align 2              # Align display_board to a word boundary
    display_board: .word 0:16  # 16 words initialized to 0


    prompt_first: .asciiz "\nSelect first tile (row and column): "
    prompt_second: .asciiz "\nSelect second tile (row and column): "
    press_enter: .asciiz "\nPress enter to continue...\n"
    win_msg: .asciiz "\nWell Done! You finished in "
    colon: .asciiz ":"  # Colon for time display
    goodbye_msg: .asciiz "\nThanks for playing!\n"
    newline: .asciiz "\n"

.text
.globl main

main:
    # Initialize card assignments
    jal init_card_assignments

    # Initialize the display_board array
    jal init_display_board

    # Display game instructions
    jal display_instructions

    # Start the timer for the game
    jal start_timer

    # Display the initial game grid
    jal display_grid

game_loop:
    # Update and display the timer
    jal update_timer
    jal display_timer

    # Show the number of unmatched pairs remaining
    jal show_unmatched_count

    # Check if the game is complete
    lw $t0, unmatched_cards
    beqz $t0, win_screen  # If unmatched_cards is 0, proceed to win_screen

    # Get the first tile input
    li $v0, SysPrintString  # Print prompt for first tile
    la $a0, prompt_first
    syscall # System call runs
    jal get_input
    move $s0, $v0  # Save row of first tile
    move $s1, $v1  # Save column of first tile

    # Reveal the first tile
    move $a0, $s0
    move $a1, $s1
    jal reveal_card
    jal display_grid  # Refresh the grid display

    # Get the second tile input
    li $v0, SysPrintString  # Print prompt for second tile
    la $a0, prompt_second
    syscall # System call runs
    jal get_input
    move $s2, $v0  # Save row of second tile
    move $s3, $v1  # Save column of second tile

    # Reveal the second tile
    move $a0, $s2
    move $a1, $s3
    jal reveal_card
    jal display_grid  # Refresh the grid display

    # Calculate the index of the first tile
    move $a0, $s0
    move $a1, $s1
    jal calculate_index
    move $a0, $v0  # Save index of first tile
    move $t0, $v0  # Temporarily store the first index

    # Calculate the index of the second tile
    move $a0, $s2
    move $a1, $s3
    jal calculate_index
    move $a1, $v0  # Save index of second tile

    # Check if the tiles match
    move $a0, $t0  # Restore first index
    jal check_match

    # Pause to allow the user to view results
    li $v0, SysPrintString
    la $a0, press_enter
    syscall # System call runs
    li $v0, SysReadChar
    syscall # System call runs

    # Refresh the grid display
    jal display_grid

    # Loop back to continue the game
    j game_loop

win_screen:
    # Update the timer and display the final time
    jal update_timer

    # Print the winning message
    li $v0, SysPrintString
    la $a0, win_msg
    syscall # System call runs

   li $a0, 72         # MIDI pitch (C5)
    li $a1, 200        # Duration in milliseconds
    li $a2, 56         # Instrument (Trumpet, patch 56)
    li $a3, 127        # Volume (maximum)
    li $v0, 31         # Syscall for playing MIDI note
    syscall # System call runs

    # Second note (E5)
    li $a0, 76         # MIDI pitch (E5)
    li $a1, 200        # Duration in milliseconds
    li $a2, 56         # Instrument (Trumpet)
    li $a3, 127        # Volume
    li $v0, 31
    syscall # System call runs

    # Third note (G5)
    li $a0, 79         # MIDI pitch (G5)
    li $a1, 200        # Duration in milliseconds
    li $a2, 56         # Instrument (Trumpet)
    li $a3, 127        # Volume
    li $v0, 31
    syscall # System call runs

    # Fourth note (C6)
    li $a0, 84         # MIDI pitch (C6)
    li $a1, 400        # Duration in milliseconds (longer)
    li $a2, 56         # Instrument (Trumpet)
    li $a3, 127        # Volume
    li $v0, 31
    syscall # System call runs

    # Short pause
    li $a0, 100        # Sleep for 100 milliseconds
    li $v0, 32         # Syscall for sleep
    syscall # System call runs

    # Final chord (C5 + E5 + G5)
    li $a0, 72         # MIDI pitch (C5)
    li $a1, 600        # Duration in milliseconds
    li $a2, 56         # Instrument (Trumpet)
    li $a3, 127        # Volume
    li $v0, 31
    syscall # System call runs

    li $a0, 76         # MIDI pitch (E5)
    li $v0, 31
    syscall # System call runs

    li $a0, 79         # MIDI pitch (G5)
    li $v0, 31
    syscall # System call runs
    
    # Display elapsed time in minutes and seconds
    lw $t0, elapsed_time  # Load elapsed time
    li $t1, 60            # Divide by 60 to get minutes and seconds
    divu $t0, $t1
    mflo $t2  # Minutes
    mfhi $t3  # Seconds

    # Print minutes with leading zero if necessary
    li $v0, SysPrintInt
    move $a0, $t2
    bge $a0, 10, print_minutes
    li $v0, SysPrintChar
    li $a0, '0'
    syscall # System call runs
    li $v0, SysPrintInt
    move $a0, $t2
print_minutes:
    syscall # System call runs

    # Print colon separator
    li $v0, SysPrintString
    la $a0, colon
    syscall # System call runs

    # Print seconds with leading zero if necessary
    li $v0, SysPrintInt
    move $a0, $t3
    bge $a0, 10, print_seconds
    li $v0, SysPrintChar
    li $a0, '0'
    syscall # System call runs
    li $v0, SysPrintInt
    move $a0, $t3
print_seconds:
    syscall # System call runs

    # Print a newline
    li $v0, SysPrintString
    la $a0, newline
    syscall # System call runs

    # Ask if the user wants to replay
    jal ask_replay

    # Replay or exit based on user input
    beq $v0, 1, restart_game
    j end_game

restart_game:
    # Reset game state
    li $t0, 16
    sw $t0, unmatched_cards  # Reset unmatched pairs to 16

    # Clear the display board
    jal init_display_board

    # Restart the timer
    jal start_timer

    # Jump to the start of the game
    j main

end_game:
    # Display goodbye message
    li $v0, SysPrintString
    la $a0, goodbye_msg
    syscall # System call runs

    # Exit the program
    li $v0, SysExit
    syscall # System call runs

init_display_board:
    # Initialize display_board array to all zeros
    la $t0, display_board
    li $t1, 16
    li $t2, 0
init_loop:
    sw $t2, 0($t0)  # Store zero in the current word
    addi $t0, $t0, 4  # Move to the next word
    addi $t1, $t1, -1
    bnez $t1, init_loop
    jr $ra  # Return
