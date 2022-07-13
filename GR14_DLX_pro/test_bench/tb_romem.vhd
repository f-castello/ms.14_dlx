LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_ROMEM IS
END TB_ROMEM;

ARCHITECTURE TEST OF TB_ROMEM IS
    TYPE MEM_ARRAY IS ARRAY (0 TO 52) OF STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
    CONSTANT MEM_COPY : MEM_ARRAY := (
        x"00210826",
        x"00421026",
        x"0339C826",
        x"035AD026",
        x"20010000",
        x"2002000A",
        x"0800000A",
        x"8C280000",
        x"8C490000",
        x"54000000",
        x"54000000",
        x"0109502B",
        x"54000000",
        x"11400002",
        x"AC290000",
        x"AC480000",
        x"4BE00000",
        x"01084026",
        x"01294826",
        x"014A5026",
        x"28420001",
        x"0102502A",
        x"54000000",
        x"1140000D",
        x"01294826",
        x"00485822",
        x"012B502A",
        x"54000000",
        x"11400006",
        x"212C0001",
        x"00098820",
        x"000C9020",
        x"0FFFFFE6",
        x"21290001",
        x"0BFFFFF6",
        x"21080001",
        x"0BFFFFF0",
        x"54000000",
        x"54000000",
        x"54000000",
        x"8C010000",
        x"8C010001",
        x"8C010002",
        x"8C010003",
        x"8C010004",
        x"8C010005",
        x"8C010006",
        x"8C010007",
        x"8C010008",
        x"8C010009",
        x"54000000",
        x"54000000",
        x"0BFFFFFD"
    );

    SIGNAL CLK_TB        : STD_LOGIC := '0';
    SIGNAL RST_TB        : STD_LOGIC;
    SIGNAL ADDRESS_TB    : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
    SIGNAL ENABLE_TB     : STD_LOGIC;
    SIGNAL DATA_READY_TB : STD_LOGIC;
    SIGNAL DATA_TB       : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);

    COMPONENT ROMEM IS
        GENERIC
        (
            FILE_PATH  : STRING;
            ENTRIES    : INTEGER := RWMEM_DEPTH;
            WORD_SIZE  : INTEGER := NbitLong;
            DATA_DELAY : NATURAL := 0
        );
        PORT
        (
            CLK        : IN STD_LOGIC;
            RST        : IN STD_LOGIC;
            ADDRESS    : IN STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
            ENABLE     : IN STD_LOGIC;
            DATA_READY : OUT STD_LOGIC;
            DATA       : OUT STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0)
        );
    END COMPONENT;
BEGIN
    DRAM : ROMEM
    GENERIC
    MAP (
    FILE_PATH  => "../../memories/romem/hex2.txt",
    ENTRIES    => RWMEM_DEPTH,
    WORD_SIZE  => NbitLong,
    DATA_DELAY => 0
    )
    PORT MAP
    (
        CLK        => CLK_TB,
        RST        => RST_TB,
        ADDRESS    => ADDRESS_TB,
        ENABLE     => ENABLE_TB,
        DATA_READY => DATA_READY_TB,
        DATA       => DATA_TB
    );

    P_STIMULI : PROCESS
        VARIABLE index : INTEGER RANGE 0 TO RWMEM_DEPTH;
    BEGIN
        REPORT("Starting simulation");
        ENABLE_TB <= '0';
        WAIT UNTIL falling_edge(CLK_tb);
        RST_TB <= '0';
        WAIT UNTIL falling_edge(CLK_tb);

        REPORT("TEST 1: Writing byte in memory");
        RST_TB    <= '1'; --no reseting
        ENABLE_TB <= '1'; --enabling memory       
        index := 0;
        WHILE (index < MEM_COPY'length) LOOP
            ADDRESS_TB <= STD_LOGIC_VECTOR(to_unsigned(index, ADDRESS_TB'length));
            WAIT FOR Tclk / 2; --wait ready signal
            WAIT UNTIL falling_edge(CLK_tb);
            ASSERT (DATA_TB = MEM_COPY(index))
            REPORT "Values different"
                SEVERITY failure;
            index := index + 1;
        END LOOP;

        REPORT("END SIMULATION");
        WAIT;
    END PROCESS P_STIMULI;

    P_CLOCK : PROCESS (CLK_tb)
    BEGIN
        CLK_tb <= NOT(CLK_tb) AFTER Tclk / 2;
    END PROCESS P_CLOCK;
END TEST;