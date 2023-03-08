.include "m328PBdef.inc" ;running

.def VinL=r18
.def VinH=r19	
.def counter=r20
.def ADC_L=r21
.def ADC_H=r22	
.def temp=r23	
 
.org 0x00
    jmp reset
.org 0x02A
    jmp ISR_ADC
    
reset:
    ldi r24, high(RAMEND)
    out SPH, r24
    ldi r24, low(RAMEND)
    out SPL, r24
   
    ;io configuration
    clr r24
    out DDRC, r24   ;input for ADC
    ser r24
    out DDRB, r24   ;output for counter
    out DDRD, r24   ;output for LCD
    
    ;ADC configuration
    ldi r24, 0b01000010
    sts ADMUX, r24
    ldi r24, 0b10001111
    sts ADCSRA, r24  
    sei
    
main:
    clr r24
    rcall lcd_init ;initialize lcd
    ldi r24, LOW(16*20)
    ldi r25, HIGH(16*20)
    rcall wait_msec
      
loop1: ;for PORTB counter
    clr counter
loop2:
    out PORTB, counter
    ldi r24, low(16*300)
    ldi r25, high(16*300)
    rcall wait_msec
    inc counter
    cpi counter, 63
    
    ;enable ADC
    lds r24, ADCSRA
    ori r24, (1<<ADSC)
    sts ADCSRA, r24
    
    breq loop1
    rjmp loop2
       
ISR_ADC:
    push r24
    out SREG, r24
    push r24
    push r25
    
    ldi r24, 0x01   ;clear lcd
    rcall lcd_command
    ldi r24, LOW(5)
    ldi r25, HIGH(5)
    rcall wait_msec
    
    lds ADC_L, ADCL
    lds ADC_H, ADCH
        
    ;Vin=(ADC*5)/2^10
    mov VinL, ADC_L
    mov VinH, ADC_H
    lsl VinL
    rol VinH
    lsl VinL
    rol VinH
    add VinL, ADC_L
    adc VinH, ADC_H ;Vin=ADC*5
    
    ;for /1024 => shift right Vin 10 times
    ;but for integer of /1024 we just need bit 10-13
    mov temp, VinH
    lsr temp
    lsr temp
    andi temp, 0x0F
    
    mov r24, temp
    ldi temp, 0x30  ;add '0' for lcd (ASCII code)
    add r24, temp
    rcall lcd_data
    //ldi r24, LOW(16*200)
    //ldi r25, HIGH(16*200)
    //rcall wait_msec
    
    ldi r24, '.'
    rcall lcd_data
    //ldi r24, LOW(16*200)
    //ldi r25, HIGH(16*200)
    //rcall wait_msec
    
    ;for first demical Vin*10 and take bit 10-13
    andi VinH, 0x03 ;we dont need the bits that we used for integer
    mov ADC_L, VinL
    mov ADC_H, VinH 
    lsl VinL ;for Vin*10 we shift left Vin 3 times (2^3=8)
    rol VinH ;and we add 2 times the original Vin to the shifted
    lsl VinL ;
    rol VinH ; 
    lsl VinL ;
    rol VinH ;  
    add VinL, ADC_L
    adc VinH, ADC_H   
    add VinL, ADC_L   
    adc VinH, ADC_H 
    
    mov temp, VinH
    lsr temp
    lsr temp
    andi temp, 0x0F
    
    mov r24, temp
    ldi temp, 0x30  ;add '0' for lcd (ASCII code)
    add r24, temp
    rcall lcd_data
    //ldi r24, LOW(16*200)
    //ldi r25, HIGH(16*200)
    //rcall wait_msec
    
    ;same procedure for the second demical
    andi VinH, 0x03 
    mov ADC_L, VinL
    mov ADC_H, VinH 
    lsl VinL 
    rol VinH 
    lsl VinL ;
    rol VinH ;
    lsl VinL ;
    rol VinH ;  
    add VinL, ADC_L
    adc VinH, ADC_H   
    add VinL, ADC_L   
    adc VinH, ADC_H 
    
    mov temp, VinH
    lsr temp
    lsr temp
    andi temp, 0x0F
    
    mov r24, temp
    ldi temp, 0x30  ;add '0' for lcd (ASCII code)
    add r24, temp
    rcall lcd_data
    //ldi r24, LOW(16*200)
    //ldi r25, HIGH(16*200)
    //rcall wait_msec
    
    //ldi r24, 0x01   ;clear lcd
    //rcall lcd_command
    //ldi r24, LOW(16*200)
    //ldi r25, HIGH(16*200)
    //rcall wait_msec
   
    pop r25
    pop r24
    in r24, SREG
    pop r24
    reti
       
    
;---------------------------------------------------    
    
write_2_nibbles:  ;write data (first 4MSB and next 4LSB)
    push r24 
    in r25 ,PIND 
    andi r25 ,0x0f 
    andi r24 ,0xf0 
    add r24 ,r25 
    out PORTD ,r24 
    sbi PORTD ,3 
    cbi PORTD ,3 
    pop r24 
    swap r24 
    andi r24 ,0xf0 
    add r24 ,r25
    out PORTD ,r24
    sbi PORTD ,3 
    nop
    nop
    cbi PORTD ,3
    nop
    nop
    ret
;---------------------------------------------
lcd_data: ;send one byte of data
    sbi PORTD ,2 
    rcall write_2_nibbles 
    ldi r24 ,43 
    ldi r25 ,0 
    rcall wait_usec
    ret
;------------------------------------------------
lcd_command: ;send instruction to lcd controller
    cbi PORTD ,2 
    rcall write_2_nibbles 
    ldi r24 ,43 
    ldi r25 ,0 
    rcall wait_usec 
    ret
 ;----------------------------------------------   
lcd_init: ;initialize lcd 
    ldi r24 ,40 
    ldi r25 ,0 
    rcall wait_msec 
    ldi r24 ,0x30 
    out PORTD ,r24 
    sbi PORTD ,3 
    cbi PORTD ,3 
    ldi r24 ,100
    ldi r25 ,0 
    rcall wait_usec 
    ldi r24 ,0x30 
    out PORTD ,r24
    sbi PORTD ,3
    cbi PORTD ,3
    ldi r24 ,100
    ldi r25 ,0
    rcall wait_usec 
    ldi r24 ,0x20 ; 4-bit mode
    out PORTD ,r24
    sbi PORTD ,3
    cbi PORTD ,3
    ldi r24 ,100
    ldi r25 ,0
    rcall wait_usec 
    ldi r24 ,0x28
    rcall lcd_command 
    ldi r24 ,0x0c 
    rcall lcd_command 
    ldi r24 ,0x01 
    rcall lcd_command
    ldi r24 ,low(5000)
    ldi r25 ,high(5000)
    rcall wait_usec 
    ldi r24 ,0x06 ;
    rcall lcd_command 
    ret
;-------------------------------------
wait_msec: ;delay routine in ms
    ldi r23,249
loop_inn:
    dec r23
    nop
    brne loop_inn

    sbiw r24,1
    brne wait_msec

    ret
;---------------------------------
wait_usec: ;delay routine in us
    ldi r23,200
loop_inn2:
    dec r23
    nop
    brne loop_inn2

    sbiw r24,1
    brne wait_usec

    ret



