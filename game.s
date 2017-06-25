game_load:
	; enable window for HUD
	ld a, (144-16)
	ldh [WY], a
	ld a, 7
	ldh [WX], a

	; page in the palettes
	ld a, 1
	ldh [VBK], a

	; the background 1 palettes are handled by load_level

	; set all of background 2 to palette 7
	ld a, 0b00000111
	ld hl, bg_tile_map_2
	ld bc, (bg_tile_map_2 - bg_tile_map_1)
	call clrmem

	; page back in the tiles
	ld a, 0
	ldh [VBK], a

	jp screen_load_done

game_loop:
	; wait for vblank
	ld a, 0b00000001
	ldh [IE], a
	halt
	nop

	ld a, [dialogue_active]
	cp 1
	jp nz, game_loop_normal
	; if dialogue_active, then bypass the normal input and debug stuff
	call dialogue_tick
	jp game_loop
game_loop_normal:
	call hud_tick_early

	; input
	ld hl, P1
	ld a, [last_p14]
	ld c, a
	ld a, [last_p15]
	ld d, a

	; pull p14 low
	ld [hl], 0b00100000
	; read d-pad input...twice
	ld a, [hl]
	ld a, [hl]

	; pull p15 low
	ld [hl], 0b00010000
	; read other inputs (done six times, as programming manual states)
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]
	ld b, [hl]

	; reset the port
	ld [hl], 0b00110000
	
	push bc
	push de
	ld d, a
	ld a, [selector_mode]
	cp 0
	ld a, d
	jp nz, game_read_input_p14_selector
	; movement mode
	; test d-pad inputs
	bit 0, a
	call z, move_right
	bit 1, a
	call z, move_left
	bit 2, a
	call z, move_up
	bit 3, a
	call z, move_down
	jp game_read_input_p14_done
game_read_input_p14_selector:
	; selector mode
	bit 0, a ; is the right button down?
	jp nz, game_read_input_p14_selector_skip_right
	bit 0, c ; was it up before?
	ld d, 1
	call nz, selector_move
game_read_input_p14_selector_skip_right:
	bit 1, a ; is the left button down?
	jp nz, game_read_input_p14_done
	bit 1, c ; was it up before?
	ld d, 255
	call nz, selector_move
game_read_input_p14_done:
	pop de
	pop bc

	; test other inputs
	bit 0, b ; is the a button up now?
	jp nz, game_read_input_skip_a
	bit 0, d ; was it up before?
	push bc
	call nz, a_button
	pop bc
game_read_input_skip_a:
	bit 1, b ; is the b button up now?
	jp nz, game_read_input_skip_b
	bit 1, d ; was it up before?
	push bc
	call nz, b_button
	pop bc
game_read_input_skip_b:
	; save this frame's input
	ld [last_p14], a
	ld a, b
	ld [last_p15], a

	; if we're in selection mode, animate the thingies
	ld a, [selector_mode]
	cp 0
	jp z, game_loop_not_selector_mode
	call selector_tick
game_loop_not_selector_mode:
	call hud_tick_late
	jp game_loop