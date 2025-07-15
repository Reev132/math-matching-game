# Authors: Arshveer Singh and Ashrit Madamraju
# Description: This file handles the logic for the elapsed time.

# File: timer.asm

.include "SysCalls.asm"

.data
    start_time: .word 0               # Stores the initial time when the timer starts
    .globl elapsed_time
    elapsed_time: .word 0            # Stores the elapsed time in seconds
    time_msg: .asciiz "Time elapsed: " # Message to display before showing the elapsed time
    colon: .asciiz ":"               # Colon symbol for formatting the timer display
    newline: .asciiz "\n"            # Newline character

.text
.globl start_timer
.globl update_timer
.globl display_timer

start_timer:
    # Start the timer by retrieving the current system time in milliseconds
    li $v0, 30                # Syscall to get the system time (code 30)
    syscall
    sw $a0, start_time                # Store the start time in memory
    jr $ra                            # Return from the subroutine

update_timer:
    # Update the elapsed time by calculating the difference from the start time
    li $v0, 30                # Syscall to get the system time (code 30)
    syscall
    
    lw $t0, start_time                # Load the start time
    subu $t1, $a0, $t0                # Calculate the elapsed time in milliseconds
    
    li $t2, 1000                      # Convert milliseconds to seconds
    divu $t1, $t2                     # Perform unsigned division
    mflo $t1                          # Move the quotient (seconds) to $t1
    
    sw $t1, elapsed_time              # Store the elapsed time in memory
    jr $ra                            # Return from the subroutine

display_timer:
    # Display the elapsed time in "minutes:seconds" format
    li $v0, SysPrintString            # Syscall to print a string
    la $a0, time_msg                  # Load the address of the time message
    syscall
    
    lw $t0, elapsed_time              # Load the elapsed time in seconds
    
    li $t1, 60                        # Divide by 60 to get minutes and seconds
    divu $t0, $t1                     # Perform unsigned division
    mflo $t2                          # Store the quotient (minutes) in $t2
    mfhi $t3                          # Store the remainder (seconds) in $t3
    
    # Print the minutes (with leading zero if necessary)
    li $v0, SysPrintInt               # Syscall to print an integer
    move $a0, $t2                     # Move minutes to $a0
    bge $a0, 10, print_minutes        # If minutes >= 10, skip leading zero
    li $v0, SysPrintChar              # Syscall to print a character
    li $a0, '0'                       # Load character '0'
    syscall
    li $v0, SysPrintInt               # Syscall to print an integer
    move $a0, $t2                     # Move minutes to $a0
print_minutes:
    syscall
    
    # Print the colon
    li $v0, SysPrintString            # Syscall to print a string
    la $a0, colon                     # Load the address of the colon symbol
    syscall
    
    # Print the seconds (with leading zero if necessary)
    li $v0, SysPrintInt               # Syscall to print an integer
    move $a0, $t3                     # Move seconds to $a0
    bge $a0, 10, print_seconds        # If seconds >= 10, skip leading zero
    li $v0, SysPrintChar              # Syscall to print a character
    li $a0, '0'                       # Load character '0'
    syscall
    li $v0, SysPrintInt               # Syscall to print an integer
    move $a0, $t3                     # Move seconds to $a0
print_seconds:
    syscall
    
    # Print a newline character
    li $v0, SysPrintString            # Syscall to print a string
    la $a0, newline                   # Load the address of the newline character
    syscall
    
    jr $ra                            # Return from the subroutine
