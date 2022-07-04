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
            N_IN0 : NATURAL := NbitJump;
            N_IN1 : NATURAL := NbitShort;
            N_OUT : NATURAL := NbitLong
        );
        PORT
        (
            ctrl_in  : IN STD_LOGIC;
            data_in  : IN STD_LOGIC_VECTOR(N_IN0 - 1 DOWNTO 0);
            data_ext : OUT STD_LOGIC_VECTOR(N_OUT - 1 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL CTRL_IN  : STD_LOGIC;
    SIGNAL DATA_IN  : STD_LOGIC_VECTOR(NbitJump - 1 DOWNTO 0);
    SIGNAL DATA_EXT : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);

BEGIN
    dut : sign_ext GENERIC
    MAP (NbitJump, NbitShort, NbitLong) PORT MAP
    (CTRL_IN, DATA_IN, DATA_EXT);

    CTRL_IN <= '0', '1' AFTER Tclk;
    DATA_IN <= (NbitJump - NbitShort - 1 DOWNTO 0 => '0') & (NbitShort - 1 DOWNTO 0 => '1');
END test;