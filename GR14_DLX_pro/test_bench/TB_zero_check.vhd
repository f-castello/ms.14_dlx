LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_zero_check IS
END TB_zero_check;

ARCHITECTURE test OF TB_zero_check IS
    COMPONENT zero_check
        GENERIC
        (
            N : NATURAL := NbitLong
        );
        PORT
        (
            data_in  : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            ctrl_out : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL DATA_IN  : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);
    SIGNAL CTRL_OUT : STD_LOGIC;

BEGIN
    dut : zero_check GENERIC
    MAP (NbitLong) PORT MAP
    (DATA_IN, CTRL_OUT);

    DATA_IN <= (OTHERS => '1'), (OTHERS => '0') AFTER Tclk;
END test;