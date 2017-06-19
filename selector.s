; selector_init: Initializes variables and memory related to the tile selector.
selector_init:
	; Set up the tile selector sprites
	ld b, 10
	ld hl, spritets0_t
	selector_init_loop:
		ld a, 2 ; tile number 3
		ldi [hl], a
		ld a, 0b00000001 ; palette number 1
		ldi [hl], a
		inc hl
		inc hl
		dec b
		jp nz, selector_init_loop

	; no ret - allow it to fall through to the below function

selector_start_selecting:
	; Clear the selection table
	ld a, 0
	ld hl, selector_select_table
	ld bc, (4*11) ; one extra for the null entry
	call clrmem

	; Reset the selection count
	ld a, 0
	ld [selector_found_count], a

	ret

; selector_can_zap_tile: Checks the tile pointed to by in HL. If it can be zapped, the zero flag is set; otherwise, it is cleared.
selector_can_zap_tile:
	push af
	push bc
	ld a, [hl]
	ld d, 1
	; reflectors are 0x90 to 0x99, inclusive
	cp 0x90
	jp c, selector_can_zap_tile_fail ; a is less than 0x90
	cp (0x99 + 1)
	jp nc, selector_can_zap_tile_fail ; a is greater than or equal to (0x99 + 1)
selector_can_zap_tile_success:
	pop bc
	pop af
	dec d ; set zero flag
	ret
selector_can_zap_tile_fail:
	pop bc
	pop af
	inc d ; clear zero flag
	ret

; selector_trigger_tile: If the tile given in register HL can be zapped, places the next selector sprite there.
selector_trigger_tile:
	call selector_can_zap_tile
	ret nz ; we can't zap it, who cares

	push af
	push bc
	push hl

	; calculate the x and y of the tile
	ld bc, ((0xFFFF - temp_level_buffer) + 1) ; set bc to negative buffer offset
	add hl, bc ; subtract the offset of the buffer it's in
	; calculate x
	ld a, l
	and 0b00011111
	ld d, a
	; calculate y
	ld e, 1

	; find what offset in the table we should be
	push de
	ld hl, selector_select_table
	ld d, 0
	ld a, [selector_found_count]
	add a, a ; each entry is two bytes long
	ld e, a 
	add hl, de
	pop de

	; set parameters of target sprite
	ld a, e
	ldi [hl], a ; set y
	ld a, d
	ld [hl], a ; set x

	; increment current index
	ld a, [selector_found_count]
	inc a
	ld [selector_found_count], a

	pop hl
	pop bc
	pop af
	ret

selector_set_sprites:
	ld hl, spritets0_y

	; reset the sprite coords
	ld e, 10
	ld a, 0
selector_set_sprites_reset_loop:
	ldi [hl], a ; set y
	ldi [hl], a ; set x
	inc hl ; skip tile number
	inc hl ; skip attributes
	dec e
	jp nz, selector_set_sprites_reset_loop

	ld hl, selector_select_table
	ld bc, spritets0_y
selector_set_sprites_loop:
	; set sprite y
	ldi a, [hl]
	; end loop if it's null
	cp 0
	jp z, selector_set_sprites_loop_done
	; a = (a * 8)
	sla a
	sla a
	sla a
	; a = a - SCY
	ld d, a
	ldh a, [SCY]
	ld e, a
	ld a, d
	sub e
	add a, 0x10
	ld [bc], a
	inc bc

	; set sprite x
	ldi a, [hl]
	; a = (a * 8)
	sla a
	sla a
	sla a
	; a = a - SCX
	ld d, a
	ldh a, [SCX]
	ld e, a
	ld a, d
	sub e
	add a, 0x8
	ld [bc], a
	inc bc

	; skip tile # and attribute info
	inc bc
	inc bc

	jp selector_set_sprites_loop
selector_set_sprites_loop_done:
	ret