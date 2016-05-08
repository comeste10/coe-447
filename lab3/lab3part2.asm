# Steve Comer
# 6 Feb 2012
# Lab 3 part 2

# takes input string and flips case of all letters
# XOR each character with 0x20

.data
input_string:	.space		32				
ask_input:	.asciiz		"Please enter your string: \n"
tell_output:	.asciiz		"Here is the output: "
space:		.asciiz		" "

.text
la $a0, ask_input		# load string
li $v0, 4			# print string
syscall				# syscall(4)

la $a0, input_string		# input prompt
li $a1, 32			# max number of characters to read
li $v0, 8			# read string	
syscall				# syscall(8)

la $t0, 0($a0)			# load address of user input string
add $t7, $t0, $zero		# copy address

LOOP:
lb $t1, 0($t0)			# load 1 byte
beq $t1, 0xA, PRINT		# branch to print statement
xor $t1, $t1, 0x20		# flip case of character
sb $t1, 0($t0)			# store 1 byte
addi $t0, $t0, 1		# increment address pointer
j LOOP				# return to LOOP start

PRINT:
li $v0, 4			# print string

la $a0, tell_output		# string to print
syscall				# syscall(4)

la $a0, 0($t7)			# load address of copy of mem address
syscall				# syscall(4)

la $a0, space
syscall

la $a0, 11($t7)
syscall


EXIT:
li $v0, 10
syscall

