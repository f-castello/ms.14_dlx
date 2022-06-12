LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.dlx_utils.ALL;

ENTITY ID_STAGE IS
	GENERIC
	(
		N_BITS_PC    : NATURAL := NbitLong; -- # of bits
		N_BITS_INST  : NATURAL := IR_N;
		N_BYTES_INST : NATURAL := NPC_GAP;
		N_BITS_DATA  : NATURAL := NbitLong;
		RF_ADDR      : NATURAL := RF_ADDR;  -- # OF BITS FOR REGISTER FILE ADDRESS
		NBITS_JUMP   : NATURAL := NbitJump; -- # OF BITS OF THE INPUT OF THE SIGN EXTENTION
		NBITS_IMM    : NATURAL := NbitShort
	);
	PORT
	(
		-- Control ports
		CLK           : IN STD_LOGIC;
		RST           : IN STD_LOGIC;
		JAL_MUX_SEL   : IN STD_LOGIC;
		DEC_OUTREG_EN : IN STD_LOGIC; -- (A, B, Imm, NPC1, IR1) Registers Enable
		IS_I_TYPE     : IN STD_LOGIC; -- Detect I-Type Instructions for Sign Extension & Writing Address Selection
		RD1_en        : IN STD_LOGIC; -- Register File Read 1 Enable
		RD2_en        : IN STD_LOGIC; -- Register File Read 2 Enable
		WR_en         : IN STD_LOGIC; --enable writing port of the RF
		-- Data ports
		I_CODE      : IN STD_LOGIC_VECTOR(0 TO N_BITS_INST - 1); -- output of the memory to the IR
		NPC1_IN     : IN STD_LOGIC_VECTOR(0 TO N_BITS_PC - 1);
		DATA_IN     : IN STD_LOGIC_VECTOR(0 TO N_BITS_DATA - 1);
		WR_ADDR_IN  : IN STD_LOGIC_VECTOR(0 TO RF_ADDR - 1);
		REGA_OUT    : OUT STD_LOGIC_VECTOR(0 TO N_BITS_DATA - 1);
		REGB_OUT    : OUT STD_LOGIC_VECTOR(0 TO N_BITS_DATA - 1);
		REGIMM_OUT  : OUT STD_LOGIC_VECTOR(0 TO N_BITS_DATA - 1);
		WR_ADDR_OUT : OUT STD_LOGIC_VECTOR(0 TO RF_ADDR - 1);
		NPC1_OUT    : OUT STD_LOGIC_VECTOR(0 TO N_BITS_PC - 1) --IN EX STAGE, THE INPUT 0 OF FIRST MUX SHOULD BE THIS REGISTER?
	);
END ID_STAGE;

ARCHITECTURE STRUCTURAL OF ID_STAGE IS
	COMPONENT gen_reg IS
		GENERIC
		(
			N : NATURAL := NbitLong -- # of bits
		);
		PORT
		(
			clk, rst, ld : IN STD_LOGIC;
			data_in      : IN STD_LOGIC_VECTOR(0 TO N - 1);
			data_out     : OUT STD_LOGIC_VECTOR(0 TO N - 1)
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
			ADD_WR, ADD_RD1, ADD_RD2         : IN STD_LOGIC_VECTOR(0 TO Abits - 1);
			DATAIN                           : IN STD_LOGIC_VECTOR(0 TO Dbits - 1);
			OUT1, OUT2                       : OUT STD_LOGIC_VECTOR(0 TO Dbits - 1)
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
			x, y : IN STD_LOGIC_VECTOR(0 TO N - 1);
			m    : OUT STD_LOGIC_VECTOR(0 TO N - 1)
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
			ctrl_in  : IN STD_LOGIC;
			data_in  : IN STD_LOGIC_VECTOR(0 TO N_IN0 - 1);
			data_ext : OUT STD_LOGIC_VECTOR(0 TO N_OUT - 1)
		);
	END COMPONENT;

	SIGNAL REGA_OUT_INT  : STD_LOGIC_VECTOR(0 TO N_BITS_DATA - 1);
	SIGNAL REGB_OUT_INT  : STD_LOGIC_VECTOR(0 TO N_BITS_DATA - 1);
	SIGNAL SIGN_EXT_OUT  : STD_LOGIC_VECTOR(0 TO N_BITS_DATA - 1);
	SIGNAL SIGN_EXT_IN   : STD_LOGIC_VECTOR(0 TO NBITS_JUMP - 1);
	SIGNAL MUX_OUT       : STD_LOGIC_VECTOR(0 TO RF_ADDR - 1);
	SIGNAL ADD_RD1       : STD_LOGIC_VECTOR(0 TO RF_ADDR - 1);
	SIGNAL ADD_RD1_AUX   : STD_LOGIC_VECTOR(0 TO RF_ADDR - 1);
	SIGNAL ADD_RD2       : STD_LOGIC_VECTOR(0 TO RF_ADDR - 1);
	SIGNAL ADD_WR        : STD_LOGIC_VECTOR(0 TO RF_ADDR - 1);
	SIGNAL ADD_WR_I_TYPE : STD_LOGIC_VECTOR(0 TO RF_ADDR - 1);
	SIGNAL ADD_WR_R_TYPE : STD_LOGIC_VECTOR(0 TO RF_ADDR - 1);

BEGIN
	NPC1 : gen_reg GENERIC
	MAP (
	N => N_BITS_PC)
	PORT MAP
	(
		clk      => CLK,
		rst      => RST,
		ld       => DEC_OUTREG_EN,
		data_in  => NPC1_IN,
		data_out => NPC1_OUT
	);

	IMM : gen_reg GENERIC
	MAP (
	N => N_BITS_DATA)
	PORT
	MAP(
	clk      => CLK,
	rst      => RST,
	ld       => DEC_OUTREG_EN,
	data_in  => SIGN_EXT_OUT,
	data_out => REGIMM_OUT
	);

	WR_ADDR : gen_reg GENERIC
	MAP (
	N => RF_ADDR)
	PORT
	MAP(
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
	MAP
	(
	CLK     => CLK,
	RESET   => RST,
	ENABLE  => DEC_OUTREG_EN,
	RD1     => RD1_en,
	RD2     => RD2_en,
	WR      => WR_en,
	ADD_WR  => ADD_WR,
	ADD_RD1 => ADD_RD1,
	ADD_RD2 => ADD_RD2,
	DATAIN  => DATA_IN,
	OUT1    => REGA_OUT,
	OUT2    => REGB_OUT
	);

	SING_EXT : sign_ext GENERIC
	MAP (
	N_IN0 => NBITS_JUMP,
	N_IN1 => NBITS_IMM,
	N_OUT => N_BITS_DATA
	)
	PORT
	MAP(
	ctrl_in  => IS_I_TYPE, --1 IF I-type INST(16bits), 0 IF NOT (26 bits)
	data_in  => SIGN_EXT_IN,
	data_ext => SIGN_EXT_OUT
	);

	MUX_WR_ADDR : gen_mux21 GENERIC
	MAP (
	N => RF_ADDR) -- # of bits
	PORT
	MAP(
	sel => IS_I_TYPE, -- selector, 1 IF I-TYPE, 0 OTHERWISE
	x   => ADD_WR_R_TYPE,
	y   => ADD_WR_I_TYPE,
	m   => MUX_OUT
	);

	ADD_RD1_AUX <= I_CODE(21 TO 25);
	-- THE FOLLOWING LINE MIGHT NOT BE NECESSARY, THIS COULD BE HANDLED WITH THE RD1 SIGNAL (IF = 0 IT TURN TO 0 THE READING PORT 1 OF THE RF)
	ADD_RD1       <= ADD_RD1_AUX;--(0 TO RF_ADDR - 1 => NOT(JAL_MUX_SEL)) AND ADD_RD1_AUX; --JAL_MUX_SEL MASKS THE RD1 ADDR IN JUMP AND JL INST, SELECTING THE REG 0 (ALWAYS 0)
	ADD_RD2       <= I_CODE(16 TO 20);                                --ONLY FOR R-TYPE, DON'T MIND IN OTHER TYPES
	ADD_WR        <= (0 TO RF_ADDR - 1 => JAL_MUX_SEL) OR WR_ADDR_IN; --JAL_MUX_SEL MASKS THE WR ADDR IN JUMP AND LINK INST, SELECTING THE REG 31
	ADD_WR_I_TYPE <= I_CODE(16 TO 20);-- I-TYPE INST: 31|OPCODE 6BITS|RS1 5BITS| RD 5BITS|    IMMEDIATE 16BITS     |0
	ADD_WR_R_TYPE <= I_CODE(11 TO 15);-- R-TYPE INST: 31|OPCODE 6BITS|RS1 5BITS|RS2 5BITS| RD 5BITS|  FUNC 11BITS  |0

	SIGN_EXT_IN <= I_CODE(0 TO 25);
END STRUCTURAL;