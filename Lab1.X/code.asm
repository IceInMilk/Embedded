#include "p16f886.inc"

  __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
    
  __CONFIG _CONFIG2, _BOR4V_BOR21V & _WRT_OFF
  
MyVars	UDATA 0x20

PressDelay res 1

PwrOnRst    CODE    0x0
    goto Main
 
IntVect	    CODE    0x4
    
UsrCode	    CODE



Main:
	; User code would go here

    banksel ANSELH
    clrf ANSELH

    banksel TRISB
    ; clrf TRISB
    movlw b'00100000'
    movwf TRISB
    ; bsf TRISB, 0x5
	
    banksel PORTB
    clrf PORTB




Loop:

; Wait for button press (active low)
WaitPress:
    btfsc PORTB, 5
    goto WaitPress

    ; debounce delay
    movlw d'200'
    movwf PressDelay
Debounce1:
    decfsz PressDelay, f
    goto Debounce1

    ; confirm still pressed
    ; this may not be needed...
    ;btfsc PORTB, 5
    ;goto Loop

    ; toggle LED on RB3
    movlw b'00001000'
    xorwf PORTB, f

; Wait for button release
WaitRelease:
    btfss PORTB, 5
    goto WaitRelease

    ; debounce delay
    movlw d'200'
    movwf PressDelay
Debounce2:
    decfsz PressDelay, f
    goto Debounce2

    goto Loop

end