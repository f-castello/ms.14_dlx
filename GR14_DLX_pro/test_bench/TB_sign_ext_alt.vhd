LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_sign_ext_alt IS
END TB_sign_ext_alt;

ARCHITECTURE test OF TB_sign_ext_alt IS
    COMPONENT sign_ext_alt
        GENERIC
        (
            N_IN0 : NATURAL := NbitShort;
            N_IN1 : NATURAL := NbitByte;
            N_OUT : NATURAL := NbitLong
        );
        PORT
        (
            ctrl_in      : IN STD_LOGIC;
            zero_padding : IN STD_LOGIC;
            data_in      : IN STD_LOGIC_VECTOR(N_IN0 - 1 DOWNTO 0);
            data_ext     : OUT STD_LOGIC_VECTOR(N_OUT - 1 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL CTRL_IN      : STD_LOGIC;
    SIGNAL ZERO_PADDING : STD_LOGIC;
    SIGNAL DATA_IN      : STD_LOGIC_VECTOR(NbitShort - 1 DOWNTO 0);
    SIGNAL DATA_EXT     : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);

BEGIN
    dut : sign_ext_alt GENERIC
    MAP (NbitShort, NbitByte, NbitLong) PORT MAP
    (CTRL_IN, ZERO_PADDING, DATA_IN, DATA_EXT);

    CTRL_IN      <= '0', '1' AFTER 2 * Tclk;
    ZERO_PADDING <= '0', '1' AFTER Tclk, '0' AFTER 2 * Tclk, '1' AFTER 3 * Tclk;
    DATA_IN      <= (NbitShort - NbitByte - 1 DOWNTO 0 => '1') & (NbitByte - 1 DOWNTO 0 => '0');
END test;