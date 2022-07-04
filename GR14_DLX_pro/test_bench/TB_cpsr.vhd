LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_cpsr IS
END TB_cpsr;

ARCHITECTURE test OF TB_cpsr IS
    COMPONENT cpsr
        PORT
        (
            clk, rst, ld, FL3, FL2, FL1, FL0 : IN STD_LOGIC;
            N, Z, C, V                       : OUT STD_LOGIC
        );
    END COMPONENT;

    CONSTANT T : TIME := Tclk;

    SIGNAL CLK, RST, LD, N, Z, C, V : STD_LOGIC;
    SIGNAL FL                       : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN
    dut : cpsr PORT MAP
        (CLK, RST, LD, FL(3), FL(2), FL(1), FL(0), N, Z, C, V);

    CLOCK : PROCESS IS
    BEGIN
        CLK <= '0';
        WAIT FOR T / 2;
        CLK <= '1';
        WAIT FOR T / 2;
    END PROCESS CLOCK;

    I_O : PROCESS IS
    BEGIN
        RST <= '0';
        LD  <= '0';
        FL  <= (OTHERS => '1');
        WAIT FOR T / 2;
        RST <= '1';
        WAIT FOR T;
        LD <= '1';
        FL <= "1000";
        WAIT FOR T;
        FL <= "0100";
        WAIT FOR T;
        FL <= "0010";
        WAIT FOR T;
        FL <= "0001";
        WAIT FOR T;
        LD <= '0';
        FL <= (OTHERS => '1');
        WAIT FOR T;
        LD <= '1';
        WAIT FOR T;
        RST <= '0';
        WAIT FOR T;
        LD <= '0';
        WAIT;
    END PROCESS I_O;
END test;