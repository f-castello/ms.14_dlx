LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.dlx_utils.ALL;

ENTITY sign_ext IS
    GENERIC
    (
        N_IN  : NATURAL := NbitShort; -- input # of bits
        N_OUT : NATURAL := NbitShort  -- output # of bits
    );
    PORT
    (
        data_in  : IN STD_LOGIC_VECTOR(N_IN - 1 DOWNTO 0);
        data_ext : OUT STD_LOGIC_VECTOR(N_OUT - 1 DOWNTO 0)
    );
END sign_ext;

ARCHITECTURE datafl OF sign_ext IS
BEGIN
    data_ext <=                                      -- signed output
        (N_OUT - N_IN - 1 DOWNTO 0 => data_in(N_IN - 1)) -- extended MSB
        & data_in;                                       -- original data
END datafl;