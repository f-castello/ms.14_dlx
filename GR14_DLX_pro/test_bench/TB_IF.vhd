LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_IF IS
END TB_IF;

ARCHITECTURE TEST OF TB_IF IS
	TYPE MEM_ARRAY IS ARRAY (0 TO 19) OF STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
	CONSTANT IR_MEM_VALS : MEM_ARRAY := (
		x"00100001",
		x"10000001",
		x"00001110",
		x"F2300100",
		x"0ED00020",
		x"00A20004",
		x"01000026",
		x"00200007",
		x"FFF00009",
		x"0000FF0A",
		x"0D10100C",
		x"111DD001",
		x"00000002",
		x"0BB00205",
		x"88800009",
		x"AA0AA001",
		x"DEF00123",
		x"00000000",
		x"00000000",
		x"00000000"
	);
	SIGNAL CLK_tb         : STD_LOGIC := '0';
	SIGNAL RST_tb         : STD_LOGIC;
	SIGNAL IF_LATCH_EN_tb : STD_LOGIC; -- (PC, IR, NPC0, NPCA, NPCB) Registers Enable
	-- Data ports
	SIGNAL PC_IN_tb   : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
	SIGNAL IR_IN_tb   : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- output of the memory to the IR
	SIGNAL PC_OUT_tb  : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
	SIGNAL ADD_OUT_tb : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
	SIGNAL IR_OUT_tb  : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
	SIGNAL NPC_OUT_tb : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);

	COMPONENT IF_STAGE IS
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
			IF_LATCH_EN : IN STD_LOGIC; -- (PC, IR, NPC0, NPCA, NPCB) Registers Enable
			-- Data ports
			PC_IN   : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
			IR_IN   : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- output of the memory to the IR
			PC_OUT  : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
			IR_OUT  : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
			ADD_OUT : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
			NPC_OUT : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0)
		);
	END COMPONENT;

BEGIN
	DUT : IF_STAGE
	GENERIC
	MAP (
	N_BITS_DATA  => NbitLong,
	N_BYTES_INST => NPC_GAP
	)
	PORT MAP
	(
		CLK         => CLK_tb,
		RST         => RST_tb,
		IF_LATCH_EN => IF_LATCH_EN_tb,
		-- Data ports
		PC_IN   => PC_IN_tb,
		IR_IN   => IR_IN_tb,
		PC_OUT  => PC_OUT_tb,
		IR_OUT  => IR_OUT_tb,
		ADD_OUT => ADD_OUT_tb,
		NPC_OUT => NPC_OUT_tb
	);

	PC_IN_tb <= ADD_OUT_tb;
	P_STIMULI : PROCESS IS
	BEGIN
		REPORT("Starting simulation");
		RST_tb         <= '0'; --resetting (active-low)
		IF_LATCH_EN_tb <= '1';
		IR_IN_tb       <= IR_MEM_VALS(TO_INTEGER(UNSIGNED(PC_OUT_tb)/4) MOD 19);
		WAIT UNTIL falling_edge(CLK_tb);
		ASSERT (PC_OUT_tb = (NbitLong - 1 DOWNTO 0 => '0') AND PC_IN_tb = ((NbitLong - 1 DOWNTO 3 => '0') & "100"))
		REPORT " PC_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(PC_OUT_tb))) & " PC_IN: exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(PC_IN_tb))) & " IR_IN: " & INTEGER'image(TO_INTEGER(UNSIGNED(IR_IN_tb)))
			SEVERITY failure;

		------------------- TEST INIT ------------------
		FOR i IN 0 TO 19 LOOP
			--WAIT UNTIL falling_edge(CLK_tb);
			RST_tb   <= '1'; --NO resetting (active-low)
			IR_IN_tb <= IR_MEM_VALS(TO_INTEGER(UNSIGNED(PC_OUT_tb)/4) MOD 19);
			ASSERT (PC_OUT_tb = STD_LOGIC_VECTOR(to_unsigned(i * 4, PC_OUT_tb'length)))
			REPORT "i = " & INTEGER'image(i) & " - PC_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(PC_OUT_tb))) & "PC_OUT exp val:" & INTEGER'image(i * 4)
				SEVERITY failure;
			ASSERT (PC_IN_tb = STD_LOGIC_VECTOR(to_unsigned(i * 4 + 4, PC_OUT_tb'length)))
			REPORT "i = " & INTEGER'image(i) & " PC_IN: " & INTEGER'image(TO_INTEGER(UNSIGNED(PC_IN_tb))) & " PC_IN exp val: " & INTEGER'image(i * 4 + 4)
				SEVERITY failure;
			IF (i > 2) THEN
				ASSERT NPC_OUT_tb = STD_LOGIC_VECTOR(to_unsigned((i - 2) * 4, NPC_OUT_tb'length))
				REPORT "i = " & INTEGER'image(i) & " NPC_OUT_tb: " & INTEGER'image(TO_INTEGER(UNSIGNED(NPC_OUT_tb))) & " NPC_OUT_tb exp val: " & INTEGER'image((i - 2) * 4)
					SEVERITY failure;
			END IF;
			WAIT UNTIL falling_edge(CLK_tb);
			ASSERT IR_OUT_tb = IR_MEM_VALS(i MOD 19)
			REPORT " IR_IN: " & INTEGER'image(TO_INTEGER(UNSIGNED(IR_OUT_tb)))
				SEVERITY failure;
		END LOOP;

		REPORT("Ending simulation");
		WAIT;
	END PROCESS;

	P_CLOCK : PROCESS (CLK_tb)
	BEGIN
		CLK_tb <= NOT(CLK_tb) AFTER Tclk / 2;
	END PROCESS;
END TEST;