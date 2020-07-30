	ORG	$5D8D
SCRST	FDB	$E00	; Start of graphic screen mem
SET	PSHS	Y,X,B,A	; Save regs
	LDA	YPOS
	LDB	#$20	; Multiply y-pos by # bytes/line
	LDX	SCRST	; to get line offset
	MUL
	LEAX	D,X	; Get address of line it's on
	LDB	XPOS
	LSRB		; Divide x-pos by 4 to get
	LSRB		; byte offset
	ABX		; Put byte address in X
	LDA	XPOS	; Get pixel # (0-3) within byte
	ANDA	#3
	LDY	#TABLE	; Get pixel mask from table,
	LDA	A,Y	; and put it in A & B
	TFR	A,B
	COMB		; Put reverse mask in B
	ANDB	,X	; Clean out previous pix contents
	ANDA	COLOR
	STB	,-S	; Put new pixel contents into byte
	ORA	,S+
	STA	,X
	PULS	A,B,X,Y,PC	; Restore regs, return
COLOR	FCB	0	; Entry variables
XPOS	FCB	0
YPOS	FCB	0
TABLE	FCB	$C0	; Table of pixel masks
	FCB	$30
	FCB	$0C
	FCB	$03
	END
