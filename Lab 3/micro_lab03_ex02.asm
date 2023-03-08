.include "m328PBdef.inc" ;checked
.def counter=r19
.def duty=r20
.def temp=r18
.equ FREQ=16 ;operating freq 
    
reset:
    ;init stack pointer
    ldi r24, LOW(RAMEND)
    out SPL, r24
    ldi r24, HIGH(RAMEND)
    out SPH, r24
    
    ;fast PWM mode and prescaler=8
    ldi r25 ,(1<<WGM10) | (1<<COM1A1) 
    sts TCCR1A, r25
    
    ldi r25 ,(1<<WGM12) | (1<<CS11) 
    sts TCCR1B, r25
    
    sei ;enable all interrupts
    
    ;set PB1 as output
    ldi r27, 0x02
    out DDRB, r27
    
    nop
    
    ldi counter, 4 ;initialize variables and d.c.
    rcall load_dc
    
    nop
    
main:
    in temp, PIND
    cpi temp, 0xFD ;check for PD1 ;possibly needs reverse logic value
    breq incr
    cpi temp, 0xFB ;check for PD2 ;possibly needs reverse logic value
    breq decr
    
    rjmp main
 
incr:
    cpi counter, 12 ;check if index exceeds 12
    breq incr_sp
    inc counter
    rcall load_dc ;load dc value
    rjmp main

incr_sp:
    ldi counter,12
    rcall load_dc ;load dc value
    rjmp main

decr:
    cpi counter, 0 ;check if index exceeds 0
    breq decr_sp
    dec counter
    rcall load_dc ;load dc value
    rjmp main

decr_sp:
    ldi counter,0
    rcall load_dc ;load dc value
    rjmp main
   
load_dc:
    ldi Zh, HIGH(Table*2) ;multiply by 2 for byte access
    ldi Zl, LOW(Table*2)
    clr r18
    add zl, counter ;access table value by index
    adc zh, r18
    lpm ; rz to r0
    mov r22,r0
    sts OCR1AL,r22
    sts OCR1AH,r18
    ldi r24, low(FREQ*200) ;then wait for 50ms
    ldi r25, high(FREQ*200)
    rcall delay_mS ;delay 50ms
    ret
 
delay_mS: ;create ms delay
    ldi r23,249
loop_inn:
    dec r23
    nop
    brne loop_inn
    
    sbiw r24,1
    brne delay_mS
    
    ret

;c values -> {5,25,46,66,86,107,127,148,168,189,209,229,250}
Table:
.DW 0x1905,0x422E,0x6B56,0x947F,0xBDA8,0xE5D1,0xFAFA 


