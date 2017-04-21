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

entity tb_AVALON_SLAVE is
end tb_AVALON_SLAVE;

architecture stimulus of tb_AVALON_SLAVE is

-- COMPONENTS --
	component AVALON_SLAVE
		port(
			CLK		: in	std_logic;
			nRST		: in	std_logic;
			AVALON_ADDRESS		: in	std_logic_vector(15 downto 0);
			AVALON_BYTEENABLE		: in	std_logic_vector(3 downto 0);
			AVALON_READ		: in	std_logic;
			AVALON_WAITREQUEST		: out	std_logic;
			AVALON_WRITE		: in	std_logic;
			AVALON_WRITEDATA		: in	std_logic_vector(31 downto 0);
			AVALON_READDATA		: out	std_logic_vector(31 downto 0);
			AVALON_READDATAVALID		: out	std_logic;
			R_LONG		: out	std_logic;
			W_LONG		: out	std_logic;
			R_SHORT		: out	std_logic;
			W_SHORT		: out	std_logic;
			ADDRESS		: out	std_logic_vector(15 downto 0);
			BYTEENABLE		: out	std_logic_vector(3 downto 0);
			D_FROM_AVALON		: out	std_logic_vector(31 downto 0);
			D_TO_AVALON		: in	std_logic_vector(31 downto 0);
			TWAIT		: in	std_logic_vector(1 downto 0)
		);
	end component;

--
-- SIGNALS --
	signal CLK		: std_logic;
	signal nRST		: std_logic;
	signal AVALON_ADDRESS		: std_logic_vector(15 downto 0);
	signal AVALON_BYTEENABLE		: std_logic_vector(3 downto 0);
	signal AVALON_READ		: std_logic;
	signal AVALON_WAITREQUEST		: std_logic;
	signal AVALON_WRITE		: std_logic;
	signal AVALON_WRITEDATA		: std_logic_vector(31 downto 0);
	signal AVALON_READDATA		: std_logic_vector(31 downto 0);
	signal AVALON_READDATAVALID		: std_logic;
	signal R		: std_logic;
	signal W		: std_logic;
	signal ADDRESS		: std_logic_vector(15 downto 0);
	signal BYTEENABLE		: std_logic_vector(3 downto 0);
	signal D_FROM_AVALON		: std_logic_vector(31 downto 0);
	signal D_TO_AVALON		: std_logic_vector(31 downto 0);
	signal TWAIT		: std_logic_vector(1 downto 0);

--
	signal RUNNING	: std_logic := '1';

begin

-- PORT MAP --
	I_AVALON_SLAVE_0 : AVALON_SLAVE
		port map (
			CLK		=> CLK,
			nRST		=> nRST,
			AVALON_ADDRESS		=> AVALON_ADDRESS,
			AVALON_BYTEENABLE		=> AVALON_BYTEENABLE,
			AVALON_READ		=> AVALON_READ,
			AVALON_WAITREQUEST		=> AVALON_WAITREQUEST,
			AVALON_WRITE		=> AVALON_WRITE,
			AVALON_WRITEDATA		=> AVALON_WRITEDATA,
			AVALON_READDATA		=> AVALON_READDATA,
			AVALON_READDATAVALID		=> AVALON_READDATAVALID,
			R_LONG		=> R,
			W_SHORT		=> W,
			ADDRESS		=> ADDRESS,
			BYTEENABLE		=> BYTEENABLE,
			D_FROM_AVALON		=> D_FROM_AVALON,
			D_TO_AVALON		=> D_TO_AVALON,
			TWAIT		=> TWAIT
		);

--
	CLOCK: process
	begin
		while (RUNNING = '1') loop
			CLK <= '1';
			wait for 10 ns;
			CLK <= '0';
			wait for 10 ns;
		end loop;
		wait;
	end process CLOCK;

	GO: process
	begin
		nRST <= '0';
		AVALON_READ 		<= '0';
		AVALON_WRITE 		<= '0';
		AVALON_ADDRESS		<= (others =>'0');
		AVALON_BYTEENABLE	<= (others =>'0');
		AVALON_WRITEDATA	<= (others =>'1');
		D_TO_AVALON			<= (others =>'1');
		TWAIT <= "00";
		wait for 501 ns;
		nRST <= '1';
		wait for 200 ns;
		AVALON_READ		<= '1';
		AVALON_ADDRESS		<= (others =>'1');
		AVALON_BYTEENABLE	<= (others =>'1');
		wait for 40 ns;
		AVALON_READ		<= '0';
		wait for 100 ns;
		AVALON_WRITE		<= '1';
		AVALON_ADDRESS		<= (others =>'0');
		AVALON_BYTEENABLE	<= (others =>'0');
		wait for 40 ns;
		AVALON_WRITE		<= '0';	
		wait for 60 ns;
		TWAIT <= "11";
		D_TO_AVALON			<= (others =>'0');
		AVALON_READ		<= '1';
		AVALON_ADDRESS		<= (others =>'1');
		AVALON_BYTEENABLE	<= (others =>'1');
		wait for 40 ns;
		wait for 60 ns; -- add 3 cycles
		AVALON_READ		<= '0';
		wait for 100 ns;
		AVALON_WRITEDATA	<= (others =>'0');
		AVALON_WRITE		<= '1';
		AVALON_ADDRESS		<= (others =>'0');
		AVALON_BYTEENABLE	<= (others =>'0');
		wait for 40 ns;
		wait for 60 ns; -- add 3 cycles
		AVALON_WRITE		<= '0';	
		wait for 60 ns;
		TWAIT <= "01";
		D_TO_AVALON			<= (others =>'1');
		AVALON_READ		<= '1';
		AVALON_ADDRESS		<= (others =>'1');
		AVALON_BYTEENABLE	<= (others =>'1');
		wait for 40 ns;
		wait for 20 ns; -- add 1 cycle
		AVALON_READ		<= '0';
		wait for 100 ns;
		AVALON_WRITEDATA	<= (others =>'1');
		AVALON_WRITE		<= '1';
		AVALON_ADDRESS		<= (others =>'0');
		AVALON_BYTEENABLE	<= (others =>'0');
		wait for 40 ns;
		wait for 20 ns; -- add 1 cycle
		AVALON_WRITE		<= '0';	
		wait for 60 ns;
		RUNNING <= '0';
		wait;
	end process GO;

end stimulus;
