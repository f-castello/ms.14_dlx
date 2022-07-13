LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;
USE work.dlx_utils.ALL;

-- Instruction memory for DLX
-- Memory filled by a process which reads from a file
-- file name is "test.asm.mem"
ENTITY ROMEM IS
	GENERIC
	(
		FILE_PATH  : STRING;
		ENTRIES    : INTEGER := RWMEM_DEPTH;
		WORD_SIZE  : INTEGER := NbitLong;
		DATA_DELAY : NATURAL := 0
	);
	PORT
	(
		CLK        : IN STD_LOGIC;
		RST        : IN STD_LOGIC;
		ADDRESS    : IN STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
		ENABLE     : IN STD_LOGIC;
		DATA_READY : OUT STD_LOGIC;
		DATA       : OUT STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0)
	);
END ROMEM;

ARCHITECTURE behav OF ROMEM IS
	TYPE RAM IS ARRAY (0 TO ENTRIES - 1) OF INTEGER;
	SIGNAL Memory : RAM;
	SIGNAL valid  : STD_LOGIC;
	SIGNAL idout  : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
	SIGNAL count  : INTEGER RANGE 0 TO (DATA_DELAY + 1);

BEGIN
	-- purpose: This process is in charge of filling the Instruction RAM with the firmware
	FILL_MEM_P : PROCESS (RST, CLK)
		FILE mem_fp         : text;
		VARIABLE file_line  : line;
		VARIABLE index      : INTEGER := 0;
		VARIABLE tmp_data_u : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
	BEGIN -- process FILL_MEM_P
		IF (RST = '0') THEN
			file_open(mem_fp, FILE_PATH, READ_MODE);
			index := 0;
			WHILE (NOT endfile(mem_fp)) LOOP
				readline(mem_fp, file_line);
				hread(file_line, tmp_data_u);
				Memory(index) <= conv_integer(unsigned(tmp_data_u));
				index := index + 1;
			END LOOP;
			file_close(mem_fp);
			count <= 0;
		ELSIF rising_edge(CLK) THEN
			IF (ENABLE = '1') THEN
				count <= count + 1;
				IF (count = DATA_DELAY) THEN
					count <= 0;
					valid <= '1';
					idout <= conv_std_logic_vector(Memory(conv_integer(unsigned(ADDRESS))), WORD_SIZE);
				END IF;
			ELSE
				count <= 0;
				valid <= '0';
			END IF;
		END IF;
	END PROCESS FILL_MEM_P;

	DATA_READY <= valid;
	DATA       <= idout WHEN valid = '1' ELSE
		(OTHERS => 'Z');
END behav;