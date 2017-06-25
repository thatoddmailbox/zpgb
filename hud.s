; hud_init: Initializes variables and memory related to the HUD.
hud_init:
	ld a, 0
	ld [num_buf], a
	ret

; hud_draw: Draws the HUD.
hud_draw:
	ld bc, bg_tile_map_2
	ld a, 0x00
	ld d, SCREEN_WIDTH_TILES
	call vmemset
	ret

; hud_tick_early: Run every frame the HUD is active, immediately after vblank is entered.
hud_tick_early:
	ld bc, num_buf
	ld hl, bg_tile_map_2
	call strcpy
	ret

; hud_tick_late: Run at the very end of every frame, when it might not be possible to mess with VRAM.
hud_tick_late:
	; debug info
	ld hl, num_buf

	ld a, [player_x]
	call print_num
	ld a, '-'
	ldi [hl], a
	ld a, [player_y]
	call print_num
	ld a, '-'
	ldi [hl], a
	ld a, [last_p15]
	call print_num
	ld a, '-'
	ldi [hl], a
	ld a, [selector_select_index]
	call print_num

	ld a, 0
	ldi [hl], a

	ret