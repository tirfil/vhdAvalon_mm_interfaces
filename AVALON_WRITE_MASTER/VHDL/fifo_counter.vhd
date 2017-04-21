--###############################
--# Project Name : 
--# File         : 
--# Author       : Philippe THIRION
--# Description  : Count word number inside the fifo
--# Modification History
--#
--###############################

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fifo_counter is
	port(
		MCLK					: in	std_logic;
		nRST					: in	std_logic;
		FIFO_CLEARBURST			: in	std_logic;
		FIFO_MAXBURSTSIZE		: out	std_logic_vector(3 downto 0);
		FIFO_FULL				: in	std_logic;
		FIFO_WRITE				: in	std_logic;
		ABORT					: in	std_logic
	);
end fifo_counter;

architecture rtl of fifo_counter is
	signal counter : std_logic_vector(3 downto 0);
	signal write : std_logic;
	signal write_q : std_logic;
	signal pair : std_logic_vector(1 downto 0);
begin
	FIFO_MAXBURSTSIZE <= counter;
	write <= FIFO_WRITE and not(FIFO_FULL);
	pair(0) <= write_q;
	pair(1) <= FIFO_CLEARBURST;
	PCNT: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			counter <= (others=>'0');
			write_q <= '0';
		elsif (MCLK'event and MCLK = '1') then
			if (ABORT='1') then
				counter <= (others=>'0');
				write_q <= '0';
			else
				write_q <= write;
				case pair is
					when "11" => counter <= (0=>'1',others=>'0');
					when "01" => counter <= std_logic_vector(unsigned(counter)+1);
					when "10" => counter <= (others=>'0');
					when others => counter <= counter;
				end case;
			end if;
		end if;
	end process PCNT;

end rtl;

