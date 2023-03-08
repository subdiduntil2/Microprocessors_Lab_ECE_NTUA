.include "m328PBdef.inc" ;cleanly running
.org 0x0
rjmp reset
.org 0x2
rjmp ISR0
        
reset:
    ;init stack pointer
    ldi r24, LOW(RAMEND)
    out SPL, r24
    ldi r24, HIGH(RAMEND)
    out SPH, r24
    
    ;interrupt on the rising edge of INT1 pin
    ldi r26, (1<<ISC01) | (1 << ISC00)
    sts EICRA, r26
    
    ;Enable INT1
    ldi r26, (1<<INT0)
    out EIMSK, r26
    
    sei

IO_set:
    ;PORTB as input    
    clr r27
    out DDRB, r27
    
    ;PORTC as output
    ser r27
    out DDRC, r27
    
    ldi r20, 0 ;output counter
    ldi r22, 6 ;bit counter in for loop
    
    clr r23 ;clr for main

main: ;default main
    nop
    nop
    rjmp main

ISR0:
    push r24
    in r24, SREG
    push r24
    push r21
    push r19
    push r22   ;save registers to stack
    
    clr r24
    out PORTC, r24 ;clear PORTC
    in r21, PINB ;read from PORTB ;a temp register
    com r21
loop:
    mov r19, r21 
    andi r19,0x01 ;temp register
    cpi r19,0x01 
    breq cont
loop_next:
    dec r22 
    asr r21 ;shift right 
    cpi r22,0 ;break or not for loop
    breq loop2
    rjmp loop
cont:
    inc r20   ;for loop operator
    rjmp loop_next
loop2:
    clr r19 
    clr r21
    ldi r19, 0x00 ;for PORTB output 
    ldi r21, 0x01 ;for shift left operator
loop2_next:
    cpi r20,0
    breq return 
    or r19,r21
    dec r20
    lsl r21 ;shift left 
    rjmp loop2_next
return:
    out PORTC, r19 ;output to portc
    
    pop r22
    pop r19
    pop r21
    pop r24
    out SREG, r24
    pop r24	    ;restore registers from stack
    
    reti




