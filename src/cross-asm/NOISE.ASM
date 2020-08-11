	ORG	$5D0B
RNDSND	JSR	RNDOM	; Get random number
	LDD	RNDNO
	LSRB		; Make it a shorter delay (higher
	LSRB		; pitch), minimum delay of 1
	CLRA
	INCB
	STD	NOISE1
	STD	NOISE2
	JSR	NOISE	; Do 2 cycles of this sound
	JMP	NOISE
RNDOM	PSHS	X,B,A	; Protect registers
	LDX	RNDCNT	; Get stuff ready
	LDD	RNDNO
	EORA	B,X	; Do a clever operation with the ROM's
	EORB	A,X	; data to generate a random number
	LEAX	2,X	; Make sure that the counter changes,
	CMPX	#$BF00	; and stays within the ROMs
	BLO	NEXT
	LDX	#$A000
NEXT	STX	RNDCNT
	STD	RNDNO	; Store number
	PULS	A,B,X,PC	; Return
RNDNO	FDB	0	; scratch values
RNDCNT	FDB	$A000	; scratch values
NOISBT	FCB	0	; scratch values
NOISE	PSHS	X,B,A	; Protect registers
	LDA	$FF01	; Set up PIA's for sound
	ANDA	#$F7
	STA	$FF01
	LDA	$FF03
	ANDA	#$F7
	STA	$FF03
	LDA	$FF23
	ORA	#8
	STA	$FF23
	LDA	NOISBT	; Make click as in SOUND, but with
	JSR	RNDOM	; random volume (thus, noise)
	LDB	RNDNO
	ANDB	#$FC
	STB	,-S
	EORA	,S+
	STA	NOISBT
	STA	$FF20
	LDX	#1	; Wait (variable)
NOISE1	EQU	.-2
NOSLP1	LEAX	-1,X
	BNE	NOSLP1
	STB	,-S	; Make same click as above to
	EORA	,S+	; restore value (finish cycle)
	STA	NOISBT
	STA	$FF20
	LDX	#1
NOISE2	EQU	.-2	; Wait (variable)
NOSLP2	LEAX	-1,X
	BNE	NOSLP2
	PULS	A,B,X,PC	; Return
LAST	EQU	.-1
	END
