; Zum Puzzler Gameboy
; yay

.incasm "defs.s"

; interrupts and stuff
.incasm "vectors.s"

; fixed data
.org 0x4000
.incasm "charset.s"
.incasm "tileset.s"
.incasm "levels.s"

dma_activate:
	ld a, oam_data_bank
	ld [DMA], a
	; wait for the dma to finish
	ld a, 0x28
dma_activate_loop:
	dec a
	jp nz, 0xFF87
	ret
	db 0x00

.org 0x150
main:
	; initialization stuff
	di
	ld sp, 0xFFFE

	call disable_lcd

	; Set up variables and stuff
	ld [frame_counter], a
	ld a, 8
	ld [player_x], a
	ld [player_y], a

	; Copy the DMA wait code into the CPU internal RAM
	ld hl, dma_code_highram
	ld bc, dma_activate
	call strcpy

	; Clear the background
	ld a, 0
	ld hl, bg_tile_map_1
	ld bc, 2*(bg_tile_map_2 - bg_tile_map_1)
	call clrmem

	; Clear the OAM
	ld hl, sprite_ram_start
	ld bc, sprite_ram_len
	call clrmem

	; Clear our OAM copy
	ld hl, oam_data
	ld bc, sprite_ram_len
	call clrmem

	; enable window
	ld a, (144-16)
	ldh [WY], a
	ld a, 7
	ldh [WX], a

	; Load level 
	ld bc, level1
	call load_level

	; Set the background tile data
	ld hl, bg_tile_data + 16
	ld c, 4
	ld de, charset + 8
	copy_loop_outer:
		ld b, 8*31
		copy_loop:
			ld a, [DE]
			inc de
			ld [hl], a
			inc hl
			ld [hl], a
			inc hl
			dec b
			jp nz, copy_loop
		dec c
		jp nz, copy_loop_outer

	; Set the shared tile data
	ld hl, shared_tile_data
	ld bc, sharedset
	ld a, (sharedset_end - sharedset)
	call memcpy

	; Set the sprite tile data
	ld hl, sprite_tile_data
	ld bc, spriteset
	ld a, (spriteset_end - spriteset)
	call memcpy

	; Set bg palette data
	ld hl, BCPS
	ld [hl], 0b10000000

	ld hl, BCPD

	; BG 0
	ld [hl], 0b10110101 ; background gray
	ld [hl], 0b01010110
	ld [hl], 0b01001010 ; light gray
	ld [hl], 0b00101001
	ld [hl], 0b10000100 ; dark gray
	ld [hl], 0b00010000
	ld [hl], 0b00000000 ; black
	ld [hl], 0b00000000

	; BG 1
	ld [hl], 0b10110101 ; background gray
	ld [hl], 0b01010110
	ld [hl], 0b00001010 ; brown
	ld [hl], 0b00000000
	ld [hl], 0b11111111 ; yellow
	ld [hl], 0b00000011
	ld [hl], 0b00000000 ; black
	ld [hl], 0b00000000

	; BG 2-7
	ld a, 6*8
reset_bg_palettes_loop:
	ld [hl], 0b00000000
	dec a
	jp nz, reset_bg_palettes_loop

	; Set sprite palette data
	ld hl, OCPS
	ld [hl], 0b10000000

	ld hl, OCPD

	; OBJ 1
	ld [hl], 0b00000000 ; transparent
	ld [hl], 0b00000000
	ld [hl], 0b00011111 ; orange
	ld [hl], 0b00000000 ;
	ld [hl], 0b11111111 ; yellow
	ld [hl], 0b00000011 ;
	ld [hl], 0b00000000 ; black
	ld [hl], 0b00000000 ;

	; Set LCDC (bit 7: operation on, bit 0: bg and win on)
	ld hl, LCDC
	ld [hl], 0b11100011

	call calc_viewport_scroll

	ei

loop:
	; wait for vblank
	ld a, 0b00000001
	ldh [IE], a
	halt
	nop

	; pull p14 low
	ld hl, P1
	ld [hl], 0b00100000
	; read key input...twice
	ld a, [hl]
	ld a, [hl]
	; reset the port
	ld [hl], 0b00110000
	
	bit 0, a
	call z, move_right
	bit 1, a
	call z, move_left
	bit 2, a
	call z, move_up
	bit 3, a
	call z, move_down

	ld hl, num_buf
	ld a, [player_x]
	call print_num
	ld a, '-'
	ldi [hl], a
	ld a, [player_y]
	call print_num
	ld a, '-'
	ldi [hl], a
	ld a, [SCY]
	call print_num

	ld a, 0
	ldi [hl], a

	ld bc, num_buf
	ld hl, bg_tile_map_2
	call strcpy

	jp loop

calc_viewport_scroll:
	; the screen is 160x144
	; player is 8x8
	; center player is at (76, 68)

	; if x < 76, SCX = 0, sprite x = x
	; if x > (VRAM_WIDTH_PX - 76), SCX = (VRAM_WIDTH_PX - SCREEN_WIDTH_PX), sprite x = x - SCX
	; else, SCX = x - 76, sprite x = 76
	call wait_for_vblank
	ld a, [player_x]

	; are we on the far left?
	cp 72
	jp c, calc_viewport_scroll_x_left_edge
	; are we on the far right?
	cp (VRAM_WIDTH_PX - (72 + 16))
	jp nc, calc_viewport_scroll_x_right_edge
	; we are in the center
	sub 72
	ldh [SCX], a
	ld a, 72
	add a, 0x8
	ld [sprite0_x], a
	jp calc_viewport_scroll_check_y
calc_viewport_scroll_x_left_edge:
	add a, 0x8
	ld [sprite0_x], a
	ld a, 0
	ldh [SCX], a
	jp calc_viewport_scroll_check_y
calc_viewport_scroll_x_right_edge:
	sub 95
	add a, 0x8
	ld [sprite0_x], a
	ld a, (VRAM_WIDTH_PX - SCREEN_WIDTH_PX)
	ldh [SCX], a

calc_viewport_scroll_check_y:
	; if y < 68, SCY = 0, sprite y = y
	; if y > (VRAM_HEIGHT_PX - 68), SCY = (VRAM_HEIGHT_PX - SCREEN_HEIGHT_PX + HUD_HEIGHT_PX), sprite y = y - SCY
	; else, SCY = x - 68, sprite y = 68
	call wait_for_vblank
	ld a, [player_y]

	; are we at the top?
	cp 68
	jp c, calc_viewport_scroll_y_top_edge
	; are we at the bottom?
	cp (VRAM_HEIGHT_PX - 60)
	jp nc, calc_viewport_scroll_y_bottom_edge
	; we are in the center
	sub 68
	ldh [SCY], a
	ld a, 68
	add a, 0x10
	ld [sprite0_y], a
	jp calc_viewport_scroll_done
calc_viewport_scroll_y_top_edge:
	add a, 0x10
	ld [sprite0_y], a
	ld a, 0
	ldh [SCY], a
	jp calc_viewport_scroll_done
calc_viewport_scroll_y_bottom_edge:
	add a, 0x10
	sub ((VRAM_HEIGHT_PX - SCREEN_HEIGHT_PX) + HUD_HEIGHT_PX)
	ld [sprite0_y], a
	ld a, ((VRAM_HEIGHT_PX - SCREEN_HEIGHT_PX) + HUD_HEIGHT_PX)
	ldh [SCY], a

calc_viewport_scroll_done:
	; position the right side
	ld a, [sprite0_x]
	add a, 8
	ld [sprite1_x], a
	ld a, [sprite0_y]
	ld [sprite1_y], a
	ld a, 1
	ld [sprite1_t], a
	ret

; check_tile_is_solid: Set Z if the tile at (d, e) is solid, else clear Z.
check_tile_is_solid:
	ld hl, level1
	ld bc, 32
	ld a, e
	cp 0
	jp z, check_tile_is_solid_skip_loop
check_tile_is_solid_y_inc:
	add hl, bc
	dec e
	jp nz, check_tile_is_solid_y_inc

check_tile_is_solid_skip_loop:
	ld c, d
	add hl, bc
	ld a, [hl]
	cp 0x80
	ret

; check_for_collision: Checks if the player will collide with anything at position (c, b)
check_for_collision:
	; find what tile we're on
	; (player_x / 8, player_y / 8)

	ld a, c ; load the x
	srl a
	srl a
	srl a
	ld d, a

	ld a, b ; load the y
	srl a
	srl a
	srl a
	ld e, a

	; check top-left corner of player
	push bc
	push de
	call check_tile_is_solid
	pop de
	pop bc
	ret z

	; check middle-right corner of player
	ld a, c
	add a, 7
	srl a
	srl a
	srl a
	ld d, a
	push bc
	push de
	call check_tile_is_solid
	pop de
	pop bc
	ret z

	; check top-right corner of player
	ld a, c
	add a, 8+7
	srl a
	srl a
	srl a
	ld d, a
	push bc
	push de
	call check_tile_is_solid
	pop de
	pop bc
	ret z

	; move to bottom
	ld a, b
	add a, 7
	srl a
	srl a
	srl a
	ld e, a

	; check bottom-right corner of player
	; THE D REGISTER IS SAVED FROM THE LAST CALCULATION
	push bc
	push de
	call check_tile_is_solid
	pop de
	pop bc
	ret z

	; check bottom-middle corner of player
	ld a, c
	add a, 7
	srl a
	srl a
	srl a
	ld d, a
	push bc
	push de
	call check_tile_is_solid
	pop de
	pop bc
	ret z

	; check bottom-left corner of player
	ld a, c
	srl a
	srl a
	srl a
	ld d, a
	push bc
	push de
	call check_tile_is_solid
	pop de
	pop bc
	ret z

	ret


move_up:
	push af
	ld a, [player_y]
	dec a
	ld b, a
	ld a, [player_x]
	ld c, a
	call check_for_collision
	jp z, move_done
	ld hl, player_y
	dec [hl]
	jp move_done
move_down:
	push af
	ld a, [player_y]
	inc a
	ld b, a
	ld a, [player_x]
	ld c, a
	call check_for_collision
	jp z, move_done
	ld hl, player_y
	inc [hl]
	jp move_done
move_left:
	push af
	ld a, [player_y]
	ld b, a
	ld a, [player_x]
	dec a
	ld c, a
	call check_for_collision
	jp z, move_done
	ld hl, player_x
	dec [hl]
	jp move_done
move_right:
	push af
	ld a, [player_y]
	ld b, a
	ld a, [player_x]
	inc a
	ld c, a
	call check_for_collision
	jp z, move_done
	ld hl, player_x
	inc [hl]
move_done:
	call calc_viewport_scroll
	pop af
	ret

wait_for_vblank:
	ldh a, [STAT]
	bit 1, a
	jp nz, wait_for_vblank
	ret

; load_level: Loads the level pointed to by BC to tile map 1.
load_level:
	; switch the ram to bank 1 (with the level buffer)
	ld a, 1
	ldh [SVBK], a

	ld hl, temp_level_buffer

	; copy the data to the temp level buffer
	ld e, 8
load_level_to_temp_loop:
	ld d, 128
	call memcpy
	dec e
	jp nz, load_level_to_temp_loop

	; set the tile bank to color palette mode
	ld a, 1
	ldh [VBK], a

	; loop over every tile, set the appropriate color palette
	ld hl, temp_level_buffer
	ld bc, bg_tile_map_1
	ld e, 8
load_level_palette_loop:
	ld d, 128
load_level_palette_inner_loop:
	ldi a, [hl]
	cp 0x81
	jp z, load_level_palette_1
	jp load_level_palette_0
	load_level_palette_0:
	ld a, 0
	jp load_level_palette_inner_loop_done
	load_level_palette_1:
	ld a, 1
	load_level_palette_inner_loop_done:
	ld [bc], a
	inc bc

	dec d
	jp nz, load_level_palette_inner_loop
	dec e
	jp nz, load_level_palette_loop

	; set the tile bank to tile mode
	ld a, 0
	ldh [VBK], a	

	; copy the level from the temp buffer to tile map 1
	ld hl, bg_tile_map_1
	ld bc, temp_level_buffer
	ld e, 8
load_level_temp_to_map_loop:
	ld d, 128
	call memcpy
	dec e
	jp nz, load_level_temp_to_map_loop

	ret

; print_num: Prints the number in A as a string to HL.
print_num:
	ld b, 100
	call print_num_digit
	ld b, 10
	call print_num_digit
	ld b, 1
print_num_digit:
	ld [hl], '0'
print_num_digit_loop:
	sub b
	inc [hl]
	jp nc, print_num_digit_loop
	add a, b
	dec [hl]
	inc hl
	ret

; clrmem: Clears the block of memory pointed to by HL with the value of A for BC times.
clrmem:
	inc b
	inc c
	clrmem_loop:
		ldi [hl], a
		dec c
		jp nz, clrmem_loop
		dec b
		jp nz, clrmem_loop
	ret

; memcpy: Copies D bytes from BC to HL.
memcpy:
	ld a, [bc]
	inc bc
	ldi [hl], a
	dec d
	jp nz, memcpy
	ret

; strcpy: Copies the null-terminated string pointed to in BC to HL.
strcpy:
	strcpy_loop:
		ld a, [bc]
		cp 0
		jp z, strcpy_end
		ldi [hl], a
		inc bc
		jp strcpy_loop
	strcpy_end:
		ret

; disable_lcd: waits for vblank/scanline 145, then disables the lcd
disable_lcd:
	; wait for LY to be >= 145 (vblank)
	; for some reason, bgb doesn't like wait_for_vblank for this,
	; and claims we're trying to disable the lcd outside of vblank
	ldh a, [LY]
	cp 145
	jp c, disable_lcd
	; Set LCDC off
	ld a, 0
	ldh [LCDC], a
	ret