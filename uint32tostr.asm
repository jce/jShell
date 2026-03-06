; Copied from https://github.com/Zeda/Z80-Optimized-Routines and adapted


uint32tostr_dec:
    sfo 10
    push ix

    ld bc, 10
    add ix, bc
    push ix
 
    dec ix \ ld (ix), 'f'
    dec ix \ ld (ix), 'd'
    dec ix \ ld (ix), 's'
    dec ix \ ld (ix), 'a'

    ld bc, ix
    pop ix    
uloop:
    ld a, (bc)
    ld (hl), a
    inc bc
    inc hl    
   
    ld a, ixl
    cp a, c
    jr nz, uloop

    pop ix 
    sfc
    ret
;Inputs:
;     DE is the memory address, HL is buffer where to write the ascii
uint32tostr_dec_:
    sfo 10              ; Temporary 10 bytes for the maximum length of the string
    push ix             ; Prepare ix to point to the end of the temporary string
    ld bc, 10           ;
    add ix, bc          ;
    push ix             ; 
 
    push hl             ; hl is needed at the end, start of destination string
    ld hl, de           ; hl becomes memory address of uint32
    ld de, (hl)         ; Load / prepare de
    inc hl \ inc hl
    ld bc, (hl)
    ld hl, bc           ; Load / prepare hl, DEHL is now prepared

    ld c,10             ; Base 10 division
    ; -------------------------------
;    call uint32tostr    ; Brilliant algorithm
    dec ix \  ld (ix), 'x'
    dec ix \  ld (ix), 'y'
    dec ix \  ld (ix), 'z'
    dec ix \  ld (ix), 'a'
    push ix
    pop hl
    ; ------------------------------

    ld de, hl           ; Pointer to the begin of the generated string
    pop hl              ; Pointer to where the string needs to go
    pop ix              ; Remember where the string started

uint32tostr_dec_copyloop:
    push hl
    ld hl, de
    call sio_uint16_hex
    pop hl
    call sio_uint16_hex_nl
;    ld a, (de)          ; Copy one character
;    ld (hl), a          ;
    inc de              ; Increment pointers
    inc hl              ;
    ld a, ixl           ; Is the low byte of the pointer equal to the low byte of the buffer end?
    cp a, l
    jr nz, uint32tostr_dec_copyloop
 
    pop ix              ; sfc expects ix to be unchanged
    sfc                 ; stack frame close
    ret

;Inputs:
;     C is the base
;     DEHL is the number to display
;     IX points to the end of the output location
;Outputs:
;     A, B, D, E is 0
;     C is not changed
;     HL points to the string
;NOTE: This does not put a 0 byte at the end
uint32tostr:    
    ld b,32     ; b = 32
    xor a       ; a = 0
minus:
    add hl,hl   ;
    rl e        ;
    rl d        ;
    rla         ; ADEHL << 1
    cp c        ; a - c
    jr c,$+4    ; is negative? (c > a) jump over to the djnz minus
    inc l       ; l = l + 1
    sub c       ; a = a - 10
    djnz minus  ; jump to minus
    add a,30h   ; translate the value in a to decimal
    cp 3Ah      ; if its more than 9, use hexadecimal characters
    jr c, plus  ;
    add a,7     ;
plus:
    dec ix      ; decrement write pointer
    ld (ix),a   ; Write the a character
    ld a,h      ; h, l, d, e not all zero?
    or l \ or d \ or e
    jr nz,uint32tostr ; Back to the beginning
    push ix     ; hl = ix
    pop hl      ;
    ret         ;

