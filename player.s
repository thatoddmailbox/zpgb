; player_trigger: Tries triggering all tiles around the player
player_trigger:
	push af

	; load in the bank with the level buffer
	ld a, 1
	ldh [SVBK], a

	; get the left tile position
	ld a, [player_x]
	srl a
	srl a
	srl a
	ld d, a
	ld a, [player_y]
	srl a
	srl a
	srl a
	ld e, a

	; convert that position into an address in WRAM
	ld hl, temp_level_buffer

	; hl = hl + (y * 32)
	ld bc, 32
	cp 0
	jp z, player_trigger_y_loop_done
player_trigger_y_loop:
	add hl, bc
	dec e
	jp nz, player_trigger_y_loop
player_trigger_y_loop_done:
	; hl = hl + x
	ld b, 0
	ld c, d
	add hl, bc

	pop af

	; top-left
	ld bc, 0xFFDF ; -33
	add hl, bc
	call player_trigger_select_action

	; above-left
	inc hl
	call player_trigger_select_action

	; above-right
	inc hl
	call player_trigger_select_action

	; top-right
	inc hl
	call player_trigger_select_action

	; middle-right
	ld bc, 32
	add hl, bc
	call player_trigger_select_action

	; bottom-right
	add hl, bc
	call player_trigger_select_action

	; below-right
	dec hl
	call player_trigger_select_action

	; below-left
	dec hl
	call player_trigger_select_action

	; bottom-left
	dec hl
	call player_trigger_select_action

	; middle-left
	ld bc, 0xFFE0 ; -32
	add hl, bc
	call player_trigger_select_action

	ret

; player_trigger_select_action: Routes the trigger to the appropriate method based on the value of A.
player_trigger_select_action:
	cp 0 ; trigger the tiles near the player
	jp z, player_trigger_tile
	cp 1 ; find the tiles for zapping
	jp z, selector_trigger_tile
	ret

; player_trigger_tile: Tries to perform an action on the tile at address HL.
player_trigger_tile:
	push af
	push hl
	push bc
	ld b, h
	ld c, l
	ld a, [hl]
	cp 0
	jp z, player_trigger_tile_done ; it's air, just skip it entirely

	; ok, go through the triggertable then
	ld hl, (temp_level_triggertable_buffer + 1)
	ldi a, [hl] ; get number of entries
	ld e, a
player_trigger_tile_entry_loop:
	ldi a, [hl] ; get lower byte of target
	cp c
	jp nz, player_trigger_tile_entry_loop_end_1
	ldi a, [hl] ; get upper byte of target
	cp b
	jp nz, player_trigger_tile_entry_loop_end_2

	push de

	; get target address
	ldi a, [hl] ; get lower byte of target address
	ld d, a
	ldi a, [hl] ; get upper byte of target address
	ld e, a

	push hl

	; swap d and l
	ld a, l
	ld l, d
	ld d, a
	; swap e and h
	ld a, h
	ld h, e
	ld e, a
	; swap d and e
	ld a, d
	ld d, e
	ld e, a

	; call the given function with the following parameters
	; hl = address of the function
	; bc = address of the tile
	; de = pointer to the extra data in the triggertable
	jp [hl]
player_trigger_tile_entry_resume:
	pop hl

	pop de

	jp player_trigger_tile_entry_loop_end_3

player_trigger_tile_entry_loop_end_1:
	inc hl
player_trigger_tile_entry_loop_end_2:
	inc hl
	inc hl
player_trigger_tile_entry_loop_end_3:
	inc hl
	inc hl
player_trigger_tile_entry_loop_end:
	dec e
	jp nz, player_trigger_tile_entry_loop
player_trigger_tile_done:
	pop bc
	pop hl
	pop af
	ret