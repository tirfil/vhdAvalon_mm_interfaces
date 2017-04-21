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

entity tb_avalonreadburst is
end tb_avalonreadburst;

architecture stimulus of tb_avalonreadburst is

-- COMPONENTS --
	component avalonreadburst
		port(
			MCLK		: in	std_logic;
			RSTN		: in	std_logic;
			AVALON_ADDRESS		: out	std_logic_vector(15 downto 0);
			AVALON_BEGINBURSTTRANSFER		: out	std_logic;
			AVALON_BURSTCOUNT		: out	std_logic_vector(3 downto 0);
			AVALON_READ		: out	std_logic;
			AVALON_READDATA		: in	std_logic_vector(31 downto 0);
			AVALON_WAITREQUEST		: in	std_logic;
			AVALON_READDATAVALID		: in	std_logic;
			ABORT		: in	std_logic;
			START		: in	std_logic;
			IDLE		: out	std_logic;
			ADDRESS		: in	std_logic_vector(15 downto 0);
			WORDLEN		: in	std_logic_vector(7 downto 0);
			FIFO_EMPTY		: in	std_logic;
			FIFO_WRITE		: out	std_logic;
			FIFO_DIN		: out	std_logic_vector(31 downto 0)
		);
	end component;

--
-- SIGNALS --
	signal MCLK		: std_logic;
	signal RSTN		: std_logic;
	signal AVALON_ADDRESS		: std_logic_vector(15 downto 0);
	signal AVALON_BEGINBURSTTRANSFER		: std_logic;
	signal AVALON_BURSTCOUNT		: std_logic_vector(3 downto 0);
	signal AVALON_READ		: std_logic;
	signal AVALON_READDATA		: std_logic_vector(31 downto 0);
	signal AVALON_WAITREQUEST		: std_logic;
	signal AVALON_READDATAVALID		: std_logic;
	signal ABORT		: std_logic;
	signal START		: std_logic;
	signal IDLE		: std_logic;
	signal ADDRESS		: std_logic_vector(15 downto 0);
	signal WORDLEN		: std_logic_vector(7 downto 0);
	signal FIFO_EMPTY		: std_logic;
	signal FIFO_WRITE		: std_logic;
	signal FIFO_DIN		: std_logic_vector(31 downto 0);

--
	signal RUNNING	: std_logic := '1';

begin

-- PORT MAP --
	I_avalonreadburst_0 : avalonreadburst
		port map (
			MCLK		=> MCLK,
			RSTN		=> RSTN,
			AVALON_ADDRESS		=> AVALON_ADDRESS,
			AVALON_BEGINBURSTTRANSFER		=> AVALON_BEGINBURSTTRANSFER,
			AVALON_BURSTCOUNT		=> AVALON_BURSTCOUNT,
			AVALON_READ		=> AVALON_READ,
			AVALON_READDATA		=> AVALON_READDATA,
			AVALON_WAITREQUEST		=> AVALON_WAITREQUEST,
			AVALON_READDATAVALID		=> AVALON_READDATAVALID,
			ABORT		=> ABORT,
			START		=> START,
			IDLE		=> IDLE,
			ADDRESS		=> ADDRESS,
			WORDLEN		=> WORDLEN,
			FIFO_EMPTY		=> FIFO_EMPTY,
			FIFO_WRITE		=> FIFO_WRITE,
			FIFO_DIN		=> FIFO_DIN
		);

--
	CLOCK: process
	begin
		while (RUNNING = '1') loop
			MCLK <= '1';
			wait for 10 ns;
			MCLK <= '0';
			wait for 10 ns;
		end loop;
		wait;
	end process CLOCK;

	GO: process
	begin
		RSTN <= '0';
		ADDRESS <= (others=>'0');
		ABORT <= '0';
		FIFO_EMPTY <= '1';
		AVALON_WAITREQUEST <= '0';
		AVALON_READDATAVALID <= '0';
		AVALON_READDATA <= x"5555AAAA";
		WORDLEN <= "00011111";
		START <= '0';
		wait for 1001 ns;
		RSTN <= '1';
		wait for 100 ns;
		START <= '1';
		wait for 20 ns;
		START <= '0';
		for I in 1 to 100 loop
			AVALON_READDATAVALID <= '0';
			wait for 20 ns;
			AVALON_READDATAVALID <= '1';
			wait for 20 ns;
		end loop;
		RUNNING <= '0';
		wait;
	end process GO;

end stimulus;
