LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_branch_cond IS
END TB_branch_cond;

ARCHITECTURE test OF TB_branch_cond IS
    COMPONENT branch_cond
        PORT
        (
            cond_in, ctrl_in : IN STD_LOGIC;
            ctrl_out         : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL COND_IN, CTRL_IN, CTRL_OUT : STD_LOGIC;

BEGIN
    dut : branch_cond PORT MAP
        (COND_IN, CTRL_IN, CTRL_OUT);

    COND_IN <= '0', '1' AFTER 2 * Tclk;
    CTRL_IN <= '0', '1' AFTER Tclk, '0' AFTER 2 * Tclk, '1' AFTER 3 * Tclk;
END test;