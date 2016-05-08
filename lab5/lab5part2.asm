# Steve Comer
# Lab 5 Part 2
# 22 Feb 2012


# int Hanoi(int n) {
#	if(n==1)
#		return 1;
#
#	else
#		return 2*Hanoi(n-1)+1


# FUNCTIONS
#	HANOI: $s2 = number of plates, $s1 = total moves required


# Saved Registers
#	$s0 = multiplier (2)
#	$s1 = number of plates
#	$s2 = moves required

.data
ask_input:	.asciiz	"Enter the number of dishes?\n"
tell_output:	.asciiz "The minimum number of moves?\n"

.text
MAIN:
	li $s0, 2		# multiplier
	
	la $a0, ask_input
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	move $s1, $v0		# user input integer
	
	move $a1, $s1		# plates
	move $a2, $s2		# moves
	jal HANOI
	
j EXIT
	
HANOI:
	beq $a1, 1, exitHanoi
	
	
exitHanoi:
jr $ra


EXIT:
	la $a0, tell_output
	li $v0, 4
	syscall
	
	move $a0, $s2
	li $v0, 1
	syscall
	
	li $v0, 10
	syscall
	
	
