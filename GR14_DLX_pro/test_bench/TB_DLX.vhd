LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_DLX IS
END TB_DLX;
ARCHITECTURE TEST OF TB_DLX IS
    -- ESSENTIAL DESIGN SIGNALS:
    SIGNAL Clock_tb  : STD_LOGIC := '0'; -- clock
    SIGNAL ResetN_tb : STD_LOGIC;        -- reset (negated)
    -- INSTRUCTION MEMORY INTERFACE:
    SIGNAL Instr_In_tb      : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- new instruction
    SIGNAL ProgCount_Out_tb : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- instruction memory address
    -- DATA MEMORY INTERFACE:
    SIGNAL DataMem_WrEn_tb  : STD_LOGIC;                               -- DRAM write enable
    SIGNAL DataMem_BLen_tb  : STD_LOGIC_VECTOR(1 DOWNTO 0);            -- DRAM exchange format
    SIGNAL DataMem_Addr_tb  : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- DRAM address
    SIGNAL DataMem_Write_tb : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- data towards DRAM
    SIGNAL DataMem_Read_tb  : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- data from DRAM
    -- EXTRA SIGNALS FOR MEMORY
    SIGNAL DATA_READY_ROMEM_TB : STD_LOGIC;
    SIGNAL DATA_READY_RWMEM_TB : STD_LOGIC;
    -- EXTRA SIGNAL TO SUPPORT INOUT PORT OF DATA MEM
    SIGNAL Inout_data_mem_tb : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0); -- data towards DRAM
    -- SIGNAL TO SOLVE ADDRESS CONFLICT BETWEEN MEMORY AND PC
    SIGNAL PC_PRIME : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
    -- SIGNAL TO SOLVE ADDRESS CONFLICT BETWEEN ALU OUTPUT AND ADDDRESS IN OF RWMEM
    SIGNAL DataMem_Addr_prime_tb : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);


    COMPONENT DLX IS
        GENERIC
        (
            N_BITS_DATA  : NATURAL := NbitLong;  -- # of bits for data
            N_BYTES_INST : NATURAL := NPC_GAP;   -- distance between consequent istructions
            RF_ADDR      : NATURAL := RF_ADDR;   -- # of bits for RF address
            N_BITS_JUMP  : NATURAL := NbitJump;  -- # of bits for Jump Ops
            N_BITS_IMM   : NATURAL := NbitShort; -- # of bits for Immediate Ops
            MICRO_SIZE   : NATURAL := MICRO_N;   -- Microcode Memory Size
            FUNC_SIZE    : NATURAL := FUNC_N;    -- Func Field Size for R-Type Ops
            OPCODE_SIZE  : NATURAL := OPCODE_N;  -- Op Code Size
            IR_SIZE      : NATURAL := NbitLong;  -- Instruction Register Size
            CW_SIZE      : NATURAL := CW_N       -- Control Word Size
        );
        PORT
        (
            -- ESSENTIAL DESIGN SIGNALS:
            Clock  : IN STD_LOGIC; -- clock
            ResetN : IN STD_LOGIC; -- reset (negated)
            -- INSTRUCTION MEMORY INTERFACE:
            Instr_In      : IN STD_LOGIC_VECTOR(IR_SIZE - 1 DOWNTO 0);      -- new instruction
            ProgCount_Out : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- instruction memory address
            -- DATA MEMORY INTERFACE:
            DataMem_WrEn  : OUT STD_LOGIC;                                  -- DRAM write enable
            DataMem_BLen  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);               -- DRAM exchange format
            DataMem_Addr  : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- DRAM address
            DataMem_Write : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- data towards DRAM
            DataMem_Read  : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0)   -- data from DRAM
        );
    END COMPONENT;

    COMPONENT ROMEM IS
        GENERIC
        (
            FILE_PATH  : STRING;
            ENTRIES    : INTEGER := RWMEM_DEPTH;
            WORD_SIZE  : INTEGER := NbitLong;
            data_delay : NATURAL := 0
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

    COMPONENT RWMEM IS
        GENERIC
        (
            FILE_PATH      : STRING; -- RAM output data file
            FILE_PATH_INIT : STRING; -- RAM initialization data file
            Data_size      : NATURAL := NbitLong;
            Instr_size     : NATURAL := NbitLong;
            RAM_DEPTH      : NATURAL := RWMEM_DEPTH;
            DATA_DELAY     : NATURAL := 0 -- Delay ( in # of clock cycles )

        );
        PORT
        (
            CLK        : IN STD_LOGIC;
            RST        : IN STD_LOGIC;
            ADDR       : IN STD_LOGIC_VECTOR(Data_size DOWNTO 0);
            ENABLE     : IN STD_LOGIC;
            WR_EN      : IN STD_LOGIC;
            DATA_READY : OUT STD_LOGIC;
            INOUT_DATA : INOUT STD_LOGIC_VECTOR(Data_size - 1 DOWNTO 0);
            BYTE_LEN   : IN STD_LOGIC_VECTOR(1 DOWNTO 0)
        );
    END COMPONENT;

BEGIN
    DUT : DLX
    GENERIC
    MAP
    (
    N_BITS_DATA  => NbitLong,  -- # of bits for data
    N_BYTES_INST => NPC_GAP,   -- distance between consequent istructions
    RF_ADDR      => RF_ADDR,   -- # of bits for RF address
    N_BITS_JUMP  => NbitJump,  -- # of bits for Jump Ops
    N_BITS_IMM   => NbitShort, -- # of bits for Immediate Ops
    MICRO_SIZE   => MICRO_N,   -- Microcode Memory Size
    FUNC_SIZE    => FUNC_N,    -- Func Field Size for R-Type Ops
    OPCODE_SIZE  => OPCODE_N,  -- Op Code Size
    IR_SIZE      => NbitLong,  -- Instruction Register Size
    CW_SIZE      => CW_N       -- Control Word Size
    )
    PORT MAP
    (
        -- ESSENTIAL DESIGN SIGNALS:
        Clock  => Clock_tb,
        ResetN => ResetN_tb,
        -- INSTRUCTION MEMORY INTERFACE:
        Instr_In      => Instr_In_tb,
        ProgCount_Out => ProgCount_Out_tb,
        -- DATA MEMORY INTERFACE:
        DataMem_WrEn  => DataMem_WrEn_tb,
        DataMem_BLen  => DataMem_BLen_tb,
        DataMem_Addr  => DataMem_Addr_tb,
        DataMem_Write => DataMem_Write_tb,
        DataMem_Read  => DataMem_Read_tb
    );

    INST_MEM : ROMEM
    GENERIC
    MAP (
    FILE_PATH  => "../../memories/romem/hex.txt",
    ENTRIES    => RWMEM_DEPTH,
    WORD_SIZE  => NbitLong,
    DATA_DELAY => 0
    )
    PORT
    MAP (
    CLK        => Clock_tb,
    RST        => ResetN_tb,
    ADDRESS    => PC_PRIME, --dividing by 4 because each line of the txt file are 4 bytes
    ENABLE     => '1',
    DATA_READY => DATA_READY_ROMEM_TB,
    DATA       => Instr_In_tb
    );

    DATA_MEM : RWMEM
    GENERIC
    MAP (
    FILE_PATH      => "../../memories/rwmem/hex.txt",
    FILE_PATH_INIT => "../../memories/rwmem/hex_init.txt",
    Data_size      => NbitLong,
    Instr_size     => NbitLong,
    RAM_DEPTH      => RWMEM_DEPTH,
    DATA_DELAY     => 0
    )
    PORT
    MAP (
    CLK        => Clock_tb,
    RST        => ResetN_tb,
    ADDR       => DataMem_Addr_prime_tb,
    ENABLE     => '1',
    WR_EN      => DataMem_WrEn_tb, -- '1' write mode, '0' reading mode
    DATA_READY => DATA_READY_RWMEM_TB,
    INOUT_DATA => Inout_data_mem_tb,
    BYTE_LEN   => DataMem_BLen_tb
    );

    Inout_data_mem_tb <= DataMem_Write_tb WHEN (DataMem_WrEn_tb = '1') ELSE
        (OTHERS => 'Z');
    DataMem_Read_tb <= Inout_data_mem_tb;
    PC_PRIME        <= ("00" & ProgCount_Out_tb(NbitLong - 1 DOWNTO 2));

    DataMem_Addr_prime_tb <=  (31 downto 7 => '0') & DataMem_Addr_tb(6 downto 0);

    P_STIMULI : PROCESS
    BEGIN
        ResetN_tb <= '0';
        WAIT UNTIL falling_edge(Clock_tb);
        ResetN_tb <= '1';
        WAIT UNTIL falling_edge(Clock_tb);

        WAIT;
    END PROCESS P_STIMULI;

    P_CLOCK : PROCESS (Clock_tb)
    BEGIN
        Clock_tb <= NOT(Clock_tb) AFTER Tclk / 2;
    END PROCESS P_CLOCK;
END TEST;