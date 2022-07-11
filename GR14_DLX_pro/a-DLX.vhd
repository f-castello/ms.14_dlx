LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.dlx_utils.ALL;

ENTITY DLX IS
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
END DLX;

ARCHITECTURE PRO OF DLX IS
    COMPONENT DP
        GENERIC
        (
            N_BITS_DATA  : NATURAL := NbitLong; -- # of bits for data
            N_BYTES_INST : NATURAL := NPC_GAP;  -- distance between consequent istructions
            RF_ADDR      : NATURAL := RF_ADDR;  -- # of bits for RF address
            N_BITS_JUMP  : NATURAL := NbitJump; -- # of bits for Jump Ops
            N_BITS_IMM   : NATURAL := NbitShort -- # of bits for Immediate Ops
        );
        PORT
        (
            --############################ CONTROL ############################--
            CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            -- IF_STAGE
            IF_LATCH_EN : IN STD_LOGIC; -- (PC, IR) Register Enable
            PC_LATCH_EN : IN STD_LOGIC; -- Program Counter Register Enable
            -- ID_STAGE
            DEC_OUTREG_EN : IN STD_LOGIC; -- (A, B, Imm, NPC1, IR1) Registers Enable
            IS_I_TYPE     : IN STD_LOGIC; -- Detect I-Type Instructions for Sign Extension & Writing Address Selection
            RD1_EN        : IN STD_LOGIC; -- Register File Read 1 Enable
            RD2_EN        : IN STD_LOGIC; -- Register File Read 2 Enable
            WR_EN         : IN STD_LOGIC; -- Register File Write Enable
            ZERO_PADDING2 : IN STD_LOGIC; -- Choose Zero Padding over normal Sign Extension
            -- EXE_STAGE
            MUXA_SEL      : IN STD_LOGIC; -- MUXA Selector
            MUXB_SEL      : IN STD_LOGIC; -- MUXB Selector
            EXE_OUTREG_EN : IN STD_LOGIC; -- (ALU Output, ALU Flags, NPC2, IR2, Pad OP, Zero OP) Registers Enable
            EQ_COND       : IN STD_LOGIC; -- Branch if (not) Equal to Zero
            JUMP_EN       : IN STD_LOGIC; -- Jump Enable Signal for Cond Selection
            ALU_OPCODE    : IN ALU_MSG;   -- Custom Type for ALU Ops
            -- MEM_STAGE
            MEM_OUTREG_EN : IN STD_LOGIC;                    -- (NPC3, IR3, BRA, ALU2MEM, OP2MEM) Registers Enable
            ZERO_PADDING4 : IN STD_LOGIC;                    -- Choose Zero Padding over normal Sign Extension
            MEM_OUT_SEL   : IN STD_LOGIC;                    -- Memory Output Mux Selector
            BYTE_LEN_IN   : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- Memory Output Modifier
            DRAM_WE       : IN STD_LOGIC;                    -- Data RAM Write Enable

            DRAM_WE_OUT  : OUT STD_LOGIC;                    -- Bypass to External Memory
            BYTE_LEN_OUT : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- Bypass to External Memory
            -- WB_STAGE
            WB_LATCH_EN : IN STD_LOGIC; -- Write Back Register Latch Enable
            JAL_MUX_SEL : IN STD_LOGIC; -- Jump And Link RF OR/Mux Selector
            WB_MUX_SEL  : IN STD_LOGIC; -- Write Back MUX Sel

            --############################ DATA ############################--
            -- IF_STAGE
            IR_IN : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Instruction Word from External Memory

            PC_OUT : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Program Counter to External Memory
            -- MEM_STAGE
            MEM_DATA_OUT_INT : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Data from External Memory

            MEM_ADDR_OUT      : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Address to External Memory
            MEM_DATA_IN_PRIME : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0)  -- Data to External Memory
        );
    END COMPONENT;

    COMPONENT CU_HW
        GENERIC
        (
            MICRO_SIZE  : NATURAL := MICRO_N;  -- Microcode Memory Size
            FUNC_SIZE   : NATURAL := FUNC_N;   -- Func Field Size for R-Type Ops
            OPCODE_SIZE : NATURAL := OPCODE_N; -- Op Code Size
            IR_SIZE     : NATURAL := NbitLong; -- Instruction Register Size
            CW_SIZE     : NATURAL := CW_N      -- Control Word Size
        );
        PORT
        (
            Clk   : IN STD_LOGIC;                              -- Clock
            Rst   : IN STD_LOGIC;                              -- Reset (Asynchronous & Active Low)
            IR_IN : IN STD_LOGIC_VECTOR(IR_SIZE - 1 DOWNTO 0); -- Instruction Register Word

            -- PIPE STAGE #1: IF
            IF_LATCH_EN : OUT STD_LOGIC; -- (PC, IR) Register Enable

            -- PIPE STAGE #2: ID
            DEC_OUTREG_EN : OUT STD_LOGIC; -- (A, B, Imm, NPC1, IR1) Registers Enable
            IS_I_TYPE     : OUT STD_LOGIC; -- Detect I-Type Instructions for Sign Extension & Writing Address Selection
            RD1_EN        : OUT STD_LOGIC; -- Register File Read 1 Enable
            RD2_EN        : OUT STD_LOGIC; -- Register File Read 2 Enable
            ZERO_PADDING2 : OUT STD_LOGIC; -- Choose Zero Padding over normal Sign Extension

            -- PIPE STAGE #3: EXE
            MUXA_SEL      : OUT STD_LOGIC; -- MUXA Selector
            MUXB_SEL      : OUT STD_LOGIC; -- MUXB Selector
            EXE_OUTREG_EN : OUT STD_LOGIC; -- (ALU Output, ALU Flags, NPC2, IR2, Pad OP, Zero OP) Registers Enable
            EQ_COND       : OUT STD_LOGIC; -- Branch if (not) Equal to Zero
            JUMP_EN       : OUT STD_LOGIC; -- Jump Enable Signal for Cond Selection
            -- EXECUTION UNITS
            ALU_OPCODE : OUT ALU_MSG; -- Custom Type for ALU Ops
            FPU_OPCODE : OUT FPU_MSG; -- Custom Type for FPU Ops

            -- PIPE STAGE #4: MEM
            PC_LATCH_EN   : OUT STD_LOGIC; -- Program Counter Register Enable
            MEM_OUTREG_EN : OUT STD_LOGIC; -- (NPC3, IR3, BRA, ALU2MEM, OP2MEM) Registers Enable
            ZERO_PADDING4 : OUT STD_LOGIC; -- Choose Zero Padding over normal Sign Extension
            MEM_OUT_SEL   : OUT STD_LOGIC; -- Memory Output Mux Selector
            -- EXTERNAL MEMORY
            DRAM_WE  : OUT STD_LOGIC;                    -- Data RAM Write Enable
            BYTE_LEN : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- Memory Output Modifier

            -- PIPE STAGE #5: WB
            WB_MUX_SEL  : OUT STD_LOGIC; -- Write Back MUX Sel
            JAL_MUX_SEL : OUT STD_LOGIC; -- Jump And Link RF OR/Mux Selector
            WR_EN       : OUT STD_LOGIC; -- Register File Write Enable
            WB_LATCH_EN : OUT STD_LOGIC  -- Write Back Register Latch Enable
        );
    END COMPONENT;

    SIGNAL IR_IN : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- interface between Instruction Memory and Datapath

    SIGNAL IF_LATCH_EN   : STD_LOGIC;
    SIGNAL DEC_OUTREG_EN : STD_LOGIC;
    SIGNAL IS_I_TYPE     : STD_LOGIC;
    SIGNAL RD1_EN        : STD_LOGIC;
    SIGNAL RD2_EN        : STD_LOGIC;
    SIGNAL ZERO_PADDING2 : STD_LOGIC;
    SIGNAL MUXA_SEL      : STD_LOGIC;
    SIGNAL MUXB_SEL      : STD_LOGIC;
    SIGNAL EXE_OUTREG_EN : STD_LOGIC;
    SIGNAL EQ_COND       : STD_LOGIC;
    SIGNAL JUMP_EN       : STD_LOGIC;
    SIGNAL PC_LATCH_EN   : STD_LOGIC;
    SIGNAL MEM_OUTREG_EN : STD_LOGIC;
    SIGNAL ZERO_PADDING4 : STD_LOGIC;
    SIGNAL MEM_OUT_SEL   : STD_LOGIC;
    SIGNAL WB_MUX_SEL    : STD_LOGIC;
    SIGNAL JAL_MUX_SEL   : STD_LOGIC;
    SIGNAL WR_EN         : STD_LOGIC;
    SIGNAL WB_LATCH_EN   : STD_LOGIC;
    SIGNAL ALU_OPCODE    : ALU_MSG;
    SIGNAL DRAM_WE_INT   : STD_LOGIC;
    SIGNAL BYTE_LEN_INT  : STD_LOGIC_VECTOR(1 DOWNTO 0);

BEGIN
    DATAPATH : DP GENERIC
    MAP
    (
    N_BITS_DATA  => N_BITS_DATA,
    N_BYTES_INST => N_BYTES_INST,
    RF_ADDR      => RF_ADDR,
    N_BITS_JUMP  => N_BITS_JUMP,
    N_BITS_IMM   => N_BITS_IMM
    )
    PORT MAP
    (
        CLK               => Clock,
        RST               => ResetN,
        IF_LATCH_EN       => IF_LATCH_EN,
        PC_LATCH_EN       => PC_LATCH_EN,
        DEC_OUTREG_EN     => DEC_OUTREG_EN,
        IS_I_TYPE         => IS_I_TYPE,
        RD1_EN            => RD1_EN,
        RD2_EN            => RD2_EN,
        WR_EN             => WR_EN,
        ZERO_PADDING2     => ZERO_PADDING2,
        MUXA_SEL          => MUXA_SEL,
        MUXB_SEL          => MUXB_SEL,
        EXE_OUTREG_EN     => EXE_OUTREG_EN,
        EQ_COND           => EQ_COND,
        JUMP_EN           => JUMP_EN,
        ALU_OPCODE        => ALU_OPCODE,
        MEM_OUTREG_EN     => MEM_OUTREG_EN,
        ZERO_PADDING4     => ZERO_PADDING4,
        MEM_OUT_SEL       => MEM_OUT_SEL,
        BYTE_LEN_IN       => BYTE_LEN_INT,
        DRAM_WE           => DRAM_WE_INT,
        DRAM_WE_OUT       => DataMem_WrEn,
        BYTE_LEN_OUT      => DataMem_BLen,
        WB_LATCH_EN       => WB_LATCH_EN,
        JAL_MUX_SEL       => JAL_MUX_SEL,
        WB_MUX_SEL        => WB_MUX_SEL,
        IR_IN             => IR_IN,
        PC_OUT            => ProgCount_Out,
        MEM_DATA_OUT_INT  => DataMem_Read,
        MEM_ADDR_OUT      => DataMem_Addr,
        MEM_DATA_IN_PRIME => DataMem_Write
    );

    CONTROL : CU_HW GENERIC
    MAP
    (
    MICRO_SIZE  => MICRO_SIZE,
    FUNC_SIZE   => FUNC_SIZE,
    OPCODE_SIZE => OPCODE_SIZE,
    IR_SIZE     => IR_SIZE,
    CW_SIZE     => CW_SIZE
    )
    PORT
    MAP
    (
    Clk           => Clock,
    Rst           => ResetN,
    IR_IN         => Instr_In,
    IF_LATCH_EN   => IF_LATCH_EN,
    DEC_OUTREG_EN => DEC_OUTREG_EN,
    IS_I_TYPE     => IS_I_TYPE,
    RD1_EN        => RD1_EN,
    RD2_EN        => RD2_EN,
    ZERO_PADDING2 => ZERO_PADDING2,
    MUXA_SEL      => MUXA_SEL,
    MUXB_SEL      => MUXB_SEL,
    EXE_OUTREG_EN => EXE_OUTREG_EN,
    EQ_COND       => EQ_COND,
    JUMP_EN       => JUMP_EN,
    ALU_OPCODE    => ALU_OPCODE,
    PC_LATCH_EN   => PC_LATCH_EN,
    MEM_OUTREG_EN => MEM_OUTREG_EN,
    ZERO_PADDING4 => ZERO_PADDING4,
    MEM_OUT_SEL   => MEM_OUT_SEL,
    DRAM_WE       => DRAM_WE_INT,
    BYTE_LEN      => BYTE_LEN_INT,
    WB_MUX_SEL    => WB_MUX_SEL,
    JAL_MUX_SEL   => JAL_MUX_SEL,
    WR_EN         => WR_EN,
    WB_LATCH_EN   => WB_LATCH_EN
    );

    PROCESS (Clock, ResetN) -- delay the whole Datapath by 1 cc with respect to the Control Unit
    BEGIN
        IF (ResetN = '0') THEN
            IR_IN <= (OTHERS => '0');
        ELSIF rising_edge(Clock) THEN
            IR_IN <= Instr_In;
        END IF;
    END PROCESS;
END PRO;