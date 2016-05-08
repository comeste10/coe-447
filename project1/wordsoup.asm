# Steve Comer
# sfc15@pitt.edu
# Project 1 - WordSoup
# 21 Feb 2012

# FUNCTIONS
# 	RANDOM: $a0 = upper bound, $v0 = random number
# 	ADD_ROUND: void
# 	SUB_ROUND: void
# 	PRINT_ROUND: void
# 	PRINT_GAME: void
#	WORD_INIT: $a0 = random dictionary index
#	SCRAMBLE: use saved registers
#	PRINT_SPACES: use saved registers
#	CLEAR: void
#	WHOLE_WORD: use saved registers
#	HINT: use saved registers
# 	EXIT: void

# Saved Registers
#	$s0 = address of current word
#	$s1 = address of word in progess with '_' + '*' + 'a-z' + 'spaces'
#	$s2 = number of question marks used in round
#	$s3 = pointer for hidden word
#	$s4 = length of current word
#	$s5 = user character
#	$s6 = correct letters
#	$s7 = times played

# Notes
#	'*' = 0x2A
#	'_' = 0x5F
#	' ' = 0x20
#	'!' = 0x21
#	'?' = 0x3F
#	'.' = 0x2E


.data
	intro_1:	.asciiz	"Welcome to WordSoup!"
	intro_2:	.asciiz "\nI am thinking of a word. The word is "
	prompt_1:	.asciiz ". Round score is "
	prompt_2:	.asciiz	".\nGuess a letter?\n"
	right_letter:	.asciiz	"\nYes! The word is "
	wrong_letter:	.asciiz	"\nNo! The word is "
	won_round:	.asciiz "\n\nYou won the round! Your final guess was:\n"
	lost_round:	.asciiz "\n\nYou lost the round! Your final guess was:\n"
	quit_round:	.asciiz "\n\nYou quit the round!"
	correct_word:	.asciiz "\nCorrect word was:\n"
	end_rs:		.asciiz "\nYour round score was "
	end_gt:		.asciiz ". The game tally is "
	end_ask:	.asciiz	".\nDo you want to play again (y/n)?\n"
	EXIT_1:		.asciiz "\n\nYour final game tally is "
	EXIT_2:		.asciiz ". Goodbye!"
	prompt_whole:	.asciiz "\nEnter the whole word:\n"
	whole_good:	.asciiz "\nCorrect! You entered:\n"
	whole_bad:	.asciiz "\nIncorrect! You entered:\n"
	w1:		.asciiz	"computer"
	w2:		.asciiz "at"
	w3:		.asciiz	"two"
	w4:		.asciiz "talk"
	w5:		.asciiz	"boats"
	w6:		.asciiz	"sailor"
	w7:		.asciiz	"whiskey"
	w8:		.asciiz "eight"
	w9:		.asciiz	"brew"
	w10:		.asciiz	"ten"
	L1:		.byte	8
	L2:		.byte	2
	L3:		.byte	3
	L4:		.byte	4
	L5:		.byte	5
	L6:		.byte	6
	L7:		.byte	7
	L8:		.byte	5
	L9:		.byte	4
	L10:		.byte	3
	user_input:	.space	8
	input_buffer:	.space  16
	scrambled:	.space	8
	scram_copy:	.space	8
	scram_out:	.space	16
	random_array:	.byte	0x99, 0x99, 0x99, 0x99, 0x99
	round_score:	.byte	0
	game_tally:	.byte	0

.align 2
	dictionary:	.word	w1, w2, w3, w4, w5, w6, w7, w8, w9, w10
	word_lengths:	.word	L1, L2, L3, L4, L5, L6, L7, L8, L9, L10
	

.text
##############################_MAIN_##################################
MAIN:
	la $a0, intro_1			# "Welcome to WordSoup! (1st iteration only)
	li $v0, 4			
	syscall
		
	# IF RESPONSE IS YES, JUMP BACK TO HERE TO START NEW ROUND
	roundLoop:
	
		la $a0, intro_2			# "I am thinking of a word. The word is "
		li $v0, 4
		syscall
		
		beq $s7, $zero, firstTime
		la $a0, 9			# random number generator w/ bound = 9
		jal RANDOM
		j other
		firstTime:
		add $v0, $zero, $zero
		
		other:
		move $a0, $v0			# put random number in $a0	
		jal WORD_INIT
		
		jal SCRAMBLE			# create scrambled word with underscores and asterisks
		
		jal PRINT_SPACES
		
		guessLoop:
						
			la $a0, prompt_1	# ". Round score is "
			li $v0, 4
			syscall
	
			jal PRINT_ROUND		# print round_score
	
			la $a0, prompt_2	# "Guess a letter?"
			li $v0, 4
			syscall
			
			li $v0, 12		# get user input character
			syscall
			move $s5, $v0		# $s5 = input
			
			#CHECK FOR '.' and '!' and '?'
			beq $s5, 0x2E, exitRoundLoopQuit	# check for '.'
			beq $s5, 0x21, WHOLE_WORD		# check for '!'
			#beq $s5, 0x3F, HINT			# check for '?' 
			#MAKE SURE ONLY THREE QUESTION MARKS CAN BE USED #	
			
			
			add $t0, $zero, $zero	# counter and index
			move $t1, $s0		# pointer to real word
			checkInputLoop:
				add $t2, $t1, $t0
				lb $t3, 0($t2)
				beq $s5, $t3, inputRight
				addi $t0, $t0, 1
				beq $t0, $s4, inputWrong
				j checkInputLoop
			inputRight:
				add $s1, $s1, $t0
				lb $t9, 0($s1)
				beq $t9, 0x2A, skipOverwrite
				sb $s5, 0($s1)
				skipOverwrite:
				sub $s1, $s1, $t0
				addi $t0, $t0, 1
				addi $s6, $s6, 1
				beq $s6, $s4, exitRoundLoopPass # PRINT YOU WON THE ROUND
				la $a0, right_letter
				jal PRINT_WORD
				jal PRINT_SPACES				
				j guessLoop		
			inputWrong:
				jal SUB_ROUND
				lb $t4, round_score
				beq $t4, $zero, exitRoundLoopFail	# check if round score is = 0
				la $a0, wrong_letter
				jal PRINT_WORD
				jal PRINT_SPACES
				j guessLoop
	
	exitRoundLoopPass:
		lb $a2, round_score
		lb $a3, game_tally
		add $t9, $a2, $a3
		sb $t9, game_tally	
		la $a0, won_round
		jal PRINT_WORD
		jal PRINT_SPACES
		la $a0, correct_word
		jal PRINT_WORD
		move $t9, $s0
		la $a0, 0($t9)
		jal PRINT_WORD
		la $a0, end_rs
		jal PRINT_WORD
		jal PRINT_ROUND
		la $a0, end_gt
		jal PRINT_WORD
		jal PRINT_GAME
		la $a0, end_ask
		jal PRINT_WORD
		j RETRY
		
	exitRoundLoopFail:
		la $a0, lost_round
		jal PRINT_WORD
		jal PRINT_SPACES
		la $a0, correct_word
		jal PRINT_WORD
		move $t9, $s0
		la $a0, 0($t9)
		jal PRINT_WORD
		la $a0, end_rs
		jal PRINT_WORD
		jal PRINT_ROUND
		la $a0, end_gt
		jal PRINT_WORD
		jal PRINT_GAME
		la $a0, end_ask
		jal PRINT_WORD
		j RETRY
		
	exitRoundLoopQuit:
		sb $zero, round_score					
		la $a0, quit_round
		jal PRINT_WORD
		la $a0, correct_word
		jal PRINT_WORD
		move $t9, $s0
		la $a0, 0($t9)
		jal PRINT_WORD
		la $a0, end_rs
		jal PRINT_WORD
		jal PRINT_ROUND
		la $a0, end_gt
		jal PRINT_WORD
		jal PRINT_GAME
		la $a0, end_ask
		jal PRINT_WORD
		j RETRY
	
	RETRY:
		jal CLEAR
		li $v0, 12			# get user input character
		syscall
		beq $v0, 0x79, roundLoop	# $v0 = input	
		
j EXIT
######################################################################


###############################_HINT_#################################


######################################################################

###########################_WHOLE_WORD_###############################
# user enters whole word (number of characters in real word)
# $s5 is user input character, checked one character at a time
# $t0 = real word address
# $t2 = real word byte
# $t3 = user input word address
# $t4 = user input byte
WHOLE_WORD:
	la $a0, prompt_whole
	jal PRINT_WORD
	la $a0, input_buffer
	addi $a1, $s4, 1
	li $v0, 8
	syscall				# user inputs guess word
	move $t0, $s0			# pointer to real word
	la $t3, input_buffer		# pointer to input_buffer
	addi $t1, $zero, 0		# counter
	checkWholeLoop:
		add $t0, $t0, $t1
		add $t3, $t3, $t1
		lb $t2, 0($t0)
		lb $t4, 0($t3)
		sub $t0, $t0, $t1
		sub $t3, $t3, $t1
		bne $t2, $t4, exitBad
		addi $t1, $t1, 1
		beq $t1, $s4, exitGood
		j checkWholeLoop
	
	exitGood:
		lb $a2, round_score
		mul $a2, $a2, 2
		sb $a2, round_score
		lb $a3, game_tally
		add $t9, $a2, $a3
		sb $t9, game_tally	
		la $a0, whole_good
		jal PRINT_WORD
	j exitFinish
	
	exitBad:
		lb $a2, round_score
		mul $a2, $a2, -2
		sb $a2, round_score
		lb $a3, game_tally
		add $t9, $a2, $a3
		sb $t9, game_tally	
		la $a0, whole_bad
		jal PRINT_WORD
	j exitFinish
	
	exitFinish:
		move $a0, $t0
		jal PRINT_WORD
		la $a0, correct_word
		jal PRINT_WORD
		la $a0, input_buffer
		jal PRINT_WORD
		la $a0, end_rs
		jal PRINT_WORD
		jal PRINT_ROUND
		la $a0, end_gt
		jal PRINT_WORD
		jal PRINT_GAME
		la $a0, end_ask
		jal PRINT_WORD
		j RETRY		

j RETRY
######################################################################


##############################_CLEAR_#################################
# clear memory for scrambled, random_array, correct_counter and question mark counter
CLEAR:
	add $s6, $zero, $zero
	add $s2, $zero, $zero
	add $s7, $s7, 1
	la $v0, scrambled
	li $v1, 0x00
	sb $v1, 0($v0)
	sb $v1, 1($v0)
	sb $v1, 2($v0)
	sb $v1, 3($v0)
	sb $v1, 4($v0)
	sb $v1, 5($v0)
	sb $v1, 6($v0)
	sb $v1, 7($v0)
	
	la $v0, random_array
	li $v1, 0x99
	sb $v1, 0($v0)
	sb $v1, 1($v0)
	sb $v1, 2($v0)
	sb $v1, 3($v0)
jr $ra
######################################################################


#############################_RANDOM_#################################
RANDOM:
	#pre
	addi $sp, $sp, -8
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	
	#body
	move $t0, $a0			# save input parameter
	li $v0, 30			# system time
	syscall				# $a0 = lower 32 bits
	move $t1, $a0			# $s1 = lower 32 bits
	move $a1, $t1			# seed
	li $a0, 1			# id
	li $v0, 40			# set seed
	syscall				# seed is set
	
	addi $a0, $zero, 1		# $a0 = 1
	move $a1, $t0			# upper bound
	li $v0, 42			# generate random number
	syscall				# $a0 has the number
	move $v0, $a0
	
	#post
	lw $t1, 4($sp)
	lw $t0, 0($sp)
	addi $sp, $sp, 8
jr $ra
######################################################################


############################_ADD_ROUND_###############################
ADD_ROUND:
	lb $t0, round_score
	addi $t0, $t0, 1
	sb $t0, round_score
jr $ra
######################################################################


############################_SUB_ROUND_###############################
SUB_ROUND:
	lb $t0, round_score
	subi $t0, $t0, 1
	sb $t0, round_score
jr $ra
######################################################################


###########################_PRINT_ROUND_##############################
PRINT_ROUND:
	lb $a0, round_score
	li $v0, 1
	syscall
jr $ra
######################################################################


###########################_PRINT_GAME_###############################
PRINT_GAME:
	lb $a0, game_tally
	li $v0, 1
	syscall
jr $ra
######################################################################


###########################_PRINT_WORD_###############################
PRINT_WORD:
	li $v0, 4
	syscall
jr $ra
######################################################################


##########################_PRINT_SPACES_##############################
# $s4 = word length
# $s1 = beginning of scrambled
# $t0 = counter (starts at $s4)
# $t1 = pointer to scrambled
# $t2 = byte to print
PRINT_SPACES:
	move $t0, $s4		# counter
	la $t1, scrambled	# pointer
	printSpacesLoop:
		lb $t2, 0($t1)		# byte to print
		move $a0, $t2
		li $v0, 11	
		syscall			# print byte
		addi $t1, $t1, 1	# increment byte address
		subi $t0, $t0, 1	# decrement counter
		beq $t0, $zero, exitPrintSpacesLoop
		li $a0, 0x20		# space ascii code (0x20)
		li $v0, 11	
		syscall			# print character
		j printSpacesLoop
	exitPrintSpacesLoop:
jr $ra
######################################################################


############################_WORD_INIT_###############################
# Saved Registers
#	$s0 = root address of current word
#	$s1 = root address of word in progess with '_' + '*' + 'a-z' + 'spaces'
#	$s2 = pointer for current word
#	$s3 = pointer for hidden word
#	$s4 = length of current word
#	round_score = length of current word
WORD_INIT:
	sll $a0, $a0, 2			# convert ith index to ith word (index*4)
	la $t0, dictionary		# $t0 = look-up table address
	add $t0, $a0, $t0		# $t0 = address of root of current
	lw $s0, 0($t0)			# $s0 = root of current (first letter here)
	move $s2, $s0			# $s2 = current pointer
	la $s1, scrambled		# $s1 = root of scrambled
	move $s3, $s1			# $s3 = scrambled pointer
	la $t1, word_lengths		# $t1 = look-up table address
	add $t0, $a0, $t1		# $t0 = pointer to look up index
	lw $t9, 0($t0)
	lb $s4, 0($t9)			# $s4 = value of word length	
	sb $s4, round_score		# round_score initialized to word length
jr $ra
######################################################################


############################_SCRAMBLE_################################
# don't change word length ($s4) and root of scrambled word ($s1)
# $t0 = root of scrambled
# $t1 = word length
# $t2 = root of random_array
# $t3 = possible asterisks (wordlength srl 1)
# $t4 = number of asterisks remaining
# $v0 = current random
# $t5 = first random (0x99 at start)
# $t6 = second random (0x99 at start)
# $t7 = third random (0x99 at start)
# $t8 = fourth random (0x99 at start)

SCRAMBLE:
	# pre
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	move $t0, $s1			# $t0 = root of scrambled
	move $t1, $s4			# $t1 = word length
	
	underscoreLoop:			# make all chars in scrambled '_' initially
		li $t9, 0x5F
		sb $t9, 0($t0)
		addi $t0, $t0, 1
		subi $t1, $t1, 1
		beq $t1, 0, exitUnderscoreLoop
		j underscoreLoop
	exitUnderscoreLoop:
	
	move $t0, $s1
	move $t1, $s4
	
	la $t2, random_array		# $t2 = address of random_array (starts as 0x99 99 99 99)
	srl $t3, $t1, 1			# $t3 = $t1 / 2
	
	move $a0, $t3			# set input to RANDOM function
	jal RANDOM
	move $t4, $v0			# store output from RANDOM
	addi $t4, $t4, 1
		
	move $t0, $s1
	move $t1, $s4
	randomLoop:
		addi $a0, $t1, 1	# set upper bound for random index to overwrite with '*'
		lb $t5, 0($t2)		# first random
		lb $t6, 1($t2)		# second random
		lb $t7, 2($t2)		# third random
		lb $t8, 3($t2)		# fourth random
		jal RANDOM		# get random index [0,n-1]
		beq $v0, $t5, randomLoop
		beq $v0, $t6, randomLoop
		beq $v0, $t7, randomLoop
		beq $v0, $t8, randomLoop
		sb $v0, 0($t2)		# save current random to random_array
		add $t0, $t0, $v0	# move to random index of scrambled
		li $t9, 0x2A
		sb $t9, 0($t0)		# overwrite character in scrambled
		sub $t0, $t0, $v0	# return scrambled pointer to beginning of word
		addi $t2, $t2, 1	# increment random_array byte pointer
		subi $t4, $t4, 1	# decrement counter
		beq $t4, $zero, exitRandomLoop	# loop is finished (counter == 0)
		j randomLoop
	
	exitRandomLoop:
				
	# post
	lw $ra, 0($sp)
	addi $sp, $sp, 4
			
jr $ra
######################################################################


##############################_EXIT_##################################
EXIT:
	la $a0, EXIT_1			# "Your final game tally is "
	li $v0, 4
	syscall
	
	jal PRINT_GAME 	 		# print game tally

	la $a0, EXIT_2			# ". Goodbye!"
	li $v0, 4
	syscall
	
li $v0, 10
syscall
######################################################################

