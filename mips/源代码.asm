# ��Ŀ���ƣ�쳲���������  
################################################################
#������������
#��������N������Ӧ��ǰN��쳲���������������
#�ֱ����ǰN��Ԫ�ص�ʮ��������ʮ��������
#����ֵ�������������Ϣ
################################################################
#�Ĵ�����ʹ�ã�
#$a0:�洢��ֵN�������ڳ����д���N
#$a1:��������ĵ�ַ
################################################################
    .data
start:  .asciiz "\n Input N = "
last1:  .asciiz "\n The result is: \n"
last2:  .asciiz "index   Dec      Hex\n"
out1:  .asciiz "\n N is not legal\n"   #N����Ƿ�
out2:  .asciiz "\n overflow\n"       #���
empty:  .asciiz "       "
Hex:    .asciiz " 0Xxxxxxxxx\n"
buf:  .word 1,1
      .space 4096              #�趨�����С
      .text
main:   la $a0,start
        li $v0,4
        syscall            #���start�ַ���
        la $a0,buf         #�����׵�ַ
        move $a1,$a0       #$a1�ǵ�ַ 
        li $v0,5
        syscall            #����N
        addi $v0,$v0,-1
        move $a0,$v0        #$a0��Ϊ������������N-1
        bltz $a0,out_1     #N�Ƿ�����
         move $t5,$a1
         move $t6,$a0
         li $s1,1
         jal FIB        #��Ҫ��洢����
         addi $a3,$a0,0
         li  $a2,0
         la $a0,last1
         li $v0,4
         syscall
         la $a0,last2
         li $v0,4
         syscall
         jal print         #��Ҫ���ӡ����
         li $v0,10         #�˳�
         syscall          
#################### FIB���� #####################
#�������ƣ�FIB
#�������ܣ���쳲��������д浽�����У����ж����
#�Ĵ������ܣ�
#$t1,$t2:���������ַ
#$a3:������Ӧ��쳲�������
################################################################
FIB:    ble $t6,$s1,ret       #$t6<=1�ͷ���
        lw $t1,($t5)
        lw $t2,4($t5)
        addu $a3,$t1,$t2  
        addi $t4,$0,-1        
        subu $t3,$t4,$t1      #f3=f1+f2
        bltu $t3,$t2,out_2    #�ж����
        addi $t5,$t5,4
        sw $a3,4($t5)
        addi $t6,$t6,-1
        b FIB
#################### print���� #####################
#�������ƣ�print
#�������ܣ��ֱ����쳲��������е�ǰN����±ꡢʮ���Ʊ�ʾ��ʮ�����Ʊ�ʾ
################################################################
print:  bgt $a2,$a3,ret
        move $a0,$a2
        li $v0,1
        syscall     #��ӡ�±�
        la $a0,empty
        li $v0,4
        syscall     #�ո�
        lw $a0,($a1)
        li $v0,1
        syscall      #��ӡʮ������ֵ
        la $a0,empty
        li $v0,4
        syscall    #�ո�
        lw $a0,($a1)
        addi $sp,$sp,-16
        sw $ra,12($sp)
        sw $a0,8($sp)
        sw $a2,4($sp) 
        sw $a1,($sp)      #�ö�ջ�洢�������Ĵ����е�ֵ
        jal hex            #����hex����ת����ʮ������
        lw $ra,12($sp)
        lw $a0,8($sp)
        lw $a2,4($sp)
        lw $a1,($sp)            #�ָ���Ӧ�Ĵ�����ֵ
        addi $sp,$sp,16
        la $a0,Hex
        li $v0,4
        syscall                #���ת���õĵ�ʮ�������ַ���
        addi $a1,$a1,4
        addi $a2,$a2,1
        b print      
hex:   la $a0, Hex	
       lw   $a1,8($sp)
      	li $a2, 7	    		 #ѭ������
     	addi $t1, $a0, 10   	 #��λ��buf+10����ʼ���16������
loop:	andi $t0, $a1, 0x0f   	#ȡa1�ĵ�4λ
	srl $a1, $a1, 4      	    #a1����4λ
	bge $t0, 10, char 	        #t0���ڵ���10��ת��ΪA-F����
	addi $t0, $t0, 0x30	        #0��ASCII��Ϊ0x30����ԭ�Ȼ����ϼ�0x30
      	b put
char:	addi $t0, $t0, 0x37   	#A��ASCII��Ϊ65����ԭ�Ȼ����ϼ�(65-10)
put:	sb $t0, ($t1)         	#�����ַ�
	addi $t1, $t1, -1   	#����λ��ǰ��һ���ַ�
	addi $a2, $a2, -1   	#��ѭ��������1
	bgez $a2, loop		#�ж�ѭ���Ƿ����
       jr $ra
out_1:  la $a0,out1        #N�Ƿ�
        li $v0,4
        syscall
        b out
out_2:  la  $a0,out2       #��ֵ�������
        li $v0,4
        syscall
        b out
ret:    jr $ra            #���ص�ַ

out: li $v0,10             #�˳�
     syscall   
