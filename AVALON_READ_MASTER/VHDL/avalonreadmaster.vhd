--###############################
--# Project Name : 
--# File         : 
--# Author       : Philippe THIRION
--# Description  : Avalon Memory Map Read Master Interface
--# Modification History
--#
--###############################

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity avalonreadmaster is
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
		FIFO_DOUT		: out	std_logic_vector(31 downto 0);
		FIFO_READ		: in	std_logic;
		FIFO_EMPTY		: out	std_logic
	);
end avalonreadmaster;

architecture struct of avalonreadmaster is
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
	component fifo_control
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
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
	end component;
	component dp8x32
		port(
		address_a	: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		address_b	: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		clock_a		: IN STD_LOGIC  := '1';
		clock_b		: IN STD_LOGIC 	:= '1';
		data_a		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data_b		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		wren_a		: IN STD_LOGIC  := '0';
		wren_b		: IN STD_LOGIC  := '0';
		q_a			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		q_b			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	end component;
	
signal MASTER_READ : std_logic;
signal MASTER_WRITE : std_logic;
signal MASTER_EMPTY : std_logic;
signal MASTER_DATA : std_logic_vector(31 downto 0);
signal WRADDRESS : std_logic_vector(2 downto 0);
signal RDADDRESS : std_logic_vector(2 downto 0);
signal zero32 : std_logic_vector(31 downto 0);
signal logic_0 : std_logic;
signal logic_1 : std_logic;

begin
	zero32 <= (others=>'0');
	logic_0 <= '0';
	logic_1 <= '1';
	FIFO_EMPTY <= MASTER_EMPTY;

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
			START		=> START, -- in
			IDLE		=> IDLE,
			ADDRESS		=> ADDRESS(15 downto 0),
			WORDLEN		=> WORDLEN,  --
			FIFO_EMPTY		=> MASTER_EMPTY,
			FIFO_WRITE		=> MASTER_WRITE, -- out
			FIFO_DIN		=> MASTER_DATA -- out
		);
	I_fifo_control_0 : fifo_control
		port map (
			MCLK		=> MCLK,
			nRST		=> RSTN,
			FIFO_WRITE		=> MASTER_WRITE, -- in
			FIFO_READ		=> MASTER_READ, --in
			WRADDRESS		=> WRADDRESS,
			RDADDRESS		=> RDADDRESS,
			FIFO_FULL		=> open,
			SET_FULL		=> open,
			SET_EMPTY			=> open,
			FIFO_EMPTY		=> MASTER_EMPTY,
			ABORT			=> ABORT
		);
	I_RAM : dp8x32
		port map (
			address_a => WRADDRESS,
			address_b => RDADDRESS,
			clock_a => MCLK,
			clock_b => MCLK,
			data_a => MASTER_DATA, -- in
			data_b => zero32,
			wren_a => MASTER_WRITE, -- in
			wren_b => logic_0,
			q_a => open,
			q_b => FIFO_DOUT -- out
		);

end struct;

