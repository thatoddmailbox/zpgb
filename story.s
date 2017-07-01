; story_init: Initializes variables and memory related to the story cutscenes.
story_init:
	ret

; story_load: Called when the story is opened.
story_load:
	; move window to bottom of screen
	; enable window for HUD
	ld a, (144-16)
	ldh [WY], a
	ld a, 7
	ldh [WX], a

	; set background map 1 to all black
	; palette mode
	ld a, 1
	ldh [VBK], a

	; reset background palettes
	ld a, 0b00000110 ; BG 6
	ld hl, bg_tile_map_1
	ld bc, (bg_tile_map_2 - bg_tile_map_1) - 1
	call clrmem

	; tile mode
	ld a, 0
	ldh [VBK], a

	; clear the tiles
	ld a, 0
	ld hl, bg_tile_map_1
	ld bc, 2*(bg_tile_map_2 - bg_tile_map_1)
	call clrmem

	ld a, 0b11100011 ; enable window for dialogue
	ldh [LCDC], a

	ld hl, script_story_start
	call dialogue_start_script

	jp screen_load_done

; story_loop: Called every frame the story is open.
story_loop:
	; wait for vblank
	ld a, 0b00000001
	ldh [IE], a
	halt
	nop

	call dialogue_tick

	jp story_loop

; story_dialogue_complete: Called when the current script for the story mode is complete.
story_dialogue_complete:
	; load the actual game
	ld a, 0
	ld [prog_current_level], a
	jp prog_load_current_level
	ret