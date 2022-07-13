LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_CU_HW IS
END TB_CU_HW;

ARCHITECTURE TEST OF TB_CU_HW IS
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
            IF_LATCH_EN : OUT STD_LOGIC; -- (PC, IR, NPC0, NPCA, NPCB) Registers Enable

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
            MEM_OUTREG_EN : OUT STD_LOGIC; -- (NPC3, IR3, BRA, ALU2MEM, OP2MEM) Registers Enable
            ZERO_PADDING4 : OUT STD_LOGIC; -- Choose Zero Padding over normal Sign Extension
            MEM_OUT_SEL   : OUT STD_LOGIC; -- Memory Output Mux Selector
            -- EXTERNAL MEMORY
            DRAM_WE  : OUT STD_LOGIC;                    -- Data RAM Write Enable
            BYTE_LEN : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- Memory Output Modifier

            -- PIPE STAGE #5: WB
            WB_MUX_SEL  : OUT STD_LOGIC; -- Write Back MUX Sel
            JAL_MUX_SEL : OUT STD_LOGIC; -- Jump And Link RF OR/Mux Selector
            WR_EN       : OUT STD_LOGIC  -- Register File Write Enable
        );
    END COMPONENT;

    -- expected codings (unimplemented/invalid -> nop)
    TYPE MICRO_MEM IS ARRAY (0 TO MICRO_N - 1) OF STD_LOGIC_VECTOR(CW_N - 1 DOWNTO 0);
    CONSTANT cw_code_tb : MICRO_MEM := (
        "11000000100100000000",
        "11000000100100000000",
        "11000001111100000000",
        "11000001111100000111",
        "11110001111100000000",
        "11110001101100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11110011100100000001",
        "11110111100100000001",
        "11110011100100000001",
        "11110111100100000001",
        "11110111100100000001",
        "11110111100100000001",
        "11110111100100000001",
        "11110111100100000001",
        "11000000100100000000",
        "11000000100100000000",
        "11001010111100000000",
        "11001010111100000011",
        "11110111100100000001",
        "11000000100100000000", -- nop
        "11110111100100000001",
        "11110111100100000001",
        "11110011100100000001",
        "11110011100100000001",
        "11110011100100000001",
        "11110011100100000001",
        "11110011100100000001",
        "11110011100100000001",
        "11000000100100000000",
        "11000000100100000000",
        "11110011100100000101",
        "11110011100100001101",
        "11000000100100000000",
        "11110011100101011101",
        "11110011100110000101",
        "11110011100110001101",
        "11000000100100000000",
        "11000000100100000000",
        "11111011100100100000",
        "11111011100100101000",
        "11000000100100000000",
        "11111011100100111000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11110111100100000001",
        "11110111100100000001",
        "11110111100100000001",
        "11110111100100000001",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11011010100100000001",
        "11000000100100000000",
        "11011010100100000001",
        "11011010100100000001",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11011010100100000001",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11011010100100000001",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11011010100100000001",
        "11011010100100000001",
        "11011010100100000001",
        "11011010100100000001",
        "11011110100100000001",
        "11011110100100000001",
        "11011110100100000001",
        "11000000100100000000",
        "11011010100100000001",
        "11011010100100000001",
        "11011010100100000001",
        "11011010100100000001",
        "11011010100100000001",
        "11011010100100000001",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11011010100100000001",
        "11011010100100000001",
        "11011010100100000001",
        "11011010100100000001",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000",
        "11000000100100000000"
    );

    -- expected ALU Ops
    TYPE ALU_MEM IS ARRAY (0 TO 121) OF ALU_MSG;
    CONSTANT ALU_MSG_tb : ALU_MEM := (
        -- I/J-Type
        J_j,
        J_jal,
        I_beqz,
        I_bnez,
        I_bfpt,
        I_bfpf,
        I_addi,
        I_addui,
        I_subi,
        I_subui,
        I_andi,
        I_ori,
        I_xori,
        I_lhi,
        J_rfe,
        J_trap,
        I_jr,
        I_jalr,
        I_slli,
        I_nop,
        I_srli,
        I_srai,
        I_seqi,
        I_snei,
        I_slti,
        I_sgti,
        I_slei,
        I_sgei,
        nop,
        nop,
        I_lb,
        I_lh,
        nop,
        I_lw,
        I_lbu,
        I_lhu,
        I_lf,
        I_ld,
        I_sb,
        I_sh,
        nop,
        I_sw,
        nop,
        nop,
        I_sf,
        I_sd,
        nop,
        nop,
        nop,
        nop,
        nop,
        nop,
        nop,
        nop,
        I_itlb,
        nop,
        I_sltui,
        I_sgtui,
        I_sleui,
        I_sgeui,
        -- R-Type
        nop,
        nop,
        nop,
        nop,
        R_sll,
        nop,
        R_srl,
        R_sra,
        nop,
        nop,
        nop,
        nop,
        nop,
        nop,
        R_mult,
        nop,
        nop,
        nop,
        nop,
        nop,
        nop,
        nop,
        R_multu,
        nop,
        nop,
        nop,
        nop,
        nop,
        nop,
        nop,
        nop,
        nop,
        R_add,
        R_addu,
        R_sub,
        R_subu,
        R_and,
        R_or,
        R_xor,
        nop,
        R_seq,
        R_sne,
        R_slt,
        R_sgt,
        R_sle,
        R_sge,
        nop,
        nop,
        R_movi2s,
        R_movs2i,
        R_movf,
        R_movd,
        R_movfp2i,
        R_movi2fp,
        R_movi2t,
        R_movt2i,
        nop,
        nop,
        R_sltu,
        R_sgtu,
        R_sleu,
        R_sgeu
    );

    -- expected FPU Ops
    TYPE FPU_MEM IS ARRAY (0 TO 29) OF FPU_MSG;
    CONSTANT FPU_MSG_tb : FPU_MEM := (
        -- FP
        addf,
        subf,
        multf,
        divf,
        addd,
        subd,
        multd,
        divd,
        cvtf2d,
        cvtf2i,
        cvtd2f,
        cvtd2i,
        cvti2f,
        cvti2d,
        mult,
        div,
        eqf,
        nef,
        ltf,
        gtf,
        lef,
        gef,
        multu,
        divu,
        eqd,
        ned,
        ltd,
        gtd,
        led,
        ged
    );

    -- I/O of the CU component
    SIGNAL Clk_tb           : STD_LOGIC;
    SIGNAL Rst_tb           : STD_LOGIC;
    SIGNAL IR_IN_tb         : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
    SIGNAL IF_LATCH_EN_tb   : STD_LOGIC;
    SIGNAL DEC_OUTREG_EN_tb : STD_LOGIC;
    SIGNAL IS_I_TYPE_tb     : STD_LOGIC;
    SIGNAL RD1_EN_tb        : STD_LOGIC;
    SIGNAL RD2_EN_tb        : STD_LOGIC;
    SIGNAL ZERO_PADDING2_tb : STD_LOGIC;
    SIGNAL MUXA_SEL_tb      : STD_LOGIC;
    SIGNAL MUXB_SEL_tb      : STD_LOGIC;
    SIGNAL EXE_OUTREG_EN_tb : STD_LOGIC;
    SIGNAL EQ_COND_tb       : STD_LOGIC;
    SIGNAL JUMP_EN_tb       : STD_LOGIC;
    SIGNAL ALU_OPCODE_tb    : ALU_MSG;
    SIGNAL FPU_OPCODE_tb    : FPU_MSG;
    SIGNAL MEM_OUTREG_EN_tb : STD_LOGIC;
    SIGNAL ZERO_PADDING4_tb : STD_LOGIC;
    SIGNAL MEM_OUT_SEL_tb   : STD_LOGIC;
    SIGNAL DRAM_WE_tb       : STD_LOGIC;
    SIGNAL BYTE_LEN_tb      : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL WB_MUX_SEL_tb    : STD_LOGIC;
    SIGNAL JAL_MUX_SEL_tb   : STD_LOGIC;
    SIGNAL WR_EN_tb         : STD_LOGIC;

    -- control words handling
    SIGNAL IR_opcode_tb  : STD_LOGIC_VECTOR(OPCODE_N - 1 DOWNTO 0);
    SIGNAL int_opcode_tb : NATURAL;
    SIGNAL IR_func_tb    : STD_LOGIC_VECTOR(FUNC_N - 1 DOWNTO 0);
    SIGNAL int_func_tb   : NATURAL;

    -- outputs to every pipeline stage
    SIGNAL IF_STAGE_tb  : STD_LOGIC;
    SIGNAL ID_STAGE_tb  : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL EXE_STAGE_tb : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL MEM_STAGE_tb : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL WB_STAGE_tb  : STD_LOGIC_VECTOR(2 DOWNTO 0);

BEGIN
    DUT : CU_HW GENERIC
    MAP (
    MICRO_SIZE  => MICRO_N,
    FUNC_SIZE   => FUNC_N,
    OPCODE_SIZE => OPCODE_N,
    IR_SIZE     => NbitLong,
    CW_SIZE     => CW_N
    )
    PORT MAP
    (
        Clk           => Clk_tb,
        Rst           => Rst_tb,
        IR_IN         => IR_IN_tb,
        IF_LATCH_EN   => IF_LATCH_EN_tb,
        DEC_OUTREG_EN => DEC_OUTREG_EN_tb,
        IS_I_TYPE     => IS_I_TYPE_tb,
        RD1_EN        => RD1_EN_tb,
        RD2_EN        => RD2_EN_tb,
        ZERO_PADDING2 => ZERO_PADDING2_tb,
        MUXA_SEL      => MUXA_SEL_tb,
        MUXB_SEL      => MUXB_SEL_tb,
        EXE_OUTREG_EN => EXE_OUTREG_EN_tb,
        EQ_COND       => EQ_COND_tb,
        JUMP_EN       => JUMP_EN_tb,
        ALU_OPCODE    => ALU_OPCODE_tb,
        FPU_OPCODE    => FPU_OPCODE_tb,
        MEM_OUTREG_EN => MEM_OUTREG_EN_tb,
        ZERO_PADDING4 => ZERO_PADDING4_tb,
        MEM_OUT_SEL   => MEM_OUT_SEL_tb,
        DRAM_WE       => DRAM_WE_tb,
        BYTE_LEN      => BYTE_LEN_tb,
        WB_MUX_SEL    => WB_MUX_SEL_tb,
        JAL_MUX_SEL   => JAL_MUX_SEL_tb,
        WR_EN         => WR_EN_tb
    );

    -- recreate control word from counters
    IR_opcode_tb <= STD_LOGIC_VECTOR(TO_UNSIGNED(int_opcode_tb, IR_opcode_tb'LENGTH));
    IR_func_tb   <= STD_LOGIC_VECTOR(TO_UNSIGNED(int_func_tb, IR_func_tb'LENGTH));
    IR_IN_tb     <= IR_opcode_tb & (NbitLong - OPCODE_N - 1 DOWNTO FUNC_N => '0') & IR_func_tb;

    -- assign control words to controls
    IF_STAGE_tb  <= IF_LATCH_EN_tb;
    ID_STAGE_tb  <= DEC_OUTREG_EN_tb & IS_I_TYPE_tb & RD1_EN_tb & RD2_EN_tb & ZERO_PADDING2_tb;
    EXE_STAGE_tb <= MUXA_SEL_tb & MUXB_SEL_tb & EXE_OUTREG_EN_tb & EQ_COND_tb & JUMP_EN_tb;
    MEM_STAGE_tb <= MEM_OUTREG_EN_tb & ZERO_PADDING4_tb & MEM_OUT_SEL_tb & DRAM_WE_tb & BYTE_LEN_tb;
    WB_STAGE_tb  <= WB_MUX_SEL_tb & JAL_MUX_SEL_tb & WR_EN_tb;

    CONTROL : PROCESS IS
    BEGIN
        REPORT("Starting simulation");
        Rst_tb        <= '0';
        int_opcode_tb <= 0;
        int_func_tb   <= 0;
        WAIT UNTIL falling_edge(Clk_tb);
        Rst_tb <= '1';

        REPORT("TEST 1: R-Type Ops");
        FOR i IN 0 TO 16#41# LOOP
            int_func_tb <= i;
            WAIT UNTIL falling_edge(Clk_tb);
            IF (i <= 16#3D#) THEN
                ASSERT (IF_STAGE_tb = cw_code_tb(i + 16#3E#)(CW_N - 1))
                REPORT "Control error inside pipe stage one."
                    SEVERITY failure;
            ELSE
                ASSERT (IF_STAGE_tb = cw_code_tb(16#15#)(CW_N - 1))
                REPORT "Control error inside pipe stage one."
                    SEVERITY failure;
            END IF;
            IF (i = 0) THEN
                ASSERT (ID_STAGE_tb = (ID_STAGE_tb'RANGE => '0'))
                REPORT "Control error inside pipe stage two."
                    SEVERITY failure;
            ELSIF (i <= 16#3E#) THEN
                ASSERT (ID_STAGE_tb = cw_code_tb(i + 16#3D#)(CW_N - 2 DOWNTO CW_N - 6))
                REPORT "Control error inside pipe stage two."
                    SEVERITY failure;
            ELSE
                ASSERT (ID_STAGE_tb = cw_code_tb(16#15#)(CW_N - 2 DOWNTO CW_N - 6))
                REPORT "Control error inside pipe stage two."
                    SEVERITY failure;
            END IF;
            IF (i <= 1) THEN
                ASSERT (EXE_STAGE_tb = (EXE_STAGE_tb'RANGE => '0'))
                REPORT "Control error inside pipe stage three."
                    SEVERITY failure;
                ASSERT (ALU_OPCODE_tb = nop)
                REPORT "Wrong arithmetic/logic operation selection."
                    SEVERITY failure;
            ELSIF (i <= 16#3F#) THEN
                ASSERT (EXE_STAGE_tb = cw_code_tb(i + 16#3C#)(CW_N - 7 DOWNTO CW_N - 11))
                REPORT "Control error inside pipe stage three."
                    SEVERITY failure;
                ASSERT (ALU_OPCODE_tb = ALU_MSG_tb(i + 16#3A#))
                REPORT "Wrong arithmetic/logic operation selection."
                    SEVERITY failure;
            ELSE
                ASSERT (EXE_STAGE_tb = cw_code_tb(16#15#)(CW_N - 7 DOWNTO CW_N - 11))
                REPORT "Control error inside pipe stage three."
                    SEVERITY failure;
                ASSERT (ALU_OPCODE_tb = nop)
                REPORT "Wrong arithmetic/logic operation selection."
                    SEVERITY failure;
            END IF;
            IF (i <= 2) THEN
                ASSERT (MEM_STAGE_tb = (MEM_STAGE_tb'RANGE => '0'))
                REPORT "Control error inside pipe stage four."
                    SEVERITY failure;
            ELSIF (i <= 16#40#) THEN
                ASSERT (MEM_STAGE_tb = cw_code_tb(i + 16#3B#)(CW_N - 12 DOWNTO CW_N - 17))
                REPORT "Control error inside pipe stage four."
                    SEVERITY failure;
            ELSE
                ASSERT (MEM_STAGE_tb = cw_code_tb(16#15#)(CW_N - 12 DOWNTO CW_N - 17))
                REPORT "Control error inside pipe stage four."
                    SEVERITY failure;
            END IF;
            IF (i <= 3) THEN
                ASSERT (WB_STAGE_tb = (WB_STAGE_tb'RANGE => '0'))
                REPORT "Control error inside pipe stage five."
                    SEVERITY failure;
            ELSE
                ASSERT (WB_STAGE_tb = cw_code_tb(i + 16#3A#)(CW_N - 18 DOWNTO CW_N - 20))
                REPORT "Control error inside pipe stage five."
                    SEVERITY failure;
            END IF;
        END LOOP;
        REPORT("TEST 1 result: SUCCESSFUL");

        REPORT("TEST 2: I/J-Type Ops");
        FOR i IN 2 TO 16#41# LOOP
            int_opcode_tb <= i;
            WAIT UNTIL falling_edge(Clk_tb);
            IF (i <= 16#3D#) THEN
                ASSERT (IF_STAGE_tb = cw_code_tb(i)(CW_N - 1))
                REPORT "Control error inside pipe stage one."
                    SEVERITY failure;
            ELSE
                ASSERT (IF_STAGE_tb = cw_code_tb(16#15#)(CW_N - 1))
                REPORT "Control error inside pipe stage one."
                    SEVERITY failure;
            END IF;
            IF (i > 2 AND i <= 16#3E#) THEN
                ASSERT (ID_STAGE_tb = cw_code_tb(i - 1)(CW_N - 2 DOWNTO CW_N - 6))
                REPORT "Control error inside pipe stage two."
                    SEVERITY failure;
            ELSE
                ASSERT (ID_STAGE_tb = cw_code_tb(16#15#)(CW_N - 2 DOWNTO CW_N - 6))
                REPORT "Control error inside pipe stage two."
                    SEVERITY failure;
            END IF;
            IF (i > 3 AND i <= 16#3F#) THEN
                ASSERT (EXE_STAGE_tb = cw_code_tb(i - 2)(CW_N - 7 DOWNTO CW_N - 11))
                REPORT "Control error inside pipe stage three."
                    SEVERITY failure;
                ASSERT (ALU_OPCODE_tb = ALU_MSG_tb(i - 4))
                REPORT "Wrong arithmetic/logic operation selection."
                    SEVERITY failure;
            ELSE
                ASSERT (EXE_STAGE_tb = cw_code_tb(16#15#)(CW_N - 7 DOWNTO CW_N - 11))
                REPORT "Control error inside pipe stage three."
                    SEVERITY failure;
                ASSERT (ALU_OPCODE_tb = nop)
                REPORT "Wrong arithmetic/logic operation selection."
                    SEVERITY failure;
            END IF;
            IF (i > 4 AND i <= 16#40#) THEN
                ASSERT (MEM_STAGE_tb = cw_code_tb(i - 3)(CW_N - 12 DOWNTO CW_N - 17))
                REPORT "Control error inside pipe stage four."
                    SEVERITY failure;
            ELSE
                ASSERT (MEM_STAGE_tb = cw_code_tb(16#15#)(CW_N - 12 DOWNTO CW_N - 17))
                REPORT "Control error inside pipe stage four."
                    SEVERITY failure;
            END IF;
            IF (i > 5) THEN
                ASSERT (WB_STAGE_tb = cw_code_tb(i - 4)(CW_N - 18 DOWNTO CW_N - 20))
                REPORT "Control error inside pipe stage five."
                    SEVERITY failure;
            ELSE
                ASSERT (WB_STAGE_tb = cw_code_tb(16#15#)(CW_N - 18 DOWNTO CW_N - 20))
                REPORT "Control error inside pipe stage five."
                    SEVERITY failure;
            END IF;
        END LOOP;
        REPORT("TEST 2 result: SUCCESSFUL");

        REPORT("TEST 3: FP Ops");
        int_opcode_tb <= 1;
        FOR i IN 0 TO 16#21# LOOP
            int_func_tb <= i;
            WAIT UNTIL falling_edge(Clk_tb);
            IF (i <= 16#1D#) THEN
                ASSERT (IF_STAGE_tb = cw_code_tb(i + 16#7C#)(CW_N - 1))
                REPORT "Control error inside pipe stage one."
                    SEVERITY failure;
            ELSE
                ASSERT (IF_STAGE_tb = cw_code_tb(16#15#)(CW_N - 1))
                REPORT "Control error inside pipe stage one."
                    SEVERITY failure;
            END IF;
            IF (i > 0 AND i <= 16#1E#) THEN
                ASSERT (ID_STAGE_tb = cw_code_tb(i + 16#7B#)(CW_N - 2 DOWNTO CW_N - 6))
                REPORT "Control error inside pipe stage two."
                    SEVERITY failure;
            ELSE
                ASSERT (ID_STAGE_tb = cw_code_tb(16#15#)(CW_N - 2 DOWNTO CW_N - 6))
                REPORT "Control error inside pipe stage two."
                    SEVERITY failure;
            END IF;
            IF (i > 1 AND i <= 16#1F#) THEN
                ASSERT (EXE_STAGE_tb = cw_code_tb(i + 16#7A#)(CW_N - 7 DOWNTO CW_N - 11))
                REPORT "Control error inside pipe stage three."
                    SEVERITY failure;

                ASSERT (FPU_OPCODE_tb = FPU_MSG_tb(i - 2))
                REPORT "Wrong floating point operation selection."
                    SEVERITY failure;
            ELSE
                ASSERT (EXE_STAGE_tb = cw_code_tb(16#15#)(CW_N - 7 DOWNTO CW_N - 11))
                REPORT "Control error inside pipe stage three."
                    SEVERITY failure;

                ASSERT (FPU_OPCODE_tb = nop)
                REPORT "Wrong floating point operation selection."
                    SEVERITY failure;
            END IF;
            IF (i > 2 AND i <= 16#20#) THEN
                ASSERT (MEM_STAGE_tb = cw_code_tb(i + 16#79#)(CW_N - 12 DOWNTO CW_N - 17))
                REPORT "Control error inside pipe stage four."
                    SEVERITY failure;
            ELSE
                ASSERT (MEM_STAGE_tb = cw_code_tb(16#15#)(CW_N - 12 DOWNTO CW_N - 17))
                REPORT "Control error inside pipe stage four."
                    SEVERITY failure;
            END IF;
            IF (i > 3) THEN
                ASSERT (WB_STAGE_tb = cw_code_tb(i + 16#78#)(CW_N - 18 DOWNTO CW_N - 20))
                REPORT "Control error inside pipe stage five."
                    SEVERITY failure;
            ELSE
                ASSERT (WB_STAGE_tb = cw_code_tb(16#15#)(CW_N - 18 DOWNTO CW_N - 20))
                REPORT "Control error inside pipe stage five."
                    SEVERITY failure;
            END IF;
        END LOOP;
        REPORT("TEST 3 result: SUCCESSFUL");

        REPORT("End simulation");
        WAIT;
    END PROCESS CONTROL;

    CLOCK : PROCESS IS
    BEGIN
        Clk_tb <= '0';
        WAIT FOR Tclk / 2;
        Clk_tb <= '1';
        WAIT FOR Tclk / 2;
    END PROCESS CLOCK;
END TEST;