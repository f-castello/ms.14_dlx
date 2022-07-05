LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.dlx_utils.ALL;
--Extends signs from 8 or 16 bits, in the case of loading a word, LOAD memory signal choose the input 
ENTITY sign_ext IS
    GENERIC
    (
        N_IN0 : NATURAL := NbitLong/2;  -- first input # of bits (must be greater than N_IN1) (half word in this case)
        N_IN1 : NATURAL := 8; -- second input # of bits (reduced size) (Byte in this case)
        N_OUT : NATURAL := NbitLong   -- unique output # of bits (must be greater than both input sizes) (Word size in this case)
    );
    PORT
    (
        ctrl_in  		: IN STD_LOGIC;
		zero_padding 	: IN STD_LOGIC;
        data_in  		: IN STD_LOGIC_VECTOR(N_IN0 - 1 DOWNTO 0);
        data_ext 		: OUT STD_LOGIC_VECTOR(N_OUT - 1 DOWNTO 0)
    );
END sign_ext;

ARCHITECTURE datafl OF sign_ext IS
BEGIN
    data_ext <= (N_OUT - N_IN1 - 1 DOWNTO 0 => data_in(N_IN1 - 1)) -- Sign extension BYTE
        & data_in (N_IN1 - 1 DOWNTO 0) WHEN (ctrl_in = '0' AND zero_padding = '0') ELSE 
		(N_OUT - N_IN1 - 1 DOWNTO 0 => '0') -- zreo padding BYTE
        & data_in (N_IN1 - 1 DOWNTO 0) WHEN (ctrl_in = '0' AND zero_padding = '1') 
		ELSE                                                           -- select N_IN0
        (N_OUT - N_IN0 - 1 DOWNTO 0 => data_in(N_IN0 - 1)) & data_in WHEN (ctrl_in = '1' AND zero_padding = '0') -- sig extension HALF-WORD
		ELSE
        (N_OUT - N_IN0 - 1 DOWNTO 0 => data_in(N_IN0 - 1)) & data_in;
END datafl;
