library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
USE work.dlx_utils.ALL;

library std;
use std.textio.all;

entity RWMEM is
	generic(
			file_path: string;
			file_path_init: string;
			Data_size : natural := NbitLong;
			Instr_size: natural := NbitLong;
			RAM_DEPTH: 	natural := RWMEM_DEPTH;
			data_delay: natural := 0
		);
	port (
			CLK   				: in std_logic;
			RST					: in std_logic;
			ADDR				: in std_logic_vector(Data_size - 1 downto 0);
			ENABLE				: in std_logic;
			WR_EN		: in std_logic;
			DATA_READY			: out std_logic;
			INOUT_DATA			: inout std_logic_vector(Data_size-1 downto 0);
			BYTE_LEN			: IN STD_LOGIC_VECTOR(1 DOWNTO 0)
		);
end RWMEM;

architecture beh of RWMEM is
	type DRAMtype is array (0 to RAM_DEPTH-1) of std_logic_vector(instr_size - 1 downto 0);
	signal DRAM_mem : DRAMtype;
	signal tmp_data: std_logic_vector(Data_size - 1 downto 0);
	signal int_data_ready,mem_ready: std_logic;
	signal counter: natural:=0;

	procedure rewrite_contenent(data: in DRAMtype; path_file: string) is
		variable index: natural range 0 to RAM_DEPTH;
		file wr_file: text;
		variable line_in: line;
	begin
		index:=0;
		file_open(wr_file,path_file,WRITE_MODE);
		while index < RAM_DEPTH loop
			hwrite(line_in,data(index));
			writeline(wr_file,line_in);
			index := index + 1;
		end loop;
	end rewrite_contenent;



begin  -- beh
	--write_process
	WR_PROCESS:
	process (CLK, RST,WR_EN)
		file mem_fp: text;
		variable index: integer:= 0;
		variable file_line : line;
		variable tmp_data_u : std_logic_vector(INSTR_SIZE-1 downto 0);
	begin  -- process
		if RST = '0' then  	 -- asynchronous reset (active low)
--			while index < RAM_DEPTH loop
--				DRAM_mem(index) <= std_logic_vector(to_unsigned(index,instr_size));
--				index := index + 1;
--			end loop;

			file_open(
				mem_fp,
				file_path_init,
				READ_MODE
			);
			index := 0;
			while (not endfile(mem_fp)) loop
			--while (index < RAM_DEPTH) loop
				readline(mem_fp,file_line);
				hread(file_line,tmp_data_u);
				DRAM_mem(index) <= tmp_data_u;
				index := index + 1;
				
			end loop;

			file_close(mem_fp);

			int_data_ready <= '0';
			mem_ready <= '0';
		elsif CLK'event and CLK = '1' then  -- rising clock edge
			if(ENABLE = '1') then
				counter <= counter + 1;
				if (counter = data_delay) then
					counter <= 0;
					if (WR_EN = '1') then
						IF (BYTE_LEN = "00") THEN --SAVING BYTE
							DRAM_Mem(to_integer(unsigned(ADDR))) <= (Data_size - 1 DOWNTO 8 => '0') & INOUT_DATA(7 downto 0);
						
						ELSIF (BYTE_LEN = "01") THEN --SAVING HALF WORD
							DRAM_Mem(to_integer(unsigned(ADDR))) <= (Data_size - 1 DOWNTO 16 => '0') & INOUT_DATA(15 downto 0);
						ELSE	--SAVING WORD
							DRAM_Mem(to_integer(unsigned(ADDR))) <= INOUT_DATA;
						END IF;
						mem_ready <= '1';
					else
						IF (BYTE_LEN = "00") THEN --READING BYTE
							tmp_data <=(Data_size - 1 DOWNTO 8 => '0') & DRAM_mem(to_integer(unsigned(ADDR)))(7 downto 0);
							
						ELSIF (BYTE_LEN = "01") THEN --READING HALF WORD
							tmp_data <=(Data_size - 1 DOWNTO 16 => '0') & DRAM_mem(to_integer(unsigned(ADDR)))(15 downto 0);
						ELSE	--READING WORD
							tmp_data <=DRAM_mem(to_integer(unsigned(ADDR)));
						END IF;
						int_data_ready <= '1';
					end if;
				else
					mem_ready <= '0';
					int_data_ready <= '0';
				end if;
			else
				counter <= 0;
			end if;
		end if;
	end process;

	rewrite_contenent(DRAM_mem,file_path); -- refresh the file
	INOUT_DATA <= tmp_data when int_data_ready='1'  else (others=>'Z'); --
	data_ready <= int_data_ready or mem_ready;--delay add

end beh;