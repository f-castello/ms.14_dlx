LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_textio.ALL;
USE work.dlx_utils.ALL;
LIBRARY std;
USE std.textio.ALL;

ENTITY RWMEM IS
	GENERIC
	(
		FILE_PATH      : STRING;
		FILE_PATH_INIT : STRING;
		DATA_SIZE      : NATURAL := NbitLong;
		INSTR_SIZE     : NATURAL := NbitLong;
		RAM_DEPTH      : NATURAL := RWMEM_DEPTH;
		DATA_DELAY     : NATURAL := 0
	);
	PORT
	(
		CLK        : IN STD_LOGIC;
		RST        : IN STD_LOGIC;
		ADDR       : IN STD_LOGIC_VECTOR(DATA_SIZE - 1 DOWNTO 0);
		ENABLE     : IN STD_LOGIC;
		WR_EN      : IN STD_LOGIC;
		DATA_READY : OUT STD_LOGIC;
		INOUT_DATA : INOUT STD_LOGIC_VECTOR(DATA_SIZE - 1 DOWNTO 0);
		BYTE_LEN   : IN STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END RWMEM;

ARCHITECTURE behav OF RWMEM IS
	TYPE DRAMtype IS ARRAY (0 TO RAM_DEPTH - 1) OF STD_LOGIC_VECTOR(INSTR_SIZE - 1 DOWNTO 0);
	SIGNAL DRAM_mem       : DRAMtype;
	SIGNAL tmp_data       : STD_LOGIC_VECTOR(DATA_SIZE - 1 DOWNTO 0);
	SIGNAL int_data_ready : STD_LOGIC;
	SIGNAL mem_ready      : STD_LOGIC;
	SIGNAL counter        : NATURAL := 0;

	PROCEDURE rewrite_contenent(data : IN DRAMtype; path_file : STRING) IS
		VARIABLE index   : NATURAL RANGE 0 TO RAM_DEPTH;
		FILE wr_file     : text;
		VARIABLE line_in : line;
	BEGIN
		index := 0;
		file_open(wr_file, path_file, WRITE_MODE);
		WHILE (index < RAM_DEPTH) LOOP
			hwrite(line_in, data(index));
			writeline(wr_file, line_in);
			index := index + 1;
		END LOOP;
	END rewrite_contenent;

BEGIN
	--write_process
	WR_PROCESS : PROCESS (CLK, RST)
		FILE mem_fp         : text;
		VARIABLE index      : INTEGER := 0;
		VARIABLE file_line  : line;
		VARIABLE tmp_data_u : STD_LOGIC_VECTOR(INSTR_SIZE - 1 DOWNTO 0);
	BEGIN
		IF (RST = '0') THEN -- asynchronous reset (active low)
			file_open(mem_fp, FILE_PATH_INIT, READ_MODE);
			index := 0;
			WHILE (NOT endfile(mem_fp)) LOOP
				readline(mem_fp, file_line);
				hread(file_line, tmp_data_u);
				DRAM_mem(index) <= tmp_data_u;
				index := index + 1;
			END LOOP;
			file_close(mem_fp);
			int_data_ready <= '0';
			mem_ready      <= '0';
		ELSIF rising_edge(CLK) THEN -- rising clock edge
			IF (ENABLE = '1') THEN
				counter <= counter + 1;
				IF (counter = DATA_DELAY) THEN
					counter <= 0;
					IF (WR_EN = '1') THEN
						IF (BYTE_LEN = "00") THEN --SAVING BYTE
							DRAM_Mem(to_integer(unsigned(ADDR))) <= (DATA_SIZE - 1 DOWNTO 8 => '0') & INOUT_DATA(7 DOWNTO 0);
						ELSIF (BYTE_LEN = "01") THEN --SAVING HALF WORD
							DRAM_Mem(to_integer(unsigned(ADDR))) <= (DATA_SIZE - 1 DOWNTO 16 => '0') & INOUT_DATA(15 DOWNTO 0);
						ELSE --SAVING WORD
							DRAM_Mem(to_integer(unsigned(ADDR))) <= INOUT_DATA;
						END IF;
						mem_ready <= '1';
					ELSE
						IF (BYTE_LEN = "00") THEN --READING BYTE
							tmp_data <= (DATA_SIZE - 1 DOWNTO 8 => '0') & DRAM_mem(to_integer(unsigned(ADDR)))(7 DOWNTO 0);
						ELSIF (BYTE_LEN = "01") THEN --READING HALF WORD
							tmp_data <= (DATA_SIZE - 1 DOWNTO 16 => '0') & DRAM_mem(to_integer(unsigned(ADDR)))(15 DOWNTO 0);
						ELSE --READING WORD
							tmp_data <= DRAM_mem(to_integer(unsigned(ADDR)));
						END IF;
						int_data_ready <= '1';
					END IF;
				ELSE
					mem_ready      <= '0';
					int_data_ready <= '0';
				END IF;
			ELSE
				counter <= 0;
			END IF;
		END IF;
	END PROCESS WR_PROCESS;

	rewrite_contenent(DRAM_mem, FILE_PATH); -- refresh the file
	INOUT_DATA <= tmp_data WHEN int_data_ready = '1' AND WR_EN = '0' ELSE
		(OTHERS => 'Z');
	data_ready <= int_data_ready OR mem_ready;--delay add
END behav;