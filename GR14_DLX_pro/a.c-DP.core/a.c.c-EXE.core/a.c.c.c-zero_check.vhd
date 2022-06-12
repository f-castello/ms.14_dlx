LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.dlx_utils.ALL;

ENTITY zero_check IS
    GENERIC
    (
        N : NATURAL := NbitLong -- # of bits
    );
    PORT
    (
        data_in  : IN STD_LOGIC_VECTOR(0 TO N - 1);
        ctrl_out : OUT STD_LOGIC
    );
END zero_check;

ARCHITECTURE dflow OF zero_check IS
BEGIN
    ctrl_out <= '1' WHEN data_in = (data_in'RANGE => '0') ELSE
        '0'; -- including input collisions
END dflow;