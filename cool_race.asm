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


    TimerCounter33:      .res 1    ; current timer value (0 to 9)
    FrameDelayCounter33: .res 1    ; how many frames to wait before incrementing timer 
    

    TimerCounterPause: .res 1
    FrameDelayCounterPause: .res 1

    TimerCounter_EnemyAiGoUp: .res 1
    FrameDelay_EnemyAiGoUp: .res 1

    TimerCounter_EnemyAiGodown: .res 1
    FrameDelay_EnemyAiGodown: .res 1

    Nopothole: .res 1

    levelcounter: .res 1

    CarGoUpDown: .res 1

    BeatLevel2: .res 1

.segment "CODE"



TitleScreen = $00
PlayingGame = $01 
GameOver = $02
Resetting = $03

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

CarEngineSound = $34

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
 STA TimerCounter  
   STA FrameDelayCounter 
    STA TimerCounter2      
   STA FrameDelayCounter2 
  STA  TimerCounter3      
 STA   FrameDelayCounter3 
 STA   TimerCounterX     
   STA FrameDelayCounterX 
STA    TimerCounterX2      
   STA FrameDelayCounterX2

  STA  TimerCounterPause 
   STA FrameDelayCounterPause 

 STA   TimerCounter_EnemyAiGoUp 
   STA FrameDelay_EnemyAiGoUp 

  STA  TimerCounter_EnemyAiGodown 
   STA FrameDelay_EnemyAiGodown 

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

JSR StartTimer33

RTS

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

LDA BeatLevel2
CMP #$01
BEQ Beatlevel2

JSR StartTimer2
JSR StartTimer3
JSR StartTimerX
JSR StartTimerX2
;JSR StartTimerPause
Beatlevel2:

LDA BeatLevel2
CMP #$00
BEQ HaveNotBeatenLevel2


LDA CarGoUpDown
CMP #$00
BNE cardonegoingdown

JSR StartTimerAIdown
cardonegoingdown:

LDA CarGoUpDown
CMP #$01
BNE cardonegoingup
JSR StartTimerAI

cardonegoingup:

HaveNotBeatenLevel2:
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

  LDA #$1D
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



; Enable Sound channel
    lda #%00000001
    sta $4015           ; Enable Square 1 channel, disable others

    lda #%00010110
    sta $4015           ; Enable Square 2, Triangle, and DMC channels. Disable Square 1 and Noise.

    lda #$0F
    sta $4015           ; Enable Square 1, Square 2, Triangle, and Noise channels. Disable DMC.

    lda #%00000111      ; Enable Square 1, Square 2, and Triangle channels
    sta $4015

    ; Play C#m chord
    ; Square 1 (C# note)
    lda #%00111000      ; Duty 00, Volume 8 (half volume)
    sta $4000
    lda #$C9            ; $0C9 is a C# in NTSC mode
    sta $4002           ; Low 8 bits of period
    lda #$00
    sta $4003           ; High 3 bits of period

    ; Square 2 (E note)
    lda #%01110110      ; Duty 01, Volume 6
    sta $4004
    lda #$A9            ; $0A9 is an E in NTSC mode
    sta $4006
    lda #$00
    sta $4007


    


        ; Delay loop (adjust for the desired delay duration)
DelayLoop20:
    ldx #$4F            ; Outer loop for a longer delay   
DelayLoopOuter20:
    ldy #$40            ; Inner loop
DelayLoopInner20:
    dey
    bne DelayLoopInner20  ; Repeat inner loop until Y = 0
    dex
    bne DelayLoopOuter20  ; Repeat outer loop until X = 0
    

    ; Stop sound after the delay
    lda #$00
    sta $4015           ; Disable all sound channels








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

;JSR StartTimerAI





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

;JSR StartTimerAIdown


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


;car engine sound
  ; Enable the noise channel
    lda #%00001000       ; Bit 3 set = enable noise channel
    sta $4015

    ; Configure Noise Channel Envelope
    lda #CarEngineSound       ; Volume 4, Envelope disabled, decay rate fast
                         ; Bit 7 = 0 (disable envelope)
                         ; Bit 6 = 1 (constant volume)
                         ; Bit 5-0 = 4 (volume)
    sta $400C            ; Write to Noise Envelope/Volume register

    ; Configure Noise Frequency
    lda #%00100000       ; Frequency index = $23 (higher frequency for sharpness)
                         ; Bit 7 = 0 (non-looping random noise)
                         ; Bits 4-0 = $23 (frequency index)
    sta $400E            ; Write to Noise Period register

    ; Restart the length counter
    lda #%00001000       ; Load length counter (short duration)
    sta $400F            ; Writing to $400F also resets envelope and length counter










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












;left screen road barrier


  LDA $0213        ; Load sprite X position
  CMP #$01         ; Check if at left side of screen
  BCS NoMoveLeft      

    ; Move sprite right by 1
  CLC
  ADC #$01
  STA $0213        ; Store updated X position  

  LDA $0203        ; Load sprite X position
  CMP #$01         ; Check if at left side of screen
  BCS NoMoveLeft      

    ; Move sprite right by 1
  CLC
  ADC #$01
  STA $0203        ; Store updated X position

  LDA $0207        ; Load sprite X position
  CMP #$09         ; Check if at left side of screen
  BCS NoMoveLeft      

    ; Move sprite right by 1
  CLC
  ADC #$01
  STA $0207        ; Store updated X position  




  LDA $0217        ; Load sprite X position
  CMP #$09         ; Check if at left side of screen
  BCS NoMoveLeft      

    ; Move sprite right by 1
  CLC
  ADC #$01
  STA $0217        ; Store updated X position  




  LDA $020B        ; Load sprite X position
  CMP #$11         ; Check if at left side of screen
  BCS NoMoveLeft      

    ; Move sprite right by 1
  CLC
  ADC #$01
  STA $020B        ; Store updated X position  






  LDA $021B        ; Load sprite X position
  CMP #$11         ; Check if at left side of screen
  BCS NoMoveLeft      

    ; Move sprite right by 1
  CLC
  ADC #$01
  STA $021B        ; Store updated X position  





  LDA $020F        ; Load sprite X position
  CMP #$19         ; Check if at left side of screen
  BCS NoMoveLeft      

    ; Move sprite right by 1
  CLC
  ADC #$01
  STA $020F        ; Store updated X position  



  LDA $021F        ; Load sprite X position
  CMP #$19         ; Check if at left side of screen
  BCS NoMoveLeft      

    ; Move sprite right by 1
  CLC
  ADC #$01
  STA $021F        ; Store updated X position  








NoMoveLeft:









LDA $020F        ; Load sprite Y position
CMP #$F9         ; Check if at ground level
BCC NoMoveRight       ; If at or below ground, stop

    ; Move sprite down by 1
SEC
SBC #$01
STA $020F        ; Store updated Y position





LDA $020B        ; Load sprite Y position
CMP #$F1         ; Check if at ground level
BCC NoMoveRight       ; If at or below ground, stop

    ; Move sprite down by 1
SEC
SBC #$01
STA $020B        ; Store updated Y position






LDA $0207        ; Load sprite Y position
CMP #$EA         ; Check if at ground level
BCC NoMoveRight       ; If at or below ground, stop

    ; Move sprite down by 1
SEC
SBC #$01
STA $0207        ; Store updated Y position




LDA $0203        ; Load sprite Y position
CMP #$E2         ; Check if at ground level
BCC NoMoveRight       ; If at or below ground, stop

    ; Move sprite down by 1
SEC
SBC #$01
STA $0203        ; Store updated Y position


LDA $0213        ; Load sprite Y position
CMP #$E2         ; Check if at ground level
BCC NoMoveRight       ; If at or below ground, stop

    ; Move sprite down by 1
SEC
SBC #$01
STA $0213        ; Store updated Y position





LDA $0217        ; Load sprite Y position
CMP #$EA         ; Check if at ground level
BCC NoMoveRight       ; If at or below ground, stop

    ; Move sprite down by 1
SEC
SBC #$01
STA $0217        ; Store updated Y position




LDA $021B        ; Load sprite Y position
CMP #$F1         ; Check if at ground level
BCC NoMoveRight       ; If at or below ground, stop

    ; Move sprite down by 1
SEC
SBC #$01
STA $021B        ; Store updated Y position


LDA $021F        ; Load sprite Y position
CMP #$F9         ; Check if at ground level
BCC NoMoveRight       ; If at or below ground, stop

    ; Move sprite down by 1
SEC
SBC #$01
STA $021F        ; Store updated Y position


NoMoveRight:









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
 LDA #%00000000
 STA $2001        ; disable rendering

JSR CollisionAttribute
JSR attributetablechange

LDA #$02
STA $2005   ; horizontal scroll
STA $2005   ; vertical scroll




    LDA #%00011110
    STA $2001        ; enable rendering again

  LDA #$02
  STA GameState




movingBG: ;this is when you speed up when pushing B
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




CollisionAttribute:

;bg 0 color (sky) 
  LDA #$3F
  STA $2006
  LDA #$00
  STA $2006        

  LDA #$16         
  STA $2007       


;bg 2 color (road) 
  LDA #$3F
  STA $2006
  LDA #$02
  STA $2006        

  LDA #$16         
  STA $2007      

;bg 3 color (curb) 
  LDA #$3F
  STA $2006
  LDA #$03
  STA $2006        

  LDA #$2D         
  STA $2007  


;bg color 5 (water)
  LDA #$3F
  STA $2006
  LDA #$05
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$22         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette


;bg color 1 (ground)
  LDA #$3F
  STA $2006
  LDA #$01
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$06         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette  


;enemycar1 color red
  LDA #$3F
  STA $2006
  LDA #$11
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$06         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette  

;window tint
  LDA #$3F
  STA $2006
  LDA #$13
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$32         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette  

;enemycar2 color 
  LDA #$3F
  STA $2006
  LDA #$1D
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$37         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette    


;enemycar2 color 
  LDA #$3F
  STA $2006
  LDA #$1F
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$3C         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette      


RTS







StartTimerAI: ;makes enemy car 1 go up, use this subroutine in the controller section. when you go up, enemy follows with delay
    ; Increment frame delay counter

    
    LDA FrameDelay_EnemyAiGoUp
    CLC
    ADC #1
    STA FrameDelay_EnemyAiGoUp

    CMP #$02             ; wait ~32 frames (adjust as needed)
    BNE SkipTimerIncAI     ; not yet time to increment

    ; Reset frame delay
    LDA #$00
    STA FrameDelay_EnemyAiGoUp

    ; Load current timer value
    LDA TimerCounter_EnemyAiGoUp
    CMP #$20
    BEQ TimerDoneAI        ; If timer == 9, jump to done routine

    ; Increment timer
    CLC
    ADC #$01
    STA TimerCounter_EnemyAiGoUp


LDA $0280 
SEC
SBC #$01
STA $0280

LDA $0284
SEC
SBC #$01
STA $0284

LDA $0288
SEC
SBC #$01
STA $0288

LDA $028C
SEC
SBC #$01
STA $028C


SkipTimerIncAI:
    RTS

TimerDoneAI:

LDA #$00
STA CarGoUpDown

LDA #$00
STA TimerCounter_EnemyAiGoUp

RTS




StartTimerAIdown: ;makes enemy car go down
    ; Increment frame delay counter

    
    LDA FrameDelay_EnemyAiGodown
    CLC
    ADC #1
    STA FrameDelay_EnemyAiGodown

    CMP #$02             ; wait ~32 frames (adjust as needed)
    BNE SkipTimerIncAIdown     ; not yet time to increment

    ; Reset frame delay
    LDA #$00
    STA FrameDelay_EnemyAiGodown

    ; Load current timer value
    LDA TimerCounter_EnemyAiGodown
    CMP #$20
    BEQ TimerDoneAIdown        ; If timer == 9, jump to done routine

    ; Increment timer
    CLC
    ADC #$01
    STA TimerCounter_EnemyAiGodown

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


SkipTimerIncAIdown:
    RTS

TimerDoneAIdown:

LDA #$01
STA CarGoUpDown

LDA #$00
STA TimerCounter_EnemyAiGodown

RTS








StartTimerPause: ;
    ; Increment frame delay counter

    
    LDA FrameDelayCounterPause
    CLC
    ADC #1
    STA FrameDelayCounterPause

    CMP #$10             ; wait ~32 frames (adjust as needed)
    BNE SkipTimerIncPause     ; not yet time to increment

    ; Reset frame delay
    LDA #$00
    STA FrameDelayCounterPause

    ; Load current timer value
    LDA TimerCounterPause
    CMP #$09
    BEQ TimerDonePause        ; If timer == 9, jump to done routine

    ; Increment timer
    CLC
    ADC #$01
    STA TimerCounterPause


SkipTimerIncPause:
    RTS

TimerDonePause:
    ; Call your subroutine here
    JSR TimerReachedNinePause
    RTS


TimerReachedNinePause:


JSR Bassdrum1


RTS












StartTimerX2: ;this timer makes the pot hole appear
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
;when you reach second level, the pothole disappears
LDA Nopothole
CMP #$01
BEQ NopotholeOnSecondLevel

LDA #$89
STA $0230

LDA #$12
STA $0231

LDA #$02
STA $0232

NopotholeOnSecondLevel:

RTS









StartTimerX: ;this timer moves the car icon right
    ; Increment frame delay counter
    LDA FrameDelayCounterX
    CLC
    ADC #1
    STA FrameDelayCounterX

    CMP #$72             ; wait ~32 frames (adjust as needed)
    BNE SkipTimerIncX     ; not yet time to increment

    ; Reset frame delay
    LDA #$00
    STA FrameDelayCounterX

    ; Load current timer value
    LDA TimerCounterX
    CMP #$F0
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











StartTimer: ;this timer increments km counter
    ; Increment frame delay counter
    LDA FrameDelayCounter
    CLC
    ADC #1
    STA FrameDelayCounter

    CMP #$FF             ; wait ~32 frames (adjust as needed)
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


LDA #$00
STA $02E5
LDA #$00
STA TimerCounter

INC levelcounter

LDA levelcounter
CMP #$01
BEQ SecondLevel

LDA levelcounter
CMP #$02
BEQ Thirdlevel

LDA levelcounter
CMP #$03
BEQ endgame

RTS



SecondLevel:
;Palm Beach level:







LDA #$A8
STA $02EB

LDA #01
STA Nopothole

LDA #$73
STA $0230

LDA #$CB
STA $0231

;LDA #$02
;STA $0232

 LDA #%00000000
    STA $2001        ; disable rendering

JSR palmlevelpalette


JSR attributetablechange
JSR PalmTreeLevel 
JSR desertsprites
JSR NewColorEnemies


LDA #$02
STA $2005   ; horizontal scroll
STA $2005   ; vertical scroll




    LDA #%00011110
    STA $2001        ; enable rendering again
;boat on water
LDA #$55
STA $0264
LDA #$C4
STA $0265
LDA #$02
STA $0266
LDA #$87
STA $0267

RTS

Thirdlevel:
LDA #$A8
STA $02EB
LDA #$01
STA BeatLevel2

JSR TheThirdlevel
RTS

endgame:
LDA #$00
STA $4015           
JSR youwin





StartTimer2: ;this timer moves yellow car down
    ; Increment frame delay counter
    LDA FrameDelayCounter2
    CLC
    ADC #1
    STA FrameDelayCounter2

    CMP #$20             ; wait ~32 frames (adjust as needed)
    BNE SkipTimerInc2     ; not yet time to increment

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
;moves car down
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

;moves car back;
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

RTS






StartTimer3:
    ; Increment frame delay counter
    LDA FrameDelayCounter3
    CLC
    ADC #1
    STA FrameDelayCounter3

    CMP #$20             ; wait ~32 frames (adjust as needed)
    BNE SkipTimerInc3     ; not yet time to increment

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











StartTimer33: ;this is the timer for resetting the game after crashing
    ; Increment frame delay counter
    LDA FrameDelayCounter33
    CLC
    ADC #1
    STA FrameDelayCounter33

    CMP #$12             ; wait ~32 frames (adjust as needed)
    BNE SkipTimerInc33     ; not yet time to increment

    ; Reset frame delay
    LDA #$00
    STA FrameDelayCounter33

    ; Load current timer value
    LDA TimerCounter33
    CMP #$02
    BEQ TimerDone33        ; If timer == 9, jump to done routine

    ; Increment timer
    CLC
    ADC #1
    STA TimerCounter33
    

SkipTimerInc33:
    RTS

TimerDone33:
    ; Call your subroutine here
    JSR TimerReachedNine33
    RTS

TimerReachedNine33:

LDA #$00
STA FrameDelayCounter33
STA TimerCounter33

LDA #$00
STA GameState

JSR ResetTheWholeGame

RTS



















youwin:




;you win text
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






  LDA #$3F
  STA $2006
  LDA #$00
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$2C         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette


LDA #0
STA GameState

JMP theend

RTI

theend:

BRK
JMP theend








loadbackground2:
    LDA $2002
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006

    LDA #<background2
    STA pointerLo
    LDA #>background2
    STA pointerHi

    LDX #$00
    LDY #$00
outsideloop2:
insideloop2:
    LDA (pointerLo),Y
    STA $2007
    INY
    CPY #$00
    BNE insideloop2
    INC pointerHi
    INX
    CPX #$04
    BNE outsideloop2
    RTS




loadpalettes2:
    LDA $2002
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006
    LDX #$00
loadpalettesloop2:
    LDA palette2,X   ; load data from adddress (palette + X)
                        ; 1st time through loop it will load palette+0
                        ; 2nd time through loop it will load palette+1
                        ; 3rd time through loop it will load palette+2
                        ; etc
    STA $2007
    INX 
    CPX #$20
    BNE loadpalettesloop2




; Set PPU address to attribute table (for $2000, it's $23C0)
LDA #$23
STA $2006
LDA #$C0
STA $2006

; Fill attribute table with correct values
LDX #$00
@Loop:
    LDA #$00         ; Use palette 0 for all quadrants (bits 00 00 00 00)
    STA $2007
    INX
    CPX #$40         ; Attribute table is 64 bytes
    BNE @Loop



    RTS


desertsprites:

;grass

;----1st palm tree

;1st sprite
LDA #$CB
STA $0231
LDA #$10
STA $0233

LDA #$03
STA $0232


;2nd sprite
LDA #$6B
STA $0234

LDA #$CB
STA $0235

LDA #$03
STA $0236

LDA #$10
STA $0237 

;3rd sprite
LDA #$63
STA $0238 

LDA #$BB
STA $0239

LDA #$10
STA $023B

;------2nd palm tree
;1st sprite

LDA #$CB
STA $023D

LDA #$03
STA $023E

LDA #$80
STA $023F

;2nd sprite
LDA #$6B
STA $0240

LDA #$CB
STA $0241

LDA #$03
STA $0242

LDA #$80
STA $0243

;3rd sprite
LDA #$63
STA $0244
LDA #$BB
STA $0245
LDA #$80
STA $0247


;-----------3rd palm tree
;1st sprite

LDA #$73
STA $0248
LDA #$BB
STA $0249
LDA #$01
STA $024A
LDA #$50 
STA $024B

;2nd sprite
LDA #$73
STA $024C
LDA #$BB
STA $024D
LDA #$01
STA $024E
LDA #$C0
STA $024F

;3rd sprite



LDA #$C1

STA $0251
STA $0255
STA $0259
STA $025D
STA $0261
STA $0265
STA $0269
STA $026D
STA $0261
STA $0275
STA $0279
STA $027D
STA $0271

RTS
    

attributetablechange:
;car HUD
  LDA #$23 ;$23C0 - 23FF
  STA $2006
  LDA #$F0
  STA $2006        ; Set PPU address to $3F00 (background color)

LDA #$FF
STA $2007

  LDA #$23 ;$23C0 - 23FF
  STA $2006
  LDA #$F1
  STA $2006        ; Set PPU address to $3F00 (background color)

LDA #$FF
STA $2007

  LDA #$23 ;$23C0 - 23FF
  STA $2006
  LDA #$F2
  STA $2006        ; Set PPU address to $3F00 (background color)

LDA #$FF
STA $2007

  LDA #$23 ;$23C0 - 23FF
  STA $2006
  LDA #$F3
  STA $2006        ; Set PPU address to $3F00 (background color)

LDA #$FF
STA $2007

  LDA #$23 ;$23C0 - 23FF
  STA $2006
  LDA #$F4
  STA $2006        ; Set PPU address to $3F00 (background color)

LDA #$FF
STA $2007

  LDA #$23 ;$23C0 - 23FF
  STA $2006
  LDA #$F5
  STA $2006        ; Set PPU address to $3F00 (background color)

LDA #$FF
STA $2007

  LDA #$23 ;$23C0 - 23FF
  STA $2006
  LDA #$F6
  STA $2006        ; Set PPU address to $3F00 (background color)

LDA #$FF
STA $2007

  LDA #$23 ;$23C0 - 23FF
  STA $2006
  LDA #$F7
  STA $2006        ; Set PPU address to $3F00 (background color)

LDA #$FF
STA $2007


;bottom row


  LDA #$23 ;$23C0 - 23FF
  STA $2006
  LDA #$F8
  STA $2006        ; Set PPU address to $3F00 (background color)

LDA #$FF
STA $2007

  LDA #$23 ;$23C0 - 23FF
  STA $2006
  LDA #$F9
  STA $2006        ; Set PPU address to $3F00 (background color)

LDA #$FF
STA $2007

  LDA #$23 ;$23C0 - 23FF
  STA $2006
  LDA #$FA
  STA $2006        ; Set PPU address to $3F00 (background color)

LDA #$FF
STA $2007

  LDA #$23 ;$23C0 - 23FF
  STA $2006
  LDA #$FB
  STA $2006        ; Set PPU address to $3F00 (background color)

LDA #$FF
STA $2007

  LDA #$23 ;$23C0 - 23FF
  STA $2006
  LDA #$FC
  STA $2006        ; Set PPU address to $3F00 (background color)

LDA #$FF
STA $2007

  LDA #$23 ;$23C0 - 23FF
  STA $2006
  LDA #$FD
  STA $2006        ; Set PPU address to $3F00 (background color)

LDA #$FF
STA $2007

  LDA #$23 ;$23C0 - 23FF
  STA $2006
  LDA #$FE
  STA $2006        ; Set PPU address to $3F00 (background color)

LDA #$FF
STA $2007

  LDA #$23 ;$23C0 - 23FF
  STA $2006
  LDA #$FF
  STA $2006        ; Set PPU address to $3F00 (background color)

LDA #$FF
STA $2007





RTS


NewColorEnemies:

; car 1
LDA #$00
STA $0282 
STA $0286 

STA $028A
STA $028E

;car2
LDA #$03
STA $0292
STA $0296
STA $029A
STA $029E



RTS

car2speed:
;car2 speed

LDA $0293
SEC
SBC #$01
STA $0293

LDA $0297
SEC
SBC #$01
STA $0297

LDA $029B
SEC
SBC #$01
STA $029B

LDA $029F
SEC
SBC #$01
STA $029F

RTS 





Bassdrum1:


; Enable the noise channel
  LDA #%00001000       ; Bit 3 set = enable noise channel
  STA $4015

; Configure Noise Channel Envelope
  LDA #%00110100       ; Volume 4, Envelope disabled, decay rate fast
                         ; Bit 7 = 0 (disable envelope)
                         ; Bit 6 = 1 (constant volume)
                         ; Bit 5-0 = 4 (volume)
  STA $400C            ; Write to Noise Envelope/Volume register

; Configure Noise Frequency
  LDA #%00100011       ; Frequency index = $23 (higher frequency for sharpness)
                         ; Bit 7 = 0 (non-looping random noise)
                         ; Bits 4-0 = $23 (frequency index)
  STA $400E            ; Write to Noise Period register

; Restart the length counter
  LDA #%00001000       ; Load length counter (short duration)
  STA $400F            ; Writing to $400F also resets envelope and length counter

DelayLoop:
  LDX #$bb            ; Outer loop for a longer delay   
DelayLoopOuter:
  LDY #$bb            ; Inner loop
DelayLoopInner:
  DEY
  BNE DelayLoopInner  ; Repeat inner loop until Y = 0
  DEX
  BNE DelayLoopOuter  ; Repeat outer loop until X = 0

  LDA #$00
  STA $4015

RTS



PalmTreeLevel:
;attribute from left tp right water on the horizon
;1st
LDA #$23
STA $2006
LDA #$D8
STA $2006        

LDA #$05
STA $2007

;2nd
LDA #$23
STA $2006
LDA #$D9
STA $2006        

LDA #$05
STA $2007

;3rd
LDA #$23
STA $2006
LDA #$DA
STA $2006        

LDA #$05
STA $2007

;4th
LDA #$23
STA $2006
LDA #$DB
STA $2006        

LDA #$05
STA $2007

;5th
LDA #$23
STA $2006
LDA #$DC
STA $2006        

LDA #$05
STA $2007

;6th
LDA #$23
STA $2006
LDA #$DD
STA $2006        

LDA #$05
STA $2007

;7th
LDA #$23
STA $2006
LDA #$DE
STA $2006        

LDA #$05
STA $2007

;8th
LDA #$23
STA $2006
LDA #$DF
STA $2006        

LDA #$05
STA $2007


;enemy car1 reset position

;x pos
LDA #$00
STA $0283

LDA #$08
STA $0287

LDA #$00
STA $028B

LDA #$08
STA $028F

;y pos
LDA #$80
STA $0280

LDA #$80
STA $0284

LDA #$88
STA $0288

LDA #$88
STA $028C

;enemy car 2 reset position

;x pos
LDA #$00
STA $0293

LDA #$08
STA $0297

LDA #$00
STA $029B

LDA #$08
STA $029F

;y pos

LDA #$9E
STA $0290

LDA #$9E
STA $0294

LDA #$A6
STA $0298

LDA #$A6
STA $029C


;enemy car2 speed change
LDA $0293
SEC
SBC #$02
STA $0293

LDA $0297
SEC
SBC #$02
STA $0297

LDA $029B
SEC
SBC #$02
STA $029B

LDA $029F
SEC
SBC #$02
STA $029F

RTS


nightlevel:

;grass made into poles

LDA #$E7
STA $0231
STA $0235
STA $0239
;x position
LDA #$00
STA $0233

LDA #$55
STA $0237

LDA #$AA
STA $023B

;make rest of grass sprites invisible
LDA #$1D
STA $023D
STA $0241
STA $0245
STA $0249
STA $024D
;bg color 1 (ground)
  LDA #$3F
  STA $2006
  LDA #$01
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$1E         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette  

;bg color 3 (curb)
  LDA #$3F
  STA $2006
  LDA #$03
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$03         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette    

;bg color 4 (road)
  LDA #$3F
  STA $2006
  LDA #$02
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$1E         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette  

;enemycar1 color pink
  LDA #$3F
  STA $2006
  LDA #$11
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$25         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette  



;sprite colors for bg objects
  LDA #$3F
  STA $2006
  LDA #$15
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$14         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette 

;2nd
  LDA #$3F
  STA $2006
  LDA #$16
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$37         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette 

;3rd
  LDA #$3F
  STA $2006
  LDA #$17
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$25         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette 




;buildings position


;1st sprite
LDA #$55
STA $0250
LDA #$10
STA $0253 

LDA #$ED
STA $0251

;2nd sprite
LDA #$55
STA $0254
LDA #$1A
STA $0257 

LDA #$DF
STA $0255

;3rd sprite
LDA #$55
STA $0258
LDA #$20
STA $025B 

LDA #$EE
STA $0259

;4th sprite
LDA #$55
STA $025C
LDA #$29
STA $025F 

LDA #$EB
STA $025D

;5th sprite
LDA #$4D
STA $0260
LDA #$2C
STA $0263 

LDA #$EB
STA $0261

;6th sprite
LDA #$55
STA $0264
LDA #$35
STA $0267 

LDA #$EE
STA $0265

;7th sprite
LDA #$55
STA $0268
LDA #$40
STA $026B 

LDA #$EC
STA $0269

;8th sprite
LDA #$01
STA $026E

LDA #$4D
STA $026C
LDA #$40
STA $026F 

LDA #$FF
STA $026D

;9th sprite
LDA #$55
STA $0270
LDA #$4F
STA $0273 

LDA #$FF
STA $0271

;10th sprite
LDA #$55
STA $0274
LDA #$5A
STA $0277 

LDA #$DF
STA $0275

;11th sprite
LDA #$57
STA $0278
LDA #$72
STA $027B 

LDA #$ED
STA $0279

;12th sprite 
LDA #$01
STA $027E


LDA #$57
STA $027C
LDA #$FF
STA $027F 

LDA #$ED
STA $027D


;enemey car index (does not work)

;LDA $30
;STA $0281

;LDA $2F
;STA $0285

;LDA $3E
;STA $0289

;LDA $3F
;STA $028D



RTS

Sunsetlevelpalette:



;bg 0 color (sky) 
  LDA #$3F
  STA $2006
  LDA #$00
  STA $2006        

  LDA #$34         
  STA $2007       


;bg 2 color (road) 
  LDA #$3F
  STA $2006
  LDA #$02
  STA $2006        

  LDA #$0C         
  STA $2007      

;bg 3 color (curb) 
  LDA #$3F
  STA $2006
  LDA #$03
  STA $2006        

  LDA #$2D         
  STA $2007  


;bg color 5 (water)
  LDA #$3F
  STA $2006
  LDA #$05
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$22         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette


;bg color 1 (ground)
  LDA #$3F
  STA $2006
  LDA #$01
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$37         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette  


;enemycar1 color red
  LDA #$3F
  STA $2006
  LDA #$11
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$06         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette  

;window tint
  LDA #$3F
  STA $2006
  LDA #$13
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$32         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette  

;enemycar2 color 
  LDA #$3F
  STA $2006
  LDA #$1D
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$37         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette    


;enemycar2 color 
  LDA #$3F
  STA $2006
  LDA #$1F
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$3C         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette      

RTS

sunsetlevelsunsprite:

LDA #$30
STA $02E0
LDA #$70
STA $02E3
LDA #$5E
STA $02E1

LDA #$03
STA $02E2


LDA #$78
STA $02B3
LDA #$30
STA $02B0
LDA #$5F
STA $02B1


LDA #$70
STA $02B7
LDA #$38
STA $02B4
LDA #$6E
STA $02B5


LDA #$78
STA $02BB
LDA #$38
STA $02B8
LDA #$6F
STA $02B9



RTS


TheThirdlevel:

 LDA #%00000000
    STA $2001        ; disable rendering

JSR Sunsetlevelpalette
JSR sunsetlevelsunsprite
JSR attributetablechange



LDA #$00
STA $0283

LDA #$08
STA $0287

LDA #$00
STA $028B

LDA #$08
STA $028F

;y pos
LDA #$80
STA $0280

LDA #$80
STA $0284

LDA #$88
STA $0288

LDA #$88
STA $028C

;enemy car 2 reset position

;x pos
LDA #$00
STA $0293

LDA #$08
STA $0297

LDA #$00
STA $029B

LDA #$08
STA $029F

;y pos

LDA #$9E
STA $0290

LDA #$9E
STA $0294

LDA #$A6
STA $0298

LDA #$A6
STA $029C

LDA #$02
STA $2005   ; horizontal scroll
STA $2005   ; vertical scroll

    LDA #%00011110
    STA $2001        ; enable rendering again

RTS    

palmlevelpalette:
;bg 0 color (sky) 
  LDA #$3F
  STA $2006
  LDA #$00
  STA $2006        

  LDA #$21         
  STA $2007       


;bg color 5 (water)
  LDA #$3F
  STA $2006
  LDA #$05
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$11         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette


;bg color 1 (ground)
  LDA #$3F
  STA $2006
  LDA #$01
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$27         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette  


;enemycar1 color pink
  LDA #$3F
  STA $2006
  LDA #$11
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$25         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette  

;window tint
  LDA #$3F
  STA $2006
  LDA #$13
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$32         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette  
RTS








ResetTheWholeGame:

;disable all audio
LDA #$00
STA $4015


;level 1
LDA #$00
STA levelcounter
LDA #$00
STA BeatLevel2

;make all colors normal
LDA #%00000000
STA $2001        ; disable rendering

JSR ResetGameAttribute
JSR attributetablechange




;reset all colors
;enemycar1 color
  LDA #$3F
  STA $2006
  LDA #$11
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$21         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette  

;window tint
  LDA #$3F
  STA $2006
  LDA #$18
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$18         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette  

;enemycar2 color 
  LDA #$3F
  STA $2006
  LDA #$1D
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$27         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette    


;enemycar2 color 
  LDA #$3F
  STA $2006
  LDA #$1F
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$37         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette      









;reset the water to grass if beyond level 1
LDA #$23
STA $2006
LDA #$D8
STA $2006        

LDA #$00
STA $2007

;2nd
LDA #$23
STA $2006
LDA #$D9
STA $2006        

LDA #$00
STA $2007

;3rd
LDA #$23
STA $2006
LDA #$DA
STA $2006        

LDA #$00
STA $2007

;4th
LDA #$23
STA $2006
LDA #$DB
STA $2006        

LDA #$00
STA $2007

;5th
LDA #$23
STA $2006
LDA #$DC
STA $2006        

LDA #$00
STA $2007

;6th
LDA #$23
STA $2006
LDA #$DD
STA $2006        

LDA #$00
STA $2007

;7th
LDA #$23
STA $2006
LDA #$DE
STA $2006        

LDA #$00
STA $2007

;8th
LDA #$23
STA $2006
LDA #$DF
STA $2006        









LDA #$00
STA $2007
LDA #$02
STA $2005   ; horizontal scroll
STA $2005   ; vertical scroll






  LDA #%00011110
  STA $2001        ; enable rendering again




;reset player position

; sprite 1
LDA #$80
STA $0200
LDA #$20
STA $0201
LDA #$02
STA $0202
LDA #$80
STA $0203

;sprite 2
LDA #$80
STA $0204
LDA #$21
STA $0205
LDA #$02
STA $0206
LDA #$88
STA $0207

;sprite 3
LDA #$80
STA $0208
LDA #$22
STA $0209
LDA #$02
STA $020A
LDA #$8F
STA $020B

;sprite 4
LDA #$80
STA $020C
LDA #$23
STA $020D
LDA #$02
STA $020E
LDA #$97
STA $020F

;sprite 5
LDA #$88
STA $0210
LDA #$30
STA $0211
LDA #$02
STA $0212
LDA #$80
STA $0213

;sprite 6
LDA #$88
STA $0214
LDA #$31
STA $0215
LDA #$02
STA $0216
LDA #$88
STA $0217

;sprite 7
LDA #$88
STA $0218
LDA #$32
STA $0219
LDA #$02
STA $021A
LDA #$8F
STA $021B

;sprite 8
LDA #$88
STA $021C
LDA #$33
STA $021D
LDA #$02
STA $021E
LDA #$97
STA $021F


;reset road lines position

;sprite 1
LDA #$99
STA $0220
LDA #$2D
STA $0221
LDA #$03
STA $0222
LDA #$10
STA $0223

;sprite 2
LDA #$99
STA $0224
LDA #$2D
STA $0225
LDA #$03
STA $0226
LDA #$50
STA $0227

;sprite 3
LDA #$99
STA $0228
LDA #$2D
STA $0229
LDA #$03
STA $022A
LDA #$90
STA $022B

;sprite 4
LDA #$99
STA $022C
LDA #$2D
STA $022D
LDA #$03
STA $022E
LDA #$D0
STA $022F

;reset all grass positons

;sprite 1
LDA #$73
STA $0230
LDA #$0C
STA $0231
LDA #$01
STA $0232
LDA #$10
STA $0233

;sprite 2
LDA #$73
STA $0234
LDA #$0D
STA $0235
LDA #$01
STA $0236
LDA #$1A
STA $0237

;sprite 3
LDA #$73
STA $0238
LDA #$0C
STA $0239
LDA #$01
STA $023A
LDA #$30
STA $023B

;sprite 4
LDA #$73
STA $023C
LDA #$0C
STA $023D
LDA #$01
STA $023E
LDA #$50
STA $023F

;sprite 5
LDA #$73
STA $0240
LDA #$0C
STA $0241
LDA #$01
STA $0242
LDA #$80
STA $0243

;sprite 6
LDA #$73
STA $0244
LDA #$0C
STA $0245
LDA #$01
STA $0246
LDA #$A0
STA $0247

;sprite 7
LDA #$73
STA $0248
LDA #$0D
STA $0249
LDA #$01
STA $024A
LDA #$AB
STA $024B

;sprite 8
LDA #$73
STA $024C
LDA #$0D
STA $024D
LDA #$01
STA $024E
LDA #$DE
STA $024F

;reset maintain 1 - base

;sprite 1
LDA #$55
STA $0250
LDA #$0A
STA $0251
LDA #$01
STA $0252
LDA #$10
STA $0253

;sprite 2
LDA #$55
STA $0254
LDA #$10
STA $0255
LDA #$01
STA $0256
LDA #$17
STA $0257

;sprite 3
LDA #$55
STA $0258
LDA #$10
STA $0259
LDA #$01
STA $025A
LDA #$1F
STA $025B

;sprite 4
LDA #$55
STA $025C
LDA #$0A
STA $025D
LDA #$71
STA $025E
LDA #$27
STA $025F

;reset mountain 2 - base

;sprite 1
LDA #$55
STA $0260
LDA #$0A
STA $0261
LDA #$01
STA $0262
LDA #$80
STA $0263

;sprite 2
LDA #$55
STA $0264
LDA #$10
STA $0265
LDA #$01
STA $0266
LDA #$87
STA $0267

;sprite 3
LDA #$55
STA $0268
LDA #$10
STA $0269
LDA #$01
STA $026A
LDA #$8F
STA $026B

;sprite 4
LDA #$55
STA $026C
LDA #$0A
STA $026D
LDA #$71
STA $026E
LDA #$97
STA $026F

;mountain 1 - top

;sprite 1
LDA #$4D
STA $0270
LDA #$0B
STA $0271
LDA #$01
STA $0272
LDA #$18
STA $0273

;sprite 2
LDA #$4D
STA $0274
LDA #$0B
STA $0275
LDA #$71
STA $0276
LDA #$1F
STA $0277

;mountain 2 - top

;sprite 1
LDA #$4D
STA $0278
LDA #$0B
STA $0279
LDA #$01
STA $027A
LDA #$88
STA $027B

;sprite 2
LDA #$4D
STA $027C
LDA #$0B
STA $027D
LDA #$71
STA $027E
LDA #$8F
STA $027F


;enemy car 1

;sprite 1
LDA #$85
STA $0280
LDA #$0E
STA $0281
LDA #$03
STA $0282
LDA #$20
STA $0283

;sprite 2
LDA #$85
STA $0284
LDA #$0F
STA $0285
LDA #$03
STA $0286
LDA #$28
STA $0287

;sprite 3
LDA #$8D
STA $0288
LDA #$1E
STA $0289
LDA #$03
STA $028A
LDA #$20
STA $028B

;sprite 4
LDA #$8D
STA $028C
LDA #$1F
STA $028D
LDA #$03
STA $028E
LDA #$28
STA $028F

; enemy car 2

;sprite 1
LDA #$A0
STA $0290
LDA #$0E
STA $0291
LDA #$00
STA $0292
LDA #$90
STA $0293

;sprite 2
LDA #$A0
STA $0294
LDA #$0F
STA $0295
LDA #$00
STA $0296
LDA #$98
STA $0297

;sprite 3
LDA #$A8
STA $0298
LDA #$1E
STA $0299
LDA #$00
STA $029A
LDA #$90
STA $029B

;sprite 4
LDA #$A8
STA $029C
LDA #$1F
STA $029D
LDA #$00
STA $029E
LDA #$98
STA $029F

;?? sprite that covers the speed number (why did i put this here?)
LDA #$CC
STA $02A0
LDA #$FC
STA $02A1
LDA #$02
STA $02A2
LDA #$60
STA $02A3

;place logo on screen

; sprite 1 -C
LDA #$30
STA $02A4
LDA #$88
STA $02A5
LDA #$02
STA $02A6
LDA #$40
STA $02A7

; sprite 2 -O
LDA #$30
STA $02A8
LDA #$89
STA $02A9
LDA #$02
STA $02AA
LDA #$50
STA $02AB

; sprite 3 -O
LDA #$30
STA $02AC
LDA #$89
STA $02AD
LDA #$02
STA $02AE
LDA #$60
STA $02AF

; sprite 4 -O
LDA #$30
STA $02B0
LDA #$8A
STA $02B1
LDA #$02
STA $02B2
LDA #$70
STA $02B3

; sprite 5 -R
LDA #$30
STA $02B4
LDA #$8B
STA $02B5
LDA #$02
STA $02B6
LDA #$90
STA $02B7

; sprite 6 -A
LDA #$30
STA $02B8
LDA #$8C
STA $02B9
LDA #$02
STA $02BA
LDA #$A0
STA $02BB

; sprite 7 -C
LDA #$30
STA $02BC
LDA #$88
STA $02BD
LDA #$02
STA $02BE
LDA #$B0
STA $02BF

; sprite 8 -E
LDA #$30
STA $02C0
LDA #$8D
STA $02C1
LDA #$02
STA $02C2
LDA #$C0
STA $02C3

;press A text

;sprite 1
LDA #$40
STA $02C4
LDA #$98
STA $02C5
LDA #$03
STA $02C6
LDA #$50
STA $02C7

;sprite 2
LDA #$40
STA $02C8
LDA #$99
STA $02C9
LDA #$03
STA $02CA
LDA #$58
STA $02CB

;sprite 3
LDA #$40
STA $02CC
LDA #$9A
STA $02CD
LDA #$03
STA $02CE
LDA #$64
STA $02CF

;vedran 2025

;sprite 1
LDA #$40
STA $02D0
LDA #$9B
STA $02D1
LDA #$03
STA $02D2
LDA #$90
STA $02D3

;sprite 2
LDA #$40
STA $02D4
LDA #$9C
STA $02D5
LDA #$03
STA $02D6
LDA #$98
STA $02D7

;sprite 3
LDA #$40
STA $02D8
LDA #$9D
STA $02D9
LDA #$03
STA $02DA
LDA #$A0
STA $02DB

;sprite 4
LDA #$40
STA $02DC
LDA #$8E
STA $02DD
LDA #$03
STA $02DE
LDA #$A9
STA $02DF

;sprite 5
LDA #$40
STA $02E0
LDA #$8F
STA $02E1
LDA #$03
STA $02E2
LDA #$B1
STA $02E3

;timer reset to zero
LDA #$CE
STA $02E4
LDA #$B1
STA $02E5
LDA #$03
STA $02E6
LDA #$80
STA $02E7

;timer reset to zero
LDA #$CC
STA $02E8
LDA #$43
STA $02E9
LDA #$02
STA $02EA
LDA #$AB
STA $02EB


LDA #00
STA Nopothole

;reset all sprites to level 1 sprites


RTS




ResetGameAttribute:



;bg 0 color (sky) 
  LDA #$3F
  STA $2006
  LDA #$00
  STA $2006        

  LDA #$22         
  STA $2007       


;bg 2 color (road) 
  LDA #$3F
  STA $2006
  LDA #$02
  STA $2006        

  LDA #$2D         
  STA $2007      

;bg 3 color (curb) 
  LDA #$3F
  STA $2006
  LDA #$03
  STA $2006        

  LDA #$17         
  STA $2007  

;bg color 1 (ground)
  LDA #$3F
  STA $2006
  LDA #$01
  STA $2006        ; Set PPU address to $3F00 (background color)

  LDA #$1A         ; Color value (change this to any valid NES color)
  STA $2007        ; Write to palette  




RTS







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

background2:
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

  .byte $27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27  ;;row 1
  .byte $27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27  ;;row 1

  .byte $27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27  ;;row 1
  .byte $27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27  ;;row 1

  .byte $27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27  ;;row 1
  .byte $27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$27  ;;row 1

  .byte $49,$49,$49,$49,$49,$49,$49,$49,$49,$49,$49,$49,$49,$49,$49,$49  ;;row 17
  .byte $49,$49,$49,$49,$49,$49,$49,$49,$49,$49,$49,$49,$49,$49,$49,$49  ;;row 17

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

  .byte $4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A  ;;row 17
  .byte $4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A  ;;row 17

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

attributes2:  ;8 x 8 = 64 bytes
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

  palette2:
  .byte $21,$1A,$2D,$27,  $0F,$36,$17,$0F,  $22,$30,$21,$0F,  $22,$0F,$04,$2B   ;;background palette
  .byte $22,$25,$3E,$31,  $22,$1B,$29,$0B,  $22,$3E,$16,$3D,  $22,$27,$0F,$38   ;;sprite palette

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

  .byte $99, $2D, $03, $10   ; road lines
  .byte $99, $2D, $03, $50   ; 
  .byte $99, $2D, $03, $90   ;
  .byte $99, $2D, $03, $D0   ;  


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
    .incbin "CoolRace.chr"


