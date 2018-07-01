library ieee;
library WORK;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity digital_tube is
	generic(
		clock_freq: INTEGER := 50000000;
		update_freq: INTEGER := 25;
		data_bus_width: INTEGER := 14
	);
	port(
		clk: IN STD_LOGIC := '0';
		reset: IN STD_LOGIC := '0';
		data: IN STD_LOGIC_VECTOR(data_bus_width - 1 downto 0) := (others => '0');
		seg: OUT  STD_LOGIC_VECTOR (6 downto 0) := (others => '0');
		segment0: OUT STD_LOGIC := '0';
		segment1: OUT STD_LOGIC := '0';
		segment2: OUT STD_LOGIC := '0';
		segment3: OUT STD_LOGIC := '0'
	);

end entity digital_tube;	

architecture tube of digital_tube is

	component bin2bcd_5bit is
		generic (
			data_bus_width: INTEGER := 14
		);
		port (
			bus_data:IN std_logic_vector(data_bus_width - 1 downto 0);
			bcd1:OUT std_logic_vector(3 downto 0);
			bcd10:OUT std_logic_vector(3 downto 0);
			bcd100:OUT std_logic_vector(3 downto 0);
			bcd1000:OUT std_logic_vector(3 downto 0)
		);
	end component bin2bcd_5bit;
	
	component bcd_7_segment is
		port (
			reset: IN STD_LOGIC := '0';
			hex: IN  STD_LOGIC_VECTOR (3 downto 0) := (others => '1');
			seg: OUT  STD_LOGIC_VECTOR (6 downto 0) := (others => '0')
		);
	end component bcd_7_segment;
	
	shared variable freq: INTEGER := 2000000;
	signal curent_segment: INTEGER range 0 to 4;
	signal wire_data: STD_LOGIC_VECTOR(data_bus_width - 1 downto 0) := (others => '0');
	signal wire_hex0: STD_LOGIC_VECTOR(3 downto 0);
	signal wire_hex1: STD_LOGIC_VECTOR(3 downto 0);
	signal wire_hex2: STD_LOGIC_VECTOR(3 downto 0);
	signal wire_hex3: STD_LOGIC_VECTOR(3 downto 0);
	
	signal wire_seg0: STD_LOGIC_VECTOR (6 downto 0) := (others => '0');
	signal wire_seg1: STD_LOGIC_VECTOR (6 downto 0) := (others => '0');
	signal wire_seg2: STD_LOGIC_VECTOR (6 downto 0) := (others => '0');
	signal wire_seg3: STD_LOGIC_VECTOR (6 downto 0) := (others => '0');

begin

	seg <= 
		wire_seg0 when curent_segment = 1 else
		wire_seg1 when curent_segment = 2 else
		wire_seg2 when curent_segment = 3 else
		wire_seg3 when curent_segment = 4;
	
	segment0 <= '0' when curent_segment = 1 else '1';
	segment1 <= '0' when curent_segment = 2 else '1';
	segment2 <= '0' when curent_segment = 3 else '1';
	segment3 <= '0' when curent_segment = 4 else '1';
	
	to_hex: bin2bcd_5bit generic map(data_bus_width => 14) port map ( 
		bus_data => wire_data,
		bcd1 => wire_hex0,
		bcd10 => wire_hex1,
		bcd100 => wire_hex2,
		bcd1000 => wire_hex3
	);
	S0: bcd_7_segment port map (
		reset => reset,
		hex => wire_hex0,
      seg => wire_seg0
	);
	S1: bcd_7_segment port map (
		reset => reset,
		hex => wire_hex1,
      seg => wire_seg1
	);
	S2: bcd_7_segment port map (
		reset => reset,
		hex => wire_hex2,
      seg => wire_seg2
	);
	S3: bcd_7_segment port map (
		reset => reset,
		hex => wire_hex3,
      seg => wire_seg3
	);
	
	comp_curent_segment: process(reset, clk)
		variable curent_value: INTEGER range 0 to 2000000 := 0;
	begin
		if(reset = '1') then
			curent_value := 0;
			curent_segment <= 0;
			wire_data <= (others => '0');
		elsif(rising_edge(clk) and clk = '1') then
			if(curent_value < (clock_freq / update_freq)) then
				curent_value := curent_value + 1;
			else
				wire_data <= data;
				curent_value := 0;
				if(curent_segment < 4) then
					curent_segment <= curent_segment + 1;
				else
					curent_segment <= 1;
				end if;
			end if;
		end if;
	end process;

end architecture tube;

