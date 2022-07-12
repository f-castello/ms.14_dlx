LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE work.dlx_utils.ALL;

ENTITY reg_file IS
    GENERIC
    (
        Dbits : NATURAL := NbitLong;
        Abits : NATURAL := RF_ADDR
    );
    PORT
    (
        CLK, RESET, ENABLE, RD1, RD2, WR : IN STD_LOGIC;
        ADD_WR, ADD_RD1, ADD_RD2         : IN STD_LOGIC_VECTOR(Abits - 1 DOWNTO 0);
        DATAIN                           : IN STD_LOGIC_VECTOR(Dbits - 1 DOWNTO 0);
        OUT1, OUT2                       : OUT STD_LOGIC_VECTOR(Dbits - 1 DOWNTO 0)
    );
END reg_file;

ARCHITECTURE INTEGER OF reg_file IS
    SUBTYPE REG_ADDR IS NATURAL RANGE 0 TO (2 ** Abits - 1);
    TYPE REG_ARRAY IS ARRAY(REG_ADDR) OF STD_LOGIC_VECTOR(Dbits - 1 DOWNTO 0);
    SIGNAL REGISTERS : REG_ARRAY; -- internal memory

BEGIN
    INT_REGS : PROCESS (RESET, CLK)
    BEGIN
        IF (RESET = '0') THEN
            REGISTERS <= (OTHERS => (OTHERS => '0')); -- wipe internal mem
            -- ... and disable both output ports
            OUT1 <= (OTHERS => '0');
            OUT2 <= (OTHERS => '0');
        ELSIF rising_edge(CLK) THEN
            IF (ENABLE = '1') THEN
                IF (WR = '1') THEN
                    IF (ADD_WR /= (Abits - 1 DOWNTO 0 => '0')) THEN
                        REGISTERS(to_integer(unsigned(ADD_WR))) <= DATAIN; -- REG(ADW) = DIN
                    END IF;
                END IF;
                IF (RD1 = '1') THEN
                    IF (ADD_RD1 = (Abits - 1 DOWNTO 0 => '0')) THEN
                        OUT1 <= REGISTERS(0);
                    ELSIF (ADD_RD1 = ADD_WR AND WR = '1') THEN -- simultaneous read & write
                        OUT1 <= DATAIN;                            -- bypass register
                    ELSE
                        OUT1 <= REGISTERS(to_integer(unsigned(ADD_RD1))); -- DOUT1 = REG(ADR1)
                    END IF;
                ELSE
                    OUT1 <= (OTHERS => '0'); -- disable output port
                END IF;
                IF (RD2 = '1') THEN
                    IF (ADD_RD2 = (Abits - 1 DOWNTO 0 => '0')) THEN
                        OUT2 <= REGISTERS(0);
                    ELSIF (ADD_RD2 = ADD_WR AND WR = '1') THEN -- simultaneous read & write
                        OUT2 <= DATAIN;                            -- bypass register
                    ELSE
                        OUT2 <= REGISTERS(to_integer(unsigned(ADD_RD2))); -- DOUT2 = REG(ADR2)
                    END IF;
                ELSE
                    OUT2 <= (OTHERS => '0'); -- disable output port
                END IF;
            END IF;
        END IF;
    END PROCESS INT_REGS;
END INTEGER;