# This program is the third assignment for CS2340.003. This program will find prime numbers
# using the algorithm known as "The Sieve of Eratosthenes". This algorithm starts with the number
# 2 and cancels out any multiples of 2. It then finds the next number that hasn't been canceled out
# and cancels its multiples. It will repeat this process until a certain point. For this program,
# the user will enter an integer that will specify the stopping point for the algorithm. In other 
# words, the algorithm will print prime numbers up to the number that the user enters. After 
# completion of the algorithm, the program will look at which numbers are left and print those to
# the user.
#
# Written by Garrett Heisey, netID: glh210000, at the University of Texas at Dallas
# Start Date: 9/19/2023
#
# 

		.include "SysCalls.asm"
		.data
userInteger:	.word	0		# integer label to hold value user enters
iterateValue:	.word	2		# integer label to hold iteration value
addressPointer:	.word 	0		# address of allocated memory
newLine:	.asciiz	"\n"		# new line char to use when printing nums
userPrompt:	.asciiz	"Enter an integer: "	
errorMsg:	.asciiz	"Error. Please enter a number in between 3 and 160,000\n"

		.text
main:
	la 	$a0, userPrompt		# print prompt for user
	li 	$v0, SysPrintString	# call system print string function
	syscall
	li 	$v0, SysReadInt		# read the input from user
	syscall
	sw 	$v0, userInteger	# store user input into int label
	add 	$s0, $v0, $zero		# store user input into saved register for later
	bgt 	$v0, 160000, numNotInBounds	# branch if number is too big 
	blt 	$v0, 3, numNotInBounds	# branch if number is too small
	jal 	allocateMemory		# jump to allocate memory subroutine
	sll 	$t0, $t0, 3		# shift left by 3 = multiply by 8
	sw 	$t0, userInteger	# store new value back into userInteger label
	li 	$t0, 1			# set value of register to use to flip bits to 1
	li 	$t2, 0			# set value of register to use as counter to 0
	jal 	fillMemoryWithOnes	# jump to fill allocated bits function
	
	# starting with 2, find multiples of non-zero bits and set them to zero
	srl 	$s2, $s0, 1		# shift right by 1 = divide by 2
	lw 	$t0, addressPointer	# load with address of allocated memory
	lw 	$t1, iterateValue	# load with value to iterate by
	add	$t0, $t0, $t1		# add value to memory address to get starting point
	li 	$t2, 0			# set register to use as counter to 0
	li	$t9, 0			# load register to use as counter for loop to 0
	jal 	findNonZeroNums		# jump to look for non-zero numbers (primes)
	
	# print prime numbers that are left in allocated memory 
	lw 	$t0, addressPointer	# load address of allocated memory
	addi	$t0, $t0, 1		# increment address pointer
	li 	$t1, 1			# load register to use as counter to 1
	j 	findPrimeNums		# jump to findPrimeNums function
	
numNotInBounds:
	la 	$a0, errorMsg		# load address of error message to print
	li 	$v0, SysPrintString	# call system print string function
	syscall
	j 	main			# jump back to main for user to enter another number
	
allocateMemory:
	lw 	$t0, userInteger	# load temp register with value of user integer
	li 	$t1, 7			# load register with 7 (0000 0111) in binary	
	and 	$t1, $t1, $t0		# logical and with userInteger and binary 7
	beqz 	$t1, divisibleByEight	# if result is equal to 0, num is divisible by 8
	sub 	$t2, $t0, $t1		# subtract userInteger by additional value
	addi 	$t0, $t2, 8		# add result to original integer to get next multiple of 8
	srl 	$t0, $t0, 3		# shift right by 3 = divide by 8
	sw 	$t0, userInteger	# save new value into userInteger label
	lw 	$a0, userInteger	# load integer of bytes to allocate
	li 	$v0, SysAlloc		# call system dynamic allocation function
	syscall
	sw 	$v0, addressPointer	# store address of allocation to label
	jr 	$ra			# jump back to main
	
divisibleByEight:
	srl 	$t0, $t0, 3		# shift right by 3 = divide by 8
	sw 	$t0, userInteger	# save new value of userInteger to label
	lw 	$a0, userInteger	# load value of userInteger
	li 	$v0, SysAlloc		# call system dynamic allocation function
	syscall
	sw 	$v0, addressPointer	# store address of allocation to label
	jr 	$ra			# jump back to main
	
fillMemoryWithOnes:
	sb 	$t0, ($v0)		# store contents of $t0 (1) into address at $v0
	addi 	$t2, $t2, 1		# increment counter register
	addi 	$v0, $v0, 1		# increment to point to next bit
	lw 	$t1, userInteger	# load integer value of value to stop branching at
	blt 	$t2, $t1, fillMemoryWithOnes# branch back to top if not done looping
	jr 	$ra			# jump back to main
	
findNonZeroNums:
	li 	$t2, 0
	lb 	$t3, ($t0)		# load byte that register points to
	addi	$t9, $t9, 1		# increment counter
	lw 	$t1, iterateValue	# load value to iterate by
	beq	$t3, 1, findMultiples	# branch if current bit is set
	addi	$t0, $t0, 1		# increment address pointer
	blt	$t9, $s2, findNonZeroNums# branch back to top if less than n/2
	jr 	$ra			# jump back to main 

findMultiples: 
	beqz 	$t1, flipBitToZero	# if counter = 0, flip the current bit
	subi 	$t1, $t1, 1		# decrement counter
	addi 	$t2, $t2, 1		# increment 2nd counter
	blt 	$t2, $s0, findMultiples	# branch back to top if less than n
	lw 	$t1, iterateValue	# load value to iterate by
	addi 	$t1, $t1, 1		# increment value
	sw 	$t1, iterateValue	# store new value back to memory
	lw 	$t0, addressPointer	# load value of address pointer
	add	$t0, $t0, $t1		# add iterate value to address pointer
	j	findNonZeroNums		# jump back to find non zero nums function
	
flipBitToZero:
	lw 	$t0, addressPointer	# load address of allocated memory
	lw 	$t1, iterateValue	# load register with current iteration value
	add 	$t0, $t0, $t1		# add the two registers together
	add	$t0, $t0, $t2		# add the counter to the value
	lb 	$t3, ($t0)		# load the bit at the specified position
	add 	$t3, $zero, $zero	# set the register to 0 by adding 0
	sb 	$t3, ($t0)		# store the new value back into memory
	j 	findMultiples		# jump back to find more multiples

printCurrentNum:
	lw 	$t3, addressPointer	# load address of allocated memory
	sub	$t2, $t0, $t3		# subtract distance from origin of allocation
	move 	$a0, $t2		# move value into argument register
	li 	$v0, SysPrintInt	# call system print integer function
	syscall
	la 	$a0, newLine		# load argument register with address of "\n"
	li 	$v0, SysPrintString	# call system print string function
	syscall
	
findPrimeNums:
	addi 	$t0, $t0, 1		# increment pointer register
	addi 	$t1, $t1, 1		# increment counter register
	lb	$t2, ($t0)		# load current bit to register
	bnez	$t2, printCurrentNum	# branch if current bit is set to print the num
	blt	$t1, $s0, findPrimeNums	# branch back to top if there is more nums
	
	li 	$v0, SysExit		# call system exit program function
	syscall
	