; 16bit prng, see http://www.retroprogramming.com/2017/07/xorshift-pseudorandom-numbers-in-z80.html
; Output: hl
xrnd:
    ld hl,1       ; seed must not be 0

    ld a,h
    rra
    ld a,l
    rra
    xor h
    ld h,a
    ld a,l
    rra
    ld a,h
    rra
    xor l
    ld l,a
    xor h
    ld h,a

    ld (xrnd+1),hl
    ret

; https://tutorials.eeems.ca/Z80ASM/part4.htm
; Mul8:     HL=DE*A
; MUL8b:    HL=H*E
; Mul16:    DEHL=BC*DE
; Div8:     HL=HL/D
; sin       A=SIN(A)        

Mul8:                            ; this routine performs the operation HL=DE*A DE can be signed or unsigned, A is unsigned.
  ld hl,0                        ; HL is used to accumulate the result
  ld b,8                         ; the multiplier (A) is 8 bits wide
Mul8Loop:
  rrca                           ; putting the next bit into the carry
  jp nc,Mul8Skip                 ; if zero, we skip the addition (jp is used for speed)
  add hl,de                      ; adding to the product if necessary
Mul8Skip:
  sla e                          ; calculating the next auxiliary product by shifting
  rl d                           ; DE one bit leftwards (refer to the shift instructions!)
  djnz Mul8Loop
  ret


Mul8b:                           ; this routine performs the operation HL=H*E (both unsigned)
  ld d,0                         ; clearing D and L
  ld l,d
  ld b,8                         ; we have 8 bits
Mul8bLoop:
  add hl,hl                      ; advancing a bit
  jp nc,Mul8bSkip                ; if zero, we skip the addition (jp is used for speed)
  add hl,de                      ; adding to the product if necessary
Mul8bSkip:
  djnz Mul8bLoop
  ret


Div8:                            ; this routine performs the operation HL=HL/D
  xor a                          ; clearing the upper 8 bits of AHL
  ld b,16                        ; the length of the dividend (16 bits)
Div8Loop:
  add hl,hl                      ; advancing a bit
  rla
  cp d                           ; checking if the divisor divides the digits chosen (in A)
  jp c,Div8NextBit               ; if not, advancing without subtraction
  sub d                          ; subtracting the divisor
  inc l                          ; and setting the next digit of the quotient
Div8NextBit:
  djnz Div8Loop
  ret


Mul16:                           ; This routine performs the operation DEHL=BC*DE
  ld hl,0
  ld a,16
Mul16Loop:
  add hl,hl
  rl e
  rl d
  jp nc, NoMul16
  add hl,bc
  jp nc,NoMul16
  inc de                         ; This instruction (with the jump) is like an "ADC DE,0"
NoMul16:
  dec a
  jp nz,Mul16Loop
  ret


; function a = cos(a). Input range 256, output range 0-255.999
cos:
    add a, 64
    call sin
    ret

; function a = sin(a). input range 0-255 (256) output range 0-255.999
sin:
    push hl
    push bc
    LD hl, sintab
    ld c, a
    ld b, 0
    add hl, bc
    ld a, (hl)
    pop bc
    pop hl
    ret

; function a = sin2(a). input range 0-255 (256) output range 16-240
sin2:
    push hl
    push bc
    LD hl, sintab2
    ld c, a
    ld b, 0
    add hl, bc
    ld a, (hl)
    pop bc
    pop hl
    ret

; full sine tables
; period = 256
; min = 0, 16
; max = 255.999, 240
sintab: .db 127, 131, 134, 137, 140, 143, 146, 149, 152, 156, 159, 162, 165, 168, 171, 174, 176, 179, 182, 185, 188, 191, 193, 196, 199, 201, 204, 206, 209, 211, 213, 216, 218, 220, 222, 224, 226, 228, 230, 232, 234, 236, 237, 239, 240, 242, 243, 245, 246, 247, 248, 249, 250, 251, 252, 252, 253, 254, 254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 254, 254, 253, 252, 252, 251, 250, 249, 248, 247, 246, 245, 243, 242, 240, 239, 237, 236, 234, 232, 230, 228, 226, 224, 222, 220, 218, 216, 213, 211, 209, 206, 204, 201, 199, 196, 193, 191, 188, 185, 182, 179, 176, 174, 171, 168, 165, 162, 159, 156, 152, 149, 146, 143, 140, 137, 134, 131, 127, 124, 121, 118, 115, 112, 109, 106, 103, 99, 96, 93, 90, 87, 84, 81, 79, 76, 73, 70, 67, 64, 62, 59, 56, 54, 51, 49, 46, 44, 42, 39, 37, 35, 33, 31, 29, 27, 25, 23, 21, 19, 18, 16, 15, 13, 12, 10, 9, 8, 7, 6, 5, 4, 3, 3, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 2, 3, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 15, 16, 18, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37, 39, 42, 44, 46, 49, 51, 54, 56, 59, 62, 64, 67, 70, 73, 76, 79, 81, 84, 87, 90, 93, 96, 99, 103, 106, 109, 112, 115, 118, 121, 124
sintab2: db 128, 130, 133, 136, 138, 141, 144, 147, 149, 152, 155, 157, 160, 163, 165, 168, 170, 173, 175, 178, 180, 183, 185, 187, 190, 192, 194, 196, 199, 201, 203, 205, 207, 209, 210, 212, 214, 216, 217, 219, 221, 222, 224, 225, 226, 228, 229, 230, 231, 232, 233, 234, 235, 235, 236, 237, 237, 238, 238, 239, 239, 239, 239, 239, 240, 239, 239, 239, 239, 239, 238, 238, 237, 237, 236, 235, 235, 234, 233, 232, 231, 230, 229, 228, 226, 225, 224, 222, 221, 219, 217, 216, 214, 212, 210, 209, 207, 205, 203, 201, 199, 196, 194, 192, 190, 187, 185, 183, 180, 178, 175, 173, 170, 168, 165, 163, 160, 157, 155, 152, 149, 147, 144, 141, 138, 136, 133, 130, 128, 125, 122, 119, 117, 114, 111, 108, 106, 103, 100, 98, 95, 92, 90, 87, 85, 82, 80, 77, 75, 72, 70, 68, 65, 63, 61, 59, 56, 54, 52, 50, 48, 46, 45, 43, 41, 39, 38, 36, 34, 33, 31, 30, 29, 27, 26, 25, 24, 23, 22, 21, 20, 20, 19, 18, 18, 17, 17, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 18, 18, 19, 20, 20, 21, 22, 23, 24, 25, 26, 27, 29, 30, 31, 33, 34, 36, 38, 39, 41, 43, 45, 46, 48, 50, 52, 54, 56, 59, 61, 63, 65, 68, 70, 72, 75, 77, 80, 82, 85, 87, 90, 92, 95, 98, 100, 103, 106, 108, 111, 114, 117, 119, 122, 125








































