--###############################
--# Project Name : 
--# File         : 
--# Author       : Philippe THIRION
--# Description  : Avalon Memory Map Read Master Interface (Burst generator)
--# Modification History
--#
--###############################

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity avalonreadburst is
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
		ADDRESS		: std_logic_vector(15 downto 0);
		WORDLEN		: in	std_logic_vector(7 downto 0);
		FIFO_EMPTY		: in	std_logic;
		FIFO_WRITE		: out	std_logic;
		FIFO_DIN		: out	std_logic_vector(31 downto 0)
	);
end avalonreadburst;

architecture rtl of avalonreadburst is
type t_state is (S_IDLE, S_START, S_WAIT, S_NEWBURST, S_INBURST);
signal state : t_state;

signal bigburstcount : std_logic_vector(4 downto 0); 	-- 8 words burst counter
signal smallburstsize : std_logic_vector(2 downto 0); 	-- less than 8 words burst size
signal wordcount  : std_logic_vector(2 downto 0);		-- in burst counter
signal internal_address : std_logic_vector(15 downto 0);
signal avalon_read_i : std_logic;

begin

	AVALON_READ <= avalon_read_i;
	FIFO_DIN <= AVALON_READDATA;
	--FIFO_WRITE <= AVALON_READDATAVALID and avalon_read_i;
	FIFO_WRITE <= AVALON_READDATAVALID;
	
	POTO: process(MCLK,RSTN)
	begin
		if (RSTN = '0') then
				AVALON_ADDRESS <= (others=>'1');
				AVALON_BEGINBURSTTRANSFER <= '0';
				AVALON_BURSTCOUNT <= (others=>'0');
				avalon_read_i <= '0';
				IDLE <= '1';
				state <= S_IDLE;
				smallburstsize <= (others=>'0');
				bigburstcount <= (others=>'0');
				wordcount <= (others=>'0');
				internal_address <= (others=>'0');
		elsif (MCLK'event and MCLK='1') then
			if (ABORT='1') then
				state <= S_IDLE;
			end if;
			if (state = S_IDLE) then
				AVALON_ADDRESS <= (others=>'1');
				AVALON_BEGINBURSTTRANSFER <= '0';
				AVALON_BURSTCOUNT <= (others=>'0');
				avalon_read_i <= '0';
				IDLE <= '1';
				if (START='1') then
					internal_address <= ADDRESS;
					smallburstsize <= WORDLEN(2 downto 0);
					bigburstcount <= WORDLEN(7 downto 3);
					state <= S_WAIT;
				else
					state <= S_IDLE;
				end if;
			elsif (state = S_WAIT) then
				IDLE <= '0';
				if (FIFO_EMPTY='1') then
					if (bigburstcount = "00000") then
						if (smallburstsize = "000") then
							state <= S_IDLE;
						else 
							wordcount <= std_logic_vector(unsigned(smallburstsize)-1);
							state <= S_NEWBURST;
						end if;
					else
						wordcount <= "111";
						state <= S_NEWBURST;
					end if;
				end if;
			elsif (state = S_NEWBURST) then
				IDLE <= '0';
				AVALON_ADDRESS <= internal_address;
				AVALON_BURSTCOUNT <= std_logic_vector(unsigned('0' & wordcount)+1);
				AVALON_BEGINBURSTTRANSFER <= '1';
				avalon_read_i <= '1';	
				state <= S_INBURST;
			elsif (state = S_INBURST) then
				IDLE <= '0';
				AVALON_BEGINBURSTTRANSFER <= '0';
				if (AVALON_READDATAVALID = '1') then
					internal_address <= std_logic_vector(unsigned(internal_address)+4);
					if (wordcount = "000") then
						if (bigburstcount = "00000") then
							smallburstsize <= (others=>'0');
						else
							bigburstcount <= std_logic_vector(unsigned(bigburstcount)-1);
						end if;
						AVALON_BURSTCOUNT <= (others=>'0');
						state <= S_WAIT;
					else
						wordcount <= std_logic_vector(unsigned(wordcount)-1);
					end if;
				end if;
				if (AVALON_WAITREQUEST='0') then
					avalon_read_i <= '0';
				end if;
				--end if;
			end if;
		end if;
	end process POTO;

end rtl;

