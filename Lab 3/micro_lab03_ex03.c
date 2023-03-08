#define F_CPU 16000000UL //checked
#include<avr/io.h>
#include<avr/interrupt.h>
#include<util/delay.h>

unsigned char duty;
unsigned int top;
unsigned int temp;

const int icr1_arr[]={15999,7999,3999,1999}; //output value on top



int main(){
    
    //fast PWM mode and prescaler at 8
    TCCR1A = (1<<WGM11)| (0<<WGM10) | (1<<COM1A1);
    TCCR1B = (1<<WGM12) | (1<<CS11) | (1<<WGM13);
    
    sei(); // enable all interrupts
    
    duty=128; //50% duty cycle
    DDRB |=0b00000010; //PB1 as output
    temp=0;
    OCR1AL=duty;
    asm("NOP");
    while(1){
        asm("NOP");
        temp=PIND;
        if(temp==0xFE){ //cases 
            OCR1A=duty;
            //_delay_ms(10);
            ICR1=icr1_arr[0];
        }
        else if(temp==0xFD){
            OCR1A=duty;
            //_delay_ms(10);
            ICR1=icr1_arr[1];
        }
        else if(temp==0xFB){
            OCR1A=duty;
            //_delay_ms(10);
            ICR1=icr1_arr[2];
        }
        else if(temp==0xF7){
            OCR1A=duty;
            //_delay_ms(10);
            ICR1=icr1_arr[3];
        }
        else if (temp==0xFF){
            OCR1A=0;
            //_delay_ms(10);
        }
}
}
