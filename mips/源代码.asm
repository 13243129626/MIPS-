# 项目名称：斐波那契数列  
################################################################
#程序功能描述：
#输入整数N，将对应的前N个斐波那契数存入数组
#分别输出前N个元素的十进制数和十六进制数
#若数值错误，输出错误信息
################################################################
#寄存器的使用：
#$a0:存储数值N，用于在程序中传递N
#$a1:传递数组的地址
################################################################
    .data
start:  .asciiz "\n Input N = "
last1:  .asciiz "\n The result is: \n"
last2:  .asciiz "index   Dec      Hex\n"
out1:  .asciiz "\n N is not legal\n"   #N输入非法
out2:  .asciiz "\n overflow\n"       #溢出
empty:  .asciiz "       "
Hex:    .asciiz " 0Xxxxxxxxx\n"
buf:  .word 1,1
      .space 4096              #设定数组大小
      .text
main:   la $a0,start
        li $v0,4
        syscall            #输出start字符串
        la $a0,buf         #数组首地址
        move $a1,$a0       #$a1是地址 
        li $v0,5
        syscall            #输入N
        addi $v0,$v0,-1
        move $a0,$v0        #$a0作为计数器，等于N-1
        bltz $a0,out_1     #N非法输入
         move $t5,$a1
         move $t6,$a0
         li $s1,1
         jal FIB        #按要求存储数据
         addi $a3,$a0,0
         li  $a2,0
         la $a0,last1
         li $v0,4
         syscall
         la $a0,last2
         li $v0,4
         syscall
         jal print         #按要求打印数据
         li $v0,10         #退出
         syscall          
#################### FIB函数 #####################
#函数名称：FIB
#函数功能：将斐波那契数列存到数组中，并判断溢出
#寄存器功能：
#$t1,$t2:传递数组地址
#$a3:计算相应的斐波那契数
################################################################
FIB:    ble $t6,$s1,ret       #$t6<=1就返回
        lw $t1,($t5)
        lw $t2,4($t5)
        addu $a3,$t1,$t2  
        addi $t4,$0,-1        
        subu $t3,$t4,$t1      #f3=f1+f2
        bltu $t3,$t2,out_2    #判断溢出
        addi $t5,$t5,4
        sw $a3,4($t5)
        addi $t6,$t6,-1
        b FIB
#################### print函数 #####################
#函数名称：print
#函数功能：分别输出斐波那契数列的前N项的下标、十进制表示、十六进制表示
################################################################
print:  bgt $a2,$a3,ret
        move $a0,$a2
        li $v0,1
        syscall     #打印下标
        la $a0,empty
        li $v0,4
        syscall     #空格
        lw $a0,($a1)
        li $v0,1
        syscall      #打印十进制数值
        la $a0,empty
        li $v0,4
        syscall    #空格
        lw $a0,($a1)
        addi $sp,$sp,-16
        sw $ra,12($sp)
        sw $a0,8($sp)
        sw $a2,4($sp) 
        sw $a1,($sp)      #用堆栈存储来保护寄存器中的值
        jal hex            #调用hex函数转换成十六进制
        lw $ra,12($sp)
        lw $a0,8($sp)
        lw $a2,4($sp)
        lw $a1,($sp)            #恢复相应寄存器的值
        addi $sp,$sp,16
        la $a0,Hex
        li $v0,4
        syscall                #输出转换好的的十六进制字符串
        addi $a1,$a1,4
        addi $a2,$a2,1
        b print      
hex:   la $a0, Hex	
       lw   $a1,8($sp)
      	li $a2, 7	    		 #循环次数
     	addi $t1, $a0, 10   	 #从位置buf+10处开始存放16进制数
loop:	andi $t0, $a1, 0x0f   	#取a1的低4位
	srl $a1, $a1, 4      	    #a1右移4位
	bge $t0, 10, char 	        #t0大于等于10跳转到为A-F处理
	addi $t0, $t0, 0x30	        #0的ASCII码为0x30，在原先基础上加0x30
      	b put
char:	addi $t0, $t0, 0x37   	#A的ASCII码为65，在原先基础上加(65-10)
put:	sb $t0, ($t1)         	#放置字符
	addi $t1, $t1, -1   	#放置位置前移一个字符
	addi $a2, $a2, -1   	#将循环次数减1
	bgez $a2, loop		#判断循环是否结束
       jr $ra
out_1:  la $a0,out1        #N非法
        li $v0,4
        syscall
        b out
out_2:  la  $a0,out2       #数值出现溢出
        li $v0,4
        syscall
        b out
ret:    jr $ra            #返回地址

out: li $v0,10             #退出
     syscall   
