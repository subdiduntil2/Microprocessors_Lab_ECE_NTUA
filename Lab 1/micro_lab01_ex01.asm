.include "m328PBdef.inc"
.equ c1 = 15 ; input msec delay

main:
   ldi r25,HIGH(c1) ; 1 clock cycle 
   ldi r24,LOW(c1) ; 1 clock cycle
   rcall loop
   rjmp main
    

;1 msec subroutine from lecture (actually produces 989usec delay) 
main_bef:
    rcall wait1m
    ret
wait4:
    ret ;4cycles
wait1m:
    ldi r26,98
loop_bef:
    rcall wait4 ;3 cycles (+4 = 7usec)
    dec r26 ;1 cycle
    brne loop_bef
    ret    
; end of subroutine


loop:
    rcall main_bef ;whole 1 loop delay at 1msec
    sbiw r24,1 ; 2 clock cycles
    nop ;1 cycle each
    nop
    brne loop
    ret



