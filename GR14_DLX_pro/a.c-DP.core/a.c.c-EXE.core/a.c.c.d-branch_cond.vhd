LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY branch_cond IS
    PORT
    (
        cond_in, ctrl_in : IN STD_LOGIC;
        ctrl_out         : OUT STD_LOGIC
    );
END branch_cond;

ARCHITECTURE datafl OF branch_cond IS
BEGIN
    -- BEHAVIORAL DESCRIPTION (inside a process...):
    -- IF (cond_in = '1') THEN
    --     ctrl_out <= ctrl_in;
    -- ELSE
    --     ctrl_out <= NOT ctrl_in;
    -- END IF;

    -- DERIVED LOGIC FUNCTION (unoptimized):
    -- ctrl_out <= (ctrl_in and cond_in) or (ctrl_in nor cond_in);

    -- BOOLEAN REDUCTION (optimized):
    ctrl_out <= ctrl_in XNOR cond_in;
END datafl;