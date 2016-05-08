# Purpose:	Get x and y from user, z = x - y
# Author:	Steve Comer
# Date:		3 Feb 2012

# variables
.data
#x:	.word	0
#y:	.word	0
#z:	.word	0
s_1:	.asciiz "What is the first value?\n"
s_2:	.asciiz "What is the second value?\n"
s_3:	.asciiz "The difference of "
s_4:	.asciiz " and "
s_5:	.asciiz " is "

# program code
.text

la $a0, s_1		# load address of string 1 into a0
li $v0, 4		# set syscall to print string
syscall			# print string

li $v0, 5		# set syscall to read integer
syscall			# read integer
add $t1, $v0, $zero	# store integer in t1

la $a0, s_2		# load address of string 1 into a0
li $v0, 4		# set syscall to print string
syscall			# print string

li $v0, 5		# set syscall to read integer
syscall			# read integer
add $t2, $v0, $zero	# store integer in t2

sub $t3, $t1, $t2	# store the result of x - y = z in t3

la $a0, s_3		# load address of string 3 into a0
li $v0, 4		# set syscall to print string
syscall			# print string

addi $a0, $t1, 0
li $v0, 1		# set syscall to print integer
syscall			# print string

la $a0, s_4		# load address of string 4 into a0
li $v0, 4		# set syscall to print string
syscall			# print string

addi $a0, $t2, 0
li $v0, 1		# set syscall to print integer
syscall

la $a0, s_5		# load address of string 4 into a0
li $v0, 4		# set syscall to print string
syscall			# print string		

addi $a0, $t3, 0
li $v0, 1		# set syscall to print integer
syscall
