screen_load_jump_table:
	dw menu_load
	dw game_load

screen_loop_jump_table:
	dw menu_loop
	dw game_loop

screen_load:
	call disable_lcd

	ld hl, screen_load_jump_table
	ld a, [current_screen]
	add a, a
	ld b, 0
	ld c, a
	add hl, bc
	ldi a, [hl]
	ld e, a
	ldi a, [hl]
	ld d, a
	ld h, d
	ld l, e
	jp [hl]
screen_load_done:
	; enable screen with bg and window
	ld hl, LCDC
	ld [hl], 0b11100011
	ret

screen_loop:
	ld hl, screen_loop_jump_table
	ld a, [current_screen]
	add a, a
	ld b, 0
	ld c, a
	add hl, bc
	ldi a, [hl]
	ld e, a
	ldi a, [hl]
	ld d, a
	ld h, d
	ld l, e
	jp [hl]