LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.dlx_utils.ALL;

ENTITY ID_STAGE IS
	GENERIC
	(
		N_BITS_DATA  : NATURAL := NbitLong; -- # of bits
		N_BYTES_INST : NATURAL := NPC_GAP;
		RF_ADDR      : NATURAL := RF_ADDR;  -- # OF BITS FOR REGISTER FILE ADDRESS
		N_BITS_JUMP  : NATURAL := NbitJump; -- # OF BITS OF THE INPUT OF THE SIGN EXTENTION
		N_BITS_IMM   : NATURAL := NbitShort
	);
	PORT
	(
		-- Control ports
		CLK           : IN STD_LOGIC;
		RST           : IN STD_LOGIC;
		JAL_MUX_SEL   : IN STD_LOGIC;
		DEC_OUTREG_EN : IN STD_LOGIC; -- (A, B, Imm, NPC1, IR1) Registers Enable
		IS_I_TYPE     : IN STD_LOGIC; -- Detect I-Type Instructions for Sign Extension & Writing Address Selection
		RD1_EN        : IN STD_LOGIC; -- Register File Read 1 Enable
		RD2_EN        : IN STD_LOGIC; -- Register File Read 2 Enable
		WR_EN         : IN STD_LOGIC; -- enable writing port of the RF
		ZERO_PADDING2 : IN STD_LOGIC;
		-- Data ports
		I_CODE      : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- output of the memory to the IR
		NPC1_IN     : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
		DATA_IN     : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
		WR_ADDR_IN  : IN STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
		REGA_OUT    : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
		REGB_OUT    : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
		REGIMM_OUT  : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
		WR_ADDR_OUT : OUT STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
		NPC1_OUT    : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0)
	);
END ID_STAGE;

ARCHITECTURE STRUCTURAL OF ID_STAGE IS
	SIGNAL SIGN_EXT_OUT  : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
	SIGNAL SIGN_EXT_IN   : STD_LOGIC_VECTOR(N_BITS_JUMP - 1 DOWNTO 0);
	SIGNAL MUX_OUT       : STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
	SIGNAL ADD_RD1       : STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
	SIGNAL ADD_RD2       : STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
	SIGNAL ADD_WR        : STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
	SIGNAL ADD_WR_I_TYPE : STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
	SIGNAL ADD_WR_R_TYPE : STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);

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

	COMPONENT reg_file IS
		GENERIC
		(
			Dbits : NATURAL := NbitLong;
			Abits : NATURAL := RF_ADDR
		);
		PORT
		(
			CLK, RESET, ENABLE, RD1, RD2, WR : IN STD_LOGIC;
			ADD_WR, ADD_RD1, ADD_RD2         : IN STD_LOGIC_VECTOR(Abits - 1 DOWNTO 0);
			DATAIN                           : IN STD_LOGIC_VECTOR(Dbits - 1 DOWNTO 0);
			OUT1, OUT2                       : OUT STD_LOGIC_VECTOR(Dbits - 1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT gen_mux21 IS
		GENERIC
		(
			N : NATURAL := RF_ADDR -- # of bits
		);
		PORT
		(
			sel  : IN STD_LOGIC; -- selector
			x, y : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			m    : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT sign_ext IS
		GENERIC
		(
			N_IN0 : NATURAL := NbitJump;  -- first input # of bits (must be greater than N_IN1)
			N_IN1 : NATURAL := NbitShort; -- second input # of bits (reduced size)
			N_OUT : NATURAL := NbitLong   -- unique output # of bits (must be greater than both input sizes)
		);
		PORT
		(
			ctrl_in      : IN STD_LOGIC;
			zero_padding : IN STD_LOGIC;
			data_in      : IN STD_LOGIC_VECTOR(N_IN0 - 1 DOWNTO 0);
			data_ext     : OUT STD_LOGIC_VECTOR(N_OUT - 1 DOWNTO 0)
		);
	END COMPONENT;

BEGIN
	NPC1 : gen_reg GENERIC
	MAP (N => N_BITS_DATA)
	PORT MAP
	(
		clk      => CLK,
		rst      => RST,
		ld       => DEC_OUTREG_EN,
		data_in  => NPC1_IN,
		data_out => NPC1_OUT
	);

	IMM : gen_reg GENERIC
	MAP (N => N_BITS_DATA)
	PORT
	MAP (
	clk      => CLK,
	rst      => RST,
	ld       => DEC_OUTREG_EN,
	data_in  => SIGN_EXT_OUT,
	data_out => REGIMM_OUT
	);

	WR_ADDR : gen_reg GENERIC
	MAP (N => RF_ADDR)
	PORT
	MAP (
	clk      => CLK,
	rst      => RST,
	ld       => DEC_OUTREG_EN,
	data_in  => MUX_OUT,
	data_out => WR_ADDR_OUT
	);

	RF : reg_file GENERIC
	MAP (
	Dbits => N_BITS_DATA,
	Abits => RF_ADDR
	)
	PORT
	MAP (
	CLK     => CLK,
	RESET   => RST,
	ENABLE  => DEC_OUTREG_EN,
	RD1     => RD1_EN,
	RD2     => RD2_EN,
	WR      => WR_EN,
	ADD_WR  => ADD_WR,
	ADD_RD1 => ADD_RD1,
	ADD_RD2 => ADD_RD2,
	DATAIN  => DATA_IN,
	OUT1    => REGA_OUT,
	OUT2    => REGB_OUT
	);

	SIGN_EXTEND : sign_ext GENERIC
	MAP (
	N_IN0 => N_BITS_JUMP,
	N_IN1 => N_BITS_IMM,
	N_OUT => N_BITS_DATA
	)
	PORT
	MAP (
	ctrl_in      => IS_I_TYPE, -- 1 IF I-type INST(16bits), 0 IF NOT (26 bits)
	zero_padding => ZERO_PADDING2,
	data_in      => SIGN_EXT_IN,
	data_ext     => SIGN_EXT_OUT
	);

	MUX_WR_ADDR : gen_mux21 GENERIC
	MAP (N => RF_ADDR) -- # of bits
	PORT
	MAP (
	sel => IS_I_TYPE, -- selector, 1 IF I-TYPE, 0 OTHERWISE
	x   => ADD_WR_R_TYPE,
	y   => ADD_WR_I_TYPE,
	m   => MUX_OUT
	);

	ADD_RD1       <= I_CODE(25 DOWNTO 21);
	ADD_RD2       <= I_CODE(20 DOWNTO 16);
	ADD_WR        <= (RF_ADDR - 1 DOWNTO 0 => JAL_MUX_SEL) OR WR_ADDR_IN;
	ADD_WR_I_TYPE <= I_CODE(20 DOWNTO 16);
	ADD_WR_R_TYPE <= I_CODE(15 DOWNTO 11);
	SIGN_EXT_IN   <= I_CODE(25 DOWNTO 0);
END STRUCTURAL;