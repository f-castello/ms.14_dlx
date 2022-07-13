
ori r4,r0,#32896 ;value with 16th and 8th bit = 1
nop
nop
nop
nop
nop
sh 1(r0), r4 ;expected value saved h8080
nop
nop
nop
nop
nop
nop
sb 2(r0), r4 ;expected value saved h80   
nop
nop
nop
nop
nop
nop
lw r8, 1(r0) ;expected value loaded h3
nop
nop
nop
nop
nop
nop
lh r9, 1(r0) ;expected value loaded hFFFF8080
nop
nop
nop
nop
nop
nop
lb r10, 2(r0);expected value loaded hFFFFFF80
nop
nop
nop
nop
nop
nop
lhu r11, 1(r0) ;expected value loaded h00008080
nop
nop
nop
nop
nop
nop
lbu r13, 2(r0) ;expected value loaded h00000080
nop
nop
nop
nop
nop
nop
lbu r14, 1(r0) ;expected value loaded h00000080
nop
nop
nop
nop
nop
nop
lh r9, 2(r0) ;expected value loaded h00000080

