library IEEE;
use IEEE.std_logic_1164.all;

entity bcd_7_segment is
    port (
		reset: IN STD_LOGIC := '0';
		hex: IN  STD_LOGIC_VECTOR (3 downto 0) := (others => '1');
      seg: OUT  STD_LOGIC_VECTOR (6 downto 0) := (others => '0')
   );
end bcd_7_segment;

architecture seg of bcd_7_segment is
begin
	process (hex, reset)
	begin
		if(reset = '1') then
			seg <="1000000";
		else
			case hex is
				when "0000"=> seg <="1000000";  -- '0'
				when "0001"=> seg <="1111001";  -- '1'
				when "0010"=> seg <="0100100";  -- '2'
				when "0011"=> seg <="0110000";  -- '3'
				when "0100"=> seg <="0011001";  -- '4' 
				when "0101"=> seg <="0010010";  -- '5'
				when "0110"=> seg <="0000010";  -- '6'
				when "0111"=> seg <="1111000";  -- '7'
				when "1000"=> seg <="0000000";  -- '8'
				when "1001"=> seg <="0010000";  -- '9'
				when "1010"=> seg <="0001000";  -- 'A'
				when "1011"=> seg <="0000011";  -- 'b'
				when "1100"=> seg <="1000110";  -- 'C'
				when "1101"=> seg <="0100001";  -- 'd'
				when "1110"=> seg <="0000110";  -- 'E'
				when "1111"=> seg <="0001110";  -- 'F'
				when others =>  NULL;
			end case;
		end if;
	end process;

end seg;