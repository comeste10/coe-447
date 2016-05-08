# Steve Comer
# Lab 5 Part 1
# 14 Feb 2012

# Purpose: replace 3 random characters in string with * (ascii character = 0x2A)

# FUNCTIONS
# LENGTH: $a0 = *address, $v0 = length
# RANDOM: $a0 = *address, $a1 = length, $t5 = rand_1, $t6 = rand_2, $t7 = rand_3

# STATIC REGISTERS
# $s0 = string length

.data
input_str:	.space	64
ask_input:	.asciiz	"Enter your string?\n"
tell_output:	.asciiz	"Here is your output?\n"
random_array:	.word	0x00, 0x00, 0x00


.text
##############################_MAIN_##################################
MAIN:
li $v0, 4
la $a0, ask_input
syscall

li $v0, 8
la $a0, input_str		# input_str points to string address
li $a1, 32
syscall

la $a0, input_str
jal LENGTH
move $s0, $v0			# $s0 = length

move $a0, $s0			# $a0 = length & upper bound
jal RANDOM			# random_array points to array of three random ints

li $t3, 0x2A			# asterisk ASCII value
la $t0, random_array		# pointer to random_array
la $t7, input_str		# pointer to input_str

lw $t1, 0($t0)			# first random int
add $t7, $t7, $t1		# $t0 now equals position of first random
sb $t3, 0($t7)			# replace character with *
sub $t7, $t7, $t1		# restore address pointer

lw $t1, 4($t0)			# second random int
add $t7, $t7, $t1		# $t0 now equals position of second random
sb $t3, 0($t7)			# replace character with *
sub $t7, $t7, $t1		# restore address pointer

lw $t1, 8($t0)			# third random int
add $t7, $t7, $t1		# $t0 now equals position of third random
sb $t3, 0($t7)			# replace character with *
sub $t7, $t7, $t1		# restore address pointer

li $v0, 4
la $a0, tell_output
syscall

li $v0, 4
la $a0, input_str
syscall

j EXIT
######################################################################


#############################_LENGTH_#################################
LENGTH:
move $t0, $a0			# pointer
addi $t1, $zero, 0		# counter
lengthLoop:
lb $t2, 0($t0)			# current character
beq $t2, 0xA, exitLengthLoop
addi $t0, $t0, 1
addi $t1, $t1, 1
j lengthLoop
exitLengthLoop:
move $v0, $t1
jr $ra
######################################################################


#############################_RANDOM_#################################
RANDOM:
move $t0, $a0			# length & upper bound
addi $t1, $0, 3			# random numbers remaining
la $t2, random_array		# random array pointer
move $t4, $t2

li $v0, 30			# system time
syscall				# $a0 = lower 32 bits
move $s1, $a0			# $s1 = lower 32 bits

move $a1, $s1			# seed
li $a0, 1			# id
li $v0, 40			# set seed
syscall				# seed is set

randomLoop:
addi $a0, $zero, 1		# $a0 = 1
move $a1, $s0			# upper bound
li $v0, 42			# generate random number
syscall				# $a0 has the number
lw $t5, 0($t4)			# first random int
lw $t6, 4($t4)			# second random int
lw $t7, 8($t4)			# third random int
beq $a0, $t5, randomLoop	# check current random int against first
beq $a0, $t6, randomLoop	# check current random int against second
beq $a0, $t7, randomLoop	# check current random int against third
sw $a0, 0($t2)			# if passes tests, store in current address of random_array
beqz $t1, randomLoopExit	# if no random numbers remain, exit loop
addi $t2, $t2, 4		# increment pointer of random_array
addi $t1, $t1, -1		# decrement random numbers remaining
j randomLoop			# jump back to top of loop

randomLoopExit:
jr $ra
######################################################################


##############################_EXIT_##################################
EXIT:
li $v0, 10
syscall
######################################################################












