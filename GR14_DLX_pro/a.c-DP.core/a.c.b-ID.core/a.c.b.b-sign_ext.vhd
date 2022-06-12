LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.dlx_utils.ALL;

ENTITY sign_ext IS
    GENERIC
    (
        N_IN0 : NATURAL := NbitJump;  -- first input # of bits (must be greater than N_IN1)
        N_IN1 : NATURAL := NbitShort; -- second input # of bits (reduced size)
        N_OUT : NATURAL := NbitLong   -- unique output # of bits (must be greater than both input sizes)
    );
    PORT
    (
        ctrl_in  : IN STD_LOGIC;
        data_in  : IN STD_LOGIC_VECTOR(0 TO N_IN0 - 1);
        data_ext : OUT STD_LOGIC_VECTOR(0 TO N_OUT - 1)
    );
END sign_ext;

ARCHITECTURE datafl OF sign_ext IS
BEGIN
    data_ext <= (0 TO N_OUT - N_IN1 - 1 => data_in(N_IN1 - 1)) -- extend reduced-length MSB
        & data_in (0 TO N_IN1 - 1) WHEN ctrl_in = '1'              -- select N_IN1
        ELSE                                                       -- select N_IN0
        (0 TO N_OUT - N_IN0 - 1 => data_in(N_IN0 - 1)) & data_in;  -- extend actual MSB
END datafl;