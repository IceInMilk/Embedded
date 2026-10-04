#include "p16f886.inc"
    
    __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF &
_MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
    __CONFIG _CONFIG2, _BOR4V_BOR21V & _WRT_OFF
    
UDATA 0x20
Delay1 RES 1
Delay2 RES 1
Flags RES 1
ORG 0x0
    goto Main
ORG 0x4
    goto ISR
    
Main:
; Disable analog
    banksel ANSEL
    clrf ANSEL
    banksel ANSELH
    clrf ANSELH
; Enable PORTB pullups for SW2 (RB5)
    banksel OPTION_REG
    bcf OPTION_REG,7
    banksel WPUB
    bsf WPUB,5
; RB5 input, RB0?RB3 outputs for LEDs
    banksel TRISB
; RB5 input, others output
    movlw b'00100000'
    movwf TRISB
    
    ; Clear LEDs
    banksel PORTB
    clrf PORTB
; Enable Interrupt-on-Change for PORTB
    banksel IOCB
; interrupt on RB5 change
    bsf IOCB,5
    banksel INTCON
; clear flag
    bcf INTCON,RBIF
; enable RB change interrupt
    bsf INTCON,RBIE
; global interrupt enable
    bsf INTCON,GIE
; Startup
    
    ; DS4 initially OFF, then ON after delay
    call Delay_Long
; DS4 ON (idle state)
    bsf PORTB,3
MainLoop:
    goto MainLoop
; Interrupt Service Routine
ISR:
    banksel INTCON
    btfss INTCON,RBIF
    retfie
    
    
; Sequence starts
    banksel PORTB
; turn DS4 OFF
    bcf PORTB,3
; DS1 blink
    bsf PORTB,0
    call Delay_Short
    bcf PORTB,0
; DS2 blink
    bsf PORTB,1
    call Delay_Short
    bcf PORTB,1
; DS3 blink
    bsf PORTB,2
    call Delay_Short
    bcf PORTB,2
    
    
    ; DS4 blink
    bsf PORTB,3
    call Delay_Short
    bcf PORTB,3
; Return to idle state with DS4 ON
    bsf PORTB,3
; Clear mismatch condition so the progam doesn;t immediately loop again
    movf PORTB,W
    banksel INTCON
    bcf INTCON,RBIF
    retfie

Delay_Short:
    movlw d'120'
    movwf Delay1
DS_L1:
    movlw d'255'
    movwf Delay2
DS_L2:
    decfsz Delay2,f
    goto DS_L2
    decfsz Delay1,f
    goto DS_L1
    return
Delay_Long:
    movlw d'200'
    movwf Delay1
DL_L1:
    movlw d'255'
    movwf Delay2
DL_L2:
    decfsz Delay2,f
    goto DL_L2
    decfsz Delay1,f
    goto DL_L1
    return
END


