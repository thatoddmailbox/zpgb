screen_load_jump_table:
	dw menu_load
	dw game_load

screen_loop_jump_table:
	dw menu_loop
	dw game_loop

screen_load:
	push bc
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

	pop bc
	jp [hl]
screen_load_done:
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