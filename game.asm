#####################################################################
#
# CSCB58 Winter 2021 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Jiazheng (Kevin) Li, 1006075630, lijiaz11
#
# Bitmap Display Configuration:
# -Unit width in pixels: 8 (update this as needed)
# -Unit height in pixels: 8 (update this as needed)
# -Display width in pixels: 256 (update this as needed)
# -Display height in pixels: 256 (update this as needed)
# -Base Address for Display: 0x10008000 ($gp)
#
# Which milestoneshave beenreached in this submission?
# (See the assignment handout for descriptions of the milestones)
# -Milestone 2 (choose the one the applies)
#
# Which approved features have been implemented for milestone 4?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)#... (add more if necessary)
#
# Link to video demonstration for final submission:
# -(insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
#Are you OKwith us sharing the video with people outside course staff?
# -yes / no/ yes, and please share this project githublink as well!
#
# Any additional information that the TA needs to know:
# -(write here, if any)
######################################################################



# Bitmap display starter code
#
# Bitmap Display Configuration:
# -Unit width in pixels: 8
# -Unit height in pixels: 8
# -Display width in pixels: 256
# -Display height in pixels: 256
# -Base Address for Display: 0x10008000 ($gp)
#
.eqv BASE_ADDRESS	0x10008000
.eqv SHIP_HEAD		0x10008818
.text
	li $t0, BASE_ADDRESS			# $t0 stores the base address for display
	li $s7, SHIP_HEAD			# $s7 stores the head of the ship
	li $s0, 3				# $s0 stores the amount of lives the player has
	
	# initial position of small asteroid
	li $v0, 42				# get a random number between 0 and 28
	li $a0, 0
	li $a1, 28
	syscall
	
	addi $a0, $a0, 3			# get the starting address of a small asteroid
	li $t1, 128
	mult $t1, $a0
	mflo $t2
	addi $t2, $t2, -48
	
	li $s6, BASE_ADDRESS			# $s6 stores the center of a small asteroid
	add $s6, $s6, $t2
	
	
	# initial position of medium asteroid
	li $v0, 42				# get a random number between 0 and 28
	li $a0, 0
	li $a1, 28
	syscall
	
	addi $a0, $a0, 4			# get the starting address of a medium asteroid
	li $t1, 128
	mult $t1, $a0
	mflo $t2
	addi $t2, $t2, -12
	
	li $s5, BASE_ADDRESS			# $s6 stores the center of a medium asteroid
	add $s5, $s5, $t2
	
	# initial position of large asteroid
	li $v0, 42				# get a random number between 0 and 28
	li $a0, 0
	li $a1, 28
	syscall
	
	addi $a0, $a0, 5			# get the starting address of a large asteroid
	li $t1, 128
	mult $t1, $a0
	mflo $t2
	addi $t2, $t2, -32
	
	li $s4, BASE_ADDRESS			# $s4 stores the center of a large asteroid
	add $s4, $s4, $t2
	
	li $t1, 0xff0000			# start display of 3 lives
	li $t0, BASE_ADDRESS
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	sw $t1, 16($t0)


loop:	

	add $t8, $zero, $zero			# reset user input register
	# takes in user input
	li $t9, 0xffff0000 
	lw $t8, 0($t9)
	beq $t8, 1, keypress_happened

	# update display
cont:	
	jal draw_ship
	jal draw_asteroids

	li $v0, 32 				# sleep for 30ms
	li $a0, 30
	syscall
	jal check_collision
	jal clear_display
	jal update_asteroid
	j loop
	
keypress_happened:
	li $t9, 0xffff0000 
	lw $t8, 4($t9) 
	# updates ship location
	beq $t8, 0x77, respond_to_w		# ASCII code of 'w' 
	beq $t8, 0x61, respond_to_a		# ASCII code of 'a' 
	beq $t8, 0x73, respond_to_s		# ASCII code of 's'
	beq $t8, 0x64, respond_to_d		# ASCII code of 'd'
	j cont
	
clear_display:
	add $s3, $ra, $zero
	
	jal clear_ship
	jal clear_sm
	jal clear_md
	jal clear_lg
	add $ra, $s3, $zero
	jr $ra
	
clear_ship:
	# clear ship
	sw $zero, 0($s7)			# paint head of the ship green.
	
	# clear body of the ship
	sw $zero, -4($s7)			# middle
	sw $zero, -8($s7)
	sw $zero, -12($s7)
				
	sw $zero, -132($s7)			# upper
	sw $zero, -136($s7)
	sw $zero, -140($s7)
			
	sw $zero, 124($s7)			# lower
	sw $zero, 120($s7)
	sw $zero, 116($s7)
	
	# clear wings of ship
	sw $zero, -268($s7)			# upper
	sw $zero, -272($s7)
	
	sw $zero, 244($s7)			# lower
	sw $zero, 240($s7)
	jr $ra
	
clear_sm:
	# clear small asteroid
	sw $zero, 0($s6)				
	sw $zero, 4($s6)
	sw $zero, -128($s6)
	jr $ra
	
clear_md:
	# clear medium asteroid
	sw $zero, 0($s5)				
	sw $zero, -124($s5)
	sw $zero, 4($s5)	
	sw $zero, 8($s5)	
	sw $zero, 132($s5)
	jr $ra
	
clear_lg:
	# clear large asteroid
	sw $zero, 0($s4)
	sw $zero, -128($s4)
	sw $zero, -252($s4)
	sw $zero, -248($s4)
	sw $zero, 4($s4)
	sw $zero, -124($s4)
	sw $zero, -120($s4)
	sw $zero, 8($s4)
	sw $zero, 12($s4)
	sw $zero, 132($s4)
	sw $zero, 136($s4)
	sw $zero, -116($s4)
	jr $ra
	
	

draw_ship:
	li $t1, 0x00ff00			# $t1 stores the green colour code
	li $t2, 0xffffff			# $t2 stores the white colour code
	li $t3, 0xff0000			# $t3 stores the red colour code
	sw $t1, 0($s7)				# paint head of the ship green.
	
	# paint body of the ship white.
	sw $t2, -4($s7)				# middle
	sw $t2, -8($s7)
	sw $t2, -12($s7)
				
	sw $t2, -132($s7)			# upper
	sw $t2, -136($s7)
	sw $t2, -140($s7)
			
	sw $t2, 124($s7)			# lower
	sw $t2, 120($s7)
	sw $t2, 116($s7)
	
	# paint wings of ship red
	sw $t3, -268($s7)			# upper
	sw $t3, -272($s7)
	
	sw $t3, 244($s7)			# lower
	sw $t3, 240($s7)				
	
	jr $ra					# go back to caller


draw_asteroids:
	li $t1, 0x5d4037			# put light brown in $t1
	li $t2, 0x4e342e			# put medium brown in $t2
	li $t3, 0x3e2723			# put dark brown in $t3
	
	# paint small asteroid
	sw $t3, 0($s6)				
	sw $t2, 4($s6)
	sw $t1, -128($s6)
	
	# paint medium asteroid
	sw $t1, 0($s5)				
	sw $t1, -124($s5)
	sw $t2, 4($s5)	
	sw $t3, 8($s5)	
	sw $t3, 132($s5)
	
	# paint large asteroid
	sw $t1, 0($s4)
	sw $t1, -128($s4)
	sw $t1, -252($s4)
	sw $t1, -248($s4)
	sw $t2, 4($s4)
	sw $t2, -124($s4)
	sw $t2, -120($s4)
	sw $t3, 8($s4)
	sw $t3, 12($s4)
	sw $t3, 132($s4)
	sw $t3, 136($s4)
	sw $t3, -116($s4)
	
	jr $ra					# go back to caller


check_collision:
	add $s3, $ra, $zero 			# store $ra in $s3

	# check if small asteroid is close to ship if not branch to next asteroid check
	# check x-axis
	li $t8, 128
	div $s7, $t8
	mfhi $t9				# store x coordinate of ship in $t9
	
	div $s6, $t8
	mfhi $t7				# store x coordinate of small asteroid in $t9
	
	sub $t6, $t9, $t7
	bltz $t6, col_md_st			# branch to next asteroid if x axis is not close
	
	# check y axis now
	div $s7, $t8
	mflo $t9				# store y coordinate of ship in $t9
	
	div $s6, $t8
	mflo $t7				# store y coordinate of small asteroid in $t9
	
	sub $t6, $t9, $t7			# get the y axis difference of the ship and small asteroid
	addi $t6, $t6, -2
	bgtz $t6, col_md_st

	addi $t6, $t6, 5
	bltz $t6, col_md_st
	
	jal sm_collision
	j collision_end

	
col_md_st:
	# check if medium asteroid is close to ship if not branch to next asteroid check
	li $t8, 128
	div $s7, $t8
	mfhi $t9				# store x coordinate of ship in $t9
	
	div $s5, $t8
	mfhi $t7				# store x coordinate of small asteroid in $t9
	
	sub $t6, $t9, $t7
	bltz $t6, col_lg_st			# branch to next asteroid if x axis is not close
	
	# check y axis now
	div $s7, $t8
	mflo $t9				# store y coordinate of ship in $t9
	
	div $s5, $t8
	mflo $t7				# store y coordinate of small asteroid in $t9
	
	sub $t6, $t9, $t7			# get the y axis difference of the ship and small asteroid
	addi $t6, $t6, -3
	bgtz $t6, col_lg_st

	
	addi $t6, $t6, 6
	bltz $t6, col_lg_st
	jal md_collision
	j collision_end
	

col_lg_st:
	# check if medium asteroid is close to ship if not branch to next asteroid check
	li $t8, 128
	div $s7, $t8
	mfhi $t9				# store x coordinate of ship in $t9
	
	div $s4, $t8
	mfhi $t7				# store x coordinate of small asteroid in $t9
	
	sub $t6, $t9, $t7
	bltz $t6, collision_end			# branch to next asteroid if x axis is not close
	
	# check y axis now
	div $s7, $t8
	mflo $t9				# store y coordinate of ship in $t9
	
	div $s4, $t8
	mflo $t7				# store y coordinate of small asteroid in $t9
	
	sub $t6, $t9, $t7			# get the y axis difference of the ship and small asteroid
	addi $t6, $t6, -3
	bgtz $t6, collision_end

	addi $t6, $t6, 7
	bltz $t6, collision_end
	jal lg_collision
	j collision_end
	
collision_end:
	add $ra, $s3, $zero
	jr $ra

	
	
sm_collision:
	# save $ra in $s2
	add $s2, $ra, $zero
	# update ship life counter
	li $t2, BASE_ADDRESS
	li $t3, 4
	mult $s0, $t3				# get location of life to clear
	mflo $t4 
	add $t2, $t2, $t4
	sw $zero, 4($t2)
	sw $zero, 0($t2)
	
	# reduce life counter by 1
	addi $s0, $s0, -1
	# if life counter reaches 0, end program
	blez $s0, END
	
	jal clear_sm
	
	# get new position for small asteroid
	li $t1, 128
	li $v0, 42				# get a random number between 0 and 28
	li $a0, 0
	li $a1, 28
	syscall
	
	addi $a0, $a0, 3			# get the starting address of a small asteroid
	mult $t1, $a0
	mflo $t2
	addi $t2, $t2, -8
	
	li $s6, BASE_ADDRESS			# $s6 stores the center of a small asteroid
	add $s6, $s6, $t2
	
	# restore $ra
	add $ra, $s2, $zero
	# jump to $ra
	jr $ra
	
	
md_collision:
	# save $ra in $s2
	add $s2, $ra, $zero
	# update ship life counter
	li $t2, BASE_ADDRESS
	li $t3, 4
	mult $s0, $t3				# get location of life to clear
	mflo $t4 
	add $t2, $t2, $t4
	sw $zero, 4($t2)
	sw $zero, 0($t2)
	
	# reduce life counter by 1
	addi $s0, $s0, -1
	# if life counter reaches 0, end program
	blez $s0, END
	
	jal clear_md
	
	# get new position for medium asteroid
	li $t1, 128
	li $v0, 42				# get a random number between 0 and 28
	li $a0, 0
	li $a1, 28
	syscall
	
	addi $a0, $a0, 3			# get the starting address of a medium asteroid
	mult $t1, $a0
	mflo $t2
	addi $t2, $t2, -8
	
	li $s5, BASE_ADDRESS			# $s5 stores the center of a medium asteroid
	add $s5, $s5, $t2
	
	# restore $ra
	add $ra, $s2, $zero
	# jump to $ra
	jr $ra
	
	
lg_collision:
	# save $ra in $s2
	add $s2, $ra, $zero
	# update ship life counter
	li $t2, BASE_ADDRESS
	li $t3, 4
	mult $s0, $t3				# get location of life to clear
	mflo $t4 
	add $t2, $t2, $t4
	sw $zero, 4($t2)
	sw $zero, 0($t2)
	
	# reduce life counter by 1
	addi $s0, $s0, -1
	# if life counter reaches 0, end program
	blez $s0, END
	
	jal clear_lg
	
	# get new position for large asteroid
	li $t1, 128
	li $v0, 42				# get a random number between 0 and 28
	li $a0, 0
	li $a1, 28
	syscall
	
	addi $a0, $a0, 3			# get the starting address of a large asteroid
	mult $t1, $a0
	mflo $t2
	addi $t2, $t2, -8
	
	li $s4, BASE_ADDRESS			# $s4 stores the center of a large asteroid
	add $s4, $s4, $t2
	
	# restore $ra
	add $ra, $s2, $zero
	# jump to $ra
	jr $ra
	
	
update_asteroid:
	# advance asteroids closer to the ship
	addi $s6, $s6, -4 
	addi $s5, $s5, -4
	addi $s4, $s4, -4
	
	# check if small asteroid is out of bounds
	li $t1, 128
	div $s6, $t1
	mfhi $t0
	bgtz $t0, next_ast_1
	
	# if small asteroid is out of bounds get new starting location for it
	li $v0, 42				# get a random number between 0 and 28
	li $a0, 0
	li $a1, 28
	syscall
	
	addi $a0, $a0, 3			# get the starting address of a small asteroid
	mult $t1, $a0
	mflo $t2
	addi $t2, $t2, -8
	
	li $s6, BASE_ADDRESS			# $s6 stores the center of a small asteroid
	add $s6, $s6, $t2
	
next_ast_1:
	# check if medium asteroid is out of bounds
	div $s5, $t1
	mfhi $t0
	addi $t0, $t0, -4			# subtract 1 from remainder since medium asteroid is odd framed
	bgtz $t0, next_ast_2
	# if medium asteroid is out of bounds get new starting location for it
	li $v0, 42				# get a random number between 0 and 28
	li $a0, 0
	li $a1, 28
	syscall
	
	addi $a0, $a0, 4			# get the starting address of a medium asteroid
	mult $t1, $a0
	mflo $t2
	addi $t2, $t2, -12
	
	li $s5, BASE_ADDRESS			# $s5 stores the center of a medium asteroid
	add $s5, $s5, $t2

next_ast_2:
	# check if large asteroid is out of bounds
	div $s4, $t1
	mfhi $t0
	bgtz $t0, update_ast_end
	# if medium large is out of bounds get new starting location for it
	li $v0, 42				# get a random number between 0 and 28
	li $a0, 0
	li $a1, 28
	syscall
	
	addi $a0, $a0, 5			# get the starting address of a large asteroid
	mult $t1, $a0
	mflo $t2
	addi $t2, $t2, -16
	
	li $s4, BASE_ADDRESS			# $s4 stores the center of a large asteroid
	add $s4, $s4, $t2
	
update_ast_end:
	jr $ra					# go back to caller
	
	
	
respond_to_w:
	addi $s7, $s7, -128			# move position of ship up
	# check new ship location bounds
	addi $t5, $s7, -384			# subtract by 2 rows
	li $t6, BASE_ADDRESS
	sub $t5, $t5, $t6
	bgtz, $t5 response_w
	addi $s7, $s7, 128			# revert ship movement
response_w:
	j cont
	
respond_to_a:
	addi $s7, $s7, -4			# move position of ship left
	li $t5, 128
	# check if the ship is still on the same row
	addi $t6, $s7, -16
	div $t6, $t5
	mflo $t7
	div $s7, $t5
	mflo $t8
	
	beq $t7, $t8, response_a
	addi $s7, $s7, 4			# revert ship movement
response_a:
	j cont
	
respond_to_s:
	addi $s7, $s7, 128			# move position of ship down
	# check new ship location bounds
	addi $t5, $s7, 256			# add by 2 rows
	li $t6, BASE_ADDRESS
	add $t6, $t6, 4096
	sub $t5, $t5, $t6
	bltz, $t5 response_s
	addi $s7, $s7, -128			# revert ship movement
response_s:
	j cont
		
respond_to_d:
	addi $s7, $s7, 4
	li $t5, 128
	# check if the ship is still on the same row
	addi $t6, $s7, -4
	div $t6, $t5
	mflo $t7
	div $s7, $t5
	mflo $t8
	
	beq $t7, $t8, response_d
	addi $s7, $s7, -4			# revert ship movement
response_d:
	j cont
	

END:
	sw $zero, -4($t2)
	li $v0, 10 				# terminate the program gracefully
	syscall
