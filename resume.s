resume_load:
	ld a, 0
	ld [resume_selection], a

	ld hl, password_buffer
	ldi [hl], a
	ldi [hl], a
	ldi [hl], a
	ldi [hl], a
	ldi [hl], a

	; palette mode
	ld a, 1
	ldh [VBK], a

	; reset background palettes
	ld a, 0b00000111
	ld hl, bg_tile_map_2
	ld bc, 2*(bg_tile_map_2 - bg_tile_map_1)
	call clrmem

	; tile mode
	ld a, 0
	ldh [VBK], a

	; clear the tiles
	ld a, 0
	ld hl, bg_tile_map_2
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
	call resume_draw_password

	ld hl, (bg_tile_map_2 + 32)
	ld bc, resume_title
	call strcpy

	ld hl, (bg_tile_map_2 + (32*5))
	ld bc, resume_keys_1
	call strcpy

	ld hl, (bg_tile_map_2 + (32*6))
	ld bc, resume_keys_2
	call strcpy

	ld hl, (bg_tile_map_2 + (32*7))
	ld bc, resume_keys_3
	call strcpy

	ld hl, (bg_tile_map_2 + (32*9) + 2)
	ld bc, resume_back_str
	call strcpy

	ld hl, (bg_tile_map_2 + (32*9) + 15)
	ld bc, resume_done_str
	call strcpy

; 	ld a, 1
; 	ld [current_screen], a
; 	ld a, 0
; 	ld hl, 0xd000
; asdfasdf:
; 	ld [prog_current_level], a
; 	push hl
; 	call password_generate
; 	pop hl
; 	ld bc, password_buffer
; 	call strcpy
; 	ld a, 0
; 	ldi [hl], a
; 	ld a, [prog_current_level]
; 	inc a
; 	cp 20
; 	ld b, b
; 	jp nz, asdfasdf
; 	ld a, 4
; 	ld [current_screen], a


	; lcd control stuff
	ld a, 0
	ldh [SCX], a
	ldh [SCY], a
	ldh [WX], a
	ldh [WY], a

	ld a, 0b10001111
	ldh [LCDC], a

	jp screen_load_done

resume_calculate_cursor_position:
	ld a, [resume_selection]
	cp 26
	jp z, resume_calculate_cursor_position_lower_option_1
	cp 27
	jp z, resume_calculate_cursor_position_lower_option_2
	ld hl, (bg_tile_map_2 + (32*5) + 1)
	ld a, [resume_selection]
	ld de, 32
resume_calculate_cursor_position_loop:
	cp 9
	jp c, resume_calculate_cursor_position_loop_done
	add hl, de
	sub 9
	jp resume_calculate_cursor_position_loop
resume_calculate_cursor_position_loop_done:
	add a, a
	ld d, 0
	ld e, a
	add hl, de
	ret
resume_calculate_cursor_position_lower_option_1:
	ld hl, (bg_tile_map_2 + (32*9) + 1)
	ret
resume_calculate_cursor_position_lower_option_2:
	ld hl, (bg_tile_map_2 + (32*9) + 14)
	ret

resume_loop:
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
	jp z, resume_loop_skip_blink

	; we should
	ld a, 0
	ld [menu_frame_counter], a

	call resume_calculate_cursor_position
	ld a, [hl]
	cp 0x10
	jp z, resume_loop_blink_off
resume_loop_blink_on:
	ld [hl], 0x10
	jp resume_loop_skip_blink
resume_loop_blink_off:
	ld [hl], 0
resume_loop_skip_blink:

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
	jp nz, resume_loop_input_skip_up
	bit 2, c
	call nz, resume_up
resume_loop_input_skip_up:
	bit 3, a ; down button
	jp nz, resume_loop_input_skip_down
	bit 3, c
	call nz, resume_down
resume_loop_input_skip_down:
	bit 1, a ; left button
	jp nz, resume_loop_input_skip_left
	bit 1, c
	call nz, resume_left
resume_loop_input_skip_left:
	bit 0, a ; right button
	jp nz, resume_loop_input_skip_right
	bit 0, c
	call nz, resume_right
resume_loop_input_skip_right:
	bit 0, b ; a button
	jp nz, resume_loop_input_skip_a
	bit 0, d
	call nz, resume_a_button
resume_loop_input_skip_a:
	bit 1, b ; b button
	jp nz, resume_loop_input_skip_b
	bit 1, d
	call nz, resume_b_button
resume_loop_input_skip_b:

	ld [last_p14], a
	ld a, b
	ld [last_p15], a

	jp resume_loop

resume_up:
	push af
	call resume_start_cursor_move
	ld a, [resume_selection]
	cp 26
	jp z, resume_up_very_bottom
	cp 27
	jp z, resume_up_very_bottom
	sub 9
	cp 26
	jp nc, resume_up_to_top
	ld [resume_selection], a
	jp resume_end_cursor_move
resume_up_to_top:
	ld a, 26
	ld [resume_selection], a
	jp resume_end_cursor_move
resume_up_very_bottom:
	ld a, 18
	ld [resume_selection], a
	jp resume_end_cursor_move

resume_down:
	push af
	call resume_start_cursor_move
	ld a, [resume_selection]
	cp 26
	jp z, resume_down_very_bottom
	cp 27
	jp z, resume_down_very_bottom
	add a, 9
	cp 26
	jp nc, resume_down_to_bottom
	ld [resume_selection], a
	jp resume_end_cursor_move
resume_down_to_bottom:
	ld a, 26
	ld [resume_selection], a
	jp resume_end_cursor_move
resume_down_very_bottom:
	ld a, 0
	ld [resume_selection], a
	jp resume_end_cursor_move

resume_left:
	push af
	call resume_start_cursor_move
	ld a, [resume_selection]
	dec a
	cp 255
	jp nz, resume_left_no_change
	ld a, 27
resume_left_no_change:
	ld [resume_selection], a
	jp resume_end_cursor_move

resume_right:
	push af
	call resume_start_cursor_move
	ld a, [resume_selection]
	inc a
	cp 28
	jp nz, resume_right_no_change
	ld a, 0
resume_right_no_change:
	ld [resume_selection], a
	jp resume_end_cursor_move

resume_start_cursor_move:
	; clear the current blinky
	call resume_calculate_cursor_position
	ld a, 0
	ld [hl], a
	ret

resume_end_cursor_move:
	; set the current blinky
	call resume_calculate_cursor_position
	ld a, 0x10
	ld [hl], a
	pop af
	ret

resume_a_button:
	ld a, [resume_selection]
	cp 26
	jp z, resume_back
	cp 27
	jp z, resume_done
	add a, 'A'
	push bc
	ld b, a
	; b now has the ASCII character to add
	ld hl, password_buffer
	ld c, 0
resume_a_button_scan_loop:
	ld a, [hl]
	cp 0
	jp z, resume_a_button_scan_done
	inc hl
	inc c
	jp resume_a_button_scan_loop
resume_a_button_scan_done:
	ld a, c
	cp 4
	jp z, resume_a_button_done ; if it's at max length, just stop
	; add the new character
	ld a, b
	ldi [hl], a
resume_a_button_done:
	call resume_draw_password
	pop bc
	ret

resume_b_button:
	push de
	ld de, password_buffer
	call strlen
	pop de
	cp 0
	ret z
	ld hl, password_buffer
resume_b_button_loop:
	ldi a, [hl]
	cp 0
	jp nz, resume_b_button_loop
resume_b_button_loop_done:
	dec hl
	dec hl
	ld a, 0
	ld [hl], a
	call resume_draw_password
	ret

resume_back:
	pop af
	ld a, 0
	ld [current_screen], a
	call screen_load
	jp screen_loop

resume_done:
	push de
	ld de, password_buffer
	call strlen
	pop de
	cp 4
	ret nz

	call password_activate
	cp 0
	jp z, resume_bad_password
	; it worked! start the screen
	pop af ; clear this function's return address
	ld a, [current_screen]
	cp 1
	jp z, prog_load_current_level ; it's a game level, we need to load it
	; it's not a level, so just go to the screen
	call screen_load
	jp screen_loop

resume_bad_password:
	call wait_for_vblank_ly
	ld hl, (bg_tile_map_2 + (32*11) + 2)
	ld bc, resume_bad_password_str
	call strcpy

	ld b, 100
resume_bad_password_idle_loop:
	ld a, 0b00000001
	ldh [IE], a
	halt
	nop
	dec b
	jp nz, resume_bad_password_idle_loop

	call wait_for_vblank_ly
	ld hl, (bg_tile_map_2 + (32*11) + 2)
	ld bc, resume_bad_password_clr_str
	call strcpy

	ret

resume_draw_password:
	push bc
	push de

	ld hl, (bg_tile_map_2 + (32*3) + 8)
	ld bc, password_buffer
	ld d, 4
resume_draw_password_loop:
	ld a, [bc]
	cp 0
	jp z, resume_draw_password_loop_done
	ldi [hl], a
	inc bc
	dec d
	jp resume_draw_password_loop
resume_draw_password_loop_done:
	ld a, d
	cp 0
	jp z, resume_draw_password_done
	ld a, '_'
resume_draw_password_blank_loop:
	ldi [hl], a
	dec d
	jp nz, resume_draw_password_blank_loop
resume_draw_password_done:
	pop de
	pop bc
	ret

resume_title:
	asciz "   Enter password"

resume_keys_1:
	asciz "  A B C D E F G H I"

resume_keys_2:
	asciz "  J K L M N O P Q R"

resume_keys_3:
	asciz "  S T U V W X Y Z"

resume_done_str:
	asciz "Done"

resume_back_str:
	asciz "Back"

resume_bad_password_str:
	asciz "Invalid password"

resume_bad_password_clr_str:
	asciz "                "