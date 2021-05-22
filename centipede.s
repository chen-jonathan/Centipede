#####################################################################
#CSC258H Winter 2021 Assembly Final Projec
# University of Toronto, St. George
# Student: Jonathan Chen, 1006046609
# Bitmap Display Configuration:
# - Unit width in pixels: 8   
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
# - Milestone 3 completed
.data
	displayAddress:	.word	0x10008000
	screenHeight: .word 32
	screenWidth: .word 32
	bgColour: .word 0x000000
	#Store default colour values in memory
	bugBlasterColour: .word 0x0070ff
	centipedeBodyColour: .word 0x00ff33
	centipedeHeadColour: .word 0xff0000
	mushroomColour: .word 0xcc9900
	bulletColour: .word 0xffffff
	fleaColour: .word 0xff00ff
	#Store bug blaster location (tip of blaster in memory)  
	bugBlasterX: .word 16
	bugBlasterY: .word 31
	
		
	#Store Mushroom Locations
	mushLocationX: .word 0:4000
	mushLocationY: .word 0:4000
	numMush: .word 0
	totalMushleft:.word 0
	#mushVisible: .space 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	
	#Store bullet location
	bulletLocationX: .word 100
	bulletLocationY: .word 32
	numBullets: .word 0
	
	#Store centipede location
	numCent: .word 10
	centLocationX: .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	centLocationY: .word 0:40

	#Store which segment is the head and tail
	centHead: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
	
	#Store Left/Right Direction of each segment
	centDir: .word 1:40
	#Store whether or not segment collided with soemthing
	centHit: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	
	#Store location of flea
	fleaX: .word -1
	fleaY: .word -1

.text
############################################################################################
#$s0 reserved for blaster.x, $s1 reserved for blaster.y
start_game:
	lw $s0, bugBlasterX
	lw $s1, bugBlasterY
# GAME LOOP
game_loop_main:	
	######################## Reset drawings #############################
	#Reset drawing of blaster
	lw $a0, bgColour		# Load bgColour into $a0 to reset drawings....
	jal draw_bug_blaster
	#Reset drawing of centipede
	lw $a1, bgColour
	jal initialize_cent	
	jal draw_centipede
	
	jal draw_bullet	
	jal draw_flea
	jal initialize_mushrooms
	jal draw_mushroom
	
	# Get Keyboard Input, move centipede accordingly:
	
	lw $t9, screenWidth				# Load in screenWidth
	addi $t9, $t9, -1				# t9 = screenWidth - 1
	

	
	lw $t8, 0xffff0000				# Check MMIO location for keypress 
	beq $t8, 1, keyboard_input		# If we have input, jump to handler
	j keyboard_input_done			# Otherwise, jump till end

	keyboard_input:
		lw $t8, 0xffff0004				# Read Key value into t8
		beq $t8, 0x6A, keyboard_left	# If `j`, move left
		beq $t8, 0x6B, keyboard_right	# If `k`, move right
		beq $t8, 0x78, keyboard_shoot
		j keyboard_input_done
		
	keyboard_left:	
			li $s3, 0
			beq $s0, $s3, keyboard_input_done 	# If at left wall, don't go anymore left	
			addi $s0, $s0, -1				# Otherwise, decrement x			
			j keyboard_input_done			# done
			
	keyboard_right:
			li $s3 31, 
			beq $s0, $s3, keyboard_input_done   #If at right wall don't go anymore right
			addi $s0, $s0, 1
			j keyboard_input_done
	keyboard_shoot:
			la $s2, numBullets 
			lw $s7, 0($s2)
			li $s3, 1 
			beq $s7,  $s3, keyboard_input_done   #If we already have 1 bullet, don't render another one
			la $s4, bulletLocationX
			la $s5, bulletLocationY
			sw $s0, 0($s4) 			#Set location of bullet
			sw $s1, 0($s5)
			add $s7, $s7, 1
			sw $s7, 0($s2)
			j keyboard_input_done
			
	keyboard_input_done:	
		
	add $a0, $t9, $zero
	jal move_centipede
	
	jal flea_drop
	jal move_flea
	lw $a0, fleaColour
	jal draw_flea
	
	jal move_bullet
	lw $a0, bulletColour
	jal draw_bullet
	
	
	lw $a0, mushroomColour
	jal draw_mushroom
	
	lw $a0, bugBlasterColour
	jal draw_bug_blaster 
	
	lw $a0, centipedeHeadColour 
	lw $a1, centipedeBodyColour
	jal draw_centipede				#Draw the centipede
	
	################################################################################
	# Sleep for a bit before restarting the loop
	
	li $v0, 32				# Sleep op code
	li $a0, 100				# Sleep 1/20 second 
	syscall
	j game_loop_main

############################################################################################
#Draw Centipede
draw_centipede:	
	la $t8, centLocationX
	la $t9, centLocationY
	la $t7, centHead
	add $t0, $zero, $zero
	add $t1, $zero, 10
draw_centipede_loop:
	bge $t0, $t1, draw_centipede_return
	sll $t2, $t0, 2
	add $t3, $t8, $t2
	add $t4, $t9, $t2
	add $s3, $t7, $t2
	
	lb $t5, 0($t3)
	lb  $t6, 0($t4)
	li $s2, -1
	beq $t5, $s2, increment_var #Check it centipede segment has already been shot
	lb $s4, 0($s3)
	
	sll $s2, $t6, 5
	add $s2, $s2, $t5
	sll $s2, $s2, 2				
	add $s2, $s2, $gp
	
	addi $s5, $zero, 1
	beq $s5, $s4, draw_red
	sw $a1, 0($s2)	
	j increment_var		
draw_red: 
	sw $a0, 0($s2)
increment_var:
	addi $t0, $t0, 1
	j draw_centipede_loop
draw_centipede_return:
	jr $ra
############################################################################################
# Draw Bug Blaster
draw_bug_blaster:

	sll $t0, $s1, 5				# idx = blaster.y * 32
	add $t0, $t0, $s0			# idx = (blaster.y * 32) + x
	sll $t0, $t0, 2				# idx = (blaster.y * 32 + x) * 4
	add $t0, $t0, $gp			# idx = $gp + (blaster.y * 32 + x) * 4


	sw $a0, 0($t0) #draw top of blaster
	#sw $a0, 128($t0) #draw bottomt side of blaster
	#sw $a0, 132($t0) #draw right of blaster
	#sw $a0, 124($t0)  #draw leftt of blaster	
	jr $ra	#return function call

	

############################################################################################
# Move Centipede
move_centipede:
	la $t8, centLocationX
	la $t9, centLocationY
	la $t7 centDir
	la $t2 centHit
	add $t0, $zero, $zero
	add $t1, $zero, 10
	
move_centipede_loop:
	#Turn collisions into function
	bge $t0, $t1, move_centipede_return
	lw $t6 0($t8)
	lw $t4, 0($t9)
	li $t3, -1
	beq $t6, $t3, increment_var_move_cent #Check if segment has a garbage value (meaning it was shot by bullet)
	lw $t5, 0($t7)
	lw $t3, 0($t2)
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)		#save $ra value on stack
	jal cent_collisions
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	li $s5, 1
	beq $v0, $s5, increment_var_move_cent

update_location:
	add $t6, $t6, $t5
	sw $t6, 0($t8)
	add $t3, $zero, $zero
	sw $t3, 0($t2)
	
increment_var_move_cent:	
	addi $t8, $t8, 4 	#set variables for next iteration
	addi $t7, $t7, 4
	addi $t9, $t9, 4	
	addi $t2, $t2, 4
	addi $t0, $t0, 1
	j move_centipede_loop
	
move_centipede_return:
	jr $ra
############################################################################################
#Check Collision with current centipede segment
	#$t6: centLocationX, $t4: centLocationY
	#$t5 direction of cent, $t3 is hit
cent_collisions:	
	li $v0, 0
	li $s5, 1
	beq $s5, $t3, jump_back
#Check collision with bug bglaster
	#Check collision with blaster
	bne $s0, $t6, collide_mushrooms
	bne $s1, $t4, collide_mushrooms
	j bye_loop_FINISH
#Check collision with mushroom
collide_mushrooms:
	la $s2, mushLocationX
	la $s3  mushLocationY
	la $s4 numMush
	lw $a2, 0($s4)
	li $s5, 0
check_mushroom:
	bge $s5, $a2, check_walls
	lw $s6, 0($s2)
	lw $s7 0($s3)
	bne $s7, $t4, increment_var_mush
	addi $s4, $s6, 1
	bne $t6, $s4, check_left_side
	j left_wall
	
check_left_side:
	add $s4, $s6, -1
	bne $t6, $s4, increment_var_mush
	j right_wall
increment_var_mush:
	addi $s5, $s5, 1
	addi $s2, $s2, 4
	addi $s3, $s3, 4
	j check_mushroom
	

check_walls: #Check collision with wall
	beq $t6, $a0, right_wall
	li $s5, 0
	beq $s5, $t6, left_wall
	j jump_back

left_wall:
	addi $s5, $zero, 31
	beq $s5, $t4, last_row_left
	addi $s5, $zero, -1
	bne $s5, $t5, jump_back	#ignore this if block if we are moving in wrong direction
	addi $t4, $t4, 1   #Go down 1 horizontal level
	sw $t4, 0($t9)
	addi $t5, $zero, 1 #Set direction
	sw $t5, 0($t7)	
	addi $t3, $zero, 1
	sw $t3, 0($t2)
	li $v0, 1
	j jump_back
last_row_left:
	addi $t5, $zero, 1 #Set direction
	sw $t5, 0($t7)	
	addi $t3, $zero, 1
	sw $t3, 0($t2)
	li $v0, 1
	j jump_back
		
	
right_wall: 
	addi $s5, $zero, 31
	beq $s5, $t4, last_row_right
	addi $s5, $zero, 1
	bne $s5, $t5, jump_back	#ignore this if block if we are moving in opposite direction
	addi $t4, $t4, 1   #Go down 1 horizontal level
	sw $t4, 0($t9)
	addi $t5, $zero, -1 #Set direction
	sw $t5, 0($t7)	
	addi $t3, $zero, 1
	sw $t3, 0($t2)
	li $v0, 1
	j jump_back	
last_row_right:
	addi $t5, $zero, -1 #Set direction
	sw $t5, 0($t7)	
	addi $t3, $zero, 1
	sw $t3, 0($t2)
	li $v0, 1
	j jump_back

jump_back:
	jr $ra
	
	
############################################################################################
#Draw Mushrooms
draw_mushroom:
	la $t9, mushLocationX
	la $t8 	mushLocationY
	la $t5, numMush
	
	lw $t4, 0($t5) 
	add $t0, $zero, $zero
	add $t1, $zero, $t4
draw_mushroom_loop:
	bge $t0, $t1, draw_mushroom_return
	
	lw $t7, 0($t9)
	lw $t6 0($t8)
	
	sll $s2, $t6, 5
	add $s2, $s2, $t7
	sll $s2, $s2, 2				
	add $s2, $s2, $gp
	
	addi $s5, $zero, 1
	sw $a0, 0($s2)	
increment_draw_mushroom:
	addi $t9, $t9, 4
	addi $t8, $t8, 4
	addi $t0 $t0, 1
	j draw_mushroom_loop
	
draw_mushroom_return:
	jr $ra

############################################################################################
#Draw Bullet
draw_bullet:
	la $t9, bulletLocationX
	la $t8 	bulletLocationY	
	
	la $t4, numBullets
	lw $t4, 0($t4)
	li $t3, 0
	beq $t3, $t4, draw_bullet_return
	
	lw $t7, 0($t9)
	lw $t6, 0($t8)
	sll $t0, $t6, 5			
	add $t0, $t0, $t7			
	sll $t0, $t0, 2				
	add $t0, $t0, $gp			
	
	sw $a0, 0($t0) #draw top of blaster
draw_bullet_return:
	jr $ra

############################################################################################
#Move Bullet
move_bullet:
	la $t9, bulletLocationY	
	la $t4, numBullets
	lw $t5, 0($t4)
	li $t3, 0
	beq $t3, $t5, return
	lw $t8, 0($t9)
	addi $t8, $t8, -1
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)		#save $ra value on stack
	jal bullet_collisions
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	sw $t8, 0($t9) 		#save information
	
	li $t3, 0		#check if bullet goes out of screen
	bge  $t8, $t3, return
	la $t4, numBullets
	li $t5, 0
	sw $t5, 0($t4)
return:
	jr $ra
############################################################################################
#Check Collision with bullet
	#$t7: bulletLocationX, $t8: bulletLocationY
	#$t9: address of bulletLocationY
bullet_collisions:
	la $t7, bulletLocationX
	lw $t7, 0($t7)
	la $t6, mushLocationX
	la $t5 	mushLocationY
	la $t4, numMush
	
	lw $t4, 0($t4) 
	add $t0, $zero, $zero
	add $t1, $zero, $t4
collide_mushroom_loop:
	bge $t0, $t1,collide_centipede
	lw $t3, 0($t6)
	lw $t2 0($t5)
	
	bne $t3, $t7, increment_collide_mushroom 
	bne $t2, $t8, increment_collide_mushroom
	li $t3, -1	#Set mushroom x and y to garbage values
	li $t2, -1
	sw $t3, 0($t6)
	sw $t2, 0($t5)
	la $s2, numBullets  #Set # of bullets back to 0
	li $s3, 0
	sw $s3, 0($s2)
	la $s2, totalMushleft
	lw $s3, 0($s2)
	add $s3, $s3, -1
	sw $s3, 0($s2)
	
increment_collide_mushroom:
	addi $t6, $t6, 4
	addi $t5, $t5, 4
	addi $t0, $t0, 1
	j collide_mushroom_loop
	
collide_centipede:
	la $t6, centLocationX
	la $t5 	centLocationY
	
	addi $t1, $zero, 10 
	add $t0, $zero, $zero
collide_centipede_loop:	
	bge $t0, $t1, bullet_collide_return
	lw $t3, 0($t6)
	li $t2, -1
	beq $t3, $t2, increment_collide_centipede
	lw $t2 0($t5)
	
	bne $t3, $t7, increment_collide_centipede
	bne $t2, $t8, increment_collide_centipede	
		
	
	
	la $s2, numBullets 	#Set number of bullets to 0
	li $s3, 0
	sw $s3, 0($s2)
		
	la $s2, numMush		
	lw $s3, 0($s2)
	
	sll $s3, $s3, 2		#Set new mushroom to where centipede segment was shot
	la $s4, mushLocationX
	add $s4, $s4, $s3
	sw $t3, 0($s4)
	la $s5, mushLocationY
	add $s5, $s5, $s3
	sw $t2, 0($s5)
	
	srl $s3, $s3, 2     #increment # of mushrooms by 1
	addi $s3, $s3, 1
	sw $s3, 0($s2)	
		
	la $s2, totalMushleft  #increment totalMushleft
	lw $s3, 0($s2)
	addi $s3, $s3, 1
	sw $s3, 0($s2)	
	
	li $t3, -1	#Set centipede x and y to garbage values
	li $t2, -1
	sw $t3, 0($t6)
	sw $t2, 0($t5)
	
	la $s4, numCent		#Update number of centipedes
	lw $s3, 0($s4)
	add $s3, $s3, -1	
	sw $s3, 0($s4)	
	li $v0,1     #prepare system call 
	move $a0,$s3 #copy t0 to a0 
	syscall
	
	addi $s3, $t0, -1
	sll $s3, $s3, 2			#Set another head
	la $s4, centHead
	add $s4, $s4, $s3
	li $s3, 1
	sw $s3, 0($s4)
	
increment_collide_centipede:
	addi $t6, $t6, 4
	addi $t5, $t5, 4
	addi $t0, $t0, 1
	j collide_centipede_loop
	
bullet_collide_return:
	jr $ra
	
############################################################################################
#Draw Flea
draw_flea:
	la $t8, fleaX
	la $t9, fleaY
	lw $t8, 0($t8)
	lw $t9, 0($t9)
	li $t7, -1
	beq $t8, $t7, draw_flea_return
	sll $t0, $t9, 5				
	add $t0, $t0, $t8			
	sll $t0, $t0, 2				
	add $t0, $t0, $gp		
	
	sw $a0, 0($t0)
draw_flea_return:
	jr $ra	
############################################################################################
#Randomly show flea
flea_drop:
	la $t8, fleaX
	la $t9, fleaY
	lw $t5, 0($t8)
	lw $t6, 0($t9)
	li $t7, -1
	bne $t5, $t7, flea_drop_return
	li $v0, 42 
	li $a0, 0 
	li $a1, 8
	syscall
	li $t7, 1
	bne $a0, $t7, flea_drop_return
	#Random x and y coordinate
	li $v0, 42 
	li $a0, 0 
	li $a1, 31	
	syscall
	sw $a0, 0($t8)
	li $v0, 42 
	li $a0, 0 
	li $a1, 16	
	syscall
	sw $a0, 0($t9)
flea_drop_return:
	jr $ra
############################################################################################
#Move flea if it exists
move_flea:
	la $t8, fleaX
	la $t9, fleaY
	lw $t5, 0($t8)
	lw $t6, 0($t9)
	li $t7, -1
	beq $t5, $t7, flea_drop_return
	#Check collision with blaster
	bne $s0, $t5, bullet_check
	bne $s1, $t6, bullet_check
	j bye_loop_FINISH
	#Go to end screen 
	
bullet_check:
	la $s6, numBullets
	lw $s7, 0($s6)
	li $s5, 0
	beq $s7, $s5, did_not_collide
	la $t4, bulletLocationX
	la $t3, bulletLocationY
	lw $s2, 0($t4)
	lw $s3, 0($t3)
	bne $s2, $t5, did_not_collide
	bne $s3, $t6, check_above
	li $s5, 0
	sw $s5, 0($s6)
	li $s5, -1
	sw $s5, 0($t8)
	sw $s5, 0($t9)
	sw $s5, 0($t4)
	sw $s5, 0($t3)
	j move_flea_return
	
check_above: #Take care of case wheen bullet and flea are side by side
	add $s5, $s3, -1
	bne $s5, $t6, did_not_collide
	li $s5, 0
	sw $s5, 0($s6)
	li $s5, -1
	sw $s5, 0($t8)
	sw $s5, 0($t9)
	sw $s5, 0($t4)
	sw $s5, 0($t3)
	j move_flea_return
		
did_not_collide:
	li $t7, 31
	beq, $t7, $t6, at_bottom
	add $t7, $t6, 1
	sw $t7, 0($t9)
	jr $ra
at_bottom:
	li $t7, -1
	sw $t7, 0($t8)
	sw $t7, 0($t9)
	jr $ra	
move_flea_return:
	jr $ra

############################################################################################
#Initialize 10 mushroom locations randomly
initialize_mushrooms:
	la $t9, mushLocationX
	la $t8  mushLocationY
	la $t7, totalMushleft
	lw $t6, 0($t7)
	li $t5, 0
	bne $t6, $t5, initial_mushroom_return
	addi $t6, $zero, 10
	sw $t6, 0($t7)			#load totalMushleft = 10
	la $t7, numMush
	sw $t6, 0($t7)			#load numMush = 10
	add $t0, $zero, $zero
initialize_mushroom_loop:
	bge $t0, $t6,initial_mushroom_return
	li $v0, 42 
	li $a0, 0 
	li $a1, 28
	syscall	
	addi $a0, $a0, 2
	sw $a0, 0($t9)
	li $v0, 42 
	li $a0, 0 
	li $a1, 28
	syscall	
	addi $a0, $a0, 1
	sw $a0, 0($t8)
	
	addi $t0, $t0, 1
	addi $t9, $t9, 4
	addi $t8, $t8, 4
	j initialize_mushroom_loop

initial_mushroom_return:
	jr $ra
############################################################################################
#Initialize 10 centipede
initialize_cent:
	la $t7, numCent
	lw $t6, 0($t7)  #Check if there is no more centipedes
	li $t5, 0
	bne $t6, $t5, initial_cent_return
	li $t6, 10
	sw $t6, 0($t7)
	add $t0, $zero, $zero
	la $t9, centLocationX
	la $t8  centLocationY
	la $t7, centHead
	la $t4, centDir
initialize_cent_loop:
	bge $t0, $t6, initial_cent_return
	li $t5, 0
	sw $t5, 0($t8) #set default y coordinate
	sw $t0, 0($t9) #set default x coordinate
	li $t3, 9
	beq $t3, $t0, set_first_head
	sw $t5, 0($t7) #set default head values
	j set_direction
set_first_head: 
	li $t2, 1
	sw $t2, 0($t7)
set_direction:	
	li $t5, 1	
	sw $t5, 0($t4) #set default direction
	addi $t0, $t0, 1
	addi $t9, $t9, 4
	addi $t8, $t8, 4
	addi $t4, $t4, 4
	addi $t7, $t7, 4
	j initialize_cent_loop
initial_cent_return:
	jr $ra
############################################################################################
#End screen
bye_loop_FINISH:
	
	#paint screen black
	lw $a0, bgColour		# Load bgColour into $a0 to reset drawings....
	jal draw_bug_blaster
	#Reset drawing of centipede
	lw $a1, bgColour
	jal draw_centipede
	jal draw_bullet
	jal draw_mushroom
	jal draw_flea	
	
	lw $a0, bulletColour
	jal draw_bye
	
end_loop: # End loop that asks for input to restart game
	lw $t8, 0xffff0000				# Check MMIO location for keypress 
	beq $t8, 1, end_keyboard_input		# If we have input, jump to handler
	j end_keyboard_input_done			# Otherwise, jump till end

	end_keyboard_input:
		lw $t8, 0xffff0004				# Read Key value into t8
		beq $t8, 0x72, keyboard_restart			# If `r`, restart game
		j end_keyboard_input_done
	keyboard_restart:	
		la $t1, totalMushleft  #set number of mushrooms and number of centipede segments to 0
		li $t2, 0
		sw $t2, 0($t1)
		la $t1, numCent
		sw $t2, 0($t1)
		lw $a0, bgColour
		jal draw_bye
		j start_game
		
	end_keyboard_input_done:
	j end_loop
############################################################################################
#Draw bye
draw_bye:	
	# draw b
	lw $t0, displayAddress
	addi $t0, $t0, 1576
	sw $a0, 128($t0)
	sw $a0, 256($t0)
	sw $a0, 384($t0)
	sw $a0, 388($t0)
	sw $a0, 392($t0)
	sw $a0, 520($t0)
	sw $a0, 512($t0)
	sw $a0, 640($t0)
	sw $a0, 644($t0)
	sw $a0, 648($t0)
	#draw y
	sw $a0, 400($t0)
	sw $a0, 528($t0)
	sw $a0, 656($t0)
	sw $a0, 408($t0)
	sw $a0, 536($t0)
	sw $a0, 660($t0)
	sw $a0, 664($t0)
	sw $a0, 792($t0)
	sw $a0, 920($t0)
	sw $a0, 916($t0)
	sw $a0, 912($t0)
	#draw E
	sw $a0, 672($t0)
	sw $a0, 676($t0)
	sw $a0, 680($t0)
	sw $a0, 544($t0)
	sw $a0, 416($t0)
	sw $a0, 420($t0)
	sw $a0, 424($t0)
	sw $a0, 288($t0)
	sw $a0, 160($t0)
	sw $a0, 164($t0)
	sw $a0, 168($t0)
	jr $ra
	
END:	li $v0, 10
	syscall
		
	
