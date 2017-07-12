; constants that are useful
.def VRAM_WIDTH_PX 256
.def VRAM_WIDTH_TILES 32
.def VRAM_HEIGHT_PX 256
.def VRAM_HEIGHT_TILES 32

.def SCREEN_WIDTH_PX 160
.def SCREEN_WIDTH_TILES 20
.def SCREEN_HEIGHT_PX 144
.def SCREEN_HEIGHT_TILES 18

.def LEVEL_TILE_COUNT (VRAM_WIDTH_TILES*VRAM_HEIGHT_TILES)

.def HUD_HEIGHT_PX 16
.def DIALOGUE_HEIGHT_PX (8*4)

.def SCREEN_MENU 0
.def SCREEN_GAME 1
.def SCREEN_STORY 2

; hardware registers
.def P1 0xFF00
.def LCDC 0xFF40
.def STAT 0xFF41
.def SCY 0xFF42
.def SCX 0xFF43
.def LY 0xFF44
.def LYC 0xFF45
.def DMA 0xFF46
.def WY 0xFF4A
.def WX 0xFF4B
.def VBK 0xFF4F
.def HDMA1 0xFF51
.def HDMA2 0xFF52
.def HDMA3 0xFF53
.def HDMA4 0xFF54
.def HDMA5 0xFF55
.def BCPS 0xFF68
.def BCPD 0xFF69
.def OCPS 0xFF6A
.def OCPD 0xFF6B
.def SVBK 0xFF70
.def IF 0xFF0F
.def IE 0xFFFF

; this is the location that the code to trigger the dma is written to
.def dma_code_highram 0xFF80

; hardware memory map
.def sprite_tile_data 0x8000
.def shared_tile_data 0x8800
.def bg_tile_data 0x9000

.def bg_tile_map_1 0x9800
.def bg_tile_map_2 0x9C00

.def sprite_ram_start 0xFE00
.def sprite_ram_len 0x9F

; ram variables
.def ram_fixed_start 0xC000

.def current_screen (ram_fixed_start+0)
.def player_x (ram_fixed_start+1)
.def player_y (ram_fixed_start+2)
.def frame_counter (ram_fixed_start+3)
.def last_p14 (ram_fixed_start+4)
.def last_p15 (ram_fixed_start+5)
.def selector_mode (ram_fixed_start+6)
.def selector_select_index (ram_fixed_start+7)
.def selector_found_count (ram_fixed_start+8)
.def selector_frame_counter (ram_fixed_start+9)
.def dialogue_active (ram_fixed_start+10)
.def dialogue_script_pointer_l (ram_fixed_start+11)
.def dialogue_script_pointer_h (ram_fixed_start+12)
.def dialogue_frame_counter (ram_fixed_start+13)
.def menu_selection (ram_fixed_start+14)
.def menu_frame_counter (ram_fixed_start+15)
.def prog_current_level (ram_fixed_start+16)
.def nonogram_active (ram_fixed_start+17)
.def nonogram_pointer_l (ram_fixed_start+18)
.def nonogram_pointer_h (ram_fixed_start+19)
.def nonogram_width (ram_fixed_start+20)
.def nonogram_height (ram_fixed_start+21)
.def nonogram_cursor_x (ram_fixed_start+22)
.def nonogram_cursor_y (ram_fixed_start+23)
.def nonogram_instruction_buffer (ram_fixed_start+24) ; 8 chars long
.def nonogram_state (ram_fixed_start+32) ; 8 bytes long
.def credits_frame_counter (ram_fixed_start+40)
.def num_buf (ram_fixed_start+41)

.def selector_select_table (ram_fixed_start+0x100)

.def oam_data (ram_fixed_start+0x200)
.def oam_data_bank 0xC2
.def sprite0_y (oam_data+(0x4*0)+0)
.def sprite0_x (oam_data+(0x4*0)+1)
.def sprite0_t (oam_data+(0x4*0)+2)
.def sprite0_a (oam_data+(0x4*0)+3)
.def sprite1_y (oam_data+(0x4*1)+0)
.def sprite1_x (oam_data+(0x4*1)+1)
.def sprite1_t (oam_data+(0x4*1)+2)
.def sprite1_a (oam_data+(0x4*1)+3)
.def sprite2_y (oam_data+(0x4*2)+0)
.def sprite2_x (oam_data+(0x4*2)+1)
.def sprite2_t (oam_data+(0x4*2)+2)
.def sprite2_a (oam_data+(0x4*2)+3)
.def spritets0_y (oam_data+(0x4*29)+0)
.def spritets0_x (oam_data+(0x4*29)+1)
.def spritets0_t (oam_data+(0x4*29)+2)
.def spritets0_a (oam_data+(0x4*29)+3)

.def ram_switchable_start 0xD000
.def temp_level_buffer (ram_switchable_start+0x0)
.def temp_level_triggertable_buffer (temp_level_buffer+0x400)