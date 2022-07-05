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
        clk, rst, ld : IN STD_LOGIC;
        data_in      : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        data_out     : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
    );
END gen_reg;

ARCHITECTURE behav OF gen_reg IS
BEGIN
    REG_MEM : PROCESS (rst, clk)
    BEGIN
        IF (rst = '0') THEN -- asynchronous, active-low
            data_out <= (OTHERS => '0');
        ELSIF rising_edge(clk) AND (ld = '1') THEN -- normal operation
            data_out <= data_in;
        END IF;
    END PROCESS REG_MEM;
END behav;