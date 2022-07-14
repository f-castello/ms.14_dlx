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
		BYTE_LEN_IN   : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		DRAM_WE       : IN STD_LOGIC;
		DRAM_WE_OUT   : OUT STD_LOGIC;
		BYTE_LEN_OUT  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		-- Data ports
		ALU_OUTPUT_IN     : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
		MEM_DATA_IN       : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- input data from EXE
		MEM_DATA_OUT_INT  : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- output data from memory
		NPC_IN            : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
		IR_IN             : IN STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
		IR_OUT            : OUT STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
		NPC_OUT           : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
		MEM_ADDR_OUT      : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- address data memory (connected to alu output)
		MEM_DATA_IN_PRIME : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- input data of data memory
		ALU_OUTPUT_OUT    : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- output of register ALU_OUTPUT
		MEM_DATA_OUT      : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0)  -- output data to WB
	);
END MEM_STAGE;

ARCHITECTURE STRUCTURAL OF MEM_STAGE IS
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

BEGIN
	-- Bypassing signals to the memory
	DRAM_WE_OUT       <= DRAM_WE;
	BYTE_LEN_OUT      <= BYTE_LEN_IN;
	MEM_ADDR_OUT      <= ALU_OUTPUT_IN;
	MEM_DATA_IN_PRIME <= MEM_DATA_IN;
	MEM_DATA_OUT      <= MEM_DATA_OUT_INT;

	PAD_ALU : gen_reg GENERIC
	MAP (N => N_BITS_DATA)
	PORT MAP
	(
		clk      => CLK,
		rst      => RST,
		ld       => MEM_OUTREG_EN,
		data_in  => ALU_OUTPUT_IN,
		data_out => ALU_OUTPUT_OUT
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
END STRUCTURAL;