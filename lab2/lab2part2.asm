# Purpose:	Add x + y and store the result in z
# Author:	Steve Comer
# Date:		3 Feb 2012

# variable section
.data
x:	.half	15		# sets aside 2 bytes in memory to store x, initialized to 15
y:	.half	8		# sets aside 2 bytes in memory to store y, initialized to 8
z:	.half	0		# sets aside 2 bytes in memory to store z, initialized to 0

# program code
.text

la $t0, x			# load x into t0, set MEM location to be that of x
lb $t1, 0($t0)			# store value of x in t1
									
lb $t2, 2($t0)			# store value of y (x offset by +2 bytes) in t2

add $t3, $t1, $t2		# store the result of x + y in t3
sb $t3, 4($t0)			# store t3 in z (x offset by +4 bytes)

sb $t3, 0($t0)			# part b: overwrite x with z (in memory)
sb $t3, 2($t0)			# part b: overwrite y (x offset by +2 bytes with z (in memory)


