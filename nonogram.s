.def nonogram_grid_x 6
.def nonogram_grid_y 6
.def nonogram_grid_top_left (bg_tile_map_2+nonogram_grid_x+(nonogram_grid_y*32))

; nonogram_start_puzzle: Starts the nonogram pointed to by HL.
nonogram_start_puzzle:
	; load state information
	ld a, 1
	ld [nonogram_active], a
	ld a, 0
	ld [nonogram_cursor_x], a
	ld [nonogram_cursor_y], a

	push hl

	; clear the current puzzle and the instruction state
	ld a, 0
	ld bc, 16
	ld hl, nonogram_instruction_buffer
	call clrmem

	; disable the display temporarily
	call disable_lcd

	; clear vram
	ld a, 0
	ld hl, bg_tile_map_2
	ld bc, (bg_tile_map_2 - bg_tile_map_1) - 1
	call clrmem

	pop hl

	; load the dimensions
	ldi a, [hl]
	ld [nonogram_width], a
	ld b, a
	ldi a, [hl]
	ld [nonogram_height], a
	ld c, a

	; save the current pointer
	ld a, l
	ld [nonogram_pointer_l], a
	ld a, h
	ld [nonogram_pointer_h], a

	; draw the instructions
	push bc
	ld a, [nonogram_pointer_l]
	ld l, a
	ld a, [nonogram_pointer_h]
	ld h, a
	call nonogram_draw_instructions
	pop bc

	; draw the grid to vram
	ld hl, nonogram_grid_top_left
	ld d, 0
	ld a, VRAM_WIDTH_TILES
	sub b
	ld e, a ; e = (VRAM_WIDTH_TILES - width)
nonogram_start_puzzle_grid:
	; get the width of one row
	ld a, [nonogram_width]
	ld b, a
	ld a, 0x0d ; empty tile
nonogram_start_puzzle_grid_row:
	ldi [hl], a
	dec b
	jp nz, nonogram_start_puzzle_grid_row
	add hl, de
	dec c
	jp nz, nonogram_start_puzzle_grid

	; disable the zum sprites, and activate the cursor sprite
	ld a, 0
	ld [sprite0_y], a
	ld [sprite1_y], a
	ld a, 4
	ld [sprite2_t], a

	call nonogram_update_cursor

	; re-enable the display (no window this time, and bg 2)
	ld a, 0b10001011
	ldh [LCDC], a

	ret

; nonogram_generate_instructions: Generate numbers for the solution row in A.
nonogram_generate_instructions:
	push bc

	ld hl, nonogram_instruction_buffer
	ld b, 0b10000000 ; the bitmask for the current bit of a
	ld c, 8 ; the bits of a left
	ld d, 0 ; the current group length of a

nonogram_generate_instructions_bit:
	; test the current bit
	push af
	and b
	jp z, nonogram_generate_instructions_bit_unset

	; the current bit is set
	inc d
	jp nonogram_generate_instructions_bit_done
nonogram_generate_instructions_bit_unset:
	; the current bit is unset
	; output the current group length if it's not 0
	ld a, d
	cp 0
	jp z, nonogram_generate_instructions_bit_done
	add a, '0'
	ldi [hl], a
	ld d, 0
nonogram_generate_instructions_bit_done:
	; move to the next bit
	pop af
	srl b
	dec c
	jp nz, nonogram_generate_instructions_bit

	push af
	; if there is a leftover group, add that
	ld a, d
	cp 0
	jp z, nonogram_generate_instructions_no_leftover_group
	add a, '0'
	ldi [hl], a
nonogram_generate_instructions_no_leftover_group:
	; terminate with a null byte
	ld a, 0
	ldi [hl], a

	pop af

	pop bc
	ret

; nonogram_draw_instructions: Draws the instructions for the nonogram pointed to by HL to the screen.
nonogram_draw_instructions:
	push hl

	; draw the rows first
	ld bc, nonogram_grid_top_left
	ld a, [nonogram_height]
nonogram_draw_instructions_row:
	push af

	push bc
	; bc = the tile to end instructions on
	; hl = current row
	ldi a, [hl]
	push hl
	call nonogram_generate_instructions
	pop hl

	; get the length of the instructions
	ld de, nonogram_instruction_buffer
	call strlen

	; double a and subtract 1 to include spaces
	sla a
	dec a

	; move bc to the place to start copying the instructions
	ld d, a
	ld a, c
	sub d
	ld c, a

	; copy them from de -> bc
	ld de, nonogram_instruction_buffer
nonogram_draw_instructions_row_copy:
	ld a, [de]
	cp 0
	jp z, nonogram_draw_instructions_row_copy_done
	inc de
	ld [bc], a
	inc bc
	ld a, ' '
	ld [bc], a
	inc bc
	jp nonogram_draw_instructions_row_copy
nonogram_draw_instructions_row_copy_done:
	pop bc

	; add +32 to bc
	push hl
	ld de, VRAM_WIDTH_TILES
	ld h, b
	ld l, c
	add hl, de
	ld b, h
	ld c, l
	pop hl

	; check if we have a row left
	pop af
	dec a
	jp nz, nonogram_draw_instructions_row

	pop hl ; restore the nonogram pointer so we can do the columns now

	; loop over the columns
	ld d, 0b10000000 ; bitmask
	ld a, [nonogram_width]
	ld bc, nonogram_grid_top_left
nonogram_draw_instructions_column:
	push af
	push de

	push bc

	; rearrange the column into a byte
	call nonogram_transform_col_to_byte
	ld a, c

	push hl
	call nonogram_generate_instructions
	pop hl

	pop bc

	ld de, nonogram_instruction_buffer
	call strlen

	; double a and subtract 1 to include spaces
	sla a
	dec a

	push hl

	; subtract 32 from BC for A times
	ld h, b
	ld l, c
	ld de, 0xFFE0 ; -32
nonogram_draw_instructions_column_sub_loop:
	add hl, de
	dec a
	jp nz, nonogram_draw_instructions_column_sub_loop
	ld b, h
	ld c, l

	; bc now is the tile to start printing instructions
	ld de, nonogram_instruction_buffer
nonogram_draw_instructions_column_copy:
	ld a, [de]
	inc de
	cp 0
	jp z, nonogram_draw_instructions_column_copy_done
	ld [bc], a
	ld hl, 64
	add hl, bc
	ld b, h
	ld c, l
	jp nonogram_draw_instructions_column_copy
nonogram_draw_instructions_column_copy_done:
	; subtract 32 from BC so that the offset is ok
	ld hl, 0xFFE0 ; -32
	add hl, bc
	ld b, h
	ld c, l

	pop hl

	pop de
	pop af

	srl d
	inc bc
	dec a
	jp nz, nonogram_draw_instructions_column

	ret

; nonogram_transform_col_to_byte: Gets the values for the column with bitmask D in nonogram HL. Outputs in register C.
nonogram_transform_col_to_byte:
	push hl

	ld c, 0b00000000 ; output
	ld e, 8 ; bytes left
nonogram_transform_col_to_byte_loop:
	sla c
	ldi a, [hl]
	and d
	cp 0
	jp z, nonogram_transform_col_to_byte_loop_done
	set 0, c
nonogram_transform_col_to_byte_loop_done:
	dec e
	jp nz, nonogram_transform_col_to_byte_loop

	pop hl
	ret

; nonogram_restore_game: Jumps back to the game after the nonogram is done.
nonogram_restore_game:
	ld a, 0

	ld [sprite2_y], a; disable the cursor sprite
	ld [nonogram_active], a ; disable the nonogram

	; re-enable the window
	ld a, 0b11100011 ; enable window
	ldh [LCDC], a

	; return to the game loop
	ret

; nonogram_update_cursor: Moves the cursor sprite to the cursor position.
nonogram_update_cursor:
	ld a, [nonogram_cursor_x]
	sla a
	sla a
	sla a
	add a, ((nonogram_grid_x*8)+0x08) ; base x
	ld [sprite2_x], a

	ld a, [nonogram_cursor_y]
	sla a
	sla a
	sla a
	add a, ((nonogram_grid_y*8)+0x10) ; base y
	ld [sprite2_y], a

	; fallthrough to nonogram_set_cursor_color

; nonogram_set_cursor_color: Sets the tile number of the cursor to the appropriate color for the tile underneath it.
nonogram_set_cursor_color:
	
	ret

; nonogram_wrap_value: Wraps the value in register A to be between 0 and D-1, inclusive
nonogram_wrap_value:
	cp 0xFF
	jp z, nonogram_wrap_value_high
	cp d
	ret c ; if carry, then a < d, so we are in range and return
	ld a, 0
	ret
nonogram_wrap_value_high:
	ld a, d
	dec a
	ret

; nonogram_move_cursor: Moves the cursor B in the X dimension and C in the Y dimension  
nonogram_move_cursor:
	ld a, [nonogram_width]
	ld d, a
	ld a, [nonogram_cursor_x]
	add a, b
	call nonogram_wrap_value
	ld [nonogram_cursor_x], a

	ld a, [nonogram_height]
	ld d, a
	ld a, [nonogram_cursor_y]
	add a, c
	call nonogram_wrap_value
	ld [nonogram_cursor_y], a

	call nonogram_update_cursor

	pop bc
	pop af
	ret

nonogram_move_up:
	push af
	push bc
	ld b, 0
	ld c, 0xFF ; -1
	jp nonogram_move_cursor

nonogram_move_down:
	push af
	push bc
	ld b, 0
	ld c, 1
	jp nonogram_move_cursor

nonogram_move_left:
	push af
	push bc
	ld b, 0xFF ; -1
	ld c, 0
	jp nonogram_move_cursor

nonogram_move_right:
	push af
	push bc
	ld b, 1
	ld c, 0
	jp nonogram_move_cursor

nonogram_a_button:
	push bc
	push de

	; get the current tile
	ld a, [nonogram_cursor_x]
	ld b, a
	ld a, [nonogram_cursor_y]
	ld d, 0
	ld e, a

	ld hl, nonogram_state
	add hl, de ; hl now points to the byte with the column with the current tile

	inc b
	ld c, 0b00000001
nonogram_a_button_bitmask_loop:
	rrc c
	dec b
	jp nz, nonogram_a_button_bitmask_loop

	; c now is the bitmask needed to access the current tile
	ld a, [hl]
	and c
	cp 0
	jp z, nonogram_a_button_current_off
	ld b, 0x0d
	jp nonogram_a_button_current_done
nonogram_a_button_current_off:
	ld b, 0x0e
nonogram_a_button_current_done:
	ld a, c
	xor [hl]

	; b is the new state for the tile in VRAM
	; a is now the new row
	ld [hl], a

	; now set the current tile
	ld hl, (nonogram_grid_top_left)
	ld a, [nonogram_cursor_y]
	sla a
	sla a
	sla a
	sla a
	sla a
	ld d, 0
	ld e, a ; de = nonogram_cursor_y * 32
	add hl, de
	ld a, [nonogram_cursor_x]
	ld e, a
	add hl, de ; de = nonogram_cursor_x

	; hl is now the tile that needs changing
	ld a, b
	ld [hl], a

	pop de
	pop bc
	ret

; nonogram_tick: Called every frame the nonogram is open.
nonogram_tick:
	; DON'T wait for vblank - that is handled by game_loop

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

	push de

	; check d-pad state
	bit 0, a
	jp nz, nonogram_tick_input_skip_right
	bit 0, c
	call nz, nonogram_move_right
nonogram_tick_input_skip_right:
	bit 1, a
	jp nz, nonogram_tick_input_skip_left
	bit 1, c
	call nz, nonogram_move_left
nonogram_tick_input_skip_left:
	bit 2, a
	jp nz, nonogram_tick_input_skip_up
	bit 2, c
	call nz, nonogram_move_up
nonogram_tick_input_skip_up:
	bit 3, a
	jp nz, nonogram_tick_input_skip_down
	bit 3, c
	call nz, nonogram_move_down
nonogram_tick_input_skip_down:

	; check the other button
	pop de

	bit 0, b
	jp nz, nonogram_tick_input_skip_a
	bit 0, d
	call nz, nonogram_a_button
nonogram_tick_input_skip_a:

	; save last state
	ld [last_p14], a
	ld a, b
	ld [last_p15], a

	jp game_loop