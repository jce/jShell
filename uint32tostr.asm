;Inputs:
; Inputs
;   DE  is the uint16 to display
; Outputs
;   HL  Buffer with the zero-terminated string    
uint16tostr_buf:
    ld hl, buf_B_begin
    call uint16tostr
    ld (hl), 0
    ld hl, buf_B_begin
    ret

;Inputs:
;   DE  is the uint16 to display
;   HL  Where to write the string. Increments HL
uint16tostr:
    push af
    push bc
    push ix
    push hl
    ld ix, buf_A_end
    ld hl, de
    ld de, 0
    ld c, 10
    call _uint32tostr    ; Brilliant algorithm
    ld bc, ix
    pop hl
    ld ix, buf_A_end    
uint16tostr_loop:
    ld a, (bc)
    ld (hl), a
    inc bc
    inc hl    
    ld a, ixl
    cp a, c
    jr nz, uint16tostr_loop
    pop ix
    pop bc
    pop af
    ret

; Inputs
;   DE  is the memory address, HL is buffer where to write the ascii
; Outputs
;   HL  Buffer with the zero-terminated string    
uint32tostr_dec_buf:
    ld hl, buf_B_begin
    call uint32tostr_dec
    ld (hl), 0
    ld hl, buf_B_begin
    ret

;Inputs:
;   DE  is the memory address
;   HL  Where to write the string. Increments HL
uint32tostr_dec:
    push af
    push bc
    push ix
    push hl
    ld ix, buf_A_end
    ld hl, de           ; hl becomes memory address of uint32
    inc hl \ inc hl
    ld de, (hl)         ; Load / prepare de
    dec hl \ dec hl
    ld bc, (hl)
    ld hl, bc           ; Load / prepare hl, DEHL is now prepared
    ld c, 10
    call _uint32tostr    ; Brilliant algorithm
    ld bc, ix
    pop hl
    ld ix, buf_A_end    
uint32tostr_dec_loop:
    ld a, (bc)
    ld (hl), a
    inc bc
    inc hl    
    ld a, ixl
    cp a, c
    jr nz, uint32tostr_dec_loop
    pop ix
    pop bc
    pop af
    ret

buf_A_begin: 
    .block 12
buf_A_end:
buf_B_begin: 
    .block 12
buf_B_end:

; Copied from https://github.com/Zeda/Z80-Optimized-Routines and adapted
;Inputs:
;     C is the base
;     DEHL is the number to display
;     IX points to the end of the output location
;Outputs:
;     A, B, D, E is 0
;     C is not changed
;     HL points to the string
;NOTE: This does not put a 0 byte at the end
_uint32tostr:    
    ld b,32     ; b = 32
    xor a       ; a = 0
_uint32tostr_a:
    add hl,hl   ;
    rl e        ;
    rl d        ;
    rla         ; ADEHL << 1
    cp c        ; a - c
    jr c,$+4    ; is negative? (c > a) jump over to a
    inc l       ; l = l + 1
    sub c       ; a = a - 10
    djnz _uint32tostr_a ; jump to a
    add a,30h   ; translate the value in a to decimal
    cp 3Ah      ; if its more than 9, use hexadecimal characters
    jr c, _uint32tostr_b  ;
    add a,7     ;
_uint32tostr_b:
    dec ix      ; decrement write pointer
    ld (ix),a   ; Write the a character
    ld a,h      ; h, l, d, e not all zero?
    or l \ or d \ or e
    jr nz,_uint32tostr ; Back to the beginning
    push ix     ; hl = ix
    pop hl      ;
    ret         ;

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

; Another shameless borrow from Zeda, Thank you!

atoui8:
strtob:
;Input:
;   HL is a string, terminated by a non-numeric ASCII char
;Output:
;   A has the 8-bit value
strtob:
    xor a
    jr inloop
loop:
    ld e,a
    ld a,d
    add a,a     ;double our accumulator
    add a,a     ;double again (now x4)
    add a,d     ;add the original (now x5)
    add a,a     ;double again (now x10)
    add a,e     ;add in the incoming digit
    inc hl
inloop:
    ld d,a
    ld a,(hl)
    sub '9'+1
    add 10
    jr c,loop
    ld a,d
    ret


;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; More Zeda, needed is a fixed-width-string from uint16, that displays a decimal dot on
; a fixed length canvas. Modified these:
; https://github.com/Zeda/Z80-Optimized-Routines/blob/master/conversion/u16toa_destructive.z80
; Since the result is ugly, i take full blame. JCE, 18-10-2026

;written by Zeda
;Converts a 16-bit unsigned integer to an ASCII string.
;Note that this version destroys registers.

u16toa_d_buf   .block  7

u16toa_d1:
;Input:
;   DE is the number to convert
;Output:
;   HL points to the null-terminated ASCII string
;Destroys:
;   BC, DE, AF
  ld hl, u16toa_d_buf
  ex de,hl

; First digit
  ld bc,-10000
  ld a,'0'-1
  inc a     ;\
  add hl,bc ; | Loop
  jr c,$-2  ;/
  ld (de),a
  inc de

; Second digit
  ld bc,1000
  ld a,'9'+1
  dec a     ;\
  add hl,bc ; | Loop
  jr nc,$-2 ;/
  ld (de),a
  inc de

; Third digit
  ld bc,-100
  ld a,'0'-1
  inc a     ;\
  add hl,bc ; | Loop
  jr c,$-2  ;/
  ld (de),a
  inc de

; Fourth digit, remainder is fifth digit
  ld a,l
  ld h,'9'+1
  dec h     ;\
  add a,10  ; | Loop
  jr nc,$-3 ;/
  ex de,hl
  ld (hl),d
  inc hl

    ld c, a
    ld a, '.'
    ld (hl), a
    inc hl
    ld a, c

  add a,'0'
  ld (hl),a
  inc hl
  ld (hl),0

;Now strip the leading zeros
  ld c,-6
  add hl,bc         ; hl is at the begin of buf
  ld a,'0'
    jr zl1
zl2:
    ld (hl), ' '    
    inc hl
zl1:
  cp (hl) 
  jr z,zl2          

  ld hl, u16toa_d_buf
  ret

u16toa_d2:
;Input:
;   DE is the number to convert
;Output:
;   HL points to the null-terminated ASCII string
;Destroys:
;   BC, DE, AF
  ld hl, u16toa_d_buf
  ex de,hl

; First digit
  ld bc,-10000
  ld a,'0'-1
  inc a     ;\
  add hl,bc ; | Loop
  jr c,$-2  ;/
  ld (de),a
  inc de

; Second digit
  ld bc,1000
  ld a,'9'+1
  dec a     ;\
  add hl,bc ; | Loop
  jr nc,$-2 ;/
  ld (de),a
  inc de

; Third digit
  ld bc,-100
  ld a,'0'-1
  inc a     ;\
  add hl,bc ; | Loop
  jr c,$-2  ;/
  ld (de),a
  inc de

    ld c, a
    ld a, '.'
    ld (de), a
    inc de
    ld a, c

; Fourth digit, remainder is fifth digit
  ld a,l
  ld h,'9'+1
  dec h     ;\
  add a,10  ; | Loop
  jr nc,$-3 ;/
  ex de,hl
  ld (hl),d
  inc hl

  add a,'0'
  ld (hl),a
  inc hl
  ld (hl),0

;Now strip the leading zeros
  ld c,-6
  add hl,bc         ; hl is at the begin of buf
  ld a,'0'
    jr zl3
zl4:
    ld (hl), ' '    
    inc hl
zl3:
  cp (hl) 
  jr z,zl4          

  ld hl, u16toa_d_buf
  ret









