.data

xSnake: .word -1:256
ySnake: .word -1:256
xApple: .word 11
yApple: .word 7
snakeSize: .word 0
snakeDir: .word 100	# Starting direction is 'd' (100 in ASCII)

rastorage: .word 0

rcontrol: .word 0xFFFF0000
rdata: .word 0xFFFF0004
tcontrol: .word 0xFFFF0008
tdata:.word 0xFFFF000C


.text
.globl main

main:


# INITIALIZING THE SNAKE VALUES.

li $t1, 2
sw $t1, snakeSize	

la $a0, xSnake
li $t1, 4
sw $t1, 0($a0)

la $a1, ySnake
li $t1, 7
sw $t1, 0($a1)    
    
la $a0, xSnake
li $t1, 3
sw $t1, 4($a0)

la $a1, ySnake
li $t1, 7
sw $t1, 4($a1)  
   
jal print

li $v0, 10
syscall





display: # Receives to $a0 the character it wants to display and it displays it.

	writing_loop:
	lw $t9, tcontrol
	lw $t9, 0($t9)
	andi $t9, $t9, 0x1
	bne $t9, 1, writing_loop
	
	lw $t7, tdata
	move $t9, $a0
	sw $t9, 0($t7)
	
	jr $ra

isApple: # Receives to $a0 and $a1 coords x and y. Receives to $a2 xApple direction and to $a3 the yApple direction. Returns to v0 wether or not is the apple.


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


print: # This function receives to $a0 snakeX, to $a1 snakeY

	li $t4, 0
	li $t8, 0

	outerloop:
		innerloop:

			move $a0, $t8
			move $a1, $t4
			la $a2, xSnake
			lw $a3, snakeSize
		
			sw $ra, rastorage
			jal isInSnake
			lw $ra, rastorage 	
		
			beq $v0, $zero, printElse
		
			printSnake:
				beq $v1, 1 , Head
				
				# Print 0x6F (o)
				li $a0, 0x6F	
				sw $ra, rastorage	
				jal display
				lw $ra, rastorage
	
				j keeploop
			
				Head:
					# Print 0x4F (O)
					li $a0, 0x4F
					sw $ra, rastorage	
					jal display
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
				
					# Print 'a' (a)
					li $a0, 'a'
					sw $ra, rastorage
					jal display
					lw $ra, rastorage									
					j keeploop
																																	
				point:												
				# Print 0x2E (.)
				li $a0, 0x2E
				sw $ra, rastorage	
				jal display
				lw $ra, rastorage
				
				j keeploop
		
		keeploop:
		addi $t8, $t8, 1
		bne $t8, 16, innerloop
	
	
	# Print '\n'
	li $a0, '\n'
	sw $ra, rastorage	
	jal display
	lw $ra, rastorage
	
	li $t8, 0		
	addi $t4, $t4, 1
	bne $t4, 16, outerloop
	
	jr $ra


getDir:
	




move:




AteApple:




GenApple:






Died:





Sleep:
