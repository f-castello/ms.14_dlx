LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_EXE IS
END TB_EXE;

ARCHITECTURE TEST OF TB_EXE IS
	-- Control ports 
	SIGNAL CLK_tb           : STD_LOGIC := '0';
	SIGNAL RST_tb           : STD_LOGIC;
	SIGNAL MUXA_SEL_tb      : STD_LOGIC; -- MUXA Sel
	SIGNAL MUXB_SEL_tb      : STD_LOGIC; -- MUXB Sel
	SIGNAL EXE_OUTREG_EN_tb : STD_LOGIC; -- (ALU Output, ALU Flags, NPC2, IR2, Pad OP, Zero OP) Registers Enable
	SIGNAL EQ_COND_tb       : STD_LOGIC; -- Branch if (not) Equal to Zero
	SIGNAL JUMP_EN_tb       : STD_LOGIC; -- Jump Enable Signal for Cond Selection
	SIGNAL ALU_OPCODE_tb    : ALU_MSG;   -- Custom Type for ALU Ops
	-- Data ports
	SIGNAL NPC2_IN_tb       : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- NPC2 reg input
	SIGNAL NPC1_MUXA_IN_tb  : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- Input 0 of the first multiplexer
	SIGNAL REGA_MUXA_IN_tb  : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- Input 1 of the first multiplexer
	SIGNAL REGB_MUXB_IN_tb  : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- Input 0 of the second multiplexer
	SIGNAL IMM_MUXB_IN_tb   : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- Input 1 of the second multiplexer
	SIGNAL PAD_IN_tb        : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- Pad OP reg input
	SIGNAL IR2_IN_tb        : STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);  -- IR2 reg input
	SIGNAL JUMP_MUX_IN_0_tb : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- Input 0 of the multiplexer for jumping (NPC)
	SIGNAL NPC2_OUT_tb      : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- NPC2 reg output
	SIGNAL ALU_OUT_tb       : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- Output data of the ALU
	SIGNAL PAD_OUT_tb       : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- Pad OP reg output
	SIGNAL IR2_OUT_tb       : STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);  -- IR2 reg output
	SIGNAL ADDR_MUX_OUT_tb  : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- Program Counter mux output
	SIGNAL N_FLAG_tb        : STD_LOGIC;                               -- Negative condition code flag ALU 
	SIGNAL Z_FLAG_tb        : STD_LOGIC;                               -- Zero condition code flag ALU 
	SIGNAL C_FLAG_tb        : STD_LOGIC;                               -- Carry condition code flag ALU 
	SIGNAL V_FLAG_tb        : STD_LOGIC;                               -- Overflow condition code flag ALU 

	COMPONENT EXE_STAGE IS
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
	END COMPONENT;

BEGIN
	DUT : EXE_STAGE
	GENERIC
	MAP (
	N_BITS_DATA => NbitLong, -- # of bits for data
	RF_ADDR     => RF_ADDR   -- # OF BITS FOR REGISTER FILE ADDRESS
	)
	PORT MAP
	(
		CLK           => CLK_tb,
		RST           => RST_tb,
		MUXA_SEL      => MUXA_SEL_tb,
		MUXB_SEL      => MUXB_SEL_tb,
		EXE_OUTREG_EN => EXE_OUTREG_EN_tb,
		EQ_COND       => EQ_COND_tb,
		JUMP_EN       => JUMP_EN_tb,
		ALU_OPCODE    => ALU_OPCODE_tb,
		NPC2_IN       => NPC2_IN_tb,
		NPC1_MUXA_IN  => NPC1_MUXA_IN_tb,
		REGA_MUXA_IN  => REGA_MUXA_IN_tb,
		REGB_MUXB_IN  => REGB_MUXB_IN_tb,
		IMM_MUXB_IN   => IMM_MUXB_IN_tb,
		PAD_IN        => PAD_IN_tb,
		IR2_IN        => IR2_IN_tb,
		JUMP_MUX_IN_0 => JUMP_MUX_IN_0_tb,
		NPC2_OUT      => NPC2_OUT_tb,
		ALU_OUT       => ALU_OUT_tb,
		PAD_OUT       => PAD_OUT_tb,
		IR2_OUT       => IR2_OUT_tb,
		ADDR_MUX_OUT  => ADDR_MUX_OUT_tb,
		N_FLAG        => N_FLAG_tb,
		Z_FLAG        => Z_FLAG_tb,
		C_FLAG        => C_FLAG_tb,
		V_FLAG        => V_FLAG_tb
	);

	P_STIMULI : PROCESS IS
		VARIABLE aux       : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0) := (OTHERS => '0');
		VARIABLE aux_bit   : STD_LOGIC_VECTOR(0 DOWNTO 0)            := (OTHERS => '0');
		VARIABLE aux_bit2  : STD_LOGIC_VECTOR(0 DOWNTO 0)            := (OTHERS => '0');
		VARIABLE aux_5bits : STD_LOGIC_VECTOR(4 DOWNTO 0)            := (OTHERS => '0');
	BEGIN
		REPORT("Starting simulation");
		REPORT("TEST 1: reset test");
		-- CONTROL IN SIGNALS
		RST_tb           <= '0';   -- Reset all registers
		EXE_OUTREG_EN_tb <= '1';   --Enabling all pipeline registers
		MUXA_SEL_tb      <= '1';   --Random value
		MUXB_SEL_tb      <= '0';   --Random value
		EQ_COND_tb       <= '0';   --Random value
		JUMP_EN_tb       <= '1';   --Random value
		ALU_OPCODE_tb    <= R_add; --Random value
		--DATA IN SIGNALS
		NPC2_IN_tb      <= x"FFFAA012";
		NPC1_MUXA_IN_tb <= x"00000001";
		REGA_MUXA_IN_tb <= x"00000002";
		REGB_MUXB_IN_tb <= x"00000003";
		IMM_MUXB_IN_tb  <= x"00000004";
		PAD_IN_tb       <= x"00000005";
		IR2_IN_tb       <= "00111";
		WAIT UNTIL falling_edge(CLK_tb);
		ASSERT (IR2_OUT_tb = "00000")
		REPORT " IR_OUT exp val: " & INTEGER'image(0) & " IRC_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(IR2_OUT_tb)))
			SEVERITY failure;
		ASSERT (NPC2_OUT_tb = x"00000000")
		REPORT " NPC2_OUT exp val: " & INTEGER'image(0) & " NPC2_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(NPC2_OUT_tb)))
			SEVERITY failure;
		aux_bit(0) := '0';
		ASSERT (ALU_OUT_tb = x"00000000")
		REPORT " ALU_OUT exp val: " & INTEGER'image(0) & " ALU_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(ALU_OUT_tb)))
			SEVERITY failure;
		ASSERT (PAD_OUT_tb = x"00000000")
		REPORT " PAD_OUT exp val: " & INTEGER'image(0) & " PAD_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(PAD_OUT_tb)))
			SEVERITY failure;
		ASSERT (IR2_OUT_tb = "00000")
		REPORT " IR2_OUT exp val: " & INTEGER'image(0) & " IR2_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(IR2_OUT_tb)))
			SEVERITY failure;
		REPORT("TEST 1 RESULT: SUCCESSFUL");

		REPORT("TEST 2: Enable test");
		RST_tb           <= '1'; -- Reset all registers
		EXE_OUTREG_EN_tb <= '1';
		EQ_COND_tb       <= '1';
		NPC2_IN_tb       <= x"FFFAA012";
		NPC1_MUXA_IN_tb  <= x"00000001";
		REGA_MUXA_IN_tb  <= x"00000002";
		REGB_MUXB_IN_tb  <= x"00000003";
		IMM_MUXB_IN_tb   <= x"00000004";
		PAD_IN_tb        <= x"00000005";
		IR2_IN_tb        <= "00111";
		WAIT UNTIL falling_edge(CLK_tb);
		EXE_OUTREG_EN_tb <= '0';
		NPC2_IN_tb       <= x"FFFFFFFF";
		NPC1_MUXA_IN_tb  <= x"FFFFFFFF";
		REGA_MUXA_IN_tb  <= x"FFFFFFFF";
		REGB_MUXB_IN_tb  <= x"FFFFFFFF";
		IMM_MUXB_IN_tb   <= x"FFFFFFFF";
		PAD_IN_tb        <= x"FFFFFFFF";
		IR2_IN_tb        <= "11111";
		WAIT UNTIL falling_edge(CLK_tb);
		aux_5bits := "00111";
		ASSERT (IR2_OUT_tb = aux_5bits)
		REPORT " IR_OUT exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_5bits))) & " IRC_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(IR2_OUT_tb)))
			SEVERITY failure;
		aux := x"FFFAA012";
		ASSERT (NPC2_OUT_tb = x"FFFAA012")
		REPORT " NPC_OUT exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " NPT_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(NPC2_OUT_tb)))
			SEVERITY failure;
		aux_bit(0) := '0';
		aux        := x"00000005";
		ASSERT (ALU_OUT_tb = x"00000005")
		REPORT " ALU_OUT exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " ALU_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(ALU_OUT_tb)))
			SEVERITY failure;
		aux := x"00000005";
		ASSERT (PAD_OUT_tb = x"00000005")
		REPORT " PAD_OUT exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " NPT_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(PAD_OUT_tb)))
			SEVERITY failure;
		aux_5bits := "00111";
		ASSERT (IR2_OUT_tb = aux_5bits)
		REPORT " IR2_OUT exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_5bits))) & " IR2_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(IR2_OUT_tb)))
			SEVERITY failure;
		REPORT("TEST 2 RESULT: SUCCESSFUL");

		REPORT("TEST 3: MUXES TEST");
		EXE_OUTREG_EN_tb <= '1'; --Enabling registers
		MUXA_SEL_tb      <= '0'; --Selection input 0 MUX A
		MUXB_SEL_tb      <= '0'; --Selection input 0 MUX B
		NPC1_MUXA_IN_tb  <= x"00000004";
		REGA_MUXA_IN_tb  <= x"00000002";
		REGB_MUXB_IN_tb  <= x"00000003";
		IMM_MUXB_IN_tb   <= x"0000000A";
		WAIT UNTIL falling_edge(CLK_tb);
		MUXA_SEL_tb <= '1'; --Selection input 1 MUX A
		aux := x"00000007";
		ASSERT (ALU_OUT_tb = aux)
		REPORT " ALU_OUT exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " ALU_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(ALU_OUT_tb)))
			SEVERITY failure;
		WAIT UNTIL falling_edge(CLK_tb);
		MUXA_SEL_tb <= '0'; --Selection input 0 MUX A
		MUXB_SEL_tb <= '1'; --Selection input 1 MUX B
		aux := x"00000005";
		ASSERT (ALU_OUT_tb = aux)
		REPORT " ALU_OUT exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " ALU_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(ALU_OUT_tb)))
			SEVERITY failure;
		WAIT UNTIL falling_edge(CLK_tb);
		MUXA_SEL_tb <= '1'; --Selection input 1 MUX A
		aux := x"0000000E";
		ASSERT (ALU_OUT_tb = aux)
		REPORT " ALU_OUT exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " ALU_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(ALU_OUT_tb)))
			SEVERITY failure;
		WAIT UNTIL falling_edge(CLK_tb);
		aux := x"0000000C";
		ASSERT (ALU_OUT_tb = aux)
		REPORT " ALU_OUT exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " ALU_OUT obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(ALU_OUT_tb)))
			SEVERITY failure;
		REPORT("TEST 3 RESULT: SUCCESSFUL");

		REPORT("TEST 4: FLAGS TEST");
		MUXB_SEL_tb     <= '0'; --Selection input 0 MUX B
		REGA_MUXA_IN_tb <= x"F0000000";
		REGB_MUXB_IN_tb <= x"10000000";
		WAIT UNTIL falling_edge(CLK_tb);
		aux_bit(0)  := '1';
		aux_bit2(0) := C_FLAG_tb;
		ASSERT (C_FLAG_tb = '1')
		REPORT " C_FLAG exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit))) & " C_FLAG obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit2)))
			SEVERITY failure;
		aux_bit2(0) := Z_FLAG_tb;
		ASSERT (Z_FLAG_tb = '1')
		REPORT " Z_FLAG exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit))) & " Z_FLAG obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit2)))
			SEVERITY failure;
		aux_bit(0)  := '0';
		aux_bit2(0) := V_FLAG_tb;
		ASSERT (V_FLAG_tb = '0')
		REPORT " V_FLAG exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit))) & " V_FLAG obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit2)))
			SEVERITY failure;
		aux_bit2(0) := N_FLAG_tb;
		ASSERT (V_FLAG_tb = '0')
		REPORT " N_FLAG exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit))) & " N_FLAG obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit2)))
			SEVERITY failure;
		REGA_MUXA_IN_tb <= x"F0000000";
		REGB_MUXB_IN_tb <= x"80000000";
		WAIT UNTIL falling_edge(CLK_tb);
		aux_bit(0)  := '1';
		aux_bit2(0) := C_FLAG_tb;
		ASSERT (C_FLAG_tb = '1')
		REPORT " C_FLAG exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit))) & " C_FLAG obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit2)))
			SEVERITY failure;
		aux_bit2(0) := V_FLAG_tb;
		ASSERT (V_FLAG_tb = '1')
		REPORT " V_FLAG exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit))) & " V_FLAG obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit2)))
			SEVERITY failure;
		aux_bit(0)  := '0';
		aux_bit2(0) := Z_FLAG_tb;
		ASSERT (Z_FLAG_tb = '0')
		REPORT " Z_FLAG exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit))) & " Z_FLAG obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit2)))
			SEVERITY failure;
		aux_bit2(0) := N_FLAG_tb;
		ASSERT (V_FLAG_tb = '1')
		REPORT " N_FLAG exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit))) & " N_FLAG obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit2)))
			SEVERITY failure;
		REGA_MUXA_IN_tb <= x"70000000";
		REGB_MUXB_IN_tb <= x"10000000";
		WAIT UNTIL falling_edge(CLK_tb);
		aux_bit(0)  := '0';
		aux_bit2(0) := C_FLAG_tb;
		ASSERT (C_FLAG_tb = '0')
		REPORT " C_FLAG exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit))) & " C_FLAG obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit2)))
			SEVERITY failure;
		aux_bit(0)  := '1';
		aux_bit2(0) := V_FLAG_tb;
		ASSERT (V_FLAG_tb = '1')
		REPORT " V_FLAG exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit))) & " V_FLAG obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit2)))
			SEVERITY failure;
		aux_bit(0)  := '0';
		aux_bit2(0) := Z_FLAG_tb;
		ASSERT (Z_FLAG_tb = '0')
		REPORT " Z_FLAG exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit))) & " Z_FLAG obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit2)))
			SEVERITY failure;
		aux_bit(0)  := '1';
		aux_bit2(0) := N_FLAG_tb;
		ASSERT (V_FLAG_tb = '1')
		REPORT " N_FLAG exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit))) & " N_FLAG obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux_bit2)))
			SEVERITY failure;
		REPORT("TEST 4 RESULT: SUCCESSFUL");

		REPORT("END SIMULATION");
		WAIT;
	END PROCESS;

	P_CLOCK : PROCESS (CLK_tb)
	BEGIN
		CLK_tb <= NOT(CLK_tb) AFTER Tclk / 2;
	END PROCESS;
END TEST;