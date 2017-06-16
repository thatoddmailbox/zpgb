load_screen_jump_table:
	dw load_screen_menu
	dw load_screen_level
	dw load_screen_error

load_screen:
	ld hl, load_screen_jump_table
	ld b, 0
	ld a, [current_screen]
	add a, a ; double it because words are two bytes long
	ld c, a
	add hl, bc
	ldi a, [hl]
	ld e, a
	ldi a, [hl]
	ld d, a
	ld h, d
	ld l, e
	jp [hl]
load_screen_done:
	ret

load_screen_menu:
	jp load_screen_done

load_screen_level:
	; enable window for HUD
	ld a, (144-16)
	ldh [WY], a
	ld a, 7
	ldh [WX], a

	; page in the palettes
	ld a, 1
	ldh [VBK], a

	; set all of background 2 to palette 7
	ld a, 0b00000111
	ld hl, bg_tile_map_2
	ld bc, (bg_tile_map_2 - bg_tile_map_1)
	call clrmem

	; page back in the tiles
	ld a, 0
	ldh [VBK], a
	jp load_screen_done

load_screen_error:
	jp load_screen_done