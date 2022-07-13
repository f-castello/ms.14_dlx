LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.dlx_utils.ALL;

ENTITY IF_STAGE IS
	GENERIC
	(
		N_BITS_DATA  : NATURAL := NbitLong; -- # of bits
		N_BYTES_INST : NATURAL := NPC_GAP
	);
	PORT
	(
		-- Control ports
		CLK         : IN STD_LOGIC;
		RST         : IN STD_LOGIC;
		IF_LATCH_EN : IN STD_LOGIC; -- (NPC, IR) Register Latch Enable
		PC_LATCH_EN : IN STD_LOGIC; -- PC Register Latch Enable
		-- Data ports
		PC_IN   : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
		IR_IN   : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- output of the memory to the IR
		PC_OUT  : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
		IR_OUT  : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
		ADD_OUT : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
		NPC_OUT : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0)
	);
END IF_STAGE;

ARCHITECTURE STRUCTURAL OF IF_STAGE IS
	SIGNAL PC_OUT_SIG : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
	SIGNAL ADDER_OUT  : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
	SIGNAL NPC_INTA   : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
	SIGNAL NPC_INTB   : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);

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

	COMPONENT pc_add IS
		GENERIC
		(
			N   : NATURAL := NbitLong; -- # of bits
			OP2 : INTEGER := NPC_GAP   -- second "short-circuited" operand
		);
		PORT
		(
			data_in  : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			data_out : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
		);
	END COMPONENT;

BEGIN
	PC : gen_reg GENERIC
	MAP (N => N_BITS_DATA)
	PORT MAP
	(
		clk      => CLK,
		rst      => RST,
		ld       => PC_LATCH_EN,
		data_in  => PC_IN,
		data_out => PC_OUT_SIG
	);

	IR : gen_reg GENERIC
	MAP (N => N_BITS_DATA)
	PORT
	MAP (
	clk      => CLK,
	rst      => RST,
	ld       => IF_LATCH_EN,
	data_in  => IR_IN,
	data_out => IR_OUT
	);

	NPC0 : gen_reg GENERIC
	MAP (N => N_BITS_DATA)
	PORT
	MAP (
	clk      => CLK,
	rst      => RST,
	ld       => IF_LATCH_EN,
	data_in  => ADDER_OUT,
	data_out => NPC_INTA
	);

	NPCA : gen_reg GENERIC
	MAP (N => N_BITS_DATA)
	PORT
	MAP (
	clk      => CLK,
	rst      => RST,
	ld       => IF_LATCH_EN,
	data_in  => NPC_INTA,
	data_out => NPC_INTB
	);

	NPCB : gen_reg GENERIC
	MAP (N => N_BITS_DATA)
	PORT
	MAP (
	clk      => CLK,
	rst      => RST,
	ld       => IF_LATCH_EN,
	data_in  => NPC_INTB,
	data_out => NPC_OUT
	);

	PC_ADDER : pc_add GENERIC
	MAP (
	N   => N_BITS_DATA,
	OP2 => N_BYTES_INST
	)
	PORT
	MAP (
	data_in  => PC_OUT_SIG,
	data_out => ADDER_OUT
	);

	PC_OUT  <= PC_OUT_SIG;
	ADD_OUT <= ADDER_OUT;
END STRUCTURAL;