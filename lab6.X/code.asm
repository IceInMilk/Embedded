;***HEADER****************************************************************************
#include "p16f886.inc"
;*************************************************************************************
    
;***CONFIGURATIONS********************************************************************
; CONFIG1 --> IMPORTANT! CLOCK CONFIGURATIONS
; _FOSC_INTRC_NOCLKOUT --> config selected internal oscillator with OSC set to I/O
; __config 0x20D4 --> hex value that config1 is set to
__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
    
; CONFIG2 --> DON'T HAVE TO WORRY ABOUT FOR THIS CLASS
; __config 0x3EFF --> hex value that config2 is set to
__CONFIG _CONFIG2, _BOR4V_BOR21V & _WRT_OFF
;*************************************************************************************
    
;***CONSTANTS*************************************************************************
LED_MASK equ b'00001000'    ; RB3 or bit 3 
START_TICK equ b'00001010'  ; == 10(decimal)
;*************************************************************************************
    
;***DEFINING VARIABLES****************************************************************
MyVars	UDATA 0x20	; shared memory loation that is accessible from all banks

w_temp res 1
status_temp res 1
pclath_temp res 1
;*************************************************************************************

;***START OF PROGRAM******************************************************************    
PwrOnRst CODE 0x0	; Execution begins at address 0 after power on
    goto Init		; branch to main to begin execution
;*************************************************************************************

;************************ INTERRUPT ROUTINE ******************************************
IntVect CODE 0x4	; Interrupt code 
 
    movwf w_temp         ; Save register W
    movf STATUS          ; Save register STATUS
    movwf status_temp
    movf PCLATH          ; Save register PCLATH
    movwf pclath_temp
 
    ; flip LED
    movlw LED_MASK	; load constant LED_MASK into w
    xorwf PORTB, f	; flip LED state using w reg
    
    ; clear the Timer 0 interrupt flag
    banksel INTCON      ; Selects bank containing INTCON
    bcf INTCON,TMR0IF   ; Clears interrupt flag TMR0IF
    
    ; set the TMR0 register back to the starting tick value
    banksel TMR0	;
    movlw START_TICK	;
    movwf TMR0		; 
    
    movf pclath_temp,w   ; PCLATH is given its original content
    movwf PCLATH
    movf status_temp,w   ; STATUS is given its original content
    movwf STATUS
    swapf w_temp,f        ; W is given its original content
    swapf w_temp,w
    
    bsf INTCON,GIE      ; Global interrupt enabled
    retfie		; return from interrupt routine
;*************************************************************************************
 
;***SUBROUTINES***********************************************************************
UsrCode	    CODE	; no address specified so assembler places it where it
			;   thinks is most convienient
;*************************************************************************************

;***INIT PROGRAM**********************************************************************
Init:
    ; system clock config
    banksel OSCCON	;
    movlw b'00000000'	; OSCCON/IRCF<bits 6-4> == 000 --> 31 kHz ~= 32 kHz
    movwf OSCCON	; move contents of W reg into OSCCON
 
    ; timer0 config
    ; init val = 10
    banksel TMR0	;
    movlw START_TICK	;
    movwf TMR0		;
    ; interrupt on overflow
    banksel INTCON      ; Bank containing register INTCON
    bsf INTCON,TMR0IE   ; TMR0 interrupt overflow enabled
    bsf INTCON,GIE      ; Global interrupt enabled
    ; change prescaler WDT --> TIMER0
    clrwdt		; clear WDT & prescaler
    banksel OPTION_REG	; 
    movlw b'11010000'	; mask TMR0 select & prescaler bits
    andwf OPTION_REG, w	; 
    iorlw b'00000011'	; set prescaler to 1:16
    movwf OPTION_REG	;
    
    ; DS4 A.K.A RB3 config
    banksel ANSELH	;
    clrf ANSELH		; set PORTB pins to digital
    banksel TRISB	;
    clrf TRISB		; all PORTB pins are output
    banksel PORTB	; 
    clrf PORTB		; DS4 is initially off

    goto Main		; After initializations use Main subroutine for 
			;   program execution control/flow
;*************************************************************************************

    
;***PROGRAM LOOP FOREVER**************************************************************
Main:
    goto Main		; forever condition instruction
end			; end of program code
;*************************************************************************************
			