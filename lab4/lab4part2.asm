# Steve Comer
# 13 Feb 2012
# Lab 4 Part 2

#CS/COE 447 Lab 4 Part 2 Template

#This template includes testing code, but also has some support code to check
#for a common error.

.text:
        #This is the beginning of the testing code. 

	# you may put additional instructions to calculate the addresses and bit patterns

	li $a0, 0xFFFF0008	# replace your_address with the actual address
        li $a1, 0x7EF965BD    	# replace your_pattern with the actual pattern
        li $a2, 7               # Draw the pattern 7 times vertically.
        jal drawRepeatedPattern # Jump and link to drawRepeatedPattern.

	li $a0, 0xFFFF0038	# replace your_address with the actual address
        li $a1, 0x8E096C4D    	# replace your_pattern with the actual pattern
        li $a2, 7               # Draw the pattern 7 times vertically.
        jal drawRepeatedPattern # Jump and link to drawRepeatedPattern.

		# do not alter 
        la $a0, successfulQuitMessage
        li $v0, 4
        syscall

        li $v0, 10             #Exit syscall
        syscall

        #This is the end of the testing code.

#========================================
# * Place your drawPattern code here    *
#========================================
    drawPattern:
        sw $a1, 0($a0)
	jr $ra


#========================================
# * DO NOT ALTER THIS NEXT LINE         *
j returnErrorHappened
#========================================


#========================================
# * Place drawRepeatedPattern code here *
#========================================
# $a0 = *address, will be updated throughout for use in drawPattern function
# $a1 = bitPattern
# $a2 = number of times to iterate
# $t0 = copy of a2 that is decremented each time through loop
    drawRepeatedPattern:
    	move $t7, $ra
    	move $t0, $a2
    	LOOP:
    	beq $t0, 0, ENDLOOP		# check for exit condition (times to iterate = 0)
    	jal drawPattern
    	addi $a0, $a0, 32
        subi $t0, $t0, 1		# decrement number of times to iterate
	j LOOP
	ENDLOOP:
	move $ra, $t7
	jr $ra

#========================================
# * DO NOT ALTER THIS NEXT LINE         *
j returnErrorHappened
#========================================


returnErrorHappened:
    #If this code is executed, your function did not properly return.
    la $a0, badReturnMessage
    li $v0, 4
    syscall
    li $v0, 10
    syscall

.data:
    badReturnMessage:       .asciiz "A function did not properly return!"
    successfulQuitMessage:  .asciiz "The program has finished."
