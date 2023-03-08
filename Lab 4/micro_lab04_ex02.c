#define F_CPU 16000000UL // running
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

void LCD_WRITE_GOOD(){
    lcd_command(0x01);
    _delay_ms(3);
    lcd_data('C');
    lcd_data('L');
    lcd_data('E');
    lcd_data('A');
    lcd_data('R');
}

void LCD_WRITE_BAD() {
    lcd_command(0x01);
    _delay_ms(3);
    lcd_data('G');
    lcd_data('A');
    lcd_data('S');
    lcd_data(' ');
    lcd_data('D');
    lcd_data('E');
    lcd_data('T');
    lcd_data('E');
    lcd_data('C');
    lcd_data('T');
    lcd_data('E');
    lcd_data('D');
}

int main() {
    DDRD |=0b11111111; //I/O set
    DDRC |=0b00000000;
    DDRB |=0b11111111;
    
    ADMUX |= 0b01000011; //ADLAR=0 -> left adjusted 
    ADCSRA |=0b10000111; // ADC enable + enable interrupt
    
    lcd_init(); //initialize lcd screen
    unsigned int temp=0;
    unsigned int lvl=0;
    
    while(1){
        //enable interrupt
        while ((ADCSRA & (1 << ADSC)) != 0) //stuck here till conversion ends (ADSC = 0)
        {
            
        }
        temp=ADC;
        if((temp>=0) & (temp<215)){ //find different levels of gas
            lvl=0;
            LCD_WRITE_GOOD();
        }
        if((temp>=215) & (temp<256)){
            lvl=1;
            LCD_WRITE_BAD();
        }
        if((temp>=256) & (temp<512)){
            lvl=3;
            LCD_WRITE_BAD();
        }
        if((temp>=512) & (temp<768)){
            lvl=7;
            LCD_WRITE_BAD();
        }
        if((temp>=768) & (temp<783)){
            lvl=15;
            LCD_WRITE_BAD();
        }
        if((temp>=783) & (temp<831)){
            lvl=31;
            LCD_WRITE_BAD();
        }
        if((temp>=831) & (temp<1024)){
            lvl=63;
            LCD_WRITE_BAD();
        }
        PORTB = lvl; //blink according to the measured gas level
        _delay_ms(200); 
        PORTB = 0x00;
        _delay_ms(200);
        ADCSRA |= (1<<ADSC);   //enable new conversion
    }
}