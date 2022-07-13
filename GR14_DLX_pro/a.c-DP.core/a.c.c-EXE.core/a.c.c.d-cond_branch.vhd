LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY cond_branch IS
    PORT
    (
        cond_in, jump_in, ctrl_in : IN STD_LOGIC;
        ctrl_out                  : OUT STD_LOGIC
    );
END cond_branch;

ARCHITECTURE dflow OF cond_branch IS
BEGIN
    -- if (jump_in) {
    --     if (cond_in) {
    --         ctrl_out = ctrl_in;
    --     } else {
    --         ctrl_out = !ctrl_in;
    --     }
    -- } else {
    --     ctrl_out = 0;
    -- }

    ctrl_out <= (ctrl_in XNOR cond_in) AND jump_in;
END dflow;