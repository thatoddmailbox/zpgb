intro_level1:
	db 0x81, 0x21, 0x80, 0x1e, 0x01, 0x01, 0x80, 0x1e, 0x01, 0x01, 0x80, 0x06, 0x2d, 0x80, 0x17, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x01, 0x01, 0x80, 0x05, 0x01, 0x80, 0x18, 0x01, 0x01, 0x80, 0x05, 0x25, 0x80, 0x18, 0x01, 0x01, 0x80, 0x05, 0x1d, 0x80, 0x04, 0x1b, 0x80, 0x13, 0x01, 0x01, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x0c, 0x01, 0x80, 0x07, 0x01, 0x80, 0x09, 0x01, 0x01, 0x80, 0x0c, 0x25, 0x80, 0x07, 0x25, 0x80, 0x09, 0x01, 0x01, 0x80, 0x07, 0x1b, 0x80, 0x04, 0x1d, 0x80, 0x03, 0x1b, 0x80, 0x03, 0x1d, 0x80, 0x09, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x04, 0x02, 0x81, 0x21
	db 0xff

intro_level1_triggertable:
	db 30
	db 5

	dw (temp_level_buffer + 0x001)
	dw level_sign_trigger
	dw script_intro_level1_start

	dw (temp_level_buffer + 0x16b)
	dw level_lever_trigger
	dw (temp_level_buffer + 0x166)

	dw (temp_level_buffer + 0x268)
	dw level_lever_trigger
	dw (temp_level_buffer + 0x26d)

	dw (temp_level_buffer + 0x271)
	dw level_lever_trigger
	dw (temp_level_buffer + 0x275)

	dw (temp_level_buffer + 0x67)
	dw level_sign_trigger
	dw script_intro_level1_sign

intro_level2:
	db 0x81, 0x21, 0x80, 0x0b, 0x08, 0x80, 0x05, 0x08, 0x80, 0x05, 0x08, 0x80, 0x06, 0x01, 0x01, 0x80, 0x1e, 0x01, 0x01, 0x80, 0x06, 0x2d, 0x80, 0x07, 0x04, 0x80, 0x05, 0x04, 0x80, 0x09, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x06, 0x80, 0x04, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x0a, 0x1b, 0x00, 0x00, 0x81, 0x0e, 0x80, 0x04, 0x0a, 0x81, 0x0b, 0x00, 0x00, 0x01, 0x01, 0x21, 0x81, 0x0b, 0x80, 0x05, 0x01, 0x01, 0x80, 0x05, 0x01, 0x80, 0x05, 0x01, 0x0d, 0x29, 0x00, 0x0a, 0x01, 0x80, 0x0d, 0x01, 0x01, 0x80, 0x05, 0x25, 0x80, 0x05, 0x81, 0x06, 0x80, 0x0d, 0x01, 0x01, 0x80, 0x05, 0x1d, 0x80, 0x18, 0x01, 0x01, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x05, 0x80, 0x03, 0x01, 0x1b, 0x80, 0x03, 0x01, 0x1b, 0x80, 0x05, 0x81, 0x07, 0x80, 0x05, 0x81, 0x05, 0x80, 0x03, 0x21, 0x01, 0x80, 0x03, 0x21, 0x01, 0x80, 0x05, 0x81, 0x07, 0x80, 0x05, 0x81, 0x05, 0x06, 0x00, 0x00, 0x29, 0x80, 0x04, 0x29, 0x80, 0x05, 0x11, 0x81, 0x07, 0x80, 0x05, 0x81, 0x11, 0x00, 0x00, 0x81, 0x08, 0x80, 0x18, 0x01, 0x80, 0x05, 0x01, 0x01, 0x80, 0x18, 0x25, 0x80, 0x05, 0x01, 0x01, 0x80, 0x18, 0x1d, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x04, 0x02, 0x81, 0x21
	db 0xff

intro_level2_triggertable:
	db 36
	db 6

	dw (temp_level_buffer + 0x1af)
	dw level_lever_trigger
	dw (temp_level_buffer + 0x1ce)

	dw (temp_level_buffer + 0x1b4)
	dw level_lever_trigger
	dw (temp_level_buffer + 0x1d3)

	dw (temp_level_buffer + 0x1f9)
	dw level_receptor_trigger
	dw (temp_level_buffer + 0x279)

	dw (temp_level_buffer + 0xe9)
	dw level_lever_trigger
	dw (temp_level_buffer + 0x10e)

	dw (temp_level_buffer + 0x12d)
	dw level_receptor_trigger
	dw (temp_level_buffer + 0x166)

	dw (temp_level_buffer + 0x67)
	dw level_sign_trigger
	dw script_intro_level2_sign

intro_level3:
	db 0x81, 0x21, 0x80, 0x14, 0x0f, 0x80, 0x03, 0x01, 0x80, 0x05, 0x01, 0x01, 0x80, 0x18, 0x25, 0x80, 0x05, 0x01, 0x01, 0x80, 0x06, 0x2d, 0x80, 0x0d, 0x06, 0x80, 0x03, 0x1d, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x01, 0x01, 0x80, 0x05, 0x01, 0x80, 0x04, 0x13, 0x80, 0x03, 0x0a, 0x80, 0x0f, 0x01, 0x01, 0x80, 0x05, 0x25, 0x80, 0x18, 0x01, 0x01, 0x80, 0x05, 0x1d, 0x80, 0x04, 0x0f, 0x80, 0x13, 0x01, 0x01, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x0b, 0x15, 0x80, 0x06, 0x13, 0x80, 0x05, 0x01, 0x80, 0x05, 0x01, 0x01, 0x80, 0x18, 0x25, 0x80, 0x05, 0x01, 0x01, 0x80, 0x0b, 0x04, 0x80, 0x06, 0x0b, 0x80, 0x05, 0x1d, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x04, 0x02, 0x81, 0x21
	db 0xff

intro_level3_triggertable:
	db 24
	db 4

	dw (temp_level_buffer + 0x273)
	dw level_receptor_trigger
	dw (temp_level_buffer + 0x279)

	dw (temp_level_buffer + 0x35)
	dw level_receptor_trigger
	dw (temp_level_buffer + 0x79)

	dw (temp_level_buffer + 0x16b)
	dw level_receptor_trigger
	dw (temp_level_buffer + 0x166)

	dw (temp_level_buffer + 0x67)
	dw level_sign_trigger
	dw script_intro_level3_sign

level99:
	db 0x81, 0x21, 0x80, 0x0f, 0x81, 0x11, 0x2e, 0x80, 0x0e, 0x81, 0x11, 0x80, 0x0f, 0x81, 0x11, 0x80, 0x0f, 0x81, 0x11, 0x80, 0x0f, 0x81, 0x12, 0x80, 0x03, 0x01, 0x01, 0x80, 0x09, 0x81, 0x11, 0x80, 0x05, 0x01, 0x80, 0x09, 0x81, 0x11, 0x80, 0x05, 0x01, 0x00, 0x1b, 0x80, 0x06, 0x2d, 0x81, 0x11, 0x80, 0x05, 0x81, 0x1b, 0x80, 0x05, 0x21, 0x80, 0x09, 0x81, 0x11, 0x80, 0x05, 0x29, 0x80, 0x09, 0x81, 0x1d, 0x80, 0x03, 0x81, 0x11, 0x80, 0x0f, 0x81, 0x11, 0x80, 0x0f, 0x81, 0x11, 0x80, 0x03, 0x81, 0x1d, 0x80, 0x03, 0x81, 0x1d, 0x80, 0x03, 0x81, 0x1d, 0x80, 0x04, 0x08, 0x00, 0x0f, 0x80, 0x03, 0x93, 0x03, 0x80, 0x09, 0x13, 0x81, 0x09, 0x80, 0x17, 0x81, 0x09, 0x80, 0x07, 0x13, 0x80, 0x08, 0x13, 0x00, 0x00, 0x13, 0x00, 0x00, 0x11, 0x81, 0x09, 0x06, 0x00, 0x00, 0x13, 0x13, 0x80, 0x06, 0x13, 0x80, 0x0b, 0x81, 0x09, 0x80, 0x10, 0x13, 0x00, 0x00, 0x13, 0x80, 0x03, 0x81, 0x09, 0x80, 0x17, 0x81, 0x09, 0x80, 0x17, 0x81, 0x09, 0x80, 0x03, 0x13, 0x00, 0x00, 0x13, 0x80, 0x05, 0x13, 0x80, 0x0a, 0x81, 0x09, 0x80, 0x17, 0x81, 0x09, 0x80, 0x17, 0x81, 0x09, 0x80, 0x0c, 0x13, 0x00, 0x00, 0x13, 0x80, 0x07, 0x81, 0x09, 0x80, 0x17, 0x21, 0x00, 0x21, 0x00, 0x21, 0x00, 0x00, 0x01, 0x01, 0x80, 0x07, 0x04, 0x00, 0x00, 0x93, 0x03, 0x00, 0x00, 0x0b, 0x80, 0x07, 0x29, 0x00, 0x29, 0x00, 0x29, 0x00, 0x02, 0x81, 0x21
	db 0xff

level99_triggertable:
	db 42
	db 7

	dw (temp_level_buffer + 0x000)
	dw level_sign_trigger
	dw script_test

	dw (temp_level_buffer + 0x041)
	dw level_terminal_trigger
	dw ngram1

	dw (temp_level_buffer + 0x108)
	dw level_lever_trigger
	dw (temp_level_buffer + 0x146)

	dw (temp_level_buffer + 0x10f)
	dw level_sign_trigger
	dw script_test

	dw (temp_level_buffer + 0x297)
	dw level_receptor_trigger
	dw (temp_level_buffer + 0x3b8)

	dw (temp_level_buffer + 0x247)
	dw level_receptor_trigger
	dw (temp_level_buffer + 0x3ba)

	dw (temp_level_buffer + 0x3d0)
	dw level_receptor_trigger
	dw (temp_level_buffer + 0x3bc)
