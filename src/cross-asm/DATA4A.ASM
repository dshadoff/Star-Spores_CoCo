	ORG	$5DC4
D5DC4H	FCB	$03	; Width (rounding up
	FCB	$03	; to nearest byte),
	FCB	$02	; of each type of Nastie
	FCB	$03
D5DC8H	FCB	$02
	FCB	$02
	FCB	$02
	FCB	$03
	FCB	$03

	FCB	$06	; Height (in pixels),
	FCB	$03	; as above
	FCB	$05
D5DD0H	FCB	$05
	FCB	$08
	FCB	$06
	FCB	$05
	FCB	$04
	FCB	$06

	FCB	$78	; Maximum x-value (for
	FCB	$78	; right-edge cutoff)
D5DD8H	FCB	$7A	; for each
	FCB	$78
	FCB	$7A
	FCB	$7A
	FCB	$7C
	FCB	$78
	FCB	$78

	FCB	$5D	; Tables for animating
D5DE0H	FCB	$F1	; figures
	FCB	$5D
	FCB	$F3
	FCB	$5D
	FCB	$FC
	FCB	$5E
	FCB	$03
	FCB	$5E
D5DE8H	FCB	$10
	FCB	$5E
	FCB	$15
	FCB	$5E
	FCB	$17
	FCB	$5E
	FCB	$1B
	FCB	$5E
D5DF0H	FCB	$22
	FCB	$00
	FCB	$FF
	FCB	$00
	FCB	$01
	FCB	$02
	FCB	$03
	FCB	$04
D5DF8H	FCB	$03
	FCB	$02
	FCB	$01
	FCB	$F8
	FCB	$00
	FCB	$01
	FCB	$02
	FCB	$03
D5E00H	FCB	$04
	FCB	$05
	FCB	$FA
	FCB	$00
	FCB	$01
	FCB	$02
	FCB	$03
	FCB	$02
D5E08H	FCB	$01
	FCB	$00
	FCB	$04
	FCB	$05
	FCB	$06
	FCB	$05
	FCB	$04
	FCB	$F4
D5E10H	FCB	$00
	FCB	$01
	FCB	$02
	FCB	$01
	FCB	$FC
	FCB	$00
	FCB	$FF
	FCB	$00
D5E18H	FCB	$01
	FCB	$02
	FCB	$FD
	FCB	$00
	FCB	$01
	FCB	$02
	FCB	$03
	FCB	$02
D5E20H	FCB	$01
	FCB	$FA
	FCB	$00
	FCB	$01
	FCB	$02
	FCB	$03
	FCB	$04
	FCB	$FB

D5E28H	FCB	$5E	; Tables of locations
	FCB	$3A	; of graphics data for
	FCB	$5E	; Nasties
	FCB	$3C
	FCB	$5E
	FCB	$46
	FCB	$5E
	FCB	$52
D5E30H	FCB	$5E
	FCB	$60
	FCB	$5E
	FCB	$66
	FCB	$5E
	FCB	$68
	FCB	$5E
	FCB	$6E
D5E38H	FCB	$5E
	FCB	$76
	FCB	$5E
	FCB	$80
	FCB	$5E
	FCB	$88
	FCB	$5E
	FCB	$90
D5E40H	FCB	$5E
	FCB	$98
	FCB	$5E
	FCB	$A0
	FCB	$5E
	FCB	$A8
	FCB	$5E
	FCB	$B0
D5E48H	FCB	$5E
	FCB	$B8
	FCB	$5E
	FCB	$C0
	FCB	$5E
	FCB	$C8
	FCB	$5E
	FCB	$D0
D5E50H	FCB	$5E
	FCB	$D8
	FCB	$5E
	FCB	$E0
	FCB	$5E
	FCB	$E8
	FCB	$5E
	FCB	$F0
D5E58H	FCB	$5E
	FCB	$F8
	FCB	$5F
	FCB	$00
	FCB	$5F
	FCB	$08
	FCB	$5F
	FCB	$10
D5E60H	FCB	$5F
	FCB	$18
	FCB	$5F
	FCB	$20
	FCB	$5F
	FCB	$28
	FCB	$5F
	FCB	$30
D5E68H	FCB	$5F
	FCB	$38
	FCB	$5F
	FCB	$40
	FCB	$5F
	FCB	$48
	FCB	$5F
	FCB	$50
D5E70H	FCB	$5F
	FCB	$58
	FCB	$5F
	FCB	$60
	FCB	$5F
	FCB	$68
	FCB	$5F
	FCB	$70
D5E78H	FCB	$5F
	FCB	$78
	FCB	$5F
	FCB	$80
	FCB	$5F
	FCB	$88
	FCB	$5F
	FCB	$90
D5E80H	FCB	$60
	FCB	$00
	FCB	$60
	FCB	$12
	FCB	$60
	FCB	$24
	FCB	$60
	FCB	$36
D5E88H	FCB	$60
	FCB	$48
	FCB	$60
	FCB	$51
	FCB	$60
	FCB	$5A
	FCB	$60
	FCB	$63
D5E90H	FCB	$60
	FCB	$6C
	FCB	$60
	FCB	$75
	FCB	$60
	FCB	$7E
	FCB	$60
	FCB	$87
D5E98H	FCB	$60
	FCB	$90
	FCB	$60
	FCB	$99
	FCB	$60
	FCB	$A2
	FCB	$60
	FCB	$AB
D5EA0H	FCB	$60
	FCB	$B4
	FCB	$60
	FCB	$BD
	FCB	$60
	FCB	$C6
	FCB	$60
	FCB	$CF
D5EA8H	FCB	$60
	FCB	$D8
	FCB	$60
	FCB	$E1
	FCB	$60
	FCB	$EA
	FCB	$60
	FCB	$F3
D5EB0H	FCB	$60
	FCB	$FC
	FCB	$61
	FCB	$06
	FCB	$61
	FCB	$10
	FCB	$61
	FCB	$1A
D5EB8H	FCB	$61
	FCB	$24
	FCB	$61
	FCB	$2E
	FCB	$61
	FCB	$38
	FCB	$61
	FCB	$42
D5EC0H	FCB	$61
	FCB	$4C
	FCB	$61
	FCB	$56
	FCB	$61
	FCB	$60
	FCB	$61
	FCB	$6A
D5EC8H	FCB	$61
	FCB	$74
	FCB	$61
	FCB	$7E
	FCB	$61
	FCB	$88
	FCB	$61
	FCB	$92
D5ED0H	FCB	$61
	FCB	$9C
	FCB	$61
	FCB	$A6
	FCB	$61
	FCB	$B0
	FCB	$61
	FCB	$BA
D5ED8H	FCB	$61
	FCB	$C4
	FCB	$61
	FCB	$CE
	FCB	$61
	FCB	$D8
	FCB	$61
	FCB	$E2
D5EE0H	FCB	$61
	FCB	$EC
	FCB	$61
	FCB	$FB
	FCB	$62
	FCB	$0A
	FCB	$62
	FCB	$19
D5EE8H	FCB	$62
	FCB	$28
	FCB	$62
	FCB	$37
	FCB	$62
	FCB	$46
	FCB	$62
	FCB	$55
D5EF0H	FCB	$62
	FCB	$64
	FCB	$62
	FCB	$73
	FCB	$62
	FCB	$82
	FCB	$62
	FCB	$91
D5EF8H	FCB	$62
	FCB	$A0
	FCB	$62
	FCB	$AF
	FCB	$62
	FCB	$BE
	FCB	$62
	FCB	$CD
D5F00H	FCB	$62
	FCB	$DC
	FCB	$62
	FCB	$EB
	FCB	$62
	FCB	$FA
	FCB	$63
	FCB	$09
D5F08H	FCB	$63
	FCB	$18
	FCB	$63
	FCB	$27
	FCB	$63
	FCB	$36
	FCB	$63
	FCB	$45
D5F10H	FCB	$63
	FCB	$54
	FCB	$63
	FCB	$63
	FCB	$63
	FCB	$72
	FCB	$63
	FCB	$81
D5F18H	FCB	$63
	FCB	$90
	FCB	$63
	FCB	$A0
	FCB	$63
	FCB	$B0
	FCB	$63
	FCB	$C0
D5F20H	FCB	$63
	FCB	$D0
	FCB	$63
	FCB	$E0
	FCB	$63
	FCB	$F0
	FCB	$64
	FCB	$00
D5F28H	FCB	$64
	FCB	$10
	FCB	$64
	FCB	$20
	FCB	$64
	FCB	$30
	FCB	$64
	FCB	$40
D5F30H	FCB	$64
	FCB	$50
	FCB	$64
	FCB	$5C
	FCB	$64
	FCB	$68
	FCB	$64
	FCB	$74
D5F38H	FCB	$64
	FCB	$80
	FCB	$64
	FCB	$8A
	FCB	$64
	FCB	$94
	FCB	$64
	FCB	$9E
D5F40H	FCB	$64
	FCB	$A8
	FCB	$64
	FCB	$B2
	FCB	$64
	FCB	$BC
	FCB	$64
	FCB	$C6
D5F48H	FCB	$64
	FCB	$D0
	FCB	$64
	FCB	$DA
	FCB	$64
	FCB	$E4
	FCB	$64
	FCB	$EE
D5F50H	FCB	$64
	FCB	$F8
	FCB	$65
	FCB	$04
	FCB	$65
	FCB	$10
	FCB	$65
	FCB	$1C
D5F58H	FCB	$65
	FCB	$28
	FCB	$65
	FCB	$34
	FCB	$65
	FCB	$40
	FCB	$65
	FCB	$4C
D5F60H	FCB	$65
	FCB	$58
	FCB	$65
	FCB	$64
	FCB	$65
	FCB	$70
	FCB	$65
	FCB	$7C
D5F68H	FCB	$65
	FCB	$88
	FCB	$65
	FCB	$94
	FCB	$65
	FCB	$A0
	FCB	$65
	FCB	$AC
D5F70H	FCB	$65
	FCB	$B8
	FCB	$65
	FCB	$CA
	FCB	$65
	FCB	$DC
	FCB	$65
	FCB	$EE
D5F78H	FCB	$66
	FCB	$00
	FCB	$66
	FCB	$12
	FCB	$66
	FCB	$24
	FCB	$66
	FCB	$36
D5F80H	FCB	$66
	FCB	$48
	FCB	$66
	FCB	$5A
	FCB	$66
	FCB	$6C
	FCB	$66
	FCB	$7E
D5F88H	FCB	$66
	FCB	$90
	FCB	$66
	FCB	$A2
	FCB	$66
	FCB	$B4
	FCB	$66
	FCB	$C6
D5F90H	FCB	$66
	FCB	$D8
	FCB	$66
	FCB	$D8
	FCB	$66
	FCB	$D8
	FCB	$66
	FCB	$D8

D5F98H	FCB	$5F	; Tables of graphic
	FCB	$A0	; data of player's ship
	FCB	$5F
	FCB	$B8
	FCB	$5F
	FCB	$D0
	FCB	$5F
	FCB	$E8
D5FA0H	FCB	$04
	FCB	$00
	FCB	$04
	FCB	$00
	FCB	$04
	FCB	$15
	FCB	$04
	FCB	$00
D5FA8H	FCB	$14
	FCB	$51
	FCB	$45
	FCB	$00
	FCB	$55
	FCB	$44
	FCB	$55
	FCB	$40
D5FB0H	FCB	$14
	FCB	$51
	FCB	$45
	FCB	$00
	FCB	$00
	FCB	$15
	FCB	$00
	FCB	$00
D5FB8H	FCB	$01
	FCB	$00
	FCB	$01
	FCB	$00
	FCB	$01
	FCB	$05
	FCB	$41
	FCB	$00
D5FC0H	FCB	$05
	FCB	$14
	FCB	$51
	FCB	$40
	FCB	$15
	FCB	$51
	FCB	$15
	FCB	$50
D5FC8H	FCB	$05
	FCB	$14
	FCB	$51
	FCB	$40
	FCB	$00
	FCB	$05
	FCB	$40
	FCB	$00
D5FD0H	FCB	$00
	FCB	$40
	FCB	$00
	FCB	$40
	FCB	$00
	FCB	$41
	FCB	$50
	FCB	$40
D5FD8H	FCB	$01
	FCB	$45
	FCB	$14
	FCB	$50
	FCB	$05
	FCB	$54
	FCB	$45
	FCB	$54
D5FE0H	FCB	$01
	FCB	$45
	FCB	$14
	FCB	$50
	FCB	$00
	FCB	$01
	FCB	$50
	FCB	$00
D5FE8H	FCB	$00
	FCB	$10
	FCB	$00
	FCB	$10
	FCB	$00
	FCB	$10
	FCB	$54
	FCB	$10
D5FF0H	FCB	$00
	FCB	$51
	FCB	$45
	FCB	$14
	FCB	$01
	FCB	$55
	FCB	$11
	FCB	$55
D5FF8H	FCB	$00
	FCB	$51
	FCB	$45
	FCB	$14
	FCB	$00
	FCB	$00
	FCB	$54
	FCB	$00
	END	D5DC4H
