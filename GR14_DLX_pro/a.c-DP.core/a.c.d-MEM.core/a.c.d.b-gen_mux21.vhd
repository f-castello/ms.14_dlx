LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.dlx_utils.ALL;

ENTITY gen_mux21 IS
    GENERIC
    (
        N : NATURAL := NbitLong -- # of bits
    );
    PORT
    (
        sel  : IN STD_LOGIC; -- selector
        x, y : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        m    : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
    );
END gen_mux21;

ARCHITECTURE dflow OF gen_mux21 IS
    SIGNAL s : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- 'sel' array

BEGIN
    s <= (OTHERS => sel);            -- extend selector to N bits
    m <= (x AND NOT s) OR (y AND s); -- standard logic function
END dflow;