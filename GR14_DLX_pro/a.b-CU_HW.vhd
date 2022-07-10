LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.dlx_utils.ALL;

ENTITY CU_HW IS
	GENERIC
	(
		MICRO_SIZE  : NATURAL := MICRO_N;  -- Microcode Memory Size
		FUNC_SIZE   : NATURAL := FUNC_N;   -- Func Field Size for R-Type Ops
		OPCODE_SIZE : NATURAL := OPCODE_N; -- Op Code Size
		IR_SIZE     : NATURAL := NbitLong; -- Instruction Register Size
		CW_SIZE     : NATURAL := CW_N      -- Control Word Size
	);
	PORT
	(
		Clk   : IN STD_LOGIC;                              -- Clock
		Rst   : IN STD_LOGIC;                              -- Reset (Asynchronous & Active Low)
		IR_IN : IN STD_LOGIC_VECTOR(IR_SIZE - 1 DOWNTO 0); -- Instruction Register Word

		-- PIPE STAGE #1: IF
		IF_LATCH_EN : OUT STD_LOGIC; -- (PC, IR) Register Enable

		-- PIPE STAGE #2: ID
		DEC_OUTREG_EN : OUT STD_LOGIC; -- (A, B, Imm, NPC1, IR1) Registers Enable
		IS_I_TYPE     : OUT STD_LOGIC; -- Detect I-Type Instructions for Sign Extension & Writing Address Selection
		RD1_EN        : OUT STD_LOGIC; -- Register File Read 1 Enable
		RD2_EN        : OUT STD_LOGIC; -- Register File Read 2 Enable
		ZERO_PADDING2 : OUT STD_LOGIC; -- Choose Zero Padding over normal Sign Extension

		-- PIPE STAGE #3: EXE
		MUXA_SEL      : OUT STD_LOGIC; -- MUXA Selector
		MUXB_SEL      : OUT STD_LOGIC; -- MUXB Selector
		EXE_OUTREG_EN : OUT STD_LOGIC; -- (ALU Output, ALU Flags, NPC2, IR2, Pad OP, Zero OP) Registers Enable
		EQ_COND       : OUT STD_LOGIC; -- Branch if (not) Equal to Zero
		JUMP_EN       : OUT STD_LOGIC; -- Jump Enable Signal for Cond Selection
		-- EXECUTION UNITS
		ALU_OPCODE : OUT ALU_MSG; -- Custom Type for ALU Ops
		FPU_OPCODE : OUT FPU_MSG; -- Custom Type for FPU Ops

		-- PIPE STAGE #4: MEM
		PC_LATCH_EN   : OUT STD_LOGIC; -- Program Counter Register Enable
		MEM_OUTREG_EN : OUT STD_LOGIC; -- (NPC3, IR3, BRA, ALU2MEM, OP2MEM) Registers Enable
		ZERO_PADDING4 : OUT STD_LOGIC; -- Choose Zero Padding over normal Sign Extension
		MEM_OUT_SEL   : OUT STD_LOGIC; -- Memory Output Mux Selector
		-- EXTERNAL MEMORY
		DRAM_WE  : OUT STD_LOGIC;                    -- Data RAM Write Enable
		BYTE_LEN : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- Memory Output Modifier

		-- PIPE STAGE #5: WB
		WB_MUX_SEL  : OUT STD_LOGIC; -- Write Back MUX Sel
		JAL_MUX_SEL : OUT STD_LOGIC; -- Jump And Link RF OR/Mux Selector
		WR_EN       : OUT STD_LOGIC; -- Register File Write Enable
		WB_LATCH_EN : OUT STD_LOGIC  -- Write Back Register Latch Enable
	);
END CU_HW;

ARCHITECTURE HARDWIRED OF CU_HW IS
	TYPE MICRO_MEM IS ARRAY (NATURAL RANGE 0 TO MICRO_SIZE - 1) OF STD_LOGIC_VECTOR(CW_SIZE - 1 DOWNTO 0);
	-- all invalid/not (yet) implemented entries will automatically get resolved to a NOP
	CONSTANT cw_code : MICRO_MEM := (
		-- +-------------------------+----------+---------+--------+------+-----------+
		-- |       CONTROL WORD      | MNEMONIC | OP TYPE | OPCODE | FUNC | MEM ENTRY |
		-- +=========================+==========+=========+========+======+===========+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | d.c. |    0x00   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    FP   |  0x01  | d.c. |    0x01   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |     j    |    J    |  0x02  | d.c. |    0x02   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    jal   |    J    |  0x03  | d.c. |    0x03   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   beqz   |    I    |  0x04  | d.c. |    0x04   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   bnez   |    I    |  0x05  | d.c. |    0x05   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   bfpt   |    I    |  0x06  | d.c. |    0x06   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   bfpf   |    I    |  0x07  | d.c. |    0x07   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   addi   |    I    |  0x08  | d.c. |    0x08   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   addui  |    I    |  0x09  | d.c. |    0x09   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   subi   |    I    |  0x0A  | d.c. |    0x0A   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   subui  |    I    |  0x0B  | d.c. |    0x0B   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   andi   |    I    |  0x0C  | d.c. |    0x0C   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    ori   |    I    |  0x0D  | d.c. |    0x0D   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   xori   |    I    |  0x0E  | d.c. |    0x0E   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    lhi   |    I    |  0x0F  | d.c. |    0x0F   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    rfe   |    J    |  0x10  | d.c. |    0x10   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   trap   |    J    |  0x11  | d.c. |    0x11   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    jr    |    I    |  0x12  | d.c. |    0x12   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   jalr   |    I    |  0x13  | d.c. |    0x13   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   slli   |    I    |  0x14  | d.c. |    0x14   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    nop   |    I    |  0x15  | d.c. |    0x15   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   srli   |    I    |  0x16  | d.c. |    0x16   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   srai   |    I    |  0x17  | d.c. |    0x17   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   seqi   |    I    |  0x18  | d.c. |    0x18   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   snei   |    I    |  0x19  | d.c. |    0x19   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   slti   |    I    |  0x1A  | d.c. |    0x1A   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   sgti   |    I    |  0x1B  | d.c. |    0x1B   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   slei   |    I    |  0x1C  | d.c. |    0x1C   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   sgei   |    I    |  0x1D  | d.c. |    0x1D   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |   I/J   |  0x1E  | d.c. |    0x1E   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |   I/J   |  0x1F  | d.c. |    0x1F   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    lb    |    I    |  0x20  | d.c. |    0x20   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    lh    |    I    |  0x21  | d.c. |    0x21   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |   I/J   |  0x22  | d.c. |    0x22   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    lw    |    I    |  0x23  | d.c. |    0x23   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    lbu   |    I    |  0x24  | d.c. |    0x24   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    lhu   |    I    |  0x25  | d.c. |    0x25   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    lf    |    I    |  0x26  | d.c. |    0x26   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    ld    |    I    |  0x27  | d.c. |    0x27   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    sb    |    I    |  0x28  | d.c. |    0x28   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    sh    |    I    |  0x29  | d.c. |    0x29   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |   I/J   |  0x2A  | d.c. |    0x2A   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    sw    |    I    |  0x2B  | d.c. |    0x2B   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |   I/J   |  0x2C  | d.c. |    0x2C   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |   I/J   |  0x2D  | d.c. |    0x2D   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    sf    |    I    |  0x2E  | d.c. |    0x2E   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    sd    |    I    |  0x2F  | d.c. |    0x2F   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |   I/J   |  0x30  | d.c. |    0x30   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |   I/J   |  0x31  | d.c. |    0x31   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |   I/J   |  0x32  | d.c. |    0x32   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |   I/J   |  0x33  | d.c. |    0x33   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |   I/J   |  0x34  | d.c. |    0x34   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |   I/J   |  0x35  | d.c. |    0x35   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |   I/J   |  0x36  | d.c. |    0x36   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |   I/J   |  0x37  | d.c. |    0x37   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   itlb   |    I    |  0x38  | d.c. |    0x38   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |   I/J   |  0x39  | d.c. |    0x39   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   sltui  |    I    |  0x3A  | d.c. |    0x3A   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   sgtui  |    I    |  0x3B  | d.c. |    0x3B   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   sleui  |    I    |  0x3C  | d.c. |    0x3C   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   sgeui  |    I    |  0x3D  | d.c. |    0x3D   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    sll   |    R    |  0x00  | 0x04 |    0x3E   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x05 |    0x3F   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    srl   |    R    |  0x00  | 0x06 |    0x40   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    sra   |    R    |  0x00  | 0x07 |    0x41   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x08 |    0x42   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x09 |    0x43   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x0A |    0x44   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x0B |    0x45   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x0C |    0x46   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x0D |    0x47   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   mult   |    R    |  0x00  | 0x0E |    0x48   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x0F |    0x49   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x10 |    0x4A   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x11 |    0x4B   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x12 |    0x4C   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x13 |    0x4D   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x14 |    0x4E   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x15 |    0x4F   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   multu  |    R    |  0x00  | 0x16 |    0x50   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x17 |    0x51   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x18 |    0x52   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x19 |    0x53   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x1A |    0x54   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x1B |    0x55   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x1C |    0x56   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x1D |    0x57   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x1E |    0x58   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x1F |    0x59   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    add   |    R    |  0x00  | 0x20 |    0x5A   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   addu   |    R    |  0x00  | 0x21 |    0x5B   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    sub   |    R    |  0x00  | 0x22 |    0x5C   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   subu   |    R    |  0x00  | 0x23 |    0x5D   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    and   |    R    |  0x00  | 0x24 |    0x5E   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    or    |    R    |  0x00  | 0x25 |    0x5F   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    xor   |    R    |  0x00  | 0x26 |    0x60   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x27 |    0x61   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    seq   |    R    |  0x00  | 0x28 |    0x62   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    sne   |    R    |  0x00  | 0x29 |    0x63   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    slt   |    R    |  0x00  | 0x2A |    0x64   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    sgt   |    R    |  0x00  | 0x2B |    0x65   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    sle   |    R    |  0x00  | 0x2C |    0x66   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    sge   |    R    |  0x00  | 0x2D |    0x67   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x2E |    0x68   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x2F |    0x69   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |  movi2s  |    R    |  0x00  | 0x30 |    0x6A   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |  movs2i  |    R    |  0x00  | 0x31 |    0x6B   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   movf   |    R    |  0x00  | 0x32 |    0x6C   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   movd   |    R    |  0x00  | 0x33 |    0x6D   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |  movfp2i |    R    |  0x00  | 0x34 |    0x6E   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |  movi2fp |    R    |  0x00  | 0x35 |    0x6F   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |  movi2t  |    R    |  0x00  | 0x36 |    0x70   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |  movt2i  |    R    |  0x00  | 0x37 |    0x71   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x38 |    0x72   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    NOP   |    R    |  0x00  | 0x39 |    0x73   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   sltu   |    R    |  0x00  | 0x3A |    0x74   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   sgtu   |    R    |  0x00  | 0x3B |    0x75   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   sleu   |    R    |  0x00  | 0x3C |    0x76   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   sgeu   |    R    |  0x00  | 0x3D |    0x77   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   addf   |    FP   |  0x01  | 0x00 |    0x78   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   subf   |    FP   |  0x01  | 0x01 |    0x79   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   multf  |    FP   |  0x01  | 0x02 |    0x7A   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   divf   |    FP   |  0x01  | 0x03 |    0x7B   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   addd   |    FP   |  0x01  | 0x04 |    0x7C   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   subd   |    FP   |  0x01  | 0x05 |    0x7D   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   multd  |    FP   |  0x01  | 0x06 |    0x7E   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   divd   |    FP   |  0x01  | 0x07 |    0x7F   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |  cvtf2d  |    FP   |  0x01  | 0x08 |    0x80   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |  cvtf2i  |    FP   |  0x01  | 0x09 |    0x81   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |  cvtd2f  |    FP   |  0x01  | 0x0A |    0x82   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |  cvtd2i  |    FP   |  0x01  | 0x0B |    0x83   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |  cvti2f  |    FP   |  0x01  | 0x0C |    0x84   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |  cvti2d  |    FP   |  0x01  | 0x0D |    0x85   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   mult   |    FP   |  0x01  | 0x0E |    0x86   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    div   |    FP   |  0x01  | 0x0F |    0x87   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    eqf   |    FP   |  0x01  | 0x10 |    0x88   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    nef   |    FP   |  0x01  | 0x11 |    0x89   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    ltf   |    FP   |  0x01  | 0x12 |    0x8A   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    gtf   |    FP   |  0x01  | 0x13 |    0x8B   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    lef   |    FP   |  0x01  | 0x14 |    0x8C   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    gef   |    FP   |  0x01  | 0x15 |    0x8D   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   multu  |    FP   |  0x01  | 0x16 |    0x8E   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |   divu   |    FP   |  0x01  | 0x17 |    0x8F   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    eqd   |    FP   |  0x01  | 0x18 |    0x90   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    ned   |    FP   |  0x01  | 0x19 |    0x91   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    ltd   |    FP   |  0x01  | 0x1A |    0x92   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    gtd   |    FP   |  0x01  | 0x1B |    0x93   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000", -- |    led   |    FP   |  0x01  | 0x1C |    0x94   |
		-- +-------------------------+----------+---------+--------+------+-----------+
		"0000000000000000000000" --  |    ged   |    FP   |  0x01  | 0x1D |    0x95   |
		-- +-------------------------+----------+---------+--------+------+-----------+
	);

	SIGNAL IR_opcode  : STD_LOGIC_VECTOR(OPCODE_SIZE - 1 DOWNTO 0); -- Op Code field
	SIGNAL int_opcode : NATURAL;                                    -- IR_opcode -> [integer type]
	SIGNAL IR_func    : STD_LOGIC_VECTOR(FUNC_SIZE DOWNTO 0);       -- Func Field
	SIGNAL int_func   : NATURAL;                                    -- IR_func -> [integer type]

	SIGNAL cw  : STD_LOGIC_VECTOR(CW_SIZE - 1 DOWNTO 0);  -- full control word
	SIGNAL cw1 : STD_LOGIC_VECTOR(CW_SIZE - 1 DOWNTO 0);  -- first stage cw
	SIGNAL cw2 : STD_LOGIC_VECTOR(CW_SIZE - 2 DOWNTO 0);  -- second stage cw
	SIGNAL cw3 : STD_LOGIC_VECTOR(CW_SIZE - 7 DOWNTO 0);  -- third stage cw
	SIGNAL cw4 : STD_LOGIC_VECTOR(CW_SIZE - 12 DOWNTO 0); -- fourth stage cw
	SIGNAL cw5 : STD_LOGIC_VECTOR(CW_SIZE - 19 DOWNTO 0); -- fifth stage cw

	SIGNAL ALU_op  : ALU_MSG; -- ALU Op Code
	SIGNAL ALU_op1 : ALU_MSG; -- delay: 1 cc
	SIGNAL ALU_op2 : ALU_MSG; -- delay: 2 cc
	SIGNAL ALU_op3 : ALU_MSG; -- delay: 3 cc (actual)

	SIGNAL FPU_op  : FPU_MSG; -- FPU Op Code
	SIGNAL FPU_op1 : FPU_MSG; -- delay: 1 cc
	SIGNAL FPU_op2 : FPU_MSG; -- delay: 2 cc
	SIGNAL FPU_op3 : FPU_MSG; -- delay: 3 cc (actual)

BEGIN
	-- parse fields of interest from input IR
	IR_opcode  <= IR_IN(IR_SIZE - 1 DOWNTO IR_SIZE - OPCODE_SIZE);
	int_opcode <= TO_INTEGER(UNSIGNED(IR_opcode));
	IR_func    <= IR_IN(FUNC_SIZE - 1 DOWNTO 0);
	int_func   <= TO_INTEGER(UNSIGNED(IR_func));

	-- stage one control signals
	IF_LATCH_EN <= cw1(CW_SIZE - 1);

	-- stage two control signals
	DEC_OUTREG_EN <= cw2(CW_SIZE - 2);
	IS_I_TYPE     <= cw2(CW_SIZE - 3);
	RD1_EN        <= cw2(CW_SIZE - 4);
	RD2_EN        <= cw2(CW_SIZE - 5);
	ZERO_PADDING2 <= cw2(CW_SIZE - 6);

	-- stage three control signals
	MUXA_SEL      <= cw3(CW_SIZE - 7);
	MUXB_SEL      <= cw3(CW_SIZE - 8);
	EXE_OUTREG_EN <= cw3(CW_SIZE - 9);
	EQ_COND       <= cw3(CW_SIZE - 10);
	JUMP_EN       <= cw3(CW_SIZE - 11);
	-- output execution
	ALU_OPCODE <= ALU_op3;
	FPU_OPCODE <= FPU_op3;

	-- stage four control signals
	PC_LATCH_EN   <= cw4(CW_SIZE - 12);
	MEM_OUTREG_EN <= cw4(CW_SIZE - 13);
	ZERO_PADDING4 <= cw4(CW_SIZE - 14);
	MEM_OUT_SEL   <= cw4(CW_SIZE - 15);
	DRAM_WE       <= cw4(CW_SIZE - 16);
	BYTE_LEN      <= cw4(CW_SIZE - 17 DOWNTO CW_SIZE - 18);

	-- stage five control signals
	WB_MUX_SEL  <= cw5(CW_SIZE - 19);
	JAL_MUX_SEL <= cw5(CW_SIZE - 20);
	WR_EN       <= cw5(CW_SIZE - 21);
	WB_LATCH_EN <= cw5(CW_SIZE - 22);

	CW_PIPE : PROCESS (Rst, Clk)
	BEGIN
		IF (Rst = '0') THEN
			-- control word
			cw1 <= (OTHERS => '0');
			cw2 <= (OTHERS => '0');
			cw3 <= (OTHERS => '0');
			cw4 <= (OTHERS => '0');
			cw5 <= (OTHERS => '0');

			-- ALU
			ALU_op1 <= nop;
			ALU_op2 <= nop;
			ALU_op3 <= nop;

			-- FPU
			FPU_op1 <= nop;
			FPU_op2 <= nop;
			FPU_op3 <= nop;
		ELSIF rising_edge(Clk) THEN
			-- control word
			cw1 <= cw;
			cw2 <= cw1(CW_SIZE - 2 DOWNTO 0);
			cw3 <= cw2(CW_SIZE - 7 DOWNTO 0);
			cw4 <= cw3(CW_SIZE - 12 DOWNTO 0);
			cw5 <= cw4(CW_SIZE - 19 DOWNTO 0);

			-- ALU
			ALU_op1 <= ALU_op;
			ALU_op2 <= ALU_op1;
			ALU_op3 <= ALU_op2;

			-- FPU
			FPU_op1 <= FPU_op;
			FPU_op2 <= FPU_op1;
			FPU_op3 <= FPU_op2;
		END IF;
	END PROCESS CW_PIPE;

	EXE_ENC : PROCESS (int_opcode, int_func)
	BEGIN
		CASE int_opcode IS
				-- R-Type
			WHEN 16#00# =>
				CASE int_func IS
					WHEN 16#04# =>
						ALU_op <= R_sll;
					WHEN 16#06# =>
						ALU_op <= R_srl;
					WHEN 16#07# =>
						ALU_op <= R_sra;
					WHEN 16#20# =>
						ALU_op <= R_add;
					WHEN 16#21# =>
						ALU_op <= R_addu;
					WHEN 16#22# =>
						ALU_op <= R_sub;
					WHEN 16#23# =>
						ALU_op <= R_subu;
					WHEN 16#24# =>
						ALU_op <= R_and;
					WHEN 16#25# =>
						ALU_op <= R_or;
					WHEN 16#26# =>
						ALU_op <= R_xor;
					WHEN 16#28# =>
						ALU_op <= R_seq;
					WHEN 16#29# =>
						ALU_op <= R_sne;
					WHEN 16#2A# =>
						ALU_op <= R_slt;
					WHEN 16#2B# =>
						ALU_op <= R_sgt;
					WHEN 16#2C# =>
						ALU_op <= R_sle;
					WHEN 16#2D# =>
						ALU_op <= R_sge;
					WHEN 16#30# =>
						ALU_op <= R_movi2s;
					WHEN 16#31# =>
						ALU_op <= R_movs2i;
					WHEN 16#32# =>
						ALU_op <= R_movf;
					WHEN 16#33# =>
						ALU_op <= R_movd;
					WHEN 16#34# =>
						ALU_op <= R_movfp2i;
					WHEN 16#35# =>
						ALU_op <= R_movi2fp;
					WHEN 16#36# =>
						ALU_op <= R_movi2t;
					WHEN 16#37# =>
						ALU_op <= R_movt2i;
					WHEN 16#3A# =>
						ALU_op <= R_sltu;
					WHEN 16#3B# =>
						ALU_op <= R_sgtu;
					WHEN 16#3C# =>
						ALU_op <= R_sleu;
					WHEN 16#3D# =>
						ALU_op <= R_sgeu;
					WHEN OTHERS =>
						ALU_op <= nop;
				END CASE;

				-- FPU
			WHEN 16#01# =>
				CASE int_func IS
					WHEN 16#00# =>
						FPU_op <= addf;
					WHEN 16#01# =>
						FPU_op <= subf;
					WHEN 16#02# =>
						FPU_op <= multf;
					WHEN 16#03# =>
						FPU_op <= divf;
					WHEN 16#04# =>
						FPU_op <= addd;
					WHEN 16#05# =>
						FPU_op <= subd;
					WHEN 16#06# =>
						FPU_op <= multd;
					WHEN 16#07# =>
						FPU_op <= divd;
					WHEN 16#08# =>
						FPU_op <= cvtf2d;
					WHEN 16#09# =>
						FPU_op <= cvtf2i;
					WHEN 16#0A# =>
						FPU_op <= cvtd2f;
					WHEN 16#0B# =>
						FPU_op <= cvtd2i;
					WHEN 16#0C# =>
						FPU_op <= cvti2f;
					WHEN 16#0D# =>
						FPU_op <= cvti2d;
					WHEN 16#0E# =>
						FPU_op <= mult;
					WHEN 16#0F# =>
						FPU_op <= div;
					WHEN 16#10# =>
						FPU_op <= eqf;
					WHEN 16#11# =>
						FPU_op <= nef;
					WHEN 16#12# =>
						FPU_op <= ltf;
					WHEN 16#13# =>
						FPU_op <= gtf;
					WHEN 16#14# =>
						FPU_op <= lef;
					WHEN 16#15# =>
						FPU_op <= gef;
					WHEN 16#16# =>
						FPU_op <= multu;
					WHEN 16#17# =>
						FPU_op <= divu;
					WHEN 16#18# =>
						FPU_op <= eqd;
					WHEN 16#19# =>
						FPU_op <= ned;
					WHEN 16#1A# =>
						FPU_op <= ltd;
					WHEN 16#1B# =>
						FPU_op <= gtd;
					WHEN 16#1C# =>
						FPU_op <= led;
					WHEN 16#1D# =>
						FPU_op <= ged;
					WHEN OTHERS =>
						FPU_op <= nop;
				END CASE;

				-- I/J-Type
			WHEN 16#02# =>
				ALU_op <= J_j;
			WHEN 16#03# =>
				ALU_op <= J_jal;
			WHEN 16#04# =>
				ALU_op <= I_beqz;
			WHEN 16#05# =>
				ALU_op <= I_bnez;
			WHEN 16#06# =>
				ALU_op <= I_bfpt;
			WHEN 16#07# =>
				ALU_op <= I_bfpf;
			WHEN 16#08# =>
				ALU_op <= I_addi;
			WHEN 16#09# =>
				ALU_op <= I_addui;
			WHEN 16#0A# =>
				ALU_op <= I_subi;
			WHEN 16#0B# =>
				ALU_op <= I_subui;
			WHEN 16#0C# =>
				ALU_op <= I_andi;
			WHEN 16#0D# =>
				ALU_op <= I_ori;
			WHEN 16#0E# =>
				ALU_op <= I_xori;
			WHEN 16#0F# =>
				ALU_op <= I_lhi;
			WHEN 16#10# =>
				ALU_op <= J_rfe;
			WHEN 16#11# =>
				ALU_op <= J_trap;
			WHEN 16#12# =>
				ALU_op <= I_jr;
			WHEN 16#13# =>
				ALU_op <= I_jalr;
			WHEN 16#14# =>
				ALU_op <= I_slli;
			WHEN 16#15# =>
				ALU_op <= I_nop;
			WHEN 16#16# =>
				ALU_op <= I_srli;
			WHEN 16#17# =>
				ALU_op <= I_srai;
			WHEN 16#18# =>
				ALU_op <= I_seqi;
			WHEN 16#19# =>
				ALU_op <= I_snei;
			WHEN 16#1A# =>
				ALU_op <= I_slti;
			WHEN 16#1B# =>
				ALU_op <= I_sgti;
			WHEN 16#1C# =>
				ALU_op <= I_slei;
			WHEN 16#1D# =>
				ALU_op <= I_sgei;
			WHEN 16#20# =>
				ALU_op <= I_lb;
			WHEN 16#21# =>
				ALU_op <= I_lh;
			WHEN 16#23# =>
				ALU_op <= I_lw;
			WHEN 16#24# =>
				ALU_op <= I_lbu;
			WHEN 16#25# =>
				ALU_op <= I_lhu;
			WHEN 16#26# =>
				ALU_op <= I_lf;
			WHEN 16#27# =>
				ALU_op <= I_ld;
			WHEN 16#28# =>
				ALU_op <= I_sb;
			WHEN 16#29# =>
				ALU_op <= I_sh;
			WHEN 16#2B# =>
				ALU_op <= I_sw;
			WHEN 16#2E# =>
				ALU_op <= I_sf;
			WHEN 16#2F# =>
				ALU_op <= I_sd;
			WHEN 16#38# =>
				ALU_op <= I_itlb;
			WHEN 16#3A# =>
				ALU_op <= I_sltui;
			WHEN 16#3B# =>
				ALU_op <= I_sgtui;
			WHEN 16#3C# =>
				ALU_op <= I_sleui;
			WHEN 16#3D# =>
				ALU_op <= I_sgeui;
			WHEN OTHERS =>
				ALU_op <= nop;
		END CASE;
	END PROCESS EXE_ENC;

	CW_DEC : PROCESS (int_opcode, int_func)
		VARIABLE deriv_func : NATURAL; -- (IR_func + offset) to index R-Type & FP Ops inside microcode memory
	BEGIN
		IF (int_opcode = 16#00#) THEN    -- R-Type
			IF (int_func <= 16#3D#) THEN     -- valid
				deriv_func := int_func + 16#3A#; -- skip all I/J-Type Ops
				cw <= cw_code(deriv_func);
			ELSE                   -- out-of-range
				cw <= (OTHERS => '0'); -- NOP
			END IF;
		ELSIF (int_opcode = 16#01#) THEN -- FP
			IF (int_func <= 16#1D#) THEN     -- valid
				deriv_func := int_func + 16#78#; -- skip both I/J-Type and R-Type Ops
				cw <= cw_code(deriv_func);
			ELSE                   -- out-of-range
				cw <= (OTHERS => '0'); -- NOP
			END IF;
		ELSIF (int_opcode <= 16#3D#) THEN -- valid I/J-Type
			cw                <= cw_code(int_opcode);
		ELSE                   -- out-of-range
			cw <= (OTHERS => '0'); -- NOP
		END IF;
	END PROCESS CW_DEC;
END HARDWIRED;