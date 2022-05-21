LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.dlx_utils.ALL;

ENTITY gen_reg IS
    GENERIC
    (
        N : NATURAL := NbitLong -- # of bits
    );
    PORT
    (
        clk, rst, en : IN STD_LOGIC;
        data_in      : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        data_out     : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
    );
END gen_reg;

ARCHITECTURE behav OF gen_reg IS

    SIGNAL int : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- internal memory

BEGIN
    data_out <= (OTHERS => '0') WHEN en = '0' ELSE
        int;

    REG_MEM : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF (rst = '0') THEN -- synchronous, active-low
                int <= (OTHERS => '0');
            ELSIF (en = '1') THEN -- normal operation
                int <= data_in;
            END IF;
        END IF;
    END PROCESS REG_MEM;
END behav;