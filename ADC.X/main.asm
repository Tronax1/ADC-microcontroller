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
    GOTO Start
Lookup:
    ADDWF PCL
    RETLW 0x08; 0
    RETLW 0xEE; 1
    RETLW 0x54; 2
    RETLW 0x64; 3
    RETLW 0xE2; 4
    RETLW 0x61; 5
    RETLW 0x41; 6
    RETLW 0xEC; 7
    RETLW 0x00; 8
    RETLW 0xE0; 9
    RETLW 0xC0; A
    RETLW 0x43; B
    RETLW 0x59; C
    RETLW 0x06; D
    RETLW 0x51; E
    RETLW 0xD1; F
Start:
    CLRF TRISA
    CLRF TRISB
    CLRF PORTA
    CLRF PORTB
    CLRF LATB
    CLRF LATA
    CLRF RESULTHI
    CLRF RESULTLO
    CLRF Delay1
    CLRF Delay2
Test:
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
    COMF RESULTLO; Complement bits since 7 segment is ACTIVE LOW
    MOVF RESULTLO, w
    ANDLW b'00011111'; Strip off high bits
    CALL Lookup; Call the lookup table
    MOVWF PORTB; Store the output pattern on the ports
Delay:
    DECFSZ Delay1, 1
    GOTO Delay
    DECFSZ Delay2, 1
    GOTO Delay
    GOTO Test
end

