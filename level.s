; decompress_level: Decompresses the level pointed to by BC into the temp level buffer
decompress_level:
	; switch the ram to bank 1 (with the level buffer)
	ld a, 1
	ldh [SVBK], a

	ld hl, temp_level_buffer

decompress_level_loop:
	ld a, [bc]
	inc bc
	cp 0xFF
	jp z, load_level_from_temp_buffer ; end of level
	bit 7, a
	jp nz, decompress_level_decompress_stream
	; it's just a single tile
	cp 0
	jp z, decompress_level_single_add_tile
	add a, 0x7F
decompress_level_single_add_tile:
	ldi [hl], a
	jp decompress_level_loop
decompress_level_decompress_stream:
	; it's a stream of multiple tiles
	ld e, a
	ld a, [bc] ; get the tile count
	ld d, a
	ld a, e

	dec a
	cp 0x7F
	jp nz, decompress_level_decompress_stream_not_air
	ld a, 0
decompress_level_decompress_stream_not_air:

	; a = tile
	; d = tile count
decompress_level_decompress_stream_loop:
	ldi [hl], a
	dec d
	jp nz, decompress_level_decompress_stream_loop

	inc bc
	jp decompress_level_loop

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

load_level_from_temp_buffer:
	; copy the trigger table
	ld hl, temp_level_triggertable_buffer
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
	cp 0xAE
	jp z, load_level_palette_3
	cp 0xAF
	jp z, load_level_palette_3
	load_level_palette_0:
	ld a, 0
	jp load_level_palette_inner_loop_done
	load_level_palette_1:
	ld a, 1
	jp load_level_palette_inner_loop_done
	load_level_palette_2:
	ld a, 2
	jp load_level_palette_inner_loop_done
	load_level_palette_3:
	ld a, 3
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
	ld [new_scroll_x], a
	ld a, 72
	add a, 0x8
	ld [sprite0_x], a
	jp calc_viewport_scroll_check_y
calc_viewport_scroll_x_left_edge:
	add a, 0x8
	ld [sprite0_x], a
	ld a, 0
	ld [new_scroll_x], a
	jp calc_viewport_scroll_check_y
calc_viewport_scroll_x_right_edge:
	sub 95
	add a, 0x8
	ld [sprite0_x], a
	ld a, (VRAM_WIDTH_PX - SCREEN_WIDTH_PX)
	ld [new_scroll_x], a

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
	cp (VRAM_HEIGHT_PX - 76)
	jp nc, calc_viewport_scroll_y_bottom_edge
	; we are in the center
	sub 68
	ld [new_scroll_y], a
	ld a, 68
	add a, 0x10
	ld [sprite0_y], a
	jp calc_viewport_scroll_done
calc_viewport_scroll_y_top_edge:
	add a, 0x10
	ld [sprite0_y], a
	ld a, 0
	ld [new_scroll_y], a
	jp calc_viewport_scroll_done
calc_viewport_scroll_y_bottom_edge:
	add a, 0x10
	sub ((VRAM_HEIGHT_PX - SCREEN_HEIGHT_PX) + HUD_HEIGHT_PX)
	ld [sprite0_y], a
	ld a, ((VRAM_HEIGHT_PX - SCREEN_HEIGHT_PX) + HUD_HEIGHT_PX)
	ld [new_scroll_y], a

calc_viewport_scroll_done:
	; position the right side
	ld a, [sprite0_x]
	add a, 8
	ld [sprite1_x], a
	ld a, [sprite0_y]
	ld [sprite1_y], a
	ld a, 1
	ld [sprite1_t], a

	; if new_scroll_available == 0, immediately set registers
	ld a, [new_scroll_available]
	cp 0
	ret nz ; it's already 1, so the vblank-synced loop will handle it
	ld a, [new_scroll_x]
	ldh [SCX], a
	ld a, [new_scroll_y]
	ldh [SCY], a
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

	; TODO: simplify this
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
	; is it piston horizontal laser?
	cp 7
	jp z, check_tile_is_solid_no
	; is it piston vertical laser?
	cp 9
	jp z, check_tile_is_solid_no
	; is it piston combo laser?
	cp 11
	jp z, check_tile_is_solid_no
	; is it an activated piston arm?
	cp 0xA5
	jp z, check_tile_is_solid_no
	cp 0xA7
	jp z, check_tile_is_solid_no
	cp 0xA9
	jp z, check_tile_is_solid_no
	cp 0xAB
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

	; fix piston arms cleared in the last step
	ld hl, calculate_level_laser_fix_pistons
	call calculate_level_lasers_for_each

	; for each lever, call laser_lever_trigger
	ld hl, calculate_level_laser_check_lever
	call calculate_level_lasers_for_each

	; for each emitter, call calculate_level_laser_from_emitter
	ld hl, calculate_level_laser_check_emitter
	call calculate_level_lasers_for_each

	; update the VRAM
	ldh a, [LCDC]
	cp 0
	jp z, copy_temp_level_buffer_to_bg ; screen is off, don't bother waiting for vblank
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
	cp 0xAF
	jp z, calculate_level_loop_resume

	; are you the horizontal laser, which goes from 0x3 -> 0x0?
	cp 0x3
	jp z, calculate_level_laser_clear_hlaser_tile
	; are you the combo laser, which goes from 0x5 -> 0x0?
	cp 0x5
	jp z, calculate_level_laser_clear_hlaser_tile

	; are you a secret piston arm?
	cp 0x7
	jp z, calculate_level_laser_clear_hlaser_tile
	cp 0x9
	jp z, calculate_level_laser_clear_hlaser_tile
	cp 0xb
	jp z, calculate_level_laser_clear_hlaser_tile

	; no, so turn it off
	res 0, a
	ld [bc], a

	jp calculate_level_loop_resume
calculate_level_laser_clear_hlaser_tile:
	ld a, 0
	ld [bc], a
	jp calculate_level_loop_resume

; calculate_level_laser_fix_pistons: adds in the correct piston arms for pistons
calculate_level_laser_fix_pistons:
	ld a, [bc]
	; are you a piston base?
	cp 0x9C
	jp c, calculate_level_loop_resume ; tile is < 0x9C
	cp (0xA3 + 1)
	jp nc, calculate_level_loop_resume ; tile is >= (0xA3 + 1)
	
	; ok you are, find where the arm goes and set that
	push hl
	push de
	push bc
	ld hl, level_laser_step_table
	sub 0x9C ; a = double the direction
	push af
	res 0, a
	ld b, 0
	ld c, a
	add hl, bc
	
	ldi a, [hl]
	ld d, a
	ldi a, [hl]
	ld e, a

	pop af
	pop bc
	ld h, b
	ld l, c
	add hl, de

	add a, 0xA4 ; find the right tile
	ld [hl], a

	pop de
	pop hl
	jp calculate_level_loop_resume

; calculate_level_laser_check_lever: checks if the given tile is a lever or active terminal, and if so, triggers its target
calculate_level_laser_check_lever:
	ld a, [bc]

	cp 0x9B
	jp z, calculate_level_laser_check_lever_is_lever
	cp 0xAF
	jp nz, calculate_level_laser_check_lever_done

	; it's a terminal
	push hl
	ld hl, (temp_level_buffer + 0x0)
	ld a, 3 ; nonogram mode
	call player_trigger_tile
	pop hl
	jp calculate_level_laser_check_lever_done

calculate_level_laser_check_lever_is_lever:
	push hl
	ld h, b
	ld l, c
	ld a, 2
	call player_trigger_tile
	pop hl
	ld a, 0x9B
	ld [bc], a

calculate_level_laser_check_lever_done:
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

	; check if that tile is a receptor
	; receptors are from 0x8A to 0x91, inclusive
	ld a, [hl]
	cp 0x8A
	jp c, calculate_level_laser_from_emitter_not_receptor ; a < 0x8A
	cp (0x91+1)
	jp nc, calculate_level_laser_from_emitter_not_receptor ; a >= (0x91 + 1)

	; ok it's a receptor then
	; check its direction
	sub 0x8A
	srl a
	; get the direction we need the laser to be going
	add a, 2
	and 3
	; check if the laser is actually going that direction
	cp d
	jp nz, calculate_level_laser_from_emitter_done
	; ok it's right
	set 0, [hl] ; turn it on
	ld a, 2 ; trigger it with the laser trigger mode rather than the player trigger mode
	call player_trigger_tile

	jp calculate_level_laser_from_emitter_done
calculate_level_laser_from_emitter_not_receptor:

	; check if that tile is solid
	call check_tile_is_solid_from_hl
	jp z, calculate_level_laser_from_emitter_done ; it is solid, rip path

	push af
	; check if that tile is a piston arm
	ld a, [hl]
	ld e, 0
	cp 0xA4
	jp c, calculate_level_laser_from_emitter_not_piston_arm ; a < 0xA4
	cp (0xAB + 1)
	jp nc, calculate_level_laser_from_emitter_not_piston_arm ; a >= (0xAB + 1)
	ld e, 6 ; it is, offset the laser tile selection
calculate_level_laser_from_emitter_not_piston_arm:
	; figure out what tile to place
	ld a, e
	add a, 0x1
	ld e, a
	bit 0, d
	jp z, calculate_level_laser_from_emitter_tile_loop_dir_done ; it's either up or down
	add a, 0x2
	ld e, a
calculate_level_laser_from_emitter_tile_loop_dir_done:
	pop af
	; it isn't solid, so set it to a laser and keep going
	; but first check if it already is a laser, in which case we set it to the combo tile
	ld a, [hl]
	cp 1
	jp z, calculate_level_laser_from_emitter_tile_loop_dir_done_combo_laser
	cp 3
	jp z, calculate_level_laser_from_emitter_tile_loop_dir_done_combo_laser
	cp 7
	jp z, calculate_level_laser_from_emitter_tile_loop_dir_done_combo_laser
	cp 9
	jp z, calculate_level_laser_from_emitter_tile_loop_dir_done_combo_laser
	ld a, e
	ld [hl], a
	jp calculate_level_laser_from_emitter_tile_loop
calculate_level_laser_from_emitter_tile_loop_dir_done_combo_laser:
	ld a, [hl]
	ld e, 5
	; check if it's a secret piston arm
	cp 7
	jp c, calculate_level_laser_from_emitter_tile_loop_dir_done_combo_laser_not_piston ; a < 7
	cp (9+1)
	jp nc, calculate_level_laser_from_emitter_tile_loop_dir_done_combo_laser_not_piston ; a >= (9+1)
	ld e, 11 ; it is
calculate_level_laser_from_emitter_tile_loop_dir_done_combo_laser_not_piston:
	ld a, e
	ld [hl], a
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
	; did we just toggle a piston base?
	cp 0x9C
	jp c, level_toggle_bc_set_done_not_piston ; a < 0x9C
	cp (0xA3 + 1) ; a >= (0xA3 + 1)
	jp nc, level_toggle_bc_set_done_not_piston

	; we did, so toggle its arm
	push hl
	push de
	push bc
	; find what direction we're in
	ld hl, level_laser_step_table
	sub 0x9C
	srl a
	add a, a ; double it because table entries are two bytes
	ld b, 0
	ld c, a
	add hl, bc
	
	ldi a, [hl]
	ld d, a
	ldi a, [hl]
	ld e, a

	pop bc
	ld h, b
	ld l, c
	add hl, de
	ld b, h
	ld c, l

	call level_toggle_bc

	pop de
	pop hl
level_toggle_bc_set_done_not_piston:
	ret

; level_lever_trigger: Called when a lever is toggled
level_lever_trigger:
	; toggle the lever tile
	call level_toggle_bc
level_receptor_trigger:
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
	jp player_trigger_tile_entry_resume

level_sign_trigger:
	; get the target script
	ld h, d
	ld l, e
	ldi a, [hl]
	ld d, a
	ldi a, [hl]
	ld h, a
	ld l, d
	call dialogue_start_script
	jp player_trigger_tile_entry_resume

level_terminal_trigger:
	; test the tile
	ld h, b
	ld l, c
	bit 0, [hl]
	jp z, level_terminal_trigger_continue

	; the lowest bit is set, meaning we've already done this
	ld hl, script_msg_duckpuzz_already_done
	call dialogue_start_script
	jp player_trigger_tile_entry_resume

level_terminal_trigger_continue:
	; switch the tile because you can't exit a puzzle w/o completing it
	set 0, [hl]

	call wait_for_vblank_ly
	call copy_temp_level_buffer_to_bg

	; get the target nonogram
	ld h, d
	ld l, e
	ldi a, [hl]
	ld d, a
	ldi a, [hl]
	ld h, a
	ld l, d
	call nonogram_start_puzzle
	jp player_trigger_tile_entry_resume

level_complete:
	; clear the stack
	; i know this is a dumb way to do this
	; a better way would be to just return upwards until we get back to the game loop
	; but i'm tired and don't want to deal with complicated lr35902 assembly so too bad
	pop af
	pop af
	pop af
	pop af
	pop af
	pop af
	pop af
	pop af

	jp prog_advance_level
