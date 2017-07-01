; dialogue_init: Initializes variables and memory related to the dialogue engine.
dialogue_init:
	ld a, 0
	ld [dialogue_active], a
	ld [dialogue_script_pointer_l], a
	ld [dialogue_script_pointer_h], a
	ld [dialogue_frame_counter], a
	ret

; dialogue_start_script: Starts displaying the script pointed to by HL.
dialogue_start_script:
	call wait_for_vblank

	; draw the dialogue box
	ld bc, bg_tile_map_2
	ld a, 0x09
	ld d, SCREEN_WIDTH_TILES
	call vmemset
	call dialogue_clear_text

	; pan the hud up
dialogue_start_script_wy_loop:
	ldh a, [WY]
	cp (SCREEN_HEIGHT_PX - DIALOGUE_HEIGHT_PX)
	jp z, dialogue_start_script_wy_loop_end
	dec a
	ldh [WY], a
	ld a, 0b00000001
	ldh [IE], a
	halt
	nop
	jp dialogue_start_script_wy_loop
dialogue_start_script_wy_loop_end:

	; write the current line
	call dialogue_write_into_box
	ld a, l
	ld [dialogue_script_pointer_l], a
	ld a, h
	ld [dialogue_script_pointer_h], a

	ld a, 1
	ld [dialogue_active], a

	ret

; dialogue_write_into_box: Writes the line pointed to by HL into the dialogue box.
dialogue_write_into_box:
	; clear the previous character
	ld bc, bg_tile_map_2
	ld a, 0x09
	ld d, SCREEN_WIDTH_TILES
	call vmemset

	; get a pointer to the character in the character table
	ldi a, [hl]
	dec a
	sla a
	sla a
	sla a
	push hl
	ld hl, dialogue_character_table
	ld b, 0
	ld c, a
	add hl, bc
	; hl now contains a memory address to the character's name
	ld b, h
	ld c, l
	ld hl, (bg_tile_map_2 + 1)
	call wait_for_vblank_ly
	call strcpy
	pop hl

	ld bc, (bg_tile_map_2 + 32 + 1)
	ld d, (SCREEN_WIDTH_TILES - 2) ; tiles left on first line
	ld e, 2*(SCREEN_WIDTH_TILES - 2) ; tiles left to end
dialogue_write_into_box_loop:
	call wait_for_vblank_ly
	ldi a, [hl]
	cp 0
	jp z, dialogue_write_into_box_loop_fill
	ld [bc], a
	inc bc
	dec e
	dec d
	jp z, dialogue_write_into_box_loop_next_line
	jp dialogue_write_into_box_loop
dialogue_write_into_box_loop_next_line:
	ld a, c
	add a, ((32 - SCREEN_WIDTH_TILES) + 2)
	ld c, a
	jp dialogue_write_into_box_loop
dialogue_write_into_box_loop_fill:
	ld a, e
	cp 0
	jp z, dialogue_write_into_box_loop_end
	ld a, 0
dialogue_write_into_box_loop_fill_loop:
	ld [bc], a
	inc bc
	dec e
	jp nz, dialogue_write_into_box_loop_fill_loop
dialogue_write_into_box_loop_end:
	ret

; dialogue_clear_text: Clears the current text in the dialogue box.
dialogue_clear_text:
	ld bc, (bg_tile_map_2 + 32 + 1)
	ld a, 0x00
	ld d, 18
	call vmemset

	ld bc, (bg_tile_map_2 + 32 + 32 + 1)
	ld a, 0x00
	ld d, 18
	call vmemset
	ret

; dialogue_advance: Advances the current script to the next line.
dialogue_advance:
	call dialogue_clear_text
	ld a, [dialogue_script_pointer_l]
	ld l, a
	ld a, [dialogue_script_pointer_h]
	ld h, a
	ld a, [hl]
	cp 0
	jp z, dialogue_complete ; if it's a null byte already, it's an empty string and a signal that this script is over
	call dialogue_write_into_box
	ld a, l
	ld [dialogue_script_pointer_l], a
	ld a, h
	ld [dialogue_script_pointer_h], a
	ret

; dialogue_complete: Disables the dialogue engine.
dialogue_complete:
	call dialogue_clear_text

	; lower the window
dialogue_complete_wy_loop:
	ldh a, [WY]
	cp (SCREEN_HEIGHT_PX - HUD_HEIGHT_PX)
	jp z, dialogue_complete_wy_loop_end
	inc a
	ldh [WY], a
	ld a, 0b00000001
	ldh [IE], a
	halt
	nop
	jp dialogue_complete_wy_loop
dialogue_complete_wy_loop_end:

	ld a, 0
	ld [dialogue_active], a

	; check what's currently open
	ld a, [current_screen]
	cp SCREEN_STORY
	jp z, story_dialogue_complete
	; it's not the story, so just draw the hud and be happy
	call hud_draw
	ret

; dialogue_tick: Handles input and things like that, only called when dialogue_active is 1.
dialogue_tick:
	; read buttons
	ld hl, P1
	ld a, [last_p15]

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

	bit 0, b ; is the a button up now?
	jp nz, dialogue_tick_skip_a
	bit 0, a ; was it up before?
	push bc
	call nz, dialogue_advance
	pop bc
dialogue_tick_skip_a:

	ld a, b
	ld [last_p15], a

	; blink the a button
	ld a, [dialogue_frame_counter]
	inc a
	ld [dialogue_frame_counter], a

	bit 5, a
	jp z, dialogue_tick_skip_anim
	ld a, 0
	ld [dialogue_frame_counter], a

	ld hl, (bg_tile_map_2 + 32 + 32 + 32 + SCREEN_WIDTH_TILES - 1)
	ld a, [hl]
	cpl
	ld [hl], a
dialogue_tick_skip_anim:
	ret

dialogue_character_table:
	ascii "???"
	db 0x00, 0x00, 0x00, 0x00, 0x00
	ascii "Sign"
	db 0x00, 0x00, 0x00, 0x00
	ascii "Zala"
	db 0x00, 0x00, 0x00, 0x00
	ascii "Ducky"
	db 0x00, 0x00, 0x00