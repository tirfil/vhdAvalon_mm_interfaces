--###############################
--# Project Name : 
--# File         : 
--# Author       : Philippe THIRION
--# Description  : Fifo dual port ram controller
--# Modification History
--#
--###############################

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fifo_control is
	port(
		MCLK			: in	std_logic;
		nRST			: in	std_logic;
		FIFO_WRITE		: in	std_logic;
		FIFO_READ		: in	std_logic;
		WRADDRESS		: out	std_logic_vector(2 downto 0);
		RDADDRESS		: out	std_logic_vector(2 downto 0);
		FIFO_FULL		: out	std_logic;
		SET_FULL		: out	std_logic;
		SET_EMPTY		: out	std_logic;
		FIFO_EMPTY		: out	std_logic;
		ABORT			: in	std_logic
	);
end fifo_control;

architecture rtl of fifo_control is
	signal wraddr_i : std_logic_vector(2 downto 0);
	signal rdaddr_i : std_logic_vector(2 downto 0);
	signal next_wraddr : std_logic_vector(2 downto 0);
	signal next_rdaddr : std_logic_vector(2 downto 0);
	signal fifo_empty_i : std_logic;
	signal fifo_full_i : std_logic;
begin
	WRADDRESS <= wraddr_i;
	RDADDRESS <= rdaddr_i;
	FIFO_EMPTY <= fifo_empty_i;
	FIFO_FULL <= fifo_full_i;
	next_wraddr <= (others=>'0') when wraddr_i = "111" else std_logic_vector(unsigned(wraddr_i)+1);
	next_rdaddr <= (others=>'0') when rdaddr_i = "111" else std_logic_vector(unsigned(rdaddr_i)+1);
	SET_EMPTY <= '1' when (FIFO_READ='1' and fifo_empty_i='0') and (next_rdaddr = wraddr_i) and (FIFO_WRITE='0') else '0';
	SET_FULL <= '1' when (FIFO_WRITE='1' and fifo_full_i='0') and (next_wraddr = rdaddr_i) and (FIFO_READ='0') else '0';
	POTO: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			fifo_full_i <= '0';
			fifo_empty_i <= '1';
			wraddr_i <= (others=>'0');
			rdaddr_i <= (others=>'0');
		elsif (MCLK'event and MCLK = '1') then
			if (ABORT='1') then
				fifo_full_i <= '0';
				fifo_empty_i <= '1';
				wraddr_i <= (others=>'0');
				rdaddr_i <= (others=>'0');
			else
				if (FIFO_WRITE='1' and fifo_full_i='0') then
					wraddr_i <= next_wraddr;
					if (next_wraddr = rdaddr_i) then
						if (FIFO_READ='0') then
							fifo_full_i <= '1';
						end if;
					end if;
					fifo_empty_i <= '0';
				end if;
				if (FIFO_READ='1' and fifo_empty_i='0') then
					rdaddr_i <= next_rdaddr;
					if (next_rdaddr = wraddr_i) then
						if (FIFO_WRITE='0') then
							fifo_empty_i <= '1';
						end if;
					end if;
					fifo_full_i <= '0';
				end if;
			end if;
		end if;
	end process POTO;

end rtl;

