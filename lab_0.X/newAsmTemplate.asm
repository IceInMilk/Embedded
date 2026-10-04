; Assembly source line config statements
#include "p16f886.inc"

; CONFIG1
; __config 0x20D4
  __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
    
; CONFIG2
; __config 0x3EFF
  __CONFIG _CONFIG2, _BOR4V_BOR21V & _WRT_OFF
  
; Place variables and data below this line
MyVars	UDATA	0x70
; Currently no variables needed at this time
 
; Place code below this line
PwrOnRst    CODE    0x0	; Execution begins at address 0 after power on
    goto Main		; Branch to main to begin execution
 
IntVect	    CODE    0x4	; Interrupt code must be placed at address 0x4
    ; Left blank for now, there is not interrupts to service
    
UsrCode	    CODE	; User code space. Not providing an address allows the
			;   assembler to place it where it thinks most
			;   convenient
Main:
	; User code would go here

	banksel	ANSELH	; ANSELH is a Special Function Register (189h)
	clrf	ANSELH	; CLRF clears the contents of "ANSELH" and sets Z status bit
	; 0 = Digital I/O. Pin is assigned to port or special function
	banksel	TRISB	; TRISB IS A Special Function Register (86h)
	clrf	TRISB	; CLRF clears the contents of "TRISB" and sets Z status bit
	; clearing TRISB bit will make the corresponding PORTB pin an output. 
	; So we essentially made every bit 0 and all ports o/p
	banksel	PORTB	; PORTB is a Special Function Register (06h)
	clrf	PORTB	; CLRF clears the contents of "PORTB" and sets Z status bit
	bsf	PORTB, 0x0 ; bit 0x0 in Register "PORTB" is set
	
LoopForever:
	goto	LoopForever ; goto is an unconditional branch
	
	end

