LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.dlx_utils.ALL;

ENTITY IF_STAGE IS
    GENERIC
    (
        N_BITS_PC   : NATURAL := NbitLong; -- # of bits
		N_BITS_INST : NATURAL := IR_N;
		N_BYTES_INST: NATURAL := NPC_GAP
    );
    PORT
    (
		-- Control ports
		CLK 		 : IN STD_LOGIC;
		RST			 : IN STD_LOGIC;
		IR_LATCH_EN  : IN STD_LOGIC; -- Instruction Register Latch Enable
		NPC_LATCH_EN : IN STD_LOGIC; -- NPC Register Latch Enable
		-- Data ports
		PC_IN		 : IN STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0);		
		IR_IN	     : IN STD_LOGIC_VECTOR(N_BITS_INST-1 downto 0); -- output of the memory to the IR
		PC_OUT		 : OUT STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0);
		IR_OUT	     : OUT STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0); 
		NPC_OUT		 : OUT STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0)

    );
END IF_STAGE;

ARCHITECTURE STRUCTURAL OF IF_STAGE IS

	SIGNAL PC_OUT_SIG: STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0);
	SIGNAL ADDER_OUT : STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0);
	
	COMPONENT gen_reg_sync IS
    	GENERIC
    	(
    	    N : NATURAL := NbitLong -- # of bits
    	);
    	PORT
    	(
    	    clk, rst, en : IN STD_LOGIC;
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

	PC: gen_reg_sync GENERIC MAP (
		N=>N_BITS_PC)
	PORT MAP(
		clk=>CLK,
		rst=>RST,
		en =>IR_LATCH_EN,
		data_in=>PC_IN,
		data_out=>PC_OUT_SIG
	);
	
	IR: gen_reg_sync GENERIC MAP (
		N=>N_BITS_INST)
	PORT MAP(
		clk=>CLK,
		rst=> RST,
		en =>IR_LATCH_EN,
		data_in=>IR_IN,
		data_out=>IR_OUT
	);
	NPC: gen_reg_sync GENERIC MAP (
		N=>N_BITS_PC)
	PORT MAP(
		clk=>CLK,
		rst=> RST,
		en =>NPC_LATCH_EN,
		data_in=>ADDER_OUT,
		data_out=>NPC_OUT
	);
	PC_ADDER: pc_add GENERIC MAP (
		N 	=> N_BITS_PC   ,
	    OP2 => N_BYTES_INST )
	PORT MAP(
    	    data_in  =>PC_OUT_SIG,
    	    data_out =>ADDER_OUT
	);
END STRUCTURAL;
