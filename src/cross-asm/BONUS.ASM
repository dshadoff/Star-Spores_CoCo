	ORG	$517E
BONUSR	LDX	#$2000	; Wait a few seconds - just
BONUS1	LEAX	-1,X	; for printing "Bonus Round"
	BNE	BONUS1
	LDX	#$5302	; Put graphically-encoded "Bonus Round"
	LDY	#$10A8	; message on screen
	JSR	PRNST
	LDX	#$52CA
	LDY	#$10B0
	JSR	PRNST
	NOP
	JMP	START	; Go to start
	LDX	#TBLBON	; No longer used (but previously used)
	LDA	$52C9	; (prints round # after "Bonus Round")
	DECA
	CLRB
	LSLA
	LDX	A,X
	LDB	#7
	STB	$52C8
LOOP2	LDD	,X++
	STD	,Y
	LEAY	$20,Y
	DEC	$52C8
	BNE	LOOP2
SONDX1	EQU	$5CF2	; Definitions
SOUNDX	EQU	$5CC8
SONDX2	EQU	$5D03
START	JSR	WHOP	; Make 5 "whop" sounds
	JSR	WHOP
	JSR	WHOP
	JSR	WHOP
	JSR	WHOP
	RTS
	NOP
WHOP	LDD	#$76	; Make a quickly rising tone ("whop")
WHOOP	STD	SONDX1
	STD	SONDX2
	JSR	SOUNDX
	JSR	SOUNDX
	LDD	SONDX1
	DECB
	DECB
	BNE	WHOOP
	RTS
	RTS
TBLBON	FDB	$5900	; No longer used (Data table for numbers)
	FDB	$5910
	FDB	$533A
	FDB	$5348
PRNST	LDB	#7	; Graphics lettering routine
	STB	$52C8
LOOP	LDB	#4
	STB	LINCNT
LOOP1	LDD	,X++
	STD	,Y++
	DEC	LINCNT
	BNE	LOOP1
	LEAY	$18,Y
	DEC	$52C8
	BNE	LOOP
	RTS
BONRN1	LDX	#$2000	; Delay - for achieving success
LOOP10	LEAX	-1,X	; in the Bonus Round
	BNE	LOOP10
	LDX	#$526D	; Print "500 Extra" in graphic letters
	LDY	#$10A5
	LDB	#7
	STB	$52C8
LOOP3	LDB	#6
	STB	LINCNT
LOOP4	LDD	,X++
	STD	,Y++
	DEC	LINCNT
	BNE	LOOP4
	LDB	,X+
	STB	,Y
	LEAY	$14,Y
	DEC	$52C8
	BNE	LOOP3
	LDX	#$5302	; Print "Bonus" directly after
	LDY	#$10B3	; "500 Extra", also in graphics letters
	JSR	PRNST
	LDD	#$10	; Make 3 beeps separated by pauses
	STD	$5CF2
	STD	$5D03
	JSR	LOOP5
	JSR	LOOP5
	JSR	LOOP5
	LDX	#$2000	; Pause, return
LOOP9	LEAX	-1,X
	BNE	LOOP9
	RTS
LOOP5	LDB	#$D0	; Do the loop
	STB	LINCNT
LOOP6	JSR	$5CC8
	DEC	LINCNT
	BNE	LOOP6
	LDX	#$1000	; Pause, return
LOOP7	LEAX	-1,X
	BNE	LOOP7
	RTS
LINCNT	FCB	0	; Scratch variable
LAST	EQU	.-1
	END	BONUSR
