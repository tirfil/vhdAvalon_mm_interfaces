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

entity avalonwriteburst is
	port(
		MCLK						: in	std_logic;
		nRST						: in	std_logic;
		AVALON_ADDRESS				: out	std_logic_vector(15 downto 0);
		AVALON_BEGINBURSTTRANSFER	: out	std_logic;
		AVALON_BURSTCOUNT			: out	std_logic_vector(3 downto 0);
		AVALON_WRITE				: out	std_logic;
		AVALON_WRITEDATA			: out	std_logic_vector(31 downto 0);
		AVALON_WAITREQUEST			: in	std_logic;
		ADDR						: in	std_logic_vector(15 downto 0);
		START						: in	std_logic;
		ABORT						: in	std_logic;
		IDLE						: out	std_logic;
		FIFO_DATAFROM				: in	std_logic_vector(31 downto 0);
		FIFO_EMPTY					: in	std_logic;
		FIFO_LAST					: in	std_logic;
		FIFO_READ					: out	std_logic;
		FIFO_MAXBURSTSIZE			: in	std_logic_vector(3 downto 0);
		FIFO_CLEARBURST				: out	std_logic
	);
end avalonwriteburst;

architecture RTL of avalonwriteburst is
	type state_t is (S_IDLE, S_BEGINBURST, S_STARTBURST, S_BURST, S_NEXTBURST, S_BEGINBURST2 );
	signal state : state_t;
	signal internal_address : std_logic_vector(15 downto 0);
	signal remaining_word 	: integer range 0 to 15;
	signal waitrequest_q 	: std_logic;
	signal fifo_last_q		: std_logic;
	signal fifo_read_i		: std_logic;
	signal fifo_empty_q		: std_logic;
	signal avalon_write_i 	: std_logic;
	signal first_read		: std_logic;	
begin

	FIFO_READ 		<= fifo_read_i;
	AVALON_WRITE 	<= avalon_write_i;
	fifo_read_i 	<= (avalon_write_i and not(AVALON_WAITREQUEST)) or first_read;
	
	PWD : process(MCLK, nRST)
	begin
		if (nRST = '0') then
			AVALON_WRITEDATA <= (others=>'1');
			fifo_last_q		 <= '0';
		elsif (MCLK'event and MCLK = '1') then
			if (first_read = '1') then
				AVALON_WRITEDATA <= FIFO_DATAFROM;
				fifo_last_q		 <= FIFO_LAST;
			elsif (fifo_read_i='1') then
				AVALON_WRITEDATA <= FIFO_DATAFROM;
				fifo_last_q		 <= FIFO_LAST;
			end if;
		end if;
	end process PWD;
			
	POTO: process(MCLK, nRST)
	variable burstsize : integer;
	begin
		if (nRST = '0') then
			IDLE <= '1';
			AVALON_ADDRESS <= (others=>'1');
			AVALON_BEGINBURSTTRANSFER <= '0';
			AVALON_BURSTCOUNT <= (others=>'0');
			FIFO_CLEARBURST <= '0';
			internal_address <= (others=>'0');
			remaining_word <= 0;
			avalon_write_i <= '0';
			first_read <= '0';
			fifo_empty_q <= '1';
			state <= S_IDLE;
		elsif (MCLK'event and MCLK = '1') then
			fifo_empty_q <= FIFO_EMPTY;
			if (ABORT='1') then
				state <= S_IDLE;
			end if;
			if (state = S_IDLE) then
				IDLE <= '1';
				AVALON_ADDRESS <= (others=>'1');
				AVALON_BEGINBURSTTRANSFER <= '0';
				AVALON_BURSTCOUNT <= (others=>'0');
				avalon_write_i <= '0';
				FIFO_CLEARBURST <= '0';
				internal_address <= (others=>'0');
				remaining_word <= 0;
				first_read <= '0';
				if (START = '1') then
					internal_address <= ADDR;
					state <= S_BEGINBURST;
					IDLE <= '0';
				end if;
			elsif (state = S_BEGINBURST) then
				if (fifo_empty_q = '0') then
					FIFO_CLEARBURST <= '1';
					first_read <= '1';
					state <= S_STARTBURST;
				end if;
			elsif (state = S_STARTBURST) then
				first_read <= '0';
				AVALON_ADDRESS <= internal_address;
				AVALON_BEGINBURSTTRANSFER <= '1';
				--AVALON_BURSTCOUNT <= FIFO_MAXBURSTSIZE;
				avalon_write_i <= '1';
				FIFO_CLEARBURST <= '0';
				-- verrue ???
				burstsize := to_integer(unsigned(FIFO_MAXBURSTSIZE));
				if burstsize = 0 then
					report "Warning max burst size is 0";
					AVALON_BURSTCOUNT <= (0=>'1',others=>'0');
					remaining_word <= 1;
				else
					AVALON_BURSTCOUNT <= FIFO_MAXBURSTSIZE;
					remaining_word <= burstsize;
				end if;
				state <= S_BURST;
			elsif (state = S_BURST) then
				AVALON_BEGINBURSTTRANSFER <= '0';
				if (AVALON_WAITREQUEST = '0' ) then
					internal_address <= std_logic_vector(unsigned(internal_address)+4);
					if (remaining_word = 1) then
						avalon_write_i <= '0';
						if (fifo_last_q = '1') then
							state <= S_IDLE;
						else
							state <= S_NEXTBURST;
						end if;
					end if;
					remaining_word <= remaining_word-1;
				end if;
			elsif (state = S_NEXTBURST) then
				if (fifo_empty = '1') then
					if (fifo_empty_q = '0') then
						-- avalon avalon_writedata is already the next value
						state <= S_BEGINBURST2;
					else
						-- avalon avalon_writedata value is dummy
						state <= S_BEGINBURST;
					end if;
				else
					avalon_write_i <= '0';
					remaining_word <= 0;
					FIFO_CLEARBURST <= '1';
					state <= S_STARTBURST;
				end if;
			elsif (state = S_BEGINBURST2) then
				if (fifo_empty_q = '0' or fifo_last_q = '1') then
				--if (fifo_empty_q = '0' ) then
					FIFO_CLEARBURST <= '1';
					--first_read <= '1';
					state <= S_STARTBURST;
				end if;
			end if;
		end if;
	end process POTO;
end RTL;

