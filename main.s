; Zum Puzzler Gameboy
; yay

; outline:
; * Story: scene in waiting room, leaves
; * Game: first part, "intro"
;   5 levels
; * Game: intermediate part, still rotations and stuff
;   5-7 levels (add more if possible)
; * Game: warning that you're close to surface
;   1-2 levels like before
;   "dead end" that can be hacked
;   more dumb hacking puzzles
; * Story: end thing that has her go to ultimate hq of doom

.incasm "defs.s"

.org 0x0000
version_text:
	asciz "v1.0"

; interrupts and stuff
.incasm "vectors.s"

; fixed data
.org 0x4000
.incasm "charset.s"
.incasm "tileset.s"
.incasm "ngrams.s"
.incasm "levels.s"
.incasm "text.s"

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
	ld a, 0
	ld [frame_counter], a
	ld [last_p14], a
	ld [last_p15], a
	ld [current_screen], a

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

	call dialogue_init
	call hud_init
	call menu_init
	call selector_init
	call prog_init

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
	ld d, 255
	call memcpy
	ld d, 255
	call memcpy
	ld d, ((sharedset_end - sharedset) - (255*3))
	call memcpy

	ld hl, (bg_tile_data - (endset_end - endset))
	ld bc, endset
	ld d, (endset_end - endset)
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

	; BG 2
	ld [hl], 0b10110101 ; background gray
	ld [hl], 0b01010110
	ld [hl], 0b10000100 ; dark gray
	ld [hl], 0b00010000
	ld [hl], 0b00011111 ; off red
	ld [hl], 0b00000000
	ld [hl], 0b00100001 ; on green
	ld [hl], 0b10000010

	; BG 3
	ld [hl], 0b10110101 ; background gray
	ld [hl], 0b01010110
	ld [hl], 0b01001010 ; light gray
	ld [hl], 0b00101001
	ld [hl], 0b10000100 ; dark gray
	ld [hl], 0b00010000
	ld [hl], 0b01100000 ; screen blue
	ld [hl], 0b01011001

	; BG 4-6
	ld a, 3*8
reset_bg_palettes_loop:
	ld [hl], 0b00000000
	dec a
	jp nz, reset_bg_palettes_loop

	; BG 7
	ld [hl], 0b11111111 ; white
	ld [hl], 0b01111111
	ld [hl], 0b01001010 ; light gray
	ld [hl], 0b00101001
	ld [hl], 0b10000100 ; dark gray
	ld [hl], 0b00010000
	ld [hl], 0b00000000 ; black
	ld [hl], 0b00000000

	; Set sprite palette data
	ld hl, OCPS
	ld [hl], 0b10000000

	ld hl, OCPD

	; OBJ 0
	ld [hl], 0b00000000 ; transparent
	ld [hl], 0b00000000
	ld [hl], 0b00011111 ; orange
	ld [hl], 0b00000000 ;
	ld [hl], 0b11111111 ; yellow
	ld [hl], 0b00000011 ;
	ld [hl], 0b00000000 ; black
	ld [hl], 0b00000000 ;

	; OBJ 1
	ld [hl], 0b00000000 ; transparent
	ld [hl], 0b00000000
	ld [hl], 0b00000011 ; unselected selector color
	ld [hl], 0b00000000 ;
	ld [hl], 0b11111111 ; selected selector color
	ld [hl], 0b00000011 ;
	ld [hl], 0b00000000 ; black
	ld [hl], 0b00000000 ;

	; OBJ 2
	ld [hl], 0b00000000 ; transparent
	ld [hl], 0b00000000
	ld [hl], 0b11111111 ; white
	ld [hl], 0b01111111 ;
	ld [hl], 0b00000000 ; unused
	ld [hl], 0b00000000 ;
	ld [hl], 0b00000000 ; black
	ld [hl], 0b00000000 ;

	call screen_load

	ei
	jp screen_loop

.incasm "screens.s"
.incasm "level.s"
.incasm "player.s"
.incasm "selector.s"
.incasm "dialogue.s"
.incasm "hud.s"
.incasm "game.s"
.incasm "menu.s"
.incasm "prog.s"
.incasm "story.s"
.incasm "nonogram.s"
.incasm "credits.s"
.incasm "password.s"
.incasm "resume.s"

; wait_for_vblank: Waits for vblank.
wait_for_vblank:
	ldh a, [STAT]
	bit 0, a
	jp nz, wait_for_vblank
	ret

; wait_for_vblank_ly: Waits for vblank by polling LY.
wait_for_vblank_ly:
	ldh a, [LY]
	cp 145
	jp c, wait_for_vblank_ly
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

; vmemset: Clears the block of VRAM pointed to by BC with the value of A for D times.
vmemset:
	ld e, a
	ldh a, [LY]
	cp 145
	call c, wait_for_vblank_ly
	ld a, e
	ld [bc], a
	inc bc
	dec d
	jp nz, vmemset
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

; strlen: Calculates the length of the string pointed to by DE and saves it to A.
strlen:
	ld a, 0
strlen_loop:
	push af
	ld a, [de]
	inc de
	cp 0
	jp z, strlen_end
	pop af
	inc a
	jp strlen_loop
strlen_end:
	pop af
	ret

; disable_lcd: waits for vblank/scanline 145, then disables the lcd
disable_lcd:
	; if the screen is already off, then just return
	ldh a, [LCDC]
	cp 0
	ret z

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