menu_title:
	asciz "Zum Puzzler Pocket"

menu_option1:
	asciz "New game"

menu_option2:
	asciz "Continue"

menu_init:
	ld a, 0
	ld [menu_selection], a
	ld [menu_frame_counter], a
	ret

menu_load:
	; palette mode
	ld a, 1
	ldh [VBK], a

	; reset background palettes
	ld a, 0b00000111
	ld hl, bg_tile_map_1
	ld bc, 2*(bg_tile_map_2 - bg_tile_map_1)
	call clrmem

	; tile mode
	ld a, 0
	ldh [VBK], a

	; clear the tiles
	ld a, 0
	ld hl, bg_tile_map_1
	ld bc, 2*(bg_tile_map_2 - bg_tile_map_1)
	call clrmem
	
	; disable the zum sprites
	ld a, 0
	ld [sprite0_y], a
	ld [sprite1_y], a

	; draw background level
	ld bc, menu_demo_level
	call decompress_level

	; draw gui stuff
	ld hl, (bg_tile_map_2 + 32 + 1)
	ld bc, menu_title
	call strcpy

	ld hl, (bg_tile_map_2 + (32*3) + 2)
	ld bc, menu_option1
	call strcpy

	ld hl, (bg_tile_map_2 + (32*4) + 2)
	ld bc, menu_option2
	call strcpy

	ld a, 7
	ldh [WX], a
	ld a, (SCREEN_HEIGHT_PX - (7*8))
	ldh [WY], a

	ld a, 0b11100011 ; enable window
	ldh [LCDC], a

	jp screen_load_done

menu_loop:
	; wait for vblank
	ld a, 0b00000001
	ldh [IE], a
	halt
	nop

	; check if we should blink the cursor
	ld a, [menu_frame_counter]
	inc a
	ld [menu_frame_counter], a
	bit 5, a
	jp z, menu_loop_skip_blink

	ld a, [menu_selection]
	cp 0

	ld a, 0
	ld [menu_frame_counter], a
	jp nz, menu_loop_cursor2
menu_loop_cursor1:
	ld [(bg_tile_map_2 + (32*4) + 1)], a
	ld hl, (bg_tile_map_2 + (32*3) + 1)
	jp menu_loop_cursor_done
menu_loop_cursor2:
	ld [(bg_tile_map_2 + (32*3) + 1)], a
	ld hl, (bg_tile_map_2 + (32*4) + 1)

menu_loop_cursor_done:
	ld a, [hl]
	cp 0
	jp z, menu_loop_from_zero
	ld a, 0
	jp menu_loop_finish_blink
menu_loop_from_zero:
	ld a, 0x10
menu_loop_finish_blink:
	ld [hl], a
menu_loop_skip_blink:

	; scroll the demo level
	ldh a, [SCX]
	inc a
	ldh [SCX], a

	; handle input
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

	bit 2, a ; up button
	jp nz, menu_loop_input_skip_up
	bit 2, c
	call nz, menu_move_cursor
menu_loop_input_skip_up:
	bit 3, a ; down button
	jp nz, menu_loop_input_skip_down
	bit 3, c
	call nz, menu_move_cursor
menu_loop_input_skip_down:
	bit 0, b ; a button
	jp nz, menu_loop_input_skip_a
	bit 0, d
	jp nz, menu_select_option
menu_loop_input_skip_a:

	ld [last_p14], a
	ld a, b
	ld [last_p15], a

	jp menu_loop

; menu_move_cursor: Moves the menu cursor to the other option.
menu_move_cursor:
	push af

	; change the variable
	ld a, [menu_selection]
	inc a
	and 1
	ld [menu_selection], a

	; change the selection arrow
	cp 0

	ld a, 0
	jp nz, menu_move_cursor2
menu_move_cursor1:
	ld [(bg_tile_map_2 + (32*4) + 1)], a
	ld a, 0x10
	ld [(bg_tile_map_2 + (32*3) + 1)], a
	pop af
	ret
menu_move_cursor2:
	ld [(bg_tile_map_2 + (32*3) + 1)], a
	ld a, 0x10
	ld [(bg_tile_map_2 + (32*4) + 1)], a
	pop af
	ret

; menu_select_option: Activates the currently selected option.
menu_select_option:
	ld a, [menu_selection]
	cp 0
	jp z, menu_new_game
	jp menu_continue_game

; menu_new_game: Handles starting a new game.
menu_new_game:
	; start the story
	ld a, 2
	ld [current_screen], a

	call screen_load
	jp screen_loop

; menu_continue_game: Handles continuing a game from a password.
menu_continue_game:
	ld a, 16
	ld [prog_current_level], a
	jp prog_load_current_level

	call screen_load
	jp screen_loop

menu_demo_level:
	db 0x81, 0x20, 0x80, 0x06, 0x81, 0x03, 0x80, 0x07, 0x13, 0x80, 0x04, 0x15, 0x80, 0x10, 0x81, 0x03, 0x80, 0x0b, 0x13, 0x80, 0x08, 0x15, 0x80, 0x09, 0x21, 0x13, 0x00, 0x00, 0x17, 0x80, 0x1b, 0x29, 0x19, 0x80, 0x13, 0x15, 0x80, 0x09, 0x81, 0x03, 0x80, 0x04, 0x13, 0x80, 0x07, 0x17, 0x80, 0x09, 0x04, 0x01, 0x01, 0x06, 0x80, 0x19, 0x17, 0x0b, 0x81, 0x05, 0x80, 0x03, 0x81, 0x03, 0x80, 0x04, 0x19, 0x80, 0x0e, 0x11, 0x81, 0x07, 0x00, 0x00, 0x81, 0x03, 0x80, 0x13, 0x81, 0x08, 0x00, 0x00, 0x81, 0x03, 0x80, 0x07, 0x04, 0x00, 0x03, 0x00, 0x04, 0x80, 0x07, 0x81, 0xff, 0x81, 0x05, 0x80, 0xff, 0x80, 0xc1
	db 0xff

menu_demo_level_triggertable:
	db 0
	db 0