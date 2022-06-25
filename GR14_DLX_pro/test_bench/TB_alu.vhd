LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_ALU IS 
END TB_ALU;

ARCHITECTURE TEST OF TB_ALU IS 

	SIGNAL ALU_OPCODE_tb : ALU_MSG := I_addui;
	SIGNAL DATA1_tb      : STD_LOGIC_VECTOR(0 TO NbitLong- 1);
	SIGNAL DATA2_tb      : STD_LOGIC_VECTOR(0 TO NbitLong - 1);
	SIGNAL NEG_tb        : STD_LOGIC;
	SIGNAL ZERO_tb       : STD_LOGIC;
	SIGNAL CARRY_tb      : STD_LOGIC;
	SIGNAL OVF_tb        : STD_LOGIC;
	SIGNAL OUTALU_tb     : STD_LOGIC_VECTOR(0 TO NbitLong - 1);
	SUBTYPE NUM_INPUTS IS NATURAL RANGE 0 TO 20;
	TYPE TEST_VECT IS ARRAY(NUM_INPUTS) OF STD_LOGIC_VECTOR(0 TO NbitLong - 1);
	SIGNAL TEST_VALUES   : TEST_VECT;

	COMPONENT ALU IS
		GENERIC
			(N : INTEGER := NbitLong);
		PORT
		(
			ALU_OPCODE            : IN ALU_MSG;
			DATA1, DATA2          : IN STD_LOGIC_VECTOR(0 TO NbitLong - 1);
			NEG, ZERO, CARRY, OVF : OUT STD_LOGIC;
			OUTALU                : OUT STD_LOGIC_VECTOR(0 TO Nbitlong - 1)
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
	x"EFFFFFFE", --[18]
	x"00000FF9", --[19]
	x"FFD00003" --[20]
	);

	DUT : ALU
	GENERIC MAP(N  => NbitLong)
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
	DATA1_tb <= STD_LOGIC_VECTOR(to_unsigned(5, NbitLong));
	DATA2_tb <= STD_LOGIC_VECTOR(to_unsigned(2, NbitLong));
	WAIT FOR 2 ns;
	ASSERT(DATA1_tb = STD_LOGIC_VECTOR(to_unsigned(5, NbitLong)) AND DATA2_tb = STD_LOGIC_VECTOR(to_unsigned(2, NbitLong)))
	REPORT " OUTALU exp val: " & INTEGER'image(7) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb))) & "OVF exp val :" & STD_LOGIC'image('0') & "OVF obt val:" & STD_LOGIC'image(OVF_tb)
		SEVERITY failure;
	
	ALU_OPCODE_tb <= I_addui;
	DATA1_tb <= TEST_VALUES(0);
	DATA2_tb <= TEST_VALUES(1);
	WAIT FOR 2 ns;
	ASSERT(DATA1_tb = TEST_VALUES(0) AND DATA2_tb = TEST_VALUES(1))
	REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(9)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb)))
		SEVERITY failure;
	
	ALU_OPCODE_tb <= I_jalr;
	DATA1_tb <= TEST_VALUES(4);
	DATA2_tb <= STD_LOGIC_VECTOR(to_unsigned(1, NbitLong));
	WAIT FOR 2 ns;
	ASSERT(DATA1_tb = TEST_VALUES(4) AND DATA2_tb = STD_LOGIC_VECTOR(to_unsigned(1, NbitLong)))
	REPORT " OUTALU exp val: " & INTEGER'image(0) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb)))
		SEVERITY failure;
	
	REPORT("TEST 1 result: SUCCESSFUL");
	--############################ TEST 2 ############################--
	REPORT("TEST 2:   - SIGNED ADDITION");
	
	ALU_OPCODE_tb <= I_sb;
	DATA1_tb <= TEST_VALUES(0);
	DATA2_tb <= TEST_VALUES(1);
	WAIT FOR 2 ns;
	ASSERT(DATA1_tb = TEST_VALUES(0) AND DATA2_tb = TEST_VALUES(1))
	REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(9)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb)))
		SEVERITY failure;
	
	ALU_OPCODE_tb <= J_jal;
	DATA1_tb <= TEST_VALUES(4);
	DATA2_tb <= TEST_VALUES(5);
	WAIT FOR 2 ns;
	ASSERT(DATA1_tb = TEST_VALUES(4) AND DATA2_tb = TEST_VALUES(5))
	REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(11)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb)))
		SEVERITY failure;
	
	ALU_OPCODE_tb <= R_add;
	DATA1_tb <= TEST_VALUES(6);
	DATA2_tb <= TEST_VALUES(7);
	WAIT FOR 2 ns;
	ASSERT(DATA1_tb = TEST_VALUES(6) AND DATA2_tb = TEST_VALUES(7))
	REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(12)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb)))
		SEVERITY failure;
	
	REPORT("TEST 2 result: SUCCESSFUL");
	--############################ TEST 3 ############################--
	REPORT("TEST 3:   - I_beqz  -I_bnez");

	ALU_OPCODE_tb <= I_beqz;
	DATA1_tb <= TEST_VALUES(13);
	DATA2_tb <= TEST_VALUES(8);
	WAIT FOR 2 ns;
	ASSERT(DATA1_tb = TEST_VALUES(13) AND DATA2_tb = TEST_VALUES(8))
	REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(13)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb)))
		SEVERITY failure;

	ALU_OPCODE_tb <= I_bnez;
	DATA1_tb <= TEST_VALUES(13);
	DATA2_tb <= TEST_VALUES(14);
	WAIT FOR 2 ns;
	ASSERT(DATA1_tb = TEST_VALUES(13) AND DATA2_tb = TEST_VALUES(14))
	REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(15)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb)))
		SEVERITY failure;

	ALU_OPCODE_tb <= I_bnez;
	DATA1_tb <= TEST_VALUES(4);
	DATA2_tb <= TEST_VALUES(5);
	WAIT FOR 2 ns;
	ASSERT(DATA1_tb = TEST_VALUES(4) AND DATA2_tb = TEST_VALUES(5))
	REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(11)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb)))
		SEVERITY failure;

	REPORT("TEST 3 result: SUCCESSFUL");
	--############################ TEST 4 ############################--
	REPORT("TEST 4:   - UNSIGNED SUBTRACTION");

	ALU_OPCODE_tb <= I_subui;
	DATA1_tb <= TEST_VALUES(14);
	DATA2_tb <= TEST_VALUES(7);
	WAIT FOR 2 ns;
	ASSERT(DATA1_tb = TEST_VALUES(14) AND DATA2_tb = TEST_VALUES(7))
	REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(16)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb)))
		SEVERITY failure;

	ALU_OPCODE_tb <= R_subu;
	DATA1_tb <= TEST_VALUES(4);
	DATA2_tb <= TEST_VALUES(4);
	WAIT FOR 2 ns;
	ASSERT(DATA1_tb = TEST_VALUES(4) AND DATA2_tb = TEST_VALUES(4))
	REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(8)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb)))
		SEVERITY failure;
	
	REPORT("TEST 4 result: SUCCESSFUL");
	--############################ TEST 5 ############################--
	REPORT("TEST 5:   - SIGNED SUBTRACTION");

	ALU_OPCODE_tb <= I_subi;
	DATA1_tb <= TEST_VALUES(17);
	DATA2_tb <= TEST_VALUES(9);
	WAIT FOR 2 ns;
	ASSERT(DATA1_tb = TEST_VALUES(17) AND DATA2_tb = TEST_VALUES(9))
	REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(18)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb)))
		SEVERITY failure;

	ALU_OPCODE_tb <= R_sub;
	DATA1_tb <= TEST_VALUES(4);
	DATA2_tb <= TEST_VALUES(4);
	WAIT FOR 2 ns;
	ASSERT(DATA1_tb = TEST_VALUES(4) AND DATA2_tb = TEST_VALUES(4))
	REPORT " OUTALU exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(TEST_VALUES(8)))) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb)))
		SEVERITY failure;

	REPORT("TEST 5 result: SUCCESSFUL");
	--############################ TEST 6 ############################--
	--REPORT("TEST 6:   - LOGIC OPERATIONS : AND, OR, XOR ");
	--REPORT("TEST 6 result: SUCCESSFUL");
	--############################ TEST 7 ############################--
	--REPORT("TEST 7:   - SHIFTS");
	--REPORT("TEST 7 result: SUCCESSFUL");
	--############################ TEST 8 ############################--
	--REPORT("TEST 8:   - COMPARISONS");
	--REPORT("TEST 8 result: SUCCESSFUL");
	--############################ TEST 9 ############################--
	--REPORT("TEST 9:   - UNSIGNED MULTIPLICATION");
	--REPORT("TEST 9 result: SUCCESSFUL");
	--############################ TEST 10 ############################--
	--REPORT("TEST 10:   - SIGNED MULTIPLICATION");
	--REPORT("TEST 10 result: SUCCESSFUL");


	END PROCESS;

END TEST;
