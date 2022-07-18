ori r1,r1,#3 ;expected value: h3
lhi r2,#3 ;expected value: h00030000
lhi r3,#-3 ;expected value :hFFFD0000
nop
nop
or r4,r1,r2 ;expected value: h00030003
andi r5,r1,#1 ;expected value: h1
nop
nop
xor r6,r4,r1 ;expected value: h00030000
sge r7,r1,r3 ;expected value: h1
sge r7,r3,r1 ;expected value: h0
sgei r8,r1,#3 ;expected value: h1
sgei r8,r1,#-3 ;expected value: h1
sgei r8,r1,#4 ;expected value: h0
sgeu r9,r3,r1 ;expected value: h1
sgeu r9,r1,r3 ;expected value: h0
nop
nop
nop
sle r10,r3,r1 ;expected value: h1
sle r10,r1,r3 ;expected value: h0
slei r11,r1,#3 ;expected value: h1
slei r11,r1,#-3 ;expected value: h0

