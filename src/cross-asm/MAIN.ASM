	ORG	$2D00
ORIGIN	JSR	CLRSTR	; Clear stars from background
	LDD	$B4B3	; Check if it's a Dragon 32 (says "(C"
	CMPD	#$2843	; in part of signon message; may not
	BNE	ORGN1	; work on all Dragons)
	LDA	#16
	STA	JOYN4	; patch up keyboard values, if Dragon
	STA	JOYN5
	LDA	#32
	STA	JOYN1
	STA	JOYN2
	STA	JOYN3
ORGN1	CLR	$FF40	; Turn off drive motor
	LDA	#$34	; initialize PIA's
	STA	$FF03
	LDA	#$3C
	STA	$FF23

; Set up title screen by decoding values from $5640-$583F and
; putting thm into $400-$5FF, using a decoding technique:
;  (1) Take the encoded value from high memory
;  (2) With this value, a boolean eXclusive-OR is performed
;      with the value $75
;  (3) The result is negated
;  (4) The value is then added the value $38
;  (5) The this result has a boolean eXclusive-OR performed
;      on it with the least-significant byte of the address
;      from which it was taken (high memory).  This result
;      is in pseudo-ASCII form, which shows up on the screen
;      as bright letters on a dark background
;
	LDX	#$5640
	LDS	#$7F00
	LDY	#$400
ORGLOP	TFR	X,D
	STB	,-S
	LDA	,X+
	EORA	#$75
	NEGA
	ADDA	#$38
	EORA	,S+
	STA	,Y+
	CMPX	#$5840
	BLO	ORGLOP

	LDA	#$60	; Clear high score screen ($600-$7FF) and
ORGLP1	STA	,Y+	; "Input Name" screen ($800-$9FF)
	CMPY	#$A00
	BLO	ORGLP1
ORGLP5	NOP		; Make a graphics screen full of $AA
	LDX	#$E00	; (hopefully red from artifacting)
	LDD	#$AAAA
ORGLP4	STD	,X++
	CMPX	#$1A00
	BLO	ORGLP4
	LDX	#ORGLP5	; Make RESET return to program (for
	STX	<$72	; turning blue to red)
	LDA	#$55
	STA	<$71
	LDA	$FF22	; Set up screen to view graphics
	ORA	#$F8	; (hopefully red)
	STA	$FF22
	STA	$FFC0
	STA	$FFC2
	STA	$FFC5
	STA	$FFC7
	STA	$FFC9
	STA	$FFCB
ORGLP6	JSR	[$A000]	; Wait for carriage return (signifying
	CMPA	#$0D	; "yes it's OK")
	BNE	ORGLP6
	LDX	#$400
ORGLP2	LDA	,X	; Copy graphics border of title screen
	STA	$200,X	; to high score and "input name" screens
	STA	$400,X
	LDA	$1E0,X
	STA	$3E0,X
	STA	$5E0,X
	LEAX	1,X
	CMPX	#$420
	BLO	ORGLP2
ORGLP3	LDA	,X
	STA	$200,X
	STA	$201,X
	STA	$400,X
	STA	$401,X
	LDA	$1E,X
	STA	$21E,X
	STA	$21F,X
	STA	$41E,X
	STA	$41F,X
	LEAX	$20,X
	CMPX	#$5E0
	BLO	ORGLP3
	LDX	#$62A	; Finish setting up high score and
	LDU	#HSMSG	; "input name" screens
	JSR	PRNSTR
	LDX	#$8AC
	LDU	#PLCNMS
	JSR	PRNSTR
	LDX	#$90B
	LDU	#SPCMSG
	JSR	PRNSTR
	LDX	#$8E8
	LDU	#CNGRMS
	JSR	PRNSTR
	LDX	#$673
	LDA	#$70
	CLR 	LINCNT
ORGLP9	LDB	#6
	STB	CNLIN1
ORGLPA	STA	,X+
	DEC	CNLIN1
	BNE	ORGLPA
	LEAX	$1A,X
	LDB	LINCNT
	ADDB	#$71
	STB	-44,X
	LDB	#$6E
	STB	-43,X
	LDB	LINCNT
	INCB
	STB	LINCNT
	CMPB	#10
	BLO	ORGLP9
	LDB	#$71
	STB	$786
	DECB
	STB	$787
TITLP2	STA	$FFC0	; Set up screen to view title page
	STA	$FFC2
	STA	$FFC4
	LDA	$FF22
	ANDA	#7
	STA	$FF22
	STA	$FFC6
	STA	$FFC9
	STA	$FFCA
	LDA	#$B0	; Make a sound, and replace original
	STA	WHOP+2	; values
	JSR	WHOP
	LDA	#$76
	STA	WHOP+2
	LDA	#1	; Fix keyboard rollover table
	STA	$153
	STA	$154
	CLR	BTN1	; Reset joystick button input
	CLR	BTN2
TITLEP	STA	$FFC6	; Always set screen location inside
	STA	$FFC9	; this loop
	STA	$FFCA
	LDS	#$7F00	; Reset stack pointer just in case...
	JSR	ROTATE	; Rotate colors
	LDX	#$40
INPLOP	PSHS	X	; Check $40 (64) times for key input
	JSR	[$A000]	; or button pressing. If something was
	TSTA		; done, go to High Score page, else
	BNE	INLPOT	; rotate colors on title page
	JSR	BUTON
	TSTA
	BNE	INLPOT
	PULS	X
	LEAX	-1,X
	BNE	INPLOP
	BRA	TITLEP
INLPOT	PULS	X	; equalize stack
HSPAGE	STA	$FFC7	; Fix screen location to view
	STA	$FFC9	; High Score page
	STA	$FFCA
	LDU	#JKMSG	; Print message - Joystick or Keyboard
	LDX	#$7C5
	JSR	PRNSTR
	JSR	WHOP1	; Make sound
	CLR	CNTER8
	CLR	CNTER8+1
HSPG1	JSR	ROTATE	; Rotate, while checking for key input as
	LDX	CNTER8	; before. If too long is taken, it reverts
	LEAX	1,X	; to title page. If capital or lower case
	CMPX	#$120	; "J" or "K" are input, the next question
	BEQ	TITLEP	; (number of players) is asked.
	STX	CNTER8	; If the spacebar or joystick button are
	LDX	#$40	; pressed, the game starts with the same
INLP1	PSHS	X	; number of players as last game
	JSR	[$A000]	; (default=1), with the game input from
	CMPA	#$20	; the device pressed.
	LBEQ	INLP1T
	CMPA	#$4A
	BEQ	INLP1S
	CMPA	#$4B
	BEQ	INLP1S
	CMPA	#$6A
	BEQ	INLP1S
	CMPA	#$6B
	BEQ	INLP1S
	JSR	BUTON
	TSTA
	BNE	INLP1T
	PULS	X
	LEAX	-1,X
	BNE	INLP1
	BRA	HSPG1
INLP1S	PULS	X	; Ask if 1 or 2 players wish to play,
	ANDA	#$4F	; wait for input, all while rotating.
	SUBA	#$4A	; If too long is taken, it reverts to
	STA	JOYKEY	; the title page.
	LDU	#PLMSG
	LDX	#$7C5
	JSR	PRNSTR
HSPG2	JSR	ROTATE
	LDX	CNTER8
	LEAX	1,X
	CMPX	#$120
	LBEQ	TITLEP
	STX	CNTER8
	LDX	#$40
INLP2	PSHS	X
	JSR	[$A000]
	CMPA	#$20
	BEQ	INLP1T
	CMPA	#$31
	BEQ	PLY1
	CMPA	#$32
	BEQ	PLY2
	JSR	BUTON
	TSTA
	BNE	INLP1T
	PULS	X
	LEAX	-1,X
	BNE	INLP2
	BRA	HSPG2
PLY1	PULS	X	; Set up joystick/keyboard flag, and
	CLR	NOPLAY	; no. of players, and go to game
	JMP	GAME	; (various routines for various input
PLY2	PULS	X	; conditions)
	LDA	#1
	STA	NOPLAY
	JMP	GAME
INLP1T	PULS	X
	CMPA	#$20
	BEQ	KEYB
	CLR	JOYKEY
	JMP	GAME
KEYB	LDA	#1
	STA	JOYKEY
	JMP	GAME
	JMP	GAME
BUTON	LDA	BTN1	; Check joystick button inputs.
	STA	BTN2	; BTN1 reflects true state of buttons.
	LDA	#$FF	; BTN2 reflects state the last time
	STA	$FF02	; the routine was called.
	LDA	$FF00	; A exits non-zero only if button was
	COMA		; just released.
	ANDA	#3
	STA	BTN1
	EORA	#3
	ANDA	BTN2
	RTS
ROTATE	LDX	#$400	; Simulation of rotation by changing of
ROTAT1	LDA	,X	; color definition of graphics characters
	CMPA	#$80
	BCS	LOWER
	SUBA	#$10
	CMPA	#$80
	BCC	HIGHER
	ADDA	#$80
HIGHER	STA	,X
LOWER	LEAX	1,X
	CMPX	#$A00
	BLO	ROTAT1
	RTS
JKMSG	FCC	/JOYSTICK OR KEYBOARD ? /
	FCB	0
PLMSG	FCC	/   1 OR 2 PLAYERS ?    /
	FCB	0
HSMSG	FCC	/HIGH SCORES/
	FCB	0
PLCNMS	FCC	/PLAYER 1/
	FCB	0
CNGRMS	FCC	/ENTER YOUR NAME/
	FCB	0
SPCMSG	FCC	/>        </
	FCB	0
CNTER8	FDB	0
BTN1	FCB	0
BTN2	FCB	0
CNSTNT	EQU	SCRSTB-SCRTBL
XPLODE	EQU	$4E00
GAME	CLR	PLYNO	; Setup for sound, graphics screen
	LDA	$FF22	; @ $E00, for 256x96 graphics with
	ORA	#$F8	; artifacting
	STA	$FF22
	STA	$FFC5
	STA	$FFC2
	STA	$FFC0
	LDX	#$FFC6
	LDD	#$0707
NXTBIT	LSRA
	BCS	HIGH
LOW	STA	,X++
	BRA	NXTBT1
HIGH	LEAX	1,X
	STA	,X+
NXTBT1	DECB
	BNE	NXTBIT
	LDX	#$E00	; Clear screen
	STX	SCRST
	LDX	SCRST
	LDD	#$0
CLSLOP	STD	,X++
	CMPX	#$1A00
	BLO	CLSLOP
	LDY	#SHTTBL
	LDA	#40
CLRSHT	CLR	,Y+	; Clear shots from shot table
	DECA
	BNE	CLRSHT
	LDY	#SCRTBL
	LEAX	CNSTNT,Y
	LDB	#80
CLRSCR	CLR	,Y+	; Clear scores-to-be-printed table
	CLR	,X+
	DECB
	BNE	CLRSCR
	LDX	#PLY1SC
	LDY	#PLY2SC
	LDA	#6
	LDB	#$0A
SCCLLP	CLR	,X+	; Set up each player's score to be
	CLR	,Y+	; "000000 03"
	DECA
	BNE	SCCLLP
	STB	,X+
	STB	,Y+
	CLR	,X+
	CLR	,Y+
	LDB	#3
	STB	,X
	STB	,Y
	LDY	#SCRTBL
	LDX	#PLY1SC
	STX	3,Y	; Set up players' scores in
	LDA	#9	; scores-to-be-printed table; if
	STA	2,Y	; player 2 is not playing, reduce
	LDA	#1	; his number of ships to 00
	STA	,Y
	STA	1,Y
	STA	5,Y
	LDA	PLYNO
	LDX	#CLTBL2
	LDA	A,X
	STA	6,Y
	LEAY	7,Y
	LDX	#PLY2SC
	STX	3,Y
	LDA	#9
	STA	2,Y
	LDA	#1
	STA	1,Y
	STA	5,Y
	LDA	#92
	STA	,Y
	TST	NOPLAY
	BNE	STSCUP
	CLR	8,X
STSCUP	LDA	PLYNO
	LDX	#CLTBL2
	EORA	#1
	LDA	A,X
	STA	6,Y
	LDX	$5D8D
	CLRB
	LDU	#$59A0
STUPSC	LDA	,U+	; Put border layout at top of screen
	STA	,X+
	DECB
	BNE	STUPSC
	LDX	#AFTXPD
	STX	$5AA1	; Set up random number seed,
	LDD	$112	; Set player's ship to center of screen,
	STB	$5D42	; Clear all players' shots,
	STA	$5D3F	; Initialize bonus round # to 1,
	EORA	$B000	; Nastie level to "Evil Eyes", and
	STA	$5D40	; special effects values
	LDA	#$3A
	STA	SHPPOS
	STA	SHPOS1
	CLR	SHOT1F
	CLR	SHOT2F
	LDA	#1
	STA	BROND1
	STA	BROND2
	STA	NOWGUY
	STA	NWGY1
	CLR	BEEPER
	CLR	BEEPR1
	LDA	#4
	STA	SPXCNT
	JSR	NUMPUT	; Put scroes on Screen
	JSR	PLYMS	; Put "Player 1" (or 2) on screen
SHEET	CLR	ALARM	; Turn off alarm, reset to no Nasties hit
	CLR	HTPOD
	LDU	#TABX	; Clear all the crosshatches from the
	LDB	#8	; bottom of the screen
	STB	LOOPER
TBXCL	CLR	,U+
	DEC	LOOPER
	BNE	TBXCL
	CLR	ALARM1	; Clear some inconsequential values,
	JSR	LEVELS	; set player's difficulty level
	CLR	BONCNT
	LDA	#$28	; Fix time-related items
	STA	CNTER
	CLR	TMCRTC
	LDA	#$FF
	STA	BARCOL
	LDA	#40
	STA	BONAMT
	CLR	SHTTHR	; Fix shot-related items
	CLR	SHPZAP
	LBRA	BONCHK	; Check for Bonus round
CHEKD1	LDU	#XPOS	; Get ready for a loop (to make 8 pods)
	LDB	#8
	STB	CNTDED
	STB	LOOPER
STRTLP	CLR	4,U	; Clear some Nastie stuff
	CLR	5,U
RNDXNX	JSR	$5D21	; Get a suitable X value (so the pod
	LDA	$5D3F	; fits on the screen)
	ANDA	#$7F
	CMPA	#2
	BLO	RNDXNX
	CMPA	#$78
	BLO	GOODX
	BRA	RNDXNX
GOODX	STA	,U
BADY	JSR	$5D21	; Get a suitable Y value
	LDA	$5D3F
	ANDA	#$3F
	CMPA	#9
	BLO	BADY
	CMPA	#$30
	BLO	GOODY
	SUBA	#$18
GOODY	STA	1,U
BADPOS	JSR	$5D21	; Get a random position in the
	LDA	$5D3F	; move sequence
	CMPA	#$AA
	BLO	GDPOS
	SUBA	#$59
GDPOS	TFR	A,B
	CLRA
	LDX	#$5BDC
	LEAX	D,X
	STX	6,U
	LDA	5,U	; Put proper place in
	LSLA		; animation sequence
	LDX	#$5DDF
	LDX	A,X
	STX	8,U
	LDA	#1	; Give him pseudo-life (pod is dormant)
	STA	10,U
	LEAU	11,U	; Go for next one
	DEC	LOOPER
	BNE	STRTLP
CHKED	JSR	ON	; Put ship on screen
	LDU	#XPOS
	LDB	#8
	STB	LOOPER	; Move the spores (put them on screen)
STMVLP	JSR	SPORMV
	LEAU	11,U
	DEC	LOOPER
	BNE	STMVLP
LOP	JSR	NUMPUT	; Put all scores on the screen
	JSR	TIME	; Tick-tock
	JSR	MOVSHP	; Move ship  (if necessary)
	JSR	MOVSTR	; Move background stars
	LDX	LEVDEL	; Load X with delay value
	LDA	#20
	LDB	SCROFF
	MUL		; Make less delay for each bunch
	COMA		; of numbers printed
	COMB
	ADDD	#1
	LEAX	D,X
	TST	STRCNT	; Less delay if armor "string" shots
	BNE	DESAME	; are active
	CMPX	#$380
	BCS	DELESS
	LEAX	-896,X
	BRA	DESAME
DELESS	LDX	#1
DESAME	STX	DELAY	; Delay
	LDX	DELAY
POLLOP	LEAX	-1,X
	BNE	POLLOP
	LDS	#$7F00	; Load stack (just in case)
	JSR	BEEPIT	; If he earned another player, beep
	TST	CNTDED	; Check if Nasties are all dead.
	BNE	MOVEIT	; If not...
	TST	SHTTHR	; Check if all Nastie shots are off screen
	BNE	MOVEIT	; If not...
	TST	SCROFF	; check if all Bonus scores are off screen
	BNE	MOVEIT	; If not...
	DEC	CNTER	; If counter is finished counting down, go
	LBEQ	BPOINT
MOVEIT	JSR	$5D21	; Get random number
	JSR	UPDSHT	; Update player's shots
	JSR	DOSHOT	; Update Nasties' shots
	LDU	#XPOS	; Check if any Nasites are hit
	LDB	#8
	STB	LOOPER
CKHTL1	TST	10,U
	BEQ	CKHTL2
	JSR	HITCHK
CKHTL2	LEAU	11,U
	DEC	LOOPER
	BNE	CKHTL1
	INC	CYCLE	; The rest only happens once every
	LDA	CYCLE	; 2 cycles
	CMPA	#2
	BNE	LOP
	CLR	CYCLE
	INC	CYCLE1	; A second counter
	LDA	CYCLE1
	CMPA	#4
	BNE	CYCLE2
	CLR	CYCLE1
CYCLE2	CLR	ALARM	; Erase, update, and reprint each spore
	LDU	#XPOS
	LDB	#8
	STB	LOOPER
ERPTLP	JSR	$560F
	JSR	$5D21
	JSR	SPORMV
	LEAU	11,U
	DEC	LOOPER
	BNE	ERPTLP
	LDU	#XPOS
	LDB	#8
	STB	LOOPER
PTSPLP	LDA	BROUND	; Put spores on screen again (in case
	CMPA	#3	; of erasure from proximity to another
	BNE	PTSPL1	; being erased in previous loop)
	TST	CYCLE1
	BNE	PTSPL2
PTSPL1	JSR	$55B5
PTSPL2	LEAU	11,U
	DEC	LOOPER
	BNE	PTSPLP
	JSR	PUTSTR	; Put stars
	JSR	PUTX	; Put crosshatches at bottom (bonus round)
	LBRA	LOP	; Keep on loopin'
TIME	TST	CNTDED	; Count time up, unless Nasties are dead
	BNE	TIME1	; Once a certain number is reached, make
	RTS		; a click and shorten time line.
TIME1	LDA	BONCNT
	INCA
	STA	BONCNT
	CMPA	BONBYT
	BNE	BONRET
	CLR	BONCNT
	DEC	BONAMT
	LBEQ	ZAPIT
	JSR	TMLNPT
	LDA	BONAMT
CLICK	CLRA
	LDB	BONAMT
	LSLB
	ADDB	#$10
	STD	$5CF2
	STD	$5D03
	JSR	$5CC8
	JSR	$5CC8
	JSR	$5CC8
	JSR	$5CC8
BONRET	LDA	TMCRTC	; If time approaches zero, a warning
	TSTA		; sounds, and the line flashes.
	BEQ	NOCRTC
	DECA
	STA	TMCRTC
	CMPA	#5
	BCC	BLNKT1
	JSR	TMLNOT
	BRA	BLNKET
BLNKT1	LDX	#$E2B
	LDB	#10
BLNKT4	CLR	128,X
	CLR	96,X
	CLR	64,X
	CLR	32,X
	CLR	,X+
	DECB
	BNE	BLNKT4
BLNKET	LDD	#$12
	STD	$5CF2
	STD	$5D03
	LDB	#10
BLNK2	PSHS	B
	JSR	$5CC8
	PULS	B
	DECB
	BNE	BLNK2
	RTS
NOCRTC	LDA	BONAMT	; If time is low, set flag, put
	CMPA	#9	; time line
	BCC	TMPT6
	LDA	#8
	STA	TMCRTC
TMPT6	JSR	TMLNPT
BONRT1	RTS
TMLNOT	LDA	#$AA	; Put red time line down, next
	STA	BARCOL	; will be black (simulating
	JSR	TMLNPT	; flashing)
	LDA	#$0
	STA	BARCOL
	RTS
TMLNPT	LDX	#$E2B	; Put time line on screen
	LDA	BONAMT
TMLN2	CMPA	#4
	BCC	NXTMPT
	LDY	#TMTBL
	LDB	A,Y
	ANDB	BARCOL
	STB	,X+
	CLR	,X
	LDA	$59D5
	STA	$E35
	LDA	$59D6
	STA	$E36
	BRA	TMLN9
NXTMPT	LDB	#$FF
	ANDB	BARCOL
	STB	,X+
	SUBA	#4
	BRA	TMLN2
TMLN9	LDX	#$E2B
	LDB	#10
TMLN91	LDA	,X
	STA	32,X
	STA	64,X
	STA	96,X
	STA	128,X
	LEAX	1,X
	DECB
	BNE	TMLN91
	RTS
TMTBL	FCB	0	; Table of partial-byte line bits
	FCB	$C0
	FCB	$F0
	FCB	$FC
ZAPIT	LDX	#$E2B	; Clear remains of line (fuel is gone)
	CLR	,X
	CLR	32,X
	CLR	64,X
	CLR	96,X
	CLR	128,X
	LDU	#XPOS	; Erase Nasties
	LDB	#8
	STB	LOP1
LOPLOP	JSR	$560F
	LEAU	11,U
	DEC	LOP1
	BNE	LOPLOP
	LDU	#XPOS	; For all live and half-live Nasties,
	LDB	#8	; change them to real live Nasties
	STB	LOP1	; and beep
BLEPLP	TST	10,U
	BEQ	NOBODY
	TST	5,U
	BNE	CHNGUY
	LDA	NOWGUY
	STA	5,U
	LDB	5,U
	CLRA
	NEGB
	ADDB	#10
	LSLB
	LSLB
	LSLB
	STD	$5CF2
	STD	$5D03
	LDB	#16
	STB	LOP2
BLPLP1	JSR	$5CC8
	DEC	LOP2
	BNE	BLPLP1
CHNGUY	PSHS	Y,X
	JSR	$55B5
	PULS	X,Y
NOBODY	LEAU	11,U
	DEC	LOP1
	BNE 	BLEPLP
	LDU	#XPOS	; Make all Nasties do a zap-shot
	LDY	#SHTTBL	; at ship
	LDB	#8
	STB	LOP1
LOP63	TST	10,U
	BEQ	NBODY
	LDX	#$5DD6
	LDA	5,U
	LDA	A,X
	ORA	#$80
	NEGA
	LSRA
	DECA
	ADDA	,U
	STA	,Y
	LDA	3,U
	ADDA	1,U
	DECA
	STA	1,Y
	LDA	#1
	STA	2,Y
	INCA
	STA	3,Y
	CLR	4,Y
	PSHS	Y
	CLR	SHPZAP
	JSR	DOSHOT
	PULS	Y
NBODY	LEAU	11,U
	DEC	LOP1
	BNE	LOP63
BLOWUP	TST	BROUND	; If only a bonus round, fix a few
	BEQ	BLOWP1	; things:
	CLR	BROUND	; Clear all shots,
	CLR	NOWGUY	; Clear bonus scores,
	JSR	DECFX	; Do special effects,
	CLR	SHOT1F	; Put stars, and
	CLR	SHOT2F	; Let player keep on playing
	JSR	ON
	JSR	PUTSTR
	LDX	#0
	JSR	DELAY3
	LDY	#SHTTBL
	LDA	#40
CLRSH	CLR	,Y+
	DECA
	BNE	CLRSH
	LDY	#SCRTBL
	LEAX	CNSTNT,Y
	LDB	#80
CLRSC8	CLR	,Y+
	CLR	,X+
	DECB
	BNE	CLRSC8
	JMP	BRONUP
BLOWP1	CLRA		; This is a real loss - decrement
	LDA	PLYNO	; number of players, and explode
	LSLA
	LDX	#PLYNOT
	LDX	A,X
	STX	YSTOR
	LEAX	8,X
	DEC	,X
	BCC	NODCNX
	DEC	-1,X
	LDA	,X
	ADDA	#$0A
	STA	,X
NODCNX	LDX	YSTOR
	LDY	#SCRTBL
	LDA	PLYNO
	LDB	#91
	MUL
	ADDB	#1
READY7	TST	5,Y
	BEQ	READY8
	LDA	#2
	STA	5,Y
	LEAY	7,Y
	BRA	READY7
READY8	LDA	#1
	STA	5,Y
	STA	1,Y
	STX	3,Y
	LDA	#$FF
	STA	6,Y
	STB	,Y
	LDA	#9
	STA	2,Y
	JSR	NUMPUT
	JSR	NUMPUT
	JMP	XPLODE
AFTXPD	JSR	MKSTBL	; Make a new star table, change
	LDA	PLYNO	; players if necessary
	EORA	NOPLAY
	STA	PLYNO
	LDX	#PLYNOT
	CLRB
	LSLA
	LDX	A,X
	LEAX	8,X
	TST	,X
	LBNE	AFTXP2
	TST	-1,X
	LBNE	AFTXP2
	LDB	NOPLAY
	TSTB
	BEQ	GAMEND
	LDA	PLYNO
	EORA	#1
	STA	PLYNO
	LDX	#PLYNOT
	CLRB
	LSLA
	LDX	A,X
	LEAX	8,X
	TST	,X
	LBNE	AFTXP1
	TST	-1,X
	LBNE	AFTXP1
GAMEND	JSR	SPFX	; Do special effects. print "Game Over".
	JSR	GMOVER	; check larger of the two scores to see
	LDX	#PLY1SC	; if it would be in the high score table
	LDY	#PLY2SC	; (If only one player, player 2's score
	LDB	#6	; (is "000000")
INSCND	LDA	,X
	ADDA	#$70
	STA	,X+
	LDA	,Y
	ADDA	#$70
	STA	,Y+
	DECB
	BNE	INSCND
HISSCK	LDX	#PLY1SC
	LDU	#PLY2SC
	JSR	COMPAR
	LDA	#10
	STA	PERMUT
	LDA	PLAYER
	ADDA	#$70
	STA	$8B3
	LDX	#$673
	TFR	U,Y
HISCK2	PSHS	Y
	JSR	COMPAR
	CMPU	,S++
	BEQ	MOVBAK
	DEC	PERMUT
	LBEQ	TITLP2
	LEAU	32,U
	EXG	X,U
	TFR	Y,U
	BRA	HISCK2
MOVBAK	DEC	PERMUT	; Insert name in appropriate place, after
	STU	SCRPOS	; moving other names down the list.
	PSHS	U,Y,X	; Then set that player's score to zero and
	JSR	INPUT	; go back to check other player.
	PULS	X,Y,U	; Eventually, both will be zero and neither
	LDA	PERMUT	; will be eligible for a high score.
	STA	PRMUT1
	PSHS	Y,X
	LDX	#$78A
	TSTA
	BEQ	MVBAK6
MVBAK1	LDB	#15
MVBAK2	LDA	-32,X
	STA	,X+
	DECB
	BNE	MVBAK2
	LEAX	-47,X
	DEC	PRMUT1
	BNE	MVBAK1
MVBAK6	LDY	#$90C
	LDB	#8
MVBAK3	LDA	,Y+
	STA	,X+
	DECB
	BNE	MVBAK3
	LEAX	1,X
	LDB	#6
	LDY	SCRPOS
MVBAK4	LDA	,Y
	CLR	,Y+
	STA	,X+
	DECB
	BNE	MVBAK4
	PULS	X,Y
	JMP	HISSCK
COMPAR	PSHS	U	; Check between two scores, pointed to
	PSHS	X	; by X and U
	LDB	#6
COMPR2	LDA	,X
	CMPA	,U
	BCS	HLBIGR
	BNE	DEBIGR
	LEAX	1,X
	LEAU	1,U
	DECB
	BNE	COMPR2
DEBIGR	LDA	#1
	STA	PLAYER
	PULS	U
	PULS	X,PC
HLBIGR	LDA	#2
	STA	PLAYER
	PULS	X
	PULS	U,PC
INPUT	LDA	$FF22	; Flip to name input screen, rotate
	ANDA	#7	; border, and input name
	STA	$FF22
	STA	$FFC0
	STA	$FFC2
	STA	$FFC4
	STA	$FFC6
	STA	$FFC8
	STA	$FFCB
	CLR	INPLCE
	LDX	#$90C
	STX	INPLOC
	LDA	#$60
	LDB	#8
INPLP	STA	,X+
	DECB
	BNE	INPLP
INPLP1	JSR	ROTATE
	LDY	#$20
INPLP2	PSHS	Y
	JSR	[$A000]
	PULS	Y
	CMPA	#8
	BEQ	BACKP1
	CMPA	#$0D
	BEQ	ENDIT6
	CMPA	#$20
	BCS	INPLP3
	JSR	PTCHR1
INPLP3	LEAY	-1,Y
	BNE	INPLP2
	BRA	INPLP1
BACKP1	TST	INPLCE
	BEQ	INPLP2
	DEC	INPLCE
	LDX	INPLOC
	LEAX	-1,X
	STX	INPLOC
	LDA	#$60
	STA	,X
	BRA	INPLP2
ENDIT6	RTS
PTCHR1	LDB	INPLCE
	CMPB	#8
	BEQ	PTCHR2
	ORA	#$40
	LDX	INPLOC
	STA	,X+
	STX	INPLOC
	INC	INPLCE
PTCHR2	RTS
AFTXP2	LDB	NOPLAY	; Switch player-dependent variables
	TSTB
	BEQ	AFTXP1
	LDA	NOWGUY
	LDB	NWGY1
	STA	NWGY1
	STB	NOWGUY
	LDA	BEEPER
	LDB	BEEPR1
	STB	BEEPER
	STA	BEEPR1
	LDA	BROND1
	LDB	BROND2
	STB	BROND1
	STA	BROND2
AFTXP1	LDY	#SCRTBL	; Put ship in centre of screen,
	LDB	#$3A	; change colors of scores (to indicate
	STB	SHPOS1	; which player in playing),
	STB	SHPPOS	; Make a special effect occur,
	LDU	#PLYNOT	; Put player message on screen
	LDX	,U
	STX	3,Y
	LDX	2,U
	STX	10,Y
	LDA	#1
	STA	5,Y
	STA	1,Y
	STA	8,Y
	STA	12,Y
	STA	,Y
	LDA	#9
	STA	2,Y
	STA	9,Y
	LDA	PLYNO
	LDX	#CLTBL2
	LDA	A,X
	STA	6,Y
	EORA	#$AA
	STA	13,Y
	LDA	#92
	STA	7,Y
	JSR	NUMPUT
	JSR	SPFX
	JSR	PLYMS
	LDY	#SHTTBL
	LDA	#40
CLRST1	CLR	,Y+	; Clear all shots and bonus points
	DECA		; from screen, go for next wave of
	BNE	CLRST1	; attackers
	LDY	#SCRTBL
	LEAX	CNSTNT,Y
	LDB	#80
CLRSC1	CLR	,Y+
	CLR	,X+
	DECB
	BNE	CLRSC1
	CLR	SHOT1F
	CLR	SHOT2F
	JMP	BONRND
SPFX	DEC	SPXCNT	; Determine which effect is to be used
	BNE	NXTFX
	LDA	#4
	STA	SPXCNT
NXTFX	CLRA
	LDA	SPXCNT
	LSLA
	LDX	#SPXTBL
	LDX	A,X
	JMP	,X
SPXTBL	FDB	0
	FDB	DECFX
	FDB	SCRLFX
	FDB	BARSFX
	FDB	NOFX
DECFX	LDX	$5D8D	; Clear screen by shifting bits right,
	LEAX	288,X	; and making sound if it is to be shifted.
	LDA	#$0A	; When screen is blank,(except for score),
	STA	LOOPER	; it exits routine.
DCNXF1	TST	,X
	BEQ	DCNXFX
	LSR	,X
	LDB	,X
	ANDB	#$0F
	INCB
	CLRA
	STD	$5CF2
	STD	$5D03
	LDB	#4
	STB	LINCNT
DCFXSN	JSR	$5CC8
	DEC	LINCNT
	BNE	DCFXSN
DCNXFX	LEAX	1,X
	CMPX	#$1A00
	BLO	DCNXF1
	DEC	LOOPER
	BEQ	OUTFX
	LDX	$5D8D
	LEAX	288,X
	BRA	DCNXF1
SCRLFX	LDX	$5D8D	; Scroll graphics up off the screen,
	LEAX	288,X	; making sound all the way
	CLR	LOOPER
SCRL1	LDA	$40,X
	STA	,X+
	CMPX	#$19C0
	BLO	SCRL1
CNTSCR	CLR	,X+
	CMPX	#$1A00
	BLO	CNTSCR
	DEC	LOOPER
	LDB	LOOPER
	CMPB	#$D5
	BEQ	OUTFX
	CLRA
	SUBB	#$D0
	STD	$5CF2
	STD	$5D03
	LDB	#10
	STB	LINCNT
SCRSND	JSR	$5CC8
	DEC	LINCNT
	BNE	SCRSND
	LDX	$5D8D
	LEAX	288,X
	BRA	SCRL1
OUTFX	RTS
BARSFX	LDX	$5D8D	; Make a white bar come down down and
	LEAX	288,X	; "wipe clear" screen from graphics,
MKWHT	LDA	#$FF	; making sound all the way
	STA	,X+
	CMPX	#$F40
	BNE	MKWHT
CONTBR	LDA	-32,X
	CLR	-32,X
	STA	,X+
	CMPX	#$1A20
	BHS	OUTFX
	TFR	X,D
	STD	STORY
	ANDB	#$1F
	BNE	CONTBR
	LDD	STORY
	RORA
	RORB
	RORA
	RORB
	RORA
	RORB
	RORA
	RORB
	RORA
	RORB
	ANDB	#$0F
	INCB
	CLRA
	STD	$5CF2
	STD	$5D03
	LDB	#$30
	STB	LINCNT
BRFXSN	JSR	$5CC8
	DEC	LINCNT
	BNE	BRFXSN
	LDY	#$480
BRSFX1	LEAY	-1,Y
	BNE	BRSFX1
	BRA	CONTBR
NOFX	LDX	#$8000	; No effects.  Just delay, clear screen
NOFX1	LEAX	-1,X	; and beep.  There you have it.
	BNE	NOFX1
	LDX	$5D8D
	LEAX	288,X
NOFX2	CLR	,X+
	CMPX	#$1A00
	BNE	NOFX2
	LDD	#$40
	STD	$5CF2
	STD	$5D03
	LDB	#$30
	STB	LOOPER
NOFX3	JSR	$5CC8
	DEC	LOOPER
	BNE	NOFX3
	LBRA	OUTFX
BEEPIT	TST	BEEPER	; If player has earned an extra ship,
	BEQ	NOBEEP	; beep a few times
	DEC	BEEPER
	BEQ	INCGUY
	LDA	BEEPER
	ANDA	#4
	BEQ	NOBEEP
	LDA	#$0C
	STA	$5CF3
	CLR	$5CF2
	STA	$5D04
	CLR	$5D03
	LDB	#$14
	STB	CNTLIN
MKBEEP	JSR	$5CC8
	DEC	CNTLIN
	BNE	MKBEEP
NOBEEP	TST	ALARM	; Another alarm (for being too close
	BEQ	NOBEP2	; to a Psychlops)
	LDB	ALARM1
	INCB
	ANDB	#1
	STB	ALARM1
	TSTB
	BNE	NOBEP1
	LDA	#$58
	STA	$5CE6
	LDB	#4
ALLOOP	STB	,-S
	LDD	#$11
	STD	$5CF2
	STD	$5D03
	JSR	$5CC8
	JSR	$5CC8
	JSR	$5CC8
	LDD	#$13
	STD	$5CF2
	STD	$5D03
	JSR	$5CC8
	LDB	,S+
	DECB
	BNE	ALLOOP
	LDA	#$C0
	STA	$5CE6
	BRA	NOBEP1
NOBEP2	CLR	ALARM1
NOBEP1	RTS
INCGUY	CLRA		; Increment # of ships player
	LDA	PLYNO	; has, and put score on screen
	LSLA
	LDX	#PLYNOT
	LDX	A,X
	STX	YSTOR
	LEAX	8,X
	LDA	,X
	INCA
	CMPA	#$0A
	BCS	IT
	SUBA	#$0A
	INC	-1,X
IT	STA	,X
	LDY	#SCRTBL
SCTST1	TST	5,Y
	BNE	SCTST2
	LDX	YSTOR
	STX	3,Y
	LDA	#1
	STA	1,Y
	STA	5,Y
	LDA	#$FF
	STA	6,Y
	LDA	#9
	STA	2,Y
	LDA	PLYNO
	LDB	#91
	MUL
	INCB
	STB	,Y
	RTS
SCTST2	LEAY	7,Y
	BRA	SCTST1
BPOINT	TST	BROUND	; Put "Bonus Points" message on
	LBNE	BEND11	; screen, prepare for a decrement
	LDX	#$10AA	; loop
	LDU	#$5920
	LDB	#7
	STB	LOOPER
BPNLP1	LDB	#18
	STB	CNLIN1
BPNLP2	LDA	,U+
	STA	,X+
	DEC	CNLIN1
	BNE	BPNLP2
	LEAX	14,X
	DEC	LOOPER
	BNE	BPNLP1
	LDX	#BONBUF
	CLR	,X+
	CLR	,X+
	CLR	,X+
	CLR	,X+
	CLR	,X+
	CLR	,X
	LDA	#$FF
	STA	BARCOL
	INC	BONAMT
BONSLP	DEC	BONAMT	; Decrement time steadily, making
	LBEQ	NOMORE	; sound and creating an accumulating
	JSR	TMLNPT	; bonus score in a buffer, and on
	LDB	#6	; the screen.
	STB	NONUM	; Also show line getting shorter
	LDX	#BONBUF	; steadily
	LEAX	5,X
	DECB
	LDU	#LEVBON
	LEAU	B,U
BIG12	LDA	,X
	ADDA	,U
	CMPA	#$0A
	BCC	BIGGR1
BIG11	STA	,X
	LEAX	-1,X
	LEAU	-1,U
	DEC	NONUM
	BNE	BIG12
	BRA	NOMOR1
BIGGR1	SUBA	#$0A
	INC	-1,X
	BRA	BIG11
NOMOR1	CLRA
	LDX	#BONBUF
NOMOR3	TST	,X+
	BNE	NOMOR2
	INCA
	BRA	NOMOR3
NOMOR2	NEGA
	ADDA	#6
	STA	DIGITS
	LDY	#SCRTBL
	LDA	#1
	STA	5,Y
	LDA	#$FF
	STA	6,Y
	LDA	#23
	STA	1,Y
	LDA	DIGITS
	STA	2,Y
	SUBA	#6
	NEGA
	PSHS	U
	LDU	#BONBUF
	LEAU	A,U
	STU	3,Y
	PULS	U
	LDB	#4
	MUL
	ADDB	#14
	STB	,Y
	JSR	NUMPUT
	LDA	BONAMT
	NEGA
	ADDA	#$2C
	TFR	A,B
	CLRA
	STD	$5CF2
	STD	$5D03
	LDB	#$11
	STB	LINCNT
BSNDLP	JSR	$5CC8
	JSR	$5CC8
	LDX	#$50
BSDLP1	LEAX	-1,X
	BNE	BSDLP1
	DEC	LINCNT
	BNE	BSNDLP
	LBRA	BONSLP
NOMORE	JSR	TMLNPT	; Add bonus score to player's
	LDU	#BONBUF	; score, put it on screen, wait.
	JSR	ADDPNT
	JSR	NUMPUT
	LDX	#$D000
NOMOLP	LEAX	-1,X
	BNE	NOMOLP
BONUS1	INC	BONAMT
	LDA	BONAMT
	CMPA	#40
	BEQ	MORENO
	JSR	TMLNPT
	LDB	BONAMT
	LSRB
	NEGB
	ADDB	#$50
	CLRA
	STD	$5CF2
	STD	$5D03
	LDB	#4	; Quickly increment time,
	STB	LINCNT	; making sound
BSNLP1	JSR	$5CC8
	LDD	$5CF2
	STD	YSTOR
	LDD	#$28
	STD	$5CF2
	STD	$5D03
	JSR	$5CC8
	LDD	YSTOR
	STD	$5CF2
	STD	$5D03
	JSR	$5CC8
	DEC	LINCNT
	BNE	BSNLP1
	BRA	BONUS1
MORENO	JSR	TMLNPT	; Delay, clear off Bonus Points
	LDX	#$8000	; message, go to BEND13
MORNO1	LEAX	-1,X
	BNE	MORNO1
	LDX	#$3000
NOMLP1	LEAX	-1,X
	BNE	NOMLP1
	LDX	#$10A0
BPNLP3	CLR	,X+
	CMPX	#$1180
	BLO	BPNLP3
	BRA	BEND13
BEND11	CLR	BROUND	; Clear cross-hatches, put ship,
	CLR	NOWGUY	; put stars, delay, print
	LDX	#$1940	; "500 Extra Bonus", add 500 point,
CLRBOT	CLR	,X+	; delay, clear bonus message, delay
	CMPX	#$1A00	; again, increment bonus round num
	BNE	CLRBOT	; (applies only to bonus rounds)
	JSR	ON
	JSR	PUTSTR
	LDX	#0
	JSR	DELAY3
	JSR	$5206
	PSHS	U
	LDU	#P500
	JSR	ADDPNT
	PULS	U
	JSR	DELAY1
	JSR	DELAY1
	JSR	CLS
	LDX	#0
	JSR	DELAY3
BRONUP	LDA	BROND1
	INCA
	CMPA	#4
	BNE	BEND12
	LDA	#1
BEND12	STA	BROND1
BEND13	LDA	NOWGUY	; Go for next wave of Nasties
	INCA		; (or to Bonus Round)
	CMPA	#7
	BCS	NXTLV1
	LDA	BROND1
	STA	BROUND
	LDA	#1
NXTLV1	STA	NOWGUY
	JMP	BONRND
UPDSHT	LDA	BUTPRS	; Update shotson screen (reset
	TSTA		; pixels of old ones, set new ones)
	BNE	UPD416
	CLR	BUTPR1
UPD416	LDA	SHOT1F
	ORA	SHOT2F
	LBEQ	UPDOUT
	CLR	$5DBD
	LDA	SHOT1X
	STA	$5DBE
	LDA	SHOTY
	STA	$5DBF
	TST	SHOT1F
	BEQ	SHT1FN
	JSR	$5D8F
	INC	$5DBF
	JSR	$5D8F
	DEC	$5DBF
SHT1FN	LDA	SHOT2X
	STA	$5DBE
	TST	SHOT2F
	BEQ	SHT2FN
	JSR	$5D8F
	INC	$5DBF
	JSR	$5D8F
	DEC	$5DBF
SHT2FN	LDA	SHOTY
	SUBA	#3
	CMPA	#6
	LBEQ	STPSHT
	STA	SHOTY
	STA	$5DBF
	LDA	#$FF
	STA	$5DBD
	LDA	SHOT1X
	STA	$5DBE
	TST	SHOT1F
	BEQ	SHT1FO
	JSR	$5D8F
	INC	$5DBF
	JSR	$5D8F
	DEC	$5DBF
SHT1FO	LDA	SHOT2X
	STA	$5DBE
	TST	SHOT2F
	BEQ	SHT2FO
	JSR	$5D8F
	INC	$5DBF
	JSR	$5D8F
	DEC	$5DBF
SHT2FO	LDA	#$FE	; Chek for pause, and un-pause
	STA	$FF02
	LDA	$FF00
	BITA	#4
JOYN5	EQU	.-1
	BNE	STPT11
POS1	LDA	#$FE
	STA	$FF02
	LDA	$FF00
	ANDA	#$40
	BNE	POS1
STPT11	RTS
UPDOUT	LDA	#$FD	; Check for game abort
	STA	$FF02
	LDA	$FF00
	ANDA	#$7F
	CMPA	#$3F
	BNE	STOPIT
	LDA	#$FB
	STA	$FF02
	LDA	$FF00
	ANDA	#$7F
	CMPA	#$3F
	BNE	STOPIT
	JMP	TITLP2
STOPIT	LDA	#$FE	; Check for pause, unpause
	STA	$FF02
	LDA	$FF00
	BITA	#4
JOYN4	EQU	.-1
	BNE	STPIT1
PAUSE	LDA	#$FE
	STA	$FF02
	LDA	$FF00
	ANDA	#$40
	BNE	PAUSE
STPIT1	LDA	BUTPRS	; Check if it's OK for the player
	LDB	BUTPR1	; to shoot again
	TSTB
	BEQ	SHTABL
	STA	BUTPR1
	RTS
SHTABL	TSTA		; Set up 2 shots, make Whoop sound
	BEQ	SHT2FO
	STA	BUTPR1
	LDA	#1
	STA	SHOT1F
	STA	SHOT2F
	LDA	SHPPOS
	ADDA	#2
	STA	SHOT1X
	ADDA	#8
	STA	SHOT2X
	LDA	#$5A
	STA	SHOTY
	LDX	#$30
	STX	$5CF2
	STX	$5D03
	LDB	#18
	STB	LINCNT
LOOPSN	LDX	$5CF2
	LEAX	-2,X
	STX	$5CF2
	STX	$5D03
	JSR	$5CC8
	JSR	$5CC8
	DEC	LINCNT
	BNE	LOOPSN
	LDA	SHOTY
	LBRA	SHT2FN
STPSHT	CLR	SHOT1F	; Get rid of shots
	CLR	SHOT2F
	LBRA	UPDOUT
DOSHOT	LDY	#SHTTBL	; Check which kind of Nastie shot
	LDB	#8	; is due
	STB	CNLIN1
	CLR	SHTTHR
SHTLP	STY	STORY
	TST	2,Y
	BEQ	NSHT
	INC	SHTTHR
	LDA	3,Y
	CMPA	#1
	LBCS	PELLET
	LBEQ	STRING
	LBCC	CYCZAP
NSHT	LDY	STORY
	LEAY	5,Y
	DEC	CNLIN1
	BNE	SHTLP
	RTS
CYCZAP	LDA	,Y	; Set up to zap ship, reverse,
	LDB	1,Y	; eradicate line, and if it's been
	STA	$5BCB	; 5 zaps, destroy ship
	CLR	$5BCC
	STB	$5BCD
	CLR	$5BCE
	LDA	SHPPOS
	ADDA	#6
	STA	$5BC9
	CLR	$5BCA
	LDA	#$FF
	STA	$5BD5
	LDA	#$58
	STA	$5BC7
	CLR	$5BC8
	PSHS	Y,X
	LDX	$5BC9
	LDY	$5BCB
	STX	STXEND
	STY	STXST
	LDX	$5BC7
	STX	STYEND
	LDX	$5BCD
	STX	STYST
	JSR	$5AA6
	JSR	REVERS
	LDX	#15
DELOOP	LEAX	-1,X
	BNE	DELOOP
	JSR	REVERS
	CLR	$5BD5
	LDX	STYST
	STX	$5BCD
	LDX	STXEND
	LDY	STXST
	STX	$5BC9
	STY	$5BCB
	LDX	STYEND
	STX	$5BC7
	JSR	$5AA6
	PULS	X,Y
	LDA	SHPZAP
	INCA
	STA	SHPZAP
	CMPA	#5
	LBCC	BLOWUP
PDEADP	CLR	2,Y
	LBRA	NSHT
PELLET	LDA	LEVEL	; If over a certain level, shots
	CMPA	#$8	; double speed
	BCC	PELET1
	TST	CYCLE
	BNE	PELET1
	LBRA	NSHT
PELET1	LDA	,Y	; Clear old pellet, update screen
	STA	$5DBE	; position, and check if off-screen.
	LDA	1,Y	; Then put it back on screen.
	STA	$5DBF
	CLR	$5DBD
	JSR	$5D8F
	INC	$5DBF
	JSR	$5D8F
	LDA	1,Y
	ADDA	#2
	CMPA	#$60
	BCC	PDEADP
	STA	1,Y
	STA	$5DBF
	LDA	,Y
	ADDA	4,Y
	CMPA	#$80
	BCC	PDEADP
	STA	,Y
	STA	$5DBE
	LDA	#$AA
	STA	$5DBD
	JSR	$5D8F
	INC	$5DBF
	JSR	$5D8F
	LBRA	NSHT
STRING	LDA	4,Y	; Update ends of string shot
	CMPA	#$60
	BCC	STRNG1
	ADDA	#2
	STA	4,Y
	SUBA	1,Y
	CMPA	#20
	BCS	STRNG2
	INC	1,Y
	INC	1,Y
	BRA	STRNG2
STRNG1	LDA	1,Y
	ADDA	#2
	CMPA	#$60
	LBCC	PDEDP1
	STA	1,Y
STRNG2	LDA	#2	; Leave a space just above shot,
	STA	CNTLIN	; make red "string" shot and
	LDA	1,Y	; some sound
	SUBA	#2
	LDB	#32
	LDX	SCRST
	MUL
	LEAX	D,X
	LDA	,Y
	TFR	A,B
	ANDA	#$3
	LSRB
	LSRB
	LEAX	B,X
	PSHS	Y
	LDY	#TBSTVL
	LEAY	A,Y
	LDA	,Y
	LSR	,Y
	ORA	,Y
	LSL	,Y
	COMA
ANDLP	LDB	,X
	STA	,-S
	ANDB	,S+
	STB	,X
	LEAX	32,X
	DEC	CNTLIN
	BNE	ANDLP
	LEAX	-32,X
	LDA	,Y
	PULS	Y
	LDB	4,Y
	SUBB	1,Y
	INCB
STRLP	LEAX	32,X
	STA	,-S
	ORA	,X
	STA	,X
	LDA	,S+
	CMPB	#20
	BEQ	SND
	BRA	NOSND
SND	PSHS	X,B,A
	CLRA
	LDB	1,Y
	LSRB
	LSRB
	LSRB
	STD	$5CF2
	STD	$5D03
	JSR	$5CC8
	JSR	$5CC8
	JSR	$5CC8
	JSR	$5CC8
	PULS	A,B,X
NOSND	DECB
	CMPB	#1
	BEQ	SND
	TSTB
	BNE	STRLP
	LBRA	NSHT
PDEDP1	LDA	,Y	; Kill remains of shot
	STA	$5DBE
	LDA	#$5F
	STA	$5DBF
	CLR	$5DBD
	JSR	$5D8F
	DEC	$5DBF
	JSR	$5D8F
	DEC	$5DBF
	JSR	$5D8F
	LBRA	PDEADP
NUMPUT	CLR	SCROFF	; Put numbers on screen.
	LDY	#SCRTBL	; Decrement counter and erase
	LDB	#10	; numbers if necessary.
	STB	NONUM
NUMNXT	TST	5,Y
	BEQ	NEXTNM
	INC	SCROFF
	LDX	$5D8D
	LDA	1,Y
	LDB	#32
	MUL
	LEAX	D,X
	LDB	,Y
	TFR	B,A
	LSRB
	LSRB
	ABX
	LDB	2,Y
	STB	NOFNUM
	ANDA	#1
	STA	SHFTBT
	LDU	3,Y
	PSHS	Y
NXNMLP	CLRA
	LDA	,U+
	LSLA
	LDY	#$5568
	LDY	A,Y
	LDB	#5
	STB	BTINUM
NUMLOP	LDA	,Y+
	TST	SHFTBT
	BEQ	NOSHBT
	LSRA
	LSRA
NOSHBT	STY	YSTOR
	PULS	Y
	ANDA	6,Y
	PSHS	Y
	LDY	YSTOR
	STA	,X
	LEAX	32,X
	DEC	BTINUM
	BNE	NUMLOP
	LEAX	-159,X
	DEC	NOFNUM
	BNE	NXNMLP
	PULS	Y
	DEC	5,Y
	LDA	5,Y
	CMPA	#1
	BNE	NEXTNM
	LDU	#EMPBUF
	STU	3,Y
NEXTNM	DEC	NONUM
	BEQ	OUTNUM
	LEAY	7,Y
	LBRA	NUMNXT
OUTNUM	RTS
SPORMV	TST	10,U	; If Nastie is dead, delay
	BNE	SPRMV1
	LDX	#100
DELOP	LEAX	-1,X
	BNE	DELOP
	RTS
SPRMV1	LDA	5,U	; If exploding, make noise and
	CMPA	#8	; go to animate
	BNE	SPRMV2
	LDB	#$0A
	STB	LINCNT
XPSOND	JSR	$5D21
	LDB	$5D3F
	ANDB	#$3F
	ADDB	#5
	CLRA
	STD	$5CF2
	LDB	$5D40
	ANDB	#$3F
	ADDB	#5
	STD	$5D03
	JSR	$5CC8
	DEC	LINCNT
	BNE	XPSOND
	LBRA	SPRANM
SPRMV2	LDA	5,U	; Go to respective move/shoot
	TSTA		; routines
	LBEQ	SPRMV3
	CMPA	#5
	LBEQ	STRSHT
	CMPA	#6
	LBEQ	PSYMOV
	BCC	BRDMOV
	BITA	#1
	BNE	RNDMOV
NORMOV	JSR	UPDOWN	; Cause Nastie to have vertical
	LDA	5,U	; motion. (Cross/Stomper)
	CMPA	#4	; If Cross/Stomer at bottom, make
	BNE	NORMY1	; him stay there momentarily.
	LDB	10,U	; Track player's ship (home in)
	ANDB	#$1E	; Always go to pellet shot.
	CMPB	#$1E
	BNE	NOROUT
NORMY1	LDX	#$5DD6
	LDA	A,X
	ORA	#$80
	COMA
	LSRA
	ADDA	,U
	STA	,-S
	LDA	SHPPOS
	ADDA	#6
	CMPA	,S+
	BEQ	NOROUT
	BCS	LEFTMV
	JSR	INCX
	BRA	NOROUT
LEFTMV	JSR	DECX
NOROUT	LBRA	PELSHT
RNDMOV	JSR	UPDOWN	; Cause Nastie to have vertical
	TST	10,U	; motion. (Evil Eyes/Qube)
	BNE	RNMV1	; Move in a random horizontal
	RTS		; direction and random duration.
RNMV1	LDA	10,U	; Always go to pellet shot.
	TFR	A,B
	ANDA	#$E1
	ANDB	#$1E
	BNE	NONURN
	ANDA	#$81
	STA	10,U
	LDA	$5D3F
	ANDA	#$60
	ORA	10,U
	LDB	$5D3F
	ANDB	#$0E
	ORB	#2
	CMPB	#9
	BCS	NONURN
	SUBB	#8
NONURN	SUBB	#2
	STA	10,U
	ORB	10,U
	STB	10,U
	BITA	#$40
	BEQ	TRYRT
	JSR	DECX
TRYRT	BITA	#$20
	BEQ	RNDOUT
	JSR	INCX
RNDOUT	LBRA	PELSHT
BRDMOV	LDA	10,U	; Move Bird right or left.
	BITA	#$40	; If it goes off of screen,
	BEQ	TRYRT1	; it disappears.
	JSR	DECX
	LDA	,U
	DECA
	BNE	BRDOUT
	CLR	10,U
	DEC	CNTDED
	BRA	BRDOUT
TRYRT1	JSR	INCX
	LDA	,U
	LDB	5,U
	LDX	#$5DD6
	LDB	B,X
	DECB
	STB	,-S
	CMPA	,S+
	BLO	BRDOUT
	CLR	10,U
	DEC	CNTDED
BRDOUT	LBRA	SPRANM
PSYMOV	JSR	UPDOWN	; Psychlops: Make it move on
	LDA	10,U	; suitable diagonal.
	BITA	#$40	; Check if in sutiable range
	BEQ	TRYRT2	; to use his weapon. If yes,
	JSR	DECX	; use alarm, setup for shot,
	BRA	PSYOUT	; and only arm it if probability
TRYRT2	JSR	INCX	; for that difficulty level
PSYOUT	LDA	3,U	; dictates so.
	ADDA	1,U
	LDB	5,U
	PSHS	X
	LDX	#$5DD6
	LDB	B,X
	PULS	X
	ORB	#$80
	NEGB
	LSRB
	DECB
	ADDB	,U
	LDY	#SHTTBL
NEXSH1	TST	2,Y
	BNE	NEXTSH
	STA	1,Y
	STB	,Y
	LDA	#2
	STA	3,Y
	LDA	SHPPOS
	ADDA	#6
	SUBA	,Y
	BCC	NNEGA
	NEGA
NNEGA	LDB	#$58
	SUBB	1,Y
	STB	,-S
	ADDA	,S+
	CMPA	#45
	BCC	NOZAP
	LDA	#1
	STA	ALARM
	JSR	$5D21
	LDA	$5D3F
	ANDA	CYCPRB
	BNE	NOZAP
	LDA	#1
	STA	2,Y
	BRA	NOZAP
NEXTSH	LEAY	5,Y
	BRA	NEXSH1
NOZAP	LBRA	SPRANM
STRSHT	LDA	10,U	; If already shooting, don't
	ANDA	#$1E	; shoot; hang motionless.
	BEQ	STRSH1	; Otherwise, make random number
	SUBA	#2	; and check if probability
	ORA	#1	; dictates to shoot.
	STA	10,U	; Check if maximum number has
	LBRA	SPRANM	; been reached; if all is OK,
STRSH1	JSR	$5D21	; set up table for string shot
	LDA	$5D3F	; and cause that Nastie to sit
	ANDA	ARMPRB	; there until string shot is
	BNE	NOSTR	; done.
	LDA	STRNO
	STA	SHCON
	LDA	3,U
	ADDA	1,U
	LDB	5,U
	PSHS	X
	LDX	#$5DD6
	LDB	B,X
	PULS	X
	ORB	#$80
	NEGB
	LSRB
	DECB
	ADDB	,U
	LDY	#SHTTBL
NXSH1	TST	2,Y
	BNE	NXTSH
	STA	1,Y
	STA	4,Y
	STB	,Y
	LDA	#1
	STA	3,Y
	STA	2,Y
	LDA	#13
	STA	10,U
	LBRA	SPRANM
NXTSH	LEAY	5,Y
	DEC	SHCON
	BNE	NXSH1
NOSTR	LBRA	SPRMV3
PELSHT	JSR	$5D21	; Get random numebr and check
	LDA	$5D3F	; if OK to shoot. If OK, set
	PSHS	X	; up table to shoot, in random
	LDX	#FLGPRB	; direction.
	LDB	5,U
	DECB
	ANDA	B,X
	BNE	NOPEL1
	LDX	#FLGNO
	LDA	B,X
	PULS	X
	STA	SHCON
	LDA	3,U
	ADDA	1,U
	LDB	5,U
	PSHS	X
	LDX	#$5DD6
	LDB	B,X
	PULS	X
	ORB	#$80
	NEGB
	LSRB
	DECB
	ADDB	,U
	LDY	#SHTTBL
NXSH11	TST	2,Y
	BNE	NXTSH1
	STA	1,Y
	STB	,Y
	CLR	3,Y
	LDA	#1
	STA	2,Y
NXRND	JSR	$5D21
	LDA	$5D3F
	ANDA	#3
	BEQ	NXRND
	SUBA	#2
	STA	4,Y
	BRA	NOPEL
NXTSH1	LEAY	5,Y
	DEC	SHCON
	BNE	NXSH11
	BRA	NOPEL
NOPEL1	PULS	X
NOPEL	LBRA	SPRANM
UPDOWN	LDA	10,U	; Check if it is to go up or down
	BITA	#$80	; and make it do that. If Stomper,
	BNE	UP	; at bottom, detain him there for
DOWN	JSR	INCY	; a timny bit of time. If hits the
	LDA	10,U	; middle point going up, bounce
	BITA	#$80	; back down (unless Psychlops -
	BNE	TRUBBL	; for him only if it hits the top)
	RTS
TRUBBL	LDA	5,U
	CMPA	#4
	BEQ	TRUBL1
	RTS
TRUBL1	LDA	10,U
	SUBA	#2
	ANDA	#$7F
	STA	10,U
	BITA	#$1E
	BEQ	TRUBL2
	RTS
TRUBL2	ORA	#$9E
	STA	10,U
	RTS
UP	JSR	DECY
	LDA	5,U
	CMPA	#6
	BEQ	NOWORY
	LDA	1,U
	CMPA	#$30
	BCC	NOWORY
	LDA	10,U
	ANDA	#$7F
	STA	10,U
NOWORY	RTS
SPRMV3	LDX	6,U	; Move Nasties according to sequence
	LDA	,X	; table; if table finishes, recycle.
	CMPA	#10
	BHS	SUBIT
	LEAX	1,X
	STX	6,U
	BRA	DONE
SUBIT	LDB	,X
	NEGB
	STB	ADDER
	FDB	$3088
ADDER	FCB	$0
	STX	6,U
	BRA	SPRMV3
DONE	CMPA	#9
	BEQ	OUTOHR
	PSHS	A
	CMPA	#7
	BEQ	CLDECY
	CMPA	#2
	BCS	CLDECY
	BEQ	CMPXBT
	CMPA	#6
	BNE	CLINCY
CMPXBT	PULS	A
	TSTA
	BEQ	OUTOHR
	CMPA	#4
	BEQ	OUTOHR
	BCS	CLINCX
CLDECX	BSR	DECX
	BRA	OUTOHR
CLINCY	BSR	INCY
	BRA	CMPXBT
CLDECY	BSR	DECY
	BRA	CMPXBT
CLINCX	BSR	INCX
OUTOHR	LBRA	SPRANM
DECX	DEC	,U	; Move left. If hits wall, bounce.
	BNE	DEKXOT
	INC	,U
	LDA	10,U
	EORA	#$60
	STA	10,U
DEKXOT	RTS
DECY	DEC	1,U	; Move up. If hits ceiling, bounce.
	DEC	1,U
	LDA	1,U
	CMPA	#9
	BCC	NDECY
	LDA	#9
	STA	1,U
	LDA	10,U
	ANDA	#$7F
	STA	10,U
NDECY	RTS
INCY	LDA	#$5F	; Move down. If hits bottom, bounce
	LDB	5,U	; unless bonus round, in which case it
	PSHS	X	; it dies and becomes a crosshatch
	LDX	#$5DCD	; roadblock
	SUBA	B,X
	PULS	X
	STA	SRBYTE
	LDB	1,U
	INCB
	INCB
	CMPB	SRBYTE
	BLO	NINCY
	LDB	SRBYTE
	LDA	10,U
	ORA	#$80
	STA	10,U
	LDA	BROUND
	CMPA	#1
	BNE	NINCY
	LDA	,U
	INCA
	CLR	10,U
	PSHS	U,B
	LDU	#TABX
NXTX9	TST	,U+
	BNE	NXTX9
	STA	-1,U
	DEC	CNTDED
	PULS	B,U
NINCY	STB	1,U
	RTS
INCX	STX	,--S	; Move right.  If hits wall, bounce.
	LDX	#$5DD6
	LDA	5,U
	LDA	A,X
	LDX	,S++
	STA	,-S
	LDB	,U
	INCB
	CMPB	,S+
	BLS	NINCX
	LEAS	-1,S
	LDB	,S+
	LDA	10,U
	EORA	#$60
	STA	10,U
NINCX	STB	,U
	RTS
SPRANM	TST	10,U	; Go get next phase of animation.
	BNE	SPRAN1	; If explosion at the end, kill it.
	RTS		; Otherwise at end recycle.
SPRAN1	LDX	8,U	; Then put Nastie.
	LDA	,X
	CMPA	#10
	BHS	SUBIT1
	LEAX	1,X
	STX	8,U
	BRA	DONE1
SUBIT1	LDB	,X
	CMPB	#$FB
	BNE	SUBIT2
	CLR	10,U
	DEC	CNTDED
	RTS
SUBIT2	STB	ADDER1
	FDB	$3088
ADDER1	FCB	0
	STX	8,U
	BRA	SPRANM
DONE1	STA	4,U
	LDA	BROUND
	CMPA	#3
	BNE	SPORM2
	TST	CYCLE1
	BNE	SPORM1
SPORM2	JSR	$55B5
SPORM1	RTS
HITCHK	LDA	10,U
	ORA	#1
	STA	10,U	; Elaborate check to see if
	LDB	5,U	; player's shot has hit a
	CMPB	#8	; specified Nastie.
	BEQ	RET
	LDB	1,U
	ADDB	3,U
	CMPB	SHOTY
	BLO	RET
	LDB	SHOTY
	ADDB	#3
	CMPB	1,U
	BLO	RET
	CMPA	#8
	BEQ	RET
	TST	SHOT1F
	BEQ	TESTS2
	LDA	SHOT1X
	LDB	5,U
	LDX	#$5DD6
	LDB	B,X
	ORB	#$80
	COMB
CHK11	CMPA	,U
	BEQ	HIT1
CHK12	DECA
	DECB
	BNE	CHK11
TESTS2	TST	SHOT2F
	BEQ	RET
	LDA	SHOT2X
	LDB	5,U
	LDX	#$5DD6
	LDB	B,X
	ORB	#$80
	COMB
CHK21	CMPA	,U
	BEQ	HIT2
CHK22	DECA
	DECB
	BNE	CHK21
RET	RTS
HIT1	CLR	ERR
	JSR	HIT11
	TST	ERR
	BNE	CHK12
	CLR	SHOT1F
	LDA	SHOT1X
	BRA	HIT
HIT2	CLR	ERR
	JSR	HIT11
	TST	ERR
	BNE	CHK22
	CLR	SHOT2F
	LDA	SHOT2X
HIT	STA	$5DBE	; Reset Player's shot, erase
	CLR	$5DBD	; Mastie (it's been hit).
	LDA	SHOTY
	STA	$5DBF
	JSR	$5D8F
	INC	$5DBF
	JSR	$5D8F
	DEC	$5DBF
	PSHS	Y,X,B,A
	JSR	$560F
	PULS	A,B,X,Y
	CLR	4,U
	PSHS	Y,X,B,A
	LDA	5,U	; Check if Nastie was a Bird.
	CMPA	#7	; If yes, check if first bonus
	LBNE	NOTBRD	; round. If yes, make bonus
	LDA	BROUND	; score of 2000 on screen and
	CMPA	#1	; in player's score.
	BNE	BRD69
	LDY	#SCRTBL
NNM1	TST	5,Y
	BNE	NNM
	PSHS	U,X
	LDA	#30
	STA	5,Y
	LDU	#BBBUFF
	LEAX	2,U
	JSR	ADDPNT
	STX	3,Y
	PULS	X,U
	LDA	,U
	STA	,Y
	LDA	1,U
	STA	1,Y
	LDA	#4
	STA	2,Y
	LDA	#$AA
	STA	6,Y
	BRA	NOTBRD
NNM	LEAY	7,Y
	BRA	NNM1
BRD69	JSR	$5D21	; Bird, but worth 100-800 points.
	LDB	$5D40	; Get random value, put it on
	ANDB	#7	; screen, and add it to player's
	INCB		; score.
	LDA	#10
	STA	NONUM
	LDY	#SCRTBL
TRNNM1	TST	5,Y
	BNE	TRYNNM
	PSHS	X
	LEAX	CNSTNT,Y
	PSHS	X
	STB	,X+
	CLR	,X+
	CLR	,X
	PULS	X
	LDA	#30
	STA	5,Y
	PSHS	U
	LEAU	-3,X
	PSHS	U
	CLR	,U+
	CLR	,U+
	CLR	,U
	PULS	U
	JSR	ADDPNT
	PULS	U
	STX	3,Y
	PULS	X
	STB	RNDNUM
	LDA	,U
	STA	,Y
	LDA	1,U
	STA	1,Y
	LDA	#3
	STA	2,Y
	LDA	#$0AA
	STA	6,Y
	BRA	NOTBRD
TRYNNM	LEAY	7,Y
	DEC	NONUM
	BRA	TRNNM1
NOTBRD	PULS	A,B,X,Y	; Add points for any other Nastie
	LDA	5,U	; onto player's score.
	CMPA	#7
	BEQ	NTBRD1
	LDB	#6
	MUL
	PSHS	U
	LDU	#$553E
	LEAU	D,U
	JSR	ADDPNT
	PULS	U
NTBRD1	TST	5,U	; If it's not a pod, then it
	BEQ	PODHIT	; should explode.
	LDB	#6	; Adjust y-position to compensate
	SUBB	3,U	; for new Y-height.
	BCS	MVYXPL	; Adjust x-position to compensate
	LSRB		; for new X-width.
	BEQ	NOMVY1	; Fix pointers for animation
	STB	LINCNT	; sequence, and type of Nastie
NXY21	JSR	DECY	; for explosion.
	DEC	LINCNT
	BNE	NXY21
	BRA	NOMVY1
MVYXPL	NEGB
	LSRB
	BEQ	NOMVY1
	STB	LINCNT
NXY22	JSR	INCY
	DEC	LINCNT
	BNE	NXY22
NOMVY1	LDB	#8
	STB	5,U
	LDX	#$5DD6
	LDB	B,X
	ORB	#$80
	INCB
	ADDB	#7
	LSRB
	INCB
DECLP1	JSR	DECX
	DECB
	BNE	DECLP1
	JSR	INCX
FINSUP	CLRA
	LDA	5,U
	LSLA
	LDX	#$5DDF
	LDX	A,X
	STX	8,U
	RTS
PODHIT	LDA	BROUND	; If during 1st bonus round,
	CMPA	#1	; and not the last to hatch,
	BNE	PDHT1	; make it an Evil Eyes. If
	LDA	HTPOD	; it is last, make it a bird.
	INCA		; If it's 2nd or 3rd bonus
	STA	HTPOD	; round, make them all birds.
	CMPA	#8	; If not bonus round, make it
	BEQ	BIRDY	; whatever Nastie is current,
	BRA	HTPOD1	; with a 1-in-8 chance of
PDHT1	LDA	$5D40	; being a bird after all
	ANDA	#$7
	TSTA
	BEQ	BIRDY
HTPOD1	LDA	NOWGUY
	BRA	BRDE1
BIRDY	LDA	#7
BRDE1	STA	5,U	; Fix some parameters. Adjust
	PSHS	X	; Y-position to compensate for
	LDX	#$5DCD	; height of new figure.
	LDA	A,X	; Make beep proportional to
	STA	3,U	; wave of Nastie just hit.
	LDB	#6	; Adjust x-position to
	PULS	X	; compensate for new width.
	SUBB	3,U
	BCS	MVYHUH
	LSRB
	BEQ	NOMVY
	STB	LINCNT
NXY11	JSR	INCY
	DEC	LINCNT
	BNE	NXY11
	BRA	NOMVY
MVYHUH	NEGB
	LSRB
	BEQ	NOMVY
	STB	LINCNT
NXY12	JSR	DECY
	DEC	LINCNT
	BNE	NXY12
NOMVY	LDA	5,U
	TFR	A,B
	CLRA
	NEGB
	ADDB	#10
	LSLB
	LSLB
	LSLB
	STD	$5CF2
	STD	$5D03
	LDB	#16
	STB	LINCNT
BEEPLP	JSR	$5CC8
	DEC	LINCNT
	BNE	BEEPLP
	LDA	5,U
	LDX	#$5DD6
	LDA	A,X
	ORA	#$80
	INCA
	ADDA	#7
	LSRA
	INCA
DECLP2	STA	,-S
	JSR	INCX
	LDA	,S+
	DECA
	BNE	DECLP2
	JSR	DECX
	CLRA
	LDA	5,U	; Jump to appropriate
	LDX	#JMPTBL	; movement-adjusting routine.
	LSLA
	LDX	A,X
	JMP	,X
JMPTBL	FDB	FINSUP
	FDB	FLGBYT
	FDB	CRSBYT
	FDB	FLGBYT
	FDB	STMBYT
	FDB	ARMBYT
	FDB	PSYBYT
	FDB	BRDBYT
CRSBYT	LDA	#1	; Cross. No real adjustments
	STA	10,U	; need to be made.
	LBRA	FINSUP
STMBYT	LDA	#$1F	; Stomper. Only adjustment is delay
	STA	10,U	; timer for when it hits bottom.
	LBRA	FINSUP
ARMBYT	LDA	#1	; Armor. Put it in figure-8
	STA	10,U	; movement table.
	LDY	#$5C8A
	STY	6,U
	LBRA	FINSUP
PSYBYT	JSR	$5D21	; Randomly decide whether it's
	LDA	$5D3F	; going left/right, and up/down 
	LDB	#$20	; (Psychlops)
	BITA	#1
	BNE	NOSHF
	LSLB
NOSHF	ANDA	#$80
	ORA	#1
	STA	,-S
	ORB	,S+
	STB	10,U
	LBRA	FINSUP
BRDBYT	JSR	$5D21	; Bird. Randonly decide which
	LDA	$5D3F	; horizontal direction to go.
	LDB	#$20
	BITA	#1
	BNE	NOSHF1
	LSLB
NOSHF1	ORB	#1
	STB	10,U
	LBRA	FINSUP
FLGBYT	JSR	$5D21	; Evil Eyes or Qube.
	LDA	$5D3F	; Make it go down. and randomly
	ANDA	#$1F	; decide whether to go left, right,
	CMPA	#2	; or no horizontal direction.
	BCS	FLGBYT	; Also, decide how long this
	CMPA	#10	; direction is to continue.
	BCC	FLGBYT
	LDB	#$20
	BITA	#1
	BNE	NOSHF2
	LSLB
NOSHF2	ORA	#1
	STA	,-S
	ORB	,S+
	STB	10,U
	LBRA	FINSUP
HIT11	PSHS	B,A	; Check if Qube has really be hit
	LDA	5,U	; (elaborate routine needed since
	CMPA	#3	; it changes size & shape)
	BNE	OUT11
	LDA	4,U
	CMPB	#7
	BEQ	MSTLKY
	CMPB	#1
	BEQ	MSTLKY
	CMPB	#6
	BEQ	LKY2
	CMPB	#2
	BEQ	LKY2
	CMPB	#5
	BEQ	LKY3
	CMPB	#3
	BEQ	LKY3
	BRA	OUT11
LKY3	CMPA	#1
	BEQ	OUT11
	CMPA	#4
	BEQ	OUT11
LKY2	CMPA	#2
	BEQ	OUT11
	CMPA	#5
	BEQ	OUT11
MSTLKY	CMPA	#3
	BEQ	OUT11
	CMPA	#6
	BEQ	OUT11
OUT12	LDA	#1
	STA	ERR
OUT11	PULS	A,B,PC
MOVSHP	PSHS	Y,X,B,A	; Controlling routine for
	LDA	SHPPOS	; moving player's ship.
	STA	SHPOS1
	JSR	CHEQ
	JSR	DAVID
	JSR	JOYIN
	LDA	DIR
	TSTA
	BEQ	STOP
	CMPA	#2
	BEQ	RIGHT
LEFT	LDB	SHPPOS
	DECB
	BEQ	STOP
	STB	SHPPOS
	JSR	OFF
	BRA	STOP
RIGHT	LDB	SHPPOS
	INCB
	CMPB	#115
	BEQ	STOP
	STB	SHPPOS
	JSR	OFF
STOP	JSR	ON
	PULS	A,B,X,Y,PC
COMMON	LDX	SCRST
	LEAX	$B20,X
	LDA	SHPPOS
COMMN1	TFR	A,B
	ANDA	#3
	LSLA
	LSRB
	LSRB
	ABX
	LDY	#$5F98
	LDY	A,Y
	LDB	#6
	STB	CNLIN1
	RTS
CHEQ	JSR	COMMON	; Check if anything red or white
LINCMP	CLRA		; is within ship (any shots, some
	LDD	,Y++	; ships); if so, blow up.
	LSLA
	LSLB
	ANDA	,X+
	BNE	SHOCK
	ANDB	,X+
	BNE	SHOCK
	CLRA
	LDD	,Y++
	LSLA
	LSLB
	ANDA	,X+
	BNE	SHOCK
	ANDB	,X
	BNE	SHOCK
	LEAX	$1D,X
	DEC	CNLIN1
	BNE	LINCMP
	RTS
SHOCK	LBRA	BLOWUP
DAVID	LDU	#XPOS	; Check all remaining ships (Evil
	LDB	#8	; Eyes, Qubes, Psychlops), to see
	STB	CNLIN1	; if they have touched the player's
REPET	TST	10,U	; ship anywhere on its outer
	BEQ	NREPET	; perimeter (one layer of pixels
	LDA	1,U	; on the top and sides, including
	ADDA	3,U	; turrets).  If hit, blow up.
	DECA
	CMPA	#$59
	BLO	NREPET
	LDB	5,U
	CMPB	#1
	BEQ	FLAGS
	CMPB	#3
	BEQ	QUBES
	CMPB	#6
	BEQ	PSYCHS
NREPET	LEAU	11,U
	DEC	CNLIN1
	BNE	REPET
	RTS
FLAGS	CLRA
	LDB	1,U
	INCB
	JSR	CHECKE
	ADDA	#6
	JSR	CHECKE
	LDA	#5
	STA	CNLIN
	INCB
FLAG1	JSR	CHECKE
	DECA
	BEQ	NREPET
	BRA	FLAG1
PSYCHS	TST	4,U
	BNE	NREPET
	LDB	3,U
	STB	CNLIN
	LDB	1,U
	CLRA
PSY1	JSR	CHECKE
	EORA	#2
	JSR	CHECKE
	EORA	#2
	INCB
	DEC	CNLIN
	BNE	PSY1
	LDA	#1
	LDB	1,U
	ADDB	3,U
	DECB
	JSR	CHECKE
	BRA	NREPET
QUBES	LDB	4,U
	CMPB	#4
	BCC	NREPET
	TSTB
	BEQ	NREPET
	DECB
	LDX	#LNQUTB
	LDA	B,X
	LDB	3,U
	STB	CNLIN
	LDB	1,U
QUB1	JSR	CHECKE
	NEGA
	ADDA	#6
	JSR	CHECKE
	NEGA
	ADDA	#6
	INCB
	DEC	CNLIN
	BNE	QUB1
	NEGA
	ADDA	#6
	PSHS	A
	SUBA	#4
	CLRB
	LSLA
	ADDA	#3
	STA	CNLIN
	LDB	1,U
	ADDB	3,U
	DECB
	PULS	A
QUB3	JSR	CHECKE
	DECA
	DEC	CNLIN
	BNE	QUB3
	LBRA	NREPET
LNQUTB	FCB	2
	FCB	1
	FCB	0
CHECKE	PSHS	B,A
	SUBB	#$59
	BCS	CHKOUT
	ADDA	,U
	SUBA	SHPPOS
	BCS	CHKOUT
	CMPA	#13
	BCC	CHKOUT
	TSTB
	BEQ	CHKTRT
	CMPA	#12
	BEQ	TIPS
	TSTA
	BEQ	TIPS
	CMPB	#5
	BCC	CHKOUT
	CMPB	#1
	LBNE	BLOWUP
	CMPA	#5
	BCS	CHKTRT
	CMPA	#8
	BCC	CHKTRT
	LBRA	BLOWUP
CHKTRT	CMPA	#2
	LBEQ	BLOWUP
	CMPA	#10
	LBEQ	BLOWUP
	BRA	CHKOUT
TIPS	CMPB	#3
	LBEQ	BLOWUP
CHKOUT	PULS	A,B,PC
OFF	LDX	SCRST	; Mask out ship from screen (using
	LEAX	$B20,X	; logical AND) to erase it.
	LDA	SHPOS1
	JSR	COMMN1
LINOFF	LDD	,Y++
	COMA
	COMB
	ANDA	,X
	ANDB	1,X
	STD	,X++
	LDD	,Y++
	COMA
	COMB
	ANDA	,X
	ANDB	1,X
	STD	,X
	LEAX	$1E,X
	DEC	CNLIN1
	BNE	LINOFF
	RTS
ON	JSR	COMMON	; Mask in ship onto screen (using
LINON	LDD	,Y++	; logical OR) to display it.
	ORA	,X
	ORB	1,X
	STD	,X++
	LDD	,Y++
	ORA	,X
	ORB	1,X
	STD	,X
	LEAX	$1E,X
	DEC	CNLIN1
	BNE	LINON
	RTS
ADDPNT	PSHS	Y,X	; Add score pointed to by U, to
	LDB	#6	; player's current score.
	STB	NONUM	; Account for "carry"ing numbers
	LDX	#PLYNOT	; if over 9 in any digit.
	CLRA		; If carry 1 into 10.000's digit,
	LDA	PLYNO	; flag for beeper to signal an
	LSLA		; extra ship.
	LDX	A,X	; Print player's score on screen.
	STX	YSTOR
	DECB
	LEAX	5,X
	LEAU	B,U
BIG2	LDA	,X
	ADDA	,U
	CMPA	#$0A
	BCC	BIGGER
BIG1	STA	,X
	LEAX	-1,X
	LEAU	-1,U
	DEC	NONUM
	BNE	BIG2
	BRA	DNUPSC
BIGGER	SUBA	#$0A
	INC	-1,X
	LDB	NONUM
	CMPB	#3
	BNE	BIG1
	LDB	#32
	STB	BEEPER
	BRA	BIG1
DNUPSC	LDY	#SCRTBL
TRNXTW	TST	5,Y
	BNE	TRNXON
	LDX	YSTOR
	STX	3,Y
	LDA	#1
	STA	5,Y
	STA	1,Y
	LDA	#$FF
	STA	6,Y
	LDA	PLYNO
	LDB	#91
	MUL
	INCB
	STB	,Y
	LDA	#9
	STA	2,Y
	PULS	X,Y
	RTS
TRNXON	LEAY	7,Y
	BRA	TRNXTW
PRNSTR	LDA	,U+	; Move string from U to X, and
	TSTA		; 'OR' $40 into each character
	BEQ	PRNOUT	; until a zero is found.
	ORA	#$40
	STA	,X+
	BRA	PRNSTR
PRNOUT	RTS
LEVELS	CLRA		; Determine by score, the level
	LDA	PLYNO	; of difficulty to inflict upon
	LDX	#PLYNOT	; the player. As scroes get
	LSLA		; larger, the difference in scores
	LDX	A,X	; between difficulty levels
	LDA	,X+	; increases.
	TSTA
	BEQ	LEV0X0
	DECA
	BEQ	LEV1X0
	DECA
	BEQ	LEV2X0
LEV3X0	LDA	#20
LEV3L0	STA	LEVEL
	BRA	LEVFIX
LEV2X0	LDB	#18
	JSR	LEVCK1
	TFR	B,A
	BRA	LEV3L0
LEV0X0	LDA	,X+
	CMPA	#5
	BCC	LEV0H0
	CLRB
	LSLA
	TFR	A,B
	JSR	LEVCK1
	TFR	B,A
	BRA	LEV3L0
LEV0H0	ADDA	#5
	BRA	LEV3L0
LEV1X0	LDB	#15
	JSR	LEVCHK
	TFR	B,A
	BRA	LEV3L0
LEVCHK	LDA	,X
	CMPA	#2
	BCS	LEVRT1
	INCB
LEVCK1	LDA	,X
	CMPA	#5
	BCS	LEVRT1
	INCB
LEVRT1	RTS
LEVFIX	LDA	LEVEL	; Load difficulty values from
	LDX	#$546C	; tables, and place them suitable
	LDB	A,X	; places such as aliens' shot
	STB	CYCPRB	; frequencies, maximum number of
	LDX	#$5481	; shots on screen, bonus points
	LDB	A,X	; for finishing a round, speed
	STB	BONBYT	; of game, and speed of fuel
	CLRB		; decay with respect to game speed.
	LSLA
	LDX	#$539A
	LEAX	A,X
	LDB	,X+
	STB	FLGNO
	LDB	,X
	STB	FLGPRB
	LDX	#$53EE
	LEAX	A,X
	LDB	,X+
	STB	CRSNO
	LDB	,X
	STB	CRSPRB
	LDX	#$53C4
	LEAX	A,X
	LDB	,X+
	STB	QUBNO
	LDB	,X
	STB	QUBPRB
	LDX	#$5418
	LEAX	A,X
	LDB	,X+
	STB	STMNO
	LDB	,X
	STB	STMPRB
	LDX	#$5442
	LEAX	A,X
	LDB	,X+
	STB	STRNO
	LDB	,X
	STB	ARMPRB
	LDX	#$5496
	LDX	A,X
	STX	LEVDEL
	LDA	LEVEL
	LDB	#6
	MUL
	LDX	#LEVBON
	LDU	#$54C0
	LEAU	D,U
	LDB	#6
	STB	LOOPER
BONLP7	LDA	,U+
	STA	,X+
	DEC	LOOPER
	BNE	BONLP7
	RTS
REVERS	PSHS	X,B,A	; Complement all graphics on
	LDX	$5D8D	; scren, and thus "invert"
RVRS1	LDD	,X	; the video.
	COMA
	COMB
	STD	,X++
	CMPX	#$1A00
	BLO	RVRS1
	LDX	#5
LOPDEL	LEAX	-1,X
	BNE	LOPDEL
	PULS	A,B,X,PC
GMOVER	LDU	#$5840	; Print graphics-encoded
	LDX	#$10A9	; "Game Over" message, wait,
	LDB	#7	; erase it, wait, and return.
	STB	LOOPER
GMOVLP	LDB	#14
	STB	LINCNT
GMOVL1	LDA	,U+
	ANDA	#$AA
	STA	,X+
	DEC	LINCNT
	BNE	GMOVL1
	LEAX	18,X
	DEC	LOOPER
	BNE	GMOVLP
	JSR	DELAY1
	JSR	DELAY1
	JSR	CLS
	JSR	DELAY1
	RTS
PLYMS	JSR	MKSTBL	; Print "Player " message,
	JSR	PUTSTR	; and "1" or "2" depending on
	LDY	#$58A4	; whose turn it is.
	LDX	#$10AA	; Then delay, erase it, delay,
	LDB	#10	; and return.
	STB	LOOPER
PLYMLP	LDB	#9
	STB	LINCNT
PLYML1	LDA	,Y+
	ANDA	#$55
	STA	,X+
	DEC	LINCNT
	BNE	PLYML1
	LEAX	23,X
	DEC	LOOPER
	BNE	PLYMLP
	LDX	#NOTBL
	CLRA
	LDA	PLYNO
	LSLA
	LDX	A,X
	LDB	#7
	STB	LOOPER
	LDU	#$10B4
PLYML2	LDA	,X+
	ANDA	#$55
	STA	,U+
	LDA	,X+
	ANDA	#$55
	STA	,U+
	LEAU	30,U
	DEC	LOOPER
	BNE	PLYML2
	JSR	DELAY1
	JSR	DELAY1
	JSR	CLS
	LDX	#0
	JSR	DELAY3
	RTS
NOTBL	FDB	$5900
	FDB	$5910
DELAY1	LDX	#$E848	; Different delay routines for
DELAY2	LEAX	-1,X	; differnet lengths of delay.
	BNE	DELAY2
DELAY3	LEAX	-1,X
	BNE	DELAY3
	RTS
CLS	LDX	#$1000	; Clear message off screen
CLS1	CLR	,X+
	CMPX	#$1200
	BLO	CLS1
	RTS
CLRSTR	LDX	#STRTBL	; Clear out table of stars'
CLRS1	CLR	,X+	; locations
	CMPX	#STREND
	BLO	CLRS1
	RTS
MOVSTR	LDA	STRCNT	; Move stars once every 3
	INCA		; times this routine is called.
	CMPA	#3	; If stars go off the bottom, or
	BCC	MVSTR1	; close enough to the ship to hit,
	STA	STRCNT	; kill the star (nobody playing
	RTS		; will notice it's gone.)
MVSTR1	CLR	CNSTDD	; If one star died, create another.
	CLR	STRCNT
	LDX	#STRTBL
MVSTR3	TST	2,X
	BEQ	MVSTR2
	LDA	,X
	STA	$5DBE
	LDA	1,X
	LSRA
	STA	$5DBF
	CLR	$5DBD
	JSR	$5D8F
	JSR	$5D21
	LDA	$5D40
	ANDA	#$3
	CMPA	#$7F
	BEQ	STPSTR
	LDA	1,X
	ADDA	4,X
	STA	1,X
	CMPA	#$C0
	BCC	STPSTR
	CMPA	#$B0
	BCS	MVSTR4
	LDA	,X
	ADDA	#3
	LDB	SHPPOS
	STB	,-S
	CMPA	,S+
	BCS	MVSTR4
	LDB	SHPPOS
	ADDB	#15
	ADDB	#4
	STB	,-S
	CMPA	,S+
	BCS	STPSTR
MVSTR4	LDA	3,X
	STA	COLOR
	LDA	,X
	STA	XPOINT
	LDA	1,X
	LSRA
	STA	YPOINT
	JSR	SET1
	BRA	MVSTR2
STPSTR	CLR	2,X
	INC	CNSTDD
MVSTR2	LEAX	5,X
	CMPX	#STREND
	BLO	MVSTR3
MKFRLS	TST	CNSTDD
	BEQ	MKOUT
	LDX	#STRTBL
MKFRL2	TST	2,X
	BNE	MKFRL1
	JSR	RNDSTR
	JSR	LRNDY
	DEC	CNSTDD
	BEQ	MKOUT
MKFRL1	LEAX	5,X
	BRA	MKFRL2
MKOUT	RTS
PUTSTR	PSHS	Y,X,B,A	; Put all the stars in the
	LDX	#STRTBL	; star table onto the screen.
PTSTR2	TST	2,X
	BEQ	PTSTR1
	LDA	3,X
	STA	COLOR
	LDA	,X
	STA	XPOINT
	LDA	1,X
	LSRA
	STA	YPOINT
	JSR	SET1
PTSTR1	LEAX	5,X
	CMPX	#STREND
	BLO	PTSTR2
	PULS	A,B,X,Y,PC
MKSTBL	PSHS	X,B,A	; Make the star table (randomly
	JSR	CLRSTR	; distributed).
	LDX	#STRTBL
	LDB	#24
	STB	CNTSTR
MKSTB1	JSR	RNDSTR
	LEAX	5,X
	DEC	CNTSTR
	BNE	MKSTB1
	PULS	A,B,X,PC
RNDSTR	JSR	$5D21	; Put random color, x-position,
	LDA	$5D3F	; speed, y-position into table
	ANDA	#3	; of stars.
	INCA
	STA	4,X
	LDA	$5D40
	ANDA	#1
	PSHS	X
	LDX	#COLTBL
	LDA	A,X
	PULS	X
	STA	3,X
	LDA	#1
	STA	2,X
	JSR	$5D21
	LDA	$5D3F
	ANDA	#$7F
	STA	,X
NGAOD2	LDA	$5D40
	ANDA	#$7F
	CMPA	#9
	BCS	NGAOD1
	CMPA	#$56
	BCC	NGAOD1
	LSLA
	STA	1,X
	RTS
NGAOD1	JSR	$5D21
	BRA	NGAOD2
LRNDY	PSHS	X,B,A	; Make random Y a little closer
	JSR	$5D21	; to the top of the screen, but
	LDA	$5D40	; still mostly random.
	ANDA	#$7F
	LSRA
	LSRA
	ADDA	#18
	STA	1,X
	PULS	A,B,X,PC
SET1	PSHS	Y,X,B,A	; Set the star pixel on the
	LDX	#$E00	; graphics screen.
	LDA	YPOINT
	LDB	#$20
	MUL
	LEAX	D,X
	LDB	XPOINT
	LDA	XPOINT
	LSRB
	LSRB
	ANDA	#3
	ABX
	LDY	#PIXTBL
	LDB	A,Y
	ANDB	COLOR
	ORB	,X
	STB	,X
	PULS	A,B,X,Y,PC
PIXTBL	FCB	$C0
	FCB	$30
	FCB	$0C
	FCB	$03
COLOR	FCB	0	; Various sundry variables for
XPOINT	FCB	0	; the star routine
YPOINT	FCB	0
STRCNT	FCB	0
CNTSTR	FCB	0
CNSTDD	FCB	0
COLTBL	FCB	$55
	FCB	$FF
STRTBL	EQU	$2000
STREND	EQU	$2078
JOYIN	TST	JOYKEY	; Determine if it was a
	BEQ	JOYSTK	; joystick or keyboard game,
	CLR	DIR	; and get left/right/shoot
	CLR	BUTPRS	; information from keyboard
	LDB	#$DF	; or appropriate joystick
	STB	$FF02
	LDA	$FF00
	ANDA	#$7F
	BITA	#8
JOYN1	EQU	.-1
	BNE	NOLFT
	LDA	DIR
	ORA	#1
	STA	DIR
NOLFT	LSLB
	ORB	#1
	STB	$FF02
	LDA	$FF00
	ANDA	#$7F
	BITA	#8
JOYN2	EQU	.-1
	BNE	NORT
	LDA	DIR
	ORA	#2
	STA	DIR
NORT	LSLB
	ORB	#1
	STB	$FF02
	LDA	$FF00
	ANDA	#$7F
	BITA	#8
JOYN3	EQU	.-1
	BNE	NOSHT
	LDA	#1
	STA	BUTPRS
NOSHT	LDA	DIR
	CMPA	#3
	BNE	NONOTH
	CLRA
	STA	DIR
NONOTH	RTS
JOYSTK	LDA	$FF23
	LDB	$FF20
	STB	STSN
	ANDA	#$F7
	STA	$FF23
	JSR	[$A00A]
	LDB	STSN
	STB	$FF20
	LDA	$FF23
	ORA	#8
	STA	$FF23
	LDA	PLYNO
	ADDA	#0
	LDX	#$15A
	LSLA
	LDB	A,X
	STB	CURNTX
	CMPB	#16
	BCC	NORM
	LDB	#1
	STB	DIR
	BRA	NORM2
NORM	CMPB	#48
	BCS	NORM1
	LDB	#2
	STB	DIR
	BRA	NORM2
NORM1	CLR	DIR
NORM2	LDA	$FF00
	COMA
	LDB	PLYNO
	LDX	#BUTTBL
	ANDA	B,X
	STA	BUTPRS
	RTS
WHOP1	JSR	WHOP	; Sound routine
	JSR	WHOP
	JSR	WHOP
	RTS
WHOP	LDD	#$76	; Another sound routine
WHOOP	STD	$5CF2
	STD	$5D03
	JSR	$5CC8
	JSR	$5CC8
	LDD	$5CF2
	DECB
	DECB
	BNE	WHOOP
	RTS
BONCHK	TST	BROUND	; Check if it's time to
	LBEQ	CHEKD1	; have a bonus round. If so,
	CLR	BONCNT	; set up special tables of
	LDA	BROUND	; bonus round Nasties, and
	ANDA	#1	; special difficulty level
	EORA	#1	; tables for the bonus round.
	LDU	#XPOS
	CLRB
	LSLA
	LDB	#8
	STB	CNTDED
	LDX	#$5356
	LDX	A,X
	STB	CNLIN1
TBLOP	LDD	,X++
	STD	,U
	LDD	,X++
	STD	6,U
	LDD	#$306
	STD	2,U
	CLRA
	CLRB
	STD	4,U
	LDD	#$5DF1
	STD	8,U
	LDA	#1
	STA	10,U
	LEAU	11,U
	DEC	CNLIN1
	BNE	TBLOP
	LDA	#$0C
	STA	BONBYT
	LDA	BROUND
	CMPA	#1
	BNE	TBLOP1
	LDA	#$10
	STA	BONBYT
TBLOP1	LBRA	CHKED
PUTX	PSHS	U,Y,X	; If, during bonus round,
	LDU	#TABX	; an Evil Eyes has touched
TABX1	TST	,U+	; bottom, it becomes a red
	BEQ	OUT	; cross-hatch work. This
	LDB	-1,U	; routine prints these
	CLRA		; cross-hatches on the screen.
	TFR	B,A
	ANDA	#3
	LSLA
	LDY	#TX1
	LDY	A,Y
	LSRB
	LSRB
	LDX	#$1940
	ABX
	JSR	XPUT
	JSR	XPUT
	JSR	XPUT
	LEAX	-160,X
	LEAY	2,Y
	JSR	XPUT
	JSR	XPUT
	BRA	TABX1
OUT	PULS	X,Y,U,PC
XPUT	LDD	,Y	; Put one line of the
	ORA	,X	; crosshatch on the screen.
	ORB	1,X
	STD	,X
	LEAX	$40,X
	RTS
BONRND	TST	BROUND	; Delay, print "Bonus round"
	BEQ	BONRN1	; message, delay, erase it,
	LDX	#0	; delay, set up for whether
	JSR	DELAY3	; Evil Eyes or Birds will
	LDA	BROUND	; mainly appear on screen.
	STA	$52C9	; Go for next wave.
	JSR	$517E
	JSR	DELAY1
	JSR	CLS
	LDX	#0
	JSR	DELAY3
	LDA	BROUND
	ANDA	#2
	BEQ	BONRN1
	LDA	#7
	STA	NOWGUY
BONRN1	JMP	SHEET
BUTTBL	FDB	$0102	; Various tables (mostly
CLTBL2	FCB	$FF	; constants)
	FCB	$55
TBSTVL	FCB	$80
	FCB	$20
	FCB	$8
	FCB	$2
SPXCNT	FCB	4
HTPOD	FCB	0
BBBUFF	FDB	0
	FDB	$200
	FDB	0
TABX	FDB	0
	FDB	0
	FDB	0
	FDB	0
TX1	FDB	X1
	FDB	X2
	FDB	X3
	FDB	X4
X1	FDB	$8880
	FDB	$2200
X2	FDB	$2220
	FDB	$0880
X3	FDB	$0888
	FDB	$0220
X4	FDB	$0222
	FDB	$0088
BROUND	FCB	0	; Various tbales (mostly
BROND1	FCB	0	; variables)
BROND2	FCB	0
CYCLE1	FCB	0
STSN	FCB	0
PRMUT1	FCB	0
PERMUT	FCB	0
PLAYER	FCB	0
SCRPOS	FDB	0
INPLCE	FCB	0
INPLOC	FDB	0
ALARM	FCB	0
ALARM1	FCB	0
BEEPER	FCB	0
BEEPR1	FCB	0
STORY	FDB	0
TMCRTC	FCB	0
BARCOL	FCB	0
BONCNT	FCB	0
BONAMT	FCB	0
CNTDED	FCB	0
CNTER	FCB	$20
SHTTHR	FCB	0
SCROFF	FCB	0
SHPZAP	FCB	0
NOWGUY	FCB	1
NWGY1	FCB	1
LEVEL	EQU	$5AA4
ERR	FCB	0
STXEND	FDB	0
STXST	FDB	0
STYEND	FDB	0
STYST	FDB	0
FLGPRB	FCB	0
CRSPRB	FCB	0
QUBPRB	FCB	0
STMPRB	FCB	0
ARMPRB	FCB	0
CYCPRB	FCB	$7F
FLGNO	FCB	8
CRSNO	FCB	5
QUBNO	FCB	3
STMNO	FCB	3
STRNO	FCB	4
LEVDEL	FDB	$800
BONBYT	FCB	$1C
DELAY	FDB	0
LEVBON	FDB	0
	FDB	0
	FDB	$100
NONUM	FCB	0
DIGITS	FCB	0
NOFNUM	FCB	0
SHFTBT	FCB	0
BTINUM	FCB	0
YSTOR	FDB	0
SHCON	FCB	0
SHOT1F	FCB	0
SHOT2F	FCB	0
SHOT1X	FCB	0
SHOT2X	FCB	0
SHOTY	FCB	0
DIR	FCB	0
JOYKEY	FCB	0
BUTPRS	FCB	0
BUTPR1	FCB	0
CURNTX	FCB	0
SHPPOS	EQU	$5AA5
SHPOS1	FCB	$0
CYCLE	FCB	0
CNLIN1	FCB	0
CNLIN	FCB	0
NOPLAY	FCB	0
PLYNO	FCB	0
SCRST	EQU	$5D8D
LINCNT	FCB	0
SRBYTE	FCB	0
CNTLIN	FCB	0
LOOPER	FCB	0
LOP1	FCB	0
LOP2	FCB	0
XPOS	RMB	108
P500	FDB	0
	FDB	5
	FDB	0
BONBUF	FDB	0
	FDB	0
	FDB	0
EMPBUF	FDB	$0A0A
	FDB	$0A0A
	FDB	$0A0A
	FDB	$0A0A
	FDB	$0A0A
	FDB	$0A0A
PLYNOT	FDB	PLY1SC
	FDB	PLY2SC
PLY1SC	FDB	0
	FDB	0
	FDB	0
	FCB	$0A
	FDB	3
PLY2SC	FDB	0
	FDB	0
	FDB	0
	FCB	$0A
	FDB	3
SHTTBL	RMB	80
RNDNUM	FDB	0
	FDB	0
SCRTBL	RMB	80
SCRSTB	RMB	80
	FCC	/(C) 1984 BY DAVE SHADOFF/
LAST	EQU	.-1
	END	ORIGIN
