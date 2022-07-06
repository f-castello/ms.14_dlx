LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_MEM IS
END TB_MEM;

ARCHITECTURE TEST OF TB_MEM IS

		TYPE MEM_ARRAY IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
    SIGNAL DATA_MEM : MEM_ARRAY :=
    (
    STD_LOGIC_VECTOR(to_unsigned(0, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(101111, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(202, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(3033, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(40, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(50555, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(60666666, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(70, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(80888888, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(90, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(1000, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(11, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(12, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(13, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(14, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(15, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(16, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(17, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(18, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(19, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(20, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(21, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(22, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(23, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(24, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(25, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(26, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(27, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(28, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(29, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(30, NbitLong)),
    STD_LOGIC_VECTOR(to_unsigned(31, NbitLong))
    );



		SIGNAL CLK_tb			: STD_LOGIC := '0';
		SIGNAL RST_tb       	: STD_LOGIC;
		SIGNAL MEM_OUTREG_EN_tb : STD_LOGIC;
		SIGNAL ZERO_PADDING_tb  : STD_LOGIC;
		SIGNAL BYTE_LOAD_tb	    : STD_LOGIC;
        SIGNAL MEM_OUT_SEL_tb	: STD_LOGIC; -- 0 sel sign extension output, otherwise data mem output	
		SIGNAL BYTE_LEN_IN_tb	: STD_LOGIC_VECTOR(1 downto 0);
		SIGNAL DRAM_WE_tb	    : STD_LOGIC;
		
		SIGNAL DRAM_WE_OUT_tb   : STD_LOGIC;
		SIGNAL BYTE_LEN_OUT_tb  : STD_LOGIC_VECTOR(1 downto 0);
		
		
		-- Data ports
		SIGNAL BRA_IN_tb 	   	: STD_LOGIC; -- BRA reg input (for jump selection)
		SIGNAL JUMP_MUX_IN_0_tb : STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0); -- Input 0 of the multiplexer for jumping (NPC)
		SIGNAL ALU_OUTPUT_IN_tb : STD_LOGIC_VECTOR(N_BITS_DATA-1 downto 0); -- 
		SIGNAL MEM_DATA_IN_tb   : STD_LOGIC_VECTOR(N_BITS_DATA - 1 downto 0); -- input data of data memory
		SIGNAL MEM_DATA_OUT_tb  : STD_LOGIC_VECTOR(N_BITS_DATA - 1 downto 0); --input of sign extention module

		SIGNAL NPC_IN_tb		: STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0); --
		SIGNAL IR_IN_tb		    : STD_LOGIC_VECTOR(RF_ADDR-1 downto 0);   

		SIGNAL IR_OUT_tb		: STD_LOGIC_VECTOR(RF_ADDR-1 downto 0);
		SIGNAL NPC_OUT_tb		: STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0); --   
		SIGNAL MEM_ADDR_OUT_tb	: STD_LOGIC_VECTOR(N_BITS_DATA - 1 downto 0); -- address data memory (connected to alu output)
		SIGNAL MEM_DATA_IN_PRIME_tb: STD_LOGIC_VECTOR(N_BITS_DATA - 1 downto 0); -- input data of data memory
		SIGNAL LMD_OUT_tb       : STD_LOGIC_VECTOR(N_BITS_DATA - 1 downto 0); --output of the memory ->
		SIGNAL ALU_OUTPUT_OUT_tb: STD_LOGIC_VECTOR(N_BITS_DATA-1 downto 0); --output of register ALU_OUTPUT
		SIGNAL ADDR_MUX_OUT_tb  : STD_LOGIC_VECTOR(N_BITS_PC - 1 downto 0);


	COMPONENT MEM_STAGE IS
	GENERIC 
	(
		N_BITS_PC   : NATURAL := N_BITS_PC; -- # of bits
		N_BITS_DATA : NATURAL := N_BITS_DATA;
		RF_ADDR     : NATURAL := RF_ADDR -- # OF BITS FOR REGISTER FILE ADDRESS
		
	);
	PORT
	(
		-- Control ports 
		CLK 		  : IN STD_LOGIC;
		RST           : IN STD_LOGIC;
		MEM_OUTREG_EN : IN STD_LOGIC;
		ZERO_PADDING  : IN STD_LOGIC;
		BYTE_LOAD     : IN STD_LOGIC;
        MEM_OUT_SEL   : IN STD_LOGIC; -- 0 sel sign extension output, otherwise data mem output	
		BYTE_LEN_IN   : IN STD_LOGIC_VECTOR(1 downto 0);
		DRAM_WE       : IN STD_LOGIC;
		
		DRAM_WE_OUT   : OUT STD_LOGIC;
		BYTE_LEN_OUT  : OUT STD_LOGIC_VECTOR(1 downto 0);
		
		
		-- Data ports
		BRA_IN 	   	   		: IN STD_LOGIC; -- BRA reg input (for jump selection)
		JUMP_MUX_IN_0  		: IN STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0); -- Input 0 of the multiplexer for jumping (NPC)
		ALU_OUTPUT_IN		: IN STD_LOGIC_VECTOR(N_BITS_DATA-1 downto 0); -- 
		MEM_DATA_IN    		: IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 downto 0); -- input data of data memory
		MEM_DATA_OUT   		: IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 downto 0); --input of sign extention module

		NPC_IN				: IN STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0); --
		IR_IN				: IN STD_LOGIC_VECTOR(RF_ADDR-1 downto 0);   

		IR_OUT				: OUT STD_LOGIC_VECTOR(RF_ADDR-1 downto 0);
		NPC_OUT				: OUT STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0); --   
		MEM_ADDR_OUT	    : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 downto 0); -- address data memory (connected to alu output)
		MEM_DATA_IN_PRIME   : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 downto 0); -- input data of data memory
		LMD_OUT           	: OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 downto 0); --output of the memory ->
		ALU_OUTPUT_OUT  	: OUT STD_LOGIC_VECTOR(N_BITS_DATA-1 downto 0); --output of register ALU_OUTPUT
		ADDR_MUX_OUT		: OUT STD_LOGIC_VECTOR(N_BITS_PC - 1 downto 0)

		);
	END COMPONENT;

BEGIN
	DUT : MEM_STAGE 
	GENERIC MAP(
		N_BITS_PC   => N_BITS_PC, -- # of bits PC
		N_BITS_DATA => N_BITS_DATA,
		RF_ADDR     => RF_ADDR -- # OF BITS FOR REGISTER FILE ADDRESS
	)
	PORT MAP(
		CLK				=>CLK_tb,
		RST				=>RST_tb,
		MEM_OUTREG_EN	=>MEM_OUTREG_EN_tb,
		ZERO_PADDING	=>ZERO_PADDING_tb,
		BYTE_LOAD		=>BYTE_LOAD_tb,
        MEM_OUT_SEL		=>MEM_OUT_SEL_tb,
		BYTE_LEN_IN		=>BYTE_LEN_IN_tb,
		DRAM_WE			=>DRAM_WE_tb,
		
		DRAM_WE_OUT		=>DRAM_WE_OUT_tb,
		BYTE_LEN_OUT    =>BYTE_LEN_OUT_tb,		
		
		-- Data ports
		BRA_IN			=>BRA_IN_tb,
		JUMP_MUX_IN_0	=>JUMP_MUX_IN_0_tb,
		ALU_OUTPUT_IN	=>ALU_OUTPUT_IN_tb,
		MEM_DATA_IN		=>MEM_DATA_IN_tb,
		MEM_DATA_OUT	=>MEM_DATA_OUT_tb,

		NPC_IN			=>NPC_IN_tb,
		IR_IN			=>IR_IN_tb,

		IR_OUT			=>IR_OUT_tb,
		NPC_OUT			=>NPC_OUT_tb,
		MEM_ADDR_OUT	=>MEM_ADDR_OUT_tb,
		MEM_DATA_IN_PRIME=>MEM_DATA_IN_PRIME_tb,
		LMD_OUT			=>LMD_OUT_tb,
		ALU_OUTPUT_OUT	=>ALU_OUTPUT_OUT_tb,
		ADDR_MUX_OUT	=>ADDR_MUX_OUT_tb
	);

	P_STIMULI : PROCESS
		VARIABLE i   : INTEGER := 0;
	BEGIN
	--############################ TEST 1  ############################--
        REPORT("Starting simulation");
        REPORT("TEST 1: reset test");
		RST_tb           <= '0'; -- Reset all registers
		MEM_OUTREG_EN_tb <= '1'; --Enabling all pipeline registers
		
		
		--other signals
		ZERO_PADDING_tb  <= '1';--random value (shouldn't care)
		BYTE_LOAD_tb	 <= '0';
        MEM_OUT_SEL_tb	 <='0'; -- 0 sel sign extension output, otherwise data mem output	
		BYTE_LEN_IN_tb	 <="11";
		DRAM_WE_tb	     <='0';
		

		
		
		-- Data ports
		BRA_IN_tb 	   	 <= '1';-- BRA reg input (for jump selection)
		JUMP_MUX_IN_0_tb <= (OTHERS => '0'); -- Input 0 of the multiplexer for jumping (NPC)
		ALU_OUTPUT_IN_tb <= x"FF00FF02"; -- 
		MEM_DATA_IN_tb   <= x"000FF030"; -- random value
		MEM_DATA_OUT_tb  <= x"FFF00400"; --random value

		NPC_IN_tb		 <= x"00000000";
		IR_IN_tb		 <= "00010";
		WAIT UNTIL falling_edge(CLK_tb);

		ASSERT (IR_OUT_tb = "00000")
		REPORT " IR_OUT exp val: " & INTEGER'image(0) & " IRC_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(IR_OUT_tb)))
            SEVERITY failure;
		
		ASSERT (NPC_OUT_tb = x"00000000")
		REPORT " NPC_OUT exp val: " & INTEGER'image(0) & " NPT_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(NPC_OUT_tb)))
            SEVERITY failure;

		ASSERT (MEM_ADDR_OUT_tb = x"00000000")
		REPORT " MEM_ADDR_OUT exp val: " & INTEGER'image(0) & " MEM_ADDR_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(MEM_ADDR_OUT_tb)))
            SEVERITY failure;

		ASSERT (MEM_DATA_IN_PRIME_tb = x"00000000")
		REPORT " MEM_DATA_IN_PRIME exp val: " & INTEGER'image(0) & " MEM_DATA_IN_PRIME obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(MEM_DATA_IN_PRIME_tb)))
            SEVERITY failure;

		ASSERT (LMD_OUT_tb = x"00000000")
		REPORT " LMD_OUT exp val: " & INTEGER'image(0) & " LMD_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(LMD_OUT_tb)))
            SEVERITY failure;

		ASSERT (ALU_OUTPUT_OUT_tb = x"00000000")
		REPORT " ALU_OUTPUT_OUT exp val: " & INTEGER'image(0) & " ALU_OUTPUT_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(ALU_OUTPUT_OUT_tb)))
            SEVERITY failure;

		ASSERT (ADDR_MUX_OUT_tb = x"00000000")
		REPORT " ADDR_MUX_OUT exp val: " & INTEGER'image(0) & " ADDR_MUX_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(ADDR_MUX_OUT_tb)))
            SEVERITY failure;

--		ASSERT (DRAM_WE_OUT_tb = '0')
--		REPORT " DRAM_WE_OUT exp val: " & INTEGER'image(0) & " DRAM_WE_OUT obt val: " & -INTEGER'image(TO_INTEGER(UNSIGNED(DRAM_WE_OUT_tb)))
--            SEVERITY failure;

		ASSERT (BYTE_LEN_OUT_tb = "11")
		REPORT " BYTE_LEN_OUT exp val: " & INTEGER'image(0) & " BYTE_LEN_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(BYTE_LEN_OUT_tb)))
            SEVERITY failure;

		--IR_OUT_tb		 
		--NPC_OUT_tb		: STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0); --   
		--MEM_ADDR_OUT_tb	: STD_LOGIC_VECTOR(N_BITS_DATA - 1 downto 0); -- address data memory (connected to alu output)
		--MEM_DATA_IN_PRIME_tb: STD_LOGIC_VECTOR(N_BITS_DATA - 1 downto 0); -- input data of data memory
		--LMD_OUT_tb       : STD_LOGIC_VECTOR(N_BITS_DATA - 1 downto 0); --output of the memory ->
		--ALU_OUTPUT_OUT_tb: STD_LOGIC_VECTOR(N_BITS_DATA-1 downto 0); --output of register ALU_OUTPUT
		--ADDR_MUX_OUT_tb  : STD_LOGIC_VECTOR(N_BITS_PC - 1 downto 0)


		--READDDD
		--DRAM_WE_OUT_tb   : STD_LOGIC; -- read it 
		--BYTE_LEN_OUT_tb  : STD_LOGIC_VECTOR(1 downto 0); -- read it
	WAIT;

	END PROCESS;

	P_CLOCK : PROCESS (CLK_tb)
    BEGIN
        CLK_tb <= NOT(CLK_tb) AFTER 1 ns;
    END PROCESS;

END TEST;


CONFIGURATION CFG_TEST_MEM OF TB_MEM IS
	FOR TEST
	END FOR;
END CFG_TEST_MEM;

