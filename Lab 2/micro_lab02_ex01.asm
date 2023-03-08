.include "m328PBdef.inc" ;cleanly running
.def counter=r19 ;counter register
    
.org 0x0
rjmp reset
.org 0x4
rjmp ISR1  

;init stack pointer
ldi r24, LOW(RAMEND)
out SPL, R24
ldi r24, HIGH(RAMEND)
out SPH, r24


reset:
    ;Interrupt on rising edge of INT1 pin
    ldi r24, (1 << ISC11) | (1 << ISC10)
    sts EICRA, r24
    
    ;Enable the INT1 interrupt (PD3)
    ldi r24, (1 << INT1)
    out EIMSK, r24
    sei
    
    ;set portc as output
    ser r26
    out DDRC, r26
    
    ser r27
    out DDRB, r27
    
    ldi counter,0x00
    
loop1:
    clr r26
loop2:
    out PORTB,r26 ;allagi sto PORTD mono
    
    ldi r24, low(16*500)
    ldi r25, high(16*500) ;set delay
    rcall delay_mS
    
    inc r26
    
    cpi r26, 16 ;compare r26 with 16
    breq loop1 ;restart if equal
    rjmp loop2 ;else start again
    
delay_mS: ;create ms delay
    ldi r23,249
loop_inn:
    dec r23
    nop
    brne loop_inn
    
    sbiw r24,1
    brne delay_mS
    
    ret

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
    
    in r25, PIND ;PIND kanonika
    sbrs r25, 7 ;check for PD7 button
    rjmp telos
    cpi counter, 31
    breq loop_f1
    inc counter
    out PORTC,counter
    rjmp telos
loop_f1:
    ldi counter,0 ;add to interrupt counter
    out PORTC,counter
    rjmp telos
telos:
    pop r24
    out SREG, r24
    pop r24
    pop r25
    reti











