.data
	lectures: .asciiz "lecture hours:" 
	meetings: .asciiz "meeting hours:" 
	office: .asciiz "office hours:" 
	lectures_avg: .asciiz "lectures per day:" 
	ratio: .asciiz "ratio of lecture hours and office hours:" 
	overlap_print: .asciiz "	Theres overlap try another period"
	add_appoitment: .asciiz " 	Appointment Add"
	day_number_to_add: .asciiz "Enter day number you want to edit: " 
	appointment_to_add: .asciiz "lectures per day:" 
	start_time:.asciiz "Enter start time:" 
	end_time:.asciiz "Enter end time:" 
	add_type:.asciiz "Enter appointment type:"
	menu: .asciiz "1) View The Calender\n2) View Statistics\n3) Add a new sappointment\n4) Delete an appointment\n"
	Welcome_Message: .asciiz "Welcome to our calender program, Please choose from the following menu:\n"
	choice: .asciiz "Your choice is: "
	wrong_choice: .asciiz "Your choice is wrong!\nyou have to choose just from the menu.\n"
	filename: .asciiz "test.txt"
	buffer: .space 1024 # Buffer to store each line
	saving_array: .space 1024 # Buffer to store each line
	after_delete_buffer: .space 1024 #Buffer to store the calender after deletion
	menu_of_choice_one: .asciiz "1) View the calender per day\n2) View the calender per set of days\n3) View the calender for a given slot in a given day\n"
	view_calender_per_day: .asciiz "Enter the day you want to view it's calender: "
	wrong_day: .asciiz "you have to choose between 1 and 31\n"
	newline: .asciiz "\n"
	calOfDay: .asciiz "The calender of day "
	numOfDays: .asciiz "Enter the number of days you want: "
	start_slot: .asciiz "Enter the beginning of the slot: "
	end_slot: .asciiz "Enter the end of the slot: "
	wrong_hours: .asciiz "Wrong input!\nThe working hours are from 8 AM until 5 PM\n"
	delete: .asciiz "Enter the day you want to delete it's appointment: "
	wrong_interval: .asciiz "Wrong Entry, you must enter an existing interval\n"
	from: .asciiz " from "
	to: .asciiz " to "
	semi_with_space: .asciiz ": "
	type_array: .byte 'M', 'L', 'O','.'
	Delete_succ: .asciiz "The slot has been deleted successfully\n"
	
.text 
	main:
	jal read_file_func
	# printing the welcome message with the menu
	li $v0, 4
	la $a0, Welcome_Message
	syscall 
start:	
	li $v0, 4
	la $a0, menu
	syscall
	li $t1, 4 #the maximum number in the menu
	jal read_choice
	
	#loading the menu numbers to know what is the choice
	li $t1, 1
	li $t2, 2
	li $t3, 3
	li $t4, 4
	beq $v1, $t1 , choice_one
	beq $v1, $t2 , choice_two
	beq $v1, $t3 , choice_three
	beq $v1, $t4 , choice_four
	
choice_one:
	li $v0, 4
	la $a0, menu_of_choice_one
	syscall
	li $t1 , 3
	jal read_choice
	# to compare the choice with the menu numbers
	li $t1, 1
	li $t2, 2
	li $t3, 3
	#to branch to the correct branch of choice one
	beq $v1 , $t1 , choice_one_one
	beq $v1 , $t2 , choice_one_two
	beq $v1 , $t3 , choice_one_three
	choice_one_one:
		jal view_cal_per_day_func
		j start
		
	choice_one_two:
		li $v0, 4
		la $a0, numOfDays
		li $t7, 2 #flag
		li $t1, 31 #max choice
		syscall
		jal read_choice
		move $t5, $v1 #num of iterations
	L3:	jal view_cal_per_day_func
		addiu $t5, $t5, -1 #subtract one from the num of iterations
		bnez $t5, L3 #if we have not reached zero then continue the loop 
		j start
		
		
	choice_one_three:
		li $t7 , 1 #this is flag to decide which wrong message to print
		jal cal_slots_func
		# to bring it back to the 12 hours format
   		ble $a2, 12, twelve_format1
   		addiu $a2, $a2, -12
   twelve_format1:
   		ble $a3, 12, twelve_format2		
   		addiu $a3, $a3, -12
   twelve_format2:
   		#this is for printing
   		li $v0, 4
   		la $a0, calOfDay
   		syscall
   		li $v0, 1
   		move $a0, $t9
   		syscall
   		li $v0, 4
   		la $a0, from
   		syscall
   		li $v0, 1
   		move $a0, $a2
   		syscall
   		li $v0, 4
   		la $a0, to
   		syscall
   		li $v0, 1
   		move $a0, $a3
   		syscall
   		li $v0, 4
   		la $a0, semi_with_space
   		syscall
   		li $v0, 1
   		move $a0, $a2
   		syscall
   		li $v0, 11
   print:	lb $a0, 0($t3)   #load the beginning of the interval to print it
   		syscall
   		addiu $t3, $t3, 1
   		beq $t3, $t4, finish  #keep printing until we reach the address of the end of the interval
   		j print
   finish:	lb $a0, 0($t3)  
   		addiu $t3, $t3, 1
   		syscall
   		beq $a0, 10, start #if there is new line stop
   		bne $a0, 44, finish  
   		
   		li $v0, 4
   		la $a0, newline
   		syscall
   		j start
   		
   wrong:	li $v0, 4
   		la $a0, wrong_interval
   		syscall
   		j start
		

choice_two:
	jal read_file_func
	la $t0, buffer    # Load the address of the buffer
      	li $s0, 0  # Initialize lecture hours register
      	li $s1, 0  # Initialize meetings hours register
      	li $s2, 0  # Initialize office hours register
      	li $s3, 0  # Initialize number of lines register
         loop_char:
        lb $t1, 0($t0)  # Load current character
        beq $t1,$zero,end_loop  # Exit loop if end of string
	beq $t1,':',add_line_num  # Exit loop if end of string
	continue9:
        # Check if it's a lecture time (L)
       j check_if_char_LMO
	continue5:
        # Code to skip to the next line or character
        j next_iteration

process_calculate_hours:
       
        # Calculate the time interval and add it to total lecture hours
      sub $t1,$t0,2 #to acces first digit see in the print the first one after the space 
      lb $t2, 0($t1)  # Load current character which is the first digite
      sub $t2, $t2, '0' # Convert ASCII digits to integers
      j loop_digits_read_before_hyphen #to make the first number from two digits if its not one digit 
continue:	
        sub $t1, $t1, 1  #accessing first digit after the hyphen  second number
        lb $t4, 0($t1)  # Load current character
        sub $t4, $t4, '0' # Convert ASCII digits to integers
       j loop_digits_read_after_hyphen
continue2:
        # Calculate time interval (end - start)
	blt $t2, 5, add_12_hours_first

continue3:
        blt $t4,5,add_12_hours_second
continue4:
	sub $t2,$t2,$t4   #the sub of the two intervals
	lb $t6,0($t0)
	beq $t6,'M',store_meeting_hours
	continue6:
        beq $t6,'L',store_lecture_hours
        continue7:
        beq $t6,'O',store_office_hours
        continue8:
    next_iteration:
        # Increment pointer to the next character or line
        addi $t0, $t0, 1
        j loop_char
        
loop_digits_read_before_hyphen:
     	sub $t1, $t1, 1
	lb $t3, 0($t1)
	beq $t3,'-',continue  #hyphen 
	sub $t3, $t3, '0' # Convert ASCII digits to integers
	mul $t3, $t3, 10
   	add $t2, $t2, $t3  # Add the value of the second digit
	j loop_digits_read_before_hyphen
loop_digits_read_after_hyphen:
     	sub $t1, $t1, 1
	lb $t3, 0($t1)
	beq $t3,' ',continue2  #hyphen 
	sub $t3, $t3, '0' # Convert ASCII digits to integers
	mul $t3, $t3, 10
   	add $t4, $t4, $t3  # Add the value of the second digit
	j loop_digits_read_after_hyphen
add_12_hours_first:
	addi $t2,$t2,12
	j continue3
add_12_hours_second: 
	addi $t4,$t4,12
	j continue4
check_if_char_LMO:
	la $a1,type_array
loop_LMO:
	lb $a0,0($a1)
	beq $t1,$a0,process_calculate_hours
	beq $a0,0,continue5
	addi $a1,$a1,1
	j loop_LMO

	
store_meeting_hours:
	add $s1,$s1,$t2
	j continue6
store_lecture_hours:
	add $s0,$s0,$t2
	j continue7
store_office_hours:
	add $s2,$s2,$t2
	j continue8
add_line_num:
	addi $s3,$s3,1
	j continue9
end_loop:
	la $a0, newline
        li $v0, 4
        syscall
        la $a0, lectures
        li $v0, 4
        syscall
	li $v0, 1             # System call code for print_int
        move $a0, $s0 # Set $a0 to the value in $t0
        syscall               # Make the system call
        la $a0, newline
        li $v0, 4
	syscall
    
    
  	la $a0, meetings
        li $v0, 4
        syscall
	li $v0, 1             # System call code for print_int
        move $a0, $s1  # Set $a0 to the value in $s1
        syscall               # Make the system call
        la $a0, newline
 	li $v0, 4
 	syscall
    
    
  	la $a0, office
 	li $v0, 4
 	syscall
	li $v0, 1             # System call code for print_int
        move $a0, $s2  # Set $a0 to the value in $s2
        syscall               # Make the system call
        la $a0, newline
	li $v0, 4
 	syscall
    
    
       la $a0, lectures_avg
       li $v0, 4
       syscall
    
 	mtc1 $s0, $f0   # Move integer to floating-point register $f0
       mtc1 $s3, $f1   # Move integer to floating-point register $f1

       div.s $f2, $f0, $f1  # Perform floating-point division
      # Print the result with two decimal places
       li $v0, 2         # System call code for print float
       mov.s $f12, $f2   # Move the result to $f12
       syscall
             # Make the system call
            la $a0, newline
    li $v0, 4
    syscall
    la $a0, ratio
    li $v0, 4
    syscall
    mtc1 $s0, $f0   # Move integer to floating-point register $f0
    mtc1 $s2, $f1   # Move integer to floating-point register $f1

    div.s $f2, $f0, $f1  # Perform floating-point division
     # Print the result with two decimal places
    li $v0, 2         # System call code for print float
    mov.s $f12, $f2   # Move the result to $f12
    syscall
    
              la $a0, newline
    li $v0, 4
    syscall
    j start
    
choice_three:
	jal read_file_func
	li $v0, 4               # syscall code for print_str
        la $a0,newline    # load address of the number to add string
        syscall
        
	li $v0, 4               # syscall code for print_str
        la $a0,day_number_to_add         # load address of the number to add string
        syscall
	 # Read integer from user
        li $v0, 5               # syscall code for read_int
        syscall
        move $t7, $v0           # store the read integer in $t0
        
        li $v0, 4               # syscall code for print_str
        la $a0,start_time       # load address of the start time
        syscall
        
	 # Read integer from user
        li $v0, 5               # syscall code for read_int
        syscall
        move $t8, $v0           # store the read integer in $t0
        blt $t8, 6, add_12_hours_start
        con8:
        li $v0, 4               # syscall code for print_str
        la $a0,end_time       # load address of the end time
        syscall
	 # Read integer from user
        li $v0, 5               # syscall code for read_int
        syscall
        move $t9, $v0           # store the read integer in $t0
        blt $t9, 6, add_12_hours_end
        con9:
        li $v0, 4               # syscall code for print_str
        la $a0,add_type       # load address of the end time
        syscall
        li $v0, 12       # System call code for reading a character without echo
    	syscall
   	move $s7, $v0     # Move the read character to register $a0
	la $t0,buffer
	lb $t1, 0($t0)  # check if its 1 
	sub $t1, $t1, '0' # Convert ASCII digits to integers
	beq $t1,$t7,found_num_to_add
	add $t0,$t0,1 #avoid check :
	loop_bytes:
		add $t0,$t0,1
	       lb $t1, 0($t0)  # Load current character
	       beq $t1,':',check_number
	j loop_bytes
check_number:
	        lb $t1, -1($t0)  # Load first digit of number
	        sub $t1, $t1, '0' # Convert ASCII digits to integers
		lb $t2, -2($t0) #check if the number have two digits
		bne $t2, '\n',combine_digits 
		con:
		beq $t1,$t7,found_num_to_add

		j loop_bytes
combine_digits:
	sub $t2, $t2, '0' # Convert ASCII digits to integers
	mul $t2,$t2,10
	add $t1,$t1,$t2
	j con
found_num_to_add:
	move $t3,$t0  # the address of the line start

loop_line:
	lb $t4, 0($t3)  # Load first digit of number	
	beq $t4,10,no_overlap
	j check_if_char_LMO2
	con2:
	add $t3,$t3,1 
	j loop_line
check_if_char_LMO2:
	la $a1,type_array
loop_LMO2:
	lb $a0,0($a1)
	beq $t4,$a0,check_overlap
	beq $a0,'.', con2
	add $a1,$a1,1
	j loop_LMO2
check_overlap:
	move $t4,$t3
	sub $t4,$t4,2
	lb $t2,0($t4)
	sub $t2, $t2, '0' # Convert ASCII digits to integers
	j loop_digits_read_before_hyphen2
	con3:
	blt $t2, 5, add_12_hours_first2
	con6:
	sub $t4,$t4,1
	li $t5,0
	lb $t5,0($t4)
	sub $t5, $t5, '0' # Convert ASCII digits to integers
	j loop_digits_read_after_hyphen2
	con4:
	blt $t5, 5, add_12_hours_second2
	con7:
	move $t7,$t8
	beq $t5,$t9,store_address
loop_interval_start_end:
	move $t6,$t5
	j loop_current_interval
	con5:
	beq $t7,$t9,con2
	add $t7,$t7,1
	j loop_interval_start_end
	
loop_digits_read_before_hyphen2:
	sub $t4, $t4, 1
	lb $t5, 0($t4)
	beq $t5,'-',con3  #hyphen 
    	addiu $t5 , $t5 , -48 #to convert into integer
	mul $t5, $t5, 10
   	add $t2, $t5, $t2  # Add the value of the second digit
	j loop_digits_read_before_hyphen2
loop_digits_read_after_hyphen2:
	sub $t4, $t4, 1
	lb $t6, 0($t4)
	beq $t6,' ',con4  #hyphen 
    	addiu $t6 , $t6 , -48 #to convert into integer
	mul $t6, $t6, 10
   	add $t5, $t6, $t5  # Add the value of the second digit
	j loop_digits_read_after_hyphen2
loop_current_interval:
	beq $t2,$t6,con5
	beq $t6,$t7 ,there_is_overlap
	add $t6,$t6,1
	j loop_current_interval	

add_12_hours_first2:
 	addi $t2,$t2,12
 	j con6
 
 add_12_hours_second2:
 	addi $t5,$t5,12
 	j con7
 
add_12_hours_start:
	addi $t8,$t8,12
	j con8
add_12_hours_end:
	addi $t9,$t9,12
	j con9
store_address:
	move $s2,$t4
	j con2
there_is_overlap:
	li $v0, 4               # syscall code for print_str
    	la $a0,newline  # load address of the start time
    	syscall
	li $v0, 4               # syscall code for print_str
        la $a0,overlap_print    # load address of the start time
        syscall
        li $v0, 11       # Syscall number for printing character
	li $a0, 10       # ASCII code for newline character
	syscall
        j choice_three
no_overlap:
        bgt $t8, 12, greater_than_12_start
        cont5:
        bgt $t9, 12, greater_than_12_end
        cont6:
        sub $t3,$t3,2
        move $s6,$t3
        la $t0,buffer
      	la $t2,saving_array
        beq $s2,0,add_at_last
loop_moving_data:
	lb $t1, 0($t0)  # Load current character
	sb $t1, 0($t2)  # Load current character	
	beq $s2,$t0,stop_adding
	beq $t1,0,ended
	add $t0,$t0,1 
    	add $t2,$t2,1 	
    	j loop_moving_data																																																																										    																																																																													
greater_than_12_start:
	sub $t8,$t8,12
	j cont5
greater_than_12_end:
	sub $t9,$t9,12
	j cont6
stop_adding:
   	 li $t5, 10
   	divu $t8,$t5        # Divide $t8 by 10, result in $t8, remainder in HI register
   	 mflo $t3              # Move quotient (tens digit) to $t3
 
    	# Extract the ones digit
    	mfhi $t4              # Move remainder (ones digit) to $t4
   	bnez $t3, two_digits_label  # If tens digit is not zero, it has two digits
    	cont1:
   	add $t4, $t4, '0' # Convert ASCII digits to integers
   	add $t2,$t2,1 
	sb $t4, 0($t2)  # Load current character
	add $t2,$t2,1 
	li $t6, 45  # Load the ASCII code for the hyphen into $t0
	sb $t6, 0($t2)  # Load current character
	li $t5, 10
  	divu $t9,$t5       # Divide $t8 by 10, result in $t8, remainder in HI register
  	mflo $t3          # Move quotient (tens digit) to $t3
   	mfhi $t4    
       	bnez $t3, two_digits_label2 # If tens digit is not zero, it has two digits
       	cont2:
       	add $t2,$t2,1
       	add $t4, $t4, '0' # Convert ASCII digits to integers
	sb $t4, 0($t2)  # Load current character
	add $t2,$t2,1 
       	li $t6, 32  # Load the ASCII code for space into $t0
	sb $t6, 0($t2)  # Load current character
	add $t2,$t2,1 
	sb $s7, 0($t2)  # Load current characterc
	add $t2,$t2,1 
	li $t6, 44  # Load the ASCII code for comma into $t0
	sb $t6, 0($t2)  # Load current character
	add $t2,$t2,1 
       	li $t6, 32  # Load the ASCII code for space into $t0
	sb $t6, 0($t2)  # Load current character
	add $t0,$t0,1
	add $t2,$t2,1 
	j loop_moving_data
two_digits_label:
	add $t2,$t2,1 
	add $t3, $t3, '0' # Convert ASCII digits to integers
	sb $t3, 0($t2)  # Load current character
	j cont1
two_digits_label2:
	add $t2,$t2,1 
	add $t3, $t3, '0' # Convert ASCII digits to integers
	sb $t3, 0($t2)  # Load current character
	j cont2 
	
add_at_last:
	loop_moving_data2:
	lb $t1, 0($t0)  # Load current character
	sb $t1, 0($t2)  # Load current character	
	beq $s6,$t0,adding_last_appoitmnet 
	beq $t1,0,ended
	add $t0,$t0,1 
    	add $t2,$t2,1 	
    	j loop_moving_data2
   																																																																										    																																																																													
adding_last_appoitmnet:
	lb $t7,0($t3)
	beq $t7,':',cont7
	add $t2,$t2,1 
	li $t6, 44  # Load the ASCII code for comma into $t0
	sb $t6, 0($t2)  # Load current character
	cont7:
	add $t2,$t2,1 
       	li $t6, 32  # Load the ASCII code for space into $t0
	sb $t6, 0($t2)  # Load current character
	li $t5, 10
   	divu $t8,$t5        # Divide $t8 by 10, result in $t8, remainder in HI register
   	mflo $t3              # Move quotient (tens digit) to $t3
    # Extract the ones digit
   	mfhi $t4              # Move remainder (ones digit) to $t4
   	bnez $t3, two_digits_label_last1 # If tens digit is not zero, it has two digits
    cont3:
   	add $t4, $t4, '0' # Convert ASCII digits to integers
   	add $t2,$t2,1 
	sb $t4, 0($t2)  # Load current character
	add $t2,$t2,1 
	li $t6, 45  # Load the ASCII code for the hyphen into $t0
	sb $t6, 0($t2)  # Load current character
	li $t5, 10
  	divu $t9,$t5       # Divide $t8 by 10, result in $t8, remainder in HI register
  	mflo $t3          # Move quotient (tens digit) to $t3
   	mfhi $t4    
       	bnez $t3,two_digits_label2_last2 #If tens digit is not zero, it has two digits
       	cont4:
       	add $t2,$t2,1
       	add $t4, $t4, '0' # Convert ASCII digits to integers
	sb $t4, 0($t2)  # Load current character
	add $t2,$t2,1 
       	li $t6, 32  # Load the ASCII code for space into $t0
	sb $t6, 0($t2)  # Load current character
	add $t2,$t2,1 
	sb $s7, 0($t2)  # Load current characterc
	add $t2,$t2,1
	add $t0,$t0,1
	 j loop_moving_data2
 two_digits_label_last1:
	add $t2,$t2,1 
	add $t3, $t3, '0' # Convert ASCII digits to integers
	sb $t3, 0($t2)  # Load current character
	j cont3
two_digits_label2_last2:
	add $t2,$t2,1 
	add $t3, $t3, '0' # Convert ASCII digits to integers
	sb $t3, 0($t2)  # Load current character
	j cont4 
	
ended:
	  # Open the file for writing
    li $v0, 13             # System call code for open
    la $a0, filename       # Load the address of the filename
    li $a1, 1              # Flags: 1 for write
    li $a2, 0              # Mode: not relevant for write
    syscall
    move $s0, $v0          # Save the file descriptor in $s0

    # Write new content to the file
    li $v0, 15             # System call code for write
    move $a0, $s0          # File descriptor
    la $a1, saving_array   # Load the address of the new content
    li $a2,  300        # Number of bytes to write
    syscall
  

    # Close the file
    li $v0, 16             # System call code for close
    move $a0, $s0          # File descriptor
    syscall
    li $v0, 4               # syscall code for print_str
    la $a0,newline  # load address of the start time
    syscall
    li $v0, 4               # syscall code for print_str
    la $a0,add_appoitment  # load address of the start time
    syscall
    li $v0, 4               # syscall code for print_str
    la $a0,newline  # load address of the start time
    syscall
    li $t1,0
    li $t2,0
    li $t3,0
    li $t4,0
    li $t5,0
    li $t6,0
    li $t7,0
    li $t8,0
    li $t9,0
    jal read_file_func
    j start
choice_four:
	li $v0, 4
	la $a0, delete
	syscall
	li $t7 , 2 #this is flag to decide which wrong message to print	
	jal cal_slots_func
	#checkers from 1 to 3 are made to get the exact address of the interval
	bne $a2, 10, check1
	addiu $t3, $t3, -2
check1:	bne $a2, 11, check2
	addiu $t3, $t3, -2
check2:	bne $a2, 12, decr_t3
	addiu $t3, $t3, -2
	j check3
decr_t3:
	addiu $t3, $t3, -1
check3:	lb $t8, 1($t4)
	bne $t8, 'O', incr_t4
	addiu $t4, $t4, 2
incr_t4:
	addiu $t4, $t4, 2
	j w


	
w:	la $s0, buffer  #address of the original buffer
	la $s1, after_delete_buffer  #address of the new buffer

loop4:
	lb $t0, 0($s0)
	beq $t0, $zero, end_loop4  #if we reached the end of the buffer
	bne $s0, $t3, store   #keep storing in new buffer if it's not the address of the beginning of the interval
increament:  #otherwise skip all the addresses between the addresses of the beginning and the end of the interval
	addiu $s0, $s0, 1
	lb $t0, 0($s0)
	beq $t0, 10, store
	bgt $s0, $t4, store
	j increament
store:	
	sb $t0, 0($s1)  #store byte in the new buffer
	addiu $s1, $s1, 1
	addiu $s0, $s0, 1
	j loop4
	
end_loop4:
	li $v0, 4
	la $a0, Delete_succ  #to show the user the edited calendar after the deletion
	syscall
	jal write_on_file_func  #overwrite the edited calendar in the original file
	jal read_file_func      #read the file again and store the new calendar in the original buffer
	jal clear_buffer	#clear the new buffer for future use
	j start			#go back to the start menu
	
	# to exit the program
	li $v0, 10
	syscall

clear_buffer:
    	li   $t0, 0   # counter
    	la   $t1, after_delete_buffer      # load address of the buffer

clear_loop:
    	beq  $t0, 1024, buffer_cleared  # exit loop if counter reaches 64
    	sb   $zero, 0($t1)   # store null character at the address in $t1
    	addi $t1, $t1, 1      # move to the next byte in the buffer
    	addi $t0, $t0, 1      # increment counter
    	j    clear_loop       # jump back to the beginning of the loop

buffer_cleared:
	jr $ra


read_file_func:
 	# Open the file
        li $v0, 13       # System call code for open file
        la $a0, filename # Load address of the filename
        li $a1, 0        # Open for reading
        li $a2, 0        # Mode not used, set to 0
        syscall
        move $s0, $v0    # Save the file descriptor in $s0

        # Check if the file was opened successfully
        bgez $s0, read_file  # If $s0 >= 0, file opened successfully
        li $v0, 10         # System call code for exit
        syscall

    read_file:
        # Read from the file
        li $v0, 14       # System call code for read file
        move $a0, $s0    # File descriptor
        la $a1, buffer   # Buffer to store read content
        li $a2, 1024      # Maximum number of bytes to read
        syscall
	
        # Close the file
        li $v0, 16       # System call code for close file
        move $a0, $s0    # File descriptor
        syscall
        
        jr $ra
        
        
write_on_file_func:
	# Open the file for writing
    	li $v0, 13           # System call code for open
    	la $a0, filename     # Load the address of the file name
    	li $a1, 1            # Open for writing (O_WRONLY)
    	li $a2, 0            # File mode (ignored for write-only)
    	syscall
    	move $s0, $v0        # Save the file descriptor in $s0

    	# Write to the file
    	li $v0, 15           # System call code for write
    	move $a0, $s0        # File descriptor
    	la $a1, after_delete_buffer       # Load the address of the data to write
    	li $a2, 1024           # Number of bytes to write (adjust accordingly)
    	syscall

    	# Close the file
    	li $v0, 16           # System call code for close
    	move $a0, $s0        # File descriptor
    	syscall
    	 
    	jr $ra       


read_choice:
	c1:	la $a0, choice
		beq $t7 , 0 , m0 #to print rhe choice menu string
		la $a0, view_calender_per_day
		beq $t7, 1 , m0
		beq $t7, 2 , m1
	m0:	syscall
	m1:	
		li $v0, 5 # to read the user choice
		syscall
		move $v1, $v0 
		li $v0, 12 #to get rid of the new line character
		syscall
		
		bgt $v1, $zero , check_if_greater_than_max #if the choice is greater than zero then we'll chceck if it is greater than max
		li $v0, 4  #else it will print an error message
		la $a0, wrong_choice
		beq $t7 , 0 , m2
		la $a0 , wrong_day
	m2:	syscall
 		b c1 #to read the choice of the menu again
	check_if_greater_than_max:	
 		ble $v1 , $t1 , done1 #if the choice is less than or equal to max then there is nothing to do
 		li $v0, 4  #else it will print an error message
		la $a0, wrong_choice
		beq $t7 , 0 , m3
		la $a0 , wrong_day
	m3:	syscall 
		b c1 #to read the choice menu again
	done1:
		jr $ra

view_cal_per_day_func:
	move $t4, $ra
	li $v0, 4 #to print a string
	li $t1 , 31 #maximum number of day per month
	li $t7 , 1 #this is flag to decide which wrong message to print	
	jal day_search_func
    	li $v0, 4
    	la $a0, calOfDay
    	syscall
    	li $v0, 1
    	move $a0, $v1
    	syscall
    	li $v0, 11
    	loop:	lb $a0, 0($t0)
    		beq $a0, 10, EOD
    		syscall
    		li $a0, 0
    		addiu $t0, $t0, 1
    		j loop
	EOD:
		li $v0, 4
		la $a0, newline
		syscall
		move $ra, $t4
		jr $ra

day_search_func:

		move $t3, $ra #to store the address of the main menu
		jal read_choice
		li $t7 , 0 #flag
		li $t8 , 0 #sum
		li $t6 , 10 #to multiply the sum with 10 in each time
		
		la $t0, buffer     # pointer to the buffer
    	L1:	lb $t1, 0($t0)     # load the byte at the beginning of the buffer
    		beq $t1, $zero , EOD #to chcek if it's the end of the buffer
    		beq $t1 , 10 , new_line  #to check if we finished a line
    		bgt $t1, '9', done3 #if the character is not numeric
    		blt $t1, '0', done3 #if the character is not numeric
    		addiu $t1 , $t1 , -48 #to convert into integer
    		#to concatenate the digits
    		mul $t8, $t8, $t6 
    		addu $t8, $t8, $t1 
    		addiu $t0, $t0, 1 #go to the next character
    		j L1
    	done3:	
    		beq $t8, $v1, found #if the user's day number and the data day number are equal then we found the day we want
    		li $t8, 0 #made it zero to be able to store a new number in it
    	loop2:	addiu $t0, $t0, 1 #go to next character
    		lb $t1, 0($t0)
    		bne $t1, 10, loop2 #to go to the next line if we don't want this day
    		j L1 
    	new_line: 
    		addiu $t0, $t0, 1
    		j L1
    	found:
    		move $ra, $t3
    		jr $ra

#to make sure that the user will input hours between 8 AM and 5 PM
hours_checker:
	li $t1, 1
    	li $t2, 12
    	beq $t0, $t1, valid_input
    	beq $t0, 2, valid_input
    	beq $t0, 3, valid_input
    	beq $t0, 4, valid_input
    	beq $t0, 5, valid_input
    	beq $t0, 8, valid_input
    	beq $t0, 9, valid_input
    	beq $t0, 10, valid_input
    	beq $t0, 11, valid_input
    	beq $t0, $t2, valid_input

    	# Invalid input
    	li $v0, 4
    	la $a0, wrong_hours
    	syscall
    	j read

	valid_input:
	jr $ra
	
	
cal_slots_func:
		li $v0, 4 #to print a string
		li $t1 , 31 #maximum number of day per month
		move $s1, $ra
		jal day_search_func
		move $t9, $v1  #the day number
		move $a1, $t0 #address of the day line
		li $v0, 4 #to print the start slot string
	read:	la $a0, start_slot
		syscall
		li $v0, 5 #to read the beginning of the slot
		syscall
		move $t0, $v0 
		li $v0, 12 #to get rid of the new line character
		syscall
		jal hours_checker
		move $a2, $t0 #beginning of the slot
		li $v0, 4 #to print the end slot string
		la $a0, end_slot
		syscall
		li $v0, 5 #to read the end of the slot
		syscall
		move $t0, $v0 
		jal hours_checker
		move $a3, $t0 #end of the slot
		li $v0, 12 #to get rid of the new line character
		syscall
		# to make it in 24 hours format
		li $t3, 8
		bge $a2, $t3, do_nothing
		addiu $a2, $a2, 12
   do_nothing:  bge $a3, $t3, do_nothing2
    		addiu $a3, $a3, 12
   do_nothing2:	
	li $t8, 0
L2:	lb $t1, 0($a1)     # load the byte at the beginning of the buffer
    	beq $t1, 45, check_start  #if we reached - then we have to check the start of the interval
    	bne $t1, 32, dont_reset_sum  #if there is no space then there is another digit
    	li $t8, 0  #otherwise reset the sum
dont_reset_sum:
    	bgt $t1, '9', done4 #if the character is not numeric
    	blt $t1, '0', done4 #if the character is not numeric
    	addiu $t1 , $t1 , -48 #to convert into integer

    	#to concatenate the digits
    	mul $t8, $t8, $t6 
    	addu $t8, $t8, $t1 
done4: 	addiu $a1, $a1, 1 #go to the next character
	beq $t1, 10, wrong
    	j L2

#compare the start interval of the calendar with the user's input
check_start:
	bgt $t8, 5, L5
	addiu $t8, $t8, 12  #to make the calendar's start interval in 24 hours format
L5:	beq $t8, $a2, L6   #if the calendar's interval equal the user's input, go to L6
	li $t8, 0   #otherwise reset the sum
	addiu $a1, $a1, 1  #and go to the next character
	bne $t1, 10,  L2  #if it was not new line character go to the main checker
	j done6   #else, the user's interval is not found
L6:	move $t3, $a1  #when it comes here, it means we found the interval and we want to store it's address "address of -"
	li $t8, 0  #reset the sum to use t8 again for check end
	addiu $a1, $a1, 1  #go to next character
L7:	lb $t1, 0($a1)  
	beq $t1 10, wrong  #if we reached the new line character then the user's input is not found
	bne $t1, 45, end    #if there is - then that's not the end of the interval
	li $t8, 0
end:   	beq $t1, ' ', check_end  #if we reached the space then we need to check the end of the interval
    	bgt $t1, '9', done5 #if the character is not numeric
    	blt $t1, '0', done5 #if the character is not numeric
    	addiu $t1 , $t1 , -48 #to convert into integer

    	#to concatenate the digits
    	mul $t8, $t8, $t6 
    	addu $t8, $t8, $t1 
done5: 	addiu $a1, $a1, 1 #go to the next character	
	j L7
	
#to compare the end of the interval with the user's input
check_end:
	bgt $t8, 5, L8
	addiu $t8, $t8, 12  #convert the calendar's end interval into 24 hours format
L8:	beq $t8, $a3, L9   #if the calendar's end interval equals the user's input then go to L9
	li $t8, 0   #otherwise reset the sum
	addiu $a1, $a1, 1  #and go to the next character
	j L7  #and go back to the main checker
L9:	
	move $t0, $a1   #if we reached here it means that we found the end of the interval
	#but we have to check if the user entered beginning of interval with another beginning of other interval
	li $t2, 0
	
	#if we reached here that means the user entered exist interval
	move $t4, $a1
	
	move $ra, $s1
	li $s1, 0
done6:	jr $ra

	
