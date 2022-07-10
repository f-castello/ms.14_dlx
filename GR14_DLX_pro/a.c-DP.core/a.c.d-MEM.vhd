LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.dlx_utils.ALL;

ENTITY MEM_STAGE IS
	GENERIC
	(
		N_BITS_DATA : NATURAL := NbitLong; -- # of bits
		RF_ADDR     : NATURAL := RF_ADDR   -- # OF BITS FOR REGISTER FILE ADDRESS
	);
	PORT
	(
		-- Control ports 
		CLK           : IN STD_LOGIC;
		RST           : IN STD_LOGIC;
		MEM_OUTREG_EN : IN STD_LOGIC;
		ZERO_PADDING4 : IN STD_LOGIC;
		MEM_OUT_SEL   : IN STD_LOGIC; -- 0 sel sign extension output, otherwise data mem output	
		BYTE_LEN_IN   : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		DRAM_WE       : IN STD_LOGIC;
		DRAM_WE_OUT   : OUT STD_LOGIC;
		BYTE_LEN_OUT  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		-- Data ports
		BRA_IN            : IN STD_LOGIC;                                  -- BRA reg input (for jump selection)
		JUMP_MUX_IN_0     : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Input 0 of the multiplexer for jumping (NPC)
		ALU_OUTPUT_IN     : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
		MEM_DATA_IN       : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- input data of data memory
		MEM_DATA_OUT_INT  : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- input of sign extention module
		NPC_IN            : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
		IR_IN             : IN STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
		IR_OUT            : OUT STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
		NPC_OUT           : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
		MEM_ADDR_OUT      : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- address data memory (connected to alu output)
		MEM_DATA_IN_PRIME : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- input data of data memory
		ALU_OUTPUT_OUT    : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- output of register ALU_OUTPUT
		MEM_DATA_OUT      : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Output data from memory (after mux)
		ADDR_MUX_OUT      : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0)
	);
END MEM_STAGE;

ARCHITECTURE STRUCTURAL OF MEM_STAGE IS
	SIGNAL DRAM_WE_AUX        : STD_LOGIC;
	SIGNAL BYTE_LEN_AUX       : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL JUMP_MUX_IN_1      : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Input 1 of the multiplexer for jumping (JUMP) connected to alu output
	SIGNAL MEM_ADDR_IN        : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- address of data memory
	SIGNAL BRA_OUT            : STD_LOGIC;
	SIGNAL SIGN_EXT_OUT       : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
	SIGNAL ALU_OUTPUT_OUT_AUX : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
	SIGNAL BRA_IN_AUX         : STD_LOGIC_VECTOR(0 DOWNTO 0); --auxiliary signal to connect to the register (requires an std_logic_vector)
	SIGNAL BRA_OUT_AUX        : STD_LOGIC_VECTOR(0 DOWNTO 0); --auxiliary signal to connect to the register

	COMPONENT sign_ext_alt IS
		GENERIC
		(
			N_IN0 : NATURAL := NbitShort; -- first input # of bits (must be greater than N_IN1): half word in this case
			N_IN1 : NATURAL := NbitByte;  -- second input # of bits (reduced size): byte in this case
			N_OUT : NATURAL := NbitLong   -- unique output # of bits (must be greater than both input sizes): word size in this case
		);
		PORT
		(
			ctrl_in      : IN STD_LOGIC;
			zero_padding : IN STD_LOGIC;
			data_in      : IN STD_LOGIC_VECTOR(N_IN0 - 1 DOWNTO 0);
			data_ext     : OUT STD_LOGIC_VECTOR(N_OUT - 1 DOWNTO 0)
		);
	END COMPONENT;

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
			N : NATURAL := NbitLong -- # of bits
		);
		PORT
		(
			sel  : IN STD_LOGIC; -- selector
			x, y : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			m    : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
		);
	END COMPONENT;

BEGIN
	--Bypassing signals to the memory
	DRAM_WE_AUX    <= DRAM_WE;
	DRAM_WE_OUT    <= DRAM_WE_AUX;
	BYTE_LEN_AUX   <= BYTE_LEN_IN;
	BYTE_LEN_OUT   <= BYTE_LEN_IN;
	MEM_ADDR_OUT   <= ALU_OUTPUT_OUT_AUX;
	ALU_OUTPUT_OUT <= ALU_OUTPUT_OUT_AUX;

	--Fixing problems in connections between STD_LOGIC_VECTOR AND STD_LOGIC	
	BRA_IN_AUX(0) <= BRA_IN;
	BRA_OUT       <= BRA_OUT_AUX(0);

	ADDR_MUX : gen_mux21 GENERIC
	MAP (N => N_BITS_DATA)
	PORT MAP
	(
		sel => BRA_OUT,
		x   => JUMP_MUX_IN_0,
		y   => ALU_OUTPUT_OUT_AUX,
		m   => ADDR_MUX_OUT
	);

	DATA_MUX : gen_mux21 GENERIC
	MAP (N => N_BITS_DATA)
	PORT
	MAP (
	sel => MEM_OUT_SEL,
	x   => SIGN_EXT_OUT,
	y   => MEM_DATA_OUT_INT,
	m   => MEM_DATA_OUT
	);

	BRA : gen_reg GENERIC
	MAP (N => 1)
	PORT
	MAP (
	clk      => CLK,
	rst      => RST,
	ld       => MEM_OUTREG_EN,
	data_in  => BRA_IN_AUX,
	data_out => BRA_OUT_AUX
	);

	ALU_OUTPUT : gen_reg GENERIC
	MAP (N => N_BITS_DATA)
	PORT
	MAP (
	clk      => CLK,
	rst      => RST,
	ld       => MEM_OUTREG_EN,
	data_in  => ALU_OUTPUT_IN,
	data_out => ALU_OUTPUT_OUT_AUX
	);

	NPC3 : gen_reg GENERIC
	MAP (N => N_BITS_DATA)
	PORT
	MAP (
	clk      => CLK,
	rst      => RST,
	ld       => MEM_OUTREG_EN,
	data_in  => NPC_IN,
	data_out => NPC_OUT
	);

	IR3 : gen_reg GENERIC
	MAP (N => RF_ADDR)
	PORT
	MAP (
	clk      => CLK,
	rst      => RST,
	ld       => MEM_OUTREG_EN,
	data_in  => IR_IN,
	data_out => IR_OUT
	);

	MEM_DATA_IN_REG : gen_reg GENERIC
	MAP (N => N_BITS_DATA)
	PORT
	MAP (
	clk      => CLK,
	rst      => RST,
	ld       => MEM_OUTREG_EN,
	data_in  => MEM_DATA_IN,
	data_out => MEM_DATA_IN_PRIME
	);

	SIGN_EXT_BLOCK : sign_ext_alt GENERIC
	MAP (
	N_IN0 => NbitShort,
	N_IN1 => NbitByte,
	N_OUT => N_BITS_DATA
	)
	PORT
	MAP (
	ctrl_in      => BYTE_LEN_IN(0), -- if 0, byte extension, Half W extension otherwise
	zero_padding => ZERO_PADDING4,
	data_in      => MEM_DATA_OUT_INT(15 DOWNTO 0),
	data_ext     => SIGN_EXT_OUT
	);
END STRUCTURAL;