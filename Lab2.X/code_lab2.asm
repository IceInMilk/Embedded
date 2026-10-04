#include "p16f886.inc"

  __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
    
  __CONFIG _CONFIG2, _BOR4V_BOR21V & _WRT_OFF
  
MyVars	UDATA 0x20

PressDelay0 res 1
PressDelay1 res 1
 
PwrOnRst    CODE    0x0
    goto Main
 
IntVect	    CODE    0x4
    
UsrCode	    CODE

Delay_Loop:
    nop
    decfsz PressDelay0, 0x1
    goto Delay_Loop
    
    movlw 0xFA
    movwf PressDelay0
    decfsz PressDelay1, 0x1
    goto Delay_Loop
    
    movlw 0xFA
    movwf PressDelay1
    nop
    return

Main:
    ; User code would go here
    
    ; RE3 for sw1
    ; Needs to be I/P
    ; init PORTE
    banksel PORTE
    clrf PORTE
    banksel ANSEL
    clrf ANSEL
    banksel TRISE
    movlw b'00001000'
    movwf TRISE
    
    ; init PORTB
    banksel ANSELH
    clrf ANSELH

    banksel TRISB
    clrf TRISB
    ; sw2 for i/p
    ;movlw b'00100000'
    ;movwf TRISB
    ; bsf TRISB, 0x5
	
    banksel PORTB
    clrf PORTB
    
    



Loop:

; Wait for button press (active low)
WaitPress:
    btfsc PORTE, 3
    goto WaitPress

    ; debounce delay
    movlw 0xFA
    movwf PressDelay0
    call Delay_Loop

    ; toggle LED on RB0
    movlw b'00000001'
    xorwf PORTB, f

; Wait for button release
WaitRelease:
    btfss PORTE, 3
    goto WaitRelease

    ; debounce delay
    movlw 0xFA
    movwf PressDelay0
    call Delay_Loop
    goto Loop
end


