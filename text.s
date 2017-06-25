script_test:
	db 0x01
	ascii "Hello! This is    "
	asciz "text! Yay words!!!"

	db 0x02
	ascii "This is a test of "
	asciz "dialogue!"

	db 0x03
	asciz "Yay it works!"

	db 0x02
	ascii "There's no more   "
	asciz "dialogue now..."

	asciz ""