LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.dlx_utils.ALL;

ENTITY sign_ext IS
    GENERIC
    (
        N_IN0 : NATURAL := NbitShort; -- first input # of bits (must be greater than N_IN1): half word in this case
        N_IN1 : NATURAL := NbitByte;  -- second input # of bits (reduced size): byte in this case
        N_OUT : NATURAL := NbitLong   -- unique output # of bits (must be greater than both input sizes): word size in this case
    );
    PORT
    (
        ctrl_in      : IN STD_LOGIC;
        zero_padding : IN STD_LOGIC;
        data_in      : IN STD_LOGIC_VECTOR(N_IN0 - 1 DOWNTO 0);
        data_ext     : OUT STD_LOGIC_VECTOR(N_OUT - 1 DOWNTO 0)
    );
END sign_ext;

ARCHITECTURE datafl OF sign_ext IS
BEGIN
    data_ext <=
        (N_OUT - N_IN1 - 1 DOWNTO 0 => data_in(N_IN1 - 1)) & data_in(N_IN1 - 1 DOWNTO 0) -- sign extension BYTE
        WHEN (ctrl_in = '0' AND zero_padding = '0')
        ELSE
        (N_OUT - N_IN1 - 1 DOWNTO 0 => '0') & data_in(N_IN1 - 1 DOWNTO 0) -- zero padding BYTE
        WHEN (ctrl_in = '0' AND zero_padding = '1')
        ELSE
        (N_OUT - N_IN0 - 1 DOWNTO 0 => data_in(N_IN0 - 1)) & data_in -- sign extension HALF-WORD
        WHEN (ctrl_in = '1' AND zero_padding = '0')
        ELSE
        (N_OUT - N_IN0 - 1 DOWNTO 0 => '0') & data_in; -- sign extension actual MSB
END datafl;