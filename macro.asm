; Collection of macro's

; Debug a value to the LEDs on out0
; in one single line.
; example: dbg 20
dbg .macro $int
    push af
    ld a, $int
    out (0), a
    pop af
    .endm

; Stack frame open macro
; Takes 6 bytes of stack in addition to $size
; uses ix as frame pointer
; Preserves registers, trashes flags
sfo .macro $size
sfo_size = $size
    push af             ; Push the registers that
    push bc             ; the macro uses
    push hl
    ld hl, 0            ;
    add hl, sp          ; Read SP
    ld bc, $size        ; Load size in bc
    or a                ; Clear c flag
    sbc hl, bc          ; Subtract size from sp
    ld sp, hl           ; Store the new stackpointer
    ld bc, hl           ; Some acrobatics to get 
    ld ixh, b           ; hl into ix
    ld ixl, c           ; so ix can be used as offset register for the SP values
    ld hl, (ix+$size+0) ; Load hl from the push, but its not pop for its not on the top of the stack
    ld bc, (ix+$size+2) ; Load bc from the push
    ;ld af, (ix+$size+4); Not allowed!
    ld a, (ix+$size+5)  ; okay, then only a, not flags
    .endm

; Stack frame close macro. Preserves registers,
; trashes flags.
sfc .macro 
    ld (ix+sfo_size+0), hl  ; Store hl in the pushed hl
    ld (ix+sfo_size+2), bc  ; Store bc in the pushed bc
    ;ld (ix+sfo_size+4), af ; Not allowed either!
    ld (ix+sfo_size+5), a   ; Store a in the pushed af (ignoring flags)
    ld hl, 0            ; clear hl      
    add hl, sp          ; Get SP in hl
    ld bc, {sfo_size}   ; Get size in bc
    add hl, bc          ; Add size to sp
    ld sp, hl           ; Store SP
    pop hl              ; Pop hl
    pop bc              ; Pop bc
    pop af              ; Pop af
    .endm
