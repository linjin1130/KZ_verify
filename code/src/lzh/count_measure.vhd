----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:50:04 08/14/2013 
-- Design Name: 
-- Module Name:    count_measure - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
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
library IEEE;
use IEEE.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity count_measure is
	generic(
		CNT_Base_Addr : std_logic_vector(7 downto 0) := X"50";
		CNT_High_Addr : std_logic_vector(7 downto 0) := X"71";
		tdc_chl_num		:	integer := 4
	);
	port(
	-- fix by herry make sys_clk_80M to sys_clk_160M
	   sys_clk_80M	:	in	std_logic;--system clock,80MHz
		sys_rst_n	:	in	std_logic;--system reset,low active
		qtel_en : in std_logic;
		---apd interface
		apd_fpga_hit_in : 	in	std_logic_vector(tdc_chl_num-1 downto 0);--apd pulse input
		qtel_hit : 	in	std_logic_vector(tdc_chl_num-1 downto 0);
		---tdc module
		tdc_count_time_value	:	in	std_logic_vector(31 downto 0);
		----KZ verify module
		delay_data_mo		:	in	std_logic_vector(16*5-1 downto 0);
		
		compare_total_over	:	IN	std_logic_vector(31 downto 0);
		compare_total_cnt_1	:	IN	std_logic_vector(31 downto 0);
		compare_error_cnt_1	:	IN	std_logic_vector(31 downto 0);
		
		compare_total_cnt_2	:	IN	std_logic_vector(31 downto 0);
		compare_error_cnt_2	:	IN	std_logic_vector(31 downto 0);
		---cpldif module
		cpldif_count_addr	:	in	std_logic_vector(7 downto 0);
		cpldif_count_wr_en	:	in	std_logic;
		cpldif_count_rd_en	:	in	std_logic;
		cpldif_count_wr_data	:	in	std_logic_vector(31 downto 0);
		count_cpldif_rd_data	:	out	std_logic_vector(31 downto 0)
--		
--		POC_ctrl		 : out std_logic_vector(13 downto 0);
--		chopper_ctrl : in std_logic--when high, go into phase steady state
	);
end count_measure;

architecture Behavioral of count_measure is
signal apd_fpga_hit : std_logic_vector(tdc_chl_num-1 downto 0);
signal apd_fpga_hit_1d : std_logic_vector(tdc_chl_num-1 downto 0);
signal apd_fpga_hit_2d : std_logic_vector(tdc_chl_num-1 downto 0);
signal hit_cnt_en	:	std_logic_vector(tdc_chl_num-1 downto 0);
-----
signal addr_sel : std_logic_vector(7 downto 0);
--read or write register
signal count_ctrl0		:	std_logic_vector(31 downto 0);--count control register
signal count_time_range	:	std_logic_vector(31 downto 0);--count time range ,from 0.1s to 100s
---read only regoster
type MultiChnlCountType is array(0 to tdc_chl_num-1) of std_logic_vector(31 downto 0);
signal chnl_cnt_reg : MultiChnlCountType;
signal time_value_chnl : MultiChnlCountType;
signal apd_cnt_reg : MultiChnlCountType;
----
signal apd_cnt_en			:	std_logic_vector(tdc_chl_num-1 downto 0);
----
signal latch_fry_cnt 	: std_logic_vector(9 downto 0);--range 0 to 100s
signal latch_fry_cnt_1d : std_logic_vector(9 downto 0);--range 0 to 100s
signal second_cnt			:	std_logic_vector(27 downto 0);
signal msecond_cnt		:	std_logic_vector(33 downto 0);
--for sys_clk160M
constant one_second 		: std_logic_vector(27 downto 0) := X"4C4B400";--*12.5ns=1s
--constant one_second 		: std_logic_vector(27 downto 0) := X"9896800"; --*6.25=1s
constant  msecond_100	: std_logic_vector(23 downto 0) := X"7A1200";--*12.5ns=0.1s
--constant  msecond_100	: std_logic_vector(23 downto 0) := X"F42400";  --*6.25=0.1
signal cnt_start_en 		: std_logic;--count start enable
signal cnt_end_en 		: std_logic;--count end enable
signal count_en 			: std_logic;--apd count enable
---
signal dly_mon_0			: std_logic_vector(31 downto 0);
signal dly_mon_1			: std_logic_vector(31 downto 0);
signal dly_mon_2			: std_logic_vector(31 downto 0);
signal dly_mon_3			: std_logic_vector(31 downto 0);
signal rd_data_reg 		: std_logic_vector(31 downto 0);
signal count_state 		: std_logic;
signal latch_cnt_en 		: std_logic;

begin

dly_mon_0 <= "000"&delay_data_mo(19 downto 15)&"000"&delay_data_mo(14 downto 10)&"000"&delay_data_mo( 9 downto  5)&"000"&delay_data_mo( 4 downto  0);
dly_mon_1 <= "000"&delay_data_mo(39 downto 35)&"000"&delay_data_mo(34 downto 30)&"000"&delay_data_mo(29 downto 25)&"000"&delay_data_mo(24 downto 20);
dly_mon_2 <= "000"&delay_data_mo(59 downto 55)&"000"&delay_data_mo(54 downto 50)&"000"&delay_data_mo(49 downto 45)&"000"&delay_data_mo(44 downto 40);
dly_mon_3 <= "000"&delay_data_mo(79 downto 75)&"000"&delay_data_mo(74 downto 70)&"000"&delay_data_mo(69 downto 65)&"000"&delay_data_mo(64 downto 60);

--****** register manager ***
lock_addr : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		addr_sel	<=	X"FF";
	elsif rising_edge(sys_clk_80M) then
		if(cpldif_count_addr >= CNT_Base_Addr and cpldif_count_addr <=	CNT_High_Addr) then
			addr_sel	<=	cpldif_count_addr	- CNT_Base_Addr;
		else
			addr_sel	<=	X"FF";
		end if;
	end if;
end process;
---write register33
reg33_wr : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		count_ctrl0	<=	(others => '0');
	elsif rising_edge(sys_clk_80M) then
		if(cnt_start_en = '1') then
			count_ctrl0(16)	<=	'0';--clear count start enable
			count_ctrl0(18)	<=	count_state;
		elsif(cnt_end_en = '1') then
			count_ctrl0(17)	<=	'0';--clear count end enable
			count_ctrl0(18)	<=	count_state;
		elsif(addr_sel = X"20") then
			if(cpldif_count_wr_en = '1') then
				count_ctrl0	<=	cpldif_count_wr_data ;
				count_ctrl0(18)	<=	count_state;		
			else
				count_ctrl0	<=	count_ctrl0;
				count_ctrl0(18)	<=	count_state;
			end if;
		else
			count_ctrl0	<=	count_ctrl0;
			count_ctrl0(18)	<=	count_state;
		end if;
	end if;
end process;
--write register34
reg34_wr : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		count_time_range	<=	(others => '0');
	elsif rising_edge(sys_clk_80M) then
		if(addr_sel = X"21") then
			if(cpldif_count_wr_en = '1') then
				count_time_range	<=	cpldif_count_wr_data;
			else
				count_time_range	<=	count_time_range;
			end if;
		else
			count_time_range	<=	count_time_range;
		end if;
	end if;
end process; 
---read register
read_ram : process(sys_clk_80M)
begin
	if rising_edge(sys_clk_80M) then
		if(cpldif_count_rd_en = '1') then
			case addr_sel is
				when X"00"	=>	rd_data_reg	<=	chnl_cnt_reg(0);--read count of channel 0
				when X"01"	=>	rd_data_reg	<=	chnl_cnt_reg(1);--read count of channel 1
				when X"02"	=>	rd_data_reg	<=	chnl_cnt_reg(2);--read count of channel 2
				when X"03"	=>	rd_data_reg	<=	chnl_cnt_reg(3);--read count of channel 3
				when X"04"	=>	rd_data_reg	<=	compare_error_cnt_1;--chnl_cnt_reg(4);--read count of channel 4
				when X"05"	=>	rd_data_reg	<=	compare_total_cnt_1;--chnl_cnt_reg(5);--read count of channel 5
				when X"06"	=>	rd_data_reg	<=	compare_total_over;--chnl_cnt_reg(6);--read count of channel 6
				when X"07"	=>	rd_data_reg	<=	dly_mon_0;--chnl_cnt_reg(7);--read count of channel 7
				when X"08"	=>	rd_data_reg	<=	dly_mon_1;--read count of channel 8
				when X"09"	=>	rd_data_reg	<=	dly_mon_2;--read count of channel 9
				when X"0A"	=>	rd_data_reg	<=	dly_mon_3;--read count of channel 10
--				when X"0B"	=>	rd_data_reg	<=	chnl_cnt_reg(11);--read count of channel 11
--				when X"0C"	=>	rd_data_reg	<=	chnl_cnt_reg(12);--read count of channel 12
--				when X"0D"	=>	rd_data_reg	<=	chnl_cnt_reg(13);--read count of channel 13
--				when X"0E"	=>	rd_data_reg	<=	chnl_cnt_reg(14);--read count of channel 14
--				when X"0F"	=>	rd_data_reg	<=	chnl_cnt_reg(15);--read count of channel 15
				when X"10"	=>	rd_data_reg	<=	time_value_chnl(0);--read latch time of channel 0
				when X"11"	=>	rd_data_reg	<=	time_value_chnl(1);--read latch time of channel 1
				when X"12"	=>	rd_data_reg	<=	time_value_chnl(2);--read latch time of channel 2
				when X"13"	=>	rd_data_reg	<=	time_value_chnl(3);--read latch time of channel 3
--				when X"14"	=>	rd_data_reg	<=	time_value_chnl(4);--read latch time of channel 4
--				when X"15"	=>	rd_data_reg	<=	time_value_chnl(5);--read latch time of channel 5
--				when X"16"	=>	rd_data_reg	<=	time_value_chnl(6);--read latch time of channel 6
--				when X"17"	=>	rd_data_reg	<=	time_value_chnl(7);--read latch time of channel 7
--				when X"18"	=>	rd_data_reg	<=	time_value_chnl(8);--read latch time of channel 8
--				when X"19"	=>	rd_data_reg	<=	time_value_chnl(9);--read latch time of channel 9
--				when X"1A"	=>	rd_data_reg	<=	time_value_chnl(10);--read latch time of channel 10
--				when X"1B"	=>	rd_data_reg	<=	time_value_chnl(11);--read latch time of channel 11
--				when X"1C"	=>	rd_data_reg	<=	time_value_chnl(12);--read latch time of channel 12
--				when X"1D"	=>	rd_data_reg	<=	time_value_chnl(13);--read latch time of channel 13
--				when X"1E"	=>	rd_data_reg	<=	time_value_chnl(14);--read latch time of channel 14
--				when X"1F"	=>	rd_data_reg	<=	time_value_chnl(15);--read latch time of channel 15
				when X"20"	=>	rd_data_reg	<=	count_ctrl0;	--read control state
				when X"21"	=>	rd_data_reg	<=	count_time_range; 
				when others	=>	rd_data_reg	<=	(others => '0');
			end case;
		end if;
	end if;
end process;
--**** end ********

---count state 
state_pro : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		count_state	<=	'0';
	elsif rising_edge(sys_clk_80M) then
		if(cnt_start_en = '1') then
			count_state	<=	'1';
		elsif(cnt_end_en = '1') then
			count_state	<=	'0';
		else
			count_state	<=	count_state;
		end if;
	end if;
end process;

apd_fpga_hit <= qtel_hit when qtel_en = '1' else
					 apd_fpga_hit_in;
---******* detect rising of the 'apd_fpga_hit' ***
---two beat delay
dly_pro : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		apd_fpga_hit_1d	<=	(others => '0');
		apd_fpga_hit_2d	<=	(others => '0');
	elsif rising_edge(sys_clk_80M) then
		apd_fpga_hit_1d	<=	apd_fpga_hit;
		apd_fpga_hit_2d	<=	apd_fpga_hit_1d;
	end if;
end process;
---generate one clock width signal
rising_gen : for i in 0 to tdc_chl_num-1 generate
rising_pro : process(sys_clk_80M)
begin
	if rising_edge(sys_clk_80M) then
		hit_cnt_en(i)	<=	apd_fpga_hit_1d(i) and (not apd_fpga_hit_2d(i));
	end if;
end process;
end generate;
--***** end ********

--****** time count *******
---generate count start/end enable signal
cnt_start_en	<=	count_ctrl0(16);
cnt_end_en		<=	count_ctrl0(17);
latch_fry_cnt	<=	count_time_range(9 downto 0);--count range
apd_cnt_en		<=	count_ctrl0(tdc_chl_num-1 downto 0);


delay_pro : process(sys_clk_80M) begin
	if rising_edge(sys_clk_80M) then
		latch_fry_cnt_1d	<=	latch_fry_cnt;
	end if;
end process;

--0.1s count
msec_cnt : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		msecond_cnt	<=	"00"&X"FFFFFFFF";
		count_en	<=	'0';
	elsif rising_edge(sys_clk_80M) then
		if(cnt_start_en = '1') then
			msecond_cnt	<=	(others => '0');
			count_en	<=	'1';
		elsif(cnt_end_en = '1') then
			msecond_cnt	<=	"00"&X"FFFFFFFF";
			count_en	<=	'0';
		elsif(second_cnt = one_second) then--1s wait time
			msecond_cnt	<=	(others => '0');
			count_en	<=	'1';
		elsif(latch_fry_cnt_1d /= latch_fry_cnt) then
			msecond_cnt	<=	(others => '0');
			count_en	<=	'1';
		elsif(msecond_cnt(33 downto 24) = latch_fry_cnt) then--time range,0.1*n
			msecond_cnt	<=	(others => '1');
			count_en	<=	'0';
		elsif(msecond_cnt(23 downto 0) = msecond_100) then--0.1s
			msecond_cnt(23 downto 0)	<=	(others => '0');
			msecond_cnt(33 downto 24)	<=	msecond_cnt(33 downto 24) + '1';
			count_en	<=	'1';
		elsif(msecond_cnt = "11" & X"FFFFFFFF") then
			msecond_cnt	<=	msecond_cnt;
			count_en	<=	'0';
		elsif(msecond_cnt = "00"&X"FFFFFFFF") then
			msecond_cnt	<=	msecond_cnt;
			count_en	<=	'0';
		else
			msecond_cnt(23 downto 0)	<=	msecond_cnt(23 downto 0) + '1';
			count_en	<=	'1';
		end if;
	end if;
end process;
---1s wait count
one_cnt : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		second_cnt	<=	(others => '0');
	elsif rising_edge(sys_clk_80M) then
		if(cnt_start_en = '1') then
			second_cnt	<=	(others => '0');
		elsif(msecond_cnt = "11" & X"FFFFFFFF") then
			second_cnt	<=	second_cnt + '1';
		else
			second_cnt	<=	(others => '0');
		end if;
	end if;
end process;
---generate latch count enable signal
range_cnt : process(msecond_cnt,latch_fry_cnt)
begin
	if(msecond_cnt(33 downto 24) = latch_fry_cnt) then--start from 0
		latch_cnt_en	<=	'1';
	else
		latch_cnt_en	<=	'0';
	end if;
end process;
--** end ******

--***** latch apd count **
apd_cnt_gen : for i in 0 to tdc_chl_num-1 generate
apd_cnt_pro : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		apd_cnt_reg(i)		<=	(others => '0');
	elsif rising_edge(sys_clk_80M) then	
		if(apd_cnt_en(i) = '1') then --count enable
			if(count_en = '1') then --range enable
				if(hit_cnt_en(i) = '1') then --hit enable
					apd_cnt_reg(i)	<=	apd_cnt_reg(i) + '1';
				else
					apd_cnt_reg(i)	<=	apd_cnt_reg(i);
				end if;
			else
				apd_cnt_reg(i)	<=	(others => '0');
			end if;
		else
			apd_cnt_reg(i)	<=	(others => '0');
		end if;
	end if;
end process;
	
	latch_cnt_pro : process(sys_clk_80M,sys_rst_n) begin
	if(sys_rst_n = '0') then
		chnl_cnt_reg(i)	<=	(others => '0');
		time_value_chnl(i)	<=	(others => '0');
	elsif rising_edge(sys_clk_80M) then
		if(cnt_end_en = '1') then
			chnl_cnt_reg(i)	<=	(others => '0');
			time_value_chnl(i)	<=	(others => '0');
		elsif(apd_cnt_en(i) = '1') then
			if(latch_cnt_en = '1') then
				chnl_cnt_reg(i)	<=	apd_cnt_reg(i);
				time_value_chnl(i)	<=	tdc_count_time_value;
			else
				chnl_cnt_reg(i)	<=	chnl_cnt_reg(i);
				time_value_chnl(i)	<=	time_value_chnl(i);
			end if;
		else
			chnl_cnt_reg(i)	<=	(others => '0');
			time_value_chnl(i)	<=	(others => '0');
		end if;
	end if;
end process;
end generate;
--** end ********

count_cpldif_rd_data	<=	rd_data_reg;


end Behavioral;

