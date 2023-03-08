.include "m328PBdef.inc" ;checked
.equ FOSC_MHZ=16
.def counter=r19   
.org 0x0
rjmp reset
.org 0x4
rjmp ISR1  
.org 0x1A
rjmp ISR_TIMER1_OVF
    

reset:
    ;init stack pointer
    ldi r24, LOW(RAMEND)
    out SPL, r24
    ldi r24, HIGH(RAMEND)
    out SPH, r24
    
    ;interrupt on the rising edge of INT1 pin
    ldi r24, (1<<ISC11) | (1 << ISC10)
    sts EICRA, r24
    
    ;Enable INT1
    ldi r24, (1<<INT1)
    out EIMSK, r24
    
    ldi r24, (1<<CS12) | (0<<CS11) | (1<<CS10)	 ;prescale=1024
    sts TCCR1B, r24
    
    
    sei
    
    
IO_set:
    ;PORTB as output    
    ser r24
    out DDRB, r24
      
    ;PORTC as input
    clr r24
    out DDRC, r24
    
    clr counter
main:
    in r24, PINC
    cpi r24, 0x5F
    brne main
    ldi r24, LOW(16*200)
    ldi r25, HIGH(16*200)
    rcall wait_x_msec	;sparkle effect
    cpi counter, 0x00
    breq pc5_routine
    ser r24
    out PORTB, r24  ;leds on
    ldi r24, LOW(16*500)
    ldi r25, HIGH(16*500)
    rcall wait_x_msec
	
    
pc5_routine:	
    
    ldi r24, 0x01
    out PORTB, r24
    
    ldi r24, HIGH(3035)	    ;4 sec timer
    sts TCNT1H, r24
    ldi r24, LOW(3035)
    sts TCNT1L, r24
    ;enable TCNT1 of TIME/COUNTER1
    ldi r24, (1<<TOIE1)
    sts TIMSK1, r24
    inc counter
    rjmp main
        

ISR_TIMER1_OVF:
    
    clr r21
    out PORTB, r21
    clr counter
    ldi r18, (0<<TOIE1)
    sts TCNT1L, r18
    reti
    
ISR1:
    cli
    push r25
    push r24
    in r24, SREG
    push r24
check:    
    ldi r24, (1 << INTF1) ;includes sparkle effect
    out EIFR, r24         ;at the start of int. routine
    ldi r24, low(16*5)
    ldi r25, high(16*5)
    rcall wait_x_msec ;5ms delay before interrupt routine
    in r24, EIFR
    cpi r24, 2
    breq check
    
    ;rcall wait_x_msec	;sparkle effect
    ldi r24, HIGH(3035)	    ;4 sec timer
    sts TCNT1H, r24
    ldi r24, LOW(3035)
    sts TCNT1L, r24
    ;enable TCNT1 of TIME/COUNTER1
    ldi r24, (1<<TOIE1)
    sts TIMSK1, r24
    ldi r24, 0x01
    out PORTB, r24
    ;inc counter
    cpi counter, 0x00
    breq telos_int1
    
    ldi r24, 0xFF
    out PORTB, r24
    ldi r24, LOW(16*500)
    ldi r25, HIGH(16*500)
    rcall wait_x_msec
    clr r24
    sts TCNT1H, r24
    sts TCNT1L, r24  
    
    ldi r24, HIGH(3035)	    ;4 sec timer
    sts TCNT1H, r24
    ldi r24, LOW(3035)
    sts TCNT1L, r24
    ldi r24, 0x01
    out PORTB, r24
    
telos_int1:
    inc counter
    pop r24
    out SREG, r24
    pop r24
    pop r25
    sei
    reti
    
    
;produces x sec delay
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




