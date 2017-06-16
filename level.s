
; load_level: Loads the level pointed to by BC to tile map 1.
load_level:
	; switch the ram to bank 1 (with the level buffer)
	ld a, 1
	ldh [SVBK], a

	ld hl, temp_level_buffer

	; copy the data to the temp level buffer
	ld e, 8
load_level_to_temp_loop:
	ld d, 128
	call memcpy
	dec e
	jp nz, load_level_to_temp_loop

	; set the tile bank to color palette mode
	ld a, 1
	ldh [VBK], a

	; loop over every tile, set the appropriate color palette
	ld hl, temp_level_buffer
	ld bc, bg_tile_map_1
	ld e, 8
load_level_palette_loop:
	ld d, 128
load_level_palette_inner_loop:
	ldi a, [hl]
	cp 0x81
	jp z, load_level_palette_1
	jp load_level_palette_0
	load_level_palette_0:
	ld a, 0
	jp load_level_palette_inner_loop_done
	load_level_palette_1:
	ld a, 1
	load_level_palette_inner_loop_done:
	ld [bc], a
	inc bc

	dec d
	jp nz, load_level_palette_inner_loop
	dec e
	jp nz, load_level_palette_loop

	; set the tile bank to tile mode
	ld a, 0
	ldh [VBK], a

	; calculate laser paths, and that function will copy the level from the temp buffer to tile map 1
	jp calculate_level_lasers

; copy_temp_level_buffer_to_bg: Uses the general-purpose DMA to copy the temp level buffer to the first tile map.
copy_temp_level_buffer_to_bg:
	; set source
	ld a, (temp_level_buffer >> 8)
	ldh [HDMA1], a
	ld a, (temp_level_buffer & 0xFF)
	ldh [HDMA2], a

	; set destination
	ld a, (bg_tile_map_1 >> 8)
	ldh [HDMA3], a
	ld a, (bg_tile_map_1 & 0xFF)
	ldh [HDMA4], a

	; set number of bytes and go
	ld a, (LEVEL_TILE_COUNT >> 4)
	ldh [HDMA5], a

	ret

calc_viewport_scroll:
	; the screen is 160x144
	; player is 8x8
	; center player is at (76, 68)

	; if x < 76, SCX = 0, sprite x = x
	; if x > (VRAM_WIDTH_PX - 76), SCX = (VRAM_WIDTH_PX - SCREEN_WIDTH_PX), sprite x = x - SCX
	; else, SCX = x - 76, sprite x = 76
	call wait_for_vblank
	ld a, [player_x]

	; are we on the far left?
	cp 72
	jp c, calc_viewport_scroll_x_left_edge
	; are we on the far right?
	cp (VRAM_WIDTH_PX - (72 + 16))
	jp nc, calc_viewport_scroll_x_right_edge
	; we are in the center
	sub 72
	ldh [SCX], a
	ld a, 72
	add a, 0x8
	ld [sprite0_x], a
	jp calc_viewport_scroll_check_y
calc_viewport_scroll_x_left_edge:
	add a, 0x8
	ld [sprite0_x], a
	ld a, 0
	ldh [SCX], a
	jp calc_viewport_scroll_check_y
calc_viewport_scroll_x_right_edge:
	sub 95
	add a, 0x8
	ld [sprite0_x], a
	ld a, (VRAM_WIDTH_PX - SCREEN_WIDTH_PX)
	ldh [SCX], a

calc_viewport_scroll_check_y:
	; if y < 68, SCY = 0, sprite y = y
	; if y > (VRAM_HEIGHT_PX - 68), SCY = (VRAM_HEIGHT_PX - SCREEN_HEIGHT_PX + HUD_HEIGHT_PX), sprite y = y - SCY
	; else, SCY = x - 68, sprite y = 68
	call wait_for_vblank
	ld a, [player_y]

	; are we at the top?
	cp 68
	jp c, calc_viewport_scroll_y_top_edge
	; are we at the bottom?
	cp (VRAM_HEIGHT_PX - 60)
	jp nc, calc_viewport_scroll_y_bottom_edge
	; we are in the center
	sub 68
	ldh [SCY], a
	ld a, 68
	add a, 0x10
	ld [sprite0_y], a
	jp calc_viewport_scroll_done
calc_viewport_scroll_y_top_edge:
	add a, 0x10
	ld [sprite0_y], a
	ld a, 0
	ldh [SCY], a
	jp calc_viewport_scroll_done
calc_viewport_scroll_y_bottom_edge:
	add a, 0x10
	sub ((VRAM_HEIGHT_PX - SCREEN_HEIGHT_PX) + HUD_HEIGHT_PX)
	ld [sprite0_y], a
	ld a, ((VRAM_HEIGHT_PX - SCREEN_HEIGHT_PX) + HUD_HEIGHT_PX)
	ldh [SCY], a

calc_viewport_scroll_done:
	; position the right side
	ld a, [sprite0_x]
	add a, 8
	ld [sprite1_x], a
	ld a, [sprite0_y]
	ld [sprite1_y], a
	ld a, 1
	ld [sprite1_t], a
	ret

; check_tile_is_solid: Set Z if the tile at (d, e) is solid, else clear Z.
check_tile_is_solid:
	ld hl, temp_level_buffer
	ld bc, 32
	ld a, e
	cp 0
	jp z, check_tile_is_solid_skip_loop
check_tile_is_solid_y_inc:
	add hl, bc
	dec e
	jp nz, check_tile_is_solid_y_inc

check_tile_is_solid_skip_loop:
	ld c, d
	add hl, bc
check_tile_is_solid_from_hl:
	ld a, [hl]

	; is it air?
	cp 0
	jp z, check_tile_is_solid_no
	; is it laser?
	cp 1
	jp z, check_tile_is_solid_no

	; ok it must be solid then
	ld a, 1
	jp check_tile_is_solid_end
check_tile_is_solid_no:
	ld a, 2
check_tile_is_solid_end:
	dec a
	ret

; check_for_collision: Checks if the player will collide with anything at position (c, b)
check_for_collision:
	; load in the bank with the level buffer
	ld a, 1
	ldh [SVBK], a

	; find what tile we're on
	; (player_x / 8, player_y / 8)

	ld a, c ; load the x
	srl a
	srl a
	srl a
	ld d, a

	ld a, b ; load the y
	srl a
	srl a
	srl a
	ld e, a

	; check top-left corner of player
	push bc
	push de
	call check_tile_is_solid
	pop de
	pop bc
	ret z

	; check middle-right corner of player
	ld a, c
	add a, 7
	srl a
	srl a
	srl a
	ld d, a
	push bc
	push de
	call check_tile_is_solid
	pop de
	pop bc
	ret z

	; check top-right corner of player
	ld a, c
	add a, 8+7
	srl a
	srl a
	srl a
	ld d, a
	push bc
	push de
	call check_tile_is_solid
	pop de
	pop bc
	ret z

	; move to bottom
	ld a, b
	add a, 7
	srl a
	srl a
	srl a
	ld e, a

	; check bottom-right corner of player
	; THE D REGISTER IS SAVED FROM THE LAST CALCULATION
	push bc
	push de
	call check_tile_is_solid
	pop de
	pop bc
	ret z

	; check bottom-middle corner of player
	ld a, c
	add a, 7
	srl a
	srl a
	srl a
	ld d, a
	push bc
	push de
	call check_tile_is_solid
	pop de
	pop bc
	ret z

	; check bottom-left corner of player
	ld a, c
	srl a
	srl a
	srl a
	ld d, a
	push bc
	push de
	call check_tile_is_solid
	pop de
	pop bc
	ret z

	ret

; calculate_level_lasers: Recalculates all laser paths in the level.
calculate_level_lasers:
	; switch the ram to bank 1 (with the level buffer)
	ld a, 1
	ldh [SVBK], a

	ld hl, temp_level_buffer
	; clear all currently on things (except emitters)

	ld hl, calculate_level_laser_check_emitter
	; for each emitter, call calculate_level_laser_from_emitter
	call calculate_level_lasers_for_each

	; update the VRAM
	call wait_for_vblank
	jp copy_temp_level_buffer_to_bg

; calculate_level_lasers_for_each: calls hl for every tile, with bc holding the current tile
calculate_level_lasers_for_each:
	ld bc, temp_level_buffer
	ld d, 0
calculate_level_lasers_for_each_row_loop:
	ld e, 0
calculate_level_lasers_for_each_col_loop:
	jp hl

calculate_level_loop_resume:
	inc bc
	inc e
	ld a, e
	cp 32
	jp nz, calculate_level_lasers_for_each_col_loop
	inc d
	ld a, d
	cp 32
	jp nz, calculate_level_lasers_for_each_row_loop

	ret

; calculate_level_laser_check_emitter: checks if the given tile is an emitter, and if so, begins calculating its path
calculate_level_laser_check_emitter:
	; check what tile it is
	ld a, [bc]
	cp 0x83 ; enabled laser emitter?
	jp nz, calculate_level_laser_check_emitter_done

	; it is!
	call calculate_level_laser_from_emitter

calculate_level_laser_check_emitter_done:
	jp calculate_level_loop_resume

; calculate_level_laser_from_emitter: follows the path from the emitter
calculate_level_laser_from_emitter:
	push bc
	push hl

	ld h, b
	ld l, c

calculate_level_laser_from_emitter_tile_loop:
	; find the next tile
	push bc
	ld b, 0xFF ; bc = -32
	ld c, 0xE0
	add hl, bc
	pop bc

	; check if that tile is solid
	call check_tile_is_solid_from_hl
	jp z, calculate_level_laser_from_emitter_done ; it is solid, rip path

	; it isn't solid, so set it to a laser and keep going
	ld [hl], 0x1
	ld b, b
	jp calculate_level_laser_from_emitter_tile_loop

calculate_level_laser_from_emitter_done:
	pop hl
	pop bc
	ret