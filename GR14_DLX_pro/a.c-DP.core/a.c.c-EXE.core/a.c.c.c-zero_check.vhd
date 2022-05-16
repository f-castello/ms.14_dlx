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
        data_in  : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        ctrl_out : STD_LOGIC
    );
END zero_check;

ARCHITECTURE datafl OF zero_check IS
BEGIN
    ctrl_out <= '1' WHEN data_in = (data_in'RANGE => '0') ELSE
        '0'; -- including collisions in input
END datafl;