;*** HEADER **************************************************************************
#include "p16f886.inc"
;*************************************************************************************
    
;*** CONFIGURATIONS ******************************************************************
__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
__CONFIG _CONFIG2, _BOR4V_BOR21V & _WRT_OFF
;*************************************************************************************

;========================
; VARIABLES
;========================
UDATA 0x20
Delay1 RES 1
Delay2 RES 1

ledIN RES 1
val1 RES 1
val2 RES 1
ledOUT RES 1
state RES 1
display_val RES 1

;========================
; RESET VECTOR
;========================
ORG 0x0
    goto Main

ORG 0x4
ISR:
    BTFSS INTCON, RBIF
    RETFIE

    MOVF PORTB, W        ; clear mismatch

    BTFSC PORTB,5
    GOTO ISR_End

    MOVF state, W

    XORLW 0
    BTFSC STATUS,Z
    GOTO Store_First

    XORLW 1
    BTFSC STATUS,Z
    GOTO Store_Second

    GOTO Reset_All

;========================
Store_First:
    MOVF ledIN, W
    MOVWF val1

    CLRF ledIN
    
    CLRF display_val
    CALL Update_LEDs

    MOVLW 1
    MOVWF state
    GOTO ISR_End

;========================
Store_Second:
    MOVF ledIN, W
    MOVWF val2

    CALL Add_Function

    MOVF ledOUT, W
    MOVWF display_val
    CALL Update_LEDs

    MOVLW 2
    MOVWF state
    GOTO ISR_End

;========================
Reset_All:
    CLRF ledIN
    CLRF val1
    CLRF val2
    CLRF ledOUT
    CLRF display_val
    CALL Update_LEDs

    CLRF state
    GOTO ISR_End

ISR_End:
    BCF INTCON, RBIF
    CALL Delay
    RETFIE

;========================
; MAIN
;========================
Main:

; Disable analog
    banksel ANSEL
    clrf ANSEL
    banksel ANSELH
    clrf ANSELH

; Pullups for SW2
    banksel OPTION_REG
    bcf OPTION_REG,7
    banksel WPUB
    bsf WPUB,5

; SW1 input
    banksel TRISE
    movlw b'00001000'
    movwf TRISE

;========================
; GPIO INIT (FIXED STARTUP SEQUENCE)
;========================

; STEP 1: force safe output state immediately
    banksel PORTB
    clrf PORTB

; small stabilization delay
    call Delay

; STEP 2: set directions
    banksel TRISB
    movlw b'00100000'     ; RB5 input, RB0â??RB4 outputs
    movwf TRISB

; STEP 3: re-clear after TRIS takes effect
    banksel PORTB
    clrf PORTB

; STEP 4: dummy read to lock port state
    movf PORTB, W

; Enable IOC on RB5
    banksel IOCB
    bsf IOCB,5

    banksel INTCON
    bcf INTCON, RBIF
    bsf INTCON, RBIE
    bsf INTCON, GIE

; init vars
    banksel ledIN
    clrf ledIN
    clrf val1
    clrf val2
    clrf ledOUT
    clrf state
    clrf display_val

;========================
; MAIN LOOP
;========================
MainLoop:

    MOVF state, W
    XORLW 2
    BTFSC STATUS,Z
    GOTO MainLoop

    banksel PORTE
    BTFSC PORTE,3
    GOTO MainLoop

WaitRel1:
    BTFSS PORTE,3
    GOTO WaitRel1

    INCF ledIN,F

    MOVF ledIN,W
    XORLW 8
    BTFSC STATUS,Z
    CLRF ledIN

    MOVF ledIN,W
    MOVWF display_val
    CALL Update_LEDs

    CALL Delay
    GOTO MainLoop

;========================
; ADD FUNCTION
;========================
Add_Function:
    MOVF val1, W
    ADDWF val2, W
    MOVWF ledOUT
    RETURN

;========================
; LED DRIVER
;========================
Update_LEDs:

    banksel display_val
    movf display_val, W

    andlw 0x0F

    banksel PORTB
    movwf PORTB

    return

;========================
; DELAY
;========================
Delay:
    movlw d'200'
    movwf Delay1
D1:
    movlw d'255'
    movwf Delay2
D2:
    decfsz Delay2,f
    goto D2
    decfsz Delay1,f
    goto D1
    RETURN

END


