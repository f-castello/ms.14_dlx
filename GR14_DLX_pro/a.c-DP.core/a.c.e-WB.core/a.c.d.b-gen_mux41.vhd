LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.dlx_utils.ALL;

ENTITY gen_mux41 IS
    GENERIC
    (
        N : NATURAL := NbitLong -- # of bits
    );
    PORT
    (
        sel        : IN STD_LOGIC_VECTOR(0 TO 1); -- selectors
        w, x, y, z : IN STD_LOGIC_VECTOR(0 TO N - 1);
        m          : OUT STD_LOGIC_VECTOR(0 TO N - 1)

    );
END gen_mux41;

ARCHITECTURE dflow OF gen_mux41 IS

    SIGNAL s1, s0 : STD_LOGIC_VECTOR(0 TO N - 1); -- 'sel' arrays

BEGIN
    s1 <= (OTHERS => sel(1));       -- extend first selector to N bits
    s0 <= (OTHERS => sel(0));       -- extend second selector to N bits
    m  <= (w AND NOT s1 AND NOT s0) -- 00
        OR (x AND s0 AND NOT s1)        -- 01
        OR (y AND NOT s0 AND s1)        -- 10
        OR (z AND s0 AND s1);           -- 11
END dflow;