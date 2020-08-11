	ORG	$5AA6
LINE	PSHS	Y,X,B,A	; Check if line is actually just
	LDA	STARTX	; a point; if so, set it
	SUBA	ENDX
	BNE	LINE1
	LDA	STARTY
	SUBA	ENDY
	BNE	LINE1
	JSR	SET
	PULS	A,B,X,Y,PC
LINE1	LDD	ENDX	; Show change in X in DIRX
	TFR	A,B
	CLRA
	STD	STO1
	LDD	STARTX
	TFR	A,B
	CLRA
	STD	D1
	LDD	STO1
	SUBD	D1
	STD	DIRX
	LDD	ENDY	; Show change in Y in DIRY
	TFR	A,B
	CLRA
	STD	STO1
	LDD	STARTY
	TFR	A,B
	CLRA
	STD	D1
	LDD	STO1
	SUBD	D1
	STD	DIRY
	TFR	D,X	; DIRX & DIRY may be positive or
	LDD	D1	; negative. This compares to find
	STD	STO1	; which of the two has a greater
	STX	D1	; absolute value by shifting
	LDD	DIRX	; DIRX & DIRY left to check for
	STD	STO1	; a change in status
	LDA	STO2
	ANDA	#$80
	STA	STO5
	LDA	STO3
	ANDA	#$80
	STA	STO4
SHIFT	ASL	STO2
	ASL	STO3
	LDA	STO2
	ANDA	#$80
	CMPA	STO5
	BNE	DSHIFT
	LDA	STO3
	ANDA	#$80
	CMPA	STO4
	BEQ	SHIFT
DSHIFT	LDD	STO1	; Store values back in direction
	STD	DIRX	; variables
	LDD	D1
	STD	DIRY
NXTBLO	JSR	SET	; Set a point. If current X and Y
	LDD	ENDX	; both equal their respective
	SUBD	STARTX	; eventual values, return - else,
	BEQ	MAYBE	; add the direction values,
NOTYET	LDD	STARTX	; and do it again
	ADDD	DIRX
	STD	STARTX
	LDD	STARTY
	ADDD	DIRY
	STD	STARTY
	BRA	NXTBLO
MAYBE	LDD	ENDY
	SUBD	STARTY
	BNE	NOTYET
	PULS	A,B,X,Y,PC
SET	PSHS	Y,X,B,A
	LDD	STARTX	; fix X value
	BITB	#$80
	BEQ	NOINC
	INCA
NOINC	STA	XPOS
	LDD	STARTY	; fix Y value
	BITB	#$80
	BEQ	NOINC1
	INCA
NOINC1	STA	YPOS
	LDB	YPOS	; Use vertical position for
	CLRA		; frequency of sound for each
	LSRB		; pixel. If pixel will turn
	LSRB		; black (erase line), no sound
	INCB		; is produced
	STD	$5CF2
	STD	$5D03
	TST	COLOR
	BEQ	NOSOND
	JSR	$5CC8
	JSR	$5CC8
NOSOND	LDX	$5D8D	; Get byte position of pixel
	LDB	YPOS	; in X, and pixel # in A
	LDA	#$20
	MUL
	LEAX	D,X
	LDA	XPOS
	TFR	A,B
	ANDA	#3
	NOP
	LSRB
	LSRB
	ABX
	LDY	#TABLE	; Get pixel mask in A & B
	LDA	A,Y
	TFR	A,B
	COMB		; Replace old pixel
	ANDB	,X	; with new one
	ANDA	COLOR
	STA	,-S
	ORB	,S+
	STB	,X
	PULS	A,B,X,Y,PC
TABLE	FCB	$C0	; Mask table
	FCB	$30
	FCB	$0C
	FCB	$03
	RMB	4
ENDY	FDB	0	; variables' storage
ENDX	FDB	0
STARTX	FDB	0
STARTY	FDB	0
DIRX	FDB	0
DIRY	FDB	0
XPOS	FCB	0
YPOS	FCB	0
COLOR	FCB	0
STO5	FCB	0
STO4	FCB	0
D1	FCB	0
STO3	FCB	0
STO1	FCB	0
STO2	FCB	0
	END	LINE
