LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_IF IS
END TB_IF;

ARCHITECTURE TEST OF TB_IF IS

	TYPE MEM_ARRAY IS ARRAY (19 downto 0) OF STD_LOGIC_VECTOR(IR_N-1 downto 0);
	CONSTANT IR_MEM_VALS : MEM_ARRAY  := 
	(
		"x00100001",
		"x10000001",
		"x00001110",
		"xF2300100",
		"x0ED00020",
		"x00A20004",
		"x01000026",
		"x00200007",
		"xFFF00009",
		"x0000FF0A",
		"x0D10100C",
		"x111DD001",
		"x00000002",
		"x0BB00205",
		"x88800009",
		"xAA0AA001",
		"xDEF00123",
		"x00000000",
		"x00000000",
		"x00000000",				
	);
	SIGNAL CLK_tb			IS STD_LOGIC;
	SIGNAL RST_tb			IS STD_LOGIC;
	SIGNAL IR_LATCH_EN_tb  	IS STD_LOGIC; -- Instruction Register Latch Enable
	SIGNAL NPC_LATCH_EN_tb	IS STD_LOGIC; -- NPC Register Latch Enable
			-- Data ports
	SIGNAL  PC_IN_tb		IS STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0);		
	SIGNAL  IR_IN_tb     	IS STD_LOGIC_VECTOR(N_BITS_INST-1 downto 0); -- output of the memory to the IR
	SIGNAL  PC_OUT_tb	 	IS STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0);
	SIGNAL  IR_OUT_tb    	IS STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0); 

	COMPONENT IF_STAGE IS
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
	END COMPONENT;

BEGIN 
	DUT: IF_STAGE 
	GENERIC MAP(
		N_BITS_PC 	=> NbitLong,
		N_BITS_INST => IR_N,
		N_BYTES_INST=> NPC_GAP
	)
	PORT MAP 
	(
		CLK			 	=> CLK_tb,
		RST			 	=> RST_tb,
		IR_LATCH_EN		=> IR_LATCH_EN_tb,
		NPC_LATCH_EN	=> NPC_LATCH_EN_tb,
		-- Data ports
		PC_IN			=> PC_IN_tb,
		IR_IN			=> IR_IN_tb,
		PC_OUT			=> PC_OUT_tb,
		IR_OUT			=> IR_OUT_tb,
		NPC_OUT			=> PC_IN_tb
	
	);

	IR_IN_tb		<=
	PC_IN_tb		<= 

	P_STIMULI : PROCESS
		VARIABLE i : NATURAL; -- counter to the position of the memory
	BEGIN
		REPORT("Starting simulation");
		RST_tb  		<= '1';
		IR_LATCH_EN_tb 	<= '1';
		NPC_LATCH_EN_tb	<= '1';
		IR_IN_tb		<= IR_MEM_VALS(TO_INTEGER(UNSIGNED(PC_OUT_tb)) MOD 19);

				

		------------------- TEST 1: FIRST WINDOW, GLOBAL REGISTERS AND READ AND WRITE AT THE SAME TIME ------------------
		WAIT UNTIL falling_edge(CLK_tb);
	P_CLOCK : PROCESS (CLK_tb)
	BEGIN
		CLK_tb <= NOT(CLK_tb) AFTER 1 ns;
	END PROCESS;

END TEST;
