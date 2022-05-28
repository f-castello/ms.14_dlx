LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_ID IS
END TB_ID;

ARCHITECTURE TEST OF TB_ID IS

    TYPE MEM_ARRAY IS ARRAY (0 to 31) OF STD_LOGIC_VECTOR(NbitLong-1 downto 0);
    CONSTANT RF_COPY : MEM_ARRAY  := 
    (
        std_logic_vector(to_unsigned(0,NbitLong)),
        std_logic_vector(to_unsigned(101111,NbitLong)),
        std_logic_vector(to_unsigned(202,NbitLong)),
        std_logic_vector(to_unsigned(3033,NbitLong)),
        std_logic_vector(to_unsigned(40,NbitLong)),
        std_logic_vector(to_unsigned(50555,NbitLong)),
        std_logic_vector(to_unsigned(60666666,NbitLong)),
        std_logic_vector(to_unsigned(70,NbitLong)),
        std_logic_vector(to_unsigned(80888888,NbitLong)),
        std_logic_vector(to_unsigned(90,NbitLong)),
        std_logic_vector(to_unsigned(1000,NbitLong)),
        std_logic_vector(to_unsigned(11,NbitLong)),
        std_logic_vector(to_unsigned(12,NbitLong)),
        std_logic_vector(to_unsigned(13,NbitLong)),
        std_logic_vector(to_unsigned(14,NbitLong)),
        std_logic_vector(to_unsigned(15,NbitLong)),
        std_logic_vector(to_unsigned(16,NbitLong)),
        std_logic_vector(to_unsigned(17,NbitLong)),   
        std_logic_vector(to_unsigned(18,NbitLong)),
        std_logic_vector(to_unsigned(19,NbitLong)),
        std_logic_vector(to_unsigned(20,NbitLong)),
        std_logic_vector(to_unsigned(21,NbitLong)),
        std_logic_vector(to_unsigned(22,NbitLong)),
        std_logic_vector(to_unsigned(23,NbitLong)),
        std_logic_vector(to_unsigned(24,NbitLong)),
        std_logic_vector(to_unsigned(25,NbitLong)),
        std_logic_vector(to_unsigned(26,NbitLong)),
        std_logic_vector(to_unsigned(27,NbitLong)),
        std_logic_vector(to_unsigned(28,NbitLong)),
        std_logic_vector(to_unsigned(29,NbitLong)),
        std_logic_vector(to_unsigned(30,NbitLong)),
        std_logic_vector(to_unsigned(31,NbitLong))
    );

    SIGNAL CLK_tb			 : STD_LOGIC := '0';
    -- Control signals
    SIGNAL RST_tb			 : STD_LOGIC;
    SIGNAL JAL_MUX_SEL_tb	 : STD_LOGIC;
    SIGNAL DEC_OUTREG_EN_tb  : STD_LOGIC; -- (A, B, Imm, NPC1, IR1) Registers Enable
    SIGNAL IS_I_TYPE_tb      : STD_LOGIC; -- Detect I-Type Instructions for Sign Extension & Writing Address Selection
    SIGNAL RD1_en_tb		 : STD_LOGIC; --enable reading port 1 of the RF
    SIGNAL RD2_en_tb		 : STD_LOGIC; --enable reading port 2 of the RF
    SIGNAL WR_en_tb			 : STD_LOGIC; --enable writing port of the RF
    --Data signals
    SIGNAL I_CODE_tb  	     : STD_LOGIC_VECTOR(IR_N-1 downto 0); -- output of the memory to the IR
    SIGNAL NPC1_IN_tb		 : STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0);
    SIGNAL DATA_IN_tb		 : STD_LOGIC_VECTOR(N_BITS_DATA-1 downto 0);
    SIGNAL WR_ADDR_IN_tb     : STD_LOGIC_VECTOR(RF_ADDR-1 downto 0);
    SIGNAL REGA_OUT_tb       : STD_LOGIC_VECTOR(N_BITS_DATA-1 downto 0);
    SIGNAL REGB_OUT_tb       : STD_LOGIC_VECTOR(N_BITS_DATA-1 downto 0);
    SIGNAL REGIMM_OUT_tb     : STD_LOGIC_VECTOR(N_BITS_DATA-1 downto 0);
    SIGNAL WR_ADDR_OUT_tb    : STD_LOGIC_VECTOR(RF_ADDR-1 downto 0);
    SIGNAL NPC1_OUT_tb		 : STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0); --IN EX STAGE, THE INPUT 0 OF FIRST MUX SHOULD BE THIS REGISTER?

    COMPONENT ID_STAGE IS
        GENERIC
        (
            N_BITS_PC   : NATURAL := NbitLong; -- # of bits
            N_BITS_INST : NATURAL := IR_N;
            N_BYTES_INST: NATURAL := NPC_GAP;
            N_BITS_DATA : NATURAL := NbitLong;
            RF_ADDR     : NATURAL := RF_ADDR; -- # OF BITS FOR REGISTER FILE ADDRESS
            NBITS_JUMP 	: NATURAL := NbitJump;  -- # OF BITS OF THE INPUT OF THE SIGN EXTENTION
            NBITS_IMM 	: NATURAL := NbitShort
        );
        PORT
        (
            -- Control ports
            CLK 		    : IN STD_LOGIC;
            RST			    : IN STD_LOGIC;
            JAL_MUX_SEL		: IN STD_LOGIC;
            DEC_OUTREG_EN   : IN STD_LOGIC; -- (A, B, Imm, NPC1, IR1) Registers Enable
            IS_I_TYPE       : IN STD_LOGIC; -- Detect I-Type Instructions for Sign Extension & Writing Address Selection
            RD1_en		  	: IN STD_LOGIC; -- Register File Read 1 Enable
            RD2_en			: IN STD_LOGIC; -- Register File Read 2 Enable
            WR_en			: IN STD_LOGIC; --enable writing port of the RF
            -- Data ports
            I_CODE  	    : IN STD_LOGIC_VECTOR(N_BITS_INST-1 downto 0); -- output of the memory to the IR
            NPC1_IN		    : IN STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0);
            DATA_IN			: IN STD_LOGIC_VECTOR(N_BITS_DATA-1 downto 0);
            WR_ADDR_IN     	: IN STD_LOGIC_VECTOR(RF_ADDR-1 downto 0);
            REGA_OUT        : OUT STD_LOGIC_VECTOR(N_BITS_DATA-1 downto 0);
            REGB_OUT        : OUT STD_LOGIC_VECTOR(N_BITS_DATA-1 downto 0);
            REGIMM_OUT      : OUT STD_LOGIC_VECTOR(N_BITS_DATA-1 downto 0);
            WR_ADDR_OUT     : OUT STD_LOGIC_VECTOR(RF_ADDR-1 downto 0);
            NPC1_OUT		: OUT STD_LOGIC_VECTOR(N_BITS_PC-1 downto 0) --IN EX STAGE, THE INPUT 0 OF FIRST MUX SHOULD BE THIS REGISTER?


        );
    END COMPONENT;

BEGIN 
    DUT: ID_STAGE
    GENERIC MAP(
        N_BITS_PC       => N_BITS_PC, -- # of bits
        N_BITS_INST     => IR_N,
        N_BYTES_INST    => NPC_GAP,
        N_BITS_DATA     => N_BITS_DATA,
        RF_ADDR         => RF_ADDR, -- # OF BITS FOR REGISTER FILE ADDRESS
        NBITS_JUMP 	    => NbitJump,  -- # OF BITS OF THE INPUT OF THE SIGN EXTENTION
        NBITS_IMM 	    => NbitShort
    )
    PORT MAP(
         -- Control ports
         CLK 		    =>CLK_tb,
         RST			=>RST_tb,
         JAL_MUX_SEL	=>JAL_MUX_SEL_tb,--
         DEC_OUTREG_EN  =>DEC_OUTREG_EN_tb,--(A, B, Imm, NPC1, IR1) Registers Enable
         IS_I_TYPE      =>IS_I_TYPE_tb,--Detect I-Type Instructions for Sign Extension & Writing Address Selection
         RD1_en		  	=>RD1_en_tb, --enable reading port 1 of the RF
         RD2_en			=>RD2_en_tb, --enable reading port 2 of the RF
         WR_en			=>WR_en_tb, --enable writing port of the RF
         -- Data ports
         I_CODE  	    =>I_CODE_tb, -- output of the memory to the IR
         NPC1_IN		=>NPC1_IN_tb,
         DATA_IN		=>DATA_IN_tb,
         WR_ADDR_IN     =>WR_ADDR_IN_tb,
         REGA_OUT       =>REGA_OUT_tb,
         REGB_OUT       =>REGB_OUT_tb,
         REGIMM_OUT     =>REGIMM_OUT_tb,
         WR_ADDR_OUT    =>WR_ADDR_OUT_tb,
         NPC1_OUT	    =>NPC1_OUT_tb --IN EX STAGE, THE INPUT 0 OF FIRST MUX SHOULD BE THIS REGISTER?
    );
    P_STIMULI : PROCESS
    variable i : integer := 0;
    variable j : integer := 0;
    variable aux : std_logic_vector(N_BITS_DATA-1 downto 0) := (others => '0');
    BEGIN
		--############################ TEST 1  ############################--
        REPORT("Starting simulation");	
		REPORT("TEST 1:   - RF reset test");	        
        RST_tb              <= '0'; -- Reset registers
        JAL_MUX_SEL_tb      <= '0'; -- 0 in order to don't mask ADD_RD1
        DEC_OUTREG_EN_tb    <= '1'; -- 1 to enable all pipeline registers
        IS_I_TYPE_tb        <= '0'; -- 0 to select the R_type put it in the WR_ADDR_OUT reg (don't care now)
        RD1_en_tb           <= '1'; -- 1 to enable reading port 1 
        RD2_en_tb           <= '1'; -- 1 to enable reading port 2
        WR_en_tb            <= '0'; -- 0 to disable writing port
        I_CODE_tb           <= (OTHERS => '0');
        NPC1_IN_tb          <= (OTHERS => '0');    
        DATA_IN_tb          <= (OTHERS => '0'); -- don't care, WR_EN is 1
        WR_ADDR_IN_tb       <= (OTHERS => '0'); -- don't care, WR_EN is 1       
        
        WAIT UNTIL falling_edge(CLK_tb);
        for i in 0 to 15 loop
            I_CODE_tb(25 DOWNTO 16) <= std_logic_vector(to_unsigned(i,RF_ADDR))&std_logic_vector(to_unsigned(i+16,RF_ADDR)); --Addressing different registers
            WAIT UNTIL falling_edge(CLK_tb);
            ASSERT (REGA_OUT_tb = (NbitLong - 1 DOWNTO 0 => '0') AND REGB_OUT_tb = (NbitLong - 1 DOWNTO 0 => '0'))
		    REPORT " REG A: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGA_OUT_tb))) & " REG B: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGB_OUT_tb)))  
		    SEVERITY failure;    

        end loop;
		REPORT("TEST 1 result: SUCCESSFUL");
		--############################ TEST 2  ############################--

		REPORT("TEST 2: - RF reading and writing at the same time in PORT1      - RF reading in PORT2" );	
		RST_tb   <= '1'; -- Stop reset	
		WR_en_tb <= '1'; --1 to enable writing port        
		WAIT UNTIL falling_edge(CLK_tb);
		for i in 0 to 31 loop
			IF i /= 0 THEN
				j := i - 1;
			ELSE -- prevent j = -1
				j := 0;
				REPORT("RF writing reg 0");	
			END IF;			

            DATA_IN_tb	<= RF_COPY(i);
			I_CODE_tb(25 DOWNTO 16) <= std_logic_vector(to_unsigned(i,RF_ADDR))&std_logic_vector(to_unsigned(j,RF_ADDR)); --Addressing different registers
			WR_ADDR_IN_tb 				<= std_logic_vector(to_unsigned(i,RF_ADDR));
            WAIT UNTIL falling_edge(CLK_tb);
            ASSERT (REGA_OUT_tb = RF_COPY(i) AND REGB_OUT_tb = RF_COPY(j))
		    REPORT "i="&INTEGER'image(i)&" REG A exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(RF_COPY(i)))) & " REG A obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGA_OUT_tb))) & " REG B exp val " & INTEGER'image(TO_INTEGER(UNSIGNED(RF_COPY(j)))) & " REG B obt val " & INTEGER'image(TO_INTEGER(UNSIGNED(REGB_OUT_tb)))  
		    SEVERITY failure;    

        end loop;
		REPORT("TEST 2 RESULT: SUCCESSFUL");
		--############################ TEST 3  ############################--
		

		REPORT("TEST 3: -Writing regs ADDR and NPC1" );
		WR_en_tb 	<= '0'; --0 to disable writing port
		NPC1_IN_tb 	<= std_logic_vector(to_unsigned(45,N_BITS_PC));
		I_CODE_tb(20 DOWNTO 11) <= std_logic_vector(to_unsigned(4,RF_ADDR))&std_logic_vector(to_unsigned(10,RF_ADDR)); --writing addres for different types of instruction (20 downto 16 -> I-Type and 15 down 11 -> R-TYPE)
		IS_I_TYPE_tb        <= '0'; -- 0 to select the R_type writing addres		
		WAIT UNTIL falling_edge(CLK_tb);
		ASSERT (NPC1_out_tb = std_logic_vector(to_unsigned(45,N_BITS_PC)) AND WR_ADDR_OUT_tb = std_logic_vector(to_unsigned(10,N_BITS_PC)))
		REPORT " NPC1 exp val: " & INTEGER'image(45) & " NPC1 obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(NPC1_out_tb))) & " WR ADDR OUT exp val " & INTEGER'image(10) & " WR ADDR OUT obt val " & INTEGER'image(TO_INTEGER(UNSIGNED(WR_ADDR_OUT_tb)))
	    SEVERITY failure;  
		IS_I_TYPE_tb        <= '1'; -- 1 to select the I_type writing addres		
		NPC1_IN_tb 	<= std_logic_vector(to_unsigned(1111,N_BITS_PC));
		WAIT UNTIL falling_edge(CLK_tb);
		ASSERT (NPC1_out_tb = std_logic_vector(to_unsigned(1111,N_BITS_PC)) AND WR_ADDR_OUT_tb = std_logic_vector(to_unsigned(4,N_BITS_PC)))
		REPORT " NPC1 exp val: " & INTEGER'image(1111) & " NPC1 obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(NPC1_out_tb))) & " WR ADDR OUT exp val " & INTEGER'image(4) & " WR ADDR OUT obt val " & INTEGER'image(TO_INTEGER(UNSIGNED(WR_ADDR_OUT_tb)))
		SEVERITY failure;  
		REPORT("TEST 3 RESULT: SUCCESSFUL");

		--############################ TEST 4  ############################--
		REPORT("TEST 4: -Sign extension test" );
		I_CODE_tb(27 DOWNTO 0) <= x"DFF7FFF"; --Positive number for 16 and 26 bits immediate
		IS_I_TYPE_tb <= '1'; --I-TYPE INSTRUCTION, 16 bits sign extension
		WAIT UNTIL falling_edge(CLK_tb);
		aux := (31 downto 16 => '0') & x"7FFF";
		ASSERT (REGIMM_OUT_tb = aux)--x"7FFF"))
		REPORT " REG IMM exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " REG IMM obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGIMM_OUT_tb))) --obtained value is 1FF7FFF
		SEVERITY failure;
  
		IS_I_TYPE_tb <= '0'; --J-TYPE INSTRUCTION, 26 bits sign extension
		WAIT UNTIL falling_edge(CLK_tb);
		aux := (31 downto 26 => '0') &"01"&  x"FF7FFF";
		ASSERT (REGIMM_OUT_tb = aux)
		REPORT " REG IMM exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " REG IMM obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGIMM_OUT_tb)))
		SEVERITY failure; 
		-------------------------------------------------------------------------------------------------		
		I_CODE_tb(27 DOWNTO 0) <= x"FFFFF00"; --Negative number for 16 and 26 bits immediate
		IS_I_TYPE_tb <= '1'; --I-TYPE INSTRUCTION, 16 bits sign extension
		WAIT UNTIL falling_edge(CLK_tb);
		aux := ((31 downto 16 => '1') & x"FF00");
		ASSERT (REGIMM_OUT_tb = aux)
		REPORT " REG IMM exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " REG IMM obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGIMM_OUT_tb)))
		SEVERITY failure;  

		IS_I_TYPE_tb <= '0'; --J-TYPE INSTRUCTION, 26 bits sign extension
		WAIT UNTIL falling_edge(CLK_tb);
		aux := (31 downto 26 => '1') &"11"&  x"FFFF00";
		ASSERT (REGIMM_OUT_tb = aux)
		REPORT " REG IMM exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " REG IMM obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGIMM_OUT_tb)))
		SEVERITY failure;  
		-------------------------------------------------------------------------------------------------		
		I_CODE_tb(27 DOWNTO 0) <= x"FFF7123"; --Positive number for 16 bits immediate but negative for 26 bits immediate
		IS_I_TYPE_tb <= '1'; --I-TYPE INSTRUCTION, 16 bits sign extension
		WAIT UNTIL falling_edge(CLK_tb);
		aux := (31 downto 16 => '0') & x"7123";
		ASSERT (REGIMM_OUT_tb = aux)
		REPORT " REG IMM exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " REG IMM obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGIMM_OUT_tb))) --obtained value is 1FF7FFF
		SEVERITY failure;
  
		IS_I_TYPE_tb <= '0'; --J-TYPE INSTRUCTION, 26 bits sign extension
		WAIT UNTIL falling_edge(CLK_tb);
		aux := (31 downto 26 => '1') &"11"&  x"FF7123";
		ASSERT (REGIMM_OUT_tb = aux)
		REPORT " REG IMM exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " REG IMM obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGIMM_OUT_tb)))
		SEVERITY failure;
		-------------------------------------------------------------------------------------------------
		I_CODE_tb(27 DOWNTO 0) <= x"D2FFFEA"; --NEGATIVE number for 16 bits immediate but POSITIVE for 26 bits immediate
		IS_I_TYPE_tb <= '1'; --I-TYPE INSTRUCTION, 16 bits sign extension
		WAIT UNTIL falling_edge(CLK_tb);
		aux := (31 downto 16 => '1') & x"FFEA";
		ASSERT (REGIMM_OUT_tb = aux)--x"7FFF"))
		REPORT " REG IMM exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " REG IMM obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGIMM_OUT_tb))) --obtained value is 1FF7FFF
		SEVERITY failure;
  
		IS_I_TYPE_tb <= '0'; --J-TYPE INSTRUCTION, 26 bits sign extension
		WAIT UNTIL falling_edge(CLK_tb);
		aux := (31 downto 26 => '0') &"01"&  x"2FFFEA";
		ASSERT (REGIMM_OUT_tb = aux)
		REPORT " REG IMM exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " REG IMM obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGIMM_OUT_tb)))
		SEVERITY failure; 		 

		REPORT("TEST 4 RESULT: SUCCESSFUL");

        WAIT;
    END PROCESS;


    P_CLOCK : PROCESS (CLK_tb)
	BEGIN
		CLK_tb <= NOT(CLK_tb) AFTER 1 ns;
	END PROCESS;

END TEST;

CONFIGURATION CFG_TEST_ID OF TB_ID IS
	FOR TEST
	END FOR;
END CFG_TEST_ID;

