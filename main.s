#include <xc.inc>

psect	code, abs
	
main:
    org 0x0
    bra setup

bigdelay:
    movlw 0x00
dloop:
    decf    0x11,f,A
    subwfb  0x10,f,A
    bc	    dloop
    decfsz  0x12,A
    bra	    bigdelay
    return
    
SPI_MasterInit:
    bcf CKE2
    
    movlw (SSP2CON1_SSPEN_MASK)|(SSP2CON1_CKP_MASK)|(SSP2CON1_SSPM1_MASK)
    movwf SSP2CON1,A
    bcf	TRISD, PORTD_SDO2_POSN,A
    bcf TRISD, PORTD_SCK2_POSN, A
    
    setf TRISE
    
    return

SPI_MasterTransmit:
    movwf SSP2BUF,A
Wait_Transmit:
    btfss SSP2IF
    bra Wait_Transmit
    bcf SSP2IF
    return


    
setup:
    call SPI_MasterInit
    movlw 0x00
    movwf   0x14
    movff   0x14, 0x13
    nop
    
transmit:
    movf    0x13, W
    
    call    SPI_MasterTransmit
    
    movlw   high(0xFFFF)
    movwf   0x10, A
    movlw   low(0xFFFF)
    movwf   0x11, A
    movlw   0x10
    movwf   0x12, A
    call    bigdelay
    
    movlw 0xff
    CPFSLT  0x13, A
    movff   0x14, 0x13
    nop
    CPFSEQ  0x13, A
    incf 0x13
    
    
    bra transmit
    