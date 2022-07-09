LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE dlx_utils IS
    -- Constant generics
    CONSTANT NbitOne   : NATURAL := 1;
    CONSTANT NbitByte  : NATURAL := 8;
    CONSTANT NbitShort : NATURAL := 16;
    CONSTANT NbitJump  : NATURAL := 26;
    CONSTANT NbitLong  : NATURAL := 32;
    CONSTANT RF_ADDR   : NATURAL := 5;
    CONSTANT NPC_GAP   : NATURAL := 4;
    CONSTANT MICRO_N   : NATURAL := 150;
    CONSTANT FUNC_N    : NATURAL := 11;
    CONSTANT OPCODE_N  : NATURAL := 6;
    CONSTANT CW_N      : NATURAL := 25;
    CONSTANT Tclk      : TIME    := 2 ns;

    -- Custom types
    TYPE ALU_MSG IS (
        R_sll,
        R_srl,
        R_sra,
        R_add,
        R_addu,
        R_sub,
        R_subu,
        R_and,
        R_or,
        R_xor,
        R_seq,
        R_sne,
        R_slt,
        R_sgt,
        R_sle,
        R_sge,
        R_movi2s,
        R_movs2i,
        R_movf,
        R_movd,
        R_movfp2i,
        R_movi2fp,
        R_movi2t,
        R_movt2i,
        R_sltu,
        R_sgtu,
        R_sleu,
        R_sgeu,
        R_mult,
        R_multu,
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
        I_lb,
        I_lh,
        I_lw,
        I_lbu,
        I_lhu,
        I_lf,
        I_ld,
        I_sb,
        I_sh,
        I_sw,
        I_sf,
        I_sd,
        I_itlb,
        I_sltui,
        I_sgtui,
        I_sleui,
        I_sgeui,
        nop
    );
    TYPE FPU_MSG IS (
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
        ged,
        nop
    );
END dlx_utils;