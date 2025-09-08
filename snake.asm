.data 

display: .space 1024

xSnake: .word -1:256
ySnake: .word -1:256
xApple: .word 11
yApple: .word 7
snakeSize: .word 2
snakeDir: .word 100	# Starting direction is 'd' (100 in ASCII)

xAllPossibleCoords: .word -1:256
yAllPossibleCoords: .word -1:256

rastorage: .word 0
rastorage2: .word 0
rastorage3: .word 0
var1storage: .word 0
var2storage: .word 0
var3storage: .word 0

snakeColor: .word 0x008000
snakeHeadColor: .word 0x00FF00
appleColor: .word 0xFF0000
grassColor: .word 0x00008B

rcontrol: .word 0xFFFF0000
rdata: .word 0xFFFF0004
tcontrol: .word 0xFFFF0008
tdata:.word 0xFFFF000C

mainMenuMessage: .asciiz "\n\n\n\n\n\n\n**WELCOME TO MIPS-SNAKE** \n Work done by alejandromolto. \n \n OPTIONS: \n \n (1) Play Snake. \n (2) Settings. \n (3) Exit. \n\n\n\n\n\n\n"
optionsMenuMessage: .asciiz "\n\n\n\n\n\n\n**SETTINGS:** \n \n DIFFICULTY: \n\n (1) Easy. \n (2) Mid. \n (3) Hard. \n\n\n\n\n\n\n "
lostMenuMessage: .asciiz "\n\n\n\n\n\n\n**YOU DIED** \n \n  \n\n (1) Play Again. \n (2) Main menu. \n (3) Exit. \n\n\n\n\n\n\n "
.text
.globl main

main:
	
	li $s0, 125  # Variable preserved across temporary calls. Represents the length of each tick in miliseconds (by default 200ms).
	
	mainMenu:
	
		la $a0, mainMenuMessage
		jal menu
		beq $v0, 49, game
		beq $v0, 50, gameOptions
		beq $v0, 51, exit
	
	game:
	
		# INITIALIZING THE SNAKE AND APPLE VALUES.
		
		li $t0, 11
		sw $t0, xApple

		li $t0, 7
		sw $t0, yApple
				
		li $t0, 100
		sw $t0, snakeDir # Direction (100 or 'd' by default)
		
		li $t1, 2
		sw $t1, snakeSize # Size (two by default)

		la $a0, xSnake
		li $t1, 4
		sw $t1, 0($a0) # Head coordinate (x)

		la $a1, ySnake
		li $t1, 7
		sw $t1, 0($a1)  # Head coordinate (y)   
    
		la $a0, xSnake
		li $t1, 3
		sw $t1, 4($a0) # Body coordinate (x)

		la $a1, ySnake
		li $t1, 7
		sw $t1, 4($a1) # Body coordinate (y)   
	
	gameLoop:
		jal print
		jal getDir
			sw $v0, snakeDir
		jal isEating
		beq $v0, 0, noApple
		jal GenApple
			sw $v0, xApple
			sw $v1, yApple
	
		noApple:
			beq $v0, 0, notExtend
			jal updateAndExtend
			j keepgoing
		notExtend:
			jal update
		keepgoing:
			jal isDead
			beq $v0, 1, exitGame

		j gameLoop
	
	gameOptions:
		la $a0, optionsMenuMessage
		jal menu
		beq $v0, 49, easy
		beq $v0, 50, mid
		beq $v0, 51, hard
		
		easy:
			li $s0, 125
			j mainMenu
		mid:
			li $s0, 100		
			j mainMenu
		hard:
			li $s0, 75	
			j mainMenu

	exitGame:
	
		la $a0 lostMenuMessage
		jal menu
		beq $v0, 49, game 
		beq $v0, 50, mainMenu
		beq $v0, 51, exit
	

	
	exit:
		li $v0, 10
		syscall

	
menu: # Gets the adress of the string to be printed in $a0 and returns to $v0 the option of the user

	# PRINTING (OUTPUT)

	sw $ra, rastorage2
	
	jal printString 

	lw $ra, rastorage2
	
	# READING (INPUT)
	
	lw $t0, rcontrol
	lw $t1, rdata
	
	menuReadLoop:
	
		lw $t2, 0($t0)
		andi $t2, $t2, 0x1
		bne $t2, 1, menuReadLoop
		
		lw $t2, 0($t1)	# Input

	bgt $t2, 51, menuReadLoop # If input is not on range (0, 3), it goes back to the loop 
	blt $t2, 49, menuReadLoop

		
	move $v0, $t2
	jr $ra

			
printString: # Receives to $a0 the adress of the string
	
	move $t0, $a0

	printMenuLoop:
		lb $t1, 0($t0)
		beq $t1, $zero, menuLoopExit
		 
		sw $ra, rastorage # ra storage
		sw $t0, var1storage # Temporary variable storage (as it is not preserved across procedure calls)
		
		move $a0, $t1
		jal displayChar

		lw $ra, rastorage
		lw $t0, var1storage		
		
		addi $t0, $t0, 1
		j printMenuLoop
	
	menuLoopExit:
	jr $ra

displayChar: # Receives to $a0 the character it wants to display and it displays it.

	writing_loop:
	lw $t9, tcontrol
	lw $t9, 0($t9)
	andi $t9, $t9, 0x1
	bne $t9, 1, writing_loop
	
	lw $t7, tdata
	move $t9, $a0
	sw $t9, 0($t7)
	
	jr $ra

isApple: # Receives to $a0 and $a1 coords x and y. Receives to $a2 xApple direction and to $a3 the yApple direction. Returns to $v0 wether or not is the apple.


	lw $t0, 0($a2)	# Stores in t0 xApple
	lw $t1, 0($a3)	# Stores in t1 yApple	

	beq $a0, $t0, firstEqual	# If xCoordinates are equal, it jumps to the second comparison
	
	li $v0, 0	# If not, it returns 0
	jr $ra	
	
		firstEqual:
			
			beq $a1, $t1, secondEqual # If xCoordinates are equal, it jumps to the return
			
			li $v0, 0	# If not, it returns 0
			jr $ra				
			
			secondEqual:
				
				li $v0, 1 # As both coordinates are equal, it is the apple and therefore it returns 1
				jr $ra


isInSnake: # Receives to $a0 and $a1 coords x and y. Receives to $a2 xSnake (And ySnake). Receives to $a3 the length of the snake. Returns to v0 wether or not is part of the sneak and to v1 wether or not is the head.
	
	move $t0, $a0		# $t0 = x
	move $t1, $a1		# $t1 = y
	move $t2, $a2		# $t2 = xSnake
	addi $t3, $a2, 1024	# $t3 = ySnake
	li $t5, 0		# $t5 counter
	li $v0, 0
	li $v1, 0
	
	loop:
		beq $t5, $a3, backPrint	
		
		lw $t6, 0($t2)
		beq $t0, $t6, equal1
		addi $t2, $t2, 4
		addi $t3, $t3, 4
		addi $t5, $t5, 1
		j loop
		
		equal1:
			lw $t6, 0($t3)
			beq $t1, $t6, equal2
			addi $t2, $t2, 4
			addi $t3, $t3, 4
			addi $t5, $t5, 1
			j loop
			
	equal2:
		li $v0, 1
		bne $t5, 0, backPrint
		li $v1, 1

	backPrint:
		jr $ra



colorPixel: # This is a function that colors a pixel. It receives to $a0 and $a1 the x and y coordinates and to $a2 the color 


	sll $t0, $a1, 4
	add $t0, $t0, $a0
	sll $t0, $t0, 2	

	sw $a2, display($t0)

	jr $ra


print: # This is a void function that prints the current state of the board

	li $t4, 0
	li $t8, 0

	outerloop:
		innerloop:

			move $a0, $t8
			move $a1, $t4
			la $a2, xSnake
			lw $a3, snakeSize
			
			sw $t8, var1storage
			sw $t4, var2storage
			sw $ra, rastorage
			
			jal isInSnake
			
			lw $ra, rastorage 	
			lw $t8, var1storage
			lw $t4, var2storage		
		
		
			beq $v0, $zero, printElse
		
			printSnake:
				beq $v1, 1 , Head
				
				# Color pixel snake
				move $a0, $t8
				move $a1, $t4	
				lw $a2, snakeColor
						
				sw $ra, rastorage	
				jal colorPixel
				lw $ra, rastorage
	
				j keeploop
			
				Head:
					# Color pixel snake
					move $a0, $t8
					move $a1, $t4	
					lw $a2, snakeHeadColor
					
					sw $ra, rastorage	
					jal colorPixel
					lw $ra, rastorage
					
					j keeploop				
				
			printElse:

				move $a0, $t8
				move $a1, $t4
				la $a2, xApple
				la $a3, yApple	
						
				sw $ra, rastorage	
				jal isApple
				lw $ra, rastorage
				
				beq $v0, $zero, point			
				
					move $a0, $t8
					move $a1, $t4	
					lw $a2, appleColor
					
					sw $ra, rastorage
					jal colorPixel
					lw $ra, rastorage									
					j keeploop
																																	
				point:												
				move $a0, $t8
				move $a1, $t4	
				lw $a2, grassColor
					
				sw $ra, rastorage	
				jal colorPixel
				lw $ra, rastorage
				
				j keeploop
		
		keeploop:
		addi $t8, $t8, 1
		bne $t8, 16, innerloop
	
	
	# Print '\n'
	li $a0, '\n'
	sw $ra, rastorage	
	jal displayChar
	lw $ra, rastorage
	
	li $t8, 0		
	addi $t4, $t4, 1
	bne $t4, 16, outerloop
	
	jr $ra


getDir:	# This function returns to $v0 a direction input by the user

	lw $t4, snakeDir # The default return is the current direction
	
	input_loop:
		li $v0, 30
		syscall
		move $t9, $a0
		
		
		lw $t0, rcontrol
		lw $t1, rdata	
	
		reading_loop:
	
			lw $t2, 0($t0)
			andi $t2, $t2, 0x1
			
			li $v0, 30
			syscall
			sub $t8, $a0, $t9
			bge $t8, $s0, invalid # time restriction
	
			bne $t2, 1, reading_loop
	
		lw $t2, 0($t1)	# The direction input by the user is in $t2 now.
		lw $t3, snakeDir # The direction of the snake is in $t3.
	
		# The only rule the input has to follow is that it cant be opposite to the snake direction.
 	   	# Opposite pairs: 'w'?'s', 'a'?'d'
 	  	# If they are NOT opposite, branch to isValid	

	
		beq $t3, 119, chk1 # If $t3 = w
		beq $t3, 115, chk2 # If $t3 = s
		beq $t3, 97, chk3 # If $t3 = a
		beq $t3, 100, chk4 # If $t3 = d	
		j invalid
	
		chk1:
			beq $t2, 115, invalid # If $t2 = s, they are opposites
			j isValid
	
		chk2:
			beq $t2, 119, invalid # If $t2 = w, they are opposites
			j isValid
	
		chk3:
			beq $t2, 100, invalid # If $t2 = d, they are opposites
			j isValid
	
		chk4:
			beq $t2, 97, invalid # If $t2 = a, they are opposites
			j isValid
		
		isValid:
		
			move $t4, $t2 # If the direction is valid, it sets the return variable to that direction
	
		invalid:

	li $v0, 30
	syscall
	sub $t9, $a0, $t9
	blt $t9, $s0, input_loop
	
	move $v0, $t4 # It returns the direction chosen by the user
	jr $ra		

	




update:

# **BODY**

lw $t2, snakeSize
addi $t2, $t2, -1
li $t3, 0
li $t4, 0
la $t5, xSnake
la $t6, ySnake
move $t8, $t2

shiftloop:
	beq $t8, $zero, shiftdone
	sll $t4, $t8, 2
	add $t7, $t6, $t4
	add $t4, $t5, $t4
	lw $t3, -4($t7)
	sw $t3, 0($t7)
	lw $t3, -4($t4)
	sw $t3, 0($t4)
	addi $t8, $t8, -1
	j shiftloop
shiftdone:


# **HEAD**

# w : 119
# s : 115
# d : 100
# a : 97

lw $t0, snakeDir

beq $t0, 119, moveup
beq $t0, 115, movedown
beq $t0, 100, moveright
beq $t0, 97, moveleft

moveup:
	lw $t1, ySnake
	addi $t1, $t1, -1
	sw $t1, ySnake
	j backmain

movedown:
	lw $t1, ySnake
	addi $t1, $t1, 1
	sw $t1, ySnake
	j backmain

moveright:
	lw $t1, xSnake
	addi $t1, $t1, 1
	sw $t1, xSnake
	j backmain

moveleft:
	lw $t1, xSnake
	addi $t1, $t1, -1
	sw $t1, xSnake
	j backmain

backmain:
	jr $ra






updateAndExtend:

# **BODY**

lw $t2, snakeSize
li $t3, 0
li $t4, 0
la $t5, xSnake
la $t6, ySnake
move $t8, $t2

shiftloop2:
	beq $t8, $zero, shiftdone2
	sll $t4, $t8, 2
	add $t7, $t6, $t4
	add $t4, $t5, $t4
	lw $t3, -4($t7)
	sw $t3, 0($t7)
	lw $t3, -4($t4)
	sw $t3, 0($t4)
	addi $t8, $t8, -1
	j shiftloop2
shiftdone2:

lw $t7, snakeSize # INCREMENTING SIZE OF THE SNAKE
addi $t7, $t7, 1
sw $t7, snakeSize


# **HEAD**

lw $t0, snakeDir

# w : 119
# s : 115
# d : 100
# a : 97

beq $t0, 119, moveup2
beq $t0, 115, movedown2
beq $t0, 100, moveright2
beq $t0, 97, moveleft2

moveup2:
	lw $t1, ySnake
	addi $t1, $t1, -1
	sw $t1, ySnake
	j backmain2
	
movedown2:
	lw $t1, ySnake
	addi $t1, $t1, 1
	sw $t1, ySnake
	j backmain2
	
moveright2:
	lw $t1, xSnake
	addi $t1, $t1, 1
	sw $t1, xSnake
	j backmain2
	
moveleft2:
	lw $t1, xSnake
	addi $t1, $t1, -1
	sw $t1, xSnake
	j backmain2
	
backmain2:
	jr $ra


isEating: # This function returns to $v0 wether or not the snake is gonna eat an apple with the current direction

	lw $t0, xSnake	# Snake coordinates
	lw $t1, ySnake # Snake coordinates
	lw $t2, xApple # Apple coordinates
	lw $t3, yApple # Apple coordinates
	lw $t4, snakeDir # Snake direction

	beq $t4, 119, moveup3
	beq $t4, 115, movedown3
	beq $t4, 100, moveright3
	beq $t4, 97, moveleft3

	moveup3:
		addi $t1, $t1, -1
		j compare
	movedown3:
		addi $t1, $t1, 1
		j compare	
	moveright3:
		addi $t0, $t0, 1
		j compare	
	moveleft3:
		addi $t0, $t0, -1
		j compare
	
	compare:
	beq $t0, $t2, equalfirst
	li $v0, 0
	j backmain3
		
		equalfirst:
			beq $t1, $t3, equalsecond
			li $v0, 0
			j backmain3
			
			equalsecond:
				li $v0, 1
				j backmain3	
		
	
backmain3:
		jr $ra

GenApple: # Generates coordinates for the apple and returns them to $v0 and $v1

	la $t4, xAllPossibleCoords
	la $t5, yAllPossibleCoords
	sw $ra, rastorage

	# Firstly, we want to append every coordinate in the map that is not inside the snake to this array.
	# Luckily, there is a function for that already defined, (isInSnake).
	
	li $t0, 0 # This will represent the x in each coordinate.
	li $t1, 0 # This will represent the y in each coordinate.
	li $t2, 0 # This will represent the size of the new array.
	
	outerforloop:
		li $t1, 0
		innerforloop:	
			move $a0, $t0
			move $a1, $t1
			la $t9, xSnake
			move $a2, $t9
			lw $t9, snakeSize
			move $a3, $t9 
			
			sw $t0, var1storage # Storing variables $t0, $t1, $t2 in memory.
			sw $t1, var2storage			
			sw $t2, var3storage			
			
			jal isInSnake # Another function is called (temporary variables like $t0 and $t1 have now garbage values in them).
			
			lw $t0, var1storage # Loading variables $t0, $t1, $t2 from memory to restore them.
			lw $t1, var2storage			
			lw $t2, var3storage				

			beq $v0, 1, notAppend
			
			# APPEND HERE
			la $t4, xAllPossibleCoords
			la $t5, yAllPossibleCoords
	
			sll $t3, $t2, 2
			add $t6, $t4, $t3 # $t6 = current index * 4 + x array adress 
			add $t7, $t5, $t3 # $t7 = current index * 4 + y array adress 	
			
			sw $t0, 0($t6)
			sw $t1, 0($t7)
			
			addi $t2, $t2, 1		
			
			notAppend:

			addi $t1, $t1, 1
			bne $t1, 16, innerforloop
			
		addi $t0, $t0, 1	
		bne $t0, 16, outerforloop
	
	move $a0, $t2
	li $v0, 1
	syscall
		
	# Now that we have the array and its size

	li $v0, 30
	syscall
	add $a1, $t2, -1
	li $v0, 42	
	syscall        	 	# This syscall generates a random number between 0 and the size of the vector - 1 inclusive and inserts it into $a0
	sll $a0, $a0, 2

	la $t4, xAllPossibleCoords
	la $t5, yAllPossibleCoords
	
	add $t0, $a0, $t4
	lw $v0, 0($t0)
	add $t0, $a0, $t5
	lw $v1, 0($t0)
				
	lw $ra, rastorage
	jr $ra




isDead: # Returns to $v0 wether the snake is dead or not.

	li $v0, 0 # The standard case is the snake is not dead.

	# If the head coordinates are the same as any other coordinates in the snake, the snake is dead.

	li $t0, 1
	lw $t1, snakeSize
	la $t6, xSnake
	la $t7, ySnake

	isDeadLoop:
		beq $t0, $t1, exitDeadLoop # When the number of iteration is equal to the size of the snake, we can stop.
		sll $t2, $t0, 2
		add $t8, $t6, $t2 # $t8 = xSnake + currentIter * 4
		add $t9, $t7, $t2 # $t9 = ySnake + currentIter * 4
		addi $t0, $t0, 1
	
		lw $t3, ($t6) # xSnake (head)
		lw $t4, ($t8) # xSnake (body part, whichever)
		bne $t3, $t4, isDeadLoop # If they are not equal, we keep the loop
	
		lw $t3, ($t7) # ySnake (head)
		lw $t4, ($t9) # ySnake (body part, whichever)	
		bne $t3, $t4, isDeadLoop # If they are not equal, we keep the loop
	
		li $v0, 1 # If it has arrived to this point, both are equal meaning the snake is dead, and it can go back to main.
		j backmain4
	
	exitDeadLoop:	
		

	# If the head coordinates are out of bounds, the snake is dead.

	lw $t0, xSnake
	lw $t1, ySnake
	
	blt $t0, 0, outOfBoundsDead
	bgt $t0, 15, outOfBoundsDead
	blt $t1, 0, outOfBoundsDead
	bgt $t1, 15, outOfBoundsDead
	
	j backmain4 # If it has made it here, it is not out of loops.
	
	outOfBoundsDead:
		li $v0, 1
		
	backmain4:
		jr $ra
