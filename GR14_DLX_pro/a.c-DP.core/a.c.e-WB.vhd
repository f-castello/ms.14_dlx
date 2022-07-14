LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.dlx_utils.ALL;

ENTITY WB_STAGE IS
    GENERIC
    (
        N_BITS_DATA : NATURAL := NbitLong -- # of bits
    );
    PORT
    (
        -- Control ports
        WB_MUX_SEL    : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- Primary Outcome Selector
        WB_CTRL_SIGN  : IN STD_LOGIC;                    -- Choose Sign Extension domain
        ZERO_PADDING5 : IN STD_LOGIC;                    -- Choose Zero Padding over normal Sign Extension
        -- Data ports
        NPC_OUT : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Mux Input #3 ("11" -> NPC)
        MEM_OUT : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Sign Ext Input/Mux Input #2 ("01" -> MEM Out)
        ALU_OUT : IN STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Mux Input #0 ("00" -> ALU Out)
        MUX_OUT : OUT STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0) -- Mux Main Output
    );
END WB_STAGE;

ARCHITECTURE STRUCTURAL OF WB_STAGE IS
    SIGNAL SIGN_OUT : STD_LOGIC_VECTOR(N_BITS_DATA - 1 DOWNTO 0); -- Mux Input #2 ("10" -> Sign Ext Out)

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

    COMPONENT sign_ext_alt
        GENERIC
        (
            N_IN0 : NATURAL := NbitShort; -- first input # of bits (must be greater than N_IN1): half word in this case
            N_IN1 : NATURAL := NbitByte;  -- second input # of bits (reduced size): byte in this case
            N_OUT : NATURAL := NbitLong   -- unique output # of bits (must be greater than both input sizes): word size in this case
        );
        PORT
        (
            ctrl_in      : IN STD_LOGIC;
            zero_padding : IN STD_LOGIC;
            data_in      : IN STD_LOGIC_VECTOR(N_IN0 - 1 DOWNTO 0);
            data_ext     : OUT STD_LOGIC_VECTOR(N_OUT - 1 DOWNTO 0)
        );
    END COMPONENT;

BEGIN
    MUX : gen_mux41 GENERIC
    MAP (N => N_BITS_DATA)
    PORT MAP
    (
        sel => WB_MUX_SEL,
        w   => ALU_OUT,
        x   => MEM_OUT,
        y   => SIGN_OUT,
        z   => NPC_OUT,
        m   => MUX_OUT
    );

    SIGN_EXTEND : sign_ext_alt GENERIC
    MAP (
    N_IN0 => NbitShort,
    N_IN1 => NbitByte,
    N_OUT => N_BITS_DATA
    )
    PORT
    MAP (
    ctrl_in      => WB_CTRL_SIGN, -- if 0, byte extension, Half W extension otherwise
    zero_padding => ZERO_PADDING5,
    data_in      => MEM_OUT(NbitShort - 1 DOWNTO 0),
    data_ext     => SIGN_OUT
    );
END STRUCTURAL;