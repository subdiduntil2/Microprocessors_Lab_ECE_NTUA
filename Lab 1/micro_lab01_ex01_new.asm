.include "m328PBdef.inc"
.equ cr = 30 ; input msec delay

reset:
      ldi r24 , low(RAMEND)     ;initialize stack pointer
      out SPL , r24
      ldi r24 , high(RAMEND)
      out SPH , r24
      
main:
    ldi r24, LOW(cr)
    ldi r25, HIGH(cr)	    
    rcall wait_x_msec	
main_sunexeia:
    rjmp main 
    

wait_x_msec:	
    sbiw r24 , 1
    breq telos	    ;check if r24 = 1
loop1:	
    rcall wait_1msec   
    rcall wait4	    
    nop
    sbiw r24 , 1	    
    brne loop1 ;1 or 2 cycles
    nop ;1 cycle
    nop
telos:	
    rcall wait_1msec
    nop
    ret ;3 cycles

    
wait_1msec:		    ;produce 988usec delay
    ldi r26 , 97    
loop2:  
    rcall wait4     ;4+3=7 cycles
    dec r26	;1 cycle    
    brne loop2	    
    rcall wait4
    nop
    nop
    nop
    nop
    ret	;4 cycles	    
	    
 wait4:	ret



