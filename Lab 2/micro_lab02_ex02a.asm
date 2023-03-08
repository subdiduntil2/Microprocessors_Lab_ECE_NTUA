.include "m328PBdef.inc" ;cleanly running
.equ FOSC_MHZ=16 ;operating freq of mC 
.equ DEL_mS=600; ;600msec delay
.equ DEL_NU=FOSC_MHZ*DEL_mS
    
;init stack pointer
ldi r24, LOW(RAMEND)
out SPL, R24
ldi r24, HIGH(RAMEND)
out SPH, r24

;PORTC as output
ser r26
out DDRC, r26

loop1:
    clr r26
loop2:
    out PORTC,r26
    
    ldi r24, low(DEL_NU)
    ldi r25, high(DEL_NU) ;set delay
    rcall delay_mS
    
    inc r26
    
    cpi r26, 32 ;compare r26 with 32
    breq loop1 ;restart if equal
    rjmp loop2 ;else start again
    
delay_mS: ;delay routine
    ldi r23,249
loop_inn:
    dec r23
    nop
    brne loop_inn
    
    sbiw r24,1
    brne delay_mS
    
    ret


