----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:43:09 11/27/2014 
-- Design Name: 
-- Module Name:    count_phase - Behavioral 
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

use ieee.std_logic_unsigned.all; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PM_count is
generic(
		tdc_chl_num		:	integer := 2
	);--修改寄存器

port(
	-- fix by herry make sys_clk_80M to sys_clk_160M
	   sys_clk_80M		:	in	std_logic;--system clock,80MHz
		sys_rst_n		:	in	std_logic;--system reset,low active
		fifo_rst			:	in	std_logic;--system reset,low active
		---apd interface
		apd_fpga_hit	: 	in	std_logic_vector(tdc_chl_num-1 downto 0);--apd pulse input
		---tdc module
		---confirm
		--tdc_count_time_value	:	in	std_logic_vector(31 downto 0);
		---from dac-----------------------------------
		dac_finish   :	in	std_logic;
		pm_data_store_en	: in std_logic;
		---count out to alt
		offset_voltage		: in std_logic_vector(11 downto 0);--offset_voltage
		half_wave_voltage	: in std_logic_vector(11 downto 0);--half_wave_voltage
		use_8apd     : in std_logic;
		use_4apd     : in std_logic;
		wait_start	 :	in 	std_logic;
		wait_count 	 : in 	std_logic_vector(19 downto 0);
		wait_dac_cnt : in 	std_logic_vector(7 downto 0);
		wait_finish	 :	out 	std_logic;
		
		chnl_cnt_reg0_out	: out std_logic_vector(9 downto 0);
		chnl_cnt_reg1_out	: out std_logic_vector(9 downto 0);
		chnl_cnt_reg2_out	: out std_logic_vector(9 downto 0);
		chnl_cnt_reg3_out	: out std_logic_vector(9 downto 0);
		chnl_cnt_reg4_out	: out std_logic_vector(9 downto 0);
		chnl_cnt_reg5_out	: out std_logic_vector(9 downto 0);
		chnl_cnt_reg6_out	: out std_logic_vector(9 downto 0);
		chnl_cnt_reg7_out	: out std_logic_vector(9 downto 0);
		
--		chnl_cnt_reg8_out	: out std_logic_vector(9 downto 0);
--		chnl_cnt_reg9_out	: out std_logic_vector(9 downto 0);
		
		alg_data_wr			: out	std_logic;
		alg_data_wr_data	: out	std_logic_vector(47 downto 0);
		---------
		lut_ram_128_vld  : in std_logic;
		lut_ram_128_addr : in STD_LOGIC_vector(6 downto 0);
		lut_ram_128_data : in STD_LOGIC_vector(11 downto 0);
		
		----alg result------
		chopper_ctrl 		: in std_logic;
		result_ok 		: in std_logic;
		one_time_end		: in std_logic;
		DAC_set_addr   : in std_logic_vector(6 downto 0);
		DAC_set_result : in std_logic_vector(11 downto 0);
		min_set_result_en : out std_logic;
		min_set_result : out std_logic_vector(11 downto 0);
		DAC_set_data 	: in std_logic_vector(11 downto 0)
	);
end PM_count;

architecture Behavioral of PM_count is
type MultiChnlCountType is array(0 to tdc_chl_num-1) of std_logic_vector(9 downto 0); ----总结
signal apd_cnt_reg   : MultiChnlCountType;
--constant  msecond		: std_logic_vector(19 downto 0) := X"13880";  --*12.5=1ms
--constant  usecned 	: std_logic_vector(11 downto 0) := X"320";   --*12.5=10us
signal stable_cnt		: std_logic_vector(19 downto 0) ;
signal min_cnt		: std_logic_vector(9 downto 0) ;
signal min_dac		: std_logic_vector(11 downto 0) ;
--signal count_en_1d		: std_logic;
--signal count_en_rising		: std_logic;
--signal dac_finish_1d		: std_logic;
--signal Dac_finish_rising		: std_logic;
signal wait_finish_reg		: std_logic;

signal apd_fpga_hit_1d		: std_logic_vector(1 downto 0);
signal apd_fpga_hit_2d		: std_logic_vector(1 downto 0); 
signal hit_cnt_en				: std_logic_vector(1 downto 0); 

signal lut_ram_128_cnt		: std_logic_vector(19 downto 0); 

signal 		chnl_cnt_reg0	:  std_logic_vector(9 downto 0);
signal 		chnl_cnt_reg1	:  std_logic_vector(9 downto 0);
signal 		chnl_cnt_reg2	:  std_logic_vector(9 downto 0);
signal 		chnl_cnt_reg3	:  std_logic_vector(9 downto 0);
signal 		chnl_cnt_reg4	:  std_logic_vector(9 downto 0);
signal 		chnl_cnt_reg5	:  std_logic_vector(9 downto 0);
signal 		chnl_cnt_reg6	:  std_logic_vector(9 downto 0);
signal 		chnl_cnt_reg7	:  std_logic_vector(9 downto 0);
		
--signal 		chnl_cnt_reg8	:  std_logic_vector(9 downto 0);
--signal 		chnl_cnt_reg9	:  std_logic_vector(9 downto 0);

begin
chnl_cnt_reg0_out <= chnl_cnt_reg0;
chnl_cnt_reg1_out <= chnl_cnt_reg1;
chnl_cnt_reg2_out <= chnl_cnt_reg2;
chnl_cnt_reg3_out <= chnl_cnt_reg3;
chnl_cnt_reg4_out <= chnl_cnt_reg4;
chnl_cnt_reg5_out <= chnl_cnt_reg5;
chnl_cnt_reg6_out <= chnl_cnt_reg6;
chnl_cnt_reg7_out <= chnl_cnt_reg7;
----chnl_cnt_reg8_out <= chnl_cnt_reg8;
----chnl_cnt_reg9_out <= chnl_cnt_reg9;

wait_finish	<= wait_finish_reg;
---******* detect rising of the 'Dac_finish' ***
---one beat delay
--dly_dac_finish_pro : process(sys_clk_80M,sys_rst_n)
--begin
--	if(sys_rst_n = '0') then
--		Dac_finish_1d	<=	'0';
--	elsif rising_edge(sys_clk_80M) then
--		Dac_finish_1d	<=	Dac_finish;
--	end if;
--end process;
--Dac_finish_rising  <=  (not Dac_finish_1d) and Dac_finish;
--PM 稳定时间 设置PM 一段时间后使能 count--------------------------
--------------DAC stable_time--------------------
-----------after the Dac_finish is rising ------------------ 
stable_time: process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0' ) then-------------
		stable_cnt	<=	(others =>'0');--(others => '0')   
	elsif rising_edge(sys_clk_80M) then
		if(wait_start = '1') then
			stable_cnt	<=	wait_count;
		else
			if(stable_cnt > 0)then 
				stable_cnt	<=	stable_cnt - '1';
			else
				null;
			end if;
		end if;
	end if;
end process;
wait_finish_pro: process(sys_clk_80M,sys_rst_n)
begin
if(sys_rst_n = '0' ) then-------------
	wait_finish_reg	<=	'0';    
elsif rising_edge(sys_clk_80M) then
	if(stable_cnt = 1)then 
		wait_finish_reg	<=	'1';
	else
		wait_finish_reg	<=	'0';
	end if;
end if;
end process;

process(sys_clk_80M,sys_rst_n, fifo_rst)
begin
if(sys_rst_n = '0' or fifo_rst = '1' ) then-------------
	lut_ram_128_cnt	<=	(others => '0');    
elsif rising_edge(sys_clk_80M) then
	if(lut_ram_128_vld = '1')then 
		lut_ram_128_cnt	<=	lut_ram_128_cnt + 1;
	end if;
end if;
end process;
---******* detect rising of the 'apd_fpga_hit' ***
---two beat delay
delay_hit : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		apd_fpga_hit_1d	<=	(others => '0');
		apd_fpga_hit_2d	<=	(others => '0');
	elsif rising_edge(sys_clk_80M) then
		apd_fpga_hit_1d	<=	apd_fpga_hit;
		apd_fpga_hit_2d	<=	apd_fpga_hit_1d;
	end if;
end process;

rising_gen : for i in 0 to tdc_chl_num-1 generate
rising_pro : process(sys_clk_80M)
begin
	if rising_edge(sys_clk_80M) then
		hit_cnt_en(i)	<=	apd_fpga_hit_1d(i) and (not apd_fpga_hit_2d(i));
	end if;
end process;
end generate;

apd_cnt_gen : for i in 0 to tdc_chl_num-1 generate
	apd_cnt_pro : process(sys_clk_80M,sys_rst_n)
	begin
		if(sys_rst_n = '0') then
			apd_cnt_reg(i)		<=	(others => '0');
		elsif rising_edge(sys_clk_80M) then	
			if(wait_start = '1') then --start count
				apd_cnt_reg(i)		<=	(others => '0');
			else
				if(hit_cnt_en(i) = '1' and apd_cnt_reg(i) < 1023) then --hit enable and hit count < 1023
					apd_cnt_reg(i)	<=	apd_cnt_reg(i) + '1';
				end if;
			end if;
		end if;
	end process;
end generate;

latch_cnt_pro : process(sys_clk_80M,sys_rst_n) begin
	if(sys_rst_n = '0') then
		chnl_cnt_reg0	<=	(others => '0');
		chnl_cnt_reg1	<=	(others => '0');
		chnl_cnt_reg2	<=	(others => '0');
		chnl_cnt_reg3	<=	(others => '0');
		chnl_cnt_reg4	<=	(others => '0');
		chnl_cnt_reg5	<=	(others => '0');
		chnl_cnt_reg6	<=	(others => '0');
		chnl_cnt_reg7	<=	(others => '0');
--		chnl_cnt_reg8	<=	(others => '0');
--		chnl_cnt_reg9	<=	(others => '0');
	elsif rising_edge(sys_clk_80M) then
			if(wait_finish_reg = '1') then
				if(wait_dac_cnt = 1) then
					chnl_cnt_reg0	<=	apd_cnt_reg(0);
					chnl_cnt_reg1	<=	apd_cnt_reg(1);
				elsif(wait_dac_cnt = 2)then
					chnl_cnt_reg2	<=	apd_cnt_reg(0);
					chnl_cnt_reg3	<=	apd_cnt_reg(1);
				elsif(wait_dac_cnt = 3)then
					chnl_cnt_reg4	<=	apd_cnt_reg(0);
					chnl_cnt_reg5	<=	apd_cnt_reg(1);
				elsif(wait_dac_cnt = 4)then
					chnl_cnt_reg6	<=	apd_cnt_reg(0);
					chnl_cnt_reg7	<=	apd_cnt_reg(1);
--				elsif(wait_dac_cnt = 5)then
--					chnl_cnt_reg8	<=	apd_cnt_reg(0);
--					chnl_cnt_reg9	<=	apd_cnt_reg(1);
				end if;
			end if;
	end if;
end process;

-----------register 8 count------------------
--		alg_data_wr			: out	std_logic;
--		alg_data_wr_data	: out	std_logic_vector(31 downto 0);
alt_out : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		alg_data_wr					<= '0';
		alg_data_wr_data			<= (others => '0');
	elsif rising_edge(sys_clk_80M) then
		if(wait_finish_reg = '1' and wait_dac_cnt /= 0) then ---10 counter
			alg_data_wr					<= '1';
			alg_data_wr_data			<=	x"F" & DAC_set_data & wait_dac_cnt & "00" & apd_cnt_reg(1) & "00" & apd_cnt_reg(0);
		else
			if(result_ok = '1') then
				alg_data_wr					<= '1';
				alg_data_wr_data			<=	x"A" & half_wave_voltage & offset_voltage & "0" & DAC_set_addr & DAC_set_result;
			else
				if(lut_ram_128_vld = '1') then
					alg_data_wr					<= '1';
					alg_data_wr_data			<=	x"B" & lut_ram_128_cnt & "0" & lut_ram_128_addr & x"0" & lut_ram_128_data;
				else
					if(one_time_end = '1' and pm_data_store_en = '1') then
						alg_data_wr					<= '1';
						alg_data_wr_data			<=	x"C00" & "00" & min_cnt & "0" & DAC_set_addr & x"0" & min_dac;
					else
						alg_data_wr					<= '0';
					end if;
				end if;
			end if;
		end if;
	end if;
end process;

process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		min_cnt				<= (others => '1');
		min_dac				<= (others => '0');
		min_set_result		<= (others => '0');
		min_set_result_en	<= '0';
	elsif rising_edge(sys_clk_80M) then
		min_set_result_en	<= one_time_end;
		if(wait_finish_reg = '1' and wait_dac_cnt /= 0 and chopper_ctrl = '1') then ---10 counter
			if(use_4apd = '1') then
				if(apd_cnt_reg(0) < min_cnt) then
					min_cnt	<= apd_cnt_reg(0);
					min_dac	<= dac_set_data;
				end if;
			else	---default is APD 2
				if(apd_cnt_reg(1) < min_cnt) then
					min_cnt	<= apd_cnt_reg(1);
					min_dac	<= dac_set_data;
				end if;
			end if;
		elsif(one_time_end = '1' or chopper_ctrl = '0') then
			min_set_result	<= min_dac;
			min_cnt			<= (others => '1');
		end if;
	end if;
end process;

end Behavioral;




------------------------------------------------------------------------------------
---- Company: 
---- Engineer: 
---- 
---- Create Date:    15:43:09 11/27/2014 
---- Design Name: 
---- Module Name:    count_phase - Behavioral 
---- Project Name: 
---- Target Devices: 
---- Tool versions: 
---- Description: 
----
---- Dependencies: 
----
---- Revision: 
---- Revision 0.01 - File Created
---- Additional Comments: 
----
------------------------------------------------------------------------------------
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--
--use ieee.std_logic_unsigned.all; 
--
---- Uncomment the following library declaration if using
---- arithmetic functions with Signed or Unsigned values
----use IEEE.NUMERIC_STD.ALL;
--
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
----library UNISIM;
----use UNISIM.VComponents.all;
--
--entity PM_count is
--generic(
--		tdc_chl_num		:	integer := 2
--	);--修改寄存器
--
--port(
--	-- fix by herry make sys_clk_80M to sys_clk_160M
--	   sys_clk_80M		:	in	std_logic;--system clock,80MHz
--		sys_rst_n		:	in	std_logic;--system reset,low active
--		---apd interface
--		apd_fpga_hit	: 	in	std_logic_vector(tdc_chl_num-1 downto 0);--apd pulse input
--		---tdc module
--		---confirm
--		--tdc_count_time_value	:	in	std_logic_vector(31 downto 0);
--		---from dac-----------------------------------
--		dac_finish   :	in	std_logic;
--		---count out to alt
--		
--		pm_stable_cnt_reg	 : in std_logic_vector(15 downto 0);
--		poc_stable_cnt_reg : in std_logic_vector(15 downto 0);
--		count_time_reg : in std_logic_vector(15 downto 0);
--		
--		chnl_cnt_reg0_out	: out std_logic_vector(9 downto 0);
--		chnl_cnt_reg1_out	: out std_logic_vector(9 downto 0);
--		chnl_cnt_reg2_out	: out std_logic_vector(9 downto 0);
--		chnl_cnt_reg3_out	: out std_logic_vector(9 downto 0);
--		chnl_cnt_reg4_out	: out std_logic_vector(9 downto 0);
--		chnl_cnt_reg5_out	: out std_logic_vector(9 downto 0);
--		chnl_cnt_reg6_out	: out std_logic_vector(9 downto 0);
--		chnl_cnt_reg7_out	: out std_logic_vector(9 downto 0);
--		
--		chnl_cnt_reg8_out	: out std_logic_vector(9 downto 0);
--		chnl_cnt_reg9_out	: out std_logic_vector(9 downto 0);
--		
--		alg_data_wr			: out	std_logic;
--		alg_data_wr_data	: out	std_logic_vector(31 downto 0);
--			
--		-----pm_module----------------
--		-----和林金确认pm控制端输出以确定八个计数的存储----
--      pm_rdy_out		  	:  out std_logic;
--		
--		----alg result------
--		result_ok 		: in std_logic;
--		DAC_set_addr   : in std_logic_vector(6 downto 0);
--		DAC_set_result : in std_logic_vector(11 downto 0);
--		
--		---alt   module--------------
----		alt_end	      : in std_logic;--是否使用？
--		alt_begin	   : out std_logic;
--		--POC_ctrl		 : out std_logic_vector(13 downto 0);
--		chopper_ctrl 	: in std_logic--when high, go into phase steady state
--	);
--end PM_count;
--
--architecture Behavioral of PM_count is
--type MultiChnlCountType is array(0 to tdc_chl_num-1) of std_logic_vector(9 downto 0); ----总结
--signal apd_cnt_reg   : MultiChnlCountType;
----constant  msecond		: std_logic_vector(19 downto 0) := X"13880";  --*12.5=1ms
----constant  usecned 	: std_logic_vector(11 downto 0) := X"320";   --*12.5=10us
--signal stable_cnt		: std_logic_vector(19 downto 0) ;
--signal pm_rdy 			: std_logic;
--signal pm_rdy_1d		: std_logic;
--signal count_en_1d		: std_logic;
--signal count_en_rising		: std_logic;
--signal pm_rdy_rising		: std_logic;
--signal dac_finish_1d		: std_logic;
--signal Dac_finish_rising		: std_logic;
--signal count_en		: std_logic;
--signal apd_ms_count_en		: std_logic;
--signal latch_cnt_en		: std_logic;
--
--signal apd_fpga_hit_1d		: std_logic_vector(1 downto 0);
--signal apd_fpga_hit_2d		: std_logic_vector(1 downto 0); 
--signal hit_cnt_en		: std_logic_vector(1 downto 0); 
--signal msecond_cnt		: std_logic_vector(19 downto 0);
--signal rdy_cnt		: std_logic_vector(2 downto 0);
--signal 		chnl_cnt_reg0	:  std_logic_vector(9 downto 0);
--signal 		chnl_cnt_reg1	:  std_logic_vector(9 downto 0);
--signal 		chnl_cnt_reg2	:  std_logic_vector(9 downto 0);
--signal 		chnl_cnt_reg3	:  std_logic_vector(9 downto 0);
--signal 		chnl_cnt_reg4	:  std_logic_vector(9 downto 0);
--signal 		chnl_cnt_reg5	:  std_logic_vector(9 downto 0);
--signal 		chnl_cnt_reg6	:  std_logic_vector(9 downto 0);
--signal 		chnl_cnt_reg7	:  std_logic_vector(9 downto 0);
--		
--signal 		chnl_cnt_reg8	:  std_logic_vector(9 downto 0);
--signal 		chnl_cnt_reg9	:  std_logic_vector(9 downto 0);
--
--begin
--pm_rdy_out <= pm_rdy;
--chnl_cnt_reg0_out <= chnl_cnt_reg0;
--chnl_cnt_reg1_out <= chnl_cnt_reg1;
--chnl_cnt_reg2_out <= chnl_cnt_reg2;
--chnl_cnt_reg3_out <= chnl_cnt_reg3;
--chnl_cnt_reg4_out <= chnl_cnt_reg4;
--chnl_cnt_reg5_out <= chnl_cnt_reg5;
--chnl_cnt_reg6_out <= chnl_cnt_reg6;
--chnl_cnt_reg7_out <= chnl_cnt_reg7;
--chnl_cnt_reg8_out <= chnl_cnt_reg8;
--chnl_cnt_reg9_out <= chnl_cnt_reg9;
-----******* detect rising of the 'pm_rdy' ***
-----one beat delay
--dly_pro : process(sys_clk_80M,sys_rst_n)
--begin
--	if(sys_rst_n = '0') then
--		pm_rdy_1d	<=	'0';
--	elsif rising_edge(sys_clk_80M) then
--		pm_rdy_1d	<=	pm_rdy;
----	else 
----		pm_rdy_1d   <= pm_rdy_1d;
--	end if;
--end process;
--pm_rdy_rising  <=  (not pm_rdy_1d) and pm_rdy;
--
-----******* detect rising of the 'Dac_finish' ***
-----one beat delay
--dly_dac_finish_pro : process(sys_clk_80M,sys_rst_n)
--begin
--	if(sys_rst_n = '0') then
--		Dac_finish_1d	<=	'0';
--	elsif rising_edge(sys_clk_80M) then
--		Dac_finish_1d	<=	Dac_finish;
--	end if;
--end process;
--Dac_finish_rising  <=  (not Dac_finish_1d) and Dac_finish;
----PM 稳定时间 设置PM 一段时间后使能 count--------------------------
----100us count
----stable_time : process(sys_clk_80M,sys_rst_n)
----begin
----	if(sys_rst_n = '0' or pm_rdy_rising = '1') then
----		stable_cnt	<=	(others =>'0');--(others => '0')
----		count_en <= 0;
----	elsif rising_edge(sys_clk_80M) then
----		if(stable_cnt = usecned ) then
----			stable_cnt	<=	(others =>'0');
----			count_en	<=	'1';
----			stable_flag <= '1';
----		elsif(stable_flag = '1') then
----		   stable_cnt	<=	stable_cnt;
----			count_en	<=	'0';
----		else
----			stable_cnt	<=	stable_cnt + '1';
----			count_en	<=	'0';
----		end if;
----	end if;
----end process;
----------------DAC stable_time--------------------
-------------after the Dac_finish is rising ------------------ 
--stable_time : process(sys_clk_80M,sys_rst_n,Dac_finish_rising)
--begin
--	if(sys_rst_n = '0' or Dac_finish_rising  = '1' ) then-------------computer the 5 DAC 0k
--		stable_cnt	<=	(others =>'0');--(others => '0')
--		count_en <= '0';    
--	elsif rising_edge(sys_clk_80M) then
--		if(stable_cnt = pm_stable_cnt_reg ) then 
--			stable_cnt	<=	stable_cnt;
--			count_en	<=	'1';
--		elsif(chopper_ctrl = '1')then 
--			stable_cnt	<=	stable_cnt + '1';
--			count_en	<=	'0';
--		else
--			stable_cnt	<=	stable_cnt;
--			count_en	<=	'0';
--		end if;
--	end if;
--end process;
--
-----******* detect rising of the 'apd_fpga_hit' ***
-----two beat delay
--delay_hit : process(sys_clk_80M,sys_rst_n)
--begin
--	if(sys_rst_n = '0') then
--		apd_fpga_hit_1d	<=	(others => '0');
--		apd_fpga_hit_2d	<=	(others => '0');
--	elsif rising_edge(sys_clk_80M) then
--		apd_fpga_hit_1d	<=	apd_fpga_hit;
--		apd_fpga_hit_2d	<=	apd_fpga_hit_1d;
--	end if;
--end process;
--
--rising_gen : for i in 0 to tdc_chl_num-1 generate
--rising_pro : process(sys_clk_80M)
--begin
--	if rising_edge(sys_clk_80M) then
--		hit_cnt_en(i)	<=	apd_fpga_hit_1d(i) and (not apd_fpga_hit_2d(i));
----	else
----		hit_cnt_en(i) <= hit_cnt_en(i);
--	  
--	end if;
--end process;
--end generate;
--
-----******* detect rising of the 'count_en' ***
-----one beat delay
--count_en_pro : process(sys_clk_80M,sys_rst_n)
--begin
--	if(sys_rst_n = '0') then
--		count_en_1d	<=	'0';
--	elsif rising_edge(sys_clk_80M) then
--		count_en_1d	<=	count_en;
--	end if;
--end process;
--count_en_rising  <=  (not count_en_1d) and count_en;
-----------------1ms count------------------
--msec_cnt : process(sys_clk_80M,sys_rst_n,count_en_rising)
--begin
--	if(sys_rst_n = '0' or count_en_rising = '1') then
--		msecond_cnt			<=	(others =>'0');--(others => '0')
--		apd_ms_count_en	<=	'0'; -- 计数使能
--		latch_cnt_en      <= '0'; -- 到达1ms将计数存储起来
--		pm_rdy            <= '0';
--	elsif rising_edge(sys_clk_80M ) then
--		if(msecond_cnt(19 downto 4) = count_time_reg) then--1ms
--			--msecond_cnt			<=	(others => '0');
--			msecond_cnt			<=	msecond_cnt;
--			pm_rdy         	<= '1';
--			apd_ms_count_en	<=	'0';
--			latch_cnt_en      <= '1';
--		elsif(count_en = '1') then
--			msecond_cnt	<=	msecond_cnt + '1';
--			pm_rdy            <= '0';
--			apd_ms_count_en	<=	'1';
--			latch_cnt_en      <= '0';	
--		--else
--		--   msecond_cnt <= msecond_cnt;
--		end if;
--	end if;
--end process;
--
--apd_cnt_gen : for i in 0 to tdc_chl_num-1 generate
--apd_cnt_pro : process(sys_clk_80M,sys_rst_n)
--begin
--	if(sys_rst_n = '0') then
--		apd_cnt_reg(i)		<=	(others => '0');
--	elsif rising_edge(sys_clk_80M) then	
--			if(apd_ms_count_en = '1') then --range enable
--				if(hit_cnt_en(i) = '1') then --hit enable
--					apd_cnt_reg(i)	<=	apd_cnt_reg(i) + '1';
--				else
--					apd_cnt_reg(i)	<=	apd_cnt_reg(i);
--				end if;
--			else
--				apd_cnt_reg(i)	<=	(others => '0');
--			end if;
--	end if;
--	
--end process;
--end generate;
--latch_cnt_pro : process(sys_clk_80M,sys_rst_n) begin
--	if(sys_rst_n = '0') then
--		chnl_cnt_reg0	<=	(others => '0');
--		chnl_cnt_reg1	<=	(others => '0');
--		chnl_cnt_reg2	<=	(others => '0');
--		chnl_cnt_reg3	<=	(others => '0');
--		chnl_cnt_reg4	<=	(others => '0');
--		chnl_cnt_reg5	<=	(others => '0');
--		chnl_cnt_reg6	<=	(others => '0');
--		chnl_cnt_reg7	<=	(others => '0');
--		chnl_cnt_reg8	<=	(others => '0');
--		chnl_cnt_reg9	<=	(others => '0');
--	elsif rising_edge(sys_clk_80M) then
--			if(latch_cnt_en = '1') then
--				if(rdy_cnt = "000") then
--					chnl_cnt_reg0	<=	apd_cnt_reg(0);
--					chnl_cnt_reg1	<=	apd_cnt_reg(1);
--				elsif(rdy_cnt = "001")then
--					chnl_cnt_reg2	<=	apd_cnt_reg(0);
--					chnl_cnt_reg3	<=	apd_cnt_reg(1);
--				elsif(rdy_cnt = "010")then
--					chnl_cnt_reg4	<=	apd_cnt_reg(0);
--					chnl_cnt_reg5	<=	apd_cnt_reg(1);
--				elsif(rdy_cnt = "011")then
--					chnl_cnt_reg6	<=	apd_cnt_reg(0);
--					chnl_cnt_reg7	<=	apd_cnt_reg(1);
--				elsif(rdy_cnt = "100")then
--					chnl_cnt_reg8	<=	apd_cnt_reg(0);
--					chnl_cnt_reg9	<=	apd_cnt_reg(1);
--				end if;
--			end if;
--	end if;
--end process;
--
--
--
-------------register 8 count------------------
--register_count : process(sys_clk_80M,sys_rst_n)
--begin
--	if(sys_rst_n = '0') then
--		rdy_cnt	<=	(others =>'0');
--		alt_begin <= '0';
--	elsif rising_edge(sys_clk_80M) then
--		if(pm_rdy_rising = '1' ) then 
--			rdy_cnt	<=	rdy_cnt + '1';
--		elsif(rdy_cnt = "100") then ------?
--			alt_begin<= '1';
--		elsif(rdy_cnt = "101") then
--			alt_begin <= '0';
--			rdy_cnt	<=	(others =>'0');
--		else
--			rdy_cnt	<=	rdy_cnt;
--		end if;
--	end if;
--end process;
-------------register 8 count------------------
----		alg_data_wr			: out	std_logic;
----		alg_data_wr_data	: out	std_logic_vector(31 downto 0);
--alt_out : process(sys_clk_80M,sys_rst_n)
--begin
--	if(sys_rst_n = '0') then
--		alg_data_wr		<= '0';
--		alg_data_wr_data		<= (others => '0');
--		--alt_begin <= '0';
--	elsif rising_edge(sys_clk_80M) then
--		if(rdy_cnt = 0 and pm_rdy_rising = '1') then 
--	      alg_data_wr					<= '1';
--			alg_data_wr_data			<=	x"1" & "00" & chnl_cnt_reg1 & x"2" & "00" & chnl_cnt_reg0;
--		elsif(rdy_cnt = 1 and pm_rdy_rising= '1') then ------?
--			alg_data_wr					<= '1';
--			alg_data_wr_data			<=	x"3" & "00" & chnl_cnt_reg3 & x"4" & "00" & chnl_cnt_reg2;
--		elsif(rdy_cnt = 2 and pm_rdy_rising= '1') then ------?
--			alg_data_wr					<= '1';
--			alg_data_wr_data			<=	x"5" & "00" & chnl_cnt_reg5 & x"6" & "00" & chnl_cnt_reg4;
--		elsif(rdy_cnt = 3 and pm_rdy_rising= '1') then ------?
--			alg_data_wr					<= '1';
--			alg_data_wr_data			<=	x"7" & "00" & chnl_cnt_reg7 & x"8" & "00" & chnl_cnt_reg6;
--		elsif(rdy_cnt = 4 and pm_rdy_rising= '1') then
--			alg_data_wr					<= '1';
--			alg_data_wr_data			<=	x"9" & "00" & chnl_cnt_reg9 & x"A" & "00" & chnl_cnt_reg8;
--		else
--			if(result_ok = '1') then
--				alg_data_wr					<= '1';
--				alg_data_wr_data			<=	x"AAA" & "0" & DAC_set_addr & DAC_set_result;
--			else
--				alg_data_wr					<= '0';
--			end if;
--		end if;
--	end if;
--end process;
--
--
--end Behavioral;
--
