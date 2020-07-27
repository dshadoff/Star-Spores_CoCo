	ORG	$55B5
PUTSPR	TST	10,U	; Check if Nastie (pointed to by U) is dead.
	BNE	PTSPR1	; If so, return
	RTS
PTSPR1	LDY	#$5E28	; Stick real x & y lengths in his data (in
	LDA	5,U	; case it was hatched since the last time
	LDX	#$5DC4	; it was displayed).
	LDB	A,X
	STB	2,U
	LDX	#$5DCD
	LDB	A,X
	STB	3,U
	LSLA		; Get location of table for different
	LDY	A,Y	; animation shots of Nastie.
	LDA	4,U	; Get location of table for different
	LSLA		; pixel-within-byte shots of character.
	LDY	A,Y
	LDB	,U	; Get screen location of Nastie (except
	TFR	B,A	; vertical pos).
	LDX	$5D8D
	LSRB
	LSRB
	ABX
	ANDA	#$3	; Y now points to character's graphic data
	LSLA
	LDY	A,Y
	LDB	3,U	; # pixels high -> store it for a loop
	STB	$563E
	LDB	#$20	; Add vertical offset for real screen position.
	LDA	1,U
	MUL
	LEAX	D,X
LOOP	LDB	2,U	; # of bytes wide - store it for a loop
	STB	$563F
	LDB	#$20
LOOP1	LDA	,X	; Put byte on screen
	ORA	,Y+
	STA	,X+
	DECB		; Fix counters
	DEC	$563F
	BNE	LOOP1
	LEAX	B,X	; Next line's start position
	DEC	$563E	; Finish loop
	BNE	LOOP
	RTS
ERSPOR	TST	10,U	; If dead, delay and return
	BNE	ERSPR1
	LDX	#50
DELOP1	LEAX	-1,X
	BNE	DELOP1
	RTS
ERSPR1	LDB	#$20	; Get screen position of Nestie's first byte
	LDA	1,U
	MUL
	LDX	$5D8D
	LEAX	D,X
	LDB	,U
	LSRB
	LSRB
	ABX
	LDB	3,U	; Vertical height - store it for a loop.
	STB	$563E
	CLRA		; Ready to blank
	CLRB
LOOPY	STD	,X++	; Clear bytes (try to maximize blank time)
	STA	,X
	LEAX	$1E,X
	DEC	$563E
	BNE	LOOPY
	RTS		; Return
LAST	EQU	.-1
	END	PUTSPR
