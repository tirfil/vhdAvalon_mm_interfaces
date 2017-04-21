--###############################
--# Project Name : 
--# File         : 
--# Author       : Philippe THIRION
--# Description  : Clock Domain Crossing fifo
--# Modification History
--#
--###############################

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library RAM_LIB;
use RAM_LIB.all;

entity cdcfifo8 is
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
		SET_FULL	: out   std_logic;
		FULL		: out	std_logic;
		EMPTY		: out	std_logic;
		ABORT_RD	: in	std_logic;
		ABORT_WR	: in	std_logic
	);
end cdcfifo8;

architecture struct of cdcfifo8 is
	
	component wrfifo8
		port(
			WCLK		: in	std_logic;
			WRESET		: in	std_logic;
			WRITE		: in	std_logic;
			WGRAY		: out	std_logic_vector(2 downto 0);
			WADR		: out	std_logic_vector(2 downto 0);
			RGRAY		: in	std_logic_vector(2 downto 0);
			SET_FULL	: out   std_logic;
			FULL		: out	std_logic;
			ABORT_WR	: in	std_logic
		);
	end component;

	component rdfifo8
		port(
			RCLK		: in	std_logic;
			RRESET		: in	std_logic;
			READ		: in	std_logic;
			READ_OUT	: out	std_logic;
			RGRAY		: out	std_logic_vector(2 downto 0);
			RADR		: out	std_logic_vector(2 downto 0);
			WGRAY		: in	std_logic_vector(2 downto 0);
			EMPTY		: out	std_logic;
			ABORT_RD	: in	std_logic
		);
	end component;
	
	component dp8x32
		port(
		address_a		: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		clock_a			: IN STD_LOGIC  := '1';
		clock_b			: IN STD_LOGIC  := '1';
		data_a			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data_b			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		wren_a			: IN STD_LOGIC  := '0';
		wren_b			: IN STD_LOGIC  := '0';
		q_a				: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		q_b				: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	end component;
	
	signal WRESET 	: std_logic;
	signal RRESET 	: std_logic;
	signal WGRAY  	: std_logic_vector(2 downto 0);
	signal RGRAY  	: std_logic_vector(2 downto 0);
	signal WADR	  	: std_logic_vector(2 downto 0);
	signal RADR	  	: std_logic_vector(2 downto 0);
	signal LOGIC_0 	: std_logic;
	signal LOGIC_1 	: std_logic;
	signal zero32	: std_logic_vector(31 downto 0);

begin

	LOGIC_0 <= '0';
	LOGIC_1 <= '1';
	zero32 <= (others=>'0');
	
	WRESET <= WRSTN;
	RRESET <= RRSTN;
	
	I_wrfifo8_0 : wrfifo8
		port map (
			WCLK		=> WCLK,
			WRESET		=> WRESET,
			WRITE		=> WRITE,
			WGRAY		=> WGRAY,
			WADR		=> WADR,
			RGRAY		=> RGRAY,
			SET_FULL	=> SET_FULL,
			FULL		=> FULL,
			ABORT_WR	=> ABORT_WR
		);
	I_rdfifo8_0 : rdfifo8
		port map (
			RCLK		=> RCLK,
			RRESET		=> RRESET,
			READ		=> READ,
			READ_OUT	=> READ_OUT,
			RGRAY		=> RGRAY,
			RADR		=> RADR,
			WGRAY		=> WGRAY,
			EMPTY		=> EMPTY,
			ABORT_RD	=> ABORT_RD
		);
	I_dpram8 : dp8x32
		port map (
			address_a => WADR,
			address_b => RADR,
			clock_a   => WCLK,
			clock_b   => RCLK,
			data_a 	  => DIN,
			data_b	  => zero32,  -- hope simplification
			wren_a	  => WRITE,
			wren_b	  => LOGIC_0,	-- always read
			q_a		  => open, 		-- not used
			q_b		  => DOUT
		);
			
	
end struct;

