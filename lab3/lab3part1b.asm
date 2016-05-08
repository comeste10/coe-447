# Steve Comer
# 6 Feb 2012
# Lab 3 part 1b
# takes input integer from user and outputs bits 20,19,18 as an integer

.data
ask_input:	.asciiz 	"Please enter your integer:\n"	
tell_output:	.asciiz		"Here is the output: "

.text

la $a0, ask_input			# load string
li $v0, 4				# print string
syscall					# syscall(4)

li  $v0, 5          			# read integer
syscall					# syscall(5)

add $t1, $v0, $zero			# store integer in t1

srl $t2, $t1, 18			# get rid of the first 17 (0-16) of input integer

andi $t3, $t2, 7			# make sure that the rest of the bits (21-31) are 0

la $a0, tell_output			# load string
li $v0, 4				# print string
syscall					# syscall(4)

la $a0, 0($t3)				# load the number in t3, which is bits (20,19,18) of input integer
li $v0, 1				# print integer
syscall					# syscall(1)
