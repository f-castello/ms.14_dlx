LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.dlx_utils.ALL;

ENTITY EXE_STAGE IS
	GENERIC 
	(
		N_BITS_PC   : NATURAL := NbitLong; -- # of bits
		N_BITS_DATA : NATURAL := NbitLong;
		RF_ADDR     : NATURAL := RF_ADDR -- # OF BITS FOR REGISTER FILE ADDRESS
	);
	PORT
	(
		-- Control ports 
		CLK 		  : IN STD_LOGIC;
		RST           : IN STD_LOGIC;
		MUXA_SEL      : IN STD_LOGIC; -- MUXA Sel
		MUXB_SEL      : IN STD_LOGIC; -- MUXB Sel
		EXE_OUTREG_EN : IN STD_LOGIC; -- (OUTALU, cpsr, branch_taken, NPC2, IR2) Registers Enable
		FLAGS_RST     : IN STD_LOGIC; -- Current Program Status Register Reset
		EQ_COND       : IN STD_LOGIC; -- Branch if (not) Equal to Zero
		JUMP_EN       : IN STD_LOGIC -- Jump Enable Signal for Cond Selection
		ALU_OPCODE    : IN ALU_MSG;  -- Custom Type for ALU Ops
		-- Data ports
		NPC2_IN 	   : IN STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0); -- NPC2 reg input
		NPC_MUXA_IN    : IN STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0); -- Input 0 of the first multiplexer
		REGA_MUXA_IN   : IN STD_LOGIC_VECTOR(N_BITS_DATA-1 downto 0); -- Input 1 of the first multiplexer
		REGB_MUXB_IN   : IN STD_LOGIC_VECTOR(N_BITS_DATA-1 downto 0); -- Input 0 of the second multiplexer
		IMM_MUXB_IN    : IN STD_LOGIC_VECTOR(N_BITS_DATA-1 downto 0); -- Input 1 of the second multiplexer
		IR2_IN         : IN STD_LOGIC_VECTOR(RF_ADDR-1 downto 0); -- IR2 reg input
		NPC2_OUT 	   : OUT STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0); -- NPC2 reg output
		COND_OUT       : OUT STD_LOGIC; 							   -- Output of the branch_cond logic
		ALU_OUT        : OUT STD_LOGIC_VECTOR(N_BITS_DATA-1 downto 0); -- Output data of the ALU
		IR2_OUT        : OUT STD_LOGIC_VECTOR(RF_ADDR-1 downto 0) -- IR2 reg output
		N_FLAG         : OUT STD_LOGIC; -- Negative condition code flag ALU 
		Z_FLAG         : OUT STD_LOGIC; -- Zero condition code flag ALU 
		C_FLAG         : OUT STD_LOGIC; -- Carry condition code flag ALU 
		V_FLAG         : OUT STD_LOGIC -- Overflow condition code flag ALU 
	);

END EXE_STAGE;

ARCHITECTURE STRUCTURAL OF EXE_STAGE IS

	SIGNAL BRANCH_TAKEN : STD_LOGIC;
	SIGNAL MUXA_OUT_INT : STD_LOGIC_VECTOR(N_BITS_DATA-1 downto 0);
	SIGNAL MUXB_OUT_INT : STD_LOGIC_VECTOR(N_BITS_DATA-1 downto 0);
	SIGNAL ALU_OUT_INT  : STD_LOGIC_VECTOR(N_BITS_DATA-1 downto 0);
	SIGNAL NEG_INT      : STD_LOGIC;
	SIGNAL ZERO_INT     : STD_LOGIC;
	SIGNAL OVF_INT      : STD_LOGIC;
	SIGNAL CARRY_INT    : STD_LOGIC;

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

	COMPONENT gen_mux21 IS
    GENERIC
    (
        N : NATURAL := NbitLong
    );
    PORT
    (
        sel  : IN STD_LOGIC; -- selector
        x, y : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        m    : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
    );
	END COMPONENT;

	COMPONENT zero_check IS
    GENERIC
    (
        N : NATURAL := NbitLong 
    );
    PORT
    (
        data_in  : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        ctrl_out : OUT STD_LOGIC
    );
	END COMPONENT;

	COMPONENT cond_branch IS
    PORT
    (
        cond_in, jump_in, ctrl_in : IN STD_LOGIC;
        ctrl_out                  : OUT STD_LOGIC
    );
	END COMPONENT;

	COMPONENT cpsr IS
    PORT
    (
       clk, rst, ld, FL3, FL2, FL1, FL0 : IN STD_LOGIC;
       N, Z, C, V                       : OUT STD_LOGIC
    );
	END COMPONENT;

	COMPONENT ALU IS
	GENERIC (N : INTEGER := NbitLong);
	PORT (
		FUNC             : IN ALU_MSG;
		DATA1, DATA2     : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		NEG, ZERO, OVF, CARRY : OUT STD_LOGIC; -- essential status flags for unsigned operation
		OUTALU           : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
	);
	END COMPONENT;

BEGIN 

	NPC2 : gen_reg GENERIC MAP (N => N_BITS_PC)
	PORT MAP(
		clk  	 => CLK,
		rst  	 => RST,
		ld   	 => EXE_OUTREG_EN,
		data_in  => NPC2_IN,
		data_out => NPC2_OUT
	);

	ZERO? : zero_check GENERIC MAP (N => N_BITS_DATA)
	PORT MAP(
		data_in  => REGA_MUXA_IN,
		ctrl_out => BRANCH_TAKEN
	);

	COND : cond_branch 
	PORT MAP(
		cond_in  => EQ_COND,
		jump_in  => JUMP_EN,
		ctrl_in  => BRANCH_TAKEN,
		ctrl_out => COND_OUT
	);

	MUXA : gen_mux21 GENERIC MAP (N => N_BITS_DATA) -- N_BITS_DATA = N_BITS_PC
	PORT MAP (
		 sel     => MUXA_SEL,
		 x       => NPC_MUXA_IN,
		 y       => REGA_MUXA_IN,
		 m       => MUXA_OUT_INT
	);

	MUXB : gen_mux21 GENERIC MAP (N => N_BITS_DATA) -- N_BITS_DATA = N_BITS_PC
	PORT MAP (
		 sel     => MUXB_SEL,
		 x       => REGB_MUXB_IN,
		 y       => IMM_MUXB_IN,
		 m       => MUXB_OUT_INT
	);

	ALU : alu GENERIC MAP (N => NbitLong)
	PORT MAP (
		FUNC     => ALU_OPCODE,
		DATA1    => MUXA_OUT_INT,
		DATA2    => MUXB_OUT_INT,
		NEG      => NEG_INT,
		ZERO     => ZERO_INT,
		OVF      => OVF_INT,
		OUTALU   => ALU_OUT_INT
	);

	ALU_OUTPUT : : gen_reg GENERIC MAP (N => N_BITS_DATA)
	PORT MAP(
		clk  	 => CLK,
		rst  	 => RST,
		ld   	 => EXE_OUTREG_EN,
		data_in  => ALU_OUT_INT,
		data_out => ALU_OUT
	);

	ALU_FLAGS : cpsr 
	PORT MAP (
		clk      => CLK,
		rst      => FLAGS_RST,
		ld       => EXE_OUTREG_EN,
		FL0      => NEG_INT,
		FL1      => ZERO_INT
		FL2      => CARRY_INT,
		FL3      => OVF_INT,
		N        => N_FLAG,
		Z        => Z_FLAG,
		C        => C_FLAG,
		V        => V_FLAG
	);

	IR2 : gen_reg GENERIC MAP (N => RF_ADDR)
	PORT MAP(
		clk  	 => CLK,
		rst  	 => RST,
		ld   	 => EXE_OUTREG_EN,
		data_in  => IR2_IN,
		data_out => IR2_OUT
	);

END STRUCTURAL;