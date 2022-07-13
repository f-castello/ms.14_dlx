LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
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
        data_in  : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        data_out : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
    );
END pc_add;

ARCHITECTURE behav OF pc_add IS
BEGIN
    data_out <= STD_LOGIC_VECTOR(SIGNED(data_in) + TO_SIGNED(OP2, data_in'LENGTH));
END behav;