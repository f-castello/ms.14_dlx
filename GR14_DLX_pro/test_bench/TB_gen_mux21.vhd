LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_gen_mux21 IS
END TB_gen_mux21;

ARCHITECTURE test OF TB_gen_mux21 IS
    COMPONENT gen_mux21
        GENERIC
        (
            N : NATURAL := NbitLong
        );
        PORT
        (
            sel  : IN STD_LOGIC;
            x, y : IN STD_LOGIC_VECTOR(0 TO N - 1);
            m    : OUT STD_LOGIC_VECTOR(0 TO N - 1)
        );
    END COMPONENT;

    SIGNAL SEL     : STD_LOGIC;
    SIGNAL X, Y, M : STD_LOGIC_VECTOR(0 TO NbitLong - 1);

BEGIN
    dut : gen_mux21 GENERIC
    MAP (NbitLong) PORT MAP
    (SEL, X, Y, M);

    SEL <= '0', '1' AFTER Tclk;
    X   <= (OTHERS => '0');
    Y   <= (OTHERS => '1');
END test;