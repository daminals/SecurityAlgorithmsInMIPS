.data
str: .asciiz "Seawolves let's go!"

.text
main:
 # test lcm
 
 #li $a0, 15
 #li $a1, 26
 #jal prikExp
 #j end
 
 # end temp comment all this out later
 li $a0, 73
 #jal isPrime

 la $a0,str
 #jal hash

 add $a0,$v0,$0
 
 li $a0, 19
 li $a1, 5
 li $a2, 7
 jal encrypt
 li $a2, 5
 li $a3, 7
 move $a0, $v0
 move $a1, $v1
 jal decrypt
 j end
 
 li $a1,107
 
 li $a2,157
 jal encrypt
 add $a0,$v0,$0
 add $a1,$v1,$0
 li $a2,107
 li $a3,157
 jal decrypt
 add $a0,$v0,$0
 li $v0,1
 syscall
 end:
 move $a0, $v0
 li $v0, 1
 syscall
 li $v0, 10
 syscall

.include "hw2.asm"
