LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.dlx_utils.ALL;

ENTITY TB_cond_branch IS
END TB_cond_branch;

ARCHITECTURE test OF TB_cond_branch IS
    COMPONENT cond_branch
        PORT
        (
            cond_in, jump_in, ctrl_in : IN STD_LOGIC;
            ctrl_out                  : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL COND_IN, JUMP_IN, CTRL_IN, CTRL_OUT : STD_LOGIC;

BEGIN
    dut : cond_branch PORT MAP
        (COND_IN, JUMP_IN, CTRL_IN, CTRL_OUT);

    I_O : PROCESS IS
    BEGIN
        JUMP_IN <= '0';
        COND_IN <= '0';
        CTRL_IN <= '0';
        WAIT FOR Tclk;
        CTRL_IN <= '1';
        WAIT FOR Tclk;
        COND_IN <= '1';
        CTRL_IN <= '0';
        WAIT FOR Tclk;
        CTRL_IN <= '1';
        WAIT FOR Tclk;
        JUMP_IN <= '1';
        COND_IN <= '0';
        CTRL_IN <= '0';
        WAIT FOR Tclk;
        CTRL_IN <= '1';
        WAIT FOR Tclk;
        COND_IN <= '1';
        CTRL_IN <= '0';
        WAIT FOR Tclk;
        CTRL_IN <= '1';
        WAIT;
    END PROCESS I_O;
END test;