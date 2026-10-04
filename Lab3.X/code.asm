#include "p16f886.inc"

  __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
    
  __CONFIG _CONFIG2, _BOR4V_BOR21V & _WRT_OFF
  
MyVars	UDATA 0x20

PressDelay0 res 1
PressDelay1 res 1
 
LED res 1 ; variable for tracking button states
; bit 0 = DS1 mode (0 On, 1 Blink)
; bit 1 = DS4 mode (0 off, 1 Blink)
; bit 2 = DS1 event
; bit 3 = DS4 event
 
PwrOnRst    CODE    0x0
    goto Main
 
IntVect	    CODE    0x4
    
UsrCode	    CODE

; to account for human slowness
Delay_Loop:
    nop
    decfsz PressDelay0, F
    goto Delay_Loop
    
    movlw 0xFA
    movwf PressDelay0
    decfsz PressDelay1, F
    goto Delay_Loop
    
    movlw 0xFA
    movwf PressDelay1
    nop
    return

; state processing for LEDs
control:
CheckDS1:
    btfsc LED, 0    ; if DS1 mode = 1 (blink)
    goto BlinkDS1
; DS1 on
OnDS1:
    bsf PORTB, 0
    goto CheckDS4
; DS1 blink
BlinkDS1:
    movlw b'00000001'
    xorwf PORTB, F
CheckDS4:
    btfsc LED, 2 ; if DS4 mode = 1 (blink)
    goto BlinkDS4
    
; DS4 off
OffDS4:
    bcf PORTB, 3
    return
; DS4 blink
BlinkDS4:
    movlw b'00001000'
    xorwf PORTB, F
    return

; if input then set var a.k.a event detection
detectInput:
SW1_press:
    btfsc PORTE, 3 ; test if SW1 was pressed
    goto SW1_release ; sw1 not pressed
    ; if pressed
    btfsc LED, 1 ; has event alr happened?
    goto SW2_press
    
    movlw b'00000001'
    xorwf LED, F ; toggle DS1 mode
    bsf LED, 2 ; set latch
    goto SW2_press
    
SW1_release:
    bcf LED, 2

SW2_press:
    btfsc PORTB, 5 ; test if sw2 was pressed
    goto SW2_release ; sw2 not pressed
    ; if pressed
    btfsc LED, 3
    return
    
    movlw b'00000010'
    xorwf LED, F
    bsf LED, 3
    return
    
SW2_release:
    bcf LED, 3
    return
    
; PORT SETUP & INIT
Main:
    ; User code would go here
    ; DS4 = RB3, start off
    ; DS1 = RB0, start on
    ; SW1 = RE3, press blinks DS1
    ; SW2 = RB5, press blinks DS4
    
    ; init PORTE for sw2
    banksel ANSEL
    clrf ANSEL ; set digital
    banksel TRISE
    movlw b'00001000'
    movwf TRISE ; set RE3 as input
    banksel PORTE
    bsf PORTE, 3; set sw1 high to start (aka the switch not pressed)
    
    ; init PORTB for DS!, DS4, SW2
    banksel ANSELH
    clrf ANSELH ; set digital
    banksel TRISB
    movlw b'00100000'
    movwf TRISB ; set sw2 as input
    banksel PORTB
    movlw b'00010001'
    movwf PORTB ; turn on DS1, and set sw2 (aka switch not pressed)


; LOOP FOREVER
Loop:
    call detectInput
    call control
    call Delay_Loop
    goto Loop
end





