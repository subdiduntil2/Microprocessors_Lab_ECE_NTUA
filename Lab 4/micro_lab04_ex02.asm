.include "m328PBdef.inc" ;running
 
.def temp = r18
.def ADC_L = r16
.def ADC_H = r17
.def flag = r19
 
.org 0x00 
    rjmp reset
.org 0x2A ;ADC Conversion Complete Interrupt
    rjmp ADC_inter

reset: 
    ldi temp, LOW(RAMEND)
    out SPL,temp
    ldi temp, HIGH(RAMEND)
    out SPH,temp
    
    clr temp
    ldi temp, 0xFF
    out DDRD, temp ;Set PORTD as output

    clr temp
    ldi temp, 0x00
    out DDRC, temp ;Set PORTC as input 
    
    clr temp
    ldi temp, 0xFF ;Set PORTB as output
    out DDRB, temp
    
    clr temp 
    out PORTB,temp ;set PORTB leds to zero
  
    
    ; REFSn[1:0]=01 => select Vref=5V, MUXn[4:0]=0011 => select ADC3(pin PC3),
    ; ADLAR=1 => Left adjust the ADC result
    clr temp
    ori temp, 0b01000011
    sts ADMUX, temp
    
    ; ADEN=1 => ADC Enable, ADCS=0 => No Conversion,
    ; ADIE=1 => enable adc interrupt, ADPS[2:0]=111 => fADC=16MHz/128=125KHz
    nop
    clr temp
    ori temp, 0b10001111
    sts ADCSRA, temp
    
    bset 7 ;set I flag
    sei
    
    clr r24
    rcall lcd_init
    
    nop
    ldi ADC_L,0x00 ;initialize CO registers
    ldi ADC_H,0x01
main:
    clr temp
    sts ADCSRA, temp
    ori temp, 0b11001111 ;enable interrupt
    sts ADCSRA,temp
    nop
    cpi ADC_H, 0x01 ;definetely over 70ppm
    brge GAS
    nop
    cpi ADC_L, 0xCD ;over 70ppm (205 ADC output)
    brlo NO_GAS
    rcall GAS
main_end:
    push r24							
    push r25
    ldi r24,low(100) ;0.1sec delay for next counter
    ldi r25,high(100)
    rcall wait_msec
    pop r25
    pop r24
    
    ldi temp,0b11000111 ; enable ADC interrupt
    sts ADCSRA,temp
    rjmp main
 
    
ADC_inter:
    in temp,SREG
    nop
    push temp
    clr ADC_L
    clr ADC_H
    lds ADC_L,ADCL ;get ADC value
    lds ADC_H,ADCH
    nop
    pop temp
    out SREG,temp
    nop
    reti
NO_GAS:
    rcall LCD_WRITE_GOOD
    nop
    ldi flag,0 
    rjmp BLINK
GAS:
    rcall LCD_WRITE_BAD
    nop
    cpi ADC_H,0 ;find level of gas
    breq LEVEL_1
    cpi ADC_H,1
    breq LEVEL_2
    cpi ADC_H,2
    breq LEVEL_3
    cpi ADC_H,3
    breq GAS_2
GAS_2:
    cpi ADC_L,63
    brge LEVEL_6
    cpi ADC_L, 15
    brge LEVEL_5
    cpi ADC_L,0
    brge LEVEL_4
    rjmp LEVEL_6
BLINK:
    out PORTB,flag
    nop
    push r24							
    push r25
    ldi r24,low(16*200) ;0.2 sec delay for blink delay
    ldi r25,high(16*200)
    rcall wait_msec
    pop r25
    pop r24
    
    clr temp
    out PORTB,temp
    ldi r24,low(16*200) ;0.2 sec delay for blink delay
    ldi r25,high(16*200)
    rcall wait_msec
    rjmp main_end
LEVEL_1: ;blink different 
    ldi flag,0x01
    rjmp BLINK  
LEVEL_2:
    ldi flag,3
    rjmp BLINK
LEVEL_3:
    ldi flag,7
    rjmp BLINK
LEVEL_4:
    ldi flag,15
    rjmp BLINK
LEVEL_5:
    ldi flag,31
    rjmp BLINK
LEVEL_6:
    ldi flag,63
    rjmp BLINK
    
LCD_WRITE_GOOD:
    ldi r24 ,0x01 ; //clear screen
    rcall lcd_command 
    //ldi r24,low(5) ;0.1sec delay for next counter
    //ldi r25,high(5)
    //rcall wait_msec
    
    
    ldi r24, 'C'
    rcall lcd_data
    ldi r24, 'L'
    rcall lcd_data  	 
    ldi r24, 'E'     
    rcall lcd_data    	
    ldi r24, 'A'
    rcall lcd_data
    ldi r24, 'R'
    rcall lcd_data  
    ret
LCD_WRITE_BAD:
    ldi r24 ,0x01 ; //clear screen
    rcall lcd_command
    //ldi r24,low(5) ;0.1sec delay for next counter
    //ldi r25,high(5)
    //rcall wait_msec
    
    ldi r24, 'G'
    rcall lcd_data
    ldi r24, 'A'
    rcall lcd_data 
    ldi r24, 'S'        
    rcall lcd_data
    ldi r24, ' '        
    rcall lcd_data
    ldi r24, 'D'
    rcall lcd_data 
    ldi r24, 'E'
    rcall lcd_data
    ldi r24, 'T'
    rcall lcd_data
    ldi r24, 'E'
    rcall lcd_data
    ldi r24, 'C'
    rcall lcd_data	
    ldi r24, 'T'
    rcall lcd_data
    ldi r24, 'E'
    rcall lcd_data
    ldi r24, 'D'
    rcall lcd_data
    ret
    
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
wait_msec: ;delay routine
    ldi r23,249
loop_inn:
    dec r23
    nop
    brne loop_inn

    sbiw r24,1
    brne wait_msec

    ret
;---------------------------------
wait_usec: ;delay routine
    ldi r23,200
loop_inn2:
    dec r23
    nop
    brne loop_inn2

    sbiw r24,1
    brne wait_usec

    ret