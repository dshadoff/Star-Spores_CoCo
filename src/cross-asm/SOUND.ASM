	ORG	$5CC7
SONXBT	FCB	0	; Scratch variable
SOUND	PSHS	X,B,A	; protect registers
	LDA	$FF01	; Setup PIA's to make sound
	ANDA	#$F7
	STA	$FF01
	LDA	$FF03
	ANDA	#$F7
	STA	$FF03
	LDA	$FF23
	ORA	#8
	STA	$FF23
	LDA	SONXBT	; Take whatever D-A was there,
	LDB	#$C0	; and produce a 'click' by
	STB	,-S	; complementing the most- and
	EORA	,S+	; second-most significant
	STA	SONXBT	; (loudest) bits
	STA	$FF20
	LDX	#1	; Variable delay for variable
SONDX1	EQU	.-2	; frequency
SONLP1	LEAX	-1,X
	BNE	SONLP1
	STB	,-S	; Make another click (other
	EORA	,S+	; half-cycle)
	STA	SONXBT
	STA	$FF20
	LDX	#1	; Other variable delay for
SONDX2	EQU	.-2	; variable frequency
SONLP2	LEAX	-1,X
	BNE	SONLP2
	PULS	A,B,X,PC	; return with regs intact
LAST	EQU	.-1
	END
