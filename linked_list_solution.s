
.text
.globl main

main:
menu_loop:
    
    la $a0, slash #"------------------------"
    li $v0, 4
    syscall
	
	la $a0, newline #print(\n)
    li $v0, 4
    syscall
	
	la $a0, msg_menu	# Printing Menu 
    li $v0, 4
    syscall
	
	
	la $a0, slash #"------------------------"
    li $v0, 4
    syscall
	
	la $a0, newline    #print(\n)
    li $v0, 4
    syscall
	
	
	la $a0, msg_option	#"Please choose an option:
    li $v0, 4
    syscall
	

    
    li $v0, 5			# read(int)
    syscall

    beq $v0, 0, exit     # Case 0: Exit
    beq $v0, 1, insert   # Case 1: Insert
    beq $v0, 2, delete   # Case 2: Delete
    beq $v0, 3, _print   # Case 3: Print
    j menu_loop

insert:
    la $a0, msg_val		#"Enter integer value: "
    li $v0, 4
    syscall
    li $v0, 5   
    syscall
    move $a0, $v0           # save the first parameter in register $a0(value)
    lw $a1, head            # and the second one in $a1 (head)
	
    jal InsertNode          # call function InsertNode
	# continue with the rest of the program
    sw $v0, head            # update the head with the new address
    la $a0, msg_added		#Value added successfully
    li $v0, 4
    syscall
    j menu_loop

delete:
    lw $t0, head
    beqz $t0, list_empty    # Check if the list is empty
    la $a0, msg_del
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $a0, $v0           # save the first parameter in register $a0(value)
    lw $a1, head             # and the second one in $a1 (head)
     
    jal DeleteNode			# call function DeleteNode
	# continue with the rest of the program	
    sw $v0, head            #head = new head
    j menu_loop

_print:
    lw $a0, head			#$a0 = head
    beqz $a0, list_empty    #if(head == null) goto list_empty
    
    jal PrintList		# call function PrintList
	# continue with the rest of the program
    j menu_loop

list_empty:
    la $a0, msg_empty
    li $v0, 4
    syscall
    j menu_loop

exit:
    li $v0, 10         #exit
    syscall

# -----------------------------------------------------------------
# CreateNode 
#   node.data = value
#   node.next = NULL
#   return node
# -----------------------------------------------------------------
CreateNode:
    # function CreateNode PROLOGUE
    move $t0, $a0           # $t0 = value

    # function CreateNode:
    li $a0, 8               # 8 bytes: 4 for the value + 4 pointer nextnode
    li $v0, 9               # sbrk
    syscall                 # $v0 = address of new node
    
    sw $t0, 0($v0)          # node.data = value
    sw $zero, 4($v0)        # node.next = NULL 
    
    # function CreateNode EPILOGUE
    jr $ra                  # return to	InsertNode

# -----------------------------------------------------------------
# InsertNode
#   newNode = CreateNode(value)
#   if (head == NULL) or (value < head.data):
#      newNode.next = head 
#	   return newNode
#   current = head
#   while (current.next != NULL and current.next.data < value):
#      current = current.next
#   newNode.next = current.next; current.next = newNode
#   return head
# -----------------------------------------------------------------
InsertNode:
    # function InsertNode PROLOGUE
    subu $sp, $sp, 16
    sw $ra, 12($sp)         # Return address
    sw $s0, 8($sp)          # value
    sw $s1, 4($sp)          # head
    sw $s2, 0($sp)          # new node
	
    # function InsertNode
    move $s0, $a0           # Backup value
    move $s1, $a1           # Backup head
 
    move $a0, $s0			# save the first parameter in register $a0(value)
    jal CreateNode			# call function CreateNode
	# continue with the rest of the program
    move $s2, $v0           # $s2 = new Node

    # Case 1: insert_front
    beqz $s1, insert_front  # if head == NULL
    lw $t0, 0($s1)          # $t0 = head.data
    bgt $t0, $s0, insert_front # if head.data > value

    # Case 2: Find place in list 
    move $t0, $s1           # $t0 = current
find_pos:
    lw $t1, 4($t0)          # $t1 = current.next
    beqz $t1, connect       # if(current.next == null) goto connect
    lw $t2, 0($t1)          # $t2 = current.next.data
    bgt $t2, $s0, connect   # if(current.next.data > value) goto connect
    move $t0, $t1           # current = current.next
    j find_pos

connect:
    lw $t1, 4($t0)          # t1 = current.next
    sw $t1, 4($s2)          # newNode.next = current.next
    sw $s2, 4($t0)          # current.next = newNode
    move $v0, $s1           # the head stays the same
    j insert_done

insert_front:
    sw $s1, 4($s2)          # newNode.next = head
    move $v0, $s2           # head = new Node

insert_done:
    # EPILOGUE
    lw $ra, 12($sp)
    lw $s0, 8($sp)
    lw $s1, 4($sp)
    lw $s2, 0($sp)
    addu $sp, $sp, 16
    jr $ra                 # return to	insert

# -----------------------------------------------------------------
#PrintList
#   current = head
#   while (current != NULL):
#      print(current.data); current = current.next
# -----------------------------------------------------------------
PrintList:
    # PROLOGUE
    move $t0, $a0           # t0 = current
	
	# PrintList subroutine 
p_loop:
    beqz $t0, p_done        # if(t0 == NULL) goto p_done
    lw $a0, 0($t0)          # print(current.data)
	li $v0, 1
    syscall
    
    la $a0, space           #print(" ")
    li $v0, 4               
    syscall
    
    lw $t0, 4($t0)          # current = current.next 
    j p_loop
p_done:
    la $a0, newline         #print(\n)
    li $v0, 4
    syscall
	# function PrintList EPILOGUE
    jr $ra					# return to	_print

# -----------------------------------------------------------------
# DeleteNode
#   if (head.data == value) return head.next
#   current = head
#   while (current.next != NULL and current.next.data != value):
#      current = current.next
#   if (current.next != NULL) current.next = current.next.next
#   return head
# -----------------------------------------------------------------
DeleteNode:
    beqz $a1, notfnd        # if head == NULL, goto notfnd
    
    move $s0, $a1           # $s0 = head
    lw $t0, 0($s0)          # $t0 = head.data
    
    
    beq $t0, $a0, del_head  # if($t0 == value) goto del_head
    
    move $t0, $s0           # current ($t0) = head

_search:
    lw $t1, 4($t0)          # t1 = current.next
    beqz $t1, notfnd        # if(current.next == NULL) goto notfnd
    
    lw $t2, 0($t1)          # t2 = current.next.data
    beq $t2, $a0, found     # if(current.next.data == value) goto found 
    
    move $t0, $t1           # current = current.next
    j _search

found:
    
    lw $t2, 4($t1)          # t2 = current.next
    sw $t2, 4($t0)          # prev.next = current.next 
    
    j _success      

del_head:
    lw $s0, 4($s0)          # head = head.next
    j _success

_success:
    
    la $a0, msg_deleted     #Value deleted!
    li $v0, 4
    syscall
    
    move $v0, $s0           # return new head 
    jr $ra                  # return to	delete

notfnd:
    la $a0, msg_notfnd      #The value you entered wasn't found
    li $v0, 4
    syscall
    
    move $v0, $a1           # return head
    jr $ra                  # return to	delete	
	
	
# Data segment 	
	
.data
head:       .word 0          # Pointer to head
msg_menu:	.asciiz "(1) Insert data!\n(2) Delete data!\n(3) Show list ascending!\n(0) Exit Program!\n"
slash:		.asciiz "------------------------"
msg_option:	.asciiz	"Please choose an option: \n"
msg_val:    .asciiz "Enter a value \n"
msg_del:    .asciiz "Delete a value \n"
msg_empty:  .asciiz "The list is empty\n"
msg_notfnd: .asciiz "The value you entered wasn't found\n"
msg_added:  .asciiz "Value added !\n"
msg_deleted:    .asciiz "Value deleted!\n"
space:      .asciiz " "
newline:    .asciiz "\n"