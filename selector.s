; selector_init: Initializes variables and memory related to the tile selector.
selector_init:
	; Set up the tile selector sprites
	ld b, 10
	ld hl, spritets0_a
	selector_init_loop:
		ld a, 0b00000001 ; palette number 1
		ldi [hl], a
		inc hl
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
	ld [selector_mode], a
	ld [selector_found_count], a
	ld [selector_select_index], a
	ld [selector_frame_counter], a

	ret

; selector_can_zap_tile: Checks the tile pointed to by in HL. If it can be zapped, the zero flag is set; otherwise, it is cleared.
selector_can_zap_tile:
	push af
	push bc
	ld a, [hl]
	ld d, 1
	; emitters are 0x82 to 0x89, inclusive
	; receptors are 0x8A to 0x91, inclusive
	; reflectors are 0x92 to 0x99, inclusive
	cp 0x82
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
	; hl = hl / 32
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	ld e, l

	; find what offset in the table we should be
	push de
	ld hl, selector_select_table
	ld d, 0
	ld a, [selector_found_count]
	add a, a ; each entry is four bytes long
	add a, a
	ld e, a 
	add hl, de
	pop de

	; set parameters of target sprite
	ld a, e
	ldi [hl], a ; set y
	ld a, d
	ldi [hl], a ; set x
	; write out the address of the tile
	ld b, h
	ld c, l
	pop hl ; restore the address
	ld a, h ; save high byte
	ld [bc], a
	inc bc
	ld a, l ; save low byte
	ld [bc], a

	; increment current index
	ld a, [selector_found_count]
	inc a
	ld [selector_found_count], a

	pop bc
	pop af
	ret

selector_set_sprites:
	ld hl, spritets0_y

	; reset the sprite coords
	ld e, 10
selector_set_sprites_reset_loop:
	ld a, 0
	ldi [hl], a ; set y
	ldi [hl], a ; set x
	ld a, 2
	ldi [hl], a ; set tile number
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

	; skip tile address info
	inc hl
	inc hl

	jp selector_set_sprites_loop
selector_set_sprites_loop_done:
	ret

selector_move:
	push af
	ld a, [selector_found_count]
	ld b, a ; b = maximum index + 1
	ld a, [selector_select_index]
	
	; change the counter
	add a, d

	; check new counter
	cp 255 ; is it trying to go to the max?
	jp z, selector_move_set_max
	cp b
	jp c, selector_move_no_reset ; (current index >= max + 1) -> reset counter
	ld a, 0
	jp selector_move_no_reset
selector_move_set_max:
	ld a, [selector_found_count]
	dec a
selector_move_no_reset:
	ld [selector_select_index], a

	; set the animation counter to trigger now
	ld a, 0b00010000
	ld [selector_frame_counter], a

	call selector_set_sprites
	pop af
	ret

; selector_tick: Called every frame in selector mode, used to animate the sprites.
selector_tick:
	ld a, [selector_frame_counter]
	inc a
	ld [selector_frame_counter], a

	; check if we should animate yet
	bit 5, a
	jp z, selector_tick_bit_done

	ld a, 0
	ld [selector_frame_counter], a

	ld a, [selector_select_index]
	; find the target sprite
	ld hl, spritets0_t
	; hl = hl + (i * 4)
	sla a
	sla a
	ld b, 0
	ld c, a
	add hl, bc

	; toggle it
	bit 0, [hl]
	jp z, selector_tick_set_bit
	res 0, [hl]
	jp selector_tick_bit_done
selector_tick_set_bit:
	set 0, [hl]
selector_tick_bit_done:
	ret

; selector_select: Selects the currently selected tile.
selector_select:
	; get the offset of the tile's pointer in the select table
	ld hl, (selector_select_table + 2)
	ld a, [selector_select_index]
	add a, a
	add a, a
	ld b, 0
	ld c, a
	add hl, bc

	; get the address of the tile
	ldi a, [hl]
	ld b, a
	ld a, [hl]
	ld c, a

	; get the actual tile
	ld a, [bc]
	; rotate it
	add a, 2
	; check if we need to wrap it around
	cp 0x8A
	jp z, selector_select_rotate_wrap
	cp 0x8B
	jp z, selector_select_rotate_wrap
	cp 0x92
	jp z, selector_select_rotate_wrap
	cp 0x93
	jp z, selector_select_rotate_wrap
	cp 0x9A
	jp z, selector_select_rotate_wrap
	cp 0x9B
	jp z, selector_select_rotate_wrap
	jp selector_select_rotate_no_wrap
selector_select_rotate_wrap:
	sub 8
selector_select_rotate_no_wrap:

	; save new tile
	ld [bc], a

	call calculate_level_lasers

	ret