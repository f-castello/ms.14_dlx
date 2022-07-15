LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.dlx_utils.ALL;

ENTITY EXE_STAGE IS
	GENERIC
	(
		N_BITS_DATA : NATURAL := NbitLong; -- # of bits for data
		RF_ADDR     : NATURAL := RF_ADDR   -- # OF BITS FOR REGISTER FILE ADDRESS
	);
	PORT
	(
		-- Control ports 
		CLK           : IN STD_LOGIC;
		RST           : IN STD_LOGIC;
		MUXA_SEL      : IN STD_LOGIC; -- MUXA Sel
		MUXB_SEL      : IN STD_LOGIC; -- MUXB Sel
		EXE_OUTREG_EN : IN STD_LOGIC; -- (ALU Output, ALU Flags, NPC2, IR2, Pad OP, Zero OP) Registers Enable
		EQ_COND       : IN STD_LOGIC; -- Branch if (not) Equal to Zero
		JUMP_EN       : IN STD_LOGIC; -- Jump Enable Signal for Cond Selection
		ALU_OPCODE    : IN ALU_MSG;   -- Custom Type for ALU Ops
		-- Data ports
		NPC2_IN       : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);  -- NPC2 reg input
		NPC1_MUXA_IN  : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);  -- Input 0 of the first multiplexer
		REGA_MUXA_IN  : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);  -- Input 1 of the first multiplexer
		REGB_MUXB_IN  : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);  -- Input 0 of the second multiplexer
		IMM_MUXB_IN   : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);  -- Input 1 of the second multiplexer
		PAD_IN        : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);  -- Pad OP reg input
		IR2_IN        : IN STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);      -- IR2 reg input
		JUMP_MUX_IN_0 : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);  -- Input 0 of the multiplexer for jumping (NPC)
		NPC2_OUT      : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- NPC2 reg output
		ALU_OUT       : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Output data of the ALU
		PAD_OUT       : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Pad OP reg output
		IR2_OUT       : OUT STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);     -- IR2 reg output
		ADDR_MUX_OUT  : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Program Counter mux output
		N_FLAG        : OUT STD_LOGIC;                                  -- Negative condition code flag ALU 
		Z_FLAG        : OUT STD_LOGIC;                                  -- Zero condition code flag ALU 
		C_FLAG        : OUT STD_LOGIC;                                  -- Carry condition code flag ALU 
		V_FLAG        : OUT STD_LOGIC                                   -- Overflow condition code flag ALU 
	);
END EXE_STAGE;

ARCHITECTURE STRUCTURAL OF EXE_STAGE IS
	COMPONENT gen_reg IS
		GENERIC
		(
			N : NATURAL := NbitLong -- # of bits
		);
		PORT
		(
			clk, rst, ld : IN STD_LOGIC;
			data_in      : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			data_out     : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT gen_mux21 IS
		GENERIC
		(
			N : NATURAL := NbitLong
		);
		PORT
		(
			sel  : IN STD_LOGIC; -- selector
			x, y : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			m    : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT zero_check IS
		GENERIC
		(
			N : NATURAL := NbitLong
		);
		PORT
		(
			data_in  : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			ctrl_out : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT cond_branch IS
		PORT
		(
			cond_in, jump_in, ctrl_in : IN STD_LOGIC;
			ctrl_out                  : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT cpsr IS
		PORT
		(
			clk, rst, ld, FL3, FL2, FL1, FL0 : IN STD_LOGIC;
			N, Z, C, V                       : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT ALU IS
		GENERIC
		(
			N : INTEGER := NbitLong
		);
		PORT
		(
			ALU_OPCODE            : IN ALU_MSG;
			DATA1, DATA2          : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			NEG, ZERO, CARRY, OVF : OUT STD_LOGIC;
			OUTALU                : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL BRANCH_TAKEN : STD_LOGIC;
	SIGNAL COND_OUT     : STD_LOGIC;
	SIGNAL MUXA_OUT_INT : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
	SIGNAL MUXB_OUT_INT : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
	SIGNAL ALU_OUT_INT  : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
	SIGNAL NEG_INT      : STD_LOGIC;
	SIGNAL ZERO_INT     : STD_LOGIC;
	SIGNAL OVF_INT      : STD_LOGIC;
	SIGNAL CARRY_INT    : STD_LOGIC;

BEGIN
	NPC2 : gen_reg GENERIC
	MAP (N => N_BITS_DATA)
	PORT MAP
	(
		clk      => CLK,
		rst      => RST,
		ld       => EXE_OUTREG_EN,
		data_in  => NPC2_IN,
		data_out => NPC2_OUT
	);

	ZERO : zero_check GENERIC
	MAP (N => N_BITS_DATA)
	PORT
	MAP (
	data_in  => REGA_MUXA_IN,
	ctrl_out => BRANCH_TAKEN
	);

	COND : cond_branch
	PORT
	MAP (
	cond_in  => EQ_COND,
	jump_in  => JUMP_EN,
	ctrl_in  => BRANCH_TAKEN,
	ctrl_out => COND_OUT
	);

	MUXA : gen_mux21 GENERIC
	MAP (N => N_BITS_DATA)
	PORT
	MAP (
	sel => MUXA_SEL,
	x   => NPC1_MUXA_IN,
	y   => REGA_MUXA_IN,
	m   => MUXA_OUT_INT
	);

	MUXB : gen_mux21 GENERIC
	MAP (N => N_BITS_DATA)
	PORT
	MAP (
	sel => MUXB_SEL,
	x   => REGB_MUXB_IN,
	y   => IMM_MUXB_IN,
	m   => MUXB_OUT_INT
	);

	ALRITH_LOG_U : alu GENERIC
	MAP (N => N_BITS_DATA)
	PORT
	MAP (
	ALU_OPCODE => ALU_OPCODE,
	DATA1      => MUXA_OUT_INT,
	DATA2      => MUXB_OUT_INT,
	NEG        => NEG_INT,
	ZERO       => ZERO_INT,
	CARRY      => CARRY_INT,
	OVF        => OVF_INT,
	OUTALU     => ALU_OUT_INT
	);

	ALU_OUTPUT : gen_reg GENERIC
	MAP (N => N_BITS_DATA)
	PORT
	MAP (
	clk      => CLK,
	rst      => RST,
	ld       => EXE_OUTREG_EN,
	data_in  => ALU_OUT_INT,
	data_out => ALU_OUT
	);

	ALU_FLAGS : cpsr
	PORT
	MAP (
	clk => CLK,
	rst => RST,
	ld  => EXE_OUTREG_EN,
	FL3 => NEG_INT,
	FL2 => ZERO_INT,
	FL1 => CARRY_INT,
	FL0 => OVF_INT,
	N   => N_FLAG,
	Z   => Z_FLAG,
	C   => C_FLAG,
	V   => V_FLAG
	);

	PAD : gen_reg GENERIC
	MAP (N => N_BITS_DATA)
	PORT
	MAP
	(
	clk      => CLK,
	rst      => RST,
	ld       => EXE_OUTREG_EN,
	data_in  => PAD_IN,
	data_out => PAD_OUT
	);

	IR2 : gen_reg GENERIC
	MAP (N => RF_ADDR)
	PORT
	MAP (
	clk      => CLK,
	rst      => RST,
	ld       => EXE_OUTREG_EN,
	data_in  => IR2_IN,
	data_out => IR2_OUT
	);

	ADDR_MUX : gen_mux21 GENERIC
	MAP (N => N_BITS_DATA)
	PORT
	MAP
	(
	sel => COND_OUT,
	x   => JUMP_MUX_IN_0,
	y   => ALU_OUT_INT,
	m   => ADDR_MUX_OUT
	);
END STRUCTURAL;