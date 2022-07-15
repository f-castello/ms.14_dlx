LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_MEM IS
END TB_MEM;

ARCHITECTURE TEST OF TB_MEM IS
	TYPE MEM_ARRAY IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
	CONSTANT DATA_MEM : MEM_ARRAY := (
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

	SIGNAL CLK_tb               : STD_LOGIC := '0';
	SIGNAL RST_tb               : STD_LOGIC;
	SIGNAL MEM_OUTREG_EN_tb     : STD_LOGIC;
	SIGNAL BYTE_LEN_IN_tb       : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL DRAM_WE_tb           : STD_LOGIC;
	SIGNAL DRAM_WE_OUT_tb       : STD_LOGIC;
	SIGNAL BYTE_LEN_OUT_tb      : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL ALU_OUTPUT_IN_tb     : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
	SIGNAL MEM_DATA_IN_tb       : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- input data from EXE
	SIGNAL MEM_DATA_OUT_INT_tb  : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- output data from memory
	SIGNAL NPC_IN_tb            : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
	SIGNAL IR_IN_tb             : STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
	SIGNAL IR_OUT_tb            : STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
	SIGNAL NPC_OUT_tb           : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
	SIGNAL MEM_ADDR_OUT_tb      : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- address data memory (connected to alu output)
	SIGNAL MEM_DATA_IN_PRIME_tb : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- input data of data memory
	SIGNAL ALU_OUTPUT_OUT_tb    : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- output of register ALU_OUTPUT
	SIGNAL MEM_DATA_OUT_tb      : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- output data to WB

	COMPONENT MEM_STAGE IS
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
	END COMPONENT;

BEGIN
	DUT : MEM_STAGE
	GENERIC
	MAP (
	N_BITS_DATA => NbitLong, -- # of bits PC
	RF_ADDR     => RF_ADDR   -- # OF BITS FOR REGISTER FILE ADDRESS
	)
	PORT MAP
	(
		CLK               => CLK_tb,
		RST               => RST_tb,
		MEM_OUTREG_EN     => MEM_OUTREG_EN_tb,
		BYTE_LEN_IN       => BYTE_LEN_IN_tb,
		DRAM_WE           => DRAM_WE_tb,
		DRAM_WE_OUT       => DRAM_WE_OUT_tb,
		BYTE_LEN_OUT      => BYTE_LEN_OUT_tb,
		ALU_OUTPUT_IN     => ALU_OUTPUT_IN_tb,
		MEM_DATA_IN       => MEM_DATA_IN_tb,
		MEM_DATA_OUT_INT  => MEM_DATA_OUT_INT_tb,
		NPC_IN            => NPC_IN_tb,
		IR_IN             => IR_IN_tb,
		IR_OUT            => IR_OUT_tb,
		NPC_OUT           => NPC_OUT_tb,
		MEM_ADDR_OUT      => MEM_ADDR_OUT_tb,
		MEM_DATA_IN_PRIME => MEM_DATA_IN_PRIME_tb,
		ALU_OUTPUT_OUT    => ALU_OUTPUT_OUT_tb,
		MEM_DATA_OUT      => MEM_DATA_OUT_tb
	);

	P_STIMULI : PROCESS IS
		VARIABLE j           : INTEGER                                 := 0;
		VARIABLE aux         : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0) := (OTHERS => '0');
		VARIABLE aux_DRAM_WE : STD_LOGIC_VECTOR(0 DOWNTO 0)            := (OTHERS => '0');
		VARIABLE aux_5bits   : STD_LOGIC_VECTOR(4 DOWNTO 0)            := (OTHERS => '0');
	BEGIN
		--############################ TEST 1  ############################--
		REPORT("Starting simulation");
		REPORT("TEST 1: reset test");
		RST_tb           <= '0'; -- Reset all registers
		MEM_OUTREG_EN_tb <= '1'; --Enabling all pipeline registers
		--other signals
		BYTE_LEN_IN_tb   <= "11";
		DRAM_WE_tb       <= '0';
		-- Data ports
		ALU_OUTPUT_IN_tb    <= x"FF00FF02";     -- 
		MEM_DATA_IN_tb      <= x"000FF030";     -- random value
		MEM_DATA_OUT_INT_tb <= x"FFF00400";     --random value
		NPC_IN_tb           <= x"00000000";
		IR_IN_tb            <= "00010";
		WAIT UNTIL falling_edge(CLK_tb);
		ASSERT (IR_OUT_tb = "00000")
		REPORT " IR_OUT exp val: " & INTEGER'image(0) & " IRC_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(IR_OUT_tb)))
			SEVERITY failure;
		ASSERT (NPC_OUT_tb = x"00000000")
		REPORT " NPC_OUT exp val: " & INTEGER'image(0) & " NPT_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(NPC_OUT_tb)))
			SEVERITY failure;
		--Now MEM_ADDR_OUT doesn't have a register so we cannot "reset" its value
		aux := x"FF00FF02";
		ASSERT (MEM_ADDR_OUT_tb = aux)
		REPORT " MEM_ADDR_OUT exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " MEM_ADDR_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(MEM_ADDR_OUT_tb)))
			SEVERITY failure;
		aux := x"000FF030";
		ASSERT (MEM_DATA_IN_PRIME_tb = aux)
		REPORT " MEM_DATA_IN_PRIME exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " MEM_DATA_IN_PRIME obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(MEM_DATA_IN_PRIME_tb)))
			SEVERITY failure;
		aux := x"FFF00400";
		ASSERT (MEM_DATA_OUT_tb = x"FFF00400")
		REPORT " MEM_DATA_OUT exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " MEM_DATA_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(MEM_DATA_OUT_tb)))
			SEVERITY failure;
		ASSERT (ALU_OUTPUT_OUT_tb = x"00000000")
		REPORT " ALU_OUTPUT_OUT exp val: " & INTEGER'image(0) & " ALU_OUTPUT_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(ALU_OUTPUT_OUT_tb)))
			SEVERITY failure;
		aux_DRAM_WE(0) := DRAM_WE_OUT_tb;
		ASSERT (DRAM_WE_OUT_tb = '0')
		REPORT " DRAM_WE_OUT exp val: " & INTEGER'image(0) & " DRAM_WE_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_DRAM_WE)))
			SEVERITY failure;
		ASSERT (BYTE_LEN_OUT_tb = "11")
		REPORT " BYTE_LEN_OUT exp val: " & INTEGER'image(0) & " BYTE_LEN_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(BYTE_LEN_OUT_tb)))
			SEVERITY failure;
		REPORT("TEST 1 RESULT: SUCCESSFUL");

		--############################ TEST 3  ############################--
		REPORT("TEST 2: Memory reading and writing test");
		RST_tb           <= '1'; -- Reset all registers
		FOR i IN 0 TO 31 LOOP
			j := 31 - i; --go through memory values from the last to the first
			ALU_OUTPUT_IN_tb <= STD_LOGIC_VECTOR(to_unsigned(i, NbitLong));
			MEM_DATA_IN_tb   <= DATA_MEM(j);
			WAIT UNTIL falling_edge(CLK_tb);
			MEM_DATA_OUT_INT_tb <= DATA_MEM(TO_INTEGER(UNSIGNED(ALU_OUTPUT_IN_tb))); --Reading data from fake memory
			WAIT FOR 100 ps;                                                         -- wait to update value of MEM_DATA_OUT_INT_tb signal
			ASSERT (MEM_DATA_OUT_tb = DATA_MEM(i))
			REPORT "i=" & INTEGER'image(i) & " MEM_DATA_OUT exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(DATA_MEM(i)))) & " MEM_DATA_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(MEM_DATA_OUT_tb)))
				SEVERITY failure;
			ASSERT (ALU_OUTPUT_OUT_tb = STD_LOGIC_VECTOR(to_unsigned(i, NbitLong))) --Also see that the other output port related to ALU output was updated
			REPORT "i=" & INTEGER'image(i) & " ALU_OUTPUT_OUT exp val: " & INTEGER'image(i) & " ALU_OUTPUT_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(ALU_OUTPUT_OUT_tb)))
				SEVERITY failure;
			ASSERT (MEM_DATA_IN_PRIME_tb = DATA_MEM(j)) --data input to memory
			REPORT "j=" & INTEGER'image(j) & " MEM_DATA_IN_PRIME exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(DATA_MEM(j)))) & " MEM_DATA_IN_PRIME obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(MEM_DATA_IN_PRIME_tb)))
				SEVERITY failure;
		END LOOP;
		REPORT("TEST 2 RESULT: SUCCESSFUL");
		--############################ TEST 6  ############################--
		REPORT("TEST 3: Register enable");
		MEM_OUTREG_EN_tb <= '1'; --Enabling all pipeline registers
		ALU_OUTPUT_IN_tb <= x"FE00FF02"; -- 
		MEM_DATA_IN_tb   <= x"040FF030"; -- random value
		NPC_IN_tb        <= x"20A10023";
		IR_IN_tb         <= "01010";
		WAIT UNTIL falling_edge(CLK_tb);
		--Changing all the values and enable = 0
		MEM_OUTREG_EN_tb <= '0'; --Disabling all pipeline registers
		ALU_OUTPUT_IN_tb <= x"00000000"; -- 
		MEM_DATA_IN_tb   <= x"040AA000"; -- random value
		NPC_IN_tb        <= x"FFFF0023";
		IR_IN_tb         <= "11111";
		WAIT UNTIL falling_edge(CLK_tb);
		aux_5bits := "01010";
		ASSERT (IR_OUT_tb = "01010")
		REPORT " IR_OUT exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_5bits))) & " IRC_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(IR_OUT_tb)))
			SEVERITY failure;
		aux := x"20A10023";
		ASSERT (NPC_OUT_tb = aux)
		REPORT " NPC_OUT exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " NPT_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(NPC_OUT_tb)))
			SEVERITY failure;
		-- THe following two signals previously had a register in their path. In the new version they don't, so now they are not affected by the enable signal
		--------------------------------------------------------------------------------------------------------------------------------------------------------
		aux := x"00000000";
		WAIT UNTIL falling_edge(CLK_tb);
		ASSERT (MEM_ADDR_OUT_tb = aux)
		REPORT " MEM_ADDR_OUT exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " MEM_ADDR_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(MEM_ADDR_OUT_tb)))
			SEVERITY failure;
		aux := x"040AA000";
		ASSERT (MEM_DATA_IN_PRIME_tb = aux)
		REPORT " MEM_DATA_IN_PRIME exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " MEM_DATA_IN_PRIME obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(MEM_DATA_IN_PRIME_tb)))
			SEVERITY failure;
		----------------------------------------------------------------------------------------------------------------------------------------------------------
		aux := x"FE00FF02";
		ASSERT (ALU_OUTPUT_OUT_tb = aux)
		REPORT " ALU_OUTPUT_OUT exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " ALU_OUTPUT_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(ALU_OUTPUT_OUT_tb)))
			SEVERITY failure;
		REPORT("TEST 3 RESULT: SUCCESSFUL");

		REPORT (" End of simulation");
		WAIT;
	END PROCESS;

	P_CLOCK : PROCESS (CLK_tb)
	BEGIN
		CLK_tb <= NOT(CLK_tb) AFTER Tclk / 2;
	END PROCESS;
END TEST;