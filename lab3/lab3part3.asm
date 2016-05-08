# Steve Comer
# 10 Feb 2012
# Lab 3 part 3

.data
buf1:	.space	64
buf2:	.space	64
ask_input:	.asciiz		"Please enter your string: \n"
tell_output:	.asciiz		"Here is the output: "

.text
la $a0, ask_input		# load string
li $v0, 4			# print string
syscall				# syscall(4)

la $a0, buf1			# input prompt
li $a1, 32			# max number of characters to read
li $v0, 8			# read string	
syscall				# syscall(8)

la $t0, buf1
la $t7, buf1

li $t1, 0
LOOP:
lb $t2, 0($t0)
beq $t2, 0xa, NEW_WORD
addi $t0, $t0, 1
addi $t1, $t1, 1
j LOOP

NEW_WORD:

la $t6, buf2
LOOP2:
lb $t3, 0($t0)
sb $t3, 0($t6)
addi $t6, $t6 1
subi $t0, $t0, 1
subi $t1, $t1, 1
blt $t0, $t7, EXIT
j LOOP2

EXIT:

li $v0, 4			# print string

la $a0, tell_output		# string to print
syscall				# syscall(4)

la $a0, buf2
syscall


