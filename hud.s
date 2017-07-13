; hud_init: Initializes variables and memory related to the HUD.
hud_init:
	ld a, 0
	ld [hud_pause_active], a
	ld [hud_pause_selection], a
	ret

; hud_draw: Draws the HUD.
hud_draw:
	ld bc, bg_tile_map_2
	ld a, 0x7c
	ld d, SCREEN_WIDTH_TILES
	call vmemset

	call wait_for_vblank_ly
	ld hl, (bg_tile_map_2 + (32*2) + 1)
	ld bc, hud_pause_title
	call strcpy

	call wait_for_vblank_ly
	ld hl, (bg_tile_map_2 + (32*4) + 2)
	ld bc, hud_pause_option1
	call strcpy

	call wait_for_vblank_ly
	ld hl, (bg_tile_map_2 + (32*5) + 2)
	ld bc, hud_pause_option2
	call strcpy

	call wait_for_vblank_ly
	ld hl, (bg_tile_map_2 + (32*7) + 1)
	ld bc, hud_pause_password
	call strcpy

	ret

; hud_tick_early: Run every frame the HUD is active, immediately after vblank is entered.
hud_tick_early:
	ld a, [hud_pause_active]
	cp 0
	ret z

	ld a, [menu_frame_counter]
	inc a
	ld [menu_frame_counter], a
	bit 5, a
	ret z

	ld a, [hud_pause_selection]
	cp 0

	ld a, 0
	ld [menu_frame_counter], a
	jp nz, hud_tick_early_cursor2
hud_tick_early_cursor1:
	ld [(bg_tile_map_2 + (32*5) + 1)], a
	ld hl, (bg_tile_map_2 + (32*4) + 1)
	jp hud_tick_early_cursor_done
hud_tick_early_cursor2:
	ld [(bg_tile_map_2 + (32*4) + 1)], a
	ld hl, (bg_tile_map_2 + (32*5) + 1)

hud_tick_early_cursor_done:
	ld a, [hl]
	cp 0
	jp z, hud_tick_early_from_zero
	ld a, 0
	jp hud_tick_early_finish_blink
hud_tick_early_from_zero:
	ld a, 0x10
hud_tick_early_finish_blink:
	ld [hl], a

	ret

; hud_tick_late: Run at the very end of every frame, when it might not be possible to mess with VRAM.
hud_tick_late:
	

	ret

; hud_pause_input: Handles d-pad input when paused.
hud_pause_input:
	push af

	push bc
	push de

	bit 2, a ; is the up button down?
	jp nz, hud_pause_input_skip_up
	bit 2, c ; was it up before?
	ld d, 1
	call nz, hud_pause_move
hud_pause_input_skip_up:
	bit 3, a ; is the down button down?
	jp nz, hud_pause_input_skip_done
	bit 3, c ; was it up before?
	ld d, 255
	call nz, hud_pause_move
hud_pause_input_skip_done:
	
	pop de
	pop bc

	pop af
	ret

; hud_pause_move: Moves the HUD pause cursor.
hud_pause_move:
	push af
	
	ld a, [hud_pause_selection]
	inc a
	and 0b00000001
	ld [hud_pause_selection], a

	cp 0

	ld a, 0
	jp nz, hud_pause_move_option2
hud_pause_move_option1:
	ld [(bg_tile_map_2 + (32*5) + 1)], a
	ld a, 0x10
	ld [(bg_tile_map_2 + (32*4) + 1)], a
	jp hud_pause_move_option_done
hud_pause_move_option2:
	ld [(bg_tile_map_2 + (32*4) + 1)], a
	ld a, 0x10
	ld [(bg_tile_map_2 + (32*5) + 1)], a
hud_pause_move_option_done:
	pop af
	ret

; hud_pause_select: Activates the currently selected option in the pause menu.
hud_pause_select:
	ld a, [hud_pause_selection]
	cp 1
	jp z, hud_pause_select_option2
	; resume game
	jp hud_toggle_pause
hud_pause_select_option2:
	; back to menu
	; clear stack
	pop af
	ld a, 0
	ld [current_screen], a
	call screen_load
	jp screen_loop

; hud_toggle_pause: Toggles the pause mode.
hud_toggle_pause:
	ld a, [hud_pause_active]
	inc a
	and 0b00000001
	ld [hud_pause_active], a
	cp 1
	jp z, hud_toggle_pause_enable
hud_toggle_pause_disable:
	; disable pause
	ldh a, [WY]
	cp (SCREEN_HEIGHT_PX - HUD_HEIGHT_PX)
	jp z, hud_toggle_pause_disable_done
	inc a
	ldh [WY], a
	ld a, 0b00000001
	ldh [IE], a
	halt
	nop
	jp hud_toggle_pause_disable
hud_toggle_pause_disable_done:
	call calc_viewport_scroll ; unhide zums
	jp hud_toggle_pause_done
hud_toggle_pause_enable:
	; enable pause
	; hide zums
	ld a, 0
	ld [sprite0_y], a
	ld [sprite1_y], a
	; clear dialogue a button prompt
	ld a, 0
	ld [(bg_tile_map_2 + 32 + 32 + 32 + SCREEN_WIDTH_TILES - 1)], a
	; generate password
	call password_generate
	call wait_for_vblank_ly
	ld hl, (bg_tile_map_2 + (32*7) + 11)
	ld bc, password_buffer
	call strcpy
hud_toggle_pause_enable_loop:
	; open the window
	ldh a, [WY]
	cp (SCREEN_HEIGHT_PX - HUD_PAUSE_HEIGHT_PX)
	jp z, hud_toggle_pause_done
	dec a
	ldh [WY], a
	ld a, 0b00000001
	ldh [IE], a
	halt
	nop
	jp hud_toggle_pause_enable_loop
hud_toggle_pause_done:
	ret

hud_pause_title:
	asciz "Pause menu"

hud_pause_option1:
	asciz "Resume game"

hud_pause_option2:
	asciz "Back to menu"

hud_pause_password:
	asciz "Password: "