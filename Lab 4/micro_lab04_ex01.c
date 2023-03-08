#define F_CPU 16000000UL //running
#include "avr/io.h"
#include<avr/interrupt.h>
#include<util/delay.h>

//given lcd functions written in C
void write_2_nibbles(char x)
{
	char y=PIND & 0x0f;
	char x1=x & 0xf0;
	x1=x1+y;
	PORTD=x1;
	PORTD=PORTD | (1<<PD3);
	PORTD=PORTD & (0<<PD3);
	x=x<<4 | x>>4;
	x=x & 0xf0;
	PORTD=x+y;
	PORTD=PORTD | (1<<PD3);
	PORTD=PORTD & (0<<PD3);
}

void lcd_data(char x)
{
	PORTD=PORTD | (1<<PD2);
	write_2_nibbles(x);
	_delay_us(40);
}

void lcd_command(char x)
{
	PORTD=PORTD | (0<<PD2);
	write_2_nibbles(x);
	_delay_us(40);
}

void lcd_init (void)
{
	_delay_ms(40);
	PORTD=0x30;
	PORTD=PORTD | (1<<PD3);
	PORTD=PORTD & (0<<PD3);
	_delay_us(38);
	PORTD=0x30;
	PORTD=PORTD | (1<<PD3);
	PORTD=PORTD & (0<<PD3);
	_delay_us(38);
	PORTD=0x20;
	PORTD=PORTD | (1<<PD3);
	PORTD=PORTD & (0<<PD3);
	_delay_us(38);
	lcd_command(0x28);
	lcd_command(0x0c);
	lcd_command(0x01);
	_delay_ms(500);
	lcd_command(0x06);
}
void lcd_print(unsigned char a, unsigned char b, unsigned char c)
{
    lcd_command(0x01);
    _delay_ms(3);
    lcd_data(a);
    lcd_data('.');
    lcd_data(b);
    lcd_data(c);    
}


int main()
{
    DDRD |= 0b11111111;  // output for LCD
    DDRC |= 0b00000000;  // input for ADC
    DDRB |= 0b11111111;  // output for counter
    
    ADMUX |= 0b01000010; //ADLAR=0 -> left adjusted, ADC2 INPUT
    ADCSRA |= 0b10000111; // disable adc interrupt
    unsigned int temp, counter=0;
    unsigned char akeraios, prwto, deutero;
    ADCSRA |= (1<<ADSC); //start ADC read
    lcd_init();
    while(1)
    {
        
        PORTB = counter;
        _delay_ms(20);
        if (counter > 63) 
        {
            counter = 0;
        }
        counter++;
        while ((ADCSRA & (1 << ADSC)) != 0) //stuck here till convertion ends (ADSC = 0)
        {
            
        }  
        temp = (ADC*5)/1024; //get value with 2-decimal accuracy
        akeraios = temp + '0';
        temp  = (((ADC*5)%1024)*10)/1024;
        prwto = temp +'0';
        temp  = ((((ADC*5)%1024)*10)%1024)*10/1024;
        deutero = temp +'0';
        lcd_print(akeraios, prwto, deutero);
        _delay_ms(500);
        ADCSRA |= (1<<ADSC);   //enable new conversion
        
    }
   
    return 0;
    
}
