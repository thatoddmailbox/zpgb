spriteset:
; player left 
	db 0b00000011, 0b00000011
	db 0b01100100, 0b01100111
	db 0b11010110, 0b10110111
	db 0b10111100, 0b11001111
	db 0b01011110, 0b01100111
	db 0b00111001, 0b00111110
	db 0b00001101, 0b00001110
	db 0b00000111, 0b00000111

; player right 
; 10 = orange
; 01 = yellow
	db 0b11000000, 0b11000000
	db 0b11100110, 0b00100110
	db 0b11101011, 0b01101101
	db 0b00111101, 0b11110011
	db 0b01111010, 0b11100110
	db 0b10011100, 0b01101100
	db 0b10110000, 0b01110000
	db 0b11100000, 0b11100000
spriteset_end:

sharedset:
	; wall - 0x80
	db 0b00000000, 0b11111111
	db 0b01111110, 0b10000001
	db 0b01111110, 0b10000001
	db 0b01111110, 0b10000001
	db 0b01111110, 0b10000001
	db 0b01111110, 0b10000001
	db 0b01111110, 0b10000001
	db 0b00000000, 0b11111111

	; door - 0x81
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b01111110, 0b01111110
	db 0b01111110, 0b01000010
	db 0b01111110, 0b01000010
	db 0b01111010, 0b01000110
	db 0b01111110, 0b01000010
	db 0b01111110, 0b01000010

	; laser emitter up (off) - 0x82
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00011000
	db 0b00011000, 0b00100100
	db 0b00011000, 0b00100100
	db 0b00011000, 0b00100100
	db 0b00011000, 0b00111100
	db 0b00000000, 0b00111100

	; laser emitter up (on) - 0x83
	db 0b00011000, 0b00011000
	db 0b00011000, 0b00011000
	db 0b00000000, 0b00011000
	db 0b00011000, 0b00100100
	db 0b00011000, 0b00100100
	db 0b00011000, 0b00100100
	db 0b00011000, 0b00111100
	db 0b00000000, 0b00111100

	; laser emitter cw (off) - 0x84
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b11111000
	db 0b01111000, 0b11000100
	db 0b01111000, 0b11000100
	db 0b00000000, 0b11111000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000

	; laser emitter cw (on) - 0x85
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b11111000
	db 0b01111011, 0b11000111
	db 0b01111011, 0b11000111
	db 0b00000000, 0b11111000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000

	; laser receptor up (off) - 0x86
	db 0b00000000, 0b00000000
	db 0b00000000, 0b01100110
	db 0b00000000, 0b01100110
	db 0b00000000, 0b01111110
	db 0b00111100, 0b01000010
	db 0b00111100, 0b01000010
	db 0b00111100, 0b01111110
	db 0b00000000, 0b01111110

	; laser receptor up (on) - 0x87
	db 0b00011000, 0b00011000
	db 0b00011000, 0b01111110
	db 0b00011000, 0b01111110
	db 0b00000000, 0b01111110
	db 0b00111100, 0b01000010
	db 0b00111100, 0b01000010
	db 0b00111100, 0b01111110
	db 0b00000000, 0b01111110

	; laser receptor cw (off) - 0x88
	db 0b00000000, 0b00000000
	db 0b00000000, 0b11111110
	db 0b01110000, 0b11101110
	db 0b01110000, 0b11101000
	db 0b01110000, 0b11101000
	db 0b01110000, 0b11101110
	db 0b00000000, 0b11111110
	db 0b00000000, 0b00000000

	; laser receptor cw (on) - 0x89
	db 0b00000000, 0b00000000
	db 0b00000000, 0b11111110
	db 0b01110000, 0b11101110
	db 0b01110111, 0b11101111
	db 0b01110111, 0b11101111
	db 0b01110000, 0b11101110
	db 0b00000000, 0b11111110
	db 0b00000000, 0b00000000

	; laser reflector up (off) - 0x8A
	db 0b00000000, 0b11111111
	db 0b01111000, 0b10000110
	db 0b01110000, 0b10001100
	db 0b01100000, 0b10011000
	db 0b01000000, 0b10110000
	db 0b00000000, 0b11100000
	db 0b00000000, 0b11000000
	db 0b00000000, 0b10000000

	; laser reflector up (on) - 0x8B
	db 0b00000000, 0b11111111
	db 0b01111000, 0b10000110
	db 0b01110000, 0b10001100
	db 0b01100111, 0b10011111
	db 0b01001111, 0b10111111
	db 0b00011000, 0b11111000
	db 0b00011000, 0b11011000
	db 0b00011000, 0b10011000

	; 01 = dark
	; 10 = light
	; laser reflector cw (off) - 0x8C
	db 0b00000000, 0b11111111
	db 0b00011110, 0b01100001
	db 0b00001110, 0b00110001
	db 0b00000110, 0b00011001
	db 0b00000010, 0b00001101
	db 0b00000000, 0b00000111
	db 0b00000000, 0b00000011
	db 0b00000000, 0b00000001

	; laser reflector cw (off) - 0x8D
	db 0b00000000, 0b11111111
	db 0b00011110, 0b01100001
	db 0b00001110, 0b00110001
	db 0b11100110, 0b11111001
	db 0b11110010, 0b11111101
	db 0b00011000, 0b00011111
	db 0b00011000, 0b00011011
	db 0b00011000, 0b00011001

sharedset_end:
