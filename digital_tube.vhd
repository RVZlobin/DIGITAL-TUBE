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
			reset: IN STD_LOGIC := '0';
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
	signal wire_data: STD_LOGIC_VECTOR(data_bus_width - 1 downto 0) bus := (others => '0');
	signal wire_hex0: STD_LOGIC_VECTOR(3 downto 0) bus;
	signal wire_hex1: STD_LOGIC_VECTOR(3 downto 0) bus;
	signal wire_hex2: STD_LOGIC_VECTOR(3 downto 0) bus;
	signal wire_hex3: STD_LOGIC_VECTOR(3 downto 0) bus;
	
	signal wire_seg0: STD_LOGIC_VECTOR (6 downto 0) bus := (others => '0');
	signal wire_seg1: STD_LOGIC_VECTOR (6 downto 0) bus := (others => '0');
	signal wire_seg2: STD_LOGIC_VECTOR (6 downto 0) bus := (others => '0');
	signal wire_seg3: STD_LOGIC_VECTOR (6 downto 0) bus := (others => '0');

begin

	seg <= 
		wire_seg0 when curent_segment = 1 else
		wire_seg1 when curent_segment = 2 else
		wire_seg2 when curent_segment = 3 else
		wire_seg3 when curent_segment = 4;
	
	segment0 <= '0' when curent_segment = 1 or reset = '1' else '1';
	segment1 <= '0' when curent_segment = 2 or reset = '1' else '1';
	segment2 <= '0' when curent_segment = 3 or reset = '1' else '1';
	segment3 <= '0' when curent_segment = 4 or reset = '1' else '1';
	
	to_hex: bin2bcd_5bit generic map(data_bus_width => 14) port map (
		reset => reset,
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
			curent_segment <= 1;
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


architecture tube_light of digital_tube is
	
	component data_serializer  is
	generic (
		DBIT: INTEGER
	);
	port (
		clk				: in STD_LOGIC := '0';
		reset				: in STD_LOGIC := '0';
		data_in			: in STD_LOGIC_VECTOR(DBIT - 1 downto 0) := (others => 'X');--данные для передачи
		tx_start			: in STD_LOGIC := '0';													--запуск передачи данных
		tx_done_tick	: out STD_LOGIC := '0'; 												--импульс завершения передачи данных
		das_sdi			: out STD_LOGIC := '0'; 												--выход данные
		das_clk			: out STD_LOGIC := '0'; 												--выход тактовый
		das_reset		: out STD_LOGIC := '0' 													--выход смброса принимающего устроqства
	);
	end component data_serializer;

	component dc_ddc_segment is
		generic( data_bus_width: INTEGER := 14 );
		port(
			in_clk			: in STD_LOGIC := '0';
			reset				: in STD_LOGIC := '0';
			fix				: in STD_LOGIC := '0';
			mult				: in STD_LOGIC := '0';
			dc_x				: in STD_LOGIC := '0';
			out_clk			: out STD_LOGIC := '0';
			dc_bit_y			: out STD_LOGIC := '0';
			overflow			: out STD_LOGIC := '0';
			ddc_seg			: out STD_LOGIC_VECTOR (3 downto 0) := (others => '0')
		);
	end component dc_ddc_segment;

	component bcd_7_segment is
		port (
			reset: IN STD_LOGIC := '0';
			hex: IN  STD_LOGIC_VECTOR (3 downto 0) := (others => '1');
			seg: OUT  STD_LOGIC_VECTOR (6 downto 0) := (others => '0')
		);
	end component bcd_7_segment;
		
	shared variable freq: INTEGER := 2000000;
	signal curent_segment: INTEGER range 0 to 4 := 0;
	
	signal wire_hex0: STD_LOGIC_VECTOR(3 downto 0) bus;
	signal wire_hex1: STD_LOGIC_VECTOR(3 downto 0) bus;
	signal wire_hex2: STD_LOGIC_VECTOR(3 downto 0) bus;
	signal wire_hex3: STD_LOGIC_VECTOR(3 downto 0) bus;
	
	signal wire_seg0: STD_LOGIC_VECTOR (6 downto 0) bus := (others => '0');
	signal wire_seg1: STD_LOGIC_VECTOR (6 downto 0) bus := (others => '0');
	signal wire_seg2: STD_LOGIC_VECTOR (6 downto 0) bus := (others => '0');
	signal wire_seg3: STD_LOGIC_VECTOR (6 downto 0) bus := (others => '0');
	
	signal wire_data_in: STD_LOGIC_VECTOR(data_bus_width - 1 downto 0) bus := (others => '0');
	signal wire_tx_start : STD_LOGIC register := '0';
	signal wire_das_clk : STD_LOGIC bus := '0';
	signal wire_fix: STD_LOGIC register := '0';
	signal wire_das_reset: STD_LOGIC register := '0';
	signal wire_dc_bit_x: STD_LOGIC bus := '0';
	signal wire_dc_bit_y_x_0: STD_LOGIC bus := '0';
	signal wire_dc_bit_y_x_1: STD_LOGIC  bus:= '0';
	signal wire_dc_bit_y_x_2: STD_LOGIC bus := '0';
	
	signal wire_clk_0_1: STD_LOGIC bus := '0';
	signal wire_clk_1_2: STD_LOGIC bus := '0';
	signal wire_clk_2_3: STD_LOGIC bus := '0';
	
begin

	seg <= 
		wire_seg0 when curent_segment = 1 else
		wire_seg1 when curent_segment = 2 else
		wire_seg2 when curent_segment = 3 else
		wire_seg3 when curent_segment = 4;
	
	segment0 <= '0' when curent_segment = 1 or reset = '1' else '1';
	segment1 <= '0' when curent_segment = 2 or reset = '1' else '1';
	segment2 <= '0' when curent_segment = 3 or reset = '1' else '1';
	segment3 <= '0' when curent_segment = 4 or reset = '1' else '1';
	
	das_tx_inst: data_serializer 
	generic map(
		DBIT => data_bus_width
	) port map (
		clk 				=> clk,
		reset 			=> reset,
		data_in			=> wire_data_in,
		tx_start			=> wire_tx_start,		--запуск передачи данных
		--tx_done_tick	=>				--импульс завершения передачи данных
		das_sdi			=> wire_dc_bit_x,
		das_clk			=> wire_das_clk,
		das_reset		=> wire_das_reset
	);
	
	dc_ddc_0: dc_ddc_segment port map (
		in_clk 	=> wire_das_clk,
		reset	=> wire_das_reset,
		fix	=> wire_fix,
		mult	=> '0',
		dc_x => wire_dc_bit_x,
		out_clk => wire_clk_0_1,
		dc_bit_y	=> wire_dc_bit_y_x_0,
		ddc_seg	=> wire_hex0
	);
	dc_ddc_1: dc_ddc_segment port map (
		in_clk 	=> wire_clk_0_1,
		reset	=> wire_das_reset,
		fix	=> wire_fix,
		mult	=> '0',
		dc_x => wire_dc_bit_y_x_0,
		out_clk => wire_clk_1_2,
		dc_bit_y	=> wire_dc_bit_y_x_1,
		ddc_seg	=> wire_hex1
	);
	dc_ddc_2: dc_ddc_segment port map (
		in_clk 	=> wire_clk_1_2,
		reset	=> wire_das_reset,
		fix	=> wire_fix,
		mult	=> '0',
		dc_x => wire_dc_bit_y_x_1,
		out_clk => wire_clk_2_3,
		dc_bit_y	=> wire_dc_bit_y_x_2,
		ddc_seg	=> wire_hex2
	);
	dc_ddc_3: dc_ddc_segment port map (
		in_clk 	=> wire_clk_2_3,
		reset	=> wire_das_reset,
		fix	=> wire_fix,
		mult	=> '0',
		dc_x => wire_dc_bit_y_x_2,
		ddc_seg	=> wire_hex3
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
	
	cal_curent_segment: process(reset, clk)
		variable curent_value	: INTEGER range 0 to 2000000 := 0;
	begin
		if(reset = '1') then
			curent_value := 0;
			curent_segment <= 1;
		elsif(clk'event and clk = '1') then
			wire_tx_start <= '0';
			if(curent_value < (clock_freq / update_freq)) then
			--if(curent_value < 20) then --Для тестирования чтоб не ждать долго.
				curent_value := curent_value + 1;
			else
				curent_value := 0;
				wire_data_in <= data;
				wire_tx_start <= '1';
				if(curent_segment < 4) then
					curent_segment <= curent_segment + 1;
				else
					curent_segment <= 1;
				end if;
			end if;
		end if;
	end process;
	
end architecture tube_light;

configuration digital_tube_cnf of digital_tube is
	for tube_light	
		for
			dc_ddc_0: dc_ddc_segment use entity work.dc_ddc_segment(dc_ddc_fisic);
		end for;
		for
			dc_ddc_1: dc_ddc_segment use entity work.dc_ddc_segment(dc_ddc_fisic);
		end for;
		for
			dc_ddc_2: dc_ddc_segment use entity work.dc_ddc_segment(dc_ddc_fisic);
		end for;
		for
			dc_ddc_3: dc_ddc_segment use entity work.dc_ddc_segment(dc_ddc_fisic);
		end for;
		for
			S0: bcd_7_segment use entity work.bcd_7_segment(seg);
		end for;
		for
			S1: bcd_7_segment use entity work.bcd_7_segment(seg);
		end for;
		for
			S2: bcd_7_segment use entity work.bcd_7_segment(seg);
		end for;
		for
			S3: bcd_7_segment use entity work.bcd_7_segment(seg);
		end for;
		for
			das_tx_inst: data_serializer use entity work.data_serializer(das_tx);
		end for;
	end for;
end configuration digital_tube_cnf;
