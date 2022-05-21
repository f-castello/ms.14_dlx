LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY cpsr IS
    PORT
    (
        clk, rst, en, FL3, FL2, FL1, FL0 : IN STD_LOGIC;
        N, Z, C, V                       : OUT STD_LOGIC
    );
END cpsr;

ARCHITECTURE status OF cpsr IS

    SIGNAL flags : STD_LOGIC_VECTOR(3 DOWNTO 0); -- internal memory

BEGIN
    N <= '0' WHEN en = '0' ELSE
        flags(3); -- Negative
    Z <= '0' WHEN en = '0' ELSE
        flags(2); -- Zero
    C <= '0' WHEN en = '0' ELSE
        flags(1); -- Carry
    V <= '0' WHEN en = '0' ELSE
        flags(0); -- Overflow

    INT_MEM : PROCESS (clk, rst, en)
    BEGIN
        IF rising_edge(clk) THEN
            IF (rst = '0') THEN -- synchronous, active-low
                flags <= (OTHERS => '0');
            ELSIF (en = '1') THEN -- normal operation
                flags(3) <= FL3;
                flags(2) <= FL2;
                flags(1) <= FL1;
                flags(0) <= FL0;
            END IF;
        END IF;
    END PROCESS INT_MEM;
END status;