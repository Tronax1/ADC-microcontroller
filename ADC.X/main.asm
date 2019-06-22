#include <p18F45K50.inc>
    
CONFIG WDTEN=OFF; disable watchdog timer
CONFIG MCLRE = ON; MCLEAR Pin on
CONFIG DEBUG = ON; Enable Debug Mode
CONFIG LVP = ON; Low-Voltage programming
CONFIG PBADEN = OFF
CONFIG FOSC = INTOSCIO;Internal oscillator as primary OSC
org 0; start code at 0
    RESULTHI EQU 0x00
    RESULTLO EQU 0x01
    Delay1 EQU 0x02
    Delay2 EQU 0x03
    offset EQU 0x04
    GOTO Start
Lookup:
    MULWF offset
    MOVF PRODL, 0
    ADDWF PCL
    RETLW 0xD1; F
    RETLW 0x51; E
    RETLW 0x06; D
    RETLW 0x59; C
    RETLW 0x43; B
    RETLW 0xC0; A
    RETLW 0xE0; 9
    RETLW 0x00; 8
    RETLW 0xEC; 7
    RETLW 0x41; 6
    RETLW 0x61; 5
    RETLW 0xE2; 4
    RETLW 0x64; 3
    RETLW 0x54; 2
    RETLW 0xEE; 1
    RETLW 0x08; 0
LookupReversed:
    MULWF offset
    MOVF PRODL, 0
    ADDWF PCL
    RETLW 0xD1; F
    RETLW 0x51; E
    RETLW 0x06; D
    RETLW 0x59; C
    RETLW 0x43; B
    RETLW 0xC0; A
    RETLW 0xE0; 9
    RETLW 0x00; 8
    RETLW 0xEC; 7
    RETLW 0x41; 6
    RETLW 0x61; 5
    RETLW 0xE2; 4
    RETLW 0x08; 0
    RETLW 0xEE; 1
    RETLW 0x54; 2
    RETLW 0x64; 3
Start:
    CLRF TRISA
    CLRF TRISB
    CLRF TRISC
    CLRF TRISD
    CLRF PORTA
    CLRF PORTB
    CLRF PORTC
    CLRF PORTD
    CLRF LATB
    CLRF LATA
    CLRF LATC
    CLRF LATD
    CLRF RESULTHI
    CLRF RESULTLO
    CLRF Delay1
    CLRF Delay2
    CLRF offset
Test:
    MOVLW d'2'
    MOVWF offset
    MOVLW B'10101111'
    MOVWF ADCON2
    MOVLW B'00000000'
    MOVWF ADCON1
    BSF TRISA, 0; Configure RA0 to be input
    BSF ANSELA, 0; Configure RAO to be analog
    MOVLW B'00000001'
    MOVWF ADCON0
    BSF ADCON0, GO
ADCPoll:
    BTFSC ADCON0, GO
    BRA ADCPoll
    MOVFF ADRESH, RESULTHI
    MOVFF ADRESL, RESULTLO
    COMF RESULTHI
    MOVF RESULTHI, w
    ANDLW b'00001111'; Strip off high bits
    CALL LookupReversed; Call the lookup table
    MOVWF PORTB; Store the output pattern on the ports
    MOVF RESULTLO, w; Upper half of the reult
    ANDLW b'00001111'; Strip off high bits
    CALL Lookup; Call the lookup table
    MOVWF PORTD; Store the output pattern on the ports
    MOVFF ADRESL, RESULTLO
    SWAPF RESULTLO, 1; Get the higher bits
    MOVF RESULTLO, w
    ANDLW b'00001111'; strip off high bits
    CALL Lookup
    MOVWF PORTC; store values on port C
    MOVFF ADRESL, RESULTLO
    SWAPF RESULTLO, 1; Get high bits
    COMF RESULTLO
    MOVF RESULTLO, w
    ANDLW b'00001111'
    CALL Lookup
    MOVWF PORTA; Remaining bits on port A
Delay:
    DECFSZ Delay1, 1
    GOTO Delay
    DECFSZ Delay2, 1
    GOTO Delay
    GOTO Test
end

