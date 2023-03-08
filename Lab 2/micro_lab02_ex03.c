#define F_CPU 16000000UL
#include<avr/io.h>
#include<avr/interrupt.h>
#include<util/delay.h> //cleanly running

unsigned char counter=0;
void delay_manual(unsigned int);
unsigned int c=0;
unsigned int a=0;
unsigned int b=0;
unsigned int flag=0;
unsigned int r23;
unsigned int r24;



ISR(INT1_vect) {
    while( INTF0 == 1) { //sparkling effect
        EIFR = (1<<INTF0);
        _delay_ms(5);   
    }
    flag=1; //check interrupt on delay routine
    counter++; //counter of interrupts 
}

void delay_manual(unsigned int ms){
    c=0;
    r23=500; //needs to change for test on board
    r24=ms; 
    flag=0;
    while(r24>0){
        if (flag==1) { 
            break;
        }
        else{
            for (int i=0; i<r23; i++) {
                if (flag==1){
                    break;
                }
                else {
                    c++; //dummy instructions to create delay
                    PORTC=0x32;
                }
            }
        }
        r24--;
    }
}


int main(){
    
    EICRA=(1<<ISC11) | (1<<ISC10); //INT1-PD3
    EIMSK = (1 << INT1);           
    sei(); // enable all interrupts
    
    DDRB=0xFF; //main output
    DDRC=0xFF; //outputs
    while(1){
        asm("NOP");
        flag=0;
        if(counter==1){
            PORTB=0x01; //lsb of portb flashed6
            delay_manual(4000);
            if (flag==1) {
                break;
            }
            else{
                counter=0;
            }
            counter=0;
        }
        if (counter>1){
             PORTB=255;
             delay_manual(500); //flash all pins for 0.5sec
             PORTB=0x01;
             delay_manual(4000); //flash only LSB for 4sec
             if (flag==1) {
                break;
            }
            else{
                counter=0; //clear counter
            }
             counter=0;
        }
        PORTB=0x00;
    }
    main();
}
