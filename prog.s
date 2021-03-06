.def LEVEL_COUNT 17

prog_level_table:
	; INTRO PART
	dw intro_level1
	dw intro_level2
	dw intro_level3
	dw intro_level4

	; MIDDLE PART
	dw middle_level1
	dw middle_level2
	dw middle_level3
	dw middle_level4
	dw middle_level5
	dw middle_level6
	dw middle_level7

	; SURFACE PART
	dw surface_level1
	dw surface_level2
	dw surface_level3
	dw surface_level4
	dw surface_level5

	dw end_level1

; prog_init: Initializes variables and memory related to the level progression handler.
prog_init:
	ld a, 0
	ld [prog_current_level], a
	ret

; prog_advance_level: Advances to the next level and loads it.
prog_advance_level:
	ld a, [prog_current_level]
	inc a

	; a now equals the level that is about to be loaded
	; handle special level events here
	cp LEVEL_COUNT
	jp z, prog_done

	ld [prog_current_level], a
	; fallthrough to prog_load_current_level
prog_load_current_level:
	; get the address of the level
	ld a, [prog_current_level]
	add a, a
	ld hl, prog_level_table
	ld b, 0
	ld c, a
	add hl, bc
	ldi a, [hl]
	ld c, a
	ld a, [hl]
	ld b, a

	ld a, 1
	ld [current_screen], a

	; bc now contains the address of the compressed level
	call screen_load
	jp screen_loop

; prog_done: Run when all levels have been completed.
prog_done:
	ld a, 3
	ld [current_screen], a
	call screen_load
	jp screen_loop