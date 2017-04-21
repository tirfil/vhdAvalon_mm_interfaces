--###############################
--# Project Name : 
--# File         : 
--# Author       : Philippe THIRION
--# Description  : Enable to connect two synchronous fifos in serial
--# Modification History
--#
--###############################

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fifo_inter is
	port(
		MCLK			: in	std_logic;
		nRST			: in	std_logic;
		EMPTY			: in	std_logic;
		SET_FULL			: in	std_logic;
		FULL			: in	std_logic;
		DIN				: in	std_logic_vector(31 downto 0);
		DOUT			: out	std_logic_vector(31 downto 0);
		FIFO_READ		: out	std_logic;
		FIFO_WRITE		: out	std_logic;
		ABORT			: in	std_logic
	);
end fifo_inter;

architecture rtl of fifo_inter is
	
	signal fifo_read_i : std_logic;
	signal fifo_write_i : std_logic;
	signal fifo_read_q : std_logic;
	signal fifo_read_qq : std_logic;
	signal reg : std_logic_vector(31 downto 0);
	signal preloaded : std_logic;

begin

	FIFO_READ <= fifo_read_i;
	fifo_read_i <= '1' when (EMPTY = '0' and ( FULL = '0' and SET_FULL = '0') ) else '0';
	FIFO_WRITE  <= fifo_write_i;
	fifo_write_i <= '1' when (preloaded = '1' and FULL='0') else '0';
	
	DOUT <= reg;

	P_RESYNC: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			fifo_read_q 	<= '0';
			fifo_read_qq 	<= '0';
		elsif (MCLK'event and MCLK = '1') then
			fifo_read_q 	<= fifo_read_i;
			fifo_read_qq	<= fifo_read_q;
		end if;
	end process P_RESYNC;
	
	P_REG: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			reg <= (others=>'1');
		elsif (MCLK'event and MCLK = '1') then
			if (fifo_read_q = '1') then
				reg <= DIN;
			end if;
		end if;
	end process P_REG;
	
	P_LOAD: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			preloaded <= '0';
		elsif (MCLK'event and MCLK = '1') then
			if (ABORT='1') then
				preloaded <= '0';
			elsif (fifo_read_q = '1') then
				preloaded <= '1';
			elsif (fifo_write_i = '1' ) then
				preloaded <= '0';
			end if;
		end if;
	end process P_LOAD;
	

end rtl;

