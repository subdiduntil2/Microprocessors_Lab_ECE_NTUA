#define F_CPU 16000000UL //running
#include<avr/io.h>
#include<avr/interrupt.h>
#include<util/delay.h>
#include<math.h>

int _sign;  //for sign of temperature
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
	_delay_us(50);
}

void lcd_command(char x)
{
	PORTD=PORTD | (0<<PD2);
	write_2_nibbles(x);
	_delay_us(50);
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

unsigned int one_wire_reset(void)
{
    unsigned int x=0;
    DDRD |= (1<<PD4); //set PD4 as output
    PORTD &= (0<<PD4);
    _delay_us(480);
    DDRD &= (0<<PD4); //set PD4 as input
    PORTD &= (0<<PD4); //disable pull-up
    asm("nop");
    _delay_us(100);
    x = PIND;
    x = x >>4;
    asm("nop");
    _delay_us(380);
    asm("nop");
    if ((x & 0x01) == 0x01) return 0;
    else return 1;   //not connected device
}

unsigned int one_wire_receive_bit (void)
{
    uint8_t x;
    DDRD |= (1<<PD4); //set PD4 as output
    PORTD &= (0<<PD4);
    _delay_us(2);
    DDRD &= (0<<PD4);
    PORTD &= (0<<PD4);
    _delay_us(10);
    x = PIND;
    x &= 0x10;
    x = x >> 4;    
    _delay_us(49);
    return x;
}

void one_wire_transmit_bit (unsigned int y)
{
    DDRD |= (1<<PD4); //set PD4 as output
    PORTD &= (0<<PD4);
    _delay_us(2);
    if (y == 1) PORTD |= (1<<PD4);
    _delay_us(58);
    DDRD &= (0<<PD4);
    PORTD &= (0<<PD4);
    _delay_us(1);   //recovery time
}

unsigned int one_wire_receive_byte (void)
{
    unsigned int value=0, x = 0;
    for (int i=0; i<8; i++)
    {
        value = value >> 1;
        x = one_wire_receive_bit();
        if (x == 1) value |= 0x80;  
    }
    return value;
}

void one_wire_transmit_byte (unsigned int z)
{
    for (int i=0; i<8; i++)
    {
        one_wire_transmit_bit (z & 0x01);
        z = z >> 1;
    }
}

int _temperature_value (void)
{
    int value_H=0, value_L=0, x;
    x = one_wire_reset();
    if (x==0) return 0x8000;
    one_wire_transmit_byte (0xCC);
    one_wire_transmit_byte (0x44);
    x = 0;
    while (x == 0) 
    {
        x = one_wire_receive_bit();
    }
    x = one_wire_reset();
    if (x==0) return 0x8000;
    one_wire_transmit_byte (0xCC);
    one_wire_transmit_byte (0xBE);
    value_L = one_wire_receive_byte();
    value_H = one_wire_receive_byte();
    asm("nop");
    int temp2 = value_H & 0xF8;
    if (temp2 == 0xF8) _sign = 1;   //negative value
    value_L &= 0xFF;        //isolate the 8 LSB
    value_H &= 0x07;        //discard sign bits
    value_H = value_H << 8; //shift bits 0-2 to position 8-10
    value_L |= value_H; //and combine the value in the 16bit variable
    return value_L;
    
}


void fix_temp_for_lcd(int a, int sign)
{
    DDRD |= 0b11111111;
    lcd_init();
    int number1=0, number2=0, number3=0, check = 0;
    float dec=0;
    if (sign)
    {
        lcd_data('-');
        a = (~a) + 1;   //2 complement
        a &= 0x7FF;
    }
    for (int i=4; i>0; i--)
    {
        check = a & 0x01;
        if (check == 1) dec += 1/(pow(2,i));
        asm("nop");
        a = a >> 1;
        check = 0;  
        asm("nop");
    }
    number1 = a/100;  
    if (number1 == 1) lcd_data(number1 + '0');
    asm("nop");
    number2 = (a-(number1*100))/10;
    _delay_ms(10);
    if (number2!=0) lcd_data(number2 + '0');
    asm("nop");
    number3 = a-(number1*100 + number2*10);
    _delay_ms(10);    
    lcd_data(number3 + '0'); 
    asm("nop");
    if(dec!=0) {
        lcd_data('.');
        for (int i=0; i<4; i++)
        {
            check = dec*10;
            _delay_ms(10);
            if (check != 0) lcd_data (check + '0');
            dec = dec*10 - (float)check;
            _delay_ms(10);
        }
    }
}

void zero_temp(void)
{
    DDRD |= 0b11111111;
    lcd_init();
    lcd_data ('0');
    lcd_data ('0');
    lcd_data ('.');
    lcd_data ('0');
    lcd_data(' ');
    lcd_data('°');
    lcd_data('C');
}

void no_dev(void)
{
    DDRD |= 0b11111111;
    lcd_init();
    lcd_data ('N');
    lcd_data ('O');
    lcd_data (' ');
    lcd_data ('D');
    lcd_data ('e');
    lcd_data ('v');
    lcd_data ('i');
    lcd_data ('c');
    lcd_data ('e');
}

int main(void)
{
    asm("nop");
    int temp = 0;
    
    while(1)
    {
        _delay_ms(1500);
        _sign = 0;
        temp = _temperature_value();
        asm("nop");
        if (temp == 0) 
        {
            zero_temp();
            continue;
        }
        if (temp == 0x8000) 
        {
            no_dev();
            continue;
        }
        fix_temp_for_lcd(temp, _sign);  //negative value
    }    
    return 0;
}
