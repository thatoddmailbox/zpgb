.org 0x40
int_vblank:
	push af
	call dma_code_highram
	pop af
	reti

.org 0x48
int_lcdc:
	reti

.org 0x50
int_timer_overflow:
	reti

.org 0x58
int_serial:
	reti
	
.org 0x60
int_joystick:
	reti