LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_sign_ext IS
END TB_sign_ext;

ARCHITECTURE test OF TB_sign_ext IS
    COMPONENT sign_ext
        GENERIC
        (
            N_IN  : NATURAL := NbitShort;
            N_OUT : NATURAL := NbitShort
        );
        PORT
        (
            data_in  : IN STD_LOGIC_VECTOR(N_IN - 1 DOWNTO 0);
            data_ext : OUT STD_LOGIC_VECTOR(N_OUT - 1 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL DATA_IN  : STD_LOGIC_VECTOR(NbitShort - 1 DOWNTO 0);
    SIGNAL DATA_EXT : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);

BEGIN
    dut : sign_ext GENERIC
    MAP (NbitShort, NbitLong) PORT MAP
    (DATA_IN, DATA_EXT);

    DATA_IN <= (OTHERS => '0'), (OTHERS => '1') AFTER Tclk;
END test;