;Inputs:
;     DE is the memory address, HL is buffer where to write the ascii
uint32tostr_dec:
    push ix
    sfo 10              ; Temporary memory of 10 bytes on the stack
    push ix 

    ld bc, 10
    add ix, bc          ; Make ix point to the end of the 10 bytes
    push ix
    push hl

    ld hl, de           ; hl becomes memory address of uint32
    inc hl \ inc hl
    ld de, (hl)         ; Load / prepare de
    dec hl \ dec hl
    ld bc, (hl)
    ld hl, bc           ; Load / prepare hl, DEHL is now prepared
    ld c, 10
    call uint32tostr    ; Brilliant algorithm

    ld bc, ix
    pop hl
    pop ix    
uint32tostr_dec_loop:
    ld a, (bc)
    ld (hl), a
    inc bc
    inc hl    
   
    ld a, ixl
    cp a, c
    jr nz, uint32tostr_dec_loop

    pop ix 
    sfc
    pop ix
    ret

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
uint32tostr:    
    ld b,32     ; b = 32
    xor a       ; a = 0
uint32tostr_a:
    add hl,hl   ;
    rl e        ;
    rl d        ;
    rla         ; ADEHL << 1
    cp c        ; a - c
    jr c,$+4    ; is negative? (c > a) jump over to a
    inc l       ; l = l + 1
    sub c       ; a = a - 10
    djnz uint32tostr_a ; jump to a
    add a,30h   ; translate the value in a to decimal
    cp 3Ah      ; if its more than 9, use hexadecimal characters
    jr c, uint32tostr_b  ;
    add a,7     ;
uint32tostr_b:
    dec ix      ; decrement write pointer
    ld (ix),a   ; Write the a character
    ld a,h      ; h, l, d, e not all zero?
    or l \ or d \ or e
    jr nz,uint32tostr ; Back to the beginning
    push ix     ; hl = ix
    pop hl      ;
    ret         ;

