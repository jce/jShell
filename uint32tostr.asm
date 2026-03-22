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
    .block 10
buf_A_end:
buf_B_begin: 
    .block 10
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

