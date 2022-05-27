LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY cpsr IS
    PORT
    (
        clk, rst, ld, FL3, FL2, FL1, FL0 : IN STD_LOGIC;
        N, Z, C, V                       : OUT STD_LOGIC
    );
END cpsr;

ARCHITECTURE status OF cpsr IS
BEGIN
    INT_MEM : PROCESS (rst, clk)
    BEGIN
        IF (rst = '0') THEN -- asynchronous, active-low
            N <= '0';
            Z <= '0';
            C <= '0';
            V <= '0';
        ELSIF rising_edge(clk) AND (ld = '1') THEN -- normal operation
            N <= FL3;                                  -- Negative
            Z <= FL2;                                  -- Zero
            C <= FL1;                                  -- Carry
            V <= FL0;                                  -- Overflow
        END IF;
    END PROCESS INT_MEM;
END status;