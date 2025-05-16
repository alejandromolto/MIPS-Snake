.data
    xSnake: .word -1:256
    ySnake: .word -1:256
    xApple: .word 11
    yApple: .word 7
    snakeSize: .word 0
    rastorage: .word 0
	
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
		
		beq $v0, $zero, printPoint 
		
		printSnake:
			li $t7, 1
			beq $v1, $t7 , Head
			li $a0, 0x6F	
			li $v0, 11
			syscall
			j keeploop
			
			Head:
				li $a0, 0x4F
				li $v0, 11
				syscall
				j keeploop				
				
		printPoint:
			li $a0, 0x2E
			li $v0, 11
			syscall		
			j keeploop
		
		keeploop:
		addi $t8, $t8, 1
		li $t7, 16
		bne $t8, $t7, innerloop
	

	li $a0, '\n'
	li $v0, 11
	syscall
	
	li $t8, 0		
	addi $t4, $t4, 1
	li $t7, 16
	bne $t4, $t7, outerloop
	
	jr $ra

getDir:
	




move:




AteApple:




GenApple:






Died:





Sleep:
