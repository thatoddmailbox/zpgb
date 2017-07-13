game_load:
	; enable window for HUD
	ld a, (SCREEN_HEIGHT_PX-HUD_HEIGHT_PX)
	ldh [WY], a
	ld a, 7
	ldh [WX], a

	; move player to start
	ld a, 8
	ld [player_x], a
	ld [player_y], a

	; unpause game
	ld a, 0
	ld [hud_pause_active], a

	ld [new_scroll_available], a

	; decompress the level passed in bc
	call decompress_level

	; clear the hud window
	ld hl, bg_tile_map_2
	ld a, 0x00
	ld bc, (VRAM_WIDTH_TILES*4)
	call clrmem

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

	; clear pause menu tiles
	ld a, 0
	ld hl, bg_tile_map_2
	ld bc, 2*(bg_tile_map_2 - bg_tile_map_1)
	call clrmem

	ld a, 0b11100011 ; enable window
	ldh [LCDC], a

	call hud_draw
	call calc_viewport_scroll

	; special level start trigger
	ld hl, (temp_level_buffer + 1)
	ld a, 3
	call player_trigger_tile

	jp screen_load_done

game_loop:
	; wait for vblank
	ld a, 0b00000001
	ldh [IE], a
	halt
	nop

	ld a, [new_scroll_available]
	cp 0
	jp z, game_loop_no_new_scroll
	ld a, [new_scroll_x]
	ldh [SCX], a
	ld a, [new_scroll_y]
	ldh [SCY], a
	ld a, 0
	ld [new_scroll_available], a
game_loop_no_new_scroll:
	ld a, [nonogram_active]
	cp 1
	jp z, nonogram_tick ; if the nonogram's open, bypass everything else
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
	
	push de
	ld d, a
	ld a, [hud_pause_active]
	cp 1
	ld a, d
	pop de
	call z, hud_pause_input
	jp z, game_hud_pause_input_skip

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

game_hud_pause_input_skip:
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
	bit 2, b ; is the b button up now?
	jp nz, game_read_input_skip_select
	bit 2, d ; was it up before?
	push bc
	call nz, select_button
	pop bc
game_read_input_skip_select:

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


a_button:
	ld a, [hud_pause_active]
	cp 1
	jp z, hud_pause_select
	ld a, [selector_mode]
	cp 0
	jp nz, a_button_selector_mode
a_button_movement_mode:
	ld a, 0
	call player_trigger
	ret
a_button_selector_mode:
	call selector_select
	ret

b_button:
	ld a, [selector_mode]
	cp 0
	jp nz, b_button_selector_mode
b_button_movement_mode:
	call selector_start_selecting
	ld a, 1
	call player_trigger
	; check if we actually found anything
	ld a, [selector_found_count]
	cp 0
	jp z, b_button_movement_mode_done
	ld a, 1
	ld [selector_mode], a
	call selector_set_sprites
b_button_movement_mode_done:
	ret
b_button_selector_mode:
	; disable selector mode
	ld a, 0
	ld [selector_mode], a
	; reset current info
	call selector_start_selecting
	call selector_set_sprites
	ret

select_button:
	call hud_toggle_pause
	ret

move_up:
	push af
	ld a, [player_y]
	dec a
	ld b, a
	ld a, [player_x]
	ld c, a
	call check_for_collision
	jp z, move_done
	ld hl, player_y
	dec [hl]
	jp move_done
move_down:
	push af
	ld a, [player_y]
	inc a
	ld b, a
	ld a, [player_x]
	ld c, a
	call check_for_collision
	jp z, move_done
	ld hl, player_y
	inc [hl]
	jp move_done
move_left:
	push af
	ld a, [player_y]
	ld b, a
	ld a, [player_x]
	dec a
	ld c, a
	call check_for_collision
	jp z, move_done
	ld hl, player_x
	dec [hl]
	jp move_done
move_right:
	push af
	ld a, [player_y]
	ld b, a
	ld a, [player_x]
	inc a
	ld c, a
	call check_for_collision
	jp z, move_done
	ld hl, player_x
	inc [hl]
move_done:
	ld a, 1
	ld [new_scroll_available], a
	call calc_viewport_scroll
	pop af
	ret