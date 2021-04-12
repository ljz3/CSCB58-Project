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
# -Milestone 4 (choose the one the applies)
#
# Which approved features have been implemented for milestone 4?
# (See the assignment handout for the list of additional features)
# 1. b. Increase in difficulty as game progresses.
# 2. c. Scoring system: add a score to the game based on survival time
# 3. g. Smooth graphics: prevent flicker by carefully erasing and/or redrawing 
#	only the parts to the frame buffer that have changed

#
# Link to video demonstration for final submission:
# -(insert YouTube / MyMedia / other URL here). Make sure we can view it!
# https://www.youtube.com/watch?v=0LnVvQDiJtc
# Are you OK with us sharing the video with people outside course staff?
# - yes, and please share this project github link as well!
#	https://github.com/ljz3/CSCB58-Project
#	(link is private until approval)
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
.data
newline: .asciiz  "\n"
.text
main:	li $t0, BASE_ADDRESS			# $t0 stores the base address for display
	li $s7, SHIP_HEAD			# $s7 stores the head of the ship
	li $s0, 3				# $s0 stores the amount of lives the player has
	li $s1, 0				# reset score of player
	
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
	addi $s1, $s1, 1
	add $t8, $zero, $zero			# reset user input register
	# takes in user input
	li $t9, 0xffff0000 
	lw $t8, 0($t9)
	beq $t8, 1, keypress_happened

	# update display
cont:	
	jal draw_ship
	jal draw_asteroids

	li $v0, 32 				# sleep for 50ms base, lower for harder difficulty
	li $t5, 50				# get how much to reduce delay by
	div $s1, $t5
	mflo $t5
	li $a0, 50				# base difficulty is at 50ms delay
	sub $a0, $a0, $t5
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
	beq $t8, 0x70, respond_to_p		# ASCII code of 'p'
	j cont
	
clear_display:
	add $s3, $ra, $zero
	
	jal clear_ship
	jal clear_sm
	jal clear_md
	jal clear_lg
	add $ra, $s3, $zero
	jr $ra
	
clear_screen:
	li $t0, BASE_ADDRESS
	li $t1, 1024
clear_loop:
	sw $zero, 0($t0)
	addi $t0, $t0, 4
	addi $t1, $t1, -1
	bgtz $t1, clear_loop
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
	sw $zero, 0($t2)
	sw $zero, 4($t2)
	
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
	
	
respond_to_p:
	jal clear_screen
	j main


END:
	jal clear_display
	li $t0, BASE_ADDRESS
	sw $zero, 0($t0)
	
	li $t1, 0xff0000			# store the red color code in $t1
	
	sw $t1, 272($t0)			# paint the letter G
	sw $t1, 400($t0)
	sw $t1, 528($t0)
	sw $t1, 656($t0)
	sw $t1, 784($t0)
	sw $t1, 912($t0)
	sw $t1, 1040($t0)
	sw $t1, 1168($t0)
	
	sw $t1, 1172($t0)
	sw $t1, 1176($t0)
	sw $t1, 1180($t0)
	sw $t1, 1184($t0)
	
	sw $t1, 1056($t0)
	sw $t1, 928($t0)
	sw $t1, 800($t0)
	sw $t1, 672($t0)
	
	sw $t1, 668($t0)
	sw $t1, 664($t0)
	
	sw $t1, 276($t0)
	sw $t1, 280($t0)
	sw $t1, 284($t0)
	sw $t1, 288($t0)
	
	sw $t1, 300($t0)			# paint the letter A
	sw $t1, 304($t0)
	sw $t1, 308($t0)
	
	sw $t1, 812($t0)
	sw $t1, 816($t0)
	sw $t1, 820($t0)
	
	sw $t1, 424($t0)
	sw $t1, 552($t0)
	sw $t1, 680($t0)
	sw $t1, 808($t0)
	sw $t1, 936($t0)
	sw $t1, 1064($t0)
	sw $t1, 1192($t0)
	
	sw $t1, 440($t0)
	sw $t1, 568($t0)
	sw $t1, 696($t0)
	sw $t1, 824($t0)
	sw $t1, 952($t0)
	sw $t1, 1080($t0)
	sw $t1, 1208($t0)
	
	
	
	sw $t1, 320($t0)			# paint the letter M
	sw $t1, 448($t0)
	sw $t1, 576($t0)
	sw $t1, 704($t0)
	sw $t1, 832($t0)
	sw $t1, 960($t0)
	sw $t1, 1088($t0)
	sw $t1, 1216($t0)
	
	sw $t1, 336($t0)
	sw $t1, 464($t0)
	sw $t1, 592($t0)
	sw $t1, 720($t0)
	sw $t1, 848($t0)
	sw $t1, 976($t0)
	sw $t1, 1104($t0)
	sw $t1, 1232($t0)
	
	sw $t1, 452($t0)
	sw $t1, 460($t0)
	
	sw $t1, 584($t0)
	sw $t1, 712($t0)
	
	
	sw $t1, 344($t0)			# paint the letter E
	sw $t1, 472($t0)
	sw $t1, 600($t0)
	sw $t1, 728($t0)
	sw $t1, 856($t0)
	sw $t1, 984($t0)
	sw $t1, 1112($t0)
	sw $t1, 1240($t0)
	
	sw $t1, 348($t0)
	sw $t1, 352($t0)
	sw $t1, 356($t0)
	sw $t1, 360($t0)
	
	sw $t1, 732($t0)
	sw $t1, 736($t0)
	sw $t1, 740($t0)
	
	sw $t1, 1244($t0)
	sw $t1, 1248($t0)
	sw $t1, 1252($t0)
	sw $t1, 1256($t0)
	
	
	sw $t1, 1928($t0)			# paint the letter O
	sw $t1, 2056($t0)
	sw $t1, 2184($t0)
	sw $t1, 2312($t0)
	sw $t1, 2440($t0)
	sw $t1, 2568($t0)
	sw $t1, 2696($t0)
	sw $t1, 2824($t0)
	sw $t1, 2952($t0)
	
	sw $t1, 1932($t0)
	sw $t1, 1936($t0)
	sw $t1, 1940($t0)
	sw $t1, 1944($t0)
	
	sw $t1, 1948($t0)
	sw $t1, 2076($t0)
	sw $t1, 2204($t0)
	sw $t1, 2332($t0)
	sw $t1, 2460($t0)
	sw $t1, 2588($t0)
	sw $t1, 2716($t0)
	sw $t1, 2844($t0)
	sw $t1, 2972($t0)
	
	sw $t1, 2956($t0)
	sw $t1, 2960($t0)
	sw $t1, 2964($t0)
	sw $t1, 2968($t0)
	
	
	
	sw $t1, 1956($t0)			# paint the letter V
	sw $t1, 2084($t0)
	sw $t1, 2212($t0)
	sw $t1, 2340($t0)
	sw $t1, 2468($t0)
	
	sw $t1, 1976($t0)
	sw $t1, 2104($t0)
	sw $t1, 2232($t0)
	sw $t1, 2360($t0)
	sw $t1, 2488($t0)
	
	sw $t1, 2600($t0)
	sw $t1, 2728($t0)
	
	sw $t1, 2612($t0)
	sw $t1, 2740($t0)
	
	sw $t1, 2860($t0)
	sw $t1, 2864($t0)
	sw $t1, 2988($t0)
	sw $t1, 2992($t0)
	
	

	sw $t1, 1984($t0)			# paint the letter E
	sw $t1, 2112($t0)
	sw $t1, 2240($t0)
	sw $t1, 2368($t0)
	sw $t1, 2496($t0)
	sw $t1, 2624($t0)
	sw $t1, 2752($t0)
	sw $t1, 2880($t0)
	sw $t1, 3008($t0)
	
	sw $t1, 1988($t0)
	sw $t1, 1992($t0)
	sw $t1, 1996($t0)
	sw $t1, 2000($t0)
	sw $t1, 2004($t0)
	
	sw $t1, 2500($t0)
	sw $t1, 2504($t0)
	sw $t1, 2508($t0)
	
	sw $t1, 3012($t0)
	sw $t1, 3016($t0)
	sw $t1, 3020($t0)
	sw $t1, 3024($t0)
	sw $t1, 3028($t0)
	
	
	sw $t1, 2012($t0)			# paint the letter R
	sw $t1, 2140($t0)
	sw $t1, 2268($t0)
	sw $t1, 2396($t0)
	sw $t1, 2524($t0)
	sw $t1, 2652($t0)
	sw $t1, 2780($t0)
	sw $t1, 2908($t0)
	sw $t1, 3036($t0)
	
	sw $t1, 2016($t0)
	sw $t1, 2020($t0)
	sw $t1, 2024($t0)
	sw $t1, 2028($t0)

	sw $t1, 2528($t0)
	sw $t1, 2532($t0)
	sw $t1, 2536($t0)
	sw $t1, 2540($t0)
	
	sw $t1, 2160($t0)
	sw $t1, 2288($t0)
	sw $t1, 2416($t0)
	
	sw $t1, 2672($t0)
	sw $t1, 2800($t0)
	sw $t1, 2928($t0)
	sw $t1, 3056($t0)
	
	li $v0, 1
	move $a0, $s1     			# print out user's final score
	syscall
	
	li $v0, 4     				# print out a line break
	la $a0, newline
	syscall
	
end_loop:
	add $t8, $zero, $zero			# reset user input register
	# takes in user input
	li $t9, 0xffff0000 
	lw $t8, 0($t9)
	beq $t8, 0, no_reset
	lw $t8, 4($t9) 
	beq $t8, 0x70, respond_to_p		# ASCII code of 'p'
no_reset:
	li $v0, 32 				# sleep for 100ms
	li $a0, 100
	syscall
	j end_loop
