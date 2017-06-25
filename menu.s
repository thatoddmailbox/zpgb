menu_load:
	; disable window
	ld a, 0
	ldh [WX], a
	ldh [WY], a

	; palette mode
	ld a, 1
	ldh [VBK], a

	; reset background 1 palettes
	; (don't care about bg 2)
	ld a, 0b00000111
	ld hl, bg_tile_map_1
	ld bc, (bg_tile_map_2 - bg_tile_map_1)
	call clrmem

	ld a, 0
	ldh [VBK], a

	jp screen_load_done

menu_loop:
