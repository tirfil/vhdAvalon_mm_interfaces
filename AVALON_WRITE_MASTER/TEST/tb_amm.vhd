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

entity tb_amm is
end tb_amm;

architecture stimulus of tb_amm is


	constant DMA_HPERIOD : time := 10 ns;

-- COMPONENTS --
-- COMPONENTS --
	component avalonwritemaster
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			DIN		: in	std_logic_vector(31 downto 0);
			LAST		: in	std_logic;
			READ		: out	std_logic;
			WRITE		: in	std_logic;
			FIFO_FULL		: out	std_logic;
			SET_FULL		: out	std_logic;
			ADDR		: in	std_logic_vector(15 downto 0);
			START		: in	std_logic;
			IDLE		: out	std_logic;
			ABORT		: in	std_logic;
			AVALON_ADDRESS		: out	std_logic_vector(15 downto 0);
			AVALON_BEGINBURSTTRANSFER		: out	std_logic;
			AVALON_BURSTCOUNT		: out	std_logic_vector(3 downto 0);
			AVALON_WRITE		: out	std_logic;
			AVALON_WRITEDATA		: out	std_logic_vector(31 downto 0);
			AVALON_WAITREQUEST		: in	std_logic
		);
	end component;
	component dma_wr_driver
		port(
			MCLK		: in	std_logic;
			RSTn		: in	std_logic;
			DMA_REQUEST		: in	std_logic;
			DMA_LEN		: in	std_logic_vector(8 downto 0);
			DMA_ADDRESS		: in	std_logic_vector(31 downto 0);
			DMA_RD		: out	std_logic;
			DMA_END		: out	std_logic;
			DMA_ERR		: out	std_logic;
			DMA_OK		: out	std_logic;
			DMA_ABORT	: out	std_logic;
			FIFO_FULL		: in	std_logic;
			WORDLEN		: out	std_logic_vector(6 downto 0);
			ADDRESS		: out	std_logic_vector(31 downto 0);
			T_END		: in	std_logic;
			T_REQUEST		: out	std_logic;
			T_ACK		: in	std_logic;
			ABORT		: in	std_logic
		);
	end component;
	
	component avalon_wr_driver
		port(
			MCLK		: in	std_logic;
			RSTn		: in	std_logic;
			T_REQUEST		: in	std_logic;
			T_ACK		: out	std_logic;
			WORDLEN		: in	std_logic_vector(6 downto 0);
			START		: out	std_logic;
			IDLE		: in	std_logic;
			T_END		: out	std_logic;
			LAST		: out	std_logic;
			READ		: in	std_logic;
			ABORT		: in	std_logic			
		);
	end component;
	
	
--
-- SIGNALS --
	signal MCLK		: std_logic;
	signal nRST		: std_logic;
	signal DIN		: std_logic_vector(31 downto 0);
	signal LAST		: std_logic;
	signal READ		: std_logic;
	signal FIFO_FULL		: std_logic;
	signal FIFO_FULL_D		: std_logic;
	signal ADDR		: std_logic_vector(15 downto 0);
	signal START		: std_logic;
	signal IDLE		: std_logic;
	signal AVALON_ADDRESS		: std_logic_vector(15 downto 0);
	signal AVALON_BEGINBURSTTRANSFER		: std_logic;
	signal AVALON_BURSTCOUNT		: std_logic_vector(3 downto 0);
	signal AVALON_WRITE		: std_logic;
	signal AVALON_WRITEDATA		: std_logic_vector(31 downto 0);
	signal AVALON_WAITREQUEST		: std_logic;
	signal lfsr						: std_logic_vector(16 downto 0);
	
	signal DMA_REQUEST		: std_logic;
	signal DMA_LEN		: std_logic_vector(8 downto 0);
	signal DMA_ADDRESS		: std_logic_vector(31 downto 0);
	signal DMA_RD		: std_logic;
	signal DMA_END		: std_logic;
	signal DMA_ERR		: std_logic;
	signal DMA_OK		: std_logic;
	--signal FIFO_FULL	: std_logic;
	signal WORDLEN		: std_logic_vector(6 downto 0);
	signal ADDRESS		: std_logic_vector(31 downto 0);
	signal T_REQUEST		: std_logic;
	signal T_ACK		: std_logic;
	
	signal T_END		: std_logic;
	
	signal ABORT		: std_logic := '0';
	
	
	signal number					: integer := 1;

--
	signal RUNNING	: std_logic := '1';
	
	signal change : std_logic;
	signal DMA_DATA		: std_logic_vector(31 downto 0);

begin

-- PORT MAP --
	I_awmtop_0 : avalonwritemaster
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			DIN		=> DIN,
			LAST		=> LAST,
			READ 		=> READ,
			WRITE		=> DMA_RD,
			FIFO_FULL		=> FIFO_FULL,
			ADDR		=> ADDRESS(15 downto 0),
			START		=> START,
			IDLE		=> IDLE,
			ABORT		=> ABORT,
			AVALON_ADDRESS		=> AVALON_ADDRESS,
			AVALON_BEGINBURSTTRANSFER		=> AVALON_BEGINBURSTTRANSFER,
			AVALON_BURSTCOUNT		=> AVALON_BURSTCOUNT,
			AVALON_WRITE		=> AVALON_WRITE,
			AVALON_WRITEDATA		=> AVALON_WRITEDATA,
			AVALON_WAITREQUEST		=> AVALON_WAITREQUEST
		);

	I_dma_wr_driver_0 : dma_wr_driver
		port map (
			MCLK		=> MCLK,
			RSTn		=> nRST,
			DMA_REQUEST		=> DMA_REQUEST,
			DMA_LEN		=> DMA_LEN,
			DMA_ADDRESS		=> DMA_ADDRESS,
			DMA_RD		=> DMA_RD,
			DMA_END		=> DMA_END,
			DMA_ERR		=> DMA_ERR,
			DMA_OK		=> DMA_OK,
			FIFO_FULL		=> FIFO_FULL,
			WORDLEN		=> WORDLEN,
			ADDRESS		=> ADDRESS,
			T_END	=> T_END,
			T_REQUEST		=> T_REQUEST,
			T_ACK		=> T_ACK,
			ABORT		=> ABORT
		);

	I_avalon_wr_driver_0 : avalon_wr_driver
		port map (
			MCLK		=> MCLK,
			RSTn		=> nRST,
			T_REQUEST		=> T_REQUEST,
			T_ACK		=> T_ACK,
			WORDLEN		=> WORDLEN,
			START		=> START,
			IDLE		=> IDLE,
			T_END		=> T_END,
			LAST		=> LAST,
			READ		=> READ,
			ABORT		=> ABORT
		);
--
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
	
	PWREQ : process
	begin
		while (RUNNING = '1') loop
			if (lfsr(1 downto 0) = "11") then
				AVALON_WAITREQUEST <= '0' after 1 ns;
				wait for 20 ns;
			else
				AVALON_WAITREQUEST <= '1' after 1 ns;
				wait for 20 ns;
			end if;
		end loop;
		wait;
	end process PWREQ;

	change <= DMA_RD or DMA_END;
	DIN <= DMA_DATA;
	
	GO: process
	procedure send( 
		signal lfsr   : in std_logic_vector;
		signal number : inout integer;
		constant size : in integer) is
	begin
		wait for 1 ns;
		DMA_REQUEST <= '1' after 1 ns;
		DMA_LEN <= std_logic_vector(to_unsigned(size*4,9))after 1 ns;
		DMA_ADDRESS <= std_logic_vector(to_unsigned(size*4,32))after 1 ns;
		DMA_DATA <= std_logic_vector(to_unsigned(number,32))after 1 ns;
		wait until change'event and change='1';
		wait for DMA_HPERIOD;
		while (DMA_END ='0') loop
			wait until DMA_RD'event and DMA_RD='0';
			number <= number + 1;
			wait for 1 ns;
			DMA_REQUEST <= '0' after 1 ns;
			DMA_DATA <= std_logic_vector(to_unsigned(number,32))after 1 ns;
			wait until change'event and change='1';
			wait for DMA_HPERIOD;
		end loop;
		wait until DMA_END'event and DMA_END='0';
		--number <= number + 1;
		--wait for 1 ns;
		DMA_REQUEST <= '0' after 1 ns;
	end send;
		procedure send0( 
		signal lfsr   : in std_logic_vector;
		signal number : inout integer;
		constant size : in integer) is
	begin
		wait for 1 ns;
		DMA_REQUEST <= '1' after 1 ns;
		DMA_LEN <= std_logic_vector(to_unsigned(size*4,9))after 1 ns;
		DMA_ADDRESS <= std_logic_vector(to_unsigned(size*4,32))after 1 ns;
		DMA_DATA <= std_logic_vector(to_unsigned(number,32))after 1 ns;
		wait until DMA_END'event and DMA_END='0';
		DMA_REQUEST <= '0' after 1 ns;
	end send0;
	begin
		--number <= 1;
		nRST <= '0';
		--AVALON_WAITREQUEST <= '0';
		DMA_DATA <= (others=>'0');
		DMA_REQUEST <= '0';
		DMA_ADDRESS <= (others=>'0');
		DMA_LEN <= (others=>'0');
		--START <= '0';
		wait for 1000 ns;
		nRST <= '1';
		wait for 100 ns;
		

		send0(lfsr,number,0);
		
		for i in 1 to 10 loop
			send(lfsr,number,i);
			report integer'image(number);
		end loop;
		
		send0(lfsr,number,0);
		
		for i in 1 to 10 loop
			wait for 100 ns;
			send(lfsr,number,i);
			report integer'image(number);
		end loop;
		
		send0(lfsr,number,0);
		
		for i in 1 to 10 loop
			 while (lfsr(3 downto 0) /= "0000") loop
				 wait for 20 ns;
			 end loop;
			send(lfsr,number,i);
			report integer'image(number);
		end loop;				
		
		RUNNING <= '0'after 1 ns;
		wait;
	end process GO;
	
	PPP : process(MCLK)
		variable value : integer;
		variable test  : integer := 1;
	begin
		if (MCLK'event and MCLK = '1') then
			if (AVALON_WRITE='1' and AVALON_WAITREQUEST='0') then
				value := to_integer(unsigned(AVALON_WRITEDATA));
				report integer'image(value) & "/" & integer'image(test);
				assert value = test report "wrong value" severity failure;
				test := test + 1;
			end if;
		end if;
	end process PPP;

end stimulus;
