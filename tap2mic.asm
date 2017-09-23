START equ 16384
	org 8192
	ld a,h                  ; 8192
	or l                    ; 8193
	jr nz,Lab8202           ; 8194
Lab8196
	ld hl,Usage
BucPrintMsg
	ld a,(hl)
	or a
	ret z
	rst 10h
	inc hl
	jr BucPrintMsg
Lab8202
	call zero
	ld hl, buffer
	ld a,42                 ; 8216
	ld b,1                  ; 8218
	rst 8                   ; 8220
	sbc a,d  ; open file               ; 8221
	ret c                   ; 8222
	ld (handle),a          ; 8223
	jr nc, petla
wypad:  ; 8231
	ld a,(handle)          ; 8234
	rst 8                   ; 8237
	sbc a,e ; close                ; 8238
	rst 0
	;ret                     ; 8239
;Lab8240
;	ld bc,(Lab8468)           ; 8241
;	ld de,(Lab8470)         ; 8245
	

petla
	ld hl,LabDlug
	ld bc,2
	ld a,(handle)
	rst 8
	sbc a,l ; read
	jr c, wypad
	ld a,b
	or c
	cp 2
	jr nz, wypad
	ld hl,START
	ld bc,(LabDlug)
	push bc
	ld a,(handle)
	rst 8
	sbc a,l ; read
	pop de
	dec de
	dec de
	ld ix, START + 1
	ld a, (START)
	call sa_bytes
	jr nc, wypad
	ld hl,0
delay
	dec hl
	ld a,h
	or l
	jr nz,delay
	jr petla

sa_bytes
	ld hl, sa_ld_ret
	push hl
	ld hl, 0x1f80
	bit 7,a
	jr z, sa_flag
	ld hl, 0xc98
sa_flag
	ex af,af'
	inc de
	dec ix
	di
	ld a,2
	ld b,a
sa_leader
	djnz sa_leader
	out (254),a
	xor 0xf
	ld b, 0xa4
	dec l
	jr nz, sa_leader
	dec b
	dec h
	jp p, sa_leader
	ld b,0x2f
sa_sync_1
	djnz sa_sync_1
	out (254),a
	ld a, 0xd
	ld b, 0x37
sa_sync_2
	djnz sa_sync_2
	out (254),a
	ld bc, 0x3B0E
	ex af, af'
	ld l, a
	jp sa_start
sa_loop
	ld a, d
	or e
	jr z, sa_parity
	ld l, (ix+0)
sa_loop_p
	ld a,h
	xor l
sa_start
	ld h,a
	ld a, 1
	scf
	jp sa_8_bits
sa_parity
	ld l,h
	jr sa_loop_p
sa_bit_2
	ld a,c
	bit 7,b
sa_bit_1
	djnz sa_bit_1
	jr nc, sa_out
	ld b,0x42
sa_set
	djnz sa_set
sa_out
	out (254),a
	ld b, 0x3e
	jr nz, sa_bit_2
	dec b
	xor a
	inc a
sa_8_bits
	rl l
	jp nz, sa_bit_1
	dec de
	inc ix
	ld b,0x31
	ld a,0x7f
	in a,(254)
	rra
	ret nc
	ld a,d
	inc a
	jp nz, sa_loop
	ld b, 0x3b
sa_delay
	djnz sa_delay
	ret
sa_ld_ret
	push af
	ld a,(23624)
	and 0x38
	rrca
	rrca
	rrca
	out (254),a
	ld a, 0x7f
	in a, (254)
	rra
	ei
	jr c, sa_ld_end
report_d
	rst 8
	defb 0xc
sa_ld_end
	pop af
	ret

zero
	ld b, 255
	ld d, h
	ld e, l
	ld hl, buffer
zero_p
	ld a,(de)
	ld (hl), a
	or a
	ret z
	cp 13
	jr nz, colon
zeruj
	xor a
	ld (hl), a
	ret
colon
	cp ':'
	jr z, zeruj
	inc de
	inc hl
	djnz zero_p
	ret

Usage
	db " tap2mic file.tap",13,13
	db "Plays a tape file to MIC",13
	db "Similar to SAVE on a real Spectrum.",13
	db "It restarts the machine at the end.",13,0

handle
	defb 0; handle
Lab8461 nop ;drive
Lab8462	nop ;device
Lab8463	nop; attr
Lab8464	nop ; date
	nop
	nop
	nop
Lab8468 ; size
	nop
	nop
	nop
	nop
LabDlug nop
	nop
Lab8472 nop
	nop
buffer
	nop

