.include "m328PBdef.inc"

reset:ldi r24 , low(RAMEND)               ;initialize stack pointer
      out SPL , r24
      ldi r24 , high(RAMEND)
      out SPH , r24
      ser r24
      out DDRD , r24  ;set PORTD as output            
     
main: 
    ldi r27, 0x01 
    set	;T flag = 1 for left move
    
left: 
      out PORTD, r27  ;typonetai h timh toy r27
      ldi r25,HIGH(500)           
      ldi r24,LOW(500)
      rcall wait_x_msec ;delay 0.5 second
      lsl r27 ;aristeri olisthisi gia na anapsei to aristero bit
      sbrs r27, 7  ;an to MSB einai 1, na ginei skip i epomeni entoli gia na sunexistei pros ta deksia i kinisi
      rjmp left

left_last: ;perasma tou MSB sto PORTD
      out PORTD,r27
      ldi r25,HIGH(1500) ;delay 1.5 sec
      ldi r24,LOW(1500)
      rcall wait_x_msec
      lsr r27 ;ena shift right gia na arxisei amesws i deksia kinisi
      clt   ;T flag = 0 gia deksia kinhsh
      rjmp right
      
      
right:                           
      out PORTD, r27                ;typonetai i timh toy r27
      ldi r25,HIGH(500)             ; 1 clock cycle 
      ldi r24,LOW(500)
      rcall wait_x_msec		    ;delay 0.5 second
      lsr r27
      sbrs r27, 0                   ;An to LSB einai 1, na ginei skip i epomeni entoli gia na sunexistei pros ta aristera i kinisi
      rjmp right
 
right_last: ;teleutaio perasma LSB pou den kanei i right
      out PORTD,r27
      ldi r25,HIGH(1500)             ; 1 clock cycle 
      ldi r24,LOW(1500)
      rcall wait_x_msec
      lsl r27 ;delay 1.5 sec
      set 	;T flag = 1 gia aristeri kinhsh stin left
      rjmp left
       
;delay subroutine from ex.01      
wait_x_msec: ;
    sbiw r24 , 1
    breq telos	    ;check if r24 = 1
loop1:	
    rcall wait_1msec   
    rcall wait4	    
    nop
    sbiw r24 , 1	    
    brne loop1
    nop
    nop
telos:	
    rcall wait_1msec
    nop
    ret

    
wait_1msec:		    ;produce 988?sec delay
	ldi r26 , 97    
loop2:  rcall wait4     ;4+3=7 cycles
	dec r26	    
	brne loop2	    
	rcall wait4
	nop
	nop
	nop
	nop
	ret		    

wait4:	ret



