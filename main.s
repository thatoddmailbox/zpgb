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
	ld a, 1
	ld [current_screen], a
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
	ld d, 255
	call memcpy
	ld d, ((sharedset_end - sharedset) - 255)
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
	ld [hl], 0b00011111 ; laser red
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

	; BG 2-6
	ld a, 5*8
reset_bg_palettes_loop:
	ld [hl], 0b00000000
	dec a
	jp nz, reset_bg_palettes_loop

	; BG 7
	ld [hl], 0b11111111 ; white
	ld [hl], 0b01111111
	ld [hl], 0b00000000 ; black
	ld [hl], 0b00000000
	ld [hl], 0b00000000 ; black
	ld [hl], 0b00000000
	ld [hl], 0b00000000 ; black
	ld [hl], 0b00000000

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

	call load_screen

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
	; read d-pad input...twice because of hw bug
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

.incasm "screens.s"
.incasm "level.s"

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

; wait_for_vblank: Waits for vblank.
wait_for_vblank:
	ldh a, [STAT]
	bit 1, a
	jp nz, wait_for_vblank
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