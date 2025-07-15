# Authors: Arshveer Singh and Ashrit Madamraju
# Description: This file displays counter showing the amount of unmatched cards remaining

# File: unmatched_counter.asm

.include "SysCalls.asm"

.data
    unmatched_msg: .asciiz "Unmatched cards remaining: "  # Message to display before the count
    newline: .asciiz "\n"                                # Newline character for formatting

.text
.globl show_unmatched_count

show_unmatched_count:
    # Display the message indicating the number of unmatched cards
    li $v0, SysPrintString             # Syscall to print a string
    la $a0, unmatched_msg              # Load the address of the unmatched cards message
    syscall

    # Display the number of unmatched cards
    li $v0, SysPrintInt                # Syscall to print an integer
    lw $a0, unmatched_cards            # Load the count of unmatched cards into $a0
    syscall

    # Print a newline for formatting
    li $v0, SysPrintString             # Syscall to print a string
    la $a0, newline                    # Load the address of the newline character
    syscall

    jr $ra                             # Return from the subroutine
