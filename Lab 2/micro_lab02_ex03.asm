.include "m328PBdef.inc"
.org 0x0
rjmp reset
.org 0x4
rjmp ISR1
 
.equ FREQ=16 ;operating freq 
    
    
reset:
    ;init stack pointer
    ldi r24, LOW(RAMEND)
    out SPL, r24
    ldi r24, HIGH(RAMEND)
    out SPH, r24
    
    ;interrupt on the rising edge of INT1 pin
    ldi r26, (1<<ISC11) | (1 << ISC10)
    sts EICRA, r26
    
    ;Enable INT1
    ldi r26, (1<<INT1)
    out EIMSK, r26
    
    sei ;enable interrupt flags

IO_set:
    ;PORTB as input    
    ser r27
    out DDRB, r27
    ldi r22, 0x00 ;for portb
    ldi r21, 0x00 ;counter for interrupts/delay
    ldi r20, 0x00 ;flag for delay break

main:
    clr r20 ;clear delay break flag
    cpi r21, 1 
    breq delays_1 ;check for first time interrupt
    cpi r21, 2
    brsh delays_2 ;check for intermediate interrupts
    clr r22 ;else all PORTB leds to zero
    out PORTB, r22
    rjmp main


delays_1:
    ldi r22, 0x01 ;flash LSB
    out PORTB, r22
    
    ldi r24, low(FREQ*4000) ;then wait for 4000ms
    ldi r25, high(FREQ*4000)
    rcall delay_mS ;delay 4sec
    
    clr r21
    rjmp main
    
delays_2:
    ldi r22, 255 ;flash all
    out PORTB, r22
    ldi r24, low(FREQ*500) ;then wait for 500ms
    ldi r25, high(FREQ*500)
    rcall delay_mS ;delay 500ms
    
    ldi r22, 0x01
    out PORTB, r22
    ldi r24, low(FREQ*4000) ;then wait for 4000ms
    ldi r25, high(FREQ*4000)
    rcall delay_mS
    
    clr r21 ;no more need for delay counter
    rjmp main    

ISR1:
    push r25 ;push registers to stack
    push r24
    in r24, SREG
    push r24
check:
    ldi r24, (1 << INTF1) ;includes sparkle effect
    out EIFR, r24         ;at the start of int. routine
    ldi r24, low(16*5)
    ldi r25, high(16*5)
    rcall delay_mS ;5ms delay before interrupt routine
    in r24, EIFR
    cpi r24, 2
    breq check
    
    inc r21 ;increase counter for delays
    ldi r20, 1 ;set delay register to 1
    rjmp telos

telos:
    pop r24
    out SREG, r24
    pop r24
    pop r25
    reti

  
delay_mS: ;delay loop
    ldi r23,200  ;decrease r23 from 249 to 200 for more accurate delay 
    clr r20
loop_inn:
    cpi r20, 1 ;check register right after interrupt on delay
    breq main
    dec r23
    brne loop_inn
    
    sbiw r24,1
    brne delay_mS
    
    ret


