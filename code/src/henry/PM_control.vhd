----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:15:00 12/04/2014 
-- Design Name: 
-- Module Name:    PM_control - Behavioral 
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
--use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity PM_control is
	port(
	   sys_clk_80M	:	in	std_logic;--system clock,80MHz
		sys_rst_n	:	in	std_logic;--system reset,low active
		
		----dac interface--
--		Dac_CLK    : out   STD_LOGIC;--40M  ----always or no always
		Dac_Ena    : out   STD_LOGIC;--DAC set enable
		Dac_Data   : out   STD_LOGIC_VECTOR (11 downto 0);--DAC value
		Sys_Rst    : out   STD_LOGIC;--System reset,high active
		
--		Dac_finish : in    STD_LOGIC;
		
		Dac_set_result :in    STD_LOGIC_VECTOR (11 downto 0);
		--poc interface
		--POC_ctrl		: out std_logic_vector(13 downto 0);
		half_wave_voltage : out std_logic_vector(11 downto 0);
		tan_adj_voltage : out std_logic_vector(11 downto 0);
		offset_voltage : out std_logic_vector(11 downto 0);
		POC_ctrl		 : out std_logic_vector(6 downto 0);
		POC_ctrl_en	 : out std_logic;
		--port to(from) count--------
		pm_steady_test	  : in std_logic;
		use_8apd     : out std_logic;
		use_4apd     : out std_logic;
		alt_begin     : out std_logic;
		alt_end       : in std_logic;
		scan_data_store_en       : in std_logic;
		pm_data_store_en       : in std_logic;
		
		--register interface
		reg_wr		 	: in std_logic;
		reg_wr_addr		: in std_logic_vector(3 downto 0);
		reg_wr_data		: in std_logic_vector(15 downto 0);
		
		
--		pm_stable_cnt_reg	 : out std_logic_vector(15 downto 0);
--		poc_stable_cnt_reg : out std_logic_vector(15 downto 0);
--		count_time_reg : out std_logic_vector(15 downto 0);
		
		---lut ram module-------------
		---
		addr_reset			:	out	std_logic;
	--	lut_data_vld	:	in	std_logic;
--		lut_data			:	in	std_logic_vector(15 downto 0);
		
		--exp_running	: in std_logic; ----------------------用法？
		-----pm_module----------------
		-----和林金确认pm控制端输出以确定八个计数的存储----
		--chopper_ctrl			:  in std_logic;

		---algrithm result
		---10 counter x 16bit, write 5 time
		---1 PM result write 1 time
		---total is 128 x 6 time
--		alg_data_wr			: out	std_logic;
--		alg_data_wr_data	: out	std_logic_vector(31 downto 0);
		one_time_end		: out std_logic;
		wait_start	 :	out 	std_logic;
		wait_count 	 : out 	std_logic_vector(19 downto 0);
		wait_dac_cnt : out 	std_logic_vector(7 downto 0);
		wait_finish	 :	in 	std_logic;
		
		-----
		--syn_light : in std_logic;--when high, go into phase steady state
		chopper_ctrl : in std_logic--when high, go into phase steady state
											--different with exp_running
	);
end PM_control;

architecture Behavioral of PM_control is
--type state is(IDLE,poc_set,DAC_set1,DAC_set2,DAC_set3,DAC_set4,DAC_result);
--

--signal pr_state,nx_state : state;
signal poc_count   : std_logic_vector(6 downto 0);
signal set_count   : std_logic_vector(7 downto 0);
signal config_reg0 : std_logic_vector(11 downto 0);
signal config_reg1 : std_logic_vector(11 downto 0);
signal config_reg2 : std_logic_vector(11 downto 0);
signal config_reg3 : std_logic_vector(11 downto 0);
signal half_wave_voltage_reg : std_logic_vector(11 downto 0);
signal offset_voltage_reg : std_logic_vector(11 downto 0);
signal minus_voltage : std_logic_vector(10 downto 0);
signal Dac_set_result_low : std_logic_vector(11 downto 0);
signal scan_dac_data : std_logic_vector(11 downto 0);

signal step_cnt_reg		: std_logic_vector(7 downto 0);
signal scan_inc_cnt_reg	: std_logic_vector(7 downto 0);
signal pm_stable_cnt_reg	: std_logic_vector(15 downto 0);
signal poc_stable_cnt_reg 	: std_logic_vector(15 downto 0);
signal count_time_reg 		: std_logic_vector(15 downto 0);
signal poc_cnt_set	 		: std_logic_vector(6 downto 0);
--signal use_apd4            : std_logic_vector(1 downto 0);
--signal use_apd8            : std_logic_vector(1 downto 0);
--signal dac_start   : std_logic;
--constant con_div	 :	std_logic_vector(7 downto 0) := X"50";
--signal poc_count :	std_logic_vector(2 downto 0);
--signal set_count	 : std_logic_vector(7 downto 0);
--signal set_onetime : std_logic;
signal add_L_sub_H : std_logic;
signal wait_stable_H_count_L : std_logic;
signal add_set_count : std_logic;
signal set_onetime_end : std_logic;
signal chopper_ctrl_rising : std_logic;
signal chopper_ctrl_1d : std_logic;
signal pm_steady_test_rising : std_logic;
signal pm_steady_test_1d : std_logic;
--signal set_onetime_end_1d : std_logic;
signal complete		: std_logic;
signal wait_start_reg: std_logic;
signal scan_data_store_en_1d: std_logic;
signal scan_data_store_en_rising: std_logic;

--signal pm_count

begin
Sys_Rst <= not sys_rst_n;
---******* detect rising of the 'pm_rdy' ***
---one beat delay
dly_pro : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		chopper_ctrl_1d	<=	'0';
		pm_steady_test_1d	<=	'0';
		scan_data_store_en_1d	<=	'0';
	elsif rising_edge(sys_clk_80M) then
		chopper_ctrl_1d	<=	chopper_ctrl;
		pm_steady_test_1d	<=	pm_steady_test;
		scan_data_store_en_1d	<=	scan_data_store_en;
--	else 
--		chopper_ctrl_1d   <= chopper_ctrl_1d;
	end if;
end process;
addr_reset					<= chopper_ctrl_rising;
chopper_ctrl_rising  	<=  (not chopper_ctrl_1d) and chopper_ctrl;
pm_steady_test_rising  	<=  (not pm_steady_test_1d) and pm_steady_test;
scan_data_store_en_rising  	<=  (not scan_data_store_en_1d) and scan_data_store_en;

----register interface
--		reg_wr		 	: in std_logic;
--		reg_wr_addr		: in std_logic_vector(3 downto 0);
--		reg_wr_data		: in std_logic_vector(15 downto 0);

------128 times stable no change  latch------------
half_wave_voltage	<= half_wave_voltage_reg;
offset_voltage	<= offset_voltage_reg;
config_reg_wr : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		config_reg0<=	x"4B8"; --:-2.05V          ---确认 config_reg0的位数
		config_reg1<=	x"333"; --:-1.5V
		config_reg2<=	x"4F5"; --:-0.95V
		config_reg3<=	x"6B8"; --:-0.4V
		count_time_reg<=	X"01F4";--100us
		pm_stable_cnt_reg<=	x"000F";--3us
		poc_stable_cnt_reg<=	x"0019";--5us  
		scan_inc_cnt_reg <=	x"29";--步进0.1V
		offset_voltage_reg<=	x"999";--  -1.5V
		half_wave_voltage_reg<=	x"547";--1.1V
		minus_voltage<=	"001" & x"60";--下限 1V
		step_cnt_reg	<=	x"27";--43 算法5次  扫点16次 共21次 耗时2.2ms 
		poc_cnt_set	<=	"0000000";--
		use_8apd	<= '0';
		use_4apd	<= '0';
		add_L_sub_H	<= '0';
	elsif rising_edge(sys_clk_80M) then		
		config_reg3	  <= ('1' & half_wave_voltage_reg(10 downto 0)) - offset_voltage_reg(10 downto 0);
		config_reg2	  <= config_reg3 - half_wave_voltage_reg(11 downto 1);
		config_reg1	  <= config_reg2 - half_wave_voltage_reg(11 downto 1);
		config_reg0	  <= config_reg1 - half_wave_voltage_reg(11 downto 1);
		if(reg_wr = '1') then
--			if(reg_wr_addr = 0)then
--				config_reg0<=	reg_wr_data(11 downto 0); ----确认 16 或者 12位
--			end if;
--			if(reg_wr_addr = 1)then
--				config_reg1<=	reg_wr_data(11 downto 0);
--			end if;
--			if(reg_wr_addr = 2)then
--				config_reg2<=	reg_wr_data(11 downto 0);
--			end if;
--			if(reg_wr_addr = 3)then
--				config_reg3<=	reg_wr_data(11 downto 0);
--			end if;
			if(reg_wr_addr = 4)then
				count_time_reg<=	reg_wr_data(15 downto 0);
			end if;
			if(reg_wr_addr = 5)then
				pm_stable_cnt_reg<=	reg_wr_data(15 downto 0);
			end if;
			if(reg_wr_addr = 6)then
				poc_stable_cnt_reg<=	reg_wr_data(15 downto 0);
			end if;
			if(reg_wr_addr = 7)then
				use_8apd<=	reg_wr_data(0);
				use_4apd<=	reg_wr_data(1);
			end if;
			if(reg_wr_addr = 8)then
				scan_inc_cnt_reg<= reg_wr_data(7 downto 0);
				step_cnt_reg	<=	(reg_wr_data(14 downto 8)&'0') + 11;
			end if;
			if(reg_wr_addr = 9)then
				offset_voltage_reg<=	reg_wr_data(11 downto 0);
			end if;
			if(reg_wr_addr = 10)then
				half_wave_voltage_reg<=	reg_wr_data(11 downto 0);
			end if;
			if(reg_wr_addr = 11)then
				minus_voltage <=	reg_wr_data(10 downto 0);
			end if;
			if(reg_wr_addr = 12)then
				poc_cnt_set <=	reg_wr_data(6 downto 0);
				add_L_sub_H	<= reg_wr_data(8);
			end if;
		else
			null;
		end if;
	end if;
end process;
	tan_adj_voltage	<= x"000";
 ---------set 128 times ------------------------------
 --------- 结束时 是否 需要输出 信号---------------------
  process(sys_clk_80M, sys_rst_n, chopper_ctrl_rising) 
  begin 
		if(sys_rst_n = '0') then
			poc_count	<= poc_cnt_set;
		elsif(sys_clk_80M'event and sys_clk_80M = '1') then
			if((chopper_ctrl_rising = '1' and pm_data_store_en = '1') or pm_steady_test_rising = '1') then
				if(add_L_sub_H = '0') then
					poc_count	<= poc_cnt_set + '1';
				else
					poc_count	<= poc_cnt_set - '1';
				end if;
			elsif(set_onetime_end = '1' and poc_count /= poc_cnt_set) then
				if(add_L_sub_H = '0') then
					poc_count 	<= poc_count + '1';
				else
					poc_count 	<= poc_count - '1';
				end if;
			else
				poc_count	<= poc_count;
			end if;
		end if;
  end process;
  
  process(set_onetime_end, poc_count) begin
	  if(set_onetime_end = '1' and poc_count = poc_cnt_set) then
			complete	<= '1';
	  else
			complete	<= '0';
	  end if;
  end process;
  -------set poc 128 times---------------------------
--  POC_ctrl		 : out std_logic_vector(7 downto 0);
--  POC_ctrl_en	 : out std_logic;
  process(sys_clk_80M, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			POC_ctrl	<= (others =>'0');
			POC_ctrl_en <= '0';
		elsif(sys_clk_80M'event and sys_clk_80M = '1') then
				if(wait_start_reg = '1' and set_count = x"01") then
					POC_ctrl <= poc_count(6 downto 0); 	--addra  与wea信号 通过状态机设置
					POC_ctrl_en <= '1';
				else
--					POC_ctrl	<= POC_ctrl;
					POC_ctrl_en <= '0';
				end if;
		end if;
  end process;
 
 ---------写一个 状态机来控DAC然后控PM---------------------
-- parameter	IDLE			   = 5'b00001,
--				DAC_set1		   = 5'b00010,
--				DAC_set2			= 5'b00100,
--				DAC_set3			= 5'b01000;
				--wait_1ms			= 5'b10000;
				
--signal 	state : STD_LOGIC_VECTOR(4 downto 0);
--signal 	state_next : STD_LOGIC_VECTOR(4 downto 0);
--
	process(alt_end, wait_finish, set_count) 
  begin 
		if(wait_finish = '1' and set_count /= 9) then
			add_set_count	<= '1';
		elsif(alt_end = '1' and set_count = 9) then
			add_set_count	<= '1';
		else
			add_set_count	<= '0';
		end if;
  end process;
  ----wait start----
  ----chopper come or pm steady test come, this is first
  ----when set count > 0, can use wait_finish as next wait start
  ----when set count = 9, next wait start is alt_end
 process(sys_clk_80M, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			wait_start_reg	<= '0';
			wait_start	<= '0';
		elsif(sys_clk_80M'event and sys_clk_80M = '1') then
			wait_start	<= wait_start_reg;
			if(scan_data_store_en = '1') then
				if(scan_data_store_en_rising = '1' or wait_finish = '1') then
					wait_start_reg	<= '1';
				else
					wait_start_reg	<= '0';	
				end if;
			else
				if((chopper_ctrl_rising = '1' or pm_steady_test_rising = '1') and pm_data_store_en = '1') then
					wait_start_reg	<= '1';		
				elsif(wait_finish = '1' and set_count > 0 and set_count /= 9 and complete = '0') then
					wait_start_reg	<= '1';	
				elsif(alt_end = '1' and set_count = 9) then
					wait_start_reg	<= '1';	
				else
					wait_start_reg	<= '0';
				end if;
			end if;
		end if;
  end process;

----set count------
----when chopper rising edge or pm_steady test rising edge come set to 1, this is start signal
----1: poc set and wait stable
----2: dac1 set and wait stable
----3: dac1 wait count
----4: dac2 set and wait stable
----5: dac2 wait count
----6: dac3 set and wait stable
----7: dac3 wait count
----8: dac4 set and wait stable
----9: dac5 wait count, wait algrithm ok
----10: result set and wait stable
----11: result wait count
---loop until complete

process(sys_clk_80M, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			set_count	<= x"00";
		elsif(sys_clk_80M'event and sys_clk_80M = '1') then
			if(pm_data_store_en = '1') then
				if(chopper_ctrl_rising = '1' or pm_steady_test_rising = '1') then
					set_count	<= x"01";
				elsif(complete = '1') then---all poc set is reached
					set_count	<= x"00";
				elsif(set_count > 0) then
					if(add_set_count = '1') then
						if(set_count < step_cnt_reg) then
							set_count	<= set_count + 1;
						else
							set_count	<= x"01";
						end if;
					end if;
				end if;
			else
				set_count	<= x"00";
			end if;
		end if;
  end process;
  
  process(wait_finish, set_count) 
  begin 
		if(wait_finish = '1' and set_count = step_cnt_reg) then
			set_onetime_end	<= '1';
		else
			set_onetime_end	<= '0';
		end if;
  end process;
  
  process(sys_clk_80M , sys_rst_n)  --confirm clk
begin
	if (sys_rst_n = '0') then
		Dac_Ena		<= '0';
		Dac_Data 	<= (others =>'0');
		alt_begin	<= '0';
		wait_count	<= x"13880";
		wait_dac_cnt<= x"00";
	elsif rising_edge(sys_clk_80M) then
		
		if(set_count = 1) then
			wait_count	<= poc_stable_cnt_reg & x"0";
			wait_dac_cnt<= x"00";
		elsif(set_count >0 and set_count(0) = '0') then
			wait_count	<= pm_stable_cnt_reg & x"0";
			wait_dac_cnt<= x"00";
		elsif(set_count(0) = '1') then
			wait_count	<= count_time_reg & x"0";
			wait_dac_cnt<= '0'&set_count(7 downto 1);
		elsif(scan_data_store_en = '1') then
			if(wait_stable_H_count_L = '1') then
				wait_count	<= pm_stable_cnt_reg & x"0";
				wait_dac_cnt<= x"FF";
			else
				wait_count	<= count_time_reg & x"0";
				wait_dac_cnt<= x"00";
			end if;
		end if;
		
		if(wait_start_reg = '1') then
			if(set_count > 0 and set_count(0) = '0') then
				Dac_Ena		<= '1';
			elsif(scan_data_store_en = '1' and wait_stable_H_count_L	= '1') then
				Dac_Ena		<= '1';
			else
				Dac_Ena		<= '0';
			end if;
		else
			Dac_Ena		<= '0';
		end if;
		
		if(set_count = 2) then
			Dac_Data	<= config_reg0;
		elsif(set_count = 4) then
			Dac_Data	<= config_reg1;
		elsif(set_count = 6) then
			Dac_Data	<= config_reg2;
		elsif(set_count = 8) then
			Dac_Data	<= config_reg3;
		elsif(set_count = 10) then
			Dac_Data	<= Dac_set_result;
		elsif(set_count > 10 and set_count(0) = '0') then
			Dac_Data <= Dac_set_result_low;
		elsif(scan_data_store_en = '1') then
			Dac_Data	<= scan_dac_data;
		end if;
		
		if(set_count = 9 and wait_finish = '1') then
			alt_begin	<= '1';
		else
			alt_begin	<= '0';
		end if;
  end if;
end process;

process(sys_clk_80M, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			Dac_set_result_low	<= (others =>'0');
		elsif(sys_clk_80M'event and sys_clk_80M = '1') then
			if(set_count = 10) then
				if(Dac_set_result > minus_voltage) then
					Dac_set_result_low <= Dac_set_result - minus_voltage;
				else
					Dac_set_result_low  <= x"000";
				end if;
			else
				if(wait_finish = '1' and set_count > 11 and set_count(0) = '1') then
					Dac_set_result_low <= Dac_set_result_low + scan_inc_cnt_reg;
				elsif(set_count < 10) then
					Dac_set_result_low	<= (others =>'0');
				end if;
			end if;			
		end if;
  end process;

process(sys_clk_80M, sys_rst_n) 
begin
	if (sys_rst_n = '0') then
		scan_dac_data 				<= x"000";
		wait_stable_H_count_L	<=  '1';
	elsif rising_edge(sys_clk_80M) then
		if(scan_data_store_en = '0') then
			scan_dac_data	<= x"000";
			wait_stable_H_count_L	<= '1';
		else
			if(wait_start_reg = '1') then
				wait_stable_H_count_L	<= not wait_stable_H_count_L;
			end if;
			
			if(wait_finish = '1' and wait_stable_H_count_L = '1') then
				scan_dac_data	<= scan_dac_data + scan_inc_cnt_reg(7 downto 0);
			end if;
		end if;
	end if;
end process;
process(sys_clk_80M, sys_rst_n) 
begin
	if (sys_rst_n = '0') then
		one_time_end <= '0';
	elsif rising_edge(sys_clk_80M) then
		one_time_end <= set_onetime_end;
	end if;
end process;
--
--
--process(pr_state,alt_end,wait_finish,poc_count,complete,chopper_ctrl, poc_stable_cnt_finish) --注意敏感列表
--begin
--	case pr_state is
--		when IDLE =>	
--				if(pm_steady_test_rising = '1' or chopper_ctrl_rising = '1') then
--					nx_state <= poc_set;
--				else
--					nx_state	<= pr_state;
--				end if;
--		when poc_set =>
--				--set_onetime_begin <= '1'; --等待POC稳定， 30us
--				if(wait_finish = '1') then
--					nx_state <= DAC_set1;
--				--	set_onetime_begin <= '0';
--				else
--					nx_state <= pr_state;
--				end if;
--		when DAC_set1 =>
--				--set_onetime_begin <= '0';	
--				if	(wait_finish = '1') then --confirm the first dac
--					nx_state <= DAC_cnt1;
--				else 
--					nx_state <= pr_state;	
--				end if;
--		when DAC_cnt1 =>
--				if	(wait_finish = '1') then --confirm the first dac
--					nx_state <= DAC_set2;
--				else 
--					nx_state <= pr_state;	
--				end if;
--		when DAC_set2 =>	
--				if	(wait_finish = '1')  then
--					nx_state <= DAC_cnt2;
--				else
--					nx_state <= pr_state;
--				end if;
--		when DAC_cnt2 =>	
--				if	(wait_finish = '1')  then
--					nx_state <= DAC_set3;
--				else
--					nx_state <= pr_state;
--				end if;
--		when DAC_set3  =>	    
--				if	(wait_finish = '1')  then
--					nx_state <= DAC_cnt3 ; ---------after the first three set complete ????????????????? 
--				else
--					nx_state <= pr_state;
--				end if;	
--		when DAC_cnt3  =>	    
--				if	(wait_finish = '1')  then
--					nx_state <= DAC_SET4 ; ---------after the first three set complete ????????????????? 
--				else
--					nx_state <= pr_state;
--				end if;	
--		when DAC_set4  =>	    
--				if	(wait_finish = '1')  then
--					nx_state <= DAC_cnt4; ---------after the first three set complete ????????????????? 
--					--set_onetime_end <= '1'; ------128 times enable
--				else
--					nx_state <= pr_state;
--					--set_onetime_end <= '0';
--				end if;
--		when DAC_cnt4  =>	    
--				if	(wait_finish = '1')  then
--					nx_state <= DAC_result ; ---------after the first three set complete ????????????????? 
--				else
--					nx_state <= pr_state;
--				end if;
--		when DAC_result  =>	
--				if	(wait_finish = '1')  then
--					nx_state <=  DAC_cnt_result; ---------after the first three set complete ????????????????? 
--				else
--					nx_state <= pr_state;
--				end if;
--		when DAC_cnt_result  =>	
--				if	(wait_finish = '1')  then
--					nx_state <= poc_set;
--				elsif(complete = '1') then
--					nx_state <= IDLE;
--				else
--					nx_state <= pr_state;
--				end if;
--		when others => 
--				nx_state	<= IDLE;
--	end case;
--end process;
------------state  output control DAC--------------------
------------DAC 是否 可以连续设置---------------------------
--------dac interface--
----		Dac_CLK    : out   STD_LOGIC;--40M  ----always or no always
----		Dac_Ena    : out   STD_LOGIC;--DAC set enable
----		Dac_Data   : out   STD_LOGIC_VECTOR (15 downto 0);--DAC value
----		Sys_Rst    : out   STD_LOGIC;--System reset,high active
----    确认DAC 时钟
--process(sys_clk_80M , sys_rst_n)  --confirm clk
--begin
--	if (sys_rst_n = '0') then
--		Dac_Ena		<= '0';
--		Dac_Data 	<= (others =>'0');
--	elsif rising_edge(sys_clk_80M) then
--		--set_onetime_end <= '1';
--		if(pr_state = ) then
--		
--		else
--		
--		end if;
--		case pr_state is
--			when IDLE =>	     
--				Dac_Ena		<= '0';                ------------confirm the enable  stable or rising
--				if(nx_state = poc_set) then
--					wait_start_reg	<= '1';
--					wait_count	<= poc_stable_cnt_reg & x"0";
--					wait_dac_cnt<= "000";
--				end if;
--			when poc_set =>	     
--				if(nx_state = DAC_set1) then
--					wait_start_reg	<= '1';
--					wait_count	<= pm_stable_cnt_reg & x"0";
--					wait_dac_cnt<= "000";
--					Dac_Ena		<= '1';                ------------confirm the enable  stable or rising
--					Dac_Data 	<=  config_reg1;
--				else
--					wait_start_reg	<= '0';
--					Dac_Ena		<= '0'; 
--				end if;
--			when DAC_set1 =>
--				if(nx_state = DAC_set2) then
--					wait_start_reg	<= '1';
--					wait_count	<= pm_stable_cnt_reg & x"0";
--					wait_dac_cnt<= "000";
--					Dac_Ena		<= '1';                ------------confirm the enable  stable or rising
--					Dac_Data 	<=  config_reg2;
--				else
--					wait_start_reg	<= '0';
--					Dac_Ena		<= '0'; 
--				end if;
--			when DAC_set2 =>	    
--				if(nx_state = DAC_set3) then
--					wait_start_reg	<= '1';
--					wait_count	<= pm_stable_cnt_reg & x"0";
--					wait_dac_cnt<= "011";
--					Dac_Ena		<= '1';                ------------confirm the enable  stable or rising
--					Dac_Data 	<=  config_reg3;
--				else
--					wait_start_reg	<= '0';
--					Dac_Ena		<= '0'; 
--				end if;
--			when DAC_set3  =>	    
--				if(nx_state = DAC_set4) then
--					wait_start_reg	<= '1';
--					wait_count	<= pm_stable_cnt_reg & x"0";
--					wait_dac_cnt<= "100";
--					Dac_Ena		<= '1';                ------------confirm the enable  stable or rising
--					Dac_Data 	<=  config_reg3;
--				else
--					wait_start_reg	<= '0';
--					Dac_Ena		<= '0'; 
--				end if;	
--			when DAC_set4  =>	    
--				if(nx_state = DAC_result)then
--					wait_start_reg	<= '1';
--					wait_count	<= pm_stable_cnt_reg & x"0";
--					wait_dac_cnt<= "101";
--					Dac_Ena		<= '1';                ------------confirm the enable  stable or rising
--					Dac_Data 	<=  dac_set_result;
--				else
--					wait_start_reg	<= '0';
--					Dac_Ena		<= '0'; 
--				end if;	
--			when DAC_result  => 	
--				if(alt_end = '1') then					---------------修改 使能条件
--					Dac_Ena		<= '1';                ------------confirm the time between lut_data_vld and dac_set_result
--					Dac_Data 	<= dac_set_result;
----					set_onetime_end <= '1';
--				else
--					Dac_Ena		<= '0';                
----					Dac_Data 	<= (others =>'0');
--				end if;
--			when others => null;
--		end case;	
--  end if;
--end process;

end Behavioral;

