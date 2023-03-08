#define F_CPU 16000000UL //checked
#include "avr/io.h"
#include<avr/interrupt.h>
#include<util/delay.h>

unsigned int counter=0;


ISR(INT1_vect)
{
   //_delay_ms(50);
   TCNT1= 3035;
   PORTB = 0x01;
   counter++;
   if (counter > 1)
   {
       PORTB = 0xFF;
       _delay_ms(500);
       TCNT1 = 3035;
       PORTB = 0x01;
       
   }
}

ISR(TIMER1_OVF_vect)
{
    PORTB = 0;
    counter = 0;
}

void pc5_routine()
{
    PORTB = 0x01;
    _delay_ms(200); //for sparkle effect
    TCNT1 = 3035;           
    counter++;
}

void pc5_again()
{
    PORTB = 0xFF;
    _delay_ms(500);
    PORTB = 0x01;
    TCNT1 = 3035;
}

int main()
{
    EICRA = (1<<ISC11) | (1<<ISC10); //INT1-PD3
    EIMSK = (1 << INT1);             
    TCCR1B = (1<<CS12) | (0<<CS11) | (1<<CS10);  //prescale 1024
    TIMSK1 = (1<<TOIE1);
    sei(); // enable all interrupts
    DDRC = 0x00;
    DDRB = 0xFF;
    unsigned int pc5=0; 
    counter = 0;
    while(1)
    {
        pc5 = PINC;
        //asm("NOP");
        if (pc5 == 0x5F)  
        //if(pc5 == 0x20) //only for simulator
        {      
            pc5_routine();
            if (counter > 1)
            {
              pc5_again();
            }
            
           
        }
    }
    return 0;
}
