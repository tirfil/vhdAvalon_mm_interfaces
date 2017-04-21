--###############################
--# Project Name : --
--# File         : avalon_slave.vhd
--# Author       : Philippe THIRION
--# Description  : AVALON MM Slave interface
--# Modification History
--#	PT 17 Mar 2017 creation
--#	
--###############################

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity AVALON_SLAVE is
	port(
		CLK							: in	std_logic;
		nRST						: in	std_logic;
		AVALON_ADDRESS				: in	std_logic_vector(15 downto 0);
		AVALON_BYTEENABLE			: in	std_logic_vector(3 downto 0);
		AVALON_READ					: in	std_logic;
		AVALON_WAITREQUEST			: out	std_logic;
		AVALON_WRITE				: in	std_logic;
		AVALON_WRITEDATA			: in	std_logic_vector(31 downto 0);
		AVALON_READDATA				: out	std_logic_vector(31 downto 0);
		AVALON_READDATAVALID		: out	std_logic;
		R_LONG						: out	std_logic;
		R_SHORT						: out	std_logic;
		W_LONG						: out	std_logic;
		W_SHORT						: out	std_logic;
		ADDRESS						: out	std_logic_vector(15 downto 0);
		BYTEENABLE					: out	std_logic_vector(3 downto 0);
		D_FROM_AVALON				: out	std_logic_vector(31 downto 0);
		D_TO_AVALON					: in	std_logic_vector(31 downto 0);
		TWAIT						: in	std_logic_vector(1 downto 0)
	);
end AVALON_SLAVE;

architecture rtl of AVALON_SLAVE is
	type t_state is (S_IDLE, S_READ1, S_READ2, S_WRITE, S_TW2, S_TW3);
	signal state: t_state;
	signal avalon_address_a : std_logic_vector(15 downto 0);
	signal avalon_byteenable_a : std_logic_vector(3 downto 0);
	signal avalon_waitrequest_a : std_logic;
	signal r_a : std_logic;
	signal w_a : std_logic;
	signal rwn : std_logic;
	signal avalon_readdatavalid_i : std_logic;
begin

ADDRESS <= AVALON_ADDRESS when (state=S_IDLE) else avalon_address_a;
BYTEENABLE <= AVALON_BYTEENABLE when (state=S_IDLE) else avalon_byteenable_a;

R_LONG  <= '1' when (state=S_IDLE and TWAIT="00" and AVALON_READ = '1')  else r_a;
W_SHORT <= '1' when (state=S_IDLE and TWAIT="00" and AVALON_WRITE = '1') else w_a;

AVALON_WAITREQUEST <= '0' when (state=S_IDLE and TWAIT="00") else avalon_waitrequest_a;
D_FROM_AVALON <= AVALON_WRITEDATA;
AVALON_READDATA <= D_TO_AVALON;

R_SHORT <= avalon_readdatavalid_i;
AVALON_READDATAVALID <= avalon_readdatavalid_i;
--W_LONG <= '0' when (state = S_IDLE) else AVALON_WRITE; -- added
W_LONG <= AVALON_WRITE;

POTO: process(CLK, nRST)
begin
	if (nRST = '0') then
		avalon_waitrequest_a 		<= '1';
		avalon_readdatavalid_i 		<= '0';
		avalon_address_a			<= (others=>'1');
		avalon_byteenable_a			<= (others=>'0');
		r_a <= '0';
		w_a <= '0';
		rwn <= '0';
		state <= S_IDLE;
	elsif (CLK'event and CLK = '1') then
		if (state=S_IDLE) then
			if ( AVALON_WRITE = '1') then
				if (TWAIT="00") then
					state <= S_IDLE;
				else
					avalon_address_a <= AVALON_ADDRESS;
					avalon_byteenable_a <= AVALON_BYTEENABLE;
					if (TWAIT="01") then
						w_a <= '1';
						avalon_waitrequest_a <= '0';
						state <= S_WRITE;
					else
						w_a <= '0';
						rwn	<= '0';
						avalon_waitrequest_a <= '1';
						if (TWAIT="10") then
							state <= S_TW2;
						else
							state <= S_TW3;
						end if;
					end if;
				end if;
			elsif (AVALON_READ = '1') then
				avalon_address_a <= AVALON_ADDRESS;
				avalon_byteenable_a <= AVALON_BYTEENABLE;
				if (TWAIT="00") then
					avalon_waitrequest_a <= '0';
					avalon_readdatavalid_i <= '1';
					r_a <= '1';
					state <= S_READ2;
				else
					avalon_waitrequest_a <= '1';
					avalon_readdatavalid_i <= '0';
					r_a <= '1';
					rwn <= '1';
					if (TWAIT="01") then
						state <= S_READ1;
					elsif(TWAIT="10") then
						state <= S_TW2;
					else
						state <= S_TW3;
					end if;
				end if;
			end if;
		elsif(state=S_WRITE) then
			w_a <= '0';
			avalon_waitrequest_a <= '1';
			avalon_address_a <= (others=>'1');
			avalon_byteenable_a	<= (others=>'0');
			state <= S_IDLE;
		elsif(state=S_READ1) then
			avalon_waitrequest_a <= '0';
			avalon_readdatavalid_i <= '1';
			r_a <= '1';
			state <= S_READ2;
		elsif(state=S_READ2) then
			avalon_waitrequest_a <= '1';
			avalon_readdatavalid_i <= '0';
			r_a <= '0';
			rwn <= '0';
			state <= S_IDLE;
		elsif(state=S_TW2) then
			if (rwn ='0') then
				w_a <= '1';
				avalon_waitrequest_a <= '0';
				state <= S_WRITE;
			else
				state <= S_READ1;
			end if;
		elsif(state=S_TW3) then
			state <= S_TW2;
		end if;
	end if;
end process POTO;

end rtl;
