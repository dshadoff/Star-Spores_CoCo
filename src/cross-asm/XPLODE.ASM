	ORG	$4E00
XPLODE	JSR	REVERS	; Flash, by reversing screen
	JSR	$5D0B	; making noise, and re-reversing
	JSR	$5D0B	; screen to normalize
	JSR	$5D0B
	JSR	$5D0B
	JSR	REVERS
	LDX	#PNTTBL	; Set up for loop of 60 points
	LDY	#COLTBL	; to move
	LDB	#60
	STB	PNTCNT
STPNT	LDB	#184	; Initial y-position is 184,
	LDA	SHPPOS	; x-position is centre of ship
	ADDA	#7
	LSLA
	STB	3,X
	STA	2,X
	STA	,X	; Point is 'on'
	LDA	$5D3F	; Color
	ANDA	#3
	LDA	A,Y
	STA	1,X
	JSR	$5D21	; Get random value for x and y
	LDD	$5D3F	; speed of point
	ANDA	#$87	; Mask values. MSBit is up/down flag
	ANDB	#15
	CMPB	#12	; Regulate y-value to an average
	BCS	YVECOK
	SUBB	#8
YVECOK	STA	4,X
	ORB	#$80	; Y must go up
	STB	5,X
	LDB	$5D40	; Get some unused random bits, use
	LSRB		; for delay in starting to move (so
	LSRB		; that they don't form 'square'
	LSRB		; patterns)
	ANDB	#3
	STB	6,X
	LEAX	7,X	; Go for next point
	DEC	PNTCNT
	BNE	STPNT
CNTLP1	LDX	#PNTTBL	; Get ready to move live points or
	CLR	CNTPNT	; count dead ones
	LDB	#60
	STB	PNTCNT
CNTLOP	TST	,X	; It's dead
	BEQ	NTHERE
	TST	6,X	; It's ready to move
	BEQ	NODEC
	DEC	6,X	; Decrement wait counter
	BRA	THERE
NODEC	CLR	$5DBD	; Reset old point off screen (black color)
	LDD	2,X	; Get (x,y) position. Note, there is an extra
	LSRA		; bit of precision in position and velocity
	LSRB		; values, which is stripped off here
	STA	$5DBE	; Reset old pixel
	STB	$5DBF
	JSR	$5D8F
	JSR	ADDX	; Make new value
	JSR	ADDY
	TST	,X	; Did it go off screen ?
	BEQ	NTHERE
	LDD	2,X	; Put new (x,y) values within the set
	LSRA		; routine's clutches
	LSRB
	STA	$5DBE
	STB	$5DBF
	LDA	1,X	; Color
	STA	$5DBD
	JSR	$5D8F	; Set point
	JSR	$5D0B	; Make noise
	BRA	THERE
NTHERE	INC	CNTPNT	; Count one more dead and delay
	PSHS	X
	LDX	#75
DELOOP	LEAX	-1,X
	BNE	DELOOP
	PULS	X
THERE	LEAX	7,X	; Go back for more
	DEC	PNTCNT
	BNE	CNTLOP
	LDA	CNTPNT	; Are we all finished ?
	CMPA	#60
	BNE	CNTLP1
LAST	JMP	[$5AA1]	; Go back to game (see SPORES.ASM)
REVERS	PSHS	X,B,A	; Complement every byte on the screen,
	LDX	$5D8D	; and delay
RVRS1	LDD	,X
	COMA
	COMB
	STD	,X++
	CMPX	#$1A00
	BLO	RVRS1
	LDX	#$500
LOPDEL	LEAX	-1,X
	BNE	LOPDEL
	PULS	A,B,X,PC
PNTCNT	FCB	0	; Variables
CNTPNT	FCB	0
SHPPOS	EQU	$5AA5
COLTBL	FCB	$AA	; Colors available - red is favoured
	FCB	$55
	FCB	$AA
	FCB	$FF
ADDY	LDA	5,X	; Either go to add, or subtract y-speed
	BITA	#$80	; Also check if it went off top of screen
	BEQ	ADYPOS
	ANDA	#15
	STA	,-S
	LDA	3,X
	SUBA	,S+
	CMPA	#18
	BCS	GONEY
	BRA	RNDMTY
ADYPOS	ANDA	#15	; Add y-speed; check if it went through
	ADDA	3,X	; through bottom
	CMPA	#192
	BCC	GONEY
RNDMTY	STA	3,X	; 1-in-2 chance of next thing happening
	JSR	$5D21
	LDA	$5D3F
	ANDA	#$80
	BEQ	NEXT
	RTS
NEXT	LDA	5,X	; Simulate gravity (acceleration) by
	ANDA	#15	; changing velocity of particle
	BNE	RDMTY1	; downward slightly
	STA	5,X
RDMTY1	LDA	5,X
	BITA	#$80
	BEQ	INCMTY
	DEC	5,X
	RTS
INCMTY	INC	5,X
	RTS
GONEY	CLR	,X	; It's dead
	RTS
ADDX	LDA	4,X	; Check if negative x-value
	BITA	#$80	; If yes, subtract
	BEQ	ADXPOS
	ANDA	#7
	BEQ	GONEX
	STA	,-S
	LDA	2,X
	SUBA	,S+
	BCS	GONEX
	BRA	DONEX
ADXPOS	ANDA	#7	; Add x-velocity to x-position
	BEQ	GONEX
	ADDA	2,X
	BCS	GONEX
DONEX	STA	2,X
	RTS
GONEX	CLR	,X	; It's dead
	RTS
PNTTBL	RMB	450	; Point table
	FCC	/(C) 1984 BY DAVE SHADOFF/
LASTBT	EQU	.-1
	END	XPLODE
