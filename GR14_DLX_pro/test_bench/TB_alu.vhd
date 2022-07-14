LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_ALU IS
END TB_ALU;

ARCHITECTURE TEST OF TB_ALU IS
	SIGNAL ALU_OPCODE_tb : ALU_MSG := I_addui;
	SIGNAL DATA1_tb      : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
	SIGNAL DATA2_tb      : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
	SIGNAL NEG_tb        : STD_LOGIC;
	SIGNAL ZERO_tb       : STD_LOGIC;
	SIGNAL CARRY_tb      : STD_LOGIC;
	SIGNAL OVF_tb        : STD_LOGIC;
	SIGNAL OUTALU_tb     : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
	SUBTYPE NUM_INPUTS IS NATURAL RANGE 0 TO 32;
	TYPE TEST_VECT IS ARRAY(NUM_INPUTS) OF STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
	SIGNAL TEST_VALUES : TEST_VECT;

	COMPONENT ALU IS
		GENERIC
			(N : INTEGER := NbitLong);
		PORT
		(
			ALU_OPCODE            : IN ALU_MSG;
			DATA1, DATA2          : IN STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
			NEG, ZERO, CARRY, OVF : OUT STD_LOGIC;
			OUTALU                : OUT STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0)
		);
	END COMPONENT;

BEGIN
	TEST_VALUES <= (
		x"7FFFFFFF", --[0]
		x"00000001", --[1]
		x"00000011", --[2]
		x"00110000", --[3]
		x"FFFFFFFF", --[4]
		x"10000000", --[5]
		x"10000011", --[6]
		x"00000010", --[7]
		x"00000000", --[8]
		x"80000000", --[9]
		x"00110011", --[10]
		x"0FFFFFFF", --[11]
		x"10000021", --[12]
		x"00000FF1", --[13]
		x"00000FF2", --[14]
		x"00001FE3", --[15]
		x"00000FE2", --[16]
		x"70000000", --[17]
		x"F0000000", --[18]
		x"00000FF9", --[19]
		x"F0002211", --[20]
		x"00000FF0", --[21]
		x"00000FF3", --[22]
		x"00000003", --[23]
		x"FF100000", --[24]
		x"E2000000", --[25]
		x"000007F8", --[26]
		x"00000002", --[27]
		x"000003FC", --[28]
		x"00000022", --[29]
		x"D0006633", --[30]
		x"FFFFFFFD", --[31]
		x"FFFE0001"  --[32]
		);

	DUT : ALU
	GENERIC
	MAP (N => NbitLong)
	PORT MAP
	(
		ALU_OPCODE => ALU_OPCODE_tb,
		DATA1      => DATA1_tb,
		DATA2      => DATA2_tb,
		NEG        => NEG_tb,
		ZERO       => ZERO_tb,
		CARRY      => CARRY_tb,
		OVF        => OVF_tb,
		OUTALU     => OUTALU_tb
	);

	P_STIMULI : PROCESS
	BEGIN
		--############################ TEST 1  ############################--
		REPORT("Starting simulation");
		REPORT("TEST 1:   - UNSIGNED ADDITION");
		ALU_OPCODE_tb <= I_jr;
		DATA1_tb      <= STD_LOGIC_VECTOR(to_unsigned(3, NbitLong));
		DATA2_tb      <= STD_LOGIC_VECTOR(to_unsigned(2, NbitLong));
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = STD_LOGIC_VECTOR(to_unsigned(3, NbitLong)) AND DATA2_tb = STD_LOGIC_VECTOR(to_unsigned(2, NbitLong)) AND OVF_tb = '0' AND CARRY_tb = '0' AND ZERO_tb = '0' AND NEG_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(5) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "OVF exp val : " & STD_LOGIC'image('0') & "OVF obt val : " & STD_LOGIC'image(OVF_tb) & "CARRY expt val : " & STD_LOGIC'image('0') & "CARRY obt val : " & STD_LOGIC'image(CARRY_tb) & "ZERO expt val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb) & "NEG expt val : " & STD_LOGIC'image('0') & "NEG obt val : " & STD_LOGIC'image(NEG_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= I_addui;
		DATA1_tb      <= TEST_VALUES(4);
		DATA2_tb      <= TEST_VALUES(1);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(4) AND DATA2_tb = TEST_VALUES(1) AND OVF_tb = '1' AND CARRY_tb = '1' AND ZERO_tb = '1' AND NEG_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(8)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "OVF exp val : " & STD_LOGIC'image('1') & "OVF obt val : " & STD_LOGIC'image(OVF_tb) & "CARRY expt val : " & STD_LOGIC'image('1') & "CARRY obt val : " & STD_LOGIC'image(CARRY_tb) & "ZERO expt val : " & STD_LOGIC'image('1') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb) & "NEG expt val : " & STD_LOGIC'image('0') & "NEG obt val : " & STD_LOGIC'image(NEG_tb)
			SEVERITY failure;
		REPORT("TEST 1 result: SUCCESSFUL");

		--############################ TEST 2 ############################--
		REPORT("TEST 2:   - SIGNED ADDITION");
		ALU_OPCODE_tb <= I_sb;
		DATA1_tb      <= TEST_VALUES(0);
		DATA2_tb      <= TEST_VALUES(1);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(0) AND DATA2_tb = TEST_VALUES(1) AND OVF_tb = '1' AND CARRY_tb = '0' AND ZERO_tb = '0' AND NEG_tb = '1')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(9)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "OVF exp val : " & STD_LOGIC'image('1') & "OVF obt val : " & STD_LOGIC'image(OVF_tb) & "CARRY expt val : " & STD_LOGIC'image('0') & "CARRY obt val : " & STD_LOGIC'image(CARRY_tb) & "ZERO exp val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb) & "NEG expt val : " & STD_LOGIC'image('1') & "NEG obt val : " & STD_LOGIC'image(NEG_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= J_jal;
		DATA1_tb      <= TEST_VALUES(4);
		DATA2_tb      <= TEST_VALUES(9);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(4) AND DATA2_tb = TEST_VALUES(9) AND OVF_tb = '1' AND CARRY_tb = '1' AND ZERO_tb = '0' AND NEG_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(0)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "OVF exp val : " & STD_LOGIC'image('1') & "OVF obt val : " & STD_LOGIC'image(OVF_tb) & "CARRY expt val : " & STD_LOGIC'image('1') & "CARRY obt val : " & STD_LOGIC'image(CARRY_tb) & "ZERO exp val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb) & "NEG expt val : " & STD_LOGIC'image('0') & "NEG obt val : " & STD_LOGIC'image(NEG_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= R_add;
		DATA1_tb      <= TEST_VALUES(6);
		DATA2_tb      <= TEST_VALUES(7);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(6) AND DATA2_tb = TEST_VALUES(7)AND OVF_tb = '0' AND CARRY_tb = '0' AND ZERO_tb = '0' AND NEG_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(12)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "OVF exp val : " & STD_LOGIC'image('0') & "OVF obt val : " & STD_LOGIC'image(OVF_tb) & "CARRY expt val : " & STD_LOGIC'image('0') & "CARRY obt val : " & STD_LOGIC'image(CARRY_tb) & "ZERO expt val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb) & "NEG expt val : " & STD_LOGIC'image('0') & "NEG obt val : " & STD_LOGIC'image(NEG_tb)
			SEVERITY failure;
		REPORT("TEST 2 result: SUCCESSFUL");

		--############################ TEST 3 ############################--
		REPORT("TEST 3:   - I_beqz  -I_bnez");
		ALU_OPCODE_tb <= I_beqz;
		DATA1_tb      <= TEST_VALUES(13);
		DATA2_tb      <= TEST_VALUES(8);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(13) AND DATA2_tb = TEST_VALUES(8) AND OVF_tb = '0' AND CARRY_tb = '0' AND ZERO_tb = '0' AND NEG_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(13)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "OVF exp val : " & STD_LOGIC'image('0') & "OVF obt val : " & STD_LOGIC'image(OVF_tb) & "CARRY expt val : " & STD_LOGIC'image('0') & "CARRY obt val : " & STD_LOGIC'image(CARRY_tb) & "ZERO expt val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb) & "NEG expt val : " & STD_LOGIC'image('0') & "NEG obt val : " & STD_LOGIC'image(NEG_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= I_beqz;
		DATA1_tb      <= TEST_VALUES(4);
		DATA2_tb      <= TEST_VALUES(9);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(4) AND DATA2_tb = TEST_VALUES(9) AND OVF_tb = '0' AND CARRY_tb = '0' AND ZERO_tb = '1' AND NEG_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(0) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "OVF exp val : " & STD_LOGIC'image('0') & "OVF obt val : " & STD_LOGIC'image(OVF_tb) & "CARRY expt val : " & STD_LOGIC'image('0') & "CARRY obt val : " & STD_LOGIC'image(CARRY_tb) & "ZERO expt val : " & STD_LOGIC'image('1') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb) & "NEG expt val : " & STD_LOGIC'image('0') & "NEG obt val : " & STD_LOGIC'image(NEG_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= I_bnez;
		DATA1_tb      <= TEST_VALUES(13);
		DATA2_tb      <= TEST_VALUES(14);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(13) AND DATA2_tb = TEST_VALUES(14) AND OVF_tb = '0' AND CARRY_tb = '0' AND ZERO_tb = '0' AND NEG_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(15)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "OVF exp val : " & STD_LOGIC'image('0') & "OVF obt val : " & STD_LOGIC'image(OVF_tb) & "CARRY expt val : " & STD_LOGIC'image('0') & "CARRY obt val : " & STD_LOGIC'image(CARRY_tb) & "ZERO expt val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb) & "NEG expt val : " & STD_LOGIC'image('0') & "NEG obt val : " & STD_LOGIC'image(NEG_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= I_bnez;
		DATA1_tb      <= TEST_VALUES(4);
		DATA2_tb      <= TEST_VALUES(5);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(4) AND DATA2_tb = TEST_VALUES(5) AND OVF_tb = '0' AND CARRY_tb = '1' AND ZERO_tb = '0' AND NEG_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(11)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "OVF exp val : " & STD_LOGIC'image('0') & "OVF obt val : " & STD_LOGIC'image(OVF_tb) & "CARRY expt val : " & STD_LOGIC'image('1') & "CARRY obt val : " & STD_LOGIC'image(CARRY_tb) & "ZERO expt val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb) & "NEG expt val : " & STD_LOGIC'image('0') & "NEG obt val : " & STD_LOGIC'image(NEG_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= I_bnez;
		DATA1_tb      <= TEST_VALUES(13);
		DATA2_tb      <= TEST_VALUES(8);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(13) AND DATA2_tb = TEST_VALUES(8) AND OVF_tb = '0' AND CARRY_tb = '0' AND ZERO_tb = '1' AND NEG_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(0) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "OVF exp val : " & STD_LOGIC'image('0') & "OVF obt val : " & STD_LOGIC'image(OVF_tb) & "CARRY expt val : " & STD_LOGIC'image('0') & "CARRY obt val : " & STD_LOGIC'image(CARRY_tb) & "ZERO expt val : " & STD_LOGIC'image('1') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb) & "NEG expt val : " & STD_LOGIC'image('0') & "NEG obt val : " & STD_LOGIC'image(NEG_tb)
			SEVERITY failure;
		REPORT("TEST 3 result: SUCCESSFUL");

		--############################ TEST 4 ############################--
		REPORT("TEST 4:   - UNSIGNED SUBTRACTION");
		ALU_OPCODE_tb <= I_subui;
		DATA1_tb      <= TEST_VALUES(14);
		DATA2_tb      <= TEST_VALUES(7);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(14) AND DATA2_tb = TEST_VALUES(7) AND OVF_tb = '0' AND CARRY_tb = '0' AND ZERO_tb = '0' AND NEG_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(16)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "OVF exp val : " & STD_LOGIC'image('0') & "OVF obt val : " & STD_LOGIC'image(OVF_tb) & "CARRY expt val : " & STD_LOGIC'image('0') & "CARRY obt val : " & STD_LOGIC'image(CARRY_tb) & "ZERO expt val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb) & "NEG expt val : " & STD_LOGIC'image('0') & "NEG obt val : " & STD_LOGIC'image(NEG_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= R_subu;
		DATA1_tb      <= TEST_VALUES(4);
		DATA2_tb      <= TEST_VALUES(4);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(4) AND DATA2_tb = TEST_VALUES(4) AND OVF_tb = '0' AND CARRY_tb = '0' AND ZERO_tb = '1' AND NEG_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(8)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "OVF exp val : " & STD_LOGIC'image('0') & "OVF obt val : " & STD_LOGIC'image(OVF_tb) & "CARRY expt val : " & STD_LOGIC'image('0') & "CARRY obt val : " & STD_LOGIC'image(CARRY_tb) & "ZERO expt val : " & STD_LOGIC'image('1') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb) & "NEG expt val : " & STD_LOGIC'image('0') & "NEG obt val : " & STD_LOGIC'image(NEG_tb)
			SEVERITY failure;
		REPORT("TEST 4 result: SUCCESSFUL");

		--############################ TEST 5 ############################--
		REPORT("TEST 5:   - SIGNED SUBTRACTION");
		ALU_OPCODE_tb <= I_subi;
		DATA1_tb      <= TEST_VALUES(17);
		DATA2_tb      <= TEST_VALUES(9);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(17) AND DATA2_tb = TEST_VALUES(9) AND OVF_tb = '0' AND CARRY_tb = '1' AND ZERO_tb = '0' AND NEG_tb = '1')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(18)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "OVF exp val : " & STD_LOGIC'image('0') & "OVF obt val : " & STD_LOGIC'image(OVF_tb) & "CARRY exp val : " & STD_LOGIC'image('1') & "CARRY obt val : " & STD_LOGIC'image(CARRY_tb) & "ZERO expt val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb) & "NEG expt val : " & STD_LOGIC'image('1') & "NEG obt val : " & STD_LOGIC'image(NEG_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= R_sub;
		DATA1_tb      <= TEST_VALUES(4);
		DATA2_tb      <= TEST_VALUES(4);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(4) AND DATA2_tb = TEST_VALUES(4) AND OVF_tb = '1' AND CARRY_tb = '0' AND ZERO_tb = '1' AND NEG_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(8)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "OVF exp val : " & STD_LOGIC'image('1') & "OVF obt val : " & STD_LOGIC'image(OVF_tb) & "CARRY expt val : " & STD_LOGIC'image('0') & "CARRY obt val : " & STD_LOGIC'image(CARRY_tb) & "ZERO exp val : " & STD_LOGIC'image('1') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb) & "NEG expt val : " & STD_LOGIC'image('0') & "NEG obt val : " & STD_LOGIC'image(NEG_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= I_subi;
		DATA1_tb      <= TEST_VALUES(4);
		DATA2_tb      <= x"0FFFDDEE";
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(4) AND DATA2_tb = x"0FFFDDEE" AND OVF_tb = '0' AND CARRY_tb = '0' AND ZERO_tb = '0' AND NEG_tb = '1')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(20)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "OVF exp val : " & STD_LOGIC'image('0') & "OVF obt val : " & STD_LOGIC'image(OVF_tb) & "CARRY exp val : " & STD_LOGIC'image('0') & "CARRY obt val : " & STD_LOGIC'image(CARRY_tb) & "ZERO exp val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb) & "NEG exp val : " & STD_LOGIC'image('1') & "NEG obt val : " & STD_LOGIC'image(NEG_tb)
			SEVERITY failure;
		REPORT("TEST 5 result: SUCCESSFUL");

		--############################ TEST 6 ############################--
		REPORT("TEST 6:   - LOGIC OPERATIONS : AND, OR, XOR ");
		ALU_OPCODE_tb <= R_and;
		DATA1_tb      <= TEST_VALUES(13);
		DATA2_tb      <= TEST_VALUES(14);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(13) AND DATA2_tb = TEST_VALUES(14) AND ZERO_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(21)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "ZERO exp val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= I_ori;
		DATA1_tb      <= TEST_VALUES(13);
		DATA2_tb      <= TEST_VALUES(14);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(13) AND DATA2_tb = TEST_VALUES(14) AND ZERO_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(22)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "ZERO exp val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= R_xor;
		DATA1_tb      <= TEST_VALUES(13);
		DATA2_tb      <= TEST_VALUES(14);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(13) AND DATA2_tb = TEST_VALUES(14) AND ZERO_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(23)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "ZERO exp val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb)
			SEVERITY failure;
		REPORT("TEST 6 result: SUCCESSFUL");

		--############################ TEST 7 ############################--
		REPORT("TEST 7:   - SHIFTS");
		ALU_OPCODE_tb <= I_lhi; --shift left by 16
		DATA1_tb      <= TEST_VALUES(13);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(13) AND CARRY_tb = '0' AND ZERO_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(24)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "CARRY exp val : " & STD_LOGIC'image('0') & "CARRY obt val : " & STD_LOGIC'image(CARRY_tb) & "ZERO exp val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= I_slli; -- shift left by uimm16_27..31]
		DATA1_tb      <= TEST_VALUES(13);
		DATA2_tb      <= TEST_VALUES(19);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(13) AND DATA2_tb = TEST_VALUES(19) AND CARRY_tb = '1' AND ZERO_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(25)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "CARRY exp val : " & STD_LOGIC'image('1') & "CARRY obt val : " & STD_LOGIC'image(CARRY_tb) & "ZERO exp val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= I_srli; -- shift right by uimm16_27..31]
		DATA1_tb      <= TEST_VALUES(13);
		DATA2_tb      <= TEST_VALUES(1);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(13) AND DATA2_tb = TEST_VALUES(1) AND CARRY_tb = '1' AND ZERO_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(26)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "CARRY exp val : " & STD_LOGIC'image('1') & "CARRY obt val : " & STD_LOGIC'image(CARRY_tb) & "ZERO exp val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= I_srai; -- arithmetic shift 
		DATA1_tb      <= TEST_VALUES(13);
		DATA2_tb      <= TEST_VALUES(27);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(13) AND DATA2_tb = TEST_VALUES(27)AND CARRY_tb = '0' AND ZERO_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(28)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "CARRY exp val : " & STD_LOGIC'image('0') & "CARRY obt val : " & STD_LOGIC'image(CARRY_tb) & "ZERO exp val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb)
			SEVERITY failure;
		REPORT("TEST 7 result: SUCCESSFUL");

		--############################ TEST 8 ############################--
		REPORT("TEST 8:   - COMPARISONS");
		ALU_OPCODE_tb <= I_seqi; --equal
		DATA1_tb      <= TEST_VALUES(13);
		DATA2_tb      <= TEST_VALUES(13);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(13) AND DATA2_tb = TEST_VALUES(13) AND ZERO_tb = '0')
		REPORT " OUTALU exp val: " & STD_LOGIC'image('1') & " OUTALU obt val: " & STD_LOGIC'image(OUTALU_tb(0)) & "ZERO exp val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= R_sne; --different
		DATA1_tb      <= TEST_VALUES(13);
		DATA2_tb      <= TEST_VALUES(4);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(13) AND DATA2_tb = TEST_VALUES(4) AND ZERO_tb = '0')
		REPORT " OUTALU exp val: " & STD_LOGIC'image('1') & " OUTALU obt val: " & STD_LOGIC'image(OUTALU_tb(0)) & "ZERO exp val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= I_slti; --lower than
		DATA1_tb      <= TEST_VALUES(4);
		DATA2_tb      <= TEST_VALUES(1);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(4) AND DATA2_tb = TEST_VALUES(1) AND ZERO_tb = '0')
		REPORT " OUTALU exp val: " & STD_LOGIC'image('1') & " OUTALU obt val: " & STD_LOGIC'image(OUTALU_tb(0)) & "ZERO exp val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= I_sgti; --greater than
		DATA1_tb      <= TEST_VALUES(1);
		DATA2_tb      <= TEST_VALUES(4);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(1) AND DATA2_tb = TEST_VALUES(4) AND ZERO_tb = '0')
		REPORT " OUTALU exp val: " & STD_LOGIC'image('1') & " OUTALU obt val: " & STD_LOGIC'image(OUTALU_tb(0)) & "ZERO exp val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= I_slei; --lower and equal than
		DATA1_tb      <= TEST_VALUES(1);
		DATA2_tb      <= TEST_VALUES(4);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(1) AND DATA2_tb = TEST_VALUES(4) AND ZERO_tb = '1')
		REPORT " OUTALU exp val: " & STD_LOGIC'image('0') & " OUTALU obt val: " & STD_LOGIC'image(OUTALU_tb(0)) & "ZERO exp val : " & STD_LOGIC'image('1') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= R_sge; --greater and equal than
		DATA1_tb      <= TEST_VALUES(4);
		DATA2_tb      <= TEST_VALUES(1);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(4) AND DATA2_tb = TEST_VALUES(1) AND ZERO_tb = '1')
		REPORT " OUTALU exp val: " & STD_LOGIC'image('0') & " OUTALU obt val: " & STD_LOGIC'image(OUTALU_tb(0)) & "ZERO exp val : " & STD_LOGIC'image('1') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= I_sltui; --lower than
		DATA1_tb      <= TEST_VALUES(1);
		DATA2_tb      <= TEST_VALUES(0);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(1) AND DATA2_tb = TEST_VALUES(0) AND ZERO_tb = '0')
		REPORT " OUTALU exp val: " & STD_LOGIC'image('1') & " OUTALU obt val: " & STD_LOGIC'image(OUTALU_tb(0)) & "ZERO exp val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= I_sgtui; --greater than
		DATA1_tb      <= TEST_VALUES(0);
		DATA2_tb      <= TEST_VALUES(1);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(0) AND DATA2_tb = TEST_VALUES(1) AND ZERO_tb = '0')
		REPORT " OUTALU exp val: " & STD_LOGIC'image('1') & " OUTALU obt val: " & STD_LOGIC'image(OUTALU_tb(0)) & "ZERO exp val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= I_sleui; --lower and equal than
		DATA1_tb      <= TEST_VALUES(0);
		DATA2_tb      <= TEST_VALUES(1);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(0) AND DATA2_tb = TEST_VALUES(1) AND ZERO_tb = '1')
		REPORT " OUTALU exp val: " & STD_LOGIC'image('0') & " OUTALU obt val: " & STD_LOGIC'image(OUTALU_tb(0)) & "ZERO exp val : " & STD_LOGIC'image('1') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= I_sgeui; --greater and equal than
		DATA1_tb      <= TEST_VALUES(1);
		DATA2_tb      <= TEST_VALUES(0);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(1) AND DATA2_tb = TEST_VALUES(0) AND ZERO_tb = '1')
		REPORT " OUTALU exp val: " & STD_LOGIC'image('0') & " OUTALU obt val: " & STD_LOGIC'image(OUTALU_tb(0)) & "ZERO exp val : " & STD_LOGIC'image('1') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb)
			SEVERITY failure;
		REPORT("TEST 8 result: SUCCESSFUL");

		--############################ TEST 9 ############################--
		REPORT("TEST 9:   - SIGNED MULTIPLICATION");
		ALU_OPCODE_tb <= R_mult;
		DATA1_tb      <= TEST_VALUES(27);
		DATA2_tb      <= TEST_VALUES(2);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(27) AND DATA2_tb = TEST_VALUES(2) AND ZERO_tb = '0' AND NEG_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(29)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "ZERO exp val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb) & "NEG exp val : " & STD_LOGIC'image('0') & "NEG obt val : " & STD_LOGIC'image(NEG_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= R_mult;
		DATA1_tb      <= TEST_VALUES(4);
		DATA2_tb      <= TEST_VALUES(4);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(4) AND DATA2_tb = TEST_VALUES(4) AND ZERO_tb = '0' AND NEG_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(1)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "ZERO exp val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb) & "NEG exp val : " & STD_LOGIC'image('0') & "NEG obt val : " & STD_LOGIC'image(NEG_tb)
			SEVERITY failure;
		REPORT("TEST 9 result: SUCCESSFUL");

		--############################ TEST 10 ############################--
		REPORT("TEST 10:   - UNSIGNED MULTIPLICATION");
		ALU_OPCODE_tb <= R_multu;
		DATA1_tb      <= TEST_VALUES(20);
		DATA2_tb      <= TEST_VALUES(23);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(20) AND DATA2_tb = TEST_VALUES(23) AND ZERO_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(30)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "ZERO exp val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= R_multu;
		DATA1_tb      <= TEST_VALUES(4);
		DATA2_tb      <= TEST_VALUES(23);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(4) AND DATA2_tb = TEST_VALUES(23) AND ZERO_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(31)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "ZERO exp val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb)
			SEVERITY failure;
		ALU_OPCODE_tb <= R_multu;
		DATA1_tb      <= TEST_VALUES(4);
		DATA2_tb      <= TEST_VALUES(4);
		WAIT FOR Tclk;
		ASSERT(DATA1_tb = TEST_VALUES(4) AND DATA2_tb = TEST_VALUES(4) AND ZERO_tb = '0')
		REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(31)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "ZERO exp val : " & STD_LOGIC'image('0') & "ZERO obt val : " & STD_LOGIC'image(ZERO_tb)
			SEVERITY failure;
		REPORT("TEST 10 result: SUCCESSFUL");

		REPORT("End simulation");
		WAIT;
	END PROCESS;
END TEST;