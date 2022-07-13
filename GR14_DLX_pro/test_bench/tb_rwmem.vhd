LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_RWMEM IS
END TB_RWMEM;

ARCHITECTURE TEST OF TB_RWMEM IS
    TYPE MEM_ARRAY IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
    CONSTANT MEM_EXAMPLE : MEM_ARRAY := (
        STD_LOGIC_VECTOR(to_unsigned(0, NbitLong)),
        STD_LOGIC_VECTOR(to_unsigned(101111, NbitLong)),
        STD_LOGIC_VECTOR(to_unsigned(1232202, NbitLong)),
        STD_LOGIC_VECTOR(to_unsigned(333033, NbitLong)),
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

    SIGNAL CLK_TB        : STD_LOGIC := '0';
    SIGNAL RST_TB        : STD_LOGIC;
    SIGNAL ADDR_TB       : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
    SIGNAL ENABLE_TB     : STD_LOGIC;
    SIGNAL WR_EN_TB      : STD_LOGIC;
    SIGNAL DATA_READY_TB : STD_LOGIC;
    SIGNAL INOUT_DATA_TB : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
    SIGNAL W_DATA_TB     : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
    SIGNAL BYTE_LEN_TB   : STD_LOGIC_VECTOR(1 DOWNTO 0);

    COMPONENT RWMEM IS
        GENERIC
        (
            FILE_PATH      : STRING; -- RAM output data file
            FILE_PATH_INIT : STRING; -- RAM initialization data file
            DATA_SIZE      : NATURAL := NbitLong;
            INSTR_SIZE     : NATURAL := NbitLong;
            RAM_DEPTH      : NATURAL := RWMEM_DEPTH;
            DATA_DELAY     : NATURAL := 0 -- Delay ( in # of clock cycles )

        );
        PORT
        (
            CLK        : IN STD_LOGIC;
            RST        : IN STD_LOGIC;
            ADDR       : IN STD_LOGIC_VECTOR(DATA_SIZE - 1 DOWNTO 0);
            ENABLE     : IN STD_LOGIC;
            WR_EN      : IN STD_LOGIC;
            DATA_READY : OUT STD_LOGIC;
            INOUT_DATA : INOUT STD_LOGIC_VECTOR(DATA_SIZE - 1 DOWNTO 0);
            BYTE_LEN   : IN STD_LOGIC_VECTOR(1 DOWNTO 0)
        );
    END COMPONENT;

BEGIN
    DRAM : RWMEM
    GENERIC
    MAP (
    FILE_PATH      => "../../memories/rwmem/hex.txt",
    FILE_PATH_INIT => "../../memories/rwmem/hex_init.txt",
    DATA_SIZE      => NbitLong,
    INSTR_SIZE     => NbitLong,
    RAM_DEPTH      => RWMEM_DEPTH,
    DATA_DELAY     => 0
    )
    PORT MAP
    (
        CLK        => CLK_TB,
        RST        => RST_TB,
        ADDR       => ADDR_TB,
        ENABLE     => ENABLE_TB,
        WR_EN      => WR_EN_TB,
        DATA_READY => DATA_READY_TB,
        INOUT_DATA => INOUT_DATA_TB,
        BYTE_LEN   => BYTE_LEN_TB
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
        RST_TB      <= '1';
        ENABLE_TB   <= '1'; --enabling memory
        WR_EN_TB    <= '1'; --writing mode
        BYTE_LEN_TB <= "00";
        index := 0;
        WHILE (index < MEM_EXAMPLE'length/4) LOOP
            ADDR_TB   <= STD_LOGIC_VECTOR(to_unsigned(index, ADDR_TB'length));
            W_DATA_TB <= MEM_EXAMPLE(index);
            WAIT FOR Tclk / 2; --wait ready signal
            index := index + 1;
            WAIT UNTIL falling_edge(CLK_tb);
        END LOOP;

        REPORT("TEST 2: Writing half word in memory");
        index := 0;
        BYTE_LEN_TB <= "01";
        WHILE (index < MEM_EXAMPLE'length/4) LOOP
            ADDR_TB   <= STD_LOGIC_VECTOR(to_unsigned(index, ADDR_TB'length));
            W_DATA_TB <= MEM_EXAMPLE(index);
            WAIT FOR Tclk / 2; --wait ready signal
            index := index + 1;
            WAIT UNTIL falling_edge(CLK_tb);
        END LOOP;

        REPORT("TEST 3: Writing full word in memory");
        index := 0;
        BYTE_LEN_TB <= "10";
        WHILE (index < MEM_EXAMPLE'length/4) LOOP
            ADDR_TB   <= STD_LOGIC_VECTOR(to_unsigned(index, ADDR_TB'length));
            W_DATA_TB <= MEM_EXAMPLE(index);
            WAIT FOR Tclk / 2; --wait ready signal
            index := index + 1;
            WAIT UNTIL falling_edge(CLK_tb);
        END LOOP;

        REPORT("TEST 4: Reading byte in memory");
        WR_EN_TB    <= '0';  --reading mode
        BYTE_LEN_TB <= "00"; --reading byte
        index := 0;
        WHILE (index < MEM_EXAMPLE'length/4) LOOP
            ADDR_TB <= STD_LOGIC_VECTOR(to_unsigned(index, ADDR_TB'length));
            WAIT FOR Tclk / 2; --wait ready signal
            index := index + 1;
            WAIT UNTIL falling_edge(CLK_tb);
        END LOOP;

        REPORT("TEST 5: Reading half word in memory");
        BYTE_LEN_TB <= "01"; --reading half word
        index := 0;
        WHILE (index < MEM_EXAMPLE'length/4) LOOP
            ADDR_TB <= STD_LOGIC_VECTOR(to_unsigned(index, ADDR_TB'length));
            WAIT FOR Tclk / 2; --wait ready signal
            index := index + 1;
            WAIT UNTIL falling_edge(CLK_tb);
        END LOOP;

        REPORT("TEST 6: Reading full word from memory");
        BYTE_LEN_TB <= "11"; --reading full word
        index := 0;
        WHILE (index < MEM_EXAMPLE'length/4) LOOP
            ADDR_TB <= STD_LOGIC_VECTOR(to_unsigned(index, ADDR_TB'length));
            WAIT FOR Tclk / 2; --wait ready signal
            index := index + 1;
            WAIT UNTIL falling_edge(CLK_tb);
        END LOOP;

        REPORT("END SIMULATION");
        WAIT;
    END PROCESS;

    P_CLOCK : PROCESS (CLK_tb)
    BEGIN
        CLK_tb <= NOT(CLK_tb) AFTER Tclk / 2;
    END PROCESS;

    INOUT_DATA_TB <= W_DATA_TB WHEN (ENABLE_TB = '1' AND WR_EN_TB = '1') ELSE
        (OTHERS => 'Z');
END TEST;