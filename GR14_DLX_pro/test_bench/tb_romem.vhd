library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
USE ieee.numeric_std.ALL;
USE work.dlx_utils.ALL;


entity TB_ROMEM is
end TB_ROMEM;


ARCHITECTURE TEST OF TB_ROMEM IS


TYPE MEM_ARRAY IS ARRAY (0 TO 52) OF STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
    SIGNAL MEM_COPY : MEM_ARRAY := (
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


            SIGNAL CLK_TB					: std_logic :='0';
            SIGNAL RST_TB					: std_logic;
            SIGNAL ADDRESS_TB				: std_logic_vector(NbitLong - 1 downto 0);
            SIGNAL ENABLE_TB				: std_logic;
            SIGNAL DATA_READY_TB			: std_logic;
            SIGNAL DATA_TB				    : std_logic_vector(NbitLong - 1 downto 0);


    COMPONENT ROMEM is
        generic (
            FILE_PATH	: string;
            ENTRIES		: integer := RWMEM_DEPTH;
            WORD_SIZE	: integer := NbitLong;
            data_delay	: natural := 0
        );
        port (
            CLK					: in std_logic;
            RST					: in std_logic;
            ADDRESS				: in std_logic_vector(WORD_SIZE - 1 downto 0);
            ENABLE				: in std_logic;
            DATA_READY			: out std_logic;
            DATA				: out std_logic_vector(WORD_SIZE - 1 downto 0)
        );
    END COMPONENT;
BEGIN
    DRAM : ROMEM
    generic map (
        
    
        FILE_PATH       =>"../../romem/hex.txt",
        ENTRIES         => RWMEM_DEPTH,
        WORD_SIZE      => NbitLong,
    	DATA_DELAY      => 0
    )
    port map ( 
        CLK					=>CLK_TB,
        RST					=>RST_TB,
        ADDRESS				=>ADDRESS_TB,
        ENABLE				=>ENABLE_TB,
        DATA_READY			=>DATA_READY_TB,
        DATA				=>DATA_TB
        );

    P_STIMULI: PROCESS
       variable index: integer range 0 to RWMEM_DEPTH;
    BEGIN
        ENABLE_TB <= '0';
        WAIT UNTIL falling_edge(CLK_tb);
        RST_TB <= '1';
        
        ---
        WAIT UNTIL falling_edge(CLK_tb);
        REPORT("Starting simulation");
        REPORT("TEST 1: Writing byte in memory");
        RST_TB          <= '0';
        ENABLE_TB       <= '1'; --enabling memory       
        index           := 0;
        while (index < MEM_COPY'length) loop
            ADDRESS_TB			<= std_logic_vector(to_unsigned(index, ADDRESS_TB'length));
    	    WAIT FOR 1 ns; --wait ready signal
            
            WAIT UNTIL falling_edge(CLK_tb);
            ASSERT (DATA_TB = MEM_COPY(index))
            REPORT "Values different"
                SEVERITY failure;
            
            index := index + 1;
        END LOOP;
        
        

        REPORT("END SIMULATION");
        WAIT;
    END PROCESS;

    P_CLOCK : PROCESS (CLK_tb)
	BEGIN
		CLK_tb <= NOT(CLK_tb) AFTER Tclk / 2;
	END PROCESS;
    
END TEST;