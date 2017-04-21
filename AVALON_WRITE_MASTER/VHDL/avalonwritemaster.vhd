--###############################
--# Project Name : 
--# File         : 
--# Author       : Philippe THIRION
--# Description  : Avalon memory Map Write Master Interface
--# Modification History
--#
--###############################

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library RAM_LIB;
--use RAM_LIB.all;

entity avalonwritemaster is
	port(
		MCLK							: in	std_logic;
		nRST							: in	std_logic;
		DIN								: in	std_logic_vector(31 downto 0);
		LAST							: in	std_logic;
		READ							: out	std_logic;
		WRITE							: in	std_logic;
		FIFO_FULL						: out	std_logic;
		SET_FULL						: out	std_logic;
		ADDR							: in	std_logic_vector(15 downto 0);
		START							: in	std_logic;
		ABORT							: in	std_logic;
		IDLE							: out	std_logic;
		AVALON_ADDRESS					: out	std_logic_vector(15 downto 0);
		AVALON_BEGINBURSTTRANSFER		: out	std_logic;
		AVALON_BURSTCOUNT				: out	std_logic_vector(3 downto 0);
		AVALON_WRITE					: out	std_logic;
		AVALON_WRITEDATA				: out	std_logic_vector(31 downto 0);
		AVALON_WAITREQUEST				: in	std_logic
	);
end avalonwritemaster;

architecture struct of avalonwritemaster is
-- COMPONENTS --
	component avalonwriteburst
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			AVALON_ADDRESS		: out	std_logic_vector(15 downto 0);
			AVALON_BEGINBURSTTRANSFER		: out	std_logic;
			AVALON_BURSTCOUNT		: out	std_logic_vector(3 downto 0);
			AVALON_WRITE		: out	std_logic;
			AVALON_WRITEDATA		: out	std_logic_vector(31 downto 0);
			AVALON_WAITREQUEST		: in	std_logic;
			ADDR		: in	std_logic_vector(15 downto 0);
			START		: in	std_logic;
			ABORT		: in	std_logic;
			IDLE		: out	std_logic;
			FIFO_DATAFROM		: in	std_logic_vector(31 downto 0);
			FIFO_EMPTY		: in	std_logic;
			FIFO_LAST		: in	std_logic;
			FIFO_READ		: out	std_logic;
			FIFO_MAXBURSTSIZE		: in	std_logic_vector(3 downto 0);
			FIFO_CLEARBURST		: out	std_logic
		);
	end component;
	component fifo_counter
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			FIFO_CLEARBURST		: in	std_logic;
			FIFO_MAXBURSTSIZE		: out	std_logic_vector(3 downto 0);
			FIFO_FULL		: in	std_logic;
			FIFO_WRITE		: in	std_logic;
			ABORT			: in	std_logic
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
	component fifo_adapter
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			FIFO_EMPTY_IN		: in	std_logic;
			FIFO_EMPTY_OUT		: out	std_logic;
			DIN		: in	std_logic_vector(31 downto 0);
			DOUT		: out	std_logic_vector(31 downto 0);
			FIFO_READ_IN		: in	std_logic;
			FIFO_READ_OUT		: out	std_logic;
			ABORT				: in	std_logic
		);
	end component;

	
	signal WRADDRESS : std_logic_vector(2 downto 0);
	signal RDADDRESS : std_logic_vector(2 downto 0);
	signal logic_0 : std_logic;
	signal zero32 : std_logic_vector(31 downto 0);
	signal data_a : std_logic_vector(31 downto 0);
	signal q_b : std_logic_vector(31 downto 0);
	signal q_b_i : std_logic_vector(31 downto 0);
	signal q_b_a : std_logic_vector(31 downto 0);
	signal FIFO_LAST : std_logic;
	signal FIFO_DATAFROM : std_logic_vector(31 downto 0);
	signal FIFO_EMPTY_IN : std_logic;
	signal FIFO_READ  : std_logic;
	signal FIFO_MAXBURSTSIZE : std_logic_vector(3 downto 0);
	signal FIFO_CLEARBURST : std_logic;
	signal FIFO_WRITE : std_logic;
	signal fifo_full_i : std_logic;
	signal FIFO_EMPTY_OUT : std_logic;
	signal FIFO_NEXT  : std_logic;
	signal LAST_WORD  : std_logic;
begin

	logic_0 <= '0';
	zero32 <= (others=>'0');
	data_a(31 downto 0) <= DIN;
	FIFO_DATAFROM <= q_b_a(31 downto 0);
	FIFO_WRITE <= WRITE and not(fifo_full_i);
	FIFO_FULL <= fifo_full_i;
	q_b_i(31 downto 0) <= q_b;
	
	FIFO_LAST <= LAST;
	
	READ <= FIFO_NEXT;

	-- PORT MAP --
	I_RAM : dp8x32
		port map (
			address_a => WRADDRESS,
			address_b => RDADDRESS,
			clock_a => MCLK,
			clock_b => MCLK,
			data_a => data_a,
			data_b => zero32,
			wren_a => FIFO_WRITE,
			wren_b => logic_0,
			q_a => open,
			q_b => q_b
		);
	I_avalonwriteburst_0 : avalonwriteburst
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			AVALON_ADDRESS		=> AVALON_ADDRESS,
			AVALON_BEGINBURSTTRANSFER		=> AVALON_BEGINBURSTTRANSFER,
			AVALON_BURSTCOUNT		=> AVALON_BURSTCOUNT,
			AVALON_WRITE		=> AVALON_WRITE,
			AVALON_WRITEDATA		=> AVALON_WRITEDATA,
			AVALON_WAITREQUEST		=> AVALON_WAITREQUEST,
			ADDR		=> ADDR,
			START		=> START,
			ABORT		=>	ABORT,
			IDLE		=> IDLE,
			FIFO_DATAFROM		=> FIFO_DATAFROM,
			FIFO_EMPTY		=> FIFO_EMPTY_OUT,
			FIFO_LAST		=> FIFO_LAST,
			FIFO_READ		=> FIFO_NEXT,
			FIFO_MAXBURSTSIZE		=> FIFO_MAXBURSTSIZE,
			FIFO_CLEARBURST		=> FIFO_CLEARBURST
		);
	I_fifo_counter_0 : fifo_counter
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			FIFO_CLEARBURST		=> FIFO_CLEARBURST,
			FIFO_MAXBURSTSIZE		=> FIFO_MAXBURSTSIZE,
			FIFO_FULL		=> fifo_full_i,
			FIFO_WRITE		=> FIFO_WRITE,
			ABORT			=> ABORT
		);
	I_fifo_control_0 : fifo_control
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			FIFO_WRITE		=> FIFO_WRITE,
			FIFO_READ		=> FIFO_READ,
			WRADDRESS		=> WRADDRESS,
			RDADDRESS		=> RDADDRESS,
			FIFO_FULL		=> fifo_full_i,
			SET_FULL		=> SET_FULL,
			SET_EMPTY		=> LAST_WORD,
			FIFO_EMPTY		=> FIFO_EMPTY_IN,
			ABORT			=> ABORT
		);
	I_fifo_adapter_0 : fifo_adapter
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			FIFO_EMPTY_IN		=> FIFO_EMPTY_IN,
			FIFO_EMPTY_OUT	=> FIFO_EMPTY_OUT,
			DIN				=> q_b_i,
			DOUT			=> q_b_a,
			FIFO_READ_IN		=> FIFO_NEXT,
			FIFO_READ_OUT	=> FIFO_READ,
			ABORT			=> ABORT
		);
	
end struct;

