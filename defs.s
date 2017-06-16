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

.def current_screen (ram_fixed_start+0x0)
.def player_x (ram_fixed_start+0x1)
.def player_y (ram_fixed_start+0x2)
.def num_buf (ram_fixed_start+0x3)

.def oam_data (ram_fixed_start+0x100)
.def oam_data_bank 0xC1
.def sprite0_y (oam_data+0x00)
.def sprite0_x (oam_data+0x01)
.def sprite0_t (oam_data+0x02)
.def sprite0_a (oam_data+0x03)
.def sprite1_y (oam_data+0x04)
.def sprite1_x (oam_data+0x05)
.def sprite1_t (oam_data+0x06)
.def sprite1_a (oam_data+0x07)

.def ram_switchable_start 0xD000
.def temp_level_buffer (ram_switchable_start+0x0)