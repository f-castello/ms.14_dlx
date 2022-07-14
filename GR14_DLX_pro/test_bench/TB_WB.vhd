LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_WB IS
END TB_WB;

ARCHITECTURE TEST OF TB_WB IS
    TYPE MEM_ARRAY IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
    CONSTANT INP_VALS : MEM_ARRAY :=
    (
    x"F2300100",
    x"0ED00020",
    x"00A20004",
    x"01000026",
    x"00200007",
    x"FFF00009",
    x"0000FF0A",
    x"0D10100C"
    );
    SIGNAL WB_MUX_SEL_tb    : STD_LOGIC_VECTOR(1 DOWNTO 0);            -- Primary Outcome Selector
    SIGNAL WB_CTRL_SIGN_tb  : STD_LOGIC;                               -- Choose Sign Extension domain
    SIGNAL ZERO_PADDING5_tb : STD_LOGIC;                               -- Choose Zero Padding over normal Sign Extension
    SIGNAL NPC_OUT_tb       : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- Mux Input #3 ("11" -> NPC)
    SIGNAL MEM_OUT_tb       : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- Sign Ext Input/Mux Input #2 ("01" -> MEM Out)
    SIGNAL ALU_OUT_tb       : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- Mux Input #0 ("00" -> ALU Out)
    SIGNAL MUX_OUT_tb       : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- Mux Main Output

    COMPONENT WB_STAGE
        GENERIC
        (
            N_BITS_DATA : NATURAL := NbitLong -- # of bits
        );
        PORT
        (
            -- Control ports
            WB_MUX_SEL    : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- Primary Outcome Selector
            WB_CTRL_SIGN  : IN STD_LOGIC;                    -- Choose Sign Extension domain
            ZERO_PADDING5 : IN STD_LOGIC;                    -- Choose Zero Padding over normal Sign Extension
            -- Data ports
            NPC_OUT : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Mux Input #3 ("11" -> NPC)
            MEM_OUT : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Sign Ext Input/Mux Input #2 ("01" -> MEM Out)
            ALU_OUT : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Mux Input #0 ("00" -> ALU Out)
            MUX_OUT : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0) -- Mux Main Output
        );
    END COMPONENT;

BEGIN
    DUT : WB_STAGE
    GENERIC
    MAP (
    N_BITS_DATA => NbitLong
    )
    PORT MAP
    (
        WB_MUX_SEL    => WB_MUX_SEL_tb,
        WB_CTRL_SIGN  => WB_CTRL_SIGN_tb,
        ZERO_PADDING5 => ZERO_PADDING5_tb,
        NPC_OUT       => NPC_OUT_tb,
        MEM_OUT       => MEM_OUT_tb,
        ALU_OUT       => ALU_OUT_tb,
        MUX_OUT       => MUX_OUT_tb
    );

    P_STIMULI : PROCESS IS
    BEGIN
        REPORT("Starting simulation");
        WB_MUX_SEL_tb    <= "00";
        WB_CTRL_SIGN_tb  <= '0';
        ZERO_PADDING5_tb <= '0';
        NPC_OUT_tb       <= (OTHERS => '0');
        MEM_OUT_tb       <= (OTHERS => '0');
        ALU_OUT_tb       <= (OTHERS => '0');
        WAIT FOR Tclk;

        --############################ TEST 1  ############################--
        REPORT("TEST 1:   - Input on 00 stable");
        ALU_OUT_tb <= INP_VALS(7);
        WAIT FOR Tclk;
        ASSERT (MUX_OUT_tb = INP_VALS(7))
        REPORT " MUX_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(MUX_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 1 result: SUCCESSFUL");

        REPORT("TEST 1.1:   - Input on 00 changing");
        ALU_OUT_tb <= INP_VALS(6);
        WAIT FOR Tclk;
        ASSERT (MUX_OUT_tb = INP_VALS(6))
        REPORT " MUX_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(MUX_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 1.1 result: SUCCESSFUL");

        --############################ TEST 2  ############################--
        REPORT("TEST 2:   - Input on 01 stable");
        MEM_OUT_tb    <= INP_VALS(5);
        WB_MUX_SEL_tb <= "01";
        WAIT FOR Tclk;
        ASSERT (MUX_OUT_tb = INP_VALS(5))
        REPORT " MUX_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(MUX_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 2 result: SUCCESSFUL");

        REPORT("TEST 2.1:   - Input on 01 changing");
        MEM_OUT_tb <= INP_VALS(4);
        WAIT FOR Tclk;
        ASSERT (MUX_OUT_tb = INP_VALS(4))
        REPORT " MUX_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(MUX_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 2.1 result: SUCCESSFUL");

        --############################ TEST 3  ############################--
        REPORT("TEST 3:   - Input on 10 stable, sign ext @ 00");
        MEM_OUT_tb    <= INP_VALS(3);
        WB_MUX_SEL_tb <= "10";
        WAIT FOR Tclk;
        ASSERT (MUX_OUT_tb = (NbitShort - NbitByte - 1 DOWNTO 0 => INP_VALS(3)(NbitByte - 1)) & INP_VALS(3)(NbitByte - 1 DOWNTO 0))
        REPORT " MUX_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(MUX_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 3 result: SUCCESSFUL");

        REPORT("TEST 3.1:   - Input on 10 stable, sign ext @ 01");
        MEM_OUT_tb       <= INP_VALS(3);
        ZERO_PADDING5_tb <= '1';
        WAIT FOR Tclk;
        ASSERT (MUX_OUT_tb = (NbitLong - NbitByte - 1 DOWNTO 0 => '0') & INP_VALS(3)(NbitByte - 1 DOWNTO 0))
        REPORT " MUX_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(MUX_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 3.1 result: SUCCESSFUL");

        REPORT("TEST 3.2:   - Input on 10 stable, sign ext @ 10");
        MEM_OUT_tb       <= INP_VALS(3);
        WB_CTRL_SIGN_tb  <= '1';
        ZERO_PADDING5_tb <= '0';
        WAIT FOR Tclk;
        ASSERT (MUX_OUT_tb = (NbitLong - NbitShort - 1 DOWNTO 0 => INP_VALS(3)(NbitShort - 1)) & INP_VALS(3)(NbitShort - 1 DOWNTO 0))
        REPORT " MUX_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(MUX_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 3.2 result: SUCCESSFUL");

        REPORT("TEST 3.3:   - Input on 10 stable, sign ext @ 10");
        MEM_OUT_tb       <= INP_VALS(3);
        WB_CTRL_SIGN_tb  <= '1';
        ZERO_PADDING5_tb <= '1';
        WAIT FOR Tclk;
        ASSERT (MUX_OUT_tb = (NbitLong - NbitShort - 1 DOWNTO 0 => '0') & INP_VALS(3)(NbitShort - 1 DOWNTO 0))
        REPORT " MUX_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(MUX_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 3.3 result: SUCCESSFUL");

        REPORT("TEST 3.4:   - Input on 10 changing");
        MEM_OUT_tb <= INP_VALS(2);
        WAIT FOR Tclk;
        ASSERT (MUX_OUT_tb = (NbitLong - NbitShort - 1 DOWNTO 0 => '0') & INP_VALS(2)(NbitShort - 1 DOWNTO 0))
        REPORT " MUX_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(MUX_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 3.4 result: SUCCESSFUL");

        --############################ TEST 4  ############################--
        REPORT("TEST 4:   - Input on 11 stable");
        NPC_OUT_tb    <= INP_VALS(1);
        WB_MUX_SEL_tb <= "11";
        WAIT FOR Tclk;
        ASSERT (MUX_OUT_tb = INP_VALS(1))
        REPORT " MUX_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(MUX_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 4 result: SUCCESSFUL");

        REPORT("TEST 4.1:   - Input on 11 changing");
        NPC_OUT_tb <= INP_VALS(0);
        WAIT FOR Tclk;
        ASSERT (MUX_OUT_tb = INP_VALS(0))
        REPORT " MUX_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(MUX_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 4.1 result: SUCCESSFUL");

        REPORT("Ending simulation");
        WAIT;
    END PROCESS P_STIMULI;
END TEST;