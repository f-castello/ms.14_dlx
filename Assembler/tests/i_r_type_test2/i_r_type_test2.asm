addi r1,r1,#5
subi r2,r0,#2
addi r10,r0,#2
subi r3,r0,#7 hFFFFFFF9
addi r7,r0,#-5
nop
nop
nop
nop
addu r4,r1,r3 ;expected result :hFFFFFFFE
sll r5,r1,r10 ;expected result: d20
sne r6,r1,r2 ;expected result: 1
sne r8,r1,r7 ;expected result: 1
srl r9,r7,r10 ;expected result: d-20
sub r11,r1,r2 ;expected result: h3