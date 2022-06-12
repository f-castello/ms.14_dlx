LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_reg_file IS
END TB_reg_file;

ARCHITECTURE test OF TB_reg_file IS
    COMPONENT reg_file
        GENERIC
        (
            Dbits : NATURAL := NbitLong;
            Abits : NATURAL := RF_ADDR
        );
        PORT
        (
            CLK, RESET, ENABLE, RD1, RD2, WR : IN STD_LOGIC;
            ADD_WR, ADD_RD1, ADD_RD2         : IN STD_LOGIC_VECTOR(0 TO Abits - 1);
            DATAIN                           : IN STD_LOGIC_VECTOR(0 TO Dbits - 1);
            OUT1, OUT2                       : OUT STD_LOGIC_VECTOR(0 TO Dbits - 1)
        );
    END COMPONENT;

    CONSTANT T : TIME := Tclk;

    SIGNAL CLK, RESET, ENABLE, RD1, RD2, WR : STD_LOGIC;
    SIGNAL ADD_WR, ADD_RD1, ADD_RD2         : STD_LOGIC_VECTOR(0 TO RF_ADDR - 1);
    SIGNAL DATAIN, OUT1, OUT2               : STD_LOGIC_VECTOR(0 TO NbitLong - 1);

BEGIN
    dut : reg_file GENERIC
    MAP (NbitLong, RF_ADDR) PORT MAP
    (CLK, RESET, ENABLE, RD1, RD2, WR, ADD_WR, ADD_RD1, ADD_RD2, DATAIN, OUT1, OUT2);

    CLOCK : PROCESS IS
    BEGIN
        CLK <= '0';
        WAIT FOR T / 2;
        CLK <= '1';
        WAIT FOR T / 2;
    END PROCESS CLOCK;

    I_O : PROCESS IS
    BEGIN
        RESET   <= '0';
        ENABLE  <= '0';
        WR      <= '0';
        RD1     <= '0';
        RD2     <= '0';
        ADD_WR  <= (OTHERS => '0');
        ADD_RD1 <= (OTHERS => '0');
        ADD_RD2 <= (OTHERS => '0');
        DATAIN  <= (OTHERS => '1');
        WAIT FOR T / 2;
        RESET <= '1';
        WR    <= '1';
        WAIT FOR T;
        ENABLE <= '1';
        WAIT FOR T;
        WR  <= '0';
        RD1 <= '1';
        WAIT FOR T;
        RD2    <= '1';
        DATAIN <= (OTHERS => '0');
        WAIT FOR T;
        DATAIN  <= DATAIN + '1';
        RD1     <= '0';
        ADD_RD2 <= (OTHERS => '1');
        WR      <= '1';
        ADD_WR  <= (OTHERS => '1');
        WAIT FOR T;
        ENABLE <= '0';
        WAIT FOR T;
        ENABLE <= '1';
        WR     <= '0';
        WAIT FOR T;
        RESET <= '0';
        WAIT FOR T;
        ENABLE <= '0';
        RD2    <= '0';
        WAIT;
    END PROCESS I_O;
END test;