;***HEADER****************************************************************************
#include "p16f886.inc"
;*************************************************************************************
    
;***CONFIGURATIONS********************************************************************
; Configuration given from assembly template in canvas 
; Only care about clock config words...ignore everything else
; ** SHOULD NOT HAVE TO CHANGE CONFIGURATION **

; CONFIG1 --> IMPORTANT! CLOCK CONFIGURATIONS
; _FOSC_INTRC_NOCLKOUT --> config selected internal oscillator with OSC set to I/O
; __config 0x20D4 --> hex value that config1 is set to
__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
    
; CONFIG2 --> DON'T HAVE TO WORRY ABOUT FOR THIS CLASS
; __config 0x3EFF --> hex value that config2 is set to
__CONFIG _CONFIG2, _BOR4V_BOR21V & _WRT_OFF
;*************************************************************************************
    
;***CONSTANTS*************************************************************************
LED_MASK equ b'00001000'; RB3 or bit 3 
TIME_INNERS equ b'11111010'; Inner Loops (1 & 2) = 250
;*************************************************************************************
    
;***DEFINING VARIABLES****************************************************************
MyVars	UDATA 0x20	; shared memory loation that is accessible from all banks
			;   define file register for the delay loop in shared memory
x res 1			; makes a register of 1 address
y res 1
z res 1
;*************************************************************************************
    
    
;***START OF PROGRAM******************************************************************    
PwrOnRst    CODE    0x0	; Execution begins at address 0 after power on
    goto Init		; branch to main to begin execution
    
IntVect	    CODE    0x4	; Interrupt code 
			; no interrupt for this lab
			
UsrCode	    CODE	; no address specified so assembler places it where it
			;   thinks is most convienient
			
; Start of Subroutine Definitions
DelayLoop:		; return after delay for 0.5 seconds w/ Counter reg.
			; Ideal 1,000,000 instruction/cycles = 0.5 seconds
    movlw TIME_INNERS
    movwf x
    movlw TIME_INNERS
    movwf y
    movlw d'4'
    movwf z
Loop:
    nop
    decfsz x, f
    goto Loop
    movlw TIME_INNERS
    movwf x
    decfsz y, f
    goto Loop
    movlw TIME_INNERS
    movwf y
    decfsz z, f
    goto Loop
    return		; 
    
ToggleDS4:
    movlw LED_MASK	; load constant LED_MASK into w
    xorwf PORTB, f	; flip LED state using w reg
    return		
;*************************************************************************************


;***INIT PROGRAM**********************************************************************
Init:

    ;bsf STATUS, RP0	; Select mem. bank of containing osccon reg.
    banksel OSCCON
    movlw b'01110000'	; OSCCON/IRCF == 111 --> 8 MHz
    movwf OSCCON	; move contents of W reg into OSCCON
    
    ;clrf ANSEL
 
    
    banksel ANSELH	;
    clrf ANSELH		; set digital
    
    
    banksel TRISB	;
    clrf TRISB
    banksel PORTB	; select mem. bank that contains PORTB reg.
    clrf PORTB		; DS4 is initially off
    
    		; 
    
    goto Main		; After initializations use Main subroutine for 
			;   program execution control/flow
    
;*************************************************************************************

    
;***PROGRAM LOOP FOREVER**************************************************************
Main:
    call ToggleDS4		; flip LED state (on/off)
    call DelayLoop		; returns after ~ 0.5 seconds
    goto Main		; forever condition instruction
    
end			; end of program code
;*************************************************************************************


