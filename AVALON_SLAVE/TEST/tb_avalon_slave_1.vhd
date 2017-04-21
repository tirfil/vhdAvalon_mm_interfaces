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
	signal R_LONG		: std_logic;
	signal R_SHORT		: std_logic;
	signal W_SHORT		: std_logic;
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
			R_LONG		=> R_LONG,
			W_SHORT		=> W_SHORT,
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
	
	TWAIT <= ADDRESS(3 downto 2); -- address decoding

	GO: process
	--
	procedure amm_write(	address : in integer;
						data	    : in integer
					) is
	begin
		--wait for clk'event and clk='1';
		AVALON_ADDRESS <= std_logic_vector(to_unsigned(address,16));
		AVALON_WRITEDATA <= std_logic_vector(to_unsigned(data,32));
		AVALON_BYTEENABLE	<= (others =>'0');
		AVALON_WRITE 		<= '1';
		wait until clk'event and clk='1';
		while ( AVALON_WAITREQUEST='1') loop
			wait until clk'event and clk='1';
		end loop;
		AVALON_WRITE 		<= '0';
	end procedure amm_write;
	--
	procedure amm_read(	address : in integer
						 ) is
	begin
		--wait for clk'event and clk='1';
		AVALON_ADDRESS <= std_logic_vector(to_unsigned(address,16));
		AVALON_BYTEENABLE	<= (others =>'0');
		AVALON_READ 		<= '1';
		wait until clk'event and clk='1';
		while ( AVALON_WAITREQUEST='1') loop
			wait until clk'event and clk='1';
		end loop;
		while ( AVALON_READDATAVALID='0') loop
			wait until clk'event and clk='1';
		end loop;
		AVALON_READ 		<= '0';
	end procedure amm_read;
	begin
		nRST <= '0';
		AVALON_READ 		<= '0';
		AVALON_WRITE 		<= '0';
		AVALON_ADDRESS		<= (others =>'0');
		AVALON_BYTEENABLE	<= (others =>'0');
		AVALON_WRITEDATA	<= (others =>'1');
		D_TO_AVALON			<= std_logic_vector(to_unsigned(100000000,32));
		wait for 501 ns;
		nRST <= '1';
		wait for 200 ns;
		amm_write(16#1230#,200200200); -- tw0
		amm_read(16#3210#);
		amm_write(16#2344#,300300300); -- tw1
		amm_read(16#2464#);
		amm_read(16#3210#); -- tw0
		amm_write(16#0178#,101010101); -- tw2
		amm_read(16#2228#);
		amm_write(16#1230#,200200200); -- tw0
		amm_write(16#AAAC#,001122233); -- tw3
		amm_read(16#333C#); -- tw3
		amm_write(16#1230#,200200200); -- tw0
		amm_read(16#3210#);
		RUNNING <= '0';
		wait;
	end process GO;
	
	DISPLAY: process(CLK)
	variable data : integer;
	variable addr : integer;
	begin
		if (clk'event and clk='1') then
			if (AVALON_READDATAVALID='1') then
				addr := to_integer(unsigned(ADDRESS));
				data := to_integer(unsigned(AVALON_READDATA));
				report "read " & integer'image(data) & " at " & integer'image(addr);
			end if;
			if (W_SHORT='1') then
				addr := to_integer(unsigned(ADDRESS));
				data := to_integer(unsigned(D_FROM_AVALON));
				report "write " & integer'image(data) & " at " & integer'image(addr);
			end if;
		end if;
	end process DISPLAY;

end stimulus;
