--###############################
--# Project Name : 
--# File         : 
--# Author       : 
--# Description  : 
--# Modification History
--#
--###############################

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_cdcfifo8 is
end tb_cdcfifo8;

architecture stimulus of tb_cdcfifo8 is

-- COMPONENTS --
	component cdcfifo8
		port(
			RCLK		: in	std_logic;
			WCLK		: in	std_logic;
			RRSTN		: in	std_logic;
			WRSTN		: in	std_logic;
			DIN			: in	std_logic_vector(31 downto 0);
			DOUT		: out	std_logic_vector(31 downto 0);
			WRITE		: in	std_logic;
			READ		: in	std_logic;
			READ_OUT	: out	std_logic;
			SET_FULL		: out	std_logic;
			FULL		: out	std_logic;
			EMPTY		: out	std_logic;
			ABORT_RD	: in 	std_logic;
			ABORT_WR	: in 	std_logic
		);
	end component;

--
-- SIGNALS --
	signal RCLK		: std_logic;
	signal WCLK		: std_logic;
	signal WRSTN		: std_logic;
	signal RRSTN		: std_logic;
	signal DIN		: std_logic_vector(31 downto 0);
	signal DOUT		: std_logic_vector(31 downto 0);
	signal WRITE	: std_logic;
	signal READ		: std_logic;
	signal FULL		: std_logic;
	signal EMPTY	: std_logic;
	signal READ_OUT	: std_logic;
	signal SET_FULL	: std_logic;
	signal ABORT_RD : std_logic := '0';
	signal ABORT_WR	: std_logic := '0';

--
	signal RUNNING	: std_logic := '1';

begin

-- PORT MAP --
	I_cdcfifo8_0 : cdcfifo8
		port map (
			RCLK		=> RCLK,
			WCLK		=> WCLK,
			WRSTN		=> WRSTN,
			RRSTN		=> RRSTN,
			DIN			=> DIN,
			DOUT		=> DOUT,
			WRITE		=> WRITE,
			READ		=> READ,
			READ_OUT	=> READ_OUT,
			FULL		=> FULL,
			SET_FULL	=> SET_FULL,
			EMPTY		=> EMPTY,
			ABORT_RD	=> ABORT_RD,
			ABORT_WR	=> ABORT_WR
		);

--
	WCLOCK: process
	begin
		while (RUNNING = '1') loop
			WCLK <= '1';
			wait for 11 ns;
			WCLK <= '0';
			wait for 11 ns;
		end loop;
		wait;
	end process WCLOCK;
	
	RCLOCK: process
	begin
		while (RUNNING = '1') loop
			RCLK <= '1';
			wait for 9 ns;
			RCLK <= '0';
			wait for 9 ns;
		end loop;
		wait;
	end process RCLOCK;

	PRESET: process
	begin
		RRSTN <= '0';
		WRSTN <= '0';
		wait for 1000 ns;
		RRSTN <= '1';
		WRSTN <= '1';		
		wait;
	end process PRESET;
	
	WR: process
	begin
		WRITE <= '0';
		DIN <= (others=>'0');
		wait until WRSTN = '1';
		wait until WCLK'event and WCLK='1';
		wait until WCLK'event and WCLK='1';
		for i in 0 to 255 loop
			while (FULL = '1') loop
				WRITE <= '0';
				wait until WCLK'event and WCLK='1';
			end loop;
			WRITE <= '1';
			DIN <= std_logic_vector(to_unsigned(i,32));
			wait until WCLK'event and WCLK='1';
		end loop;
		wait;
	end process WR;
	
	RD: process
	begin
		READ <= '0';
		wait until RRSTN = '1';
		wait until RCLK'event and RCLK='1';
		wait until RCLK'event and RCLK='1';
		for i in 0 to 255 loop
			while (EMPTY = '1') loop
				READ <= '0';
				wait until RCLK'event and RCLK='1';
			end loop;
			READ <= '1';
			wait until RCLK'event and RCLK='1';
			wait for 0 ns; -- next delta time (DOUT has changed)
			assert (to_integer(unsigned(DOUT)) = i) report "failed" severity error;
		end loop;
		RUNNING <= '0';
		wait;
	end process RD;	

end stimulus;
