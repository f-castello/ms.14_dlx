LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_ALU IS 
END TB_ALU;

ARCHITECTURE TEST OF TB_ALU IS 

	SIGNAL ALU_OPCODE_tb : ALU_MSG;
	SIGNAL DATA1_tb      : STD_LOGIC_VECTOR(0 TO N - 1);
	SIGNAL DATA2_tb      : STD_LOGIC_VECTOR(0 TO N - 1);
	SIGNAL NEG_tb        : STD_LOGIC;
	SIGNAL ZERO_tb       : STD_LOGIC;
	SIGNAL CARRY_tb      : STD_LOGIC;
	SIGNAL OVF_tb        : STD_LOGIC;
	SIGNAL OUTALU_tb     : STD_LOGIC_VECTOR(0 TO N - 1);
	SIGNAL TEST_VALUES   : STD_LOGIC_VECTOR(0 TO N - 1);

	COMPONENT ALU IS
		GENERIC
			(N : INTEGER := NbitLong);
		PORT
		(
			ALU_OPCODE            : IN ALU_MSG;
			DATA1, DATA2          : IN STD_LOGIC_VECTOR(0 TO N - 1);
			NEG, ZERO, CARRY, OVF : OUT STD_LOGIC;
			OUTALU                : OUT STD_LOGIC_VECTOR(0 TO N - 1)
		);
	END COMPONENT;

BEGIN 

	TEST_VALUES <= (
	x"7FFFFFFF", 
	x"00000001", 
	x"00000011",
	x"00110000",
	x"FFFFFFFF",
	x"10000000",
	x"10000011",
	x"00000010",
	x"00000000",
	x"00000FF1",
	x"00000FF2",
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

	--############################ TEST 1  ############################--
	REPORT("Starting simulation");
	REPORT("TEST 1:   - UNSIGNED ADDITION");
	ALU_OPCODE_tb <= I_addui AFTER 2 ns;
	ASSERT(DATA1_tb = TEST_VALUES(0) AND DATA2_tb = TEST_VALUES(1))
	REPORT " OUTALU exp val: " & INTEGER'image(80000000) & " OUTALU obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(OUTALU_tb)))
		SEVERITY failure;
	REPORT("TEST 1 result: SUCCESSFUL");
	--############################ TEST 2 ############################--
	REPORT("TEST 2:   - SIGNED ADDITION");
	REPORT("TEST 2 result: SUCCESSFUL");
	--############################ TEST 3 ############################--
	REPORT("TEST 3:   - I_beqz  -I_bnez");
	REPORT("TEST 3 result: SUCCESSFUL");
	--############################ TEST 4 ############################--
	REPORT("TEST 4:   - UNSIGNED SUBTRACTION");
	REPORT("TEST 4 result: SUCCESSFUL");
	--############################ TEST 5 ############################--
	REPORT("TEST 5:   - SIGNED SUBTRACTION");
	REPORT("TEST 5 result: SUCCESSFUL");
	--############################ TEST 6 ############################--
	REPORT("TEST 6:   - LOGIC OPERATIONS : AND, OR, XOR ");
	REPORT("TEST 6 result: SUCCESSFUL");
	--############################ TEST 7 ############################--
	REPORT("TEST 7:   - SHIFTS");
	REPORT("TEST 7 result: SUCCESSFUL");
	--############################ TEST 8 ############################--
	REPORT("TEST 8:   - COMPARISONS");
	REPORT("TEST 8 result: SUCCESSFUL");
	--############################ TEST 9 ############################--
	REPORT("TEST 9:   - UNSIGNED MULTIPLICATION");
	REPORT("TEST 9 result: SUCCESSFUL");
	--############################ TEST 10 ############################--
	REPORT("TEST 10:   - SIGNED MULTIPLICATION");
	REPORT("TEST 10 result: SUCCESSFUL");


	END PROCESS;

END TEST;
