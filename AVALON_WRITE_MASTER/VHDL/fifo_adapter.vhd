--###############################
--# Project Name : 
--# File         : 
--# Author       : Philippe THIRION
--# Description  : Adapt a synchronous fifo (read side) with a "zero T wait" back pressure
--# Modification History
--#
--###############################

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fifo_adapter is
	port(
		MCLK			: in	std_logic;
		nRST			: in	std_logic;
		FIFO_EMPTY_IN	: in	std_logic;
		FIFO_EMPTY_OUT	: out	std_logic;
		DIN				: in	std_logic_vector(31 downto 0);
		DOUT			: out	std_logic_vector(31 downto 0);
		FIFO_READ_IN		: in	std_logic;
		FIFO_READ_OUT	: out 	std_logic;
		ABORT			: in	std_logic
	);
end fifo_adapter;

architecture rtl of fifo_adapter is

	-- register preload state machine
	type state_t is (S_IDLE,S_PRE,S_PRE2,S_CYCLE);
	signal state 		    : state_t;
	signal preloaded 	    : std_logic;
	signal reg 			    : std_logic_vector(31 downto 0);
	signal read_int		    : std_logic;
	signal fifo_read_q	    : std_logic;
	signal select_register	: std_logic;
	signal load_register	: std_logic;
	signal preloading   	: std_logic;
	signal fifo_empty_out_i	: std_logic;
	signal fifo_empty_q		: std_logic;

begin

	FIFO_READ_OUT <= FIFO_READ_IN or read_int;
	
	select_register <= 	(FIFO_READ_IN and not(fifo_read_q));  					  	-- use register content
	load_register <= (fifo_read_q and not(FIFO_READ_IN)) and not(fifo_empty_q);    -- write in register
	DOUT <= reg when preloaded='1' else DIN;

	fifo_empty_out_i <= '1' when preloading = '1'	else
					  '0' when preloaded = '1' 		else
					  '0' when load_register = '1'	else
					  fifo_empty_q;
					  --FIFO_EMPTY_IN;
					
	FIFO_EMPTY_OUT <= fifo_empty_out_i;
	
	PFR: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			fifo_read_q <= '0';
			fifo_empty_q <= '1';
		elsif (MCLK'event and MCLK = '1') then
			fifo_read_q <= FIFO_READ_IN;
			fifo_empty_q <= FIFO_EMPTY_IN;
		end if;
	end process PFR;
	
	-- register preload state machine
	PP: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			preloaded <= '0';
			state <= S_IDLE;
			preloading <= '1';
			read_int <= '0';
			reg <= (others=>'0');
		elsif (MCLK'event and MCLK = '1') then
			if (ABORT='1') then
				preloaded <= '0';
				state <= S_IDLE;
				preloading <= '1';
				read_int <= '0';
				reg <= (others=>'0');				
			elsif (state = S_IDLE) then
				state <= S_IDLE;
				preloading <= '1';
				if (FIFO_EMPTY_IN='0') then
					read_int <= '1';
					state <= S_PRE;
				end if;
			elsif (state = S_PRE) then
				read_int <= '0';
				state <= S_PRE2;
			elsif (state = S_PRE2) then
				reg <= DIN;
				preloaded <= '1';
				preloading <= '0';
				state <= S_CYCLE;
			elsif (state = S_CYCLE) then
				if (select_register='1') then
					assert (preloaded = '1') report "Error: register must be filled" severity error;
					preloaded <= '0';
				elsif (load_register='1') then
					reg <= DIN;
					preloaded <= '1';
				end if;
				if (fifo_empty_out_i = '1') then
					state <= S_IDLE;
					preloading <= '1';
				end if; 
			end if;
		end if;
	end process PP;
end rtl;

