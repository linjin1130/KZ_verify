----------------------------------------------------------------------------------
-- Company: USTC
-- Engineer: LINZEHONG
-- 
-- Create Date:    18:51:50 01/20/2013 
-- Design Name: 
-- Module Name:    Rnd_Gen_TOP - Behavioral 
-- Project Name: 	 QKD_QND
-- Target Devices: VertexIIP40-FG676
-- Tool versions: Xilinx10.1.03
-- Description: generate random data
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Rnd_Gen_TOP is
	generic
    (
     BURST_LEN 		: integer := 1;   -- Data Width
     DATA_WIDTH 		: integer := 31;   -- Data Width
     RND_CHIP_NUM   	: integer := 4     -- Byte Write Width
    );
	port(
		Sys_clk		:	in	std_logic; -------80MHz 
		sys_rst_n		:	in	std_logic;-------80MHz reset active low
		fifo_clr		:	in	std_logic;-------80MHz reset active low
		
		test_rnd:  in std_logic;--fifo read clock
		test_rnd_data:  in std_logic_vector(15 downto 0);--fifo read clock
		random_fifo_rd_clk:  in std_logic;--fifo read clock
		
		Rnd_Gen_WNG_Data	:	in	std_logic_vector(RND_CHIP_NUM - 1 downto 0 );    ---------20MHz 
		Rnd_Gen_WNG_Clk	:	out	std_logic_vector(RND_CHIP_NUM - 1 downto 0 ); ---------20MHz 
		Rnd_Gen_WNG_Oe_n	:	out	std_logic_vector(RND_CHIP_NUM - 1 downto 0 ); ---------20MHz
		
		-----------signal for data tRndsfer to rfifo----------------------------------
		random_fifo_empty			:  out std_logic;--fifo has data
	   random_fifo_vld			:  out std_logic;--fifo read data valid
	  
	   random_fifo_rd_en			:  in  std_logic;--fifo read enable
	   random_fifo_rd_data		:  out std_logic_vector(BURST_LEN*DATA_WIDTH-1 downto 0)--fifo read data
	);
end Rnd_Gen_TOP;

architecture Behavioral of Rnd_Gen_TOP is

COMPONENT rnd_gen_fifo
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full : OUT STD_LOGIC;
    valid : OUT STD_LOGIC;
    almost_full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------
-------------out put intenal signal
signal wng_clk_rising  : std_logic; --10M clock
signal wng_clk_falling : std_logic; --10M clock
signal rnd_gen_cnt_set : std_logic; --10M clock
signal Div_cnt : std_logic_vector(1 downto 0); -------used to generate 20MHz clk
signal rnd_gen_cnt : std_logic_vector(3 downto 0); -------used to generate 20MHz clk
signal rnd_num_cnt : std_logic_vector(31 downto 0); -------used to generate 20MHz clk

signal    rnd_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal    fifo_din : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal    fifo_wr_en : STD_LOGIC;
signal    fifo_almost_full : STD_LOGIC;

begin
-----generate 20M clock
process(Sys_clk, sys_rst_n)
begin
	if(sys_rst_n = '0') then
		Div_cnt	<=	(others => '0');
	elsif(Sys_clk' event and Sys_clk = '1') then
		if(Div_cnt = 0 and fifo_almost_full = '1') then
			Div_cnt	<=	Div_cnt;
		else
			Div_cnt	<=	Div_cnt + 1;
		end if;
	end if;
end process;
Rnd_Gen_WNG_Oe_n	<= (others => '0');
Rnd_Gen_WNG_Clk	<= (others => Div_cnt(1));

--generate wng clock rising edge flag
process(Div_cnt)
begin
	if(Div_cnt = 1) then
		WNG_Clk_rising	<= '1';
	else
		WNG_Clk_rising	<= '0';
	end if;
end process;

--generate wng clock rising edge flag
process(Div_cnt)
begin
	if(Div_cnt = 3) then
		WNG_Clk_falling	<= '1';
	else
		WNG_Clk_falling	<= '0';
	end if;
end process;

--generate rnd_gen_cnt
process(Sys_clk, sys_rst_n)
begin
	if(sys_rst_n = '0') then
		rnd_gen_cnt	<=	(others => '1');
	elsif(Sys_clk' event and Sys_clk = '1') then
		if(WNG_Clk_rising = '1' and fifo_almost_full = '0') then
			if(rnd_gen_cnt_set = '1') then
				rnd_gen_cnt	<=	(others => '0');
			else
				rnd_gen_cnt	<=	rnd_gen_cnt + 1;
			end if;
		end if;
	end if;
end process;

--generate rnd gen count set
process(rnd_gen_cnt)
begin
	if( rnd_gen_cnt = DATA_WIDTH/RND_CHIP_NUM - 1) then
		rnd_gen_cnt_set	<=	'1';
	else
		rnd_gen_cnt_set	<= '0';
	end if;
end process;

--rnd data gererate
process(Sys_clk, sys_rst_n)
begin
	if(sys_rst_n = '0') then
		rnd_data	<= (others => '0');
	elsif(Sys_clk' event and Sys_clk = '1') then
		if(WNG_Clk_falling = '1') then
			rnd_data	<= rnd_data(DATA_WIDTH - 4 -1 downto 0 ) & Rnd_Gen_WNG_Data;
		end if;
	end if;
end process;

--generate rnd gen count set
process(Sys_clk, sys_rst_n)
begin
	if(sys_rst_n = '0') then
		fifo_din	<= (others => '0');
		fifo_wr_en	<= '0';
	elsif(Sys_clk' event and Sys_clk = '1') then
		if( rnd_gen_cnt_set = '1' and WNG_Clk_rising = '1') then
			if(test_rnd = '1') then
				if(test_rnd_data = x"FFFF") then
					fifo_din		<= rnd_num_cnt;--rnd_num_cnt;
				else
					fifo_din		<= test_rnd_data & test_rnd_data;--rnd_num_cnt;
				end if;
			else
				fifo_din		<= rnd_data;
			end if;
			fifo_wr_en	<= '1';
		else
			fifo_wr_en	<= '0';
		end if;
	end if;
end process;
--random fifo write count 
process(Sys_clk, sys_rst_n)
begin
	if(sys_rst_n = '0') then
		rnd_num_cnt	<= x"00010203";
	elsif(Sys_clk' event and Sys_clk = '1') then
		if( fifo_wr_en = '1') then
			rnd_num_cnt(7 downto 0)			<= rnd_num_cnt(7 downto 0) + 4;
			rnd_num_cnt(15 downto 8)		<= rnd_num_cnt(15 downto 8) + 4;
			rnd_num_cnt(23 downto 16)		<= rnd_num_cnt(23 downto 16) + 4;
			rnd_num_cnt(31 downto 24)		<= rnd_num_cnt(31 downto 24) + 4;
		else
			if(fifo_clr = '1') then
				rnd_num_cnt	<= x"00010203";
			else
				null;
			end if;
		end if;
	end if;
end process;

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
rnd_gen_fifo_inst : rnd_gen_fifo
  PORT MAP (
    rst 		=> fifo_clr,
    wr_clk 	=> sys_clk,--80MHz
    rd_clk 	=> random_fifo_rd_clk,
    din 		=> fifo_din,
    wr_en 	=> fifo_wr_en,
    rd_en 	=> random_fifo_rd_en,
    dout 	=> random_fifo_rd_data,
    full 	=> open,
    valid 	=> random_fifo_vld,
    almost_full => fifo_almost_full,
    empty 	=> random_fifo_empty
  );
end Behavioral;



