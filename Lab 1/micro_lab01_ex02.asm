.include "m328PBdef.inc"

.def A=r22
.def B=r23
.def C=r24
.def D=r25
.def F0=r18
.def F1=r19
.def count=r17

loader:
    ldi A, 0x55 ;load initial values
    ldi B, 0x43
    ldi C, 0x22
    ldi D, 0x02
    ldi count, 0x00 ; counter for later
    
Func00: ;(B+D') -> for both functions
    com D
    mov r20, D
    com D ;return to initial state
    or r20, B ;r20=(B+D')
    
Func0: ;(A+B)*(B+D')
    mov r21,A
    or r21, B ;(A+B)
    and r21, r20 ;r21=r21*r20
    mov F0, r21 ;r18 for F0
    clr r21
Func1: ;(A+C)*(B+D')
    mov r21,A
    or r21, C ; (A+C)
    and r21,r20
    mov F1,r21
    clr r21
    clr r20
counter:
    inc count
    subi A, -2 ;increase variables
    subi B, -3
    subi C, -4
    subi D, -5
    cpi count, 0x06
    brne Func00
    

    
    
    
    
    
    
    

   




