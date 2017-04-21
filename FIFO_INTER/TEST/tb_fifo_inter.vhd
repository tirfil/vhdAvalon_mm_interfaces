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

library RAM_LIB;
use RAM_LIB.all;

entity tb_fifo_inter is
end tb_fifo_inter;

architecture stimulus of tb_fifo_inter is

-- COMPONENTS --
	component fifo_inter
		port(
			MCLK			: in	std_logic;
			nRST			: in	std_logic;
			EMPTY			: in	std_logic;
			SET_FULL			: in	std_logic;
			FULL			: in	std_logic;
			DIN				: in	std_logic_vector(31 downto 0);
			DOUT			: out	std_logic_vector(31 downto 0);
			FIFO_READ		: out	std_logic;
			FIFO_WRITE		: out	std_logic;
			ABORT			: in	std_logic
		);
	end component;
	component dp8x32
	PORT
	(
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
	component fifo_control
		port(
			MCLK			: in	std_logic;
			nRST			: in	std_logic;
			FIFO_WRITE		: in	std_logic;
			FIFO_READ		: in	std_logic;
			WRADDRESS		: out	std_logic_vector(2 downto 0);
			RDADDRESS		: out	std_logic_vector(2 downto 0);
			FIFO_FULL_D		: out	std_logic;
			FIFO_FULL		: out	std_logic;
			FIFO_EMPTY_D	: out	std_logic;
			FIFO_EMPTY		: out	std_logic
		);
	end component;

--
-- SIGNALS --
	signal MCLK		: std_logic;
	signal nRST		: std_logic;
	signal EMPTY		: std_logic;
	signal FULL_D		: std_logic;
	signal FULL		: std_logic;
	signal DIN		: std_logic_vector(31 downto 0);
	signal DOUT		: std_logic_vector(31 downto 0);
	signal FIFO_READ		: std_logic;
	signal FIFO_WRITE		: std_logic;
	signal ABORT			: std_logic := '0';


	signal zero32	: std_logic_vector(31 downto 0) := (others=>'0');
	signal logic_0  : std_logic := '0';
	
	signal TEST_WRITE		: std_logic;
	signal TEST_FULL		: std_logic;
	signal TEST_DIN			: std_logic_vector(31 downto 0);
	
	signal TEST_READ		: std_logic;
	signal TEST_EMPTY		: std_logic;
	signal TEST_DOUT			: std_logic_vector(31 downto 0);	
	
	signal WRADDRESS0		: std_logic_vector(2 downto 0);
	signal RDADDRESS0		: std_logic_vector(2 downto 0);	
	signal WRADDRESS1		: std_logic_vector(2 downto 0);
	signal RDADDRESS1		: std_logic_vector(2 downto 0);
	
	signal lfsr						: std_logic_vector(16 downto 0);
	
	signal test_read_q				: std_logic;
	signal test_empty_q				: std_logic;
	
	signal test_write0				: std_logic;
	
	--signal number					: integer := 1;
	
--
	signal RUNNING	: std_logic := '1';
	

begin


	test_write0 <= TEST_WRITE and not(TEST_FULL);

-- PORT MAP --
	I_fifo_inter_0 : fifo_inter
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			EMPTY		=> EMPTY,
			FULL		=> FULL,
			SET_FULL		=> FULL_D,
			DIN			=> DIN,
			DOUT		=> DOUT,
			FIFO_READ	=> FIFO_READ,
			FIFO_WRITE	=> FIFO_WRITE,
			ABORT		=> ABORT
		);
		
	I_fifo_control_0 : fifo_control
		port map (
			MCLK			=> MCLK,
			nRST			=> nRST,
			FIFO_WRITE		=> TEST_WRITE,
			FIFO_READ		=> FIFO_READ,
			WRADDRESS		=> WRADDRESS0,
			RDADDRESS		=> RDADDRESS0,
			FIFO_FULL_D		=> open,
			FIFO_FULL		=> TEST_FULL,
			FIFO_EMPTY_D	=> open,
			FIFO_EMPTY		=> EMPTY
		);
	I_RAM_0 : dp8x32
		port map (
			address_a => WRADDRESS0,
			address_b => RDADDRESS0,
			clock_a => MCLK,
			clock_b => MCLK,
			data_a => TEST_DIN,
			data_b => zero32,
			wren_a => test_write0,
			wren_b => logic_0,
			q_a => open,
			q_b => DIN
		);
	I_fifo_control_1 : fifo_control
		port map (
			MCLK			=> MCLK,
			nRST			=> nRST,
			FIFO_WRITE		=> FIFO_WRITE,
			FIFO_READ		=> TEST_READ,
			WRADDRESS		=> WRADDRESS1,
			RDADDRESS		=> RDADDRESS1,
			FIFO_FULL_D		=> FULL_D,
			FIFO_FULL		=> FULL,
			FIFO_EMPTY_D	=> open,
			FIFO_EMPTY		=> TEST_EMPTY
		);
	I_RAM_1 : dp8x32
		port map (
			address_a => WRADDRESS1,
			address_b => RDADDRESS1,
			clock_a => MCLK,
			clock_b => MCLK,
			data_a => DOUT,
			data_b => zero32,
			wren_a => FIFO_WRITE,
			wren_b => logic_0,
			q_a => open,
			q_b => TEST_DOUT
		);	
		
		
	PLFSR: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			--lfsr <= (0=>'1',others=>'0');
			--lfsr <= (others=>'1');
			lfsr <= "11100011100011100";
		elsif (MCLK'event and MCLK = '1') then
			lfsr(0) <= lfsr(16) xor lfsr(13);
			lfsr(16 downto 1) <= lfsr(15 downto 0);
		end if;
	end process PLFSR;
	
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
	procedure send( 
		signal lfsr   : in std_logic_vector;
		variable number : inout integer;
		constant size : in integer) is
	begin
		for i in 1 to size loop
			TEST_DIN <= std_logic_vector(to_unsigned(number,32)) after 1 ns;
			number := number + 1; -- after 20 ns;
			while (lfsr(1 downto 0) /= "00") loop
				TEST_WRITE<='0' after 1 ns;
				wait for 20 ns;
			end loop;
			
			TEST_WRITE <= '1' after 1 ns;
			wait for 20 ns;
			
			while (TEST_FULL = '1') loop
				TEST_WRITE<='1' after 1 ns;
				wait for 20 ns;
			end loop;

		end loop;
		TEST_WRITE<='0' after 1 ns;
		wait until MCLK='1' and MCLK'event;
	end send;
	variable number : integer := 1;
	begin
		--TEST_FULL <= '0';
		--EMPTY <= '0';
		--FIFO_READ <= '0';
		nRST <= '0';
		TEST_WRITE <= '0';
		--TEST_READ <= '1';
		TEST_DIN <= (others=>'1');
		wait for 1000 ns;
		nRST <= '1';
		wait for 20 ns;
		send(lfsr,number,100000);
		wait for 10000 ns;
		RUNNING <= '0';
		wait;
	end process GO;
	
	GOR: process
	begin
		TEST_READ <= '0' ;
		while (RUNNING = '1') loop
			while (TEST_EMPTY = '1' and RUNNING = '1') loop
				TEST_READ <= '0' after 1 ns;
				wait for 20 ns;
			end loop;
			while ((lfsr(16 downto 15) /= "11") and (RUNNING = '1')) loop
				TEST_READ <= '0' after 1 ns;
				wait for 20 ns;
			end loop; 
			if (TEST_EMPTY = '0') then
				TEST_READ <= '1' after 1 ns;
			end if;
			wait for 20 ns;
		end loop;
		wait;
	end process GOR;
	
	PPP : process(MCLK)
		variable value : integer;
		variable test  : integer := 1;
	begin
		if (MCLK'event and MCLK = '1') then
			test_read_q <= TEST_READ; 
			test_empty_q <= TEST_EMPTY;
			if (test_read_q = '1' and test_empty_q = '0') then
				value := to_integer(unsigned(TEST_DOUT));
				--report integer'image(value);
				report integer'image(value) & "/" & integer'image(test);
				assert value = test report "wrong value" severity error;
				test := test + 1;
			end if;
		end if;
	end process PPP;
	

end stimulus;
