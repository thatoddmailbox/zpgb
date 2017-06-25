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

; tile selector (not selected)
	db 0b11100111, 0b00000000
	db 0b10000001, 0b00000000
	db 0b10000001, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b10000001, 0b00000000
	db 0b10000001, 0b00000000
	db 0b11100111, 0b00000000

; tile selector (selected)
	db 0b00000000, 0b11100111
	db 0b00000000, 0b10000001
	db 0b00000000, 0b10000001
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b10000001
	db 0b00000000, 0b10000001
	db 0b00000000, 0b11100111
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

	; laser emitter (dir 0, off) - 0x82
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00011000
	db 0b00011000, 0b00100100
	db 0b00011000, 0b00100100
	db 0b00011000, 0b00100100
	db 0b00011000, 0b00111100
	db 0b00000000, 0b00111100

	; laser emitter (dir 0, on) - 0x83
	db 0b00011000, 0b00011000
	db 0b00011000, 0b00011000
	db 0b00000000, 0b00011000
	db 0b00011000, 0b00100100
	db 0b00011000, 0b00100100
	db 0b00011000, 0b00100100
	db 0b00011000, 0b00111100
	db 0b00000000, 0b00111100

	; laser emitter (dir 1, off) - 0x84
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b11111000
	db 0b01111000, 0b11000100
	db 0b01111000, 0b11000100
	db 0b00000000, 0b11111000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000

	; laser emitter (dir 1, on) - 0x85
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b11111000
	db 0b01111011, 0b11000111
	db 0b01111011, 0b11000111
	db 0b00000000, 0b11111000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000

	; laser emitter (dir 2, off) - 0x86
	db 0b00000000, 0b00111100
	db 0b00011000, 0b00111100
	db 0b00011000, 0b00100100
	db 0b00011000, 0b00100100
	db 0b00011000, 0b00100100
	db 0b00000000, 0b00011000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000

	; laser emitter (dir 2, on) - 0x87
	db 0b00000000, 0b00111100
	db 0b00011000, 0b00111100
	db 0b00011000, 0b00100100
	db 0b00011000, 0b00100100
	db 0b00011000, 0b00100100
	db 0b00000000, 0b00011000
	db 0b00011000, 0b00011000
	db 0b00011000, 0b00011000

	; laser emitter (dir 3, off) - 0x88
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00011111
	db 0b00011110, 0b00100011
	db 0b00011110, 0b00100011
	db 0b00000000, 0b00011111
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000

	; laser emitter (dir 3, on) - 0x89
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00011111
	db 0b11011110, 0b11100011
	db 0b11011110, 0b11100011
	db 0b00000000, 0b00011111
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000

	; laser receptor (dir 0, off) - 0x8A
	db 0b00000000, 0b00000000
	db 0b00000000, 0b01100110
	db 0b00000000, 0b01100110
	db 0b00000000, 0b01111110
	db 0b00111100, 0b01000010
	db 0b00111100, 0b01000010
	db 0b00111100, 0b01111110
	db 0b00000000, 0b01111110

	; laser receptor (dir 0, on) - 0x8B
	db 0b00011000, 0b00011000
	db 0b00011000, 0b01111110
	db 0b00011000, 0b01111110
	db 0b00000000, 0b01111110
	db 0b00111100, 0b01000010
	db 0b00111100, 0b01000010
	db 0b00111100, 0b01111110
	db 0b00000000, 0b01111110

	; laser receptor (dir 1, off) - 0x8C
	db 0b00000000, 0b00000000
	db 0b00000000, 0b11111110
	db 0b01110000, 0b11001110
	db 0b01110000, 0b11001000
	db 0b01110000, 0b11001000
	db 0b01110000, 0b11001110
	db 0b00000000, 0b11111110
	db 0b00000000, 0b00000000

	; laser receptor (dir 1, on) - 0x8D
	db 0b00000000, 0b00000000
	db 0b00000000, 0b11111110
	db 0b01110000, 0b11001110
	db 0b01110111, 0b11001111
	db 0b01110111, 0b11001111
	db 0b01110000, 0b11001110
	db 0b00000000, 0b11111110
	db 0b00000000, 0b00000000

	; laser receptor (dir 2, off) - 0x8E
	db 0b00000000, 0b01111110
	db 0b00111100, 0b01111110
	db 0b00111100, 0b01000010
	db 0b00111100, 0b01000010
	db 0b00000000, 0b01111110
	db 0b00000000, 0b01100110
	db 0b00000000, 0b01100110
	db 0b00000000, 0b00000000

	; laser receptor (dir 2, on) - 0x8F
	db 0b00000000, 0b01111110
	db 0b00111100, 0b01111110
	db 0b00111100, 0b01000010
	db 0b00111100, 0b01000010
	db 0b00000000, 0b01111110
	db 0b00011000, 0b01111110
	db 0b00011000, 0b01111110
	db 0b00011000, 0b00011000

	; laser receptor (dir 3, off) - 0x90
	db 0b00000000, 0b00000000
	db 0b00000000, 0b01111111
	db 0b00001110, 0b01110011
	db 0b00001110, 0b00010011
	db 0b00001110, 0b00010011
	db 0b00001110, 0b01110011
	db 0b00000000, 0b01111111
	db 0b00000000, 0b00000000

	; laser receptor (dir 3, on) - 0x91
	db 0b00000000, 0b00000000
	db 0b00000000, 0b01111111
	db 0b00001110, 0b01110011
	db 0b11101110, 0b11110011
	db 0b11101110, 0b11110011
	db 0b00001110, 0b01110011
	db 0b00000000, 0b01111111
	db 0b00000000, 0b00000000

	; laser reflector (dir 0, off) - 0x92
	db 0b00000000, 0b11111111
	db 0b01111000, 0b10000110
	db 0b01110000, 0b10001100
	db 0b01100000, 0b10011000
	db 0b01000000, 0b10110000
	db 0b00000000, 0b11100000
	db 0b00000000, 0b11000000
	db 0b00000000, 0b10000000

	; laser reflector (dir 0, on) - 0x93
	db 0b00000000, 0b11111111
	db 0b01111000, 0b10000110
	db 0b01110000, 0b10001100
	db 0b01100111, 0b10011111
	db 0b01001111, 0b10111111
	db 0b00011000, 0b11111000
	db 0b00011000, 0b11011000
	db 0b00011000, 0b10011000

	; laser reflector (dir 1, off) - 0x94
	db 0b00000000, 0b11111111
	db 0b00011110, 0b01100001
	db 0b00001110, 0b00110001
	db 0b00000110, 0b00011001
	db 0b00000010, 0b00001101
	db 0b00000000, 0b00000111
	db 0b00000000, 0b00000011
	db 0b00000000, 0b00000001

	; laser reflector (dir 1, on) - 0x95
	db 0b00000000, 0b11111111
	db 0b00011110, 0b01100001
	db 0b00001110, 0b00110001
	db 0b11100110, 0b11111001
	db 0b11110010, 0b11111101
	db 0b00011000, 0b00011111
	db 0b00011000, 0b00011011
	db 0b00011000, 0b00011001

	; laser reflector (dir 2, off) - 0x96
	db 0b00000000, 0b00000001
	db 0b00000000, 0b00000011
	db 0b00000000, 0b00000111
	db 0b00000010, 0b00001101
	db 0b00000110, 0b00011001
	db 0b00001110, 0b00110001
	db 0b00011110, 0b01100001
	db 0b00000000, 0b11111111

	; laser reflector (dir 2, on) - 0x97
	db 0b00011000, 0b00011001
	db 0b00011000, 0b00011011
	db 0b00011000, 0b00011111
	db 0b11110010, 0b11111101
	db 0b11100110, 0b11111001
	db 0b00001110, 0b00110001
	db 0b00011110, 0b01100001
	db 0b00000000, 0b11111111

	; laser reflector (dir 3, off) - 0x98
	db 0b00000000, 0b10000000
	db 0b00000000, 0b11000000
	db 0b00000000, 0b11100000
	db 0b01000000, 0b10110000
	db 0b01100000, 0b10011000
	db 0b01110000, 0b10001100
	db 0b01111000, 0b10000110
	db 0b00000000, 0b11111111

	; laser reflector (dir 3, on) - 0x99
	db 0b00011000, 0b10011000
	db 0b00011000, 0b11011000
	db 0b00011000, 0b11111000
	db 0b01001111, 0b10111111
	db 0b01100111, 0b10011111
	db 0b01110000, 0b10001100
	db 0b01111000, 0b10000110
	db 0b00000000, 0b11111111

	; lever (dir 0, off) - 0x9A
	db 0b00000000, 0b00000000
	db 0b00000000, 0b01100000
	db 0b01100000, 0b00000000
	db 0b01100000, 0b00000000
	db 0b01100000, 0b00000000
	db 0b01100000, 0b00000000
	db 0b11111111, 0b00000000
	db 0b11111111, 0b00000000

	; lever (dir 0, on) - 0x9B
	db 0b00000000, 0b00000000
	db 0b00000110, 0b00000110
	db 0b00000110, 0b00000000
	db 0b00000110, 0b00000000
	db 0b00000110, 0b00000000
	db 0b00000110, 0b00000000
	db 0b11111111, 0b00000000
	db 0b11111111, 0b00000000

	; piston base (dir 0, off) - 0x9C
	db 0b00000000, 0b00011000
	db 0b00000000, 0b00011000
	db 0b00000000, 0b00011000
	db 0b00000000, 0b11111111
	db 0b01111110, 0b10000001
	db 0b01111110, 0b10000001
	db 0b01111110, 0b10000001
	db 0b00000000, 0b11111111

	; piston base (dir 0, on) - 0x9D
	db 0b00000000, 0b11111111
	db 0b00000000, 0b11111111
	db 0b00000000, 0b00011000
	db 0b00000000, 0b11111111
	db 0b01111110, 0b10000001
	db 0b01111110, 0b10000001
	db 0b01111110, 0b10000001
	db 0b00000000, 0b11111111

	; 01 = dark
	; 10 = light
	; piston base (dir 1, off) - 0x9E
	db 0b00000000, 0b11111000
	db 0b01110000, 0b10001000
	db 0b01110000, 0b10001000
	db 0b01110000, 0b10001111
	db 0b01110000, 0b10001111
	db 0b01110000, 0b10001000
	db 0b01110000, 0b10001000
	db 0b00000000, 0b11111000

	; piston base (dir 1, on) - 0x9F
	db 0b00000000, 0b11111011
	db 0b01110000, 0b10001011
	db 0b01110000, 0b10001011
	db 0b01110000, 0b10001111
	db 0b01110000, 0b10001111
	db 0b01110000, 0b10001011
	db 0b01110000, 0b10001011
	db 0b00000000, 0b11111011

	; piston base (dir 2, off) - 0xA0
	db 0b00000000, 0b11111111
	db 0b01111110, 0b10000001
	db 0b01111110, 0b10000001
	db 0b01111110, 0b10000001
	db 0b00000000, 0b11111111
	db 0b00000000, 0b00011000
	db 0b00000000, 0b00011000
	db 0b00000000, 0b00011000

	; piston base (dir 2, on) - 0xA1
	db 0b00000000, 0b11111111
	db 0b01111110, 0b10000001
	db 0b01111110, 0b10000001
	db 0b01111110, 0b10000001
	db 0b00000000, 0b11111111
	db 0b00000000, 0b00011000
	db 0b00000000, 0b11111111
	db 0b00000000, 0b11111111

	; piston base (dir 3, off) - 0xA2
	db 0b00000000, 0b00011111
	db 0b00001110, 0b00010001
	db 0b00001110, 0b00010001
	db 0b00001110, 0b11110001
	db 0b00001110, 0b11110001
	db 0b00001110, 0b00010001
	db 0b00001110, 0b00010001
	db 0b00000000, 0b00011111

	; piston base (dir 3, on) - 0xA3
	db 0b00000000, 0b11011111
	db 0b00001110, 0b11010001
	db 0b00001110, 0b11010001
	db 0b00001110, 0b11110001
	db 0b00001110, 0b11110001
	db 0b00001110, 0b11010001
	db 0b00001110, 0b11010001
	db 0b00000000, 0b11011111

	; piston arm (dir 0, off) - 0xA4
	db 0b00000000, 0b11111111
	db 0b00000000, 0b11111111
	db 0b00000000, 0b00011000
	db 0b00000000, 0b00011000
	db 0b00000000, 0b00011000
	db 0b00000000, 0b00011000
	db 0b00000000, 0b00011000
	db 0b00000000, 0b00011000

	; piston arm (dir 0, on) - 0xA5
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000

	; piston arm (dir 1, off) - 0xA6
	db 0b00000000, 0b00000011
	db 0b00000000, 0b00000011
	db 0b00000000, 0b00000011
	db 0b00000000, 0b11111111
	db 0b00000000, 0b11111111
	db 0b00000000, 0b00000011
	db 0b00000000, 0b00000011
	db 0b00000000, 0b00000011

	; piston arm (dir 1, on) - 0xA7
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000

	; piston arm (dir 2, off) - 0xA8
	db 0b00000000, 0b00011000
	db 0b00000000, 0b00011000
	db 0b00000000, 0b00011000
	db 0b00000000, 0b00011000
	db 0b00000000, 0b00011000
	db 0b00000000, 0b00011000
	db 0b00000000, 0b11111111
	db 0b00000000, 0b11111111

	; piston arm (dir 2, on) - 0xA9
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000

	; piston arm (dir 3, off) - 0xAA
	db 0b00000000, 0b11000000
	db 0b00000000, 0b11000000
	db 0b00000000, 0b11000000
	db 0b00000000, 0b11111111
	db 0b00000000, 0b11111111
	db 0b00000000, 0b11000000
	db 0b00000000, 0b11000000
	db 0b00000000, 0b11000000

	; piston arm (dir 3, on) - 0xAB
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000
	db 0b00000000, 0b00000000

	; sign - 0xAC
	db 0b00000000, 0b00000000
	db 0b00000000, 0b11111111
	db 0b01111110, 0b10000001
	db 0b01111110, 0b10000001
	db 0b01111110, 0b10000001
	db 0b00000000, 0b11111111
	db 0b00000000, 0b00011000
	db 0b00000000, 0b00011000

sharedset_end:
endset:
	; a button - 0xFF
	db 0b01111110, 0b01111110
	db 0b11111111, 0b10000001
	db 0b11111111, 0b10111101
	db 0b11111111, 0b10100101
	db 0b11111111, 0b10111101
	db 0b11111111, 0b10100101
	db 0b11111111, 0b10000001
	db 0b01111110, 0b01111110

endset_end:
