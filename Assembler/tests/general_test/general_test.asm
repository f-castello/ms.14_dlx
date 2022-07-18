addui r1,r0,#24
jal NEXT ;expecting R31 = 8
nop
nop
nop
nop
addui r3,r0,#32768;position 24, jumping here
lhi   r14,#-3 ;expected value : hFFFD0000
addi r7,r0,#24
subi r2,r1,#3 ;expected value: d21
subi r4,r1,#32768; expected value d32791 or h8017
subui r5,r3,#32767; expected value h1
subu r6,r3,r1 ;expected value: d32744 or h7FE8
seq r8,r1,r7 ;expected value: h1
seq r8,r1,r2 ;expected value: h0
seqi r9,r1,#24;expected value: h1
seqi r9,r1,#23;expected value: h0
sgeui r10,r1,#23;expected value: h1
sgeui r10,r1,#-23;expected value: h0
sgt   r11,r7,r9 ;expected value: h1
sgt   r11,r7,r1 ;expected value: h0
sgti  r12,r1,#23 ;expected value: h1
sgti  r12,r1,#-24 ;expected value: h1
sgti  r12,r1,#24 ;expected value: h0
mult  r13,r1,r7 ;expected value: h240
sgtu  r15,r14,r1 ;expected value : h1
sgtu  r15,r1,r14 ;expected value : h0
sgtui r16,r1,#3 ;expected value :h1
sgtui r16,r1,#-3 ;expected value :h0
slt r17,r1,r4 ;expected value: h1
slt r17,r1,r14 ;expected value: h0
sltu r18,r1,r14 ;expected value: h1
sltu r18,r1,r2 ;expected value: h0
sltui r19,r1,#-3 ;expected value:h1
sltui r19,r1,#21 ;expected value:h0
sra   r20,r14,r5 ;expected value:hFFFE8000
NEXT:
jalr r1 ;jumping to position 24
