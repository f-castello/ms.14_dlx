LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_pc_add IS
END TB_pc_add;

ARCHITECTURE test OF TB_pc_add IS
    COMPONENT pc_add
        GENERIC
        (
            N   : NATURAL := NbitLong;
            OP2 : INTEGER := NPC_GAP
        );
        PORT
        (
            data_in  : IN STD_LOGIC_VECTOR(0 TO N - 1);
            data_out : OUT STD_LOGIC_VECTOR(0 TO N - 1)
        );
    END COMPONENT;

    SIGNAL DATA_IN, DATA_OUT : STD_LOGIC_VECTOR(NbitLong - 1 DOWNTO 0);

BEGIN
    dut : pc_add GENERIC
    MAP (NbitLong, NPC_GAP) PORT MAP
    (DATA_IN, DATA_OUT);

    I_O : PROCESS IS
    BEGIN
        DATA_IN <= (OTHERS => '1');
        FOR i IN 0 TO NPC_GAP LOOP
            WAIT FOR Tclk;
            DATA_IN <= DATA_IN + '1';
        END LOOP;
        WAIT;
    END PROCESS I_O;
END test;