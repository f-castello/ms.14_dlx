LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_ID IS
END TB_ID;

ARCHITECTURE TEST OF TB_ID IS
    TYPE MEM_ARRAY IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
    SIGNAL RF_COPY : MEM_ARRAY := (
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

    SIGNAL CLK_tb : STD_LOGIC := '0';
    -- Control signals
    SIGNAL RST_tb           : STD_LOGIC;
    SIGNAL JAL_MUX_SEL_tb   : STD_LOGIC;
    SIGNAL DEC_OUTREG_EN_tb : STD_LOGIC; -- (A, B, Imm, NPC1, IR1) Registers Enable
    SIGNAL IS_I_TYPE_tb     : STD_LOGIC; -- Detect I-Type Instructions for Sign Extension & Writing Address Selection
    SIGNAL RD1_EN_tb        : STD_LOGIC; --enable reading port 1 of the RF
    SIGNAL RD2_EN_tb        : STD_LOGIC; --enable reading port 2 of the RF
    SIGNAL WR_EN_tb         : STD_LOGIC; --enable writing port of the RF
    SIGNAL ZERO_PADDING2_tb : STD_LOGIC;
    --Data signals
    SIGNAL I_CODE_tb      : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- output of the memory to the IR
    SIGNAL NPC1_IN_tb     : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
    SIGNAL DATA_IN_tb     : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
    SIGNAL WR_ADDR_IN_tb  : STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
    SIGNAL REGA_OUT_tb    : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
    SIGNAL REGB_OUT_tb    : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
    SIGNAL REGIMM_OUT_tb  : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
    SIGNAL WR_ADDR_OUT_tb : STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
    SIGNAL NPC1_OUT_tb    : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); --IN EX STAGE, THE INPUT 0 OF FIRST MUX SHOULD BE THIS REGISTER?

    COMPONENT ID_STAGE IS
        GENERIC
        (
            N_BITS_DATA  : NATURAL := NbitLong; -- # of bits
            N_BYTES_INST : NATURAL := NPC_GAP;
            RF_ADDR      : NATURAL := RF_ADDR;  -- # OF BITS FOR REGISTER FILE ADDRESS
            N_BITS_JUMP  : NATURAL := NbitJump; -- # OF BITS OF THE INPUT OF THE SIGN EXTENTION
            N_BITS_IMM   : NATURAL := NbitShort
        );
        PORT
        (
            -- Control ports
            CLK           : IN STD_LOGIC;
            RST           : IN STD_LOGIC;
            JAL_MUX_SEL   : IN STD_LOGIC;
            DEC_OUTREG_EN : IN STD_LOGIC; -- (A, B, Imm, NPC1, IR1) Registers Enable
            IS_I_TYPE     : IN STD_LOGIC; -- Detect I-Type Instructions for Sign Extension & Writing Address Selection
            RD1_EN        : IN STD_LOGIC; -- Register File Read 1 Enable
            RD2_EN        : IN STD_LOGIC; -- Register File Read 2 Enable
            WR_EN         : IN STD_LOGIC; -- enable writing port of the RF
            ZERO_PADDING2 : IN STD_LOGIC;
            -- Data ports
            I_CODE      : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- output of the memory to the IR
            NPC1_IN     : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
            DATA_IN     : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
            WR_ADDR_IN  : IN STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
            REGA_OUT    : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
            REGB_OUT    : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
            REGIMM_OUT  : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
            WR_ADDR_OUT : OUT STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
            NPC1_OUT    : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0)
        );
    END COMPONENT;

BEGIN
    DUT : ID_STAGE
    GENERIC
    MAP (
    N_BITS_DATA  => NbitLong, -- # of bits
    N_BYTES_INST => NPC_GAP,
    RF_ADDR      => RF_ADDR,  -- # OF BITS FOR REGISTER FILE ADDRESS
    N_BITS_JUMP  => NbitJump, -- # OF BITS OF THE INPUT OF THE SIGN EXTENTION
    N_BITS_IMM   => NbitShort
    )
    PORT MAP
    (
        -- Control ports
        CLK           => CLK_tb,
        RST           => RST_tb,
        JAL_MUX_SEL   => JAL_MUX_SEL_tb,   --
        DEC_OUTREG_EN => DEC_OUTREG_EN_tb, -- (A, B, Imm, NPC1, IR1) Registers Enable
        IS_I_TYPE     => IS_I_TYPE_tb,     -- Detect I-Type Instructions for Sign Extension & Writing Address Selection
        RD1_EN        => RD1_EN_tb,        -- enable reading port 1 of the RF
        RD2_EN        => RD2_EN_tb,        -- enable reading port 2 of the RF
        WR_EN         => WR_EN_tb,         -- enable writing port of the RF
        ZERO_PADDING2 => ZERO_PADDING2_tb,
        -- Data ports
        I_CODE      => I_CODE_tb, -- output of the memory to the IR
        NPC1_IN     => NPC1_IN_tb,
        DATA_IN     => DATA_IN_tb,
        WR_ADDR_IN  => WR_ADDR_IN_tb,
        REGA_OUT    => REGA_OUT_tb,
        REGB_OUT    => REGB_OUT_tb,
        REGIMM_OUT  => REGIMM_OUT_tb,
        WR_ADDR_OUT => WR_ADDR_OUT_tb,
        NPC1_OUT    => NPC1_OUT_tb
    );

    P_STIMULI : PROCESS IS
        VARIABLE j   : INTEGER                                 := 0;
        VARIABLE aux : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0) := (OTHERS => '0');
    BEGIN
        --############################ TEST 1  ############################--
        REPORT("Starting simulation");
        REPORT("TEST 1:   - RF reset test");
        RST_tb           <= '0'; -- Reset registers
        JAL_MUX_SEL_tb   <= '0'; -- 0 in order to don't mask ADD_WR
        DEC_OUTREG_EN_tb <= '1'; -- 1 to enable all pipeline registers
        IS_I_TYPE_tb     <= '0'; -- 0 to select the R_type put it in the WR_ADDR_OUT reg (don't care now)
        ZERO_PADDING2_tb <= '0';
        RD1_EN_tb        <= '1'; -- 1 to enable reading port 1 
        RD2_EN_tb        <= '1'; -- 1 to enable reading port 2
        WR_EN_tb         <= '0'; -- 0 to disable writing port
        I_CODE_tb        <= (OTHERS => '0');
        NPC1_IN_tb       <= (OTHERS => '0');
        DATA_IN_tb       <= (OTHERS => '0'); -- don't care, WR_EN is 1
        WR_ADDR_IN_tb    <= (OTHERS => '0'); -- don't care, WR_EN is 1       
        WAIT UNTIL falling_edge(CLK_tb);
        FOR i IN 0 TO 15 LOOP
            I_CODE_tb(25 DOWNTO 16) <= STD_LOGIC_VECTOR(to_unsigned(i, RF_ADDR)) & STD_LOGIC_VECTOR(to_unsigned(i + 16, RF_ADDR)); --Addressing different registers
            WAIT UNTIL falling_edge(CLK_tb);
            ASSERT (REGA_OUT_tb = (NbitLong - 1 DOWNTO 0 => '0') AND REGB_OUT_tb = (NbitLong - 1 DOWNTO 0 => '0'))
            REPORT " REG A: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGA_OUT_tb))) & " REG B: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGB_OUT_tb)))
                SEVERITY failure;
        END LOOP;
        REPORT("TEST 1 result: SUCCESSFUL");

        --############################ TEST 2  ############################--
        REPORT("TEST 2: - RF reading and writing at the same time in PORT1      - RF reading in PORT2");
        RST_tb   <= '1'; -- Stop reset	
        WR_EN_tb <= '1'; --1 to enable writing port        
        WAIT UNTIL falling_edge(CLK_tb);
        FOR i IN 0 TO 31 LOOP
            IF i /= 0 THEN
                j := i - 1;
            ELSE -- prevent j = -1
                j := 0;
                REPORT("RF writing reg 0");
            END IF;

            DATA_IN_tb              <= RF_COPY(i);
            I_CODE_tb(25 DOWNTO 16) <= STD_LOGIC_VECTOR(to_unsigned(i, RF_ADDR)) & STD_LOGIC_VECTOR(to_unsigned(j, RF_ADDR)); --Addressing different registers
            WR_ADDR_IN_tb           <= STD_LOGIC_VECTOR(to_unsigned(i, RF_ADDR));
            WAIT UNTIL falling_edge(CLK_tb);
            ASSERT (REGA_OUT_tb = RF_COPY(i) AND REGB_OUT_tb = RF_COPY(j))
            REPORT "i=" & INTEGER'image(i) & " REG A exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(RF_COPY(i)))) & " REG A obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGA_OUT_tb))) & " REG B exp val " & INTEGER'image(TO_INTEGER(UNSIGNED(RF_COPY(j)))) & " REG B obt val " & INTEGER'image(TO_INTEGER(UNSIGNED(REGB_OUT_tb)))
                SEVERITY failure;

        END LOOP;
        REPORT("TEST 2 RESULT: SUCCESSFUL");

        --############################ TEST 3  ############################--
        REPORT("TEST 3: -Writing regs ADDR and NPC1");
        WR_EN_tb                <= '0'; --0 to disable writing port
        NPC1_IN_tb              <= STD_LOGIC_VECTOR(to_unsigned(45, NbitLong));
        I_CODE_tb(20 DOWNTO 11) <= STD_LOGIC_VECTOR(to_unsigned(4, RF_ADDR)) & STD_LOGIC_VECTOR(to_unsigned(10, RF_ADDR)); --writing addres for different types of instruction (20 downto 16 -> I-Type and 15 down 11 -> R-TYPE)
        IS_I_TYPE_tb            <= '0';                                                                                    -- 0 to select the R_type writing addres		
        WAIT UNTIL falling_edge(CLK_tb);
        ASSERT (NPC1_out_tb = STD_LOGIC_VECTOR(to_unsigned(45, NbitLong)) AND WR_ADDR_OUT_tb = STD_LOGIC_VECTOR(to_unsigned(10, NbitLong)))
        REPORT " NPC1 exp val: " & INTEGER'image(45) & " NPC1 obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(NPC1_out_tb))) & " WR ADDR OUT exp val " & INTEGER'image(10) & " WR ADDR OUT obt val " & INTEGER'image(TO_INTEGER(UNSIGNED(WR_ADDR_OUT_tb)))
            SEVERITY failure;
        IS_I_TYPE_tb <= '1'; -- 1 to select the I_type writing addres		
        NPC1_IN_tb   <= STD_LOGIC_VECTOR(to_unsigned(1111, NbitLong));
        WAIT UNTIL falling_edge(CLK_tb);
        ASSERT (NPC1_out_tb = STD_LOGIC_VECTOR(to_unsigned(1111, NbitLong)) AND WR_ADDR_OUT_tb = STD_LOGIC_VECTOR(to_unsigned(4, NbitLong)))
        REPORT " NPC1 exp val: " & INTEGER'image(1111) & " NPC1 obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(NPC1_out_tb))) & " WR ADDR OUT exp val " & INTEGER'image(4) & " WR ADDR OUT obt val " & INTEGER'image(TO_INTEGER(UNSIGNED(WR_ADDR_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 3 RESULT: SUCCESSFUL");

        --############################ TEST 4  ############################--
        REPORT("TEST 4: -Sign extension test");
        I_CODE_tb(27 DOWNTO 0) <= x"DFF7FFF"; --Positive number for 16 and 26 bits immediate
        IS_I_TYPE_tb           <= '1';        --I-TYPE INSTRUCTION, 16 bits sign extension
        WAIT UNTIL falling_edge(CLK_tb);
        aux := (31 DOWNTO 16 => '0') & x"7FFF";
        ASSERT (REGIMM_OUT_tb = aux)--x"7FFF"))
        REPORT " REG IMM exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " REG IMM obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGIMM_OUT_tb))) --obtained value is 1FF7FFF
            SEVERITY failure;

        IS_I_TYPE_tb <= '0'; --J-TYPE INSTRUCTION, 26 bits sign extension
        WAIT UNTIL falling_edge(CLK_tb);
        aux := (31 DOWNTO 26 => '0') & "01" & x"FF7FFF";
        ASSERT (REGIMM_OUT_tb = aux)
        REPORT " REG IMM exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " REG IMM obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGIMM_OUT_tb)))
            SEVERITY failure;
        -------------------------------------------------------------------------------------------------		
        I_CODE_tb(27 DOWNTO 0) <= x"FFFFF00"; --Negative number for 16 and 26 bits immediate
        IS_I_TYPE_tb           <= '1';        --I-TYPE INSTRUCTION, 16 bits sign extension
        WAIT UNTIL falling_edge(CLK_tb);
        aux := ((31 DOWNTO 16 => '1') & x"FF00");
        ASSERT (REGIMM_OUT_tb = aux)
        REPORT " REG IMM exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " REG IMM obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGIMM_OUT_tb)))
            SEVERITY failure;

        IS_I_TYPE_tb <= '0'; --J-TYPE INSTRUCTION, 26 bits sign extension
        WAIT UNTIL falling_edge(CLK_tb);
        aux := (31 DOWNTO 26 => '1') & "11" & x"FFFF00";
        ASSERT (REGIMM_OUT_tb = aux)
        REPORT " REG IMM exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " REG IMM obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGIMM_OUT_tb)))
            SEVERITY failure;
        -------------------------------------------------------------------------------------------------		
        I_CODE_tb(27 DOWNTO 0) <= x"FFF7123"; --Positive number for 16 bits immediate but negative for 26 bits immediate
        IS_I_TYPE_tb           <= '1';        --I-TYPE INSTRUCTION, 16 bits sign extension
        WAIT UNTIL falling_edge(CLK_tb);
        aux := (31 DOWNTO 16 => '0') & x"7123";
        ASSERT (REGIMM_OUT_tb = aux)
        REPORT " REG IMM exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " REG IMM obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGIMM_OUT_tb))) --obtained value is 1FF7FFF
            SEVERITY failure;
        IS_I_TYPE_tb <= '0'; --J-TYPE INSTRUCTION, 26 bits sign extension
        WAIT UNTIL falling_edge(CLK_tb);
        aux := (31 DOWNTO 26 => '1') & "11" & x"FF7123";
        ASSERT (REGIMM_OUT_tb = aux)
        REPORT " REG IMM exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " REG IMM obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGIMM_OUT_tb)))
            SEVERITY failure;
        -------------------------------------------------------------------------------------------------
        I_CODE_tb(27 DOWNTO 0) <= x"D2FFFEA"; --NEGATIVE number for 16 bits immediate but POSITIVE for 26 bits immediate
        IS_I_TYPE_tb           <= '1';        --I-TYPE INSTRUCTION, 16 bits sign extension
        WAIT UNTIL falling_edge(CLK_tb);
        aux := (31 DOWNTO 16 => '1') & x"FFEA";
        ASSERT (REGIMM_OUT_tb = aux)--x"7FFF"))
        REPORT " REG IMM exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " REG IMM obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGIMM_OUT_tb))) --obtained value is 1FF7FFF
            SEVERITY failure;

        IS_I_TYPE_tb <= '0'; --J-TYPE INSTRUCTION, 26 bits sign extension
        WAIT UNTIL falling_edge(CLK_tb);
        aux := (31 DOWNTO 26 => '0') & "01" & x"2FFFEA";
        ASSERT (REGIMM_OUT_tb = aux)
        REPORT " REG IMM exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " REG IMM obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGIMM_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 4 RESULT: SUCCESSFUL");

        --############################ TEST 4.2  ############################--        
        REPORT("TEST 4.2: -Sign extension new features test (zero padding)");

        I_CODE_tb(27 DOWNTO 0) <= x"FFFFF01"; --Negative number for 16 and 26 bits immediate
        IS_I_TYPE_tb           <= '1';        --I-TYPE INSTRUCTION, 16 bits sign extension
        ZERO_PADDING2_tb       <= '1';
        WAIT UNTIL falling_edge(CLK_tb);
        aux := ((31 DOWNTO 16 => '0') & x"FF01");
        ASSERT (REGIMM_OUT_tb = aux)
        REPORT " REG IMM exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " REG IMM obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGIMM_OUT_tb)))
            SEVERITY failure;
        IS_I_TYPE_tb <= '0'; --J-TYPE INSTRUCTION, 26 bits sign extension
        WAIT UNTIL falling_edge(CLK_tb);
        aux := (31 DOWNTO 26 => '1') & "11" & x"FFFF01";
        ASSERT (REGIMM_OUT_tb = aux)
        REPORT " REG IMM exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " REG IMM obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGIMM_OUT_tb)))
            SEVERITY failure;
        WAIT UNTIL falling_edge(CLK_tb);
        ZERO_PADDING2_tb <= '1';
        ASSERT (REGIMM_OUT_tb = aux)
        REPORT " REG IMM exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " REG IMM obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGIMM_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 4.2 RESULT: SUCCESSFUL");

        --############################ TEST 5  ############################--
        REPORT("TEST 5: -Writing address in JAL instruction");
        -- We write any address in the writing port but it should be masked.
        ZERO_PADDING2_tb <= '0';
        JAL_MUX_SEL_tb   <= '1';     -- 1 in order to mask ADD_WR
        WR_ADDR_IN_tb    <= "10101"; --Any value different form 31 in writing address
        DATA_IN_tb       <= x"F0E0D0C0";
        WR_EN_tb         <= '1';
        RF_COPY(31)      <= x"F0E0D0C0"; --keeping track of the values in the RF

        WAIT UNTIL falling_edge(CLK_tb);
        I_CODE_tb(25 DOWNTO 21) <= STD_LOGIC_VECTOR(to_unsigned(31, RF_ADDR)); --Addressing last reg in port 1

        WAIT UNTIL falling_edge(CLK_tb);
        ASSERT (REGA_OUT_tb = RF_COPY(31))
        REPORT " REG A exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(RF_COPY(31)))) & " REG A obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGA_OUT_tb)))
            SEVERITY failure;

        REPORT("TEST 5 RESULT: SUCCESSFUL");

        --############################ TEST 6  ############################--
        REPORT("TEST 6: -Writing reg 0    -Reading ports with reading enable = 0");
        JAL_MUX_SEL_tb <= '0'; -- 0 in order to don't mask ADD_WR
        WR_ADDR_IN_tb  <= "00000";

        WAIT UNTIL falling_edge(CLK_tb);
        I_CODE_tb(25 DOWNTO 21) <= STD_LOGIC_VECTOR(to_unsigned(0, RF_ADDR)); --Addressing last reg in port 1

        WAIT UNTIL falling_edge(CLK_tb);
        ASSERT (REGA_OUT_tb = "00000000")
        REPORT " REG A exp val: " & INTEGER'image(0) & " REG A obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGA_OUT_tb)))
            SEVERITY failure;
        -- Reading ports when RD_EN = 0
        WAIT UNTIL falling_edge(CLK_tb);
        I_CODE_tb(25 DOWNTO 16) <= STD_LOGIC_VECTOR(to_unsigned(5, RF_ADDR)) & STD_LOGIC_VECTOR(to_unsigned(30, RF_ADDR)); --Addressing different registers
        RD1_EN_tb               <= '0';                                                                                    -- 0 to disable reading port 1 
        RD2_EN_tb               <= '0';                                                                                    -- 0 to disable reading port 2
        WAIT UNTIL falling_edge(CLK_tb);
        ASSERT (REGA_OUT_tb = "00000000" AND REGB_OUT_tb = "00000000")
        REPORT " REG A exp val: " & INTEGER'image(0) & " REG A obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGA_OUT_tb))) & " REG B exp val " & INTEGER'image(0) & " REG B obt val " & INTEGER'image(TO_INTEGER(UNSIGNED(REGB_OUT_tb)))
            SEVERITY failure;
        WAIT UNTIL falling_edge(CLK_tb);

        REPORT("TEST 6 RESULT: SUCCESSFUL");

        --############################ TEST 7  ############################--
        REPORT("TEST 7: -Reading output registers when enable = 0");
        --We expect the registers to keep the value
        WR_EN_tb   <= '0';                                         -- 0 to disable writing port 
        RD1_EN_tb  <= '1';                                         -- 1 to enable reading port 1 
        RD2_EN_tb  <= '1';                                         -- 1 to enable reading port 2
        NPC1_IN_tb <= STD_LOGIC_VECTOR(to_unsigned(22, NbitLong)); -- Writing any value in NPC1 reg
        --Here we are mixing I and R type instruction, we read the instruction
        --considering both types in order to see in which address I am reading in port 2 and which immediate
        --I am writing (Modifying the reading address modifies the immeddiate) This shouldn't happend.
        IS_I_TYPE_tb           <= '1';                                         --I-TYPE INSTRUCTION, 16 bits sign extension and selecting I-type writing address from the instruction
        I_CODE_tb(25 DOWNTO 0) <= "10001" & "10101" & "00011" & "101" & x"00"; --Rd Port1 = d17,WR_ADDR = d21 RD PORT2 = d21, Imm =0x3500 or d13568 (positive)

        WAIT UNTIL falling_edge(CLK_tb);
        DEC_OUTREG_EN_tb       <= '0';                                         -- 0 to disable all pipeline registers
        I_CODE_tb(25 DOWNTO 0) <= "11101" & "11000" & "11100" & "011" & x"0F"; --Changing all input values (output values should not change)

        ASSERT (REGA_OUT_tb = RF_COPY(17) AND REGB_OUT_tb = RF_COPY(21))
        REPORT " REG A exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(RF_COPY(17)))) & " REG A obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGA_OUT_tb))) & " REG B exp val " & INTEGER'image(TO_INTEGER(UNSIGNED(RF_COPY(21)))) & " REG B obt val " & INTEGER'image(TO_INTEGER(UNSIGNED(REGB_OUT_tb)))
            SEVERITY failure;

        ASSERT (NPC1_out_tb = STD_LOGIC_VECTOR(to_unsigned(22, NbitLong)) AND WR_ADDR_OUT_tb = STD_LOGIC_VECTOR(to_unsigned(21, NbitLong)))
        REPORT " NPC1 exp val: " & INTEGER'image(22) & " NPC1 obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(NPC1_out_tb))) & " WR ADDR OUT exp val " & INTEGER'image(21) & " WR ADDR OUT obt val " & INTEGER'image(TO_INTEGER(UNSIGNED(WR_ADDR_OUT_tb)))
            SEVERITY failure;

        aux := (31 DOWNTO 16 => '0') & "00011101" & x"00";
        ASSERT (REGIMM_OUT_tb = aux)
        REPORT " REG IMM exp val: " & INTEGER'image(TO_INTEGER(UNSIGNED(aux))) & " REG IMM obt val: " & INTEGER'image(TO_INTEGER(UNSIGNED(REGIMM_OUT_tb)))
            SEVERITY failure;

        REPORT("TEST 7 RESULT: SUCCESSFUL");
        REPORT " End of simulation";

        WAIT;
    END PROCESS;

    P_CLOCK : PROCESS (CLK_tb)
    BEGIN
        CLK_tb <= NOT(CLK_tb) AFTER Tclk / 2;
    END PROCESS;
END TEST;