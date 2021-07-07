arch n64.cpu
endian msb
output "../ExploringTheUnknown.z64", create
fill 0x00101000 // Set ROM Size // 1024 KB + 4 KB = 1028 KB = 0x00101000 bytes

origin 0x00000000
base 0x80000000

constant BUF_BASE(0xA0100000)
constant SCREEN_WIDTH(320)
constant SCREEN_HEIGHT(240)
constant BYTES_PER_PIXEL(4)
constant FONT_SPACING(1)

// RDRAM Addresses for printable values
constant PRINT_ADDR(0xA0002000)

include "lib/n64/header.asm"
include "lib/n64/n64.inc"
include "lib/n64/gfx.inc"
include "lib/graphics/colors.inc"
insert "lib/bin/n64_bootcode.bin"

macro ClearScreen() {
    la t0, BUF_BASE + (4 * SCREEN_WIDTH * SCREEN_HEIGHT)
    la t1, BUF_BASE
Clear:
    la t2, 0
    sw t2, 0(t1)
    bne t0, t1, Clear
    addi t1, t1, 4
}



Start:
	lui t0, PIF_BASE
	addi t1, zero, 8
	sw t1, PIF_CTRL(t0)
	
	ScreenNTSC(SCREEN_WIDTH, SCREEN_HEIGHT, BPP32|INTERLACE|AA_MODE_3, BUF_BASE)
    
    la t6, 0xA000C0F0
	la t7, BUF_BASE
    sw t7, 0(t6)
    
    la t0, PRINT_ADDR
    sw zero, 0(t0)
    sw zero, 4(t0)
    
    include "lib/graphics/print.inc"
    
Refresh:
    WaitScanline(512)
    ClearScreen()
    
    
    la t6, 0xA000C0F0     ////
    la t8, COLOR_DARKGREEN  //
                            //
    lw t7, 0(t6)            //
    sw t8, 0(t7)            //
    addi t7, t7, 16         //
    sw t7, 0(t6)          //// moving green pixel across the screen
    
    
    la t0, PRINT_ADDR     ////
    lw t1, 0(t0)            //
    addiu t1, t1, 8         //
    sw t1, 0(t0)          //// Increment value at PRINT_ADDR
    
    
    //la t1, 0x12345678     //
    //sw t1, 0(t0)          // Uncomment to set value stored at PRINT_ADDR to a specific number
    
    
    // This is a macro call that sets the necessary a- registers, and then calls the Func_HexDW function (located in src/lib/graphics/print.inc)
    PrintHexW(BUF_BASE, 10, 10, PRINT_ADDR, LineFont, COLOR_WHITE)
    
    la t0, PRINT_ADDR
    PrintHexRegW(BUF_BASE, 10, 20, t0, GoodFont, COLOR_WHITE)
    
    
    // Column 1
    la s0, 0xA5000000
    PrintHexRegW(BUF_BASE, 6, (70 + (9 * 0)), s0, GoodFont, COLOR_GREEN | 0x00001000)
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 6, (70 + (9 * 1)), s0, GoodFont, COLOR_GREEN | 0x00002000)
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 6, (70 + (9 * 2)), s0, GoodFont, COLOR_GREEN | 0x00003000)
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 6, (70 + (9 * 3)), s0, GoodFont, COLOR_GREEN | 0x00004000)
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 6, (70 + (9 * 4)), s0, GoodFont, COLOR_GREEN | 0x00005000)
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 6, (70 + (9 * 5)), s0, GoodFont, COLOR_GREEN | 0x00006000)
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 6, (70 + (9 * 6)), s0, GoodFont, COLOR_GREEN | 0x00007000)
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 6, (70 + (9 * 7)), s0, GoodFont, COLOR_GREEN | 0x00008000)
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 6, (70 + (9 * 8)), s0, GoodFont, COLOR_GREEN | 0x00009000)
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 6, (70 + (9 * 9)), s0, GoodFont, COLOR_GREEN | 0x0000A000)
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 6, (70 + (9 * 10)), s0, GoodFont, COLOR_GREEN | 0x0000B000)
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 6, (70 + (9 * 11)), s0, GoodFont, COLOR_GREEN | 0x0000C000)
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 6, (70 + (9 * 12)), s0, GoodFont, COLOR_GREEN | 0x0000D000)
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 6, (70 + (9 * 13)), s0, GoodFont, COLOR_GREEN | 0x0000E000)
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 6, (70 + (9 * 14)), s0, GoodFont, COLOR_GREEN | 0x0000F000)
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 6, (70 + (9 * 15)), s0, GoodFont, COLOR_GREEN | 0x0000FF00)
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 6, (70 + (9 * 16)), s0, GoodFont, COLOR_GREEN | 0x1000FF00)
    
    
    // Column 2 // PIF RAM
    la s0, 0xBFC007C0
    PrepareHexRegW(BUF_BASE, 82, (70 + (9 * 0)), s0, GoodFont, COLOR_GREEN)
    
    addiu s1, zero, 15
Column2Loop:
    jal Func_HexW
    nop
    addiu a1, a1, 4
    addiu a0, a0, 9 * SCREEN_WIDTH * BYTES_PER_PIXEL
    la t0, 0x00000F00
    addu a3, a3, t0
    
    bne s1, zero, Column2Loop
    addi s1, s1, -1
    
    
    
    // Column 3
    la s0, 0xA4300004   // MI_VERSION
    PrintHexRegW(BUF_BASE, 234, 70, s0, GoodFont, COLOR_WHITE)
    
    la s0, 0xA4800018   // SI_STATUS
    PrintHexRegW(BUF_BASE, 234, (81 + (9 * 0)), s0, GoodFont, COLOR_WHITE)
    la s0, 0xBFC007FC   // last 4 bytes of PIF RAM
    PrintHexRegW(BUF_BASE, 234, (81 + (9 * 1)), s0, GoodFont, COLOR_WHITE)
    
    la s0, 0xA4600014   // PI Registers starting at PI_DOM1_LAT
    PrintHexRegW(BUF_BASE, 234, (83 + (9 * 2)), s0, GoodFont, COLOR_WHITE)
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 234, (83 + (9 * 3)), s0, GoodFont, COLOR_WHITE)
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 234, (83 + (9 * 4)), s0, GoodFont, COLOR_WHITE)
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 234, (83 + (9 * 5)), s0, GoodFont, COLOR_WHITE)
    
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 234, (85 + (9 * 6)), s0, GoodFont, COLOR_WHITE)
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 234, (85 + (9 * 7)), s0, GoodFont, COLOR_WHITE)
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 234, (85 + (9 * 8)), s0, GoodFont, COLOR_WHITE)
    addiu s0, s0, 4
    PrintHexRegW(BUF_BASE, 234, (85 + (9 * 9)), s0, GoodFont, COLOR_WHITE)
    
    la s0, 0xA4700014   // RI_LATENCY
    PrintHexRegW(BUF_BASE, 234, (87 + (9 * 10)), s0, GoodFont, COLOR_WHITE)
    
    la s0, 0xBFC00000   // first 4 bytes of PIF ROM
    PrintHexRegW(BUF_BASE, 234, (89 + (9 * 11)), s0, GoodFont, COLOR_WHITE)
    
    la t0, 0x12345678
    la s0, 0xBFD00000   // Cart Domain 1 Address 3
    sw t0, 0(s0)
    PrintHexRegW(BUF_BASE, 234, (91 + (9 * 12)), s0, GoodFont, COLOR_WHITE)
    la t0, 0x9ABCDEF0
    la s0, 0xBFD00100   // Cart Domain 1 Address 3
    sw t0, 0(s0)
    PrintHexRegW(BUF_BASE, 234, (91 + (9 * 13)), s0, GoodFont, COLOR_WHITE)
    la t0, 0x66FFAA99
    la s0, 0xBFD00104   // Cart Domain 1 Address 3
    sw t0, 0(s0)
    PrintHexRegW(BUF_BASE, 234, (91 + (9 * 14)), s0, GoodFont, COLOR_WHITE)
    
    
    
    la t0, 0xA0002008
    dmfc0 Count, t1
    daddu t2, zero, zero
    daddu t2, t2, t1
    daddu t2, t2, t1
    daddu t2, t2, t1
    daddu t2, t2, t1
    sd t2, 0(t0)
    PrintHexRegW(BUF_BASE, 10, 50, t0, GoodFont, COLOR_WHITE)
    PrintHexW(BUF_BASE, 10+(8*9), 50, 0xA000200C, GoodFont, COLOR_WHITE)
    
    
    j Refresh
    nop
    
    

    
insert LineFont, "linefont.bin"
insert GoodFont, "goodfont.bin"