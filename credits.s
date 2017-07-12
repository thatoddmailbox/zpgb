credits_load:
	ld a, 0
	ld [SCX], a
	ld [SCY], a
	ld [credits_frame_counter], a

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

	call credits_copy

	; disable the zum sprites
	ld a, 0
	ld [sprite0_y], a
	ld [sprite1_y], a

	; re-enable the display (no window this time, and bg 1)
	ld a, 0b10000011
	ldh [LCDC], a

	ret

credits_copy:
	ld bc, credits_text
	ld hl, bg_tile_map_1
credits_copy_line:
	ld d, VRAM_WIDTH_TILES
credits_copy_line_loop:
	ld a, [bc]
	cp 0
	jp z, credits_copy_done
	ldi [hl], a
	inc bc
	dec d
	jp credits_copy_line_loop
credits_copy_done:
	inc bc
	ld a, 0
credits_copy_fill_loop:
	ldi [hl], a
	dec d
	jp nz, credits_copy_fill_loop
	ld a, [bc]
	cp 0
	jp nz, credits_copy_line
	ret

credits_loop:
	; wait for vblank
	ld a, 0b00000001
	ldh [IE], a
	halt
	nop

	ld a, [credits_frame_counter]
	inc a
	ld [credits_frame_counter], a
	cp 2
	jp nz, credits_loop

	ld a, 0
	ld [credits_frame_counter], a

	ld a, [SCY]
	inc a
	jp z, credits_done
	ld [SCY], a

	jp credits_loop

credits_done:
	ld a, 0
	ld [current_screen], a
	call screen_load
	jp screen_loop

credits_text:
	asciz " "
	asciz " "
	asciz " "
	asciz " "
	asciz " "
	asciz " "
	asciz " "
	asciz " "
	asciz " "
	asciz " "
	asciz " "
	asciz " "
	asciz " "
	asciz " "
	asciz " "
	asciz " "
	asciz " "
	asciz " "
	asciz "Zum Puzzler Pocket"
	asciz " "
	asciz "Created with gbasm"
	asciz "https://github.com/t"
	asciz "hatoddmailbox/gbasm"
	asciz " "
	asciz "A Dogo Games game"
	asciz " "
	asciz "Visit us online at g"
	asciz "ames.dogosoftware.tk"
	asciz " "
	asciz " "
	asciz " "
	asciz "Thanks for playing!"
	db 0x0