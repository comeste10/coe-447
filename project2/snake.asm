# Steve Comer
# sfc15@pitt.edu
# Project 2 - Snake
# 27 March 2012

# FUNCTIONS
#	TURN: void
#	CONTINUE: void
#	PEEK: void
#	INIT: void
#	PAINT_SNAKE: void
#	RANDOM_INIT: void
# 	RANDOM: $a0 = upper bound, $v0 = random number
#	SETLED: $a0 = x, $a1 = y, $a2 = color (0=off, 1=red, 2=orange, 3=green)
#	GETLED: $a0 = x, $a1 = y, $v0 = color (see above)
#	ADD_SCORE: void
# 	EXIT: void

# Saved Registers
#	$s0 = current direction
#	$s1 = next direction
#	$s2 = head_x pointer
#	$s3 = head_y pointer
#	$s4 = snake length
#	$s5 = game score
#	$s6 = next_x
#	$s7 = next_y
#	$a3 = 1 if frog just eaten
#	$v1 = time tracker

# Notes
#	up(w)     = 0x2A
#	down(a)   = 0x5F
#	left(s)   = 0x20
#	right(d)  = 0x21



.data	
	end_string_1:	.asciiz	"\nGame over.\nThe playing time was "
	end_string_2:	.asciiz	" ms.\nThe game score was "
	end_string_3:	.asciiz	" frogs.\n"
	game_score:	.word	0x00
	play_time:	.word	0x00
	
.align 2
	snake_x:	.word	00,01,02,03,04,05,06,07,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	snake_y:	.word	31,31,31,31,31,31,31,31,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	
.text
##############################_MAIN_##################################
MAIN:
	li $v0, 30				# get initial time
	syscall
	move $t9, $a0

	li $t0, 7
	sll $t0, $t0, 2

	la $s2, snake_x
	add $s2, $s2, $t0			# head_x pointer
	
	la $s3, snake_y
	add $s3, $s3, $t0			# head_y pointer
	
	li $s4, 8				# initial length
	
	jal RANDOM_INIT
	jal INIT
	
	li $s0, 0xE3				# initial direction = right
	li $s1, 0xE3
	
	polling:
		beq $s5, 32, EXIT
		beq $k1, 1, EXIT
	
		# scan for user key press
		# store key press in $s0
		
		la	$t0, 0xFFFF0000	# status register address	
		lw	$t0, 0($t0)	# read status register
		andi	$t0, $t0, 1		# check for key press
		bne	$t0, $0, KEYPRESS
		
		NO_KEYPRESS:
		beq $s1, 0xE3, RIGHT
		beq $s1, 0xE2, LEFT
		beq $s1, 0xE0, UP
		beq $s1, 0xE1, DOWN	
		
		KEYPRESS:
		lw $s0, 0xFFFF0004
		beq $s0, 0xE3, IF_RIGHT_PRESS
		beq $s0, 0xE2, IF_LEFT_PRESS
		beq $s0, 0xE0, IF_UP_PRESS
		beq $s0, 0xE1, IF_DOWN_PRESS	
		
		IF_RIGHT_PRESS:
			beq $s1, 0xE2, LEFT
			beq $s0, 0xE0, UP
			beq $s0, 0xE1, DOWN
			j RIGHT
			
		IF_LEFT_PRESS:
			beq $s1, 0xE3, RIGHT
			beq $s0, 0xE0, UP
			beq $s0, 0xE1, DOWN
			j LEFT
			
		IF_UP_PRESS:
			beq $s1, 0xE1, DOWN
			beq $s0, 0xE3, RIGHT
			beq $s0, 0xE2, LEFT
			j UP
			
		IF_DOWN_PRESS:
			beq $s1, 0xE0, UP
			beq $s0, 0xE3, RIGHT
			beq $s0, 0xE2, LEFT
			j DOWN
		
	
j EXIT
######################################################################


#############################_MOVEMENT_###############################

RIGHT:
	li $s1, 0xE3
	# (next_x, next_y) = (head_x+1, head_y)
	# if next_x == 64, next_x = 0
	
	# find x coordinate of next
	lw $s6, 0($s2)
	addi $s6, $s6, 1
	
	# find y coordinate of next
	lw $s7, 0($s3)
	addi $s7, $s7, 0
	
	# check boundary condition
	bne $s6, 64, inRange0		# if next_x == 64
	addi $s6, $zero, 0		# set next_x = 0
	
	inRange0:
	jal PEEK 			# ($s6, $s7) == (next_x, next_y)
	
	# turn on new head
	move $a0, $s6
	move $a1, $s7
	li $a2, 2
	jal SETLED
	
	jal UPDATE			# turns off tail, updates new head pointers, writes new head to memory
	
	# sleep for 200 ms
	li $a0, 200
	li $v0, 32
	syscall
	
	j polling

LEFT:
	li $s1, 0xE2
	# (next_x, next_y) = (head_x-1, head_y)
	# if next_x == -1, next_x = 63
	
	# find x coordinate of next
	lw $s6, 0($s2)
	addi $s6, $s6, -1
	
	# find y coordinate of next
	lw $s7, 0($s3)
	addi $s7, $s7, 0
	
	# check boundary condition
	bne $s6, -1, inRange1		# if next_x == -1
	addi $s6, $zero, 63		# set next_x = 63
	
	inRange1:
	jal PEEK 			# ($s6, $s7) == (next_x, next_y)
	
	# turn on new head
	move $a0, $s6
	move $a1, $s7
	li $a2, 2
	jal SETLED
	
	jal UPDATE			# turns off tail, updates new head pointers, writes new head to memory
	
	# sleep for 200 ms
	li $a0, 200
	li $v0, 32
	syscall
	
	j polling
	
UP:	
	li $s1, 0xE0
	# (next_x, next_y) = (head_x, head_y-1)
	# if next_y == -1, next_y = 63
	
	# find x coordinate of next
	lw $s6, 0($s2)
	addi $s6, $s6, 0
	
	# find y coordinate of next
	lw $s7, 0($s3)
	addi $s7, $s7, -1
	
	# check boundary condition
	bne $s7, -1, inRange2		# if next_x == -1
	addi $s7, $zero, 63		# set next_x = 63
	
	inRange2:
	jal PEEK 			# ($s6, $s7) == (next_x, next_y)
	
	# turn on new head
	move $a0, $s6
	move $a1, $s7
	li $a2, 2
	jal SETLED
	
	jal UPDATE			# turns off tail, updates new head pointers, writes new head to memory
	
	# sleep for 200 ms
	li $a0, 200
	li $v0, 32
	syscall
	
	j polling

DOWN:	
	li $s1, 0xE1
	# (next_x, next_y) = (head_x, head_y+1)
	# if next_y == 64, next_y = 0
	
	# find x coordinate of next
	lw $s6, 0($s2)
	addi $s6, $s6, 0
	
	# find y coordinate of next
	lw $s7, 0($s3)
	addi $s7, $s7, 1
	
	# check boundary condition
	bne $s7, 64, inRange3		# if next_x == -1
	addi $s7, $zero, 0		# set next_x = 63
	
	inRange3:
	jal PEEK 			# ($s6, $s7) == (next_x, next_y)
	
	# turn on new head
	move $a0, $s6
	move $a1, $s7
	li $a2, 2
	jal SETLED
	
	jal UPDATE			# turns off tail, updates new head pointers, writes new head to memory
	
	# sleep for 200 ms
	li $a0, 200
	li $v0, 32
	syscall
	
	j polling
	
	
######################################################################


##############################_PEEK_##################################
dead:
li $k1, 1
j polling

PEEK:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	add $a3, $zero, $zero		# frogEaten = false
	
	move $a0, $s6
	move $a1, $s7
	jal GETLED			# $v0 = color of next LED
	
	beq $v0, 2, dead		# snake hit itself
	bne $v0, 3, noFrog
	addi $a3, $zero, 1		# frogEaten = true
	addi $s4, $s4, 1		# length++
	addi $s5, $s5, 1		# game_score++
	#jal ADD_SCORE
	noFrog:
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
jr $ra
######################################################################


#############################_UPDATE_#################################
# 1: turn off tail LED
#	set old tail to be (-1,-1)
#    	tail_x pointer = head_x pointer - (length - 1)*4
#    	tail_y pointer = head_y pointer - (length - 1)*4
# 2: head_x pointer += 4
#    head_y pointer += 4
# 3: head_x (mem) = next_x
#    head_y (mem) = next_y
UPDATE:
	addi $sp, $sp, -16		# pre
	sw $t0, 12($sp)
	sw $t4, 8($sp)
	sw $t5, 4($sp)
	sw $ra, 0($sp)
	
	bnez $a3, frogEaten		# if frogEaten == true, don't delete old tail
	
	# turn off tail LED
	subi $t0, $s4, 1		# length - 1
	
	mul $t0, $t0, 4			# offset = (length - 1)*4
	
	sub $t4, $s2, $t0		# $t4 = tail_x pointer
	sub $t5, $s3, $t0		# $t5 = tail_y pointer
	
	lw $a0, 0($t4)			# $a0 = tail_x
	lw $a1, 0($t5)			# $a1 = tail_y
	li $a2, 0
	jal SETLED			# turn off tail LED
	
	#li $t0, -1			# value to store in memory = -1
	#sw $t0, 0($t4)			# old tail_x = -1
	#sw $t0, 0($t5)			# old tail_y = -1
	
	frogEaten:
		
	# update head pointers		
	addi $s2, $s2, 4
	addi $s3, $s3, 4
	
	# write (next_x, next_y) to memory as new head
	sw $s6, 0($s2)
	sw $s7, 0($s3)
	
	lw $ra, 0($sp)			# post
	lw $t5, 4($sp)
	lw $t4, 8($sp)
	lw $t0, 12($sp)
	addi $sp, $sp, 16
	
jr $ra
######################################################################


##############################_INIT_##################################
# 32 frogs guaranteed every time (checks for green or yellow)
INIT:
	addi $sp, $sp, -16		# pre
	sw $t4, 12($sp)
	sw $t5, 8($sp)
	sw $t6, 4($sp)
	sw $ra, 0($sp)
	
	li $s5, 0			# game score = 0
	
	jal PAINT_SNAKE
	
	# TESTING ONLY, SKIP FROGS
	# TAKE THIS LINE OUT
	#j endFrogLoop		
	
	li $t4, 32			# 32 possible frogs
	frogLoop:
		li $v0, 0
	
		li $a0, 64
		jal RANDOM
		move $t5, $v0		# $t5 = random x
		
		li $a0, 64
		jal RANDOM
		move $t6, $v0		# $t6 = random y
		
		move $a0, $t5		# $a0 = x to check
		move $a1, $t6		# $a1 = y to check
		jal GETLED		# $v0 = LED color (2 = yellow)
		beq $v0, 2, skipFrog	# skip if part of snake (LED = yellow)
		beq $v0, 3, skipFrog	# skip if already a frog
		
		move $a0, $t5		# $a0 = x to set
		move $a1, $t6		# $a1 = y to set
		li $a2, 3		# $a2 = 3 (green)
		jal SETLED
				
		subi $t4, $t4, 1
		skipFrog:		
		bnez $t4, frogLoop
	endFrogLoop:
		
	lw $ra, 0($sp)			# post
	lw $t6, 4($sp)
	lw $t5, 8($sp)
	lw $t4, 12($sp)
	addi $sp, $sp, 16
jr $ra
######################################################################


###########################_PAINT_SNAKE_##############################
PAINT_SNAKE:
	addi $sp, $sp, -16		# pre
	sw $t7, 12($sp)
	sw $t8, 8($sp)
	sw $t9, 4($sp)
	sw $ra, 0($sp)
			
	li $t7, 8			# t7 = loop counter
	li $a2, 2			# set color argument to yellow
	la $t8, snake_x			# snake_x pointer
	la $t9, snake_y			# snake_y pointer
	
	paintSnakeLoop:
		lb $a0, 0($t8)		# current x
		lb $a1, 0($t9)		# current y
		jal SETLED
		addi $t8, $t8, 4	# inc pointer
		addi $t9, $t9, 4	# inc pointer	
		subi $t7, $t7, 1	# dec counter
		bnez $t7, paintSnakeLoop
	endPaintSnakeLoop:
	
	lw $ra, 0($sp)			# post
	lw $t9, 4($sp)
	lw $t8, 8($sp)
	lw $t7, 12($sp)
	addi $sp, $sp, 16
	
jr $ra
######################################################################


###########################_RANDOM_INIT_##############################
RANDOM_INIT:
	#pre
	addi $sp, $sp, -8
	sw $t0, 0($sp)
	sw $t1, 4($sp)	
	#body
	li $v0, 30			# system time
	syscall				# $a0 = lower 32 bits
	move $t1, $a0			# $s1 = lower 32 bits
	move $a1, $t1			# seed
	li $a0, 1			# id
	li $v0, 40			# set seed
	syscall				# seed is set
	#post
	lw $t1, 4($sp)
	lw $t0, 0($sp)
	addi $sp, $sp, 8
jr $ra

#############################_RANDOM_#################################
RANDOM:
	# pre
	addi $sp, $sp, -8
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	# body
	move $t0, $a0			# save input parameter
	addi $a0, $zero, 1		# $a0 = 1
	move $a1, $t0			# upper bound
	li $v0, 42			# generate random number
	syscall				# $a0 has the number
	move $v0, $a0
	# post
	lw $t1, 4($sp)
	lw $t0, 0($sp)
	addi $sp, $sp, 8
jr $ra
######################################################################


#############################_SET_LED_################################
# void _setLED(int x, int y, int color)
	# 03/11/2012: this version is for the 64x64 LED
	#   sets the LED at (x,y) to color
	#   color: 0=off, 1=red, 2=orange, 3=green
	#
	# warning:   x, y and color are assumed to be legal values (0-63,0-63,0-3)
	# arguments: $a0 is x, $a1 is y, $a2 is color 
	# trashes:   $t0-$t3
	# returns:   none
	#
SETLED:
	addi $sp, $sp, -16		# pre
	sw $t0, 12($sp)
	sw $t1, 8($sp)
	sw $t2, 4($sp)
	sw $t3, 0($sp)

	# byte offset into display = y * 16 bytes + (x / 4)
	sll	$t0,$a1,4      # y * 16 bytes
	srl	$t1,$a0,2      # x / 4
	add	$t0,$t0,$t1    # byte offset into display
	li	$t2,0xffff0008	# base address of LED display
	add	$t0,$t2,$t0    # address of byte with the LED
	# now, compute led position in the byte and the mask for it
	andi	$t1,$a0,0x3    # remainder is led position in byte
	neg	$t1,$t1        # negate position for subtraction
	addi	$t1,$t1,3      # bit positions in reverse order
	sll	$t1,$t1,1      # led is 2 bits
	# compute two masks: one to clear field, one to set new color
	li	$t2,3		
	sllv	$t2,$t2,$t1
	not	$t2,$t2        # bit mask for clearing current color
	sllv	$t1,$a2,$t1    # bit mask for setting color
	# get current LED value, set the new field, store it back to LED
	lbu	$t3,0($t0)     # read current LED value	
	and	$t3,$t3,$t2    # clear the field for the color
	or	$t3,$t3,$t1    # set color field
	sb	$t3,0($t0)     # update display
	
	lw $t3, 0($sp)			# post
	lw $t2, 4($sp)
	lw $t1, 8($sp)
	lw $t0, 12($sp)
	addi $sp, $sp, 16
jr $ra
######################################################################


#############################_GET_LED_################################
# int _getLED(int x, int y)
	# 03/11/2012: this version is for the 64x64 LED
	#   returns the value of the LED at position (x,y)
	#
	#  warning:   x and y are assumed to be legal values (0-63,0-63)
	#  arguments: $a0 holds x, $a1 holds y
	#  trashes:   $t0-$t2
	#  returns:   $v0 holds the value of the LED (0, 1, 2, 3)
	#
GETLED:
	addi $sp, $sp, -12		# pre
	sw $t0, 8($sp)
	sw $t1, 4($sp)
	sw $t2, 0($sp)
	
	# byte offset into display = y * 16 bytes + (x / 4)
	sll  $t0,$a1,4      # y * 16 bytes
	srl  $t1,$a0,2      # x / 4
	add  $t0,$t0,$t1    # byte offset into display
	la   $t2,0xffff0008
	add  $t0,$t2,$t0    # address of byte with the LED
	# now, compute bit position in the byte and the mask for it
	andi $t1,$a0,0x3    # remainder is bit position in byte
	neg  $t1,$t1        # negate position for subtraction
	addi $t1,$t1,3      # bit positions in reverse order
    	sll  $t1,$t1,1      # led is 2 bits
	# load LED value, get the desired bit in the loaded byte
	lbu  $t2,0($t0)
	srlv $t2,$t2,$t1    # shift LED value to lsb position
	andi $v0,$t2,0x3    # mask off any remaining upper bits
	
	# post
	lw $t2, 0($sp)
	lw $t1, 4($sp)
	lw $t0, 8($sp)
	addi $sp, $sp, 12
jr $ra
######################################################################


############################_ADD_SCORE_###############################
ADD_SCORE:
	# pre
	addi $sp, $sp, -4
	sw $t0, 0($sp)

	lb $t0, game_score
	addi $t0, $t0, 1
	sb $t0, game_score
	
	# post
	lw $t0, 0($sp)
	addi $sp, $sp, 4
jr $ra
######################################################################


##############################_EXIT_##################################
EXIT:
	la $a0, end_string_1		# "Game over.\nThe playing time was "
	li $v0, 4
	syscall
	
	li $a0, 0
	li $v0, 30
	syscall
	sub $t9, $a0, $t9
	
	move $a0, $t9			# play time
	li $v0, 1
	syscall

	la $a0, end_string_2		# " ms.\nThe game score was "
	li $v0, 4
	syscall
	
	move $a0, $s5			# game score
	li $v0, 1
	syscall
	
	la $a0, end_string_3		# " frogs.\n"
	li $v0, 4
	syscall
	
li $v0, 10
syscall
######################################################################

