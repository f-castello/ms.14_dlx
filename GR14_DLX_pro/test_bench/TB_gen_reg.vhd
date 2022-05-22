LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_gen_reg IS
END TB_gen_reg;

ARCHITECTURE test OF TB_gen_reg IS
    COMPONENT gen_reg
        GENERIC
        (
            N : NATURAL := NbitLong
        );
        PORT
        (
            clk, rst, ld : IN STD_LOGIC;
            data_in      : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            data_out     : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
        );
    END COMPONENT;

    CONSTANT T : TIME := Tclk;

    SIGNAL CLK, RST, LD      : STD_LOGIC;
    SIGNAL DATA_IN, DATA_OUT : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);

BEGIN

    dut : gen_reg GENERIC
    MAP (NbitLong) PORT MAP
    (CLK, RST, LD, DATA_IN, DATA_OUT);

    CLOCK : PROCESS IS
    BEGIN
        CLK <= '0';
        WAIT FOR T / 2;
        CLK <= '1';
        WAIT FOR T / 2;
    END PROCESS CLOCK;

    I_O : PROCESS IS
    BEGIN
        RST     <= '0';
        LD      <= '0';
        DATA_IN <= (OTHERS => '0');
        WAIT FOR T / 2;
        RST <= '1';
        WAIT FOR T;
        LD <= '1';
        FOR i IN 0 TO NPC_GAP LOOP
            WAIT FOR T;
            DATA_IN <= DATA_IN + '1';
        END LOOP;
        WAIT FOR T / 2;
        LD <= '0';
        WAIT FOR T / 2;
        DATA_IN <= DATA_IN + '1';
        WAIT FOR 2 * T;
        LD <= '1';
        WAIT FOR T;
        RST <= '0';
        LD  <= '0';
        WAIT;
    END PROCESS I_O;
END test;