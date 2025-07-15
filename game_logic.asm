# Authors: Arshveer Singh and Ashrit Madamraju
# Description: This file handles the logic of the game.

# File: game_logic.asm

.include "SysCalls.asm"

.data
    match_msg: .asciiz "Match found!\n"                 # Message for a successful match
    no_match_msg: .asciiz "No match, try again.\n"      # Message for a failed match
    error_msg: .asciiz "Invalid coordinate. Please enter a number between 1 and 4.\n"
    hide_card_error_msg: .asciiz "Error: Attempted to access memory outside of display_board.\n"

.text
.globl check_match
.globl reveal_card
.globl calculate_index

# Function: calculate_index
# Description:
#   Computes the linear index of a card in the 4x4 grid based on its row and column.
# Parameters:
#   $a0 = row (1-4), $a1 = column (1-4)
# Returns:
#   $v0 = index (0-15), or -1 if the input is out of bounds
calculate_index:
    # Save caller's registers
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    
    # Compute the linear index
    addi $t0, $a0, -1     # row - 1
    addi $t1, $a1, -1     # column - 1
    mul $t0, $t0, 4       # (row - 1) * 4
    add $v0, $t0, $t1     # ((row - 1) * 4) + (column - 1)
    
    # Bounds checking
    bltz $v0, calc_error   # Index is less than 0
    li $t0, 15
    bgt $v0, $t0, calc_error  # Index exceeds 15
    j calc_end             # Valid index

calc_error:
    li $v0, -1             # Return -1 for invalid index

calc_end:    
    # Restore caller's registers
    lw $ra, 0($sp)
    lw $t0, 4($sp)
    lw $t1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

# Function: reveal_card
# Description:
#   Reveals the card at the specified row and column by updating display_board.
# Parameters:
#   $a0 = row, $a1 = column
# Updates:
#   Modifies display_board to reveal the card.
reveal_card:
    # Save caller's registers
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    # Calculate index for the given row and column
    jal calculate_index
    move $s0, $v0          # Save the computed index

    # Handle invalid index
    li $t0, -1
    beq $s0, $t0, reveal_error

    # Retrieve the expression for the card
    move $a0, $s0
    jal get_expression
    move $s1, $v0          # Save the expression's address

    # Update display_board with the revealed expression
    la $t0, display_board
    sll $t1, $s0, 2        # Compute memory offset (index * 4)
    add $t0, $t0, $t1
    sw $s1, 0($t0)         # Store the expression in display_board
    j reveal_end

reveal_error:
    # Print error message for invalid coordinates
    li $v0, SysPrintString
    la $a0, error_msg
    syscall # System call runs

reveal_end:
    # Restore caller's registers
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

# Function: check_match
# Description:
#   Checks if two selected cards form a matching pair.
# Parameters:
#   $a0 = index1, $a1 = index2
# Updates:
#   Prints a message indicating whether a match was found.
#   Updates unmatched_cards and hides unmatched cards if necessary.
check_match:
    # Save caller's registers
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)

    move $s0, $a0          # Save index1
    move $s1, $a1          # Save index2

    # Ensure one card is from the top half and one from the bottom half
    li $t0, 8
    blt $s0, $t0, check_first_top
    j check_first_bottom

check_first_top:
    bge $s1, $t0, continue_match  # Top and bottom pair - OK
    j no_match                    # Both cards in top half - not OK

check_first_bottom:
    blt $s1, $t0, continue_match  # Bottom and top pair - OK
    j no_match                    # Both cards in bottom half - not OK

continue_match:
    # Retrieve results for both cards
    move $a0, $s0
    jal get_result
    move $s2, $v0          # Save result of first card

    move $a0, $s1
    jal get_result
    # $v0 now contains result of the second card

    # Compare the two results
    bne $s2, $v0, no_match

    # Match found
    li $v0, SysPrintString
    la $a0, match_msg
    syscall # System call runs

  # First note
    li $a0, 72         # MIDI pitch (C5)
    li $a1, 300        # Duration in milliseconds
    li $a2, 10         # Instrument (Music Box, patch 10)
    li $a3, 100        # Volume
    li $v0, 31         # Syscall for playing MIDI note
    syscall # System call runs

    # Second note
    li $a0, 76         # MIDI pitch (E5)
    li $a1, 300        # Duration in milliseconds
    li $a2, 10         # Instrument (Music Box)
    li $a3, 100        # Volume
    li $v0, 31
    syscall # System call runs

    # Third note
    li $a0, 79         # MIDI pitch (G5)
    li $a1, 300        # Duration in milliseconds
    li $a2, 10         # Instrument (Music Box)
    li $a3, 100        # Volume
    li $v0, 31
    syscall # System call runs


    
    # Decrement the count of unmatched pairs
    lw $t7, unmatched_cards
    addi $t7, $t7, -2
    sw $t7, unmatched_cards
    j check_match_end

no_match:
    # Print no match message
    li $v0, SysPrintString
    la $a0, no_match_msg
    syscall # System call runs

    # Hide both cards by resetting display_board
    la $t2, display_board
    sll $t3, $s0, 2        # Compute offset for index1
    add $t3, $t2, $t3
    sw $zero, 0($t3)       # Hide first card

    sll $t3, $s1, 2        # Compute offset for index2
    add $t3, $t2, $t3
    sw $zero, 0($t3)       # Hide second card

check_match_end:
    # Restore caller's registers
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra
