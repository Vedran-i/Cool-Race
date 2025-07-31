.segment "HEADER"
    .byte "NES"
    .byte $1a
    .byte $02
    .byte $01
    .byte %00000001
    .byte $00
    .byte $00
    .byte $00
    .byte $00
    .byte $00, $00, $00, $00, $00
.segment "STARTUP"
.segment "ZEROPAGE"
    pointerLo: .res 1    ; pointer variables declared in RAM
    pointerHi: .res 1    ; low byte first, high byte immediately after
    GameState: .res 1
    Speed: .res 1
    Speed2: .res 1
    TimerCounter:      .res 1    ; current timer value (0 to 9)
    FrameDelayCounter: .res 1    ; how many frames to wait before incrementing timer  
    TimerCounter2:      .res 1    ; current timer value (0 to 9)
    FrameDelayCounter2: .res 1    ; how many frames to wait before incrementing timer  
    TimerCounter3:      .res 1    ; current timer value (0 to 9)
    FrameDelayCounter3: .res 1    ; how many frames to wait before incrementing timer 
    TimerCounterX:      .res 1    ; current timer value (0 to 9)
    FrameDelayCounterX: .res 1    ; how many frames to wait before incrementing timer 
    TimerCounterX2:      .res 1    ; current timer value (0 to 9)
    FrameDelayCounterX2: .res 1    ; how many frames to wait before incrementing timer 
.segment "CODE"



TitleScreen = $00
PlayingGame = $01 
GameOver = $02

Sprite1_Y = $0200
Sprite2_Y = $0280
Sprite3_Y = $029C

Player1SpriteTwo_Y = $021C

Sprite1_X = $0203
Sprite2_X = $0283
Sprite3_X = $029F

Player1SpriteTwo_X = $021F

HoleSprite_X = $0233 
HoleSprite_Y = $0230

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Subroutines ;;;
vblankwait:
    BIT $2002 
    BPL vblankwait 
    RTS 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init code ;;;
RESET:
    SEI 
    CLD 
    LDX #$40
    STX $4017
    LDX #$ff
    TXS 
    INX 
    STX $2000   ; disable NMI
    STX $2001   ; disable rendering
    STX $4010   ; disab;e DMC IRQs

    JSR vblankwait

    TXA 
clearmem:
    STA $0000,X
    STA $0100,X
    STA $0300,X
    STA $0400,X
    STA $0500,X
    STA $0600,X
    STA $0700,X
    LDA #$fe
    STA $0200,X
    LDA #$00
    INX 
    BNE clearmem 

    JSR vblankwait

    LDA $02     ; high byte for sprite memory
    STA $4014
    NOP 

clearnametables:
    LDA $2002   ; reset PPU status
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006
    LDX #$08
    LDY #$00
    LDA #$24    ; clear background tile
:
    STA $2007
    DEY 
    BNE :-
    DEX 
    BNE :-

loadpalettes:
    LDA $2002
    LDA #$3f
    STA $2006
    LDA #$00
    STA $2006
    LDX #$00
loadpalettesloop:
    LDA palette,X   ; load data from adddress (palette + X)
                        ; 1st time through loop it will load palette+0
                        ; 2nd time through loop it will load palette+1
                        ; 3rd time through loop it will load palette+2
                        ; etc
    STA $2007
    INX 
    CPX #$20
    BNE loadpalettesloop

loadsprites:
    LDX #$00
loadspritesloop:
    LDA sprites,X
    STA $0200,X
    INX 
    CPX #$FF
    BNE loadspritesloop 
                
;;; Using nested loops to load the background efficiently ;;;
loadbackground:
    LDA $2002               ; read PPU status to reset the high/low latch
    LDA #$20
    STA $2006               ; write high byte of $2000 address
    LDA #$00
    STA $2006               ; write low byte of $2000 address

    LDA #<background 
    STA pointerLo           ; put the low byte of address of background into pointer
    LDA #>background        ; #> is the same as HIGH() function in NESASM, used to get the high byte
    STA pointerHi           ; put high byte of address into pointer

    LDX #$00                ; start at pointer + 0
    LDY #$00
outsideloop:

insideloop:
    LDA (pointerLo),Y       ; copy one background byte from address in pointer + Y
    STA $2007               ; runs 256*4 times

    INY                     ; inside loop counter
    CPY #$00                
    BNE insideloop          ; run inside loop 256 times before continuing

    INC pointerHi           ; low byte went from 0 -> 256, so high byte needs to be changed now

    INX                     ; increment outside loop counter
    CPX #$04                ; needs to happen $04 times, to copy 1KB data
    BNE outsideloop         


    CLI 
    LDA #%10010000  ; enable NMI, sprites from pattern table 0, background from 1
    STA $2000
    LDA #%00011110  ; background and sprites enable, no left clipping
    STA $2001



forever:
    JMP forever 














    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; NMI / vblank ;;;
VBLANK:
  LDA #$00
  STA $2003       ; set the low byte (00) of the RAM address 
    LDA #$02
    STA $4014











GameEngine:  


  LDA GameState
  CMP #0
  BEQ EngineTitle    ;;game is displaying title screen

  LDA GameState
  CMP #1
  BEQ EnginePlaying   ;;game is playing

  LDA GameState
  CMP #2
  BEQ GameOverScreen   ;;game is playing


GameOverScreen:




LDA #$00
STA $2000
STA $2001


LDA #$50
STA $2000
STA $2001



LDA #%00001000       ; Bit 3 set = enable noise channel
  STA $4015

; Configure Noise Channel Envelope
  LDA #%00110100       ; Volume 4, Envelope disabled, decay rate fast
                         ; Bit 7 = 0 (disable envelope)
                         ; Bit 6 = 1 (constant volume)
                         ; Bit 5-0 = 4 (volume)
  STA $400C            ; Write to Noise Envelope/Volume register

; Configure Noise Frequency
  LDA #%00111110       ; Frequency index = $23 (higher frequency for sharpness)
                         ; Bit 7 = 0 (non-looping random noise)
                         ; Bits 4-0 = $23 (frequency index)
  STA $400E            ; Write to Noise Period register

; Restart the length counter
  LDA #%00001000       ; Load length counter (short duration)
  STA $400F            ; Writing to $400F also resets envelope and length counter



;Stops sound
  LDA #$00
  STA $4015


LDA #%00001000       ; Bit 3 set = enable noise channel
  STA $4015

; Configure Noise Channel Envelope
  LDA #%00110100       ; Volume 4, Envelope disabled, decay rate fast
                         ; Bit 7 = 0 (disable envelope)
                         ; Bit 6 = 1 (constant volume)
                         ; Bit 5-0 = 4 (volume)
  STA $400C            ; Write to Noise Envelope/Volume register

; Configure Noise Frequency
  LDA #%00111111       ; Frequency index = $23 (higher frequency for sharpness)
                         ; Bit 7 = 0 (non-looping random noise)
                         ; Bits 4-0 = $23 (frequency index)
  STA $400E            ; Write to Noise Period register

; Restart the length counter
  LDA #%00001000       ; Load length counter (short duration)
  STA $400F            ; Writing to $400F also resets envelope and length counter

DelayLoopX1:
  LDX #$Fb            ; Outer loop for a longer delay   
DelayLoopOuterX1:
  LDY #$Fb            ; Inner loop
DelayLoopInnerX1:
  DEY
  BNE DelayLoopInnerX1  ; Repeat inner loop until Y = 0
  DEX
  BNE DelayLoopOuterX1  ; Repeat outer loop until X = 0

;Stops sound
  LDA #$00
  STA $4015





GameEngineDone:



EngineTitle:




LatchControllerT:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016       ; tell both the controllers to latch buttons


ReadAT: 
  LDA $4016       ; player 1 - A
  AND #%00000001  ; only look at bit 0
  BEQ ReadADoneT   ; branch to ReadADone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)

  
 
  LDA #$01
  STA GameState



ReadADoneT:        ; handling this button is done



 JMP GameEngineDone



EnginePlaying:

JSR StartTimer
JSR StartTimer2
JSR StartTimer3
JSR StartTimerX
JSR StartTimerX2



;removes the title when game starts


LDA #$FF
STA $02E0
LDA #$FF
STA $02E3

LDA #$FF
STA $02DF
LDA #$FF
STA $02DC

LDA #$FF
STA $02DC
LDA #$FF
STA $02D8

LDA #$FF
STA $02D7
LDA #$FF
STA $02D4

LDA #$FF ;car icon pos
STA $02D3
LDA #$FF
STA $02D0

LDA #$43  ;car icon lower right index
STA $02D1

LDA #$02  ;palette
STA $02D2

LDA #$FF
STA $02CF
LDA #$FF
STA $02CC

LDA #$FF
STA $02CC
LDA #$FF
STA $02C8

LDA #$FF
STA $02C7
LDA #$FF
STA $02C4
     
LDA #$FF
STA $02C3
LDA #$FF
STA $02C0

LDA #$FF
STA $02BF
LDA #$FF
STA $02BC

LDA #$FF
STA $02BC
LDA #$FF
STA $02B8

LDA #$FF
STA $02B7
LDA #$FF
STA $02B4

LDA #$FF
STA $02B3
LDA #$FF
STA $02B0

LDA #$FF
STA $02AF
LDA #$FF
STA $02AC

LDA #$FF
STA $02AC
LDA #$FF
STA $02A8





LDA #$5E
STA $02A7
LDA #$CD
STA $02A4
LDA #$F5
STA $02A5
LDA #$01
STA $02A6



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; sprite / nametable / attributes / palettes

LatchController:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016       ; tell both the controllers to latch buttons




ReadA: 
  LDA $4016       ; player 1 - A
  AND #%00000001  ; only look at bit 0
  BEQ ReadADone   ; branch to ReadADone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)




ReadADone:        ; handling this button is done
  
ReadB: 
  LDA $4016       ; player 1 - B
  AND #%00000001  ; only look at bit 0
  BEQ ReadBDone   ; branch to ReadBDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)


  LDA #$F6
  STA $02A5
  JSR movingBG


ReadBDone:        ; handling this button is done

  LDA #$FC
  STA $02A1

  


ReadSelect: 
  LDA $4016       ; player 1 - B
  AND #%00000001  ; only look at bit 0
  BEQ ReadSelectDone   ; branch to ReadBDone if button is NOT pressed (0)




ReadSelectDone:        ; handling this button is done

ReadStart: 
  LDA $4016       ; player 1 - B
  AND #%00000001  ; only look at bit 0
  BEQ ReadStartDone   ; branch to ReadBDone if button is NOT pressed (0)

ReadStartDone:

ReadUp:
LDA $4016       ; player 1 - B
AND #%00000001  ; only look at bit 0
BEQ ReadUpDone   ; branch to ReadBDone if button is NOT pressed (0)

LDA $0200       ; load sprite1 X position
SEC             ; make sure the carry flag is clear
SBC #$01        ; A = A + 1
STA $0200       ; save sprite X position

LDA $0204       ; load sprite1 X position
SEC            ; make sure the carry flag is clear
SBC #$01        ; A = A + 1
STA $0204       ; save sprite X position

LDA $0208       ; load sprite1 X position
SEC             ; make sure the carry flag is clear
SBC #$01        ; A = A + 1
STA $0208       ; save sprite X position

LDA $020C       ; load sprite1 X position
SEC             ; make sure the carry flag is clear
SBC #$01        ; A = A + 1
STA $020C       ; save sprite X position

LDA $0210       ; load sprite1 X position
SEC             ; make sure the carry flag is clear
SBC #$01        ; A = A + 1
STA $0210       ; save sprite X position

LDA $0214       ; load sprite1 X position
SEC             ; make sure the carry flag is clear
SBC #$01        ; A = A + 1
STA $0214       ; save sprite X position

LDA $0218       ; load sprite1 X position
SEC             ; make sure the carry flag is clear
SBC #$01        ; A = A + 1
STA $0218       ; save sprite X position

LDA $021C       ; load sprite1 X position
SEC             ; make sure the carry flag is clear
SBC #$01        ; A = A + 1
STA $021C       ; save sprite X position



ReadUpDone:

down:
LDA $4016       ; player 1 - B
AND #%00000001  ; only look at bit 0
BEQ downdone   ; branch to ReadBDone if button is NOT pressed (0)

LDA $0200       ; load sprite1 X position
CLC             ; make sure the carry flag is clear
ADC #$01        ; A = A + 1
STA $0200       ; save sprite X position

LDA $0204       ; load sprite1 X position
CLC            ; make sure the carry flag is clear
ADC #$01        ; A = A + 1
STA $0204       ; save sprite X position

LDA $0208       ; load sprite1 X position
CLC             ; make sure the carry flag is clear
ADC #$01        ; A = A + 1
STA $0208       ; save sprite X position

LDA $020C       ; load sprite1 X position
CLC             ; make sure the carry flag is clear
ADC #$01        ; A = A + 1
STA $020C       ; save sprite X position

LDA $0210       ; load sprite1 X position
CLC             ; make sure the carry flag is clear
ADC #$01        ; A = A + 1
STA $0210       ; save sprite X position

LDA $0214       ; load sprite1 X position
CLC             ; make sure the carry flag is clear
ADC #$01        ; A = A + 1
STA $0214       ; save sprite X position

LDA $0218       ; load sprite1 X position
CLC             ; make sure the carry flag is clear
ADC #$01        ; A = A + 1
STA $0218       ; save sprite X position

LDA $021C       ; load sprite1 X position
CLC             ; make sure the carry flag is clear
ADC #$01        ; A = A + 1
STA $021C       ; save sprite X position




downdone:

left:
LDA $4016       ; player 1 - B
AND #%00000001  ; only look at bit 0
BEQ leftdone   ; branch to ReadBDone if button is NOT pressed (0) 



LDA $0203       ; load sprite1 X position
SEC             ; make sure the carry flag is clear
SBC #$01        ; A = A + 1
STA $0203       ; save sprite X position

LDA $0207       ; load sprite1 X position
SEC             ; make sure the carry flag is clear
SBC #$01        ; A = A + 1
STA $0207       ; save sprite X position

LDA $020B       ; load sprite1 X position
SEC             ; make sure the carry flag is clear
SBC #$01        ; A = A + 1
STA $020B       ; save sprite X position

LDA $020F       ; load sprite1 X position
SEC             ; make sure the carry flag is clear
SBC #$01        ; A = A + 1
STA $020F       ; save sprite X position

LDA $0213       ; load sprite1 X position
SEC             ; make sure the carry flag is clear
SBC #$01        ; A = A + 1
STA $0213       ; save sprite X position

LDA $0217       ; load sprite1 X position
SEC             ; make sure the carry flag is clear
SBC #$01        ; A = A + 1
STA $0217       ; save sprite X position

LDA $021B       ; load sprite1 X position
SEC             ; make sure the carry flag is clear
SBC #$01        ; A = A + 1
STA $021B       ; save sprite X position

LDA $021F       ; load sprite1 X position
SEC             ; make sure the carry flag is clear
SBC #$01        ; A = A + 1
STA $021F       ; save sprite X position

leftdone:

right:

LDA $4016       ; player 1 - B
AND #%00000001  ; only look at bit 0
BEQ rightdone  ; branch to ReadBDone if button is NOT pressed (0)

LDA $0203       ; load sprite1 X position
CLC             ; make sure the carry flag is clear
ADC #$01        ; A = A + 1
STA $0203       ; save sprite X position

LDA $0207       ; load sprite1 X position
CLC            ; make sure the carry flag is clear
ADC #$01        ; A = A + 1
STA $0207       ; save sprite X position

LDA $020B       ; load sprite1 X position
CLC             ; make sure the carry flag is clear
ADC #$01        ; A = A + 1
STA $020B       ; save sprite X position

LDA $020F       ; load sprite1 X position
CLC             ; make sure the carry flag is clear
ADC #$01        ; A = A + 1
STA $020F       ; save sprite X position

LDA $0213       ; load sprite1 X position
CLC             ; make sure the carry flag is clear
ADC #$01        ; A = A + 1
STA $0213       ; save sprite X position

LDA $0217       ; load sprite1 X position
CLC             ; make sure the carry flag is clear
ADC #$01        ; A = A + 1
STA $0217       ; save sprite X position

LDA $021B       ; load sprite1 X position
CLC             ; make sure the carry flag is clear
ADC #$01        ; A = A + 1
STA $021B       ; save sprite X position

LDA $021F       ; load sprite1 X position
CLC             ; make sure the carry flag is clear
ADC #$01        ; A = A + 1
STA $021F       ; save sprite X position

rightdone:





;end of controller ========================================================================================











PhysicsEngine:
;top road barrier
  LDA $0200        ; Load sprite Y position
  CMP #$7E         ; Check if at ground level
  BCS NoMove       ; If at or below ground, stop

    ; Move sprite down by 1
  CLC
  ADC #$01
  STA $0200        ; Store updated Y position

  LDA $0204        ; Load sprite Y position
  CMP #$7E         ; Check if at ground level
  BCS NoMove       ; If at or below ground, stop

    ; Move sprite down by 1
  CLC
  ADC #$01
  STA $0204        ; Store updated Y position  


  LDA $0208        ; Load sprite Y position
  CMP #$7E         ; Check if at ground level
  BCS NoMove       ; If at or below ground, stop

    ; Move sprite down by 1
  CLC
  ADC #$01
  STA $0208        ; Store updated Y position  


  LDA $020C        ; Load sprite Y position
  CMP #$7E         ; Check if at ground level
  BCS NoMove       ; If at or below ground, stop

    ; Move sprite down by 1
  CLC
  ADC #$01
  STA $020C        ; Store updated Y position    


  LDA $0210        ; Load sprite Y position
  CMP #$86         ; Check if at ground level
  BCS NoMove       ; If at or below ground, stop

    ; Move sprite down by 1
  CLC
  ADC #$01
  STA $0210        ; Store updated Y position    

  LDA $0214        ; Load sprite Y position
  CMP #$86         ; Check if at ground level
  BCS NoMove       ; If at or below ground, stop

    ; Move sprite down by 1
  CLC
  ADC #$01
  STA $0214        ; Store updated Y position  


  LDA $0218        ; Load sprite Y position
  CMP #$86         ; Check if at ground level
  BCS NoMove       ; If at or below ground, stop

    ; Move sprite down by 1
  CLC
  ADC #$01
  STA $0218        ; Store updated Y position    

  LDA $021C        ; Load sprite Y position
  CMP #$86         ; Check if at ground level
  BCS NoMove       ; If at or below ground, stop

    ; Move sprite down by 1
  CLC
  ADC #$01
  STA $021C        ; Store updated Y position    






NoMove:




;bottom road barrier

LDA $021C        ; Load sprite Y position
CMP #$AC         ; Check if at ground level
BCC NoMoveBottom       ; If at or below ground, stop

    ; Move sprite down by 1
SEC
SBC #$01
STA $021C        ; Store updated Y position

LDA $0218        ; Load sprite Y position
CMP #$AC         ; Check if at ground level
BCC NoMoveBottom       ; If at or below ground, stop

    ; Move sprite down by 1
SEC
SBC #$01
STA $0218        ; Store updated Y position


LDA $0214        ; Load sprite Y position
CMP #$AC         ; Check if at ground level
BCC NoMoveBottom       ; If at or below ground, stop

    ; Move sprite down by 1
SEC
SBC #$01
STA $0214        ; Store updated Y position

LDA $0210        ; Load sprite Y position
CMP #$AC         ; Check if at ground level
BCC NoMoveBottom       ; If at or below ground, stop

    ; Move sprite down by 1
SEC
SBC #$01
STA $0210        ; Store updated Y position

LDA $020C        ; Load sprite Y position
CMP #$A4         ; Check if at ground level
BCC NoMoveBottom       ; If at or below ground, stop

    ; Move sprite down by 1
SEC
SBC #$01
STA $020C        ; Store updated Y position

LDA $0208        ; Load sprite Y position
CMP #$A4         ; Check if at ground level
BCC NoMoveBottom       ; If at or below ground, stop

    ; Move sprite down by 1
SEC
SBC #$01
STA $0208        ; Store updated Y position

LDA $0204        ; Load sprite Y position
CMP #$A4         ; Check if at ground level
BCC NoMoveBottom       ; If at or below ground, stop

    ; Move sprite down by 1
SEC
SBC #$01
STA $0204        ; Store updated Y position

LDA $0200        ; Load sprite Y position
CMP #$A4         ; Check if at ground level
BCC NoMoveBottom       ; If at or below ground, stop

    ; Move sprite down by 1
SEC
SBC #$01
STA $0200        ; Store updated Y position


NoMoveBottom:




;=========================== Moving BG 


;road lines that move

LDA $0223 
CLC
ADC #$03
STA $0223

LDA $0227 
CLC
ADC #$03
STA $0227

LDA $022B 
CLC
ADC #$03
STA $022B

LDA $022F 
CLC
ADC #$03
STA $022F

;grass

LDA $0233
CLC
ADC #$03
STA $0233

LDA $0237
CLC
ADC #$03
STA $0237

LDA $023B
CLC
ADC #$03
STA $023B

LDA $023F
CLC
ADC #$03
STA $023F

LDA $0243
CLC
ADC #$03
STA $0243

LDA $0247
CLC
ADC #$03
STA $0247

LDA $024B
CLC
ADC #$03
STA $024B

LDA $024F
CLC
ADC #$03
STA $024F

; Mountains

LDA $0253
CLC
ADC #$01
STA $0253

LDA $0257
CLC
ADC #$01
STA $0257

LDA $025B
CLC
ADC #$01
STA $025B

LDA $025F
CLC
ADC #$01
STA $025F



LDA $0263
CLC
ADC #$01
STA $0263

LDA $0267
CLC
ADC #$01
STA $0267

LDA $026B
CLC
ADC #$01
STA $026B

LDA $026F
CLC
ADC #$01
STA $026F



LDA $0273
CLC
ADC #$01
STA $0273

LDA $0277
CLC
ADC #$01
STA $0277

LDA $027B
CLC
ADC #$01
STA $027B

LDA $027F
CLC
ADC #$01
STA $027F

;enemy1
LDA $0283 
CLC
ADC #$01
STA $0283

LDA $0287
CLC
ADC #$01
STA $0287

LDA $028B
CLC
ADC #$01
STA $028B

LDA $028F
CLC
ADC #$01
STA $028F

;enemy2
LDA $0293
CLC
ADC #$02
STA $0293

LDA $0297
CLC
ADC #$02
STA $0297

LDA $029B
CLC
ADC #$02
STA $029B

LDA $029F
CLC
ADC #$02
STA $029F




Check_Collision:

  LDA Sprite1_X
  CLC
  ADC #8 
  CMP Sprite2_X
  BCC NoCollision

  LDA Sprite2_X
  CLC
  ADC #8 
  CMP Sprite1_X
  BCC NoCollision

  LDA Sprite1_Y
  CLC
  ADC #8 
  CMP Sprite2_Y
  BCC NoCollision

  LDA Sprite2_Y
  CLC
  ADC #8 
  CMP Sprite1_Y
  BCC NoCollision

  JMP CollisionDetected

NoCollision:



CheckOtherCollision:

  LDA Sprite1_X
  CLC
  ADC #8 
  CMP Sprite3_X
  BCC NoCollision2

  LDA Sprite3_X
  CLC
  ADC #8 
  CMP Sprite1_X
  BCC NoCollision2

  LDA Sprite1_Y
  CLC
  ADC #8 
  CMP Sprite3_Y
  BCC NoCollision2

  LDA Sprite3_Y
  CLC
  ADC #8 
  CMP Sprite1_Y
  BCC NoCollision2

  JMP CollisionDetected

NoCollision2:



CheckOtherCollision2:

  LDA Player1SpriteTwo_X
  CLC
  ADC #8 
  CMP Sprite2_X
  BCC NoCollision2x

  LDA Sprite2_X
  CLC
  ADC #8 
  CMP Player1SpriteTwo_X
  BCC NoCollision2x

  LDA Player1SpriteTwo_Y
  CLC
  ADC #8 
  CMP Sprite2_Y
  BCC NoCollision2x

  LDA Sprite2_Y
  CLC
  ADC #8 
  CMP Player1SpriteTwo_Y
  BCC NoCollision2x

  JMP CollisionDetected

NoCollision2x:





heckOtherCollision2x:

  LDA Player1SpriteTwo_X
  CLC
  ADC #8 
  CMP Sprite3_X
  BCC NoCollision2xx

  LDA Sprite3_X
  CLC
  ADC #8 
  CMP Player1SpriteTwo_X
  BCC NoCollision2xx

  LDA Player1SpriteTwo_Y
  CLC
  ADC #8 
  CMP Sprite3_Y
  BCC NoCollision2xx

  LDA Sprite3_Y
  CLC
  ADC #8 
  CMP Player1SpriteTwo_Y
  BCC NoCollision2xx

  JMP CollisionDetected

NoCollision2xx:








heckOtherCollision2xx:

  LDA Player1SpriteTwo_X
  CLC
  ADC #8 
  CMP HoleSprite_X
  BCC NoCollision2xxx

  LDA HoleSprite_X
  CLC
  ADC #8 
  CMP Player1SpriteTwo_X
  BCC NoCollision2xxx

  LDA Player1SpriteTwo_Y
  CLC
  ADC #8 
  CMP HoleSprite_Y
  BCC NoCollision2xxx

  LDA HoleSprite_Y
  CLC
  ADC #8 
  CMP Player1SpriteTwo_Y
  BCC NoCollision2xxx

  JMP CollisionDetected

NoCollision2xxx:






RTI             ; return from interrupt









CollisionDetected: 


LDA $202
CLC
ADC #$05
STA $202



  LDA #$3F
  STA $2006
  LDA #$00
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$16         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette

  LDA #$02
  STA GameState




movingBG:
;road lines that move

LDA $0223 
CLC
ADC #$03
STA $0223

LDA $0227 
CLC
ADC #$03
STA $0227

LDA $022B 
CLC
ADC #$03
STA $022B

LDA $022F 
CLC
ADC #$03
STA $022F

;grass

LDA $0233
CLC
ADC #$03
STA $0233

LDA $0237
CLC
ADC #$03
STA $0237

LDA $023B
CLC
ADC #$03
STA $023B

LDA $023F
CLC
ADC #$03
STA $023F

LDA $0243
CLC
ADC #$03
STA $0243

LDA $0247
CLC
ADC #$03
STA $0247

LDA $024B
CLC
ADC #$03
STA $024B

LDA $024F
CLC
ADC #$03
STA $024F

; Mountains

LDA $0253
CLC
ADC #$01
STA $0253

LDA $0257
CLC
ADC #$01
STA $0257

LDA $025B
CLC
ADC #$01
STA $025B

LDA $025F
CLC
ADC #$01
STA $025F



LDA $0263
CLC
ADC #$01
STA $0263

LDA $0267
CLC
ADC #$01
STA $0267

LDA $026B
CLC
ADC #$01
STA $026B

LDA $026F
CLC
ADC #$01
STA $026F



LDA $0273
CLC
ADC #$01
STA $0273

LDA $0277
CLC
ADC #$01
STA $0277

LDA $027B
CLC
ADC #$01
STA $027B

LDA $027F
CLC
ADC #$01
STA $027F

;enemy1
LDA $0283 
CLC
ADC #$01
STA $0283

LDA $0287
CLC
ADC #$01
STA $0287

LDA $028B
CLC
ADC #$01
STA $028B

LDA $028F
CLC
ADC #$01
STA $028F

;enemy2
LDA $0293
CLC
ADC #$02
STA $0293

LDA $0297
CLC
ADC #$02
STA $0297

LDA $029B
CLC
ADC #$02
STA $029B

LDA $029F
CLC
ADC #$02
STA $029F




RTS







StartTimerX2:
    ; Increment frame delay counter
    LDA FrameDelayCounterX2
    CLC
    ADC #1
    STA FrameDelayCounterX2

    CMP #$EC             ; wait ~32 frames (adjust as needed)
    BNE SkipTimerIncX2     ; not yet time to increment

    ; Reset frame delay
    LDA #$00
    STA FrameDelayCounterX2

    ; Load current timer value
    LDA TimerCounterX2
    CMP #$08
    BEQ TimerDoneX2        ; If timer == 9, jump to done routine

    ; Increment timer
    CLC
    ADC #$01
    STA TimerCounterX2


SkipTimerIncX2:
    RTS

TimerDoneX2:
    ; Call your subroutine here
    JSR TimerReachedNineX2
    RTS


TimerReachedNineX2:



LDA #$89
STA $0230

LDA #$12
STA $0231

LDA #$02
STA $0232

RTS









StartTimerX:
    ; Increment frame delay counter
    LDA FrameDelayCounterX
    CLC
    ADC #1
    STA FrameDelayCounterX

    CMP #$70             ; wait ~32 frames (adjust as needed)
    BNE SkipTimerIncX     ; not yet time to increment

    ; Reset frame delay
    LDA #$00
    STA FrameDelayCounterX

    ; Load current timer value
    LDA TimerCounterX
    CMP #$20
    BEQ TimerDoneX        ; If timer == 9, jump to done routine

    ; Increment timer
    CLC
    ADC #$01
    STA TimerCounterX

    LDA $02EB
    CLC
    ADC #$01
    STA $02EB


SkipTimerIncX:
    RTS

TimerDoneX:
    ; Call your subroutine here
    JSR TimerReachedNineX
    RTS


TimerReachedNineX:


RTS











StartTimer:
    ; Increment frame delay counter
    LDA FrameDelayCounter
    CLC
    ADC #1
    STA FrameDelayCounter

    CMP #$10             ; wait ~32 frames (adjust as needed)
    BNE SkipTimerInc     ; not yet time to increment

    ; Reset frame delay
    LDA #$00
    STA FrameDelayCounter

    ; Load current timer value
    LDA TimerCounter
    CMP #$09
    BEQ TimerDone        ; If timer == 9, jump to done routine

    ; Increment timer
    CLC
    ADC #1
    STA TimerCounter
    STA $02E5            ; update timer sprite with new value ;1 5 9 D
 



SkipTimerInc:
    RTS

TimerDone:
    ; Call your subroutine here
    JSR TimerReachedNine
    RTS


TimerReachedNine:

JSR youwin


RTS




StartTimer2:
    ; Increment frame delay counter
    LDA FrameDelayCounter2
    CLC
    ADC #1
    STA FrameDelayCounter2

    CMP #$20             ; wait ~32 frames (adjust as needed)
    BNE SkipTimerInc     ; not yet time to increment

    ; Reset frame delay
    LDA #$00
    STA FrameDelayCounter2

    ; Load current timer value
    LDA TimerCounter2
    CMP #$08
    BEQ TimerDone2        ; If timer == 9, jump to done routine

    ; Increment timer
    CLC
    ADC #1
    STA TimerCounter2
    

SkipTimerInc2:
    RTS

TimerDone2:
    ; Call your subroutine here
    JSR TimerReachedNine2
    RTS

TimerReachedNine2:

LDA $0280 
CLC
ADC #$01
STA $0280

LDA $0284
CLC
ADC #$01
STA $0284

LDA $0288
CLC
ADC #$01
STA $0288

LDA $028C
CLC
ADC #$01
STA $028C

RTS






StartTimer3:
    ; Increment frame delay counter
    LDA FrameDelayCounter3
    CLC
    ADC #1
    STA FrameDelayCounter3

    CMP #$20             ; wait ~32 frames (adjust as needed)
    BNE SkipTimerInc     ; not yet time to increment

    ; Reset frame delay
    LDA #$00
    STA FrameDelayCounter3

    ; Load current timer value
    LDA TimerCounter3
    CMP #$02
    BEQ TimerDone3        ; If timer == 9, jump to done routine

    ; Increment timer
    CLC
    ADC #1
    STA TimerCounter3
    

SkipTimerInc3:
    RTS

TimerDone3:
    ; Call your subroutine here
    JSR TimerReachedNine3
    RTS

TimerReachedNine3:

LDA $0280 
SEC
SBC #$02
STA $0280

LDA $0284
SEC
SBC #$02
STA $0284

LDA $0288
SEC
SBC #$02
STA $0288

LDA $028C
SEC
SBC #$02
STA $028C


;car2

LDA $0293
SEC
SBC #$03
STA $0293

LDA $0297
SEC
SBC #$03
STA $0297

LDA $029B
SEC
SBC #$03
STA $029B

LDA $029F
SEC
SBC #$03
STA $029F

LDA #$00

STA TimerCounter3

RTS


youwin:





LDA #$30
STA $0230
LDA #$50
STA $0233

LDA #$58
STA $0237
LDA #$30
STA $0234

LDA #$68
STA $023B
LDA #$30
STA $0238

LDA #$70
STA $023F
LDA #$30
STA $023C

;index
LDA #$24
STA $0231

LDA #$25
STA $0235

LDA #$26
STA $0239

LDA #$27
STA $023D

LDA #%00011110
STA $2001

;color

LDA #$02
STA $0232

LDA #$02
STA $0236

LDA #$02
STA $023A

LDA #$02
STA $023E




    ; Enable Sound channel
    lda #%00000001
    sta $4015           ; Enable Square 1 channel, disable others

    lda #%00010110
    sta $4015           ; Enable Square 2, Triangle, and DMC channels. Disable Square 1 and Noise.

    lda #$0F
    sta $4015           ; Enable Square 1, Square 2, Triangle, and Noise channels. Disable DMC.

    lda #%00000111      ; Enable Square 1, Square 2, and Triangle channels
    sta $4015


    ; Square 2 (E note)
    lda #%01110110      ; Duty 01, Volume 6
    sta $4004
    lda #$A9            ; $0A9 is an E in NTSC mode
    sta $4006
    lda #$00
    sta $4007

    ; Triangle (G# note)
    lda #%10000001      ; Triangle channel on
    sta $4008
    lda #$42            ; $042 is a G# in NTSC mode
    sta $400A
    lda #$00
    sta $400B



DelayLoopX1x:
  LDX #$Fb            ; Outer loop for a longer delay   
DelayLoopOuterX1x:
  LDY #$Fb            ; Inner loop
DelayLoopInnerX1x:
  DEY
  BNE DelayLoopInnerX1x  ; Repeat inner loop until Y = 0
  DEX
  BNE DelayLoopOuterX1x  ; Repeat outer loop until X = 0

;Stops sound
  LDA #$00
  STA $4015










LDA #2
STA GameState

JMP theend

RTI

theend:

BRK
JMP theend

background:
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 1
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 1
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 1
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 1
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 5
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 6
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 1
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 1
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 1
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 1
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 1
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 1
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1

  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1

  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1

  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1

  .byte $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48  ;;row 17
  .byte $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48  ;;all sky

  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26  ;;row 19
  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26  ;;row 19

  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26  ;;row 19
  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26  ;;row 19

  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26  ;;row 19
  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26  ;;row 19

  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26  ;;row 19
  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26  ;;row 19

  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26  ;;row 19
  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26  ;;row 19

  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26  ;;row 19
  .byte $26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26  ;;row 19

  .byte $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48  ;;row 17
  .byte $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48  ;;all sky

  .byte $D0,$D1,$D1,$D1,$D1,$D1,$D1,$D1,$D1,$D1,$D1,$D1,$D1,$D1,$D1,$D1  ;;row 1
  .byte $D1,$D1,$D1,$D1,$D1,$D1,$D1,$D1,$D1,$D1,$D1,$D1,$D1,$D1,$D1,$D2  ;;row 1

  .byte $E0,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$E2  ;;row 1

  .byte $E0,$25,$25,$D3,$E4,$25,$D4,$D5,$D6,$D7,$D9,$25,$25,$25,$DE,$DF  ;;row 1
  .byte $25,$25,$E3,$E3,$E3,$25,$25,$25,$25,$CF,$CC,$CD,$25,$25,$25,$E2  ;;row 1

  .byte $E0,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$E2  ;;row 1

  .byte $F0,$F1,$F1,$F1,$F1,$F1,$F1,$F1,$F1,$F1,$F1,$F1,$F1,$F1,$F1,$F1  ;;row 1
  .byte $F1,$F1,$F1,$F1,$F1,$F1,$F1,$F1,$F1,$F1,$F1,$F1,$F1,$F1,$F1,$F2  ;;row 1

  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25  ;;row 1




attributes:  ;8 x 8 = 64 bytes
  .byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
  .byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
  .byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
  .byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
  .byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
  .byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
  .byte %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
  .byte %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111


  .byte $24,$24,$24,$24, $47,$47,$24,$24 
  .byte $47,$47,$47,$47, $47,$47,$24,$24 
  .byte $24,$24,$24,$24 ,$24,$24,$24,$24
  .byte $24,$24,$24,$24, $55,$56,$24,$24  ;;brick bottoms
  .byte $47,$47,$47,$47, $47,$47,$24,$24 
  .byte $24,$24,$24,$24 ,$24,$24,$24,$24
  .byte $24,$24,$24,$24, $55,$56,$24,$24 



palette:
  .byte $22,$1A,$2D,$17,  $0F,$36,$17,$0F,  $22,$30,$21,$0F,  $22,$0F,$04,$2B   ;;background palette
  .byte $22,$21,$3E,$18,  $22,$1B,$29,$0B,  $22,$3E,$16,$3D,  $22,$27,$0F,$38   ;;sprite palette

sprites:
     ;vert tile attr horiz
     ;y, index, attribute, x
  .byte $80, $20, $02, $80   ;player one car
  .byte $80, $21, $02, $88   ;
  .byte $80, $22, $02, $8F   ;
  .byte $80, $23, $02, $97   ;
  .byte $88, $30, $02, $80   ;
  .byte $88, $31, $02, $88   ;
  .byte $88, $32, $02, $8F   ;
  .byte $88, $33, $02, $97   ;

  .byte $99, $2E, $03, $10   ; road lines
  .byte $99, $2E, $03, $50   ; 
  .byte $99, $2E, $03, $90   ;
  .byte $99, $2E, $03, $D0   ;  


  .byte $73, $0C, $01, $10   ; grass
  .byte $73, $0D, $01, $1A   ;

  .byte $73, $0C, $01, $30   ; 
  .byte $73, $0C, $01, $50   ;

  .byte $73, $0C, $01, $80   ;

  .byte $73, $0C, $01, $A0   ;
  .byte $73, $0D, $01, $AB   ;  

  .byte $73, $0C, $01, $DE   ;    


  .byte $55, $0A, $01, $10   ;  mountain 1 - base
  .byte $55, $10, $01, $17   ;    
  .byte $55, $10, $01, $1F   ;    
  .byte $55, $0A, $71, $27   ;      

  .byte $55, $0A, $01, $80   ;  mountain 2 - base
  .byte $55, $10, $01, $87   ;    
  .byte $55, $10, $01, $8F   ;    
  .byte $55, $0A, $71, $97   ;      


  .byte $4D, $0B, $01, $18   ;  mountain 1 - top
  .byte $4D, $0B, $71, $1F   ;    
      
  .byte $4D, $0B, $01, $88   ;  mountain 2 - top
  .byte $4D, $0B, $71, $8F   ;    


  .byte $85, $0E, $03, $20   ;  enemy car
  .byte $85, $0F, $03, $28   ;        
  .byte $8D, $1E, $03, $20   ; 
  .byte $8D, $1F, $03, $28   ;       

  .byte $A0, $0E, $00, $90   ;  enemy car2
  .byte $A0, $0F, $00, $98   ;        
  .byte $A8, $1E, $00, $90   ; 
  .byte $A8, $1F, $00, $98   ;      

  .byte $CC, $FC, $02, $60   ;        


  .byte $30, $88, $02, $40   ;  Cool race  
  .byte $30, $89, $02, $50   ;    
  .byte $30, $89, $02, $60   ;  
  .byte $30, $8A, $02, $70   ;       
  .byte $30, $8B, $02, $90   ;
  .byte $30, $8C, $02, $A0   ;   
  .byte $30, $88, $02, $B0   ;  C    
  .byte $30, $8D, $02, $C0   ;   


  .byte $40, $98, $03, $50   ;      press A 
  .byte $40, $99, $03, $58   ;
  .byte $40, $9A, $03, $64   ;

  .byte $40, $9B, $03, $90   ; vedran 2025
  .byte $40, $9C, $03, $98   ;
  .byte $40, $9D, $03, $A0   ;
  .byte $40, $8E, $03, $A9   ;
  .byte $40, $8F, $03, $B1   ;

  .byte $CE, $B1, $03, $80   ; timer

  .byte $CC, $43, $02, $AB   ; car icon


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.segment "VECTORS"
    .word VBLANK 
    .word RESET 
    .word 0
.segment "CHARS"
    .incbin "mario.chr"
