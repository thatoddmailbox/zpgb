; password
; stuff to save
; * current_screen (max of 3)
; * prog_current_level (max of LEVEL_COUNT)
; charset: A-Z (length of 26)

; AAAA
; A + prog_current_level with bytes 0 and 1 swapped with 2 and 3
; H + (current_screen | ((prog_current_level & 0b00010000) >> 1))

password_generate:
	ld hl, password_buffer

	ld a, [prog_current_level]
	and 0b00001100
	srl a
	srl a
	ld b, a
	ld a, [prog_current_level]
	and 0b00000011
	sla a
	sla a
	or b

	add a, 'A'
	ldi [hl], a

	ld a, [current_screen]
	ld b, a
	ld a, [prog_current_level]
	and 0b00010000
	srl a
	or b

	add a, 'H'
	ldi [hl], a

	ld a, [password_buffer]
	sub 'A'
	xor 3
	add a, 'A'
	ldi [hl], a

	ld a, [password_buffer + 1]
	sub 'A'
	xor 3
	add a, 'A'
	ldi [hl], a

	ld a, 0
	ldi [hl], a

	ret

; A + prog_current_level with bytes 0 and 1 swapped with 2 and 3
; Q - (current_screen | ((prog_current_level & 0b00010000) >> 1))

password_activate:
	; verify the checksum
	ld a, [password_buffer]
	sub 'A'
	xor 3
	add a, 'A'
	ld hl, (password_buffer + 2)
	cp [hl]
	jp nz, password_fail

	ld a, [password_buffer + 1]
	sub 'A'
	xor 3
	add a, 'A'
	ld hl, (password_buffer + 3)
	cp [hl]
	jp nz, password_fail

	; actually read the password
	ld a, [password_buffer]
	sub 'A'
	and 0b00001100
	srl a
	srl a
	ld b, a
	ld a, [password_buffer]
	sub 'A'
	and 0b00000011
	sla a
	sla a
	or b
	ld b, a
	; b now has prog_current_level, except for the high bit
	ld a, [password_buffer + 1]
	sub 'H'
	and 0b00001000
	sla a
	or b
	ld [prog_current_level], a

	ld a, [password_buffer + 1]
	sub 'H'
	and 0b00000111
	ld [current_screen], a


	ld a, 1
	ret
password_fail:
	ld a, 0
	ret