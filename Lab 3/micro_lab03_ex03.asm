.include "m328PBdef.inc" ;checked
.def freql=r19
.def freqh=r20
.def duty=r17
.def temp=r18
.equ FREQS=16 ;operating freq
.equ HALF_DUTY=128
    
reset:
    ;init stack pointer
    ldi r24, LOW(RAMEND)
    out SPL, r24
    ldi r24, HIGH(RAMEND)
    out SPH, r24
    
    ;fast PWM mode and prescaler=8
    ldi r25 ,(1<<WGM11)| (0<<WGM10) | (1<<COM1A1) 
    sts TCCR1A, r25
    
    ldi r26 ,(1<<WGM12) | (1<<CS11) | (1<<WGM13)
    sts TCCR1B, r26

    sei ;enable all interrupts
    
    ;set PB1 as output
    ldi r27, 0x02
    out DDRB, r27
    
    
    clr duty ;initialize d.c. at 50%
    clr r18
    rcall load_dc
    
    nop
    
main:
    in temp, PIND
    cpi temp, 0xFF ;check pushed PDi and change freq accordingly
    breq freq0
    cpi temp, 0xFE ;possibly needs reverse logic value
    breq freq1
    cpi temp, 0xFD
    breq freq2
    cpi temp, 0xFB
    breq freq3
    cpi temp, 0xF7
    breq freq4
    rjmp main

freq0:
    clr duty ;initialize d.c. at 50%
    clr r18
    rcall load_dc
    rjmp main
freq1:
    ldi duty, HALF_DUTY ;initialize d.c. at 50%
    clr r18
    rcall load_dc
    ldi freql,0x7F
    ldi freqh,0x3E
    rcall load_freq
    rjmp main
freq2:
    ldi duty, HALF_DUTY ;initialize d.c. at 50%
    clr r18
    rcall load_dc
    ldi freql,0x3F
    ldi freqh,0x1F
    rcall load_freq
    rjmp main
freq3:
    ldi duty, HALF_DUTY ;initialize d.c. at 50%
    clr r18
    rcall load_dc
    ldi freql,0x9F
    ldi freqh,0xF
    rcall load_freq
    rjmp main
freq4:
    ldi duty, HALF_DUTY ;initialize d.c. at 50%
    clr r18
    rcall load_dc
    ldi freql,0xCF
    ldi freqh,0x7
    rcall load_freq
    rjmp main
    
   
load_dc:
    sts OCR1AH, r18
    sts OCR1AL,duty
    ret
load_freq:
    sts ICR1H,freqh
    sts ICR1L,freql
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

    
    
