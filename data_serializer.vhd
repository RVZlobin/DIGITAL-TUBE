library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_serializer  is
	generic (
		DBIT: INTEGER := 10
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
end data_serializer;

architecture das_tx of data_serializer is
	type state_type is (idle, data, data_fix, stop);
	
	signal state_reg: state_type := idle;
	signal state_next: state_type := idle;
	signal count_reg: UNSIGNED(3 downto 0) := (others => '0');
	signal count_next: UNSIGNED(3 downto 0) := (others => '0');
	signal b_reg: STD_LOGIC_VECTOR(DBIT - 1 downto 0) := (others => 'X');
	signal b_next: STD_LOGIC_VECTOR(DBIT - 1 downto 0) := (others => 'X');
	signal tx_done_tick_reg: STD_LOGIC := '0';
	signal tx_done_tick_next: STD_LOGIC := '0';
	signal das_sdi_reg: STD_LOGIC := '0';
	signal das_sdi_next: STD_LOGIC := '0';
	signal das_clk_reg: STD_LOGIC := '0';
	signal das_clk_next: STD_LOGIC := '0';
	signal das_reset_reg: STD_LOGIC := '0';
	signal das_reset_next: STD_LOGIC := '0';
	
begin
	
	das_sdi <= das_sdi_reg after 2 ns;
	das_clk <= das_clk_reg after 2 ns;
	das_reset <= das_reset_reg after 2 ns;
	tx_done_tick <= tx_done_tick_reg after 2 ns;
	
	process (clk, state_next, reset)
	begin
		if (reset = '1') then
			state_reg <= idle;
			tx_done_tick_reg <= '0';
			das_sdi_reg <= '0';
			das_clk_reg <= '0';
			das_reset_reg <= '0';
			b_reg <= (others => 'X');
		elsif (falling_edge(clk)) then
			state_reg <= state_next;
			b_reg <= b_next;
			tx_done_tick_reg <= tx_done_tick_next;
			das_sdi_reg <= das_sdi_next;
			das_clk_reg <= das_clk_next;
			das_reset_reg <= das_reset_next;
			count_reg <= count_next;
		end if;
	end process;
	
	process (reset, clk, tx_start)
	begin
		if(reset = '1') then
			tx_done_tick_next <= '0';
			state_next <= idle;
			das_sdi_next <= '0';
			das_clk_next <= '0';
			das_reset_next <= '0';
			b_next <= (others => 'X');
		elsif(rising_edge(clk)) then
			tx_done_tick_next <= '0';
			das_reset_next <= '0';
			case state_reg is
				when idle =>
					if (tx_start = '1') then
						b_next <= data_in;
						state_next <= data;
						das_reset_next <= '1';
					end if;
				when data =>
					das_sdi_next <= b_reg(DBIT - 1);
					b_next <= b_reg(DBIT - 2 downto 0) & '0';
					das_clk_next <= '0';
					state_next <= data_fix;
				when data_fix =>
					das_clk_next <= '1';
					if(count_reg = DBIT - 1) then
						state_next <= stop;
						tx_done_tick_next <= '1';
					else
						state_next <= data;
					end if;
					count_next <= count_reg + 1;
				when stop =>
					das_sdi_next <= '0';
					das_clk_next <= '0';
					count_next <= (others => '0');
					state_next <= idle;
			end case;
		end if;
	end process;

end das_tx;