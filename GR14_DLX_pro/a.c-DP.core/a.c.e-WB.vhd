LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.dlx_utils.ALL;

ENTITY WB_STAGE IS
    GENERIC
    (
        N_BITS_DATA : NATURAL := NbitLong; -- # of bits
        RF_ADDR     : NATURAL := RF_ADDR
    );
    PORT
    (
        -- Control ports
        JAL_MUX_SEL : IN STD_LOGIC; -- 'Jal' Op Auxiliary Selector
        WB_MUX_SEL  : IN STD_LOGIC; -- Primary Outcome Selector
        -- Data ports
        IR_IN   : IN STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0);
        MUX_IN2 : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);  -- Mux Input #2 ("1-" -> NPC)
        MUX_IN1 : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);  -- Mux Input #1 ("01" -> MEM Out)
        MUX_IN0 : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0);  -- Mux Input #0 ("00" -> ALU Out)
        MUX_OUT : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Mux Main Output
        IR_OUT  : OUT STD_LOGIC_VECTOR(RF_ADDR - 1 DOWNTO 0)
    );
END WB_STAGE;

ARCHITECTURE STRUCTURAL OF WB_STAGE IS
    SIGNAL SEL : STD_LOGIC_VECTOR(1 DOWNTO 0); -- mux selector array

    COMPONENT gen_mux41
        GENERIC
        (
            N : NATURAL := NbitLong -- # of bits
        );
        PORT
        (
            sel        : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- selectors
            w, x, y, z : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            m          : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
        );
    END COMPONENT;

BEGIN
    MUX : gen_mux41 GENERIC
    MAP (N => N_BITS_DATA)
    PORT MAP
    (
        sel => SEL,
        w   => MUX_IN0,
        x   => MUX_IN1,
        -- always select the NPC whenever JAL_MUX_SEL is '1',
        -- no matter what WB_MUX_SEL is (don't care condition):
        y => MUX_IN2,
        z => MUX_IN2,
        m => MUX_OUT
    );

    SEL    <= JAL_MUX_SEL & WB_MUX_SEL;
    IR_OUT <= IR_IN; -- direct bypass
END STRUCTURAL;