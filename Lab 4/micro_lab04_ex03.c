#define F_CPU 16000000UL  //running
#include<avr/io.h>
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

void lcd_init_2 (void) { //skips screen clear with 0x01 instruction
	_delay_ms(2);
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
	_delay_ms(1);
	lcd_command(0x06);  
}


void lcd_print_2(unsigned char a, unsigned char b, unsigned char c){
    lcd_command(0xC0); //start writing from initial address of second lcd line
    _delay_ms(3);
    lcd_data(a);
    lcd_data('.');
    lcd_data(b);
    lcd_data(c);    
}

void adc_display(void)
{
    unsigned int temp2;
    unsigned char akeraios, prwto, deutero;
    temp2 = (ADC*5)/1024; //ADC 2-decimal conversion 
    akeraios = temp2 + '0';
    temp2  = (((ADC*5)%1024)*10)/1024;
    prwto = temp2 +'0';
    temp2  = ((((ADC*5)%1024)*10)%1024)*10/1024;
    deutero = temp2 +'0';
    lcd_print_2(akeraios, prwto, deutero); //to print on the second row
    _delay_ms(700);
}
int main(){
    
    //fast PWM mode and pre-scaler at 8
    TCCR1A = (1<<WGM11)| (0<<WGM10) | (1<<COM1A1);
    TCCR1B = (1<<WGM12) | (1<<CS11) | (1<<WGM13);
    
    DDRD |= 0b11111111;  // output for LCD
    DDRC |= 0b00000000;  // input for ADC
    DDRB |= 0b00000010;  // output for counter
    
    ADMUX |= 0b01000001; //ADLAR=0 -> left adjusted
    ADCSRA |=0b10000111; // ADC enable + enable interrupt

    ICR1=399;
    lcd_init();
    unsigned int temp=0;  
    
    while(1){
        asm("NOP");
        temp=~PINB;
        /*while ((ADCSRA & (1 << ADSC)) != 0) //stuck here till converion ends (ADSC = 0)
        {
            
        }*/
        temp=PINB;
        asm("NOP");
        if(temp==0xB9){ //cases 
            asm("NOP");
            OCR1A=51+20; //duty
            ICR1=399; //frequency
            lcd_command(0x01);
             _delay_ms(3);
            lcd_data(2+'0');
            lcd_data(0+'0');
            lcd_data('%');
            while ((ADCSRA & (1 << ADSC)) != 0){}
            adc_display();
            temp=PINB;
            
        }
        if(temp==0xB5){
            OCR1A=102+40;
            ICR1=399;
            lcd_command(0x01);
             _delay_ms(3);
            lcd_data(4+'0');
            lcd_data(0+'0');
            lcd_data('%');
            while ((ADCSRA & (1 << ADSC)) != 0){}
            adc_display();
        }
        if(temp==0xAD){
             OCR1A=153+70;
             ICR1=399;
             lcd_command(0x01);
             _delay_ms(3);
             lcd_data(6+'0');
             lcd_data(0+'0');
             lcd_data('%');
             while ((ADCSRA & (1 << ADSC)) != 0){}
             adc_display();
        }
        if(temp==0x9D){
            OCR1A=320; 
            ICR1=400;
            lcd_command(0x01);
            _delay_ms(3);
            lcd_data(8+'0');
            lcd_data(0+'0');
            lcd_data('%');
            while ((ADCSRA & (1 << ADSC)) != 0){}
            adc_display();
        }
        if(temp==0xBD){
            OCR1A=1;
            lcd_command(0x01);
            _delay_ms(3);
            lcd_data(0+'0');
            lcd_data(0+'0');
            lcd_data('%');
            while ((ADCSRA & (1 << ADSC)) != 0){}
            adc_display();
        }
        lcd_command(0x01);
        _delay_ms(3);
        
        ADCSRA |= (1<<ADSC);   //enable new conversion
}
    return 0;
}

