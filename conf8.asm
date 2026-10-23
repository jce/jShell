;.org 0x0000
;    jp 0x8000

.ORG 0x8000
trap_start      .equ    0x0003
int_offs        .equ    0x80
nv_block .equ           0xCFE5
loc_NTP_offs .equ       0xCFE5
loc_NTP_ip .equ         0xCFE6
loc_W5500_mac .equ      0xCFEA
loc_W5500_ip .equ       0xCFF0
loc_W5500_mask .equ     0xCFF4
loc_W5500_gw .equ       0xCFF8
loc_runtime .equ        0xCFFC
log_location_c  .equ    0xD000
log_len_c       .equ    0x1000
