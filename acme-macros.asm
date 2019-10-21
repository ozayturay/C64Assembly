  FALSE             = $00
  TRUE              = $01
  OFF               = $00
  ON                = $01

  COLOR_BLACK       = $00
  COLOR_WHITE       = $01
  COLOR_RED         = $02
  COLOR_CYAN        = $03
  COLOR_PURPLE      = $04
  COLOR_GREEN       = $05
  COLOR_BLUE        = $06
  COLOR_YELLOW      = $07
  COLOR_ORANGE      = $08
  COLOR_BROWN       = $09
  COLOR_PINK        = $0a
  COLOR_DARKGREY    = $0b
  COLOR_GREY        = $0c
  COLOR_LIGHTGREEN  = $0d
  COLOR_LIGHTBLUE   = $0e
  COLOR_LIGHTGREY   = $0f

!macro BasicUpStart .line_num {
*=$0801
  !byte <.next_line, >.next_line
  !byte <.line_num, >.line_num
  !byte $9e
  !byte $30 + (.code_start / 1000)
  !byte $30 + ((.code_start / 100) % 10)
  !byte $30 + ((.code_start / 10) % 10)
  !byte $30 + (.code_start % 10)
	!byte 0
.next_line
  !byte 0, 0
.code_start
}

!macro BasicUpStart .line_num, .del_count, .cr_count {
*=$0801
  !byte <.next_line, >.next_line
  !byte <.line_num, >.line_num
  !byte $9e
  !byte $30 + (.code_start / 1000)
  !byte $30 + ((.code_start / 100) % 10)
  !byte $30 + ((.code_start / 10) % 10)
  !byte $30 + (.code_start % 10)
  !byte $3a, $8f, $20
	!fill .del_count, $14
  !pet "(c)2019 simon/cgtr"
  !fill .cr_count, $0d
	!byte 0
.next_line
  !byte 0, 0
.code_start
}

!macro FillBlock .target, .data {
  ldx #$00
  lda #.data
-
  sta .target + $0000, x
	sta .target + $0100, x
	sta .target + $0200, x
	sta .target + $02e8, x
	inx
  bne -
}

!macro FillBlock .target, .addr, .count {
	ldx #$00
	lda .addr
-
	sta .target, x
	inx
	cpx #.count
	bne -
}

!macro FillBlock .target, .data, .count, .repeat {
  ldx #$00
  lda #.data
-
  !for i, 0, (.repeat - 1) {
    sta .target + .count * i, x
  }
	inx
  cpx #.count
  bne -
}

!macro CopyBlock .target, .source, .count, .repeat {
	ldx #$00
-
  !for i, 0, (.repeat - 1) {
    lda .source + .count * i, x
    sta .target + .count * i, x
  }
	inx
	cpx #.count
	bne -
}

!macro CopyBlock .target, .source, .count {
  +CopyBlock .target, .source, .count, 1
}

!macro PrintText .target, .source, .source_end {
  ldx #$00
-
  lda .source, x
  sta .target, x
  inx
  cpx #.source_end - .source
  bne -
}

!macro PrintText_1x2 .target, .source, .source_end {
  ldx #$00
-
  lda .source, x
  sta .target, x
  ora #$40
  sta .target + 40, x
  inx
  cpx #.source_end - .source
  bne -
}

!macro PrepareScroll_1x1 .message, .selfmod {
  lda #<.message
  sta .selfmod + 1
  lda #>.message
  sta .selfmod + 2
}

!macro ScrollText_1x1 .message, .start, .speed, .temp {
  lda .temp
  sec
  sbc #.speed
  and #$07
  sta .temp
  bcs ++
  ldx #$00
-
  lda .start + 1, x
  sta .start, x
  inx
  cpx #$28
  bne -
read1x1
  lda .start + 39
  cmp #$00
  bne +
  lda #<.message
  sta read1x1 + 1
  lda #>.message
  sta read1x1 + 2
  jmp read1x1
+
  sta .start + 39
  inc read1x1 + 1
  lda read1x1 + 1
  cmp #$00
  bne ++
  inc read1x1 + 2
++
}

!macro PrepareScroll_1x2 .message, .selfmod {
  lda #<.message
  sta .selfmod + 1
  lda #>.message
  sta .selfmod + 2
}

!macro ScrollText_1x2 .message, .start, .speed, .temp {
  lda .temp
  sec
  sbc #.speed
  and #$07
  sta .temp
  bcs ++
  ldx #$00
-
  lda .start + 1, x
  sta .start, x
  lda .start + 41, x
  sta .start + 40, x
  inx
  cpx #$28
  bne -
read1x2
  lda .start + 39
  cmp #$00
  bne +
  lda #<.message
  sta read1x2 + 1
  lda #>.message
  sta read1x2 + 2
  jmp read1x2
+
  sta .start + 39
  ora #$40
  sta .start + 79
  inc read1x2 + 1
  lda read1x2 + 1
  cmp #$00
  bne ++
  inc read1x2 + 2
++
}

!macro RotateLeft .source, .source_end {
  lda .source
  sta .source_end
  ldx #$00
-
  lda .source + 1, x
  sta .source, x
  inx
  cpx #.source_end - .source
  bne -
}

!macro WashLeft .target, .source, .source_end, .repeat, .mod {
  lda .source
  sta .source_end
  ldx #$00
-
  lda .source + 1, x
  sta .source, x
  !for i, 0, (.repeat - 1) {
    sta .target + 40 * i * .mod, x
  }
  inx
  cpx #.source_end - .source
  bne -
}

!macro WashLeft .target, .source, .source_end {
  +WashLeft .target, .source, .source_end, 1, 1
}

!macro RotateRight .source, .source_end {
  ldx #.source_end - .source
-
  lda .source - 1, x
  sta .source, x
  dex
  bne -
  lda .source_end
  sta .source
}

!macro WashRight .target, .source, .source_end, .repeat, .mod {
  ldx #.source_end - .source
-
  lda .source - 1, x
  sta .source, x
  !for i, 0, (.repeat - 1) {
    sta .target + 40 * i * .mod, x
  }
  dex
  bne -
  lda .source_end
  sta .source
}

!macro WashRight .target, .source, .source_end {
  +WashRight .target, .source, .source_end, 1, 1
}

!macro Wait .delay {
  !if (.delay > 255) {
  ldx #.delay >> 255
--
  ldy #.delay & 255
-
    dey
    bne -
    dex
    bne --
  } else {
	  ldy #.delay
-
    dey
	  bne -
  }
}

!macro SetColors .color {
	lda #.color
  sta $d020
	sta $d021
}

!macro SetColors .border, .backgnd {
	lda #.border
  sta $d020
	lda #.backgnd
	sta $d021
}

!macro PrepareMusic .address, .songnum {
  lda #.songnum
	jsr .address
}

!macro PlayMusic .address {
	jsr .address
}

!macro SelectVICBank .bank {
  lda $dd00
  and #$fc
  ora #(3 - (.bank % 4))
  sta $dd00 
}

!macro SelectVICMemory .screen_addr, .char_addr {
  lda #((((.screen_addr & $3fff) / $400) << 4) | (((.char_addr & $3fff) / $800) << 1))
  sta $d018
}

!macro CBMFontUpperGfx {
  +SelectVICMemory $0400, $1000
}

!macro CBMFontLowerUpper {
  +SelectVICMemory $0400, $1800
}

!macro WaitSpace {
-
  lda $dc01
  cmp #$ef
  bne -
}

!macro JumpOnSpace .address {
  lda $dc01
  cmp #$ef
  bne +
  jmp .address
+
}

!macro WaitSpaceOrFire {
-
  lda $dc01
  lsr
  lsr
  lsr
  lsr
  lsr
  bcs -
}

!macro JumpOnSpaceOrFire .address {
-
  lda $dc01
  lsr
  lsr
  lsr
  lsr
  lsr
  bcs +
  jmp .address
+
}

!macro RunStopRestore .enable {
  !if (.enable) {
    lda #$ed
    sta $0328
  } else {
    lda #$ea
    sta $0328
  }
}

!macro ShiftCommodore .enable {
  !if (.enable) {
    lda #$00
    sta $0291
  } else {
    lda #$80
    sta $0291
  }
}

!macro MemoryConfig .value {
  lda #.value
  sta $01
}

!macro KernalAndBasic .enable {
  !if (.enable) {
    +MemoryConfig $37
  } else {
    +MemoryConfig $35
  }
}

!macro BackupRegisters {
  pha
  txa
  pha
  tya
  pha
}

!macro RestoreRegisters {
  pla
  tay
  pla
  tax
  pla
}

!macro SetVector .address, .vector {
	lda #<.address
	sta .vector
	lda #>.address
	sta .vector + 1
}

!macro SetRaster .raster , .irqaddr {
  lda #(.raster & $ff)
	sta $d012
  lda $d011
	!if (.raster > 255) {
    ora #$80
  } else {
	  and #$7f
  }
	sta $d011
  +SetVector .irqaddr, $0314
}

!macro SetRaster .raster , .irqaddr, .brkaddr {
  lda #(.raster & $ff)
	sta $d012
  lda $d011
	!if (.raster > 255) {
    ora #$80
  } else {
	  and #$7f
  }
	sta $d011
  +SetVector .irqaddr, $fffe
  +SetVector .brkaddr, $fffa
}

!macro EnableRasters .raster, .irqaddr {
  sei
  lda #$7f
	sta $dc0d
  sta $dd0d
	bit $dc0d
  bit $dd0d
	lda #$01
	sta $d019
	sta $d01a
  +SetRaster .raster, .irqaddr
	cli
}

!macro EnableRasters .raster, .irqaddr, .brkaddr {
  sei
  lda #$7f
	sta $dc0d
  sta $dd0d
	bit $dc0d
  bit $dd0d
	lda #$01
	sta $d019
	sta $d01a
  +SetRaster .raster, .irqaddr, .brkaddr
	cli
}

!macro DisableRasters {
  sei
	lda #$81
	sta $dc0d
	sta $dd0d
	+SetVector $fffe, $0314
  cli
}