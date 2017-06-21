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

	; copy the trigger table
	ld a, [bc] ; get its length first
	add a, 2 ; add one to it so the length and entry count is copied too
	ld d, a
	call memcpy

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
	cp 0x9A
	jp z, load_level_palette_2
	cp 0x9B
	jp z, load_level_palette_2
	load_level_palette_0:
	ld a, 0
	jp load_level_palette_inner_loop_done
	load_level_palette_1:
	ld a, 1
	jp load_level_palette_inner_loop_done
	load_level_palette_2:
	ld a, 2
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
	ld a, ((LEVEL_TILE_COUNT >> 4) - 1)
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
	; is it horizontal laser?
	cp 1
	jp z, check_tile_is_solid_no
	; is it debug smiley?
	cp 2
	jp z, check_tile_is_solid_no
	; is it vertical laser?
	cp 3
	jp z, check_tile_is_solid_no
	; is it combo laser?
	cp 5
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

	; clear all currently on things (except emitters)
	ld hl, calculate_level_laser_clear_tile
	call calculate_level_lasers_for_each

	; for each emitter, call calculate_level_laser_from_emitter
	ld hl, calculate_level_laser_check_emitter
	call calculate_level_lasers_for_each

	; update the VRAM
	ld a, 0b00000001
	ldh [IE], a
	halt
	nop
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

; calculate_level_laser_clear_tile: turns all laser tiles that aren't emitters off
calculate_level_laser_clear_tile:
	ld a, [bc]

	; do you have bit 0 set?
	bit 0, a
	jp z, calculate_level_loop_resume ; if no, it cannot be an on laser tile.

	; are you one of the special exceptions?
	cp 0x81
	jp z, calculate_level_loop_resume
	cp 0x83
	jp z, calculate_level_loop_resume
	cp 0x85
	jp z, calculate_level_loop_resume
	cp 0x87
	jp z, calculate_level_loop_resume
	cp 0x89
	jp z, calculate_level_loop_resume
	cp 0x9B
	jp z, calculate_level_loop_resume

	; are you the horizontal laser, which goes from 0x3 -> 0x0?
	cp 0x3
	jp z, calculate_level_laser_clear_hlaser_tile
	; are you the combo laser, which goes from 0x5 -> 0x0?
	cp 0x5
	jp z, calculate_level_laser_clear_hlaser_tile

	; no, so turn it off
	res 0, a
	ld [bc], a

	jp calculate_level_loop_resume
calculate_level_laser_clear_hlaser_tile:
	ld a, 0
	ld [bc], a
	jp calculate_level_loop_resume

; calculate_level_laser_check_emitter: checks if the given tile is an emitter, and if so, begins calculating its path
calculate_level_laser_check_emitter:
	push de
	; check what tile it is
	ld a, [bc]

	cp 0x83 ; laser emitter, dir 0, on
	ld d, 0 ; direction
	jp z, calculate_level_laser_check_emitter_go
	cp 0x85 ; laser emitter, dir 1, on
	ld d, 1 ; direction
	jp z, calculate_level_laser_check_emitter_go
	cp 0x87 ; laser emitter, dir 2, on
	ld d, 2 ; direction
	jp z, calculate_level_laser_check_emitter_go
	cp 0x89 ; laser emitter, dir 3, on
	ld d, 3 ; direction
	jp z, calculate_level_laser_check_emitter_go

	; must not be then
	jp calculate_level_laser_check_emitter_done
calculate_level_laser_check_emitter_go:
	; it is!
	call calculate_level_laser_from_emitter

calculate_level_laser_check_emitter_done:
	pop de
	jp calculate_level_loop_resume

; calculate_level_laser_from_emitter: follows the path from the emitter
; Input: d = direction
calculate_level_laser_from_emitter:
	push bc
	push hl

	ld h, b
	ld l, c

calculate_level_laser_from_emitter_tile_loop:
	; find the next tile
	push bc
	call level_laser_step_one
	pop bc

	; TODO: maybe use a jump table for this?

	; check if that tile is a reflector
	; reflector ids: 0x92, 0x94, 0x96, 0x98
	ld a, [hl]
	cp 0x92
	jp z, calculate_level_laser_from_emitter_tile_loop_reflector
	cp 0x94
	jp z, calculate_level_laser_from_emitter_tile_loop_reflector
	cp 0x96
	jp z, calculate_level_laser_from_emitter_tile_loop_reflector
	cp 0x98
	jp z, calculate_level_laser_from_emitter_tile_loop_reflector

	; check if that tile is solid
	call check_tile_is_solid_from_hl
	jp z, calculate_level_laser_from_emitter_done ; it is solid, rip path

	; figure out what tile to place
	bit 0, d
	ld e, 0x1
	jp z, calculate_level_laser_from_emitter_tile_loop_dir_done ; it's either up or down
	ld e, 0x3

calculate_level_laser_from_emitter_tile_loop_dir_done:
	; it isn't solid, so set it to a laser and keep going
	; but first check if it already is a laser, in which case we set it to the combo tile
	bit 0, [hl]
	jp nz, calculate_level_laser_from_emitter_tile_loop_dir_done_combo_laser ; the only non-solid tiles with bit 0 set are the laser ones
	ld a, e
	ld [hl], a
	jp calculate_level_laser_from_emitter_tile_loop
calculate_level_laser_from_emitter_tile_loop_dir_done_combo_laser:
	ld [hl], 5
	jp calculate_level_laser_from_emitter_tile_loop

calculate_level_laser_from_emitter_tile_loop_reflector:
	push bc
	; check its direction
	sub 0x92
	srl a
	ld e, a ; e = direction possiblity 1
	sub 1
	and 3
	ld c, a ; c = direction possiblity 2

	ld a, d
	; check if we can go
	cp e
	ld b, 0x01 ; if we go with the first possibility, we need to add 1 to the direction
	jp z, calculate_level_laser_from_emitter_tile_loop_reflector_ok
	cp c
	ld b, 0xFF ; if we go with the first possibility, we need to subtract 1 from the direction (add -1)
	jp z, calculate_level_laser_from_emitter_tile_loop_reflector_ok
	pop bc
	jp calculate_level_laser_from_emitter_done ; we can't reflect, so rip path
calculate_level_laser_from_emitter_tile_loop_reflector_ok:
	; turn on the reflector
	set 0, [hl]

	; set the new direction
	ld a, d
	add a, b
	and 3 ; make sure it is within 0 to 3
	ld d, a

	pop bc
	jp calculate_level_laser_from_emitter_tile_loop

calculate_level_laser_from_emitter_done:
	pop hl
	pop bc
	ret

level_laser_step_table:
	; up
	db 0xFF ; -32
	db 0xE0

	; right
	db 0x00 ; +1
	db 0x01

	; down
	db 0x00 ; +32
	db 0x20

	; left
	db 0xFF ; -1
	db 0xFF

; level_laser_step_one: Modifies HL by stepping a laser originating from BC one step in direction D.
level_laser_step_one:
	push hl
	push af

	ld hl, level_laser_step_table
	ld a, d
	add a, a
	ld b, 0
	ld c, a
	add hl, bc ; get the entry in the table

	ldi a, [hl]
	ld b, a
	ldi a, [hl]
	ld c, a

	pop af
	pop hl
	add hl, bc
	ret

; level_toggle_bc: Toggles the tile in address BC on or off.
level_toggle_bc:
	ld a, [bc]
	bit 0, a
	jp nz, level_toggle_bc_set_off
	set 0, a
	jp level_toggle_bc_set_done
level_toggle_bc_set_off:
	res 0, a
level_toggle_bc_set_done:
	ld [bc], a
	ret

; level_lever_trigger: Called when a lever is toggled
level_lever_trigger:
	; toggle the lever tile
	call level_toggle_bc

	; get the target
	; this is weird because there's a layer of indirection, where de points to a pointer to the target
	ld h, d
	ld l, e
	ldi a, [hl]
	ld c, a
	ldi a, [hl]
	ld b, a
	cp 0
	jp z, level_lever_trigger_done

	; toggle the target
	call level_toggle_bc

level_lever_trigger_done:
	call calculate_level_lasers

	jp player_trigger_tile_entry_resume