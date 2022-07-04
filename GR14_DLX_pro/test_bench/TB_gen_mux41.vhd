LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_gen_mux41 IS
END TB_gen_mux41;

ARCHITECTURE test OF TB_gen_mux41 IS
    COMPONENT gen_mux41
        GENERIC
        (
            N : NATURAL := NbitLong
        );
        PORT
        (
            sel        : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            w, x, y, z : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            m          : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL SEL           : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL W, X, Y, Z, M : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);

BEGIN
    dut : gen_mux41 GENERIC
    MAP (NbitLong) PORT MAP
    (SEL, W, X, Y, Z, M);

    SEL <= "00", "01" AFTER Tclk, "10" AFTER 2 * Tclk, "11" AFTER 3 * Tclk;
    W   <= (OTHERS => '0');
    X   <= W + '1';
    Y   <= X + '1';
    Z   <= Y + '1';
END test;