library ieee;
library WORK;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity dc_ddc_segment is
	generic(
		data_bus_width: INTEGER := 14
	);
	port(
		in_clk	: in STD_LOGIC := '0';
		reset		: in STD_LOGIC := '0';
		fix		: in STD_LOGIC := '0';
		mult		: in STD_LOGIC := '0';
		dc_x		: in STD_LOGIC := '0';
		out_clk	: out STD_LOGIC := '0';
		dc_bit_y	: out STD_LOGIC := '0';
		overflow	: out STD_LOGIC := '0';
		ddc_seg	: out STD_LOGIC_VECTOR (3 downto 0) := (others => '0')
	);

end entity dc_ddc_segment;

architecture dc_ddc_fisic of dc_ddc_segment is
	shared variable clk_edg_ivers : STD_LOGIC := '0';
	
	signal dc_bit_y_reg				: STD_LOGIC := '0';
	signal overflow_reg				: STD_LOGIC := '0';
	signal ddc_seg_reg				: STD_LOGIC_VECTOR(3 downto 0)  := (others => '0');
	signal clk_rising_edge_reg		: STD_LOGIC := '1';
	signal clk_falling_edge_reg	: STD_LOGIC := '1';
	signal out_clk_reg				: STD_LOGIC := '0';
	
begin
	
	out_clk 	<= '0' when reset = '1' else out_clk_reg after 2 ns;
	dc_bit_y <= '0' when reset = '1' else dc_bit_y_reg after 2 ns;
	overflow <= '0' when reset = '1' else overflow_reg after 2 ns;
	ddc_seg  <= (others => '0') when reset = '1' else ddc_seg_reg after 2 ns;
	
	dc_ddc_work_rising_process: process (in_clk, reset, dc_x, mult, fix)
		variable ddc_seg_temp: STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
		variable ddc_seg_m: STD_LOGIC_VECTOR(3 downto 0)  := (others => '0');
	begin
		if(reset = '1') then
			clk_rising_edge_reg	<= '1';
			dc_bit_y_reg			<= '0';
			overflow_reg			<= '0';
			clk_edg_ivers 			:= '0';
			ddc_seg_reg				<= (others => '0');
			ddc_seg_temp 			:= (others => '0');
			ddc_seg_m				:= (others => '0');
		elsif(rising_edge(in_clk)) then
			if(clk_rising_edge_reg = '1') then
				clk_edg_ivers := '1';
				clk_rising_edge_reg <= '0';
			else
				clk_edg_ivers := '0';
				clk_rising_edge_reg	<= '1';
			end if;
			if(fix = '0') then
				ddc_seg_temp := '0' & ddc_seg_m(3 downto 0);
				if(mult = '1') then
					ddc_seg_temp := ddc_seg_temp  + 1 ;
				end if;
				if(ddc_seg_temp > 4) then
					ddc_seg_temp := ddc_seg_temp + 3;
				end if;
				dc_bit_y_reg <= ddc_seg_temp(3);
				overflow_reg <= ddc_seg_temp(4);
				ddc_seg_m := ddc_seg_temp(2 downto 0) & dc_x;
				ddc_seg_reg <= ddc_seg_m;
			else
				dc_bit_y_reg <= dc_x;
			end if;
		end if;
	end process;
	
	dc_ddc_work_falling_process: process (in_clk, reset)
	begin
		if(reset = '1') then
			clk_falling_edge_reg <= '1';
		elsif(falling_edge(in_clk)) then
			if(clk_falling_edge_reg = '1') then
				clk_falling_edge_reg	<= '0';
			else
				clk_falling_edge_reg	<= '1';
			end if;
		end if;
	end process;
	
	out_clk_synthes : process (reset, clk_rising_edge_reg, clk_falling_edge_reg)
		variable p_m: STD_LOGIC_VECTOR(2 downto 0)  := (others => '0');
	begin
		if(reset = '1') then
			p_m := (others => '0');
			out_clk_reg <= '0';
		else
			p_m := clk_edg_ivers & clk_rising_edge_reg & clk_falling_edge_reg;
			case p_m is
				when "011" => out_clk_reg <= '0';  -- '0'
				when "101" => out_clk_reg <= '1';  -- '1'
				when "100" => out_clk_reg <= '0';  -- '2'
				when "010" => out_clk_reg <= '1';  -- '3'
				when others =>  NULL;
			end case;
		end if;
	end process;

end dc_ddc_fisic;