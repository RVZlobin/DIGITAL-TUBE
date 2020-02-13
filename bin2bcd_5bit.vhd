library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity bin2bcd_5bit is
	generic(
		data_bus_width	: INTEGER := 14;
		lcd_d_count		: INTEGER := 4
	);
	port(
		reset: in STD_LOGIC := '0';
		bus_data:in STD_LOGIC_VECTOR(data_bus_width - 1 downto 0) := (others => '0');
		bcd1:out STD_LOGIC_VECTOR(3 downto 0) := (others => '1');
		bcd10:out STD_LOGIC_VECTOR(3 downto 0) := (others => '1');
		bcd100:out STD_LOGIC_VECTOR(3 downto 0) := (others => '1');
		bcd1000:out STD_LOGIC_VECTOR(3 downto 0) := (others => '1')
	);

end entity bin2bcd_5bit;

architecture converter of bin2bcd_5bit is
begin
	process(bus_data, reset)
		variable i : integer range 0 to 9999;
		variable data : integer range 0 to 9999;
	begin
		if(reset = '1') then
			bcd1 <= (others => '1');
			bcd10 <= (others => '1');
			bcd100 <= (others => '1');
			bcd1000 <= (others => '1');
		else
			i := conv_integer(bus_data);
			if(i > 9999) then 
				bcd1 <= "1111";
				bcd10 <= "1111";
				bcd100 <= "1111";
				bcd1000 <= "1111";
			else
				if(i >= 0) then
					data := i mod 10;
					bcd1 <= CONV_STD_LOGIC_VECTOR(data, 4);
					i := i - data;
				else
					bcd1 <= (others => '0');
				end if;
				if(i >= 10) then
					data := i mod 100;
					i := i - data;
					data := data / 10;
					bcd10 <= CONV_STD_LOGIC_VECTOR(data, 4);
				else
					bcd10 <= (others => '0');
				end if;
				if(i >= 100) then
					data := i mod 1000;
					i := i - data;
					data := data / 100;
					bcd100 <= CONV_STD_LOGIC_VECTOR(data, 4);
				else
					bcd100 <= (others => '0');
				end if;
				if(i >= 1000) then
					data := i mod 10000;
					i := i - data;
					data := data / 1000;
					bcd1000 <= CONV_STD_LOGIC_VECTOR(data, 4);
				else
					bcd1000 <= (others => '0');
				end if;
			end if;
		end if;
	end process;
end converter;
