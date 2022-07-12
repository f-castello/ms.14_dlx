library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
USE ieee.numeric_std.ALL;
USE work.dlx_utils.ALL;


entity TB_RWMEM is
end TB_RWMEM;


ARCHITECTURE TEST OF TB_RWMEM IS

                TYPE MEM_ARRAY IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
                SIGNAL MEM_EXAMPLE : MEM_ARRAY := (
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



                SIGNAL CLK_TB   				: std_logic := '0';
    			SIGNAL RST_TB					: std_logic;
    			SIGNAL ADDR_TB			    	: STD_LOGIC_VECTOR(6 downto 0);
    			SIGNAL ENABLE_TB		 		: STD_LOGIC;
    			SIGNAL READNOTWRITE_TB		    : STD_LOGIC;
    			SIGNAL DATA_READY_TB			: STD_LOGIC;
    			SIGNAL INOUT_DATA_TB			: std_logic_vector(NbitLong-1 downto 0);
                SIGNAL W_DATA_TB                : std_logic_vector(NbitLong-1 downto 0);
                SIGNAL BYTE_LEN_TB			    : STD_LOGIC_VECTOR(1 DOWNTO 0);    


    COMPONENT RWMEM is
    	generic(
    			FILE_PATH: string;				-- RAM output data file
    			FILE_PATH_INIT: string;			-- RAM initialization data file
                Data_size : natural := NbitLong;
                Instr_size: natural := NbitLong;
                RAM_DEPTH: 	natural := RWMEM_DEPTH;
    			DATA_DELAY: natural := 0		-- Delay ( in # of clock cycles )
                
    		);
    	port (
    			CLK   				: in std_logic;
    			RST					: in std_logic;
    			ADDR				: in std_logic_vector(6 downto 0);
    			ENABLE				: in std_logic;
    			READNOTWRITE		: in std_logic;
    			DATA_READY			: out std_logic;
    			INOUT_DATA			: INOUT std_logic_vector(Data_size-1 downto 0);
                BYTE_LEN			: IN STD_LOGIC_VECTOR(1 DOWNTO 0)
    		);
    END COMPONENT;
BEGIN
    DRAM : RWMEM
    generic map (
        FILE_PATH       =>"../../rwmem/hex.txt",
        FILE_PATH_INIT  =>"../../rwmem/hex_init.txt",
        Data_size       => NbitLong,
        Instr_size      => NbitLong,
        RAM_DEPTH       => RWMEM_DEPTH,
    	DATA_DELAY      => 0
    )
    port map ( 
        CLK =>CLK_TB , 
        RST =>RST_TB, 
        ADDR =>ADDR_TB, 
        ENABLE =>ENABLE_TB, 
        READNOTWRITE =>READNOTWRITE_TB, 
        DATA_READY =>DATA_READY_TB, 
        INOUT_DATA =>INOUT_DATA_TB,
		BYTE_LEN => BYTE_LEN_TB 
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
        READNOTWRITE_TB <= '0'; --writing mode
        BYTE_LEN_TB	    <= "00";
        index           := 0;
        while (index < MEM_EXAMPLE'length/4) loop
            ADDR_TB			<= std_logic_vector(to_unsigned(index, ADDR_TB'length));
            W_DATA_TB	<= MEM_EXAMPLE(index);
    	    WAIT FOR 1 ns; --wait ready signal

            
    	    
            
            index := index + 1;
            WAIT UNTIL falling_edge(CLK_tb);
        END LOOP;
        
        REPORT("TEST 2: Writing half word in memory");
        index           := 0;
        BYTE_LEN_TB	    <= "01";
        while (index < MEM_EXAMPLE'length/4) loop
            ADDR_TB			<= std_logic_vector(to_unsigned(index, ADDR_TB'length));
            W_DATA_TB	<= MEM_EXAMPLE(index);
    	    WAIT FOR 1 ns; --wait ready signal

            
    	    
            
            index := index + 1;
            WAIT UNTIL falling_edge(CLK_tb);
        END LOOP;

        REPORT("TEST 3: Writing full word in memory");
        index           := 0;
        BYTE_LEN_TB	    <= "10";
        while (index < MEM_EXAMPLE'length/4) loop
            ADDR_TB			<= std_logic_vector(to_unsigned(index, ADDR_TB'length));
            W_DATA_TB	<= MEM_EXAMPLE(index);
    	    WAIT FOR 1 ns; --wait ready signal

            
    	    
            
            index := index + 1;
            WAIT UNTIL falling_edge(CLK_tb);
        END LOOP;
        
        REPORT("TEST 4: Reading byte in memory");
        READNOTWRITE_TB <= '1'; --reading mode
        BYTE_LEN_TB	    <= "00"; --reading byte
        index           := 0;
        while (index < MEM_EXAMPLE'length/4) loop
            ADDR_TB			<= std_logic_vector(to_unsigned(index, ADDR_TB'length));
    	    WAIT FOR 1 ns; --wait ready signal

            index := index + 1;
            WAIT UNTIL falling_edge(CLK_tb);
        END LOOP;

        REPORT("TEST 5: Reading half word in memory");
        BYTE_LEN_TB	    <= "01"; --reading half word
        index           := 0;
        while (index < MEM_EXAMPLE'length/4) loop
            ADDR_TB			<= std_logic_vector(to_unsigned(index, ADDR_TB'length));
    	    WAIT FOR 1 ns; --wait ready signal

            index := index + 1;
            WAIT UNTIL falling_edge(CLK_tb);
        END LOOP;

        REPORT("TEST 6: Reading full word from memory");
        BYTE_LEN_TB	    <= "11"; --reading full word
        index           := 0;
        while (index < MEM_EXAMPLE'length/4) loop
            ADDR_TB			<= std_logic_vector(to_unsigned(index, ADDR_TB'length));
    	    WAIT FOR 1 ns; --wait ready signal

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
    INOUT_DATA_TB <= W_DATA_TB when (ENABLE_TB = '1' and READNOTWRITE_TB = '0') else (others=>'Z');
    
END TEST;