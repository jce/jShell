.org 0x0000
    jp 0x6000

.ORG 0x6000
trap_start .equ         0x0003
int_offs .equ           0x60
log_location_c  .equ    0xC000
log_len_c       .equ    0x2000
