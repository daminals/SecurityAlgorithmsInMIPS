########### Daniel Kogan ############

###################################
##### DO NOT ADD A DATA SECTION ###
###################################

.text
.globl hash
hash:
  # registers changed: t0, t1, v0
  # read value from a0
  #move $t0, $a0
  move $t0, $a0 
  li $v0, 0
  # store answer in v0
  hash_loop: 
  # for (int i=0;i<len;i++) {}
  lbu $t1 0($t0)
  beq $t1, $0, hash_loop_over
  addi $t0, $t0, 1
  add $v0, $v0, $t1
  j hash_loop
  hash_loop_over:
  jr $ra

.globl isPrime
isPrime:
  # registers changed: t0, t1, t2, t3, v0
  # 1 and 2 are prime
  li $t0, 1
  beq $a0, $t0, prime_loop_over
  li $t0, 2
  beq $a0, $t0, prime_loop_over
  # epic loop time
  # read value from a0
  # move $t0, $a0
  move $t0, $a0
  # counter lol
  move $t1, $a0
  li $v0, 0
  # store answer in v0
  prime_loop: 
  # for (int i=0;i<len;i++) {}
  # start at highest keep going down
  addi $t1, $t1, -1
  li $t3, 1
  beq $t1, $t3, prime_loop_over
  # divide, save reminder in HI
  div $t0, $t1
  # move from HI to t2
  mfhi $t2
  # if the remainder is 0, certified not prime
  beqz $t2 certified_not_prime
  j prime_loop
  prime_loop_over:
    li $v0, 1
    certified_not_prime:
      jr $ra

.globl lcm
lcm:
  # least commomn multiple
  # abs (a * b) / gcd(a,b)
  # input a=a0, b=a1
  # registers changed: t0, t1, t2 v0
  # advanced manuever, save to stack
  addi $sp, $sp, -8
  sw $ra, 0($sp)
  # get gcd, save result
  jal gcd
  move $t0, $v0
  lw $ra, 0($sp)
  addi $sp, $sp, 8 
  # lcm stuff now - t0 = gcd(a,b)
  # multiplication:
  mult $a0, $a1
  # numerator stored in t1
  mflo $t1
  # absolute value / t1=abs(t1) / t2 is garbage data
  sra $t2, $t1, 31
  xor $t1, $t1, $t2
  sub $t1, $t1, $t2
  # get result now |a*b| / gcd(a,b)
  div $t1, $t0
  mflo $v0
  # debug
  # move $a0, $v0
  #li $v0, 1
  #syscall
  jr $ra

.globl gcd
gcd:
  # greatest common denominator
  # inputs a=a0, b=a1
  # registers changed: t0, t1, t2 v0
  # implementing euclid's formula
  move $t0, $a0
  move $t1, $a1
  gcd_loop:
  beqz $t1, t1_is_zero_gcd
  beqz $t0, t0_is_zero_gcd
  bgt $t0, $t1, skip_switching_gcd # check a > b
  # swap a and b if b < a
  move $t2, $t1
  move $t1, $t0
  move $t0, $t2
  skip_switching_gcd:
  div $t0, $t1
  # take the remainder
  mfhi $t0
  j gcd_loop
  t0_is_zero_gcd:
  move $v0, $t1
  j end_function
  t1_is_zero_gcd:
  move $v0, $t0
  end_function:
  li $t0, 0
  jr $ra


.globl pubkExp
pubkExp:
  # inputs z=a0
  # registers used t0, t1, t2, a0, a1, v0
  # generate random number r, 1<r<z
  # syscall 42
  # check if gcd(z,r) = 1
  # return r
  move $t0, $a0
  pubkExp_while_loop:
    # generate random number
    move $a1, $t0
    li $v0, 42
    syscall
    # save random number to t1
    move $t1, $a0
    li $t2, 2
    blt $t1, $t2, pubkExp_while_loop
    # gcd(z,r)
    # advanced manuever, save to stack
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $a1, 4($sp)
    sw $t1, 8($sp)
    # gcd takes a0 a1
    move $a0, $t0
    move $a1, $t1
    # get gcd. stored in v0
    jal gcd
    # save gcd in v0
    lw $ra, 0($sp)
    lw $t0, 4($sp)
    lw $t1, 8($sp)
    addi $sp, $sp, 12
    # beq gcd 1
    li $t2, 1
    beq $v0, $t2, pubkExp_end_function
    # jump if bne
    j pubkExp_while_loop
  pubkExp_end_function:
  # move r to v0
  move $v0, $t1
  jr $ra

.globl prikExp
prikExp:
  # inputs x=a0, y=a1 | x<y
  # registers changed t0, t1, t2, t3, t9
  #j coprimeness_validated # debugging use only
  # check coprimeness, return -1 if not 1
    # gcd(x,y)
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    # gcd takes a0 a1
    jal gcd
    # save gcd in v0
    lw $ra, 0($sp)
    addi $sp, $sp, 8 
    # beq gcd 1
    li $t0, 1
    bne $v0, $t0, prikExpNotCoprime
  coprimeness_validated:
  # coprimeness validated
  move $t0, $a0
  move $t1, $a1
  li $t2, 0 # counter var
  li $t9, 3 # for skipping p0 p1
  # p
  li $t8, 0 # p0
  li $t7, 1 # p1
  #li $t3, 0 # p2
  # q
  li $t6, 1 # q0
  li $t5, 1 # q1
  li $t4, 1 # q2
  extended_euclidean_algo_loop:
    beqz $t0,load_t1_as_t0
    beqz $t1, end_extended_euclidean_algo
    div $t1, $t0
    move $t1, $t0 # t1 becomes t0
    mfhi $t0  # t0 becomes remainder
    
    
    # q stuff
    move $t4, $t5
    move $t5, $t6 
    mflo $t6 # q is quotient
    
    addi $t2, $t2, 1 # counter++
    blt $t2, $t9 extended_euclidean_algo_loop # skip 1 & 2 p0/p1
    # p stuff
    p_stuff:
    mult $t7, $t4
    mflo $t3 # t3 is result
    sub $t3, $t8,$t3 # 0 - 1*1 in example
    bltz $t3, negative_mod
    # not less than 0
    positive_modulo:
    div $t3, $a1
    move $t8, $t7
    mfhi $t7
    
    j extended_euclidean_algo_loop
    
  load_t1_as_t0:
    move $t1, $t0
    li $t0, 1
    move $t4, $t5
    move $t5, $t6 
    j p_stuff
    
  end_extended_euclidean_algo:
    move $v0, $t7
    j prikExpReturnVal
    
  prikExpNotCoprime:
    li $v0, -1
  prikExpReturnVal:
  jr $ra

negative_mod:
  add $t3, $t3, $a1
  bltz $t3, negative_mod
  j positive_modulo


.globl encrypt
encrypt:
 #inputs: m=a0, p=a1, q=a2
 # registers changed: t6, t7,t8,t9
 # Step 3: n = a1*a2 | n = t7
 mul $t7, $a1, $a2
 # Step 1: K = lcm(p-1, q-1) | K = t9
 # move to temp registers unaffected to lcm | no need for stack
 
 move $t6, $a0
 addi $a0, $a1, -1
 addi $a1, $a2, -1 # a2 unaffected
 
   # run lcm function
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    # gcd takes a0 a1
    jal lcm
    # save gcd in v0
    lw $ra, 0($sp)
    addi $sp, $sp, 8 
 move $t9, $v0 # K
 addi $a1, $a0, 1
 # Step 2: get public key of K (e) | e=t8
 move $a0, $t9 # pubkey takes in a0
    # run pubkExp function
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    # gcd takes a0 a1
    jal pubkExp
    # save gcd in v0
    lw $ra, 0($sp)
    addi $sp, $sp, 8 
 move $t8, $v0 # e
 move $a0, $t6 # restore hashed message 
 # Step 4: c = m^e mod n | c = t6
 # use the grand fancy 'memory efficient algorithm'
 li $t1, 1 # storing c
 li $t2, 0 # e'
 # while e' != e:
 modular_exponentiation_loop:
  beq $t2, $t8, encrypt_end_func
  addi $t2, $t2, 1
  mul $t1, $t1, $a0
  div $t1, $t7 # mod n
  mfhi $t1
  j modular_exponentiation_loop
 # Step 5: return v0=c v1=e
 encrypt_end_func:
  move $v0, $t1
  move $v1, $t8 # e
 jr $ra

.globl decrypt
decrypt:
  # inputs: a0=c a1=e a2=p a3=q
  # solve m = c^d mod n 
  # Step 1: find second arg in priv key
  # lcm (p-1, q-1) | p=a2 | q=a3
  move $t9, $a0 # c
  move $t8, $a1 # e | public key
  addi $a0, $a2, -1
  addi $a1, $a3, -1
     # run lcm function
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    # gcd takes a0 a1
    jal lcm
    # save gcd in v0
    lw $ra, 0($sp)
    addi $sp, $sp, 8 
  # Step 2: prikExp
  move $a0, $t8 # public key
  move $a1, $v0  # set a1 to lcm
  # stash stuff this is gonna eat all my registers
    # run prikExp function
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $t9, 4($sp) # c
    # gcd takes a0 a1
    jal prikExp
    # save gcd in v0
    lw $ra, 0($sp)
    move $t9, $a1 # set t9 to lcm
    move $a1, $a0 # set a1 to public key
    lw $a0, 4($sp) # set c to a0
    addi $sp, $sp, 8
  # Step 4: m = c^d mod n | c = t6
  # use the grand fancy 'memory efficient algorithm'
  move $t1, $a0 # storing m
  move $t6, $v0 # d
  li $t2, 0 # d'
  mul $t3, $a2, $a3 # set n
  # while d' != d:
  decrypt_modular_exponentiation_loop:
   addi $t2, $t2, 1
   beq $t2, $t6, decrypt_end_func
   mul $t1, $t1, $a0
   div $t1, $t3 # mod n
   mfhi $t1
   j decrypt_modular_exponentiation_loop
  decrypt_end_func:
  move $v0, $t1
  jr $ra
