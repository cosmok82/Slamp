;Program compiled by Great Cow BASIC (0.9 8/9/2013)
;Need help? See the GCBASIC forums at http://sourceforge.net/projects/gcbasic/forums,
;check the documentation or email w_cholmondeley at users dot sourceforge dot net.

;********************************************************************************

;Set up the assembler options (Chip type, clock source, other bits and pieces)
 LIST p=12F683, r=DEC
#include <P12F683.inc>
 __CONFIG _INTOSCIO & _WDT_OFF & _MCLRE_OFF

;********************************************************************************

;Set aside memory locations for variables
DELAYTEMP	EQU	112
SYSBYTETEMPX	EQU	112
SYSDIVMULTA	EQU	119
SYSDIVMULTA_H	EQU	120
SYSINTEGERTEMPA	EQU	117
SYSINTEGERTEMPA_H	EQU	118
SYSINTEGERTEMPB	EQU	121
SYSINTEGERTEMPB_H	EQU	122
SysWORDTempA	EQU	117
SysWORDTempA_H	EQU	118
SysWORDTempB	EQU	121
SysWORDTempB_H	EQU	122
SysWaitTemp10US	EQU	117
SysWaitTempUS	EQU	117
SysWaitTempUS_H	EQU	118
ADREADPORT	EQU	32
ADTEMP	EQU	33
I	EQU	34
I_H	EQU	35
READAD10	EQU	36
READAD10_H	EQU	37
SysTemp1	EQU	39
TIME	EQU	40
TIME_H	EQU	41

;********************************************************************************

;Alias variables
ALLANSEL	EQU	159

;********************************************************************************

;Vectors
	ORG	0
	goto	BASPROGRAMSTART
	ORG	4
	retfie

;********************************************************************************

;Start of program memory page 0
	ORG	5
BASPROGRAMSTART
;Call initialisation routines
	call	INITSYS

;Start of the main program
	call	INIT
START
	bsf	GPIO,2
	btfss	GPIO,1
	goto	ELSE1_1
	movlw	3
	movwf	ADREADPORT
	call	FN_READAD10
	movf	READAD10,W
	movwf	SysWORDTempA
	movf	READAD10_H,W
	movwf	SysWORDTempA_H
	movlw	72
	movwf	SysWORDTempB
	movlw	3
	movwf	SysWORDTempB_H
	call	SysCompLessThan16
	comf	SysByteTempX,F
	btfss	SysByteTempX,0
	goto	ENDIF2
	movlw	112
	movwf	TIME
	movlw	23
	movwf	TIME_H
	movlw	255
	movwf	I
	movwf	I_H
	clrf	SysINTEGERTempB
	clrf	SysINTEGERTempB_H
	movf	TIME,W
	movwf	SysINTEGERTempA
	movf	TIME_H,W
	movwf	SysINTEGERTempA_H
	call	SysCompLessThanINT
	btfsc	SysByteTempX,0
	goto	SysForLoopEnd1
SysForLoop1
	incf	I,F
	btfsc	STATUS,Z
	incf	I_H,F
	call	_052_56
	movf	I,W
	movwf	SysINTEGERTempA
	movf	I_H,W
	movwf	SysINTEGERTempA_H
	movf	TIME,W
	movwf	SysINTEGERTempB
	movf	TIME_H,W
	movwf	SysINTEGERTempB_H
	call	SysCompLessThanINT
	btfsc	SysByteTempX,0
	goto	SysForLoop1
SysForLoopEnd1
ENDIF2
	goto	ENDIF1
ELSE1_1
	movlw	255
	movwf	I
	movwf	I_H
SysForLoop2
	incf	I,F
	btfsc	STATUS,Z
	incf	I_H,F
	call	_090_18
	movf	I,W
	movwf	SysINTEGERTempA
	movf	I_H,W
	movwf	SysINTEGERTempA_H
	movlw	40
	movwf	SysINTEGERTempB
	movlw	35
	movwf	SysINTEGERTempB_H
	call	SysCompLessThanINT
	btfsc	SysByteTempX,0
	goto	SysForLoop2
SysForLoopEnd2
ENDIF1
	goto	START
BASPROGRAMEND
	sleep
	goto	BASPROGRAMEND

;********************************************************************************

Delay_10US
D10US_START
	movlw	5
	movwf	DELAYTEMP
DelayUS0
	decfsz	DELAYTEMP,F
	goto	DelayUS0
	nop
	decfsz	SysWaitTemp10US, F
	goto	D10US_START
	return

;********************************************************************************

INIT
	banksel	TRISIO
	bcf	TRISIO,2
	bsf	TRISIO,1
	bsf	TRISIO,3
	bsf	TRISIO,0
	bsf	TRISIO,4
	banksel	I
	clrf	I
	clrf	I_H
	clrf	TIME
	clrf	TIME_H
	return

;********************************************************************************

INITSYS
	movlw	112
	banksel	OSCCON
	iorwf	OSCCON,F
	banksel	ADCON0
	bcf	ADCON0,ADON
	bcf	ADCON0,ADFM
	banksel	ANSEL
	clrf	ANSEL
	movlw	7
	banksel	CMCON0
	movwf	CMCON0
	clrf	GPIO
	return

;********************************************************************************

FN_READAD10
	bsf	ADCON0,ADFM
	banksel	ALLANSEL
	clrf	ALLANSEL
	banksel	ADREADPORT
	incf	ADREADPORT,W
	movwf	ADTEMP
	bsf	STATUS,C
SysDoLoop_S1
	banksel	ALLANSEL
	rlf	ALLANSEL,F
	banksel	ADTEMP
	decfsz	ADTEMP,F
	goto	SysDoLoop_S1
SysDoLoop_E1
	banksel	ANSEL
	bcf	ANSEL,ADCS1
	bsf	ANSEL,ADCS0
	banksel	ADCON0
	bcf	ADCON0,CHS0
	bcf	ADCON0,CHS1
	btfsc	ADREADPORT,0
	bsf	ADCON0,CHS0
	btfsc	ADREADPORT,1
	bsf	ADCON0,CHS1
	bsf	ADCON0,ADON
	movlw	2
	movwf	SysWaitTemp10US
	call	Delay_10US
	bsf	ADCON0,GO_DONE
SysWaitLoop1
	btfsc	ADCON0,GO_DONE
	goto	SysWaitLoop1
	bcf	ADCON0,ADON
	banksel	ANSEL
	clrf	ANSEL
	movf	ADRESL,W
	banksel	READAD10
	movwf	READAD10
	clrf	READAD10_H
	movf	ADRESH,W
	movwf	READAD10_H
	bcf	ADCON0,ADFM
	return

;********************************************************************************

SYSCOMPLESSTHAN16
	clrf	SYSBYTETEMPX
	movf	SYSWORDTEMPA_H,W
	subwf	SYSWORDTEMPB_H,W
	btfss	STATUS,C
	return
	movf	SYSWORDTEMPB_H,W
	subwf	SYSWORDTEMPA_H,W
	btfss	STATUS,C
	goto	SCLT16TRUE
	movf	SYSWORDTEMPB,W
	subwf	SYSWORDTEMPA,W
	btfsc	STATUS,C
	return
SCLT16TRUE
	comf	SYSBYTETEMPX,F
	return

;********************************************************************************

SYSCOMPLESSTHANINT
	clrf	SYSBYTETEMPX
	btfss	SYSINTEGERTEMPA_H,7
	goto	ELSE8_1
	btfsc	SYSINTEGERTEMPB_H,7
	goto	ENDIF9
	comf	SYSBYTETEMPX,F
	return
ENDIF9
	comf	SYSINTEGERTEMPA,W
	movwf	SYSDIVMULTA
	comf	SYSINTEGERTEMPA_H,W
	movwf	SYSDIVMULTA_H
	incf	SYSDIVMULTA,F
	btfsc	STATUS,Z
	incf	SYSDIVMULTA_H,F
	comf	SYSINTEGERTEMPB,W
	movwf	SYSINTEGERTEMPA
	comf	SYSINTEGERTEMPB_H,W
	movwf	SYSINTEGERTEMPA_H
	incf	SYSINTEGERTEMPA,F
	btfsc	STATUS,Z
	incf	SYSINTEGERTEMPA_H,F
	movf	SYSDIVMULTA,W
	movwf	SYSINTEGERTEMPB
	movf	SYSDIVMULTA_H,W
	movwf	SYSINTEGERTEMPB_H
	goto	ENDIF8
ELSE8_1
	btfsc	SYSINTEGERTEMPB_H,7
	return
ENDIF8
	movf	SYSINTEGERTEMPA_H,W
	subwf	SYSINTEGERTEMPB_H,W
	btfss	STATUS,C
	return
	movf	SYSINTEGERTEMPB_H,W
	subwf	SYSINTEGERTEMPA_H,W
	btfss	STATUS,C
	goto	SCLTINTTRUE
	movf	SYSINTEGERTEMPB,W
	subwf	SYSINTEGERTEMPA,W
	btfsc	STATUS,C
	return
SCLTINTTRUE
	comf	SYSBYTETEMPX,F
	return

;********************************************************************************

_052_56
	bsf	GPIO,2
	movlw	34
	movwf	DELAYTEMP
DelayUS1
	decfsz	DELAYTEMP,F
	goto	DelayUS1
	nop
	bcf	GPIO,2
	movlw	37
	movwf	DELAYTEMP
DelayUS2
	decfsz	DELAYTEMP,F
	goto	DelayUS2
	return

;********************************************************************************

_090_18
	bsf	GPIO,2
	movlw	60
	movwf	DELAYTEMP
DelayUS3
	decfsz	DELAYTEMP,F
	goto	DelayUS3
	bcf	GPIO,2
	movlw	12
	movwf	DELAYTEMP
DelayUS4
	decfsz	DELAYTEMP,F
	goto	DelayUS4
	return

;********************************************************************************


 END
