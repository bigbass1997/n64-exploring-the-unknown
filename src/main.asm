arch n64.cpu
endian msb
output "../ExploringTheUnknown.z64", create
fill 0x00101000 // Set ROM Size // 1024 KB + 4 KB = 1028 KB = 0x00101000 bytes

origin 0x00000000
base 0x80000000

constant fp(s8) // frame pointer (being used as framebuffer pointer)
constant BUF_BASE(0xA0010000)
constant BUF_BASE1(0xA0010000)
constant BUF_BASE2(0xA0210000)
constant BUF_FLAGS(0xA000FFFC)

constant SP_STORAGE(0xA000FF00)

constant SCREEN_WIDTH(640)
constant SCREEN_HEIGHT(480)
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
    addu t0, zero, fp
    la t1, (BYTES_PER_PIXEL * SCREEN_WIDTH * SCREEN_HEIGHT)
    addu t0, t0, t1
    
    addu t1, zero, fp
Clear:
    la t2, 0
    sw t2, 0(t1)
    bne t0, t1, Clear
    addi t1, t1, 4
}


macro SetupISR() {
    la t1, 0x80000000
	la t0, ISR_Jump
    
    lw t2, 0(t0)
    sw t2, 0x0000(t1)
    sw t2, 0x0180(t1)
    
    lw t2, 4(t0)
    sw t2, 0x0004(t1)
    sw t2, 0x0184(t1)
    
    mfc0 t0, Status
    ori t0, t0, 0x0401
    mtc0 t0, Status
    
    la t0, 0x00000080
    la t2, 0xA430000C
    sw t0, 0(t2)
}


macro SetupSwapBuffer() {
    la fp, BUF_BASE1
    la t0, 0xA4400004 // VI_ORIGIN
    sw fp, 0(t0)
    la fp, BUF_BASE2
}

macro SwapBuffer() {
    la sp, SP_STORAGE
    sd t0, 0(sp)
    sd t1, 8(sp)
    sd t2, 16(sp)
    
    la t0, 0xA4400004 // VI_ORIGIN
    sw fp, 0(t0)
    
    la t0, BUF_BASE1
    beq t0, fp, SwapB_CurrentIs1
    nop
    
//CurrentIs2
    la fp, BUF_BASE1
    
    j SwapB_End
    nop
    
SwapB_CurrentIs1:
    la fp, BUF_BASE2
    
    
SwapB_End:
    
    ClearScreen()
    
    ld t0, 0(sp)
    ld t1, 8(sp)
    ld t2, 16(sp)
}


macro SetReadyForSwap() {
    la t0, BUF_FLAGS
    lw t1, 0(t0)
    la t2, 0x00000001
    or t1, t1, t2
    sw t1, 0(t0)
}

macro WaitForSwap() {
    addu t0, zero, fp
WFS_Loop:
    beq t0, fp, WFS_Loop
    nop
}


Start:
    ScreenNTSC(SCREEN_WIDTH, SCREEN_HEIGHT, BPP32|INTERLACE|AA_MODE_3, BUF_BASE1)
    SetupSwapBuffer()
    SetupISR()
    
    
    lui t0, PIF_BASE
	addi t1, zero, 8
	sw t1, PIF_CTRL(t0)
	
    
    la t6, 0xA000C0F0
	la t7, BUF_BASE
    sw t7, 0(t6)
    
    la t0, PRINT_ADDR
    sw zero, 0(t0)
    sw zero, 4(t0)
    
    include "lib/graphics/print.inc"
    
    
    
Refresh:
    la t0, PRINT_ADDR     ////
    lw t1, 0(t0)            //
    addiu t1, t1, 8         //
    sw t1, 0(t0)          //// Increment value at PRINT_ADDR
    
    // This is a macro call that sets the necessary a- registers, and then calls the Func_HexW function (located in src/lib/graphics/print.inc)
    //PrintHexW(BUF_BASE, 476, 10, PRINT_ADDR, LineFont, COLOR_WHITE)
    
    la t0, PRINT_ADDR
    PrintHexRegW(fp, 476, 20, t0, GoodFont, COLOR_WHITE)
    
    la t0, PRINT_ADDR + 8
    dmfc0 t1, Count
    daddu t2, zero, zero
    daddu t2, t2, t1
    daddu t2, t2, t1
    daddu t2, t2, t1
    daddu t2, t2, t1
    sd t2, 0(t0)
    PrintHexRegW(fp, 476, 30, t0, GoodFont, COLOR_CYAN)
    la t0, PRINT_ADDR + 8 + 4
    PrintHexRegW(fp, 476+(8*9), 30, t0, GoodFont, COLOR_RED)
    //PrintHexW(BUF_BASE, 476+(8*9), 30, 0xA000200C, GoodFont, COLOR_WHITE)
    
    
    
    
    
    
    // Column 1
    la s0, 0xA5000000
    PrepareHexRegW(fp, 10, 10, s0, GoodFont, COLOR_GREEN)
    addu s2, zero, zero
    
    addiu s1, zero, 50
Column1Loop:
    sw s2, 0(a1)
    addiu s2, s2, 1
    jal Func_HexW
    nop
    addiu a1, a1, 4
    addiu a0, a0, 9 * SCREEN_WIDTH * BYTES_PER_PIXEL
    la t0, 0x00000500
    addu a3, a3, t0
    
    bne s1, zero, Column1Loop
    addi s1, s1, -1
    
    
    
    // Column 2
    la s0, 0xA6000000
    PrepareHexRegW(fp, 86, 10, s0, GoodFont, COLOR_RED)
    addu s2, zero, zero
    
    addiu s1, zero, 50
Column2Loop:
    sw s2, 0(a1)
    addiu s2, s2, 1
    jal Func_HexW
    nop
    addiu a1, a1, 4
    addiu a0, a0, 9 * SCREEN_WIDTH * BYTES_PER_PIXEL
    la t0, 0x00050000
    addu a3, a3, t0
    
    bne s1, zero, Column2Loop
    addi s1, s1, -1
    
    
    // Column 3
    la s0, 0xBFD00000
    PrepareHexRegW(fp, 162, 10, s0, GoodFont, 0xFF00FFFF)
    addu s2, zero, zero
    
    addiu s1, zero, 50
Column3Loop:
    sw s2, 0(a1)
    addiu s2, s2, 1
    jal Func_HexW
    nop
    addiu a1, a1, 4
    addiu a0, a0, 9 * SCREEN_WIDTH * BYTES_PER_PIXEL
    la t0, 0x00050000
    addu a3, a3, t0
    
    bne s1, zero, Column3Loop
    addi s1, s1, -1
    
    
    
    // Column 4
    la s0, 0xBFE00000
    PrepareHexRegW(fp, 238, 10, s0, GoodFont, 0xAAFFFFFF)
    addu s2, zero, zero
    
    addiu s1, zero, 50
Column4Loop:
    sw s2, 0(a1)
    addiu s2, s2, 1
    jal Func_HexW
    nop
    addiu a1, a1, 4
    addiu a0, a0, 9 * SCREEN_WIDTH * BYTES_PER_PIXEL
    la t0, 0x00000500
    subu a3, a3, t0
    
    bne s1, zero, Column4Loop
    addi s1, s1, -1
    
    
    
    // Column DMEM
    la s0, 0xA4000000
    PrepareHexRegW(fp, 314, 10, s0, GoodFont, 0x0000CCFF)
    
    addiu s1, zero, 50
ColumnDMEMLoop:
    jal Func_HexW
    nop
    addiu a1, a1, 4
    addiu a0, a0, 9 * SCREEN_WIDTH * BYTES_PER_PIXEL
    la t0, 0x05030100
    addu a3, a3, t0
    
    bne s1, zero, ColumnDMEMLoop
    addi s1, s1, -1
    
    
    
    // Column IMEM
    la s0, 0xA4001000
    PrepareHexRegW(fp, 390, 10, s0, GoodFont, 0x0000CCFF)
    
    addiu s1, zero, 50
ColumnIMEMLoop:
    jal Func_HexW
    nop
    addiu a1, a1, 4
    addiu a0, a0, 9 * SCREEN_WIDTH * BYTES_PER_PIXEL
    la t0, 0x05030100
    addu a3, a3, t0
    
    bne s1, zero, ColumnIMEMLoop
    addi s1, s1, -1
    
    
    
    // PIF RAM
    la s0, 0xBFC007C0
    PrepareHexRegW(fp, 476, 200, s0, GoodFont, COLOR_RED)
    
    addiu s1, zero, 15
PIFLoop:
    jal Func_HexW
    nop
    addiu a1, a1, 4
    addiu a0, a0, 9 * SCREEN_WIDTH * BYTES_PER_PIXEL
    la t0, 0x00000F00
    addu a3, a3, t0
    
    bne s1, zero, PIFLoop
    addi s1, s1, -1
    
    
    
    // Column 3
    la s0, 0xA4300004   // MI_VERSION
    PrintHexRegW(fp, 476, 70, s0, GoodFont, COLOR_WHITE)
    
    la s0, 0xA4800018   // SI_STATUS
    PrintHexRegW(fp, 476, (81 + (9 * 0)), s0, GoodFont, COLOR_WHITE)
    la s0, 0xA4300008   // MI_INTERRUPT
    PrintHexRegW(fp, 476, (81 + (9 * 1)), s0, GoodFont, COLOR_WHITE)
    
    la s0, 0xA4600014   // PI Registers starting at PI_DOM1_LAT
    PrintHexRegW(fp, 476, (83 + (9 * 2)), s0, GoodFont, COLOR_WHITE)
    addiu s0, s0, 4
    PrintHexRegW(fp, 476, (83 + (9 * 3)), s0, GoodFont, COLOR_WHITE)
    addiu s0, s0, 4
    PrintHexRegW(fp, 476, (83 + (9 * 4)), s0, GoodFont, COLOR_WHITE)
    addiu s0, s0, 4
    PrintHexRegW(fp, 476, (83 + (9 * 5)), s0, GoodFont, COLOR_WHITE)
    
    addiu s0, s0, 4
    PrintHexRegW(fp, 476, (85 + (9 * 6)), s0, GoodFont, COLOR_WHITE)
    addiu s0, s0, 4
    PrintHexRegW(fp, 476, (85 + (9 * 7)), s0, GoodFont, COLOR_WHITE)
    addiu s0, s0, 4
    PrintHexRegW(fp, 476, (85 + (9 * 8)), s0, GoodFont, COLOR_WHITE)
    addiu s0, s0, 4
    PrintHexRegW(fp, 476, (85 + (9 * 9)), s0, GoodFont, COLOR_WHITE)
    
    la s0, 0xBFC00000   // first 4 bytes of PIF ROM
    PrintHexRegW(fp, 476, (89 + (9 * 11)), s0, GoodFont, COLOR_WHITE)
    
    
    SetReadyForSwap()
    WaitForSwap()
    
    j Refresh
    nop
    
    
ISR_Jump:
    j ISR_Exceptions
    nop
    
ISR_Exceptions:
    la s6, BUF_FLAGS
    lw s6, 0(s6)
    la s7, 0x00000001
    and s6, s6, s7
    
    beq s6, zero, ISRE_BufferNotReady
    nop
    
//BufferIsReady
    SwapBuffer()
    
    la s6, BUF_FLAGS
    lw s6, 0(s6)
    xor s6, s6, s7
    la s7, BUF_FLAGS
    sw s6, 0(s7)
    
ISRE_BufferNotReady:
    
    addu s6, zero, zero
    la s7, 0xA4400010
    sw s6, 0(s7)
    
    eret
    nop
    
    
ALIGN(32)

insert LineFont, "linefont.bin"
insert GoodFont, "goodfont.bin"