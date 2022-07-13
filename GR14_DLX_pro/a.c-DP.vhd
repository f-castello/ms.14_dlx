LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.dlx_utils.ALL;

ENTITY DP IS
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
        IF_LATCH_EN : IN STD_LOGIC; -- (PC, IR, NPC0, NPCA, NPCB) Registers Enable
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
END DP;

ARCHITECTURE PIPELINED OF DP IS
    SIGNAL PC_MEM2IF : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);

    COMPONENT IF_STAGE
        GENERIC
        (
            N_BITS_DATA  : NATURAL := NbitLong; -- # of bits
            N_BYTES_INST : NATURAL := NPC_GAP
        );
        PORT
        (
            -- Control ports
            CLK         : IN STD_LOGIC;
            RST         : IN STD_LOGIC;
            IF_LATCH_EN : IN STD_LOGIC; -- (PC, IR, NPC0, NPCA, NPCB) Registers Enable
            -- Data ports
            PC_IN   : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
            IR_IN   : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- output of the memory to the IR
            PC_OUT  : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
            IR_OUT  : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
            ADD_OUT : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
            NPC_OUT : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL NPC_IF2ID  : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
    SIGNAL NPC_IF2MEM : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);

    SIGNAL IR_IF2ID : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);

    SIGNAL IR_WB2ID : STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);

    SIGNAL MUX_WB2ID : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);

    COMPONENT ID_STAGE
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
            WR_EN         : IN STD_LOGIC; --enable writing port of the RF
            ZERO_PADDING2 : IN STD_LOGIC; --
            -- Data ports
            I_CODE      : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- output of the memory to the IR
            NPC1_IN     : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
            DATA_IN     : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
            WR_ADDR_IN  : IN STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
            REGA_OUT    : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
            REGB_OUT    : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
            REGIMM_OUT  : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
            WR_ADDR_OUT : OUT STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
            NPC1_OUT    : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0) --IN EX STAGE, THE INPUT 0 OF FIRST MUX SHOULD BE THIS REGISTER?
        );
    END COMPONENT;

    SIGNAL NPC_ID2EXE : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
    SIGNAL A_ID2EXE   : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
    SIGNAL B_ID2EXE   : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
    SIGNAL IMM_ID2EXE : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
    SIGNAL IR_ID2EXE  : STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);

    SIGNAL N : STD_LOGIC;
    SIGNAL Z : STD_LOGIC;
    SIGNAL C : STD_LOGIC;
    SIGNAL V : STD_LOGIC;

    COMPONENT EXE_STAGE
        GENERIC
        (
            N_BITS_DATA : NATURAL := NbitLong; -- # of bits for data
            RF_ADDR     : NATURAL := RF_ADDR   -- # OF BITS FOR REGISTER FILE ADDRESS
        );
        PORT
        (
            -- Control ports 
            CLK           : IN STD_LOGIC;
            RST           : IN STD_LOGIC;
            MUXA_SEL      : IN STD_LOGIC; -- MUXA Sel
            MUXB_SEL      : IN STD_LOGIC; -- MUXB Sel
            EXE_OUTREG_EN : IN STD_LOGIC; -- (ALU Output, ALU Flags, NPC2, IR2, Pad OP, Zero OP) Registers Enable
            EQ_COND       : IN STD_LOGIC; -- Branch if (not) Equal to Zero
            JUMP_EN       : IN STD_LOGIC; -- Jump Enable Signal for Cond Selection
            ALU_OPCODE    : IN ALU_MSG;   -- Custom Type for ALU Ops
            -- Data ports
            NPC2_IN      : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);  -- NPC2 reg input
            NPC1_MUXA_IN : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);  -- Input 0 of the first multiplexer
            REGA_MUXA_IN : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);  -- Input 1 of the first multiplexer
            REGB_MUXB_IN : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);  -- Input 0 of the second multiplexer
            IMM_MUXB_IN  : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);  -- Input 1 of the second multiplexer
            PAD_IN       : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);  -- Pad OP reg input
            IR2_IN       : IN STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);      -- IR2 reg input
            NPC2_OUT     : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- NPC2 reg output
            ZERO_OP_OUT  : OUT STD_LOGIC;                                  -- Output of the Zero OP reg
            ALU_OUT      : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Output data of the ALU
            PAD_OUT      : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Pad OP reg output
            IR2_OUT      : OUT STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);     -- IR2 reg output
            N_FLAG       : OUT STD_LOGIC;                                  -- Negative condition code flag ALU 
            Z_FLAG       : OUT STD_LOGIC;                                  -- Zero condition code flag ALU 
            C_FLAG       : OUT STD_LOGIC;                                  -- Carry condition code flag ALU 
            V_FLAG       : OUT STD_LOGIC                                   -- Overflow condition code flag ALU 
        );
    END COMPONENT;

    SIGNAL NPC_EXE2MEM : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
    SIGNAL ZOP_EXE2MEM : STD_LOGIC;
    SIGNAL ALU_EXE2MEM : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
    SIGNAL PAD_EXE2MEM : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
    SIGNAL IR_EXE2MEM  : STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);

    COMPONENT MEM_STAGE
        GENERIC
        (
            N_BITS_DATA : NATURAL := N_BITS_DATA; -- # of bits
            RF_ADDR     : NATURAL := RF_ADDR      -- # OF BITS FOR REGISTER FILE ADDRESS
        );
        PORT
        (
            -- Control ports 
            CLK           : IN STD_LOGIC;
            RST           : IN STD_LOGIC;
            MEM_OUTREG_EN : IN STD_LOGIC;
            ZERO_PADDING4 : IN STD_LOGIC;
            MEM_OUT_SEL   : IN STD_LOGIC; -- 0 sel sign extension output, otherwise data mem output	
            BYTE_LEN_IN   : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            DRAM_WE       : IN STD_LOGIC;
            DRAM_WE_OUT   : OUT STD_LOGIC;
            BYTE_LEN_OUT  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            -- Data ports
            BRA_IN            : IN STD_LOGIC;                                  -- BRA reg input (for jump selection)
            JUMP_MUX_IN_0     : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Input 0 of the multiplexer for jumping (NPC)
            ALU_OUTPUT_IN     : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
            MEM_DATA_IN       : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- input data of data memory
            MEM_DATA_OUT_INT  : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- input of sign extention module
            NPC_IN            : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
            IR_IN             : IN STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
            IR_OUT            : OUT STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
            NPC_OUT           : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
            MEM_ADDR_OUT      : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- address data memory (connected to alu output)
            MEM_DATA_IN_PRIME : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- input data of data memory
            ALU_OUTPUT_OUT    : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- output of register ALU_OUTPUT
            MEM_DATA_OUT      : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Output data from memory (after mux)
            ADDR_MUX_OUT      : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL NPC_MEM2WB : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
    SIGNAL MEM_MEM2WB : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
    SIGNAL ALU_MEM2WB : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);
    SIGNAL IR_MEM2WB  : STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);

    COMPONENT WB_STAGE IS
        GENERIC
        (
            N_BITS_DATA : NATURAL := NbitLong; -- # of bits
            RF_ADDR     : NATURAL := RF_ADDR
        );
        PORT
        (
            -- Control ports
            JAL_MUX_SEL : IN STD_LOGIC; -- 'Jal' Op Auxiliary Selector
            WB_MUX_SEL  : IN STD_LOGIC; -- Primary Outcome Selector
            -- Data ports
            IR_IN   : IN STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
            MUX_IN2 : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);  -- Mux Input #2 ("1-" -> NPC)
            MUX_IN1 : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);  -- Mux Input #1 ("01" -> MEM Out)
            MUX_IN0 : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);  -- Mux Input #0 ("00" -> ALU Out)
            MUX_OUT : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Mux Main Output
            IR_OUT  : OUT STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0)
        );
    END COMPONENT;

BEGIN
    FETCH : IF_STAGE
    GENERIC
    MAP (
    N_BITS_DATA  => N_BITS_DATA,
    N_BYTES_INST => N_BYTES_INST
    )
    PORT MAP
    (
        CLK         => CLK,
        RST         => RST,
        IF_LATCH_EN => IF_LATCH_EN,
        PC_IN       => PC_MEM2IF,
        IR_IN       => IR_IN,
        PC_OUT      => PC_OUT,
        IR_OUT      => IR_IF2ID,
        ADD_OUT     => NPC_IF2MEM,
        NPC_OUT     => NPC_IF2ID
    );

    DECODE : ID_STAGE
    GENERIC
    MAP (
    N_BITS_DATA  => N_BITS_DATA,
    N_BYTES_INST => NPC_GAP,
    RF_ADDR      => RF_ADDR,
    N_BITS_JUMP  => N_BITS_JUMP,
    N_BITS_IMM   => N_BITS_IMM
    )
    PORT
    MAP
    (
    CLK           => CLK,
    RST           => RST,
    JAL_MUX_SEL   => JAL_MUX_SEL,
    DEC_OUTREG_EN => DEC_OUTREG_EN,
    IS_I_TYPE     => IS_I_TYPE,
    RD1_EN        => RD1_EN,
    RD2_EN        => RD2_EN,
    WR_EN         => WR_EN,
    ZERO_PADDING2 => ZERO_PADDING2,
    I_CODE        => IR_IF2ID,
    NPC1_IN       => NPC_IF2ID,
    DATA_IN       => MUX_WB2ID,
    WR_ADDR_IN    => IR_WB2ID,
    REGA_OUT      => A_ID2EXE,
    REGB_OUT      => B_ID2EXE,
    REGIMM_OUT    => IMM_ID2EXE,
    WR_ADDR_OUT   => IR_ID2EXE,
    NPC1_OUT      => NPC_ID2EXE
    );

    EXECUTE : EXE_STAGE GENERIC
    MAP
    (
    N_BITS_DATA => N_BITS_DATA,
    RF_ADDR     => RF_ADDR
    )
    PORT
    MAP
    (
    CLK           => CLK,
    RST           => RST,
    MUXA_SEL      => MUXA_SEL,
    MUXB_SEL      => MUXB_SEL,
    EXE_OUTREG_EN => EXE_OUTREG_EN,
    EQ_COND       => EQ_COND,
    JUMP_EN       => JUMP_EN,
    ALU_OPCODE    => ALU_OPCODE,
    NPC2_IN       => NPC_ID2EXE,
    NPC1_MUXA_IN  => NPC_ID2EXE,
    REGA_MUXA_IN  => A_ID2EXE,
    REGB_MUXB_IN  => B_ID2EXE,
    IMM_MUXB_IN   => IMM_ID2EXE,
    PAD_IN        => B_ID2EXE,
    IR2_IN        => IR_ID2EXE,
    NPC2_OUT      => NPC_EXE2MEM,
    ZERO_OP_OUT   => ZOP_EXE2MEM,
    ALU_OUT       => ALU_EXE2MEM,
    PAD_OUT       => PAD_EXE2MEM,
    IR2_OUT       => IR_EXE2MEM,
    N_FLAG        => N,
    Z_FLAG        => Z,
    C_FLAG        => C,
    V_FLAG        => V
    );

    MEMORY : MEM_STAGE
    GENERIC
    MAP (
    N_BITS_DATA => N_BITS_DATA,
    RF_ADDR     => RF_ADDR
    )
    PORT
    MAP
    (
    CLK               => CLK,
    RST               => RST,
    MEM_OUTREG_EN     => MEM_OUTREG_EN,
    ZERO_PADDING4     => ZERO_PADDING4,
    MEM_OUT_SEL       => MEM_OUT_SEL,
    BYTE_LEN_IN       => BYTE_LEN_IN,
    DRAM_WE           => DRAM_WE,
    DRAM_WE_OUT       => DRAM_WE_OUT,
    BYTE_LEN_OUT      => BYTE_LEN_OUT,
    BRA_IN            => ZOP_EXE2MEM,
    JUMP_MUX_IN_0     => NPC_IF2MEM,
    ALU_OUTPUT_IN     => ALU_EXE2MEM,
    MEM_DATA_IN       => PAD_EXE2MEM,
    MEM_DATA_OUT_INT  => MEM_DATA_OUT_INT,
    NPC_IN            => NPC_EXE2MEM,
    IR_IN             => IR_EXE2MEM,
    IR_OUT            => IR_MEM2WB,
    NPC_OUT           => NPC_MEM2WB,
    MEM_ADDR_OUT      => MEM_ADDR_OUT,
    MEM_DATA_IN_PRIME => MEM_DATA_IN_PRIME,
    ALU_OUTPUT_OUT    => ALU_MEM2WB,
    MEM_DATA_OUT      => MEM_MEM2WB,
    ADDR_MUX_OUT      => PC_MEM2IF
    );

    WRITE_BACK : WB_STAGE
    GENERIC
    MAP (
    N_BITS_DATA => N_BITS_DATA,
    RF_ADDR     => RF_ADDR
    )
    PORT
    MAP
    (
    JAL_MUX_SEL => JAL_MUX_SEL,
    WB_MUX_SEL  => WB_MUX_SEL,
    IR_IN       => IR_MEM2WB,
    MUX_IN2     => NPC_MEM2WB,
    MUX_IN1     => MEM_MEM2WB,
    MUX_IN0     => ALU_MEM2WB,
    MUX_OUT     => MUX_WB2ID,
    IR_OUT      => IR_WB2ID
    );
END PIPELINED;