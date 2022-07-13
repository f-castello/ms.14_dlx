addi r1,r1,#3
addi r2,r1,#10
addi r3,r0,#-5
ori r4,r0,#32896 ;value with 16th and 8th bit = 1
xori r5,r0,#-9 ;expected value:0000FFF7
and  r6,r1,r2 ;expected result: 2
xor r7,r2,r1 ;expected result: 9
sw 0(r0), r1 ;expected value saved h3
sh 1(r0), r4 ;expected value saved h8080
sb 2(r0), r4 ;expected value saved h80   
lw r8, 0(r0) ;expected value loaded h3
lh r9, 1(r0) ;expected value loaded hFFFF8080
lb r10, 2(r0);expected value loaded hFFFFFF80
lhu r11, 1(r0) ;expected value loaded h00008080
lbu r13, 2(r0) ;expected value loaded h00000080
lbu r14, 1(r0) ;expected value loaded h00000080
lh r9, 2(r0) ;expected value loaded h00000080

