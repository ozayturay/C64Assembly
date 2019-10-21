  !src "acme-macros.asm"

  SCREEN_BASE = $0400
  COLOR_BASE  = $d800
  MUSIC_BASE  = $1000

  +BasicUpStart 2019

  +RunStopRestore OFF
  +ShiftCommodore OFF

  +SetColors COLOR_BLACK
  +FillBlock SCREEN_BASE, 32
  +FillBlock COLOR_BASE, COLOR_WHITE

  +CBMFontLowerUpper
  +PrintText SCREEN_BASE + 40 * 0 + 10, hello, hello_end

  +PrepareMusic MUSIC_BASE, 0

  +EnableRasters 0, irq_music

  jmp *

irq_music
  inc $d019

  +PlayMusic MUSIC_BASE + 3
  +JumpOnSpace $fce2

  +SetRaster 50, irq_main
  jmp $ea31

irq_main
  inc $d019

  +WashLeft COLOR_BASE + 40 * 0 + 10, colors, colors_end, 1, 1

  +SetRaster 0, irq_music
  jmp $ea81

hello
  !scr "!!! Hello, World !!!"
hello_end

colors
  !byte $01,$07,$0d,$05,$0e,$04,$06,$0e,$04,$04,$04,$04,$0e,$06,$04,$0e,$05,$0d,$07,$01
colors_end
  !byte $00

*=MUSIC_BASE
  !bin "irqmusic/helloworld.sid",,$7c+2