#define F_CPU 16000000UL //checked
#include "avr/io.h"
#include <util/delay.h>
#include<avr/interrupt.h>

const int duty_arr[]={5,25,46,66,86,107,127,148,168,189,209,229,250};

int main() {
    unsigned char duty;
    unsigned int temp;
    unsigned int counter;
    
    //fast PWM mode and prescaler at 8
    TCCR1A = (1<<WGM10) | (1<<COM1A1);
    TCCR1B = (1<<WGM12) | (1<<CS11);
    
    sei(); // enable all interrupts
    
    DDRB |=0b00000010; //PB1 as output
    DDRD |=0b00000000;
    //PWM_init();
    duty=duty_arr[6];
    counter=6; //initialize counter
    OCR1A=duty;
    while(1){
        temp=PIND;
        if(temp==0xFB){
            counter++;
            if(counter<13){
                duty=duty_arr[counter];
                OCR1A=duty;
                _delay_ms(200);
            }
            else{
                counter=12;
                duty=duty_arr[counter];
                OCR1A=duty;
                _delay_ms(200);
            }
        }
        if(temp==0xFD){
            if (counter == 0){
                counter=0;
                duty=duty_arr[counter];
                OCR1A=duty;
                _delay_ms(200);
            }     
            if(counter>0){
                counter--;
                duty=duty_arr[counter];
                OCR1A=duty;
                _delay_ms(200);
            }
        }
    }         
}

