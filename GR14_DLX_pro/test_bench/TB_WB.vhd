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
    SIGNAL CLK_tb          : STD_LOGIC := '0';
    SIGNAL RST_tb          : STD_LOGIC;
    SIGNAL WB_LATCH_EN_tb  : STD_LOGIC; -- Write Back Register Latch Enable
    SIGNAL JAL_MUX_SEL5_tb : STD_LOGIC; -- 'Jal' Op Auxiliary Selector
    SIGNAL WB_MUX_SEL_tb   : STD_LOGIC; -- Primary Outcome Selector
    SIGNAL IR_IN_tb        : STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
    SIGNAL MUX_IN2_tb      : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- Mux Input #2
    SIGNAL MUX_IN1_tb      : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- Mux Input #1
    SIGNAL MUX_IN0_tb      : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- Mux Input #0
    SIGNAL WRT_OUT_tb      : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- Pipe Register Output
    SIGNAL IR_OUT_tb       : STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);

    COMPONENT WB_STAGE IS
        GENERIC
        (
            N_BITS_DATA : NATURAL := NbitLong; -- # of bits
            RF_ADDR     : NATURAL := RF_ADDR
        );
        PORT
        (
            -- Control ports
            CLK          : IN STD_LOGIC;
            RST          : IN STD_LOGIC;
            WB_LATCH_EN  : IN STD_LOGIC; -- (WRT, IR4) Registers Enable
            JAL_MUX_SEL5 : IN STD_LOGIC; -- 'Jal' Op Auxiliary Selector
            WB_MUX_SEL   : IN STD_LOGIC; -- Primary Outcome Selector
            -- Data ports
            IR_IN   : IN STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
            MUX_IN2 : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);  -- Mux Input #2 ("1-" -> NPC)
            MUX_IN1 : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);  -- Mux Input #1 ("01" -> MEM Out)
            MUX_IN0 : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);  -- Mux Input #0 ("00" -> ALU Out)
            WRT_OUT : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Pipe Register Output
            IR_OUT  : OUT STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0)
        );
    END COMPONENT;

BEGIN
    DUT : WB_STAGE
    GENERIC
    MAP (
    N_BITS_DATA => NbitLong,
    RF_ADDR     => RF_ADDR
    )
    PORT MAP
    (
        CLK          => CLK_tb,
        RST          => RST_tb,
        WB_LATCH_EN  => WB_LATCH_EN_tb,
        JAL_MUX_SEL5 => JAL_MUX_SEL5_tb,
        WB_MUX_SEL   => WB_MUX_SEL_tb,
        IR_IN        => IR_IN_tb,
        MUX_IN2      => MUX_IN2_tb,
        MUX_IN1      => MUX_IN1_tb,
        MUX_IN0      => MUX_IN0_tb,
        WRT_OUT      => WRT_OUT_tb,
        IR_OUT       => IR_OUT_tb
    );

    P_STIMULI : PROCESS
    BEGIN
        REPORT("Starting simulation");
        RST_tb          <= '0'; -- resetting (active-low)
        WB_LATCH_EN_tb  <= '1';
        JAL_MUX_SEL5_tb <= '0';
        WB_MUX_SEL_tb   <= '0';
        IR_IN_tb        <= (OTHERS => '0');
        MUX_IN0_tb      <= (OTHERS => '0');
        MUX_IN1_tb      <= (OTHERS => '0');
        MUX_IN2_tb      <= (OTHERS => '0');
        WAIT UNTIL falling_edge(CLK_tb);
        RST_tb <= '1';

        --############################ TEST 1  ############################--
        REPORT("TEST 1:   - Input on 00 stable");
        MUX_IN0_tb <= INP_VALS(7);
        WAIT UNTIL falling_edge(CLK_tb);
        ASSERT (WRT_OUT_tb = INP_VALS(7))
        REPORT " WRT_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(WRT_OUT_tb)))
            SEVERITY failure;
        ASSERT (IR_OUT_tb = (IR_OUT_tb'RANGE => '0'))
        REPORT " IR_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(IR_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 1 result: SUCCESSFUL");

        REPORT("TEST 1.1:   - Input on 00 changing");
        MUX_IN0_tb <= INP_VALS(6);
        WAIT UNTIL falling_edge(CLK_tb);
        ASSERT (WRT_OUT_tb = INP_VALS(6))
        REPORT " WRT_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(WRT_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 1.1 result: SUCCESSFUL");

        --############################ TEST 2  ############################--
        REPORT("TEST 2:   - Input on 01 stable");
        MUX_IN1_tb      <= INP_VALS(5);
        JAL_MUX_SEL5_tb <= '0';
        WB_MUX_SEL_tb   <= '1';
        WAIT UNTIL falling_edge(CLK_tb);
        ASSERT (WRT_OUT_tb = INP_VALS(5))
        REPORT " WRT_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(WRT_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 2 result: SUCCESSFUL");

        REPORT("TEST 2.1:   - Input on 01 changing");
        MUX_IN1_tb <= INP_VALS(4);
        WAIT UNTIL falling_edge(CLK_tb);
        ASSERT (WRT_OUT_tb = INP_VALS(4))
        REPORT " WRT_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(WRT_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 2.1 result: SUCCESSFUL");

        --############################ TEST 3  ############################--
        REPORT("TEST 3:   - Input on 10 stable");
        MUX_IN2_tb      <= INP_VALS(3);
        JAL_MUX_SEL5_tb <= '1';
        WB_MUX_SEL_tb   <= '0';
        WAIT UNTIL falling_edge(CLK_tb);
        ASSERT (WRT_OUT_tb = INP_VALS(3))
        REPORT " WRT_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(WRT_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 3 result: SUCCESSFUL");

        REPORT("TEST 3.1:   - Input on 10 changing");
        MUX_IN2_tb <= INP_VALS(2);
        WAIT UNTIL falling_edge(CLK_tb);
        ASSERT (WRT_OUT_tb = INP_VALS(2))
        REPORT " WRT_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(WRT_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 3.1 result: SUCCESSFUL");

        --############################ TEST 4  ############################--
        REPORT("TEST 4:   - Input on 11 stable");
        MUX_IN2_tb      <= INP_VALS(1);
        JAL_MUX_SEL5_tb <= '1';
        WB_MUX_SEL_tb   <= '1';
        WAIT UNTIL falling_edge(CLK_tb);
        ASSERT (WRT_OUT_tb = INP_VALS(1))
        REPORT " WRT_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(WRT_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 4 result: SUCCESSFUL");

        REPORT("TEST 4.1:   - Input on 11 & IR changing");
        MUX_IN2_tb <= INP_VALS(0);
        IR_IN_tb   <= (OTHERS => '1');
        WAIT UNTIL falling_edge(CLK_tb);
        ASSERT (WRT_OUT_tb = INP_VALS(0))
        REPORT " WRT_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(WRT_OUT_tb)))
            SEVERITY failure;
        ASSERT (IR_OUT_tb = (IR_OUT_tb'RANGE => '1'))
        REPORT " IR_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(IR_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 4.1 result: SUCCESSFUL");

        --############################ TEST 5  ############################--
        REPORT("TEST 5:   - Disable stage");
        WB_LATCH_EN_tb <= '0';
        WAIT UNTIL falling_edge(CLK_tb);
        ASSERT (WRT_OUT_tb = INP_VALS(0))
        REPORT " WRT_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(WRT_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 5 result: SUCCESSFUL");

        --############################ TEST 6  ############################--
        REPORT("TEST 6:   - Reset during normal operation");
        WB_LATCH_EN_tb <= '1';
        RST_tb         <= '0';
        WAIT UNTIL falling_edge(CLK_tb);
        ASSERT (WRT_OUT_tb = (WRT_OUT_tb'RANGE => '0'))
        REPORT " WRT_OUT: " & INTEGER'image(TO_INTEGER(UNSIGNED(WRT_OUT_tb)))
            SEVERITY failure;
        REPORT("TEST 6 result: SUCCESSFUL");

        WAIT;
    END PROCESS;

    P_CLOCK : PROCESS (CLK_tb)
    BEGIN
        CLK_tb <= NOT(CLK_tb) AFTER Tclk / 2;
    END PROCESS;
END TEST;