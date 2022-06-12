LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE work.dlx_utils.ALL;

ENTITY pc_add IS
    GENERIC
    (
        N   : NATURAL := NbitLong; -- # of bits
        OP2 : INTEGER := NPC_GAP   -- second "short-circuited" operand
    );
    PORT
    (
        data_in  : IN STD_LOGIC_VECTOR(0 TO N - 1);
        data_out : OUT STD_LOGIC_VECTOR(0 TO N - 1)
    );
END pc_add;

ARCHITECTURE behav OF pc_add IS

    SIGNAL second : STD_LOGIC_VECTOR(0 TO N - 1); -- integer to std_logic_vector

BEGIN
    second   <= STD_LOGIC_VECTOR(to_signed(OP2, second'LENGTH));
    data_out <= data_in + second;
END behav;