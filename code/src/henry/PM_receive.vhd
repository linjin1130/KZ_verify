----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:18:28 11/27/2014 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity PM_receive is
	generic(
		tdc_chl_num		:	integer := 2
	);--修改
port(
	-- 
	   sys_clk_80M	:	in	std_logic;--system clock,80MHz
		sys_rst_n	:	in	std_logic;--system reset,low active
		fifo_rst			:	in	std_logic;
--		----dac interface--
		--Dac_Finish_out : out  STD_LOGIC;	--it has output 16 bit data
--		Dac_Sclk   : out  STD_LOGIC; --DAC chip clock
--		Dac_Csn    : out  STD_LOGIC; --DAC chip select
--		Dac_Din    : out  STD_LOGIC; --DAC data input
		
		scan_data_store_en : in  STD_LOGIC; 
		pm_data_store_en : in  STD_LOGIC; 
		pm_steady_test : in  STD_LOGIC; 
		dac_finish : in  STD_LOGIC; 
		Dac_Ena	  : out  STD_LOGIC; 
		dac_data	  : out  STD_LOGIC_vector(11 downto 0); 
		
		--poc interface
		--和师兄确认 poc 控制方法
		POC_ctrl		 : out std_logic_vector(6 downto 0);
		POC_ctrl_en	 : out std_logic;
		
		--register interface
		reg_wr		 	: in std_logic;                     -------------count set
		reg_wr_addr		: in std_logic_vector(3 downto 0);
		reg_wr_data		: in std_logic_vector(15 downto 0); ---------qen ren ---接受 左移三位
		
		
		apd_fpga_hit	: 	in	std_logic_vector(tdc_chl_num-1 downto 0);--apd pulse input

		---lut ram module
      -----128 lut?-------------------------------------	
		--lut_wr_en: in std_logic; -- LUT查找表写使能 
		lut_ram_rd_addr	: out std_logic_vector(9 downto 0); 
		lut_ram_rd_data	: in std_logic_vector(15 downto 0); 
		------lut_ram 128------------------------
		lut_ram_128_vld  : in std_logic;
		lut_ram_128_addr : in STD_LOGIC_vector(6 downto 0);
		lut_ram_128_data : out STD_LOGIC_vector(11 downto 0); 
		
		---
		--
		--exp_running	: in std_logic;
		-----pm_module----------------
		-----和林金确认pm控制端输出以确定八个计数的存储----
		--chopper_ctrl			:  in std_logic;

		--contact with upper
		---algrithm result
		---10 counter x 16bit, write 5 time
		---1 PM result write 1 time
		---total is 128 x 6 time
		
		alg_data_wr			: out	std_logic;
		alg_data_wr_data	: out	std_logic_vector(47 downto 0);
		
		---syn_light : in std_logic;--when high, go into phase steady state
		chopper_ctrl : in std_logic--when high, go into phase steady state
	);
end PM_receive;

architecture Behavioral of PM_receive      is

	COMPONENT atan_lut
	PORT(
		sys_clk : IN std_logic;
		sys_rst : IN std_logic;
		start : IN std_logic;
		use_8apd     : in std_logic;
		use_4apd     : in std_logic;
		chnl_cnt_reg0_out : IN std_logic_vector(9 downto 0);
		chnl_cnt_reg1_out : IN std_logic_vector(9 downto 0);
		chnl_cnt_reg2_out : IN std_logic_vector(9 downto 0);
		chnl_cnt_reg3_out : IN std_logic_vector(9 downto 0);
		chnl_cnt_reg4_out : IN std_logic_vector(9 downto 0);
		chnl_cnt_reg5_out : IN std_logic_vector(9 downto 0);
		chnl_cnt_reg6_out : IN std_logic_vector(9 downto 0);
		chnl_cnt_reg7_out : IN std_logic_vector(9 downto 0);
		-----128 lut?-------------------------------------	
		--lut_wr_en: in std_logic; -- LUT查找表写使能 
		lut_ram_rd_addr	: out std_logic_vector(9 downto 0); 
		lut_ram_rd_data	: in std_logic_vector(15 downto 0); 

		------lut_ram 128------------------------
		min_set_result_en : in std_logic;
		min_set_result : in std_logic_vector(11 downto 0);
		addr_reset : in STD_LOGIC;
		lut_ram_128_addr : in STD_LOGIC_vector(6 downto 0);
		lut_ram_128_data : out STD_LOGIC_vector(11 downto 0); 
		------
		tan_adj_voltage : in std_logic_vector(11 downto 0);
		half_wave_voltage : in std_logic_vector(11 downto 0);
		offset_voltage : in std_logic_vector(11 downto 0);
		------
		result_ok : OUT std_logic;
		DAC_set_addr   : in std_logic_vector(6 downto 0);
		DAC_set_result : OUT std_logic_vector(11 downto 0)
		);
	END COMPONENT;
   COMPONENT PM_control
	PORT(
		sys_clk_80M : IN std_logic;
		sys_rst_n : IN std_logic;
--		Dac_finish : IN std_logic;
		Dac_set_result : IN std_logic_vector(11 downto 0);
		pm_steady_test : IN std_logic;
				
		pm_data_store_en : in std_logic;
		scan_data_store_en : in std_logic;
		alt_begin : out std_logic;
		alt_end : IN std_logic;
		use_8apd     : out std_logic;
		use_4apd     : out std_logic;
		wait_start	 :	out 	std_logic;
		wait_count 	 : out 	std_logic_vector(19 downto 0);
		wait_dac_cnt : out 	std_logic_vector(7 downto 0);
		wait_finish	 :	in 	std_logic;
		reg_wr : IN std_logic;
		reg_wr_addr : IN std_logic_vector(3 downto 0);
		reg_wr_data : IN std_logic_vector(15 downto 0);
--		lut_data : IN std_logic_vector(15 downto 0);
		addr_reset : out std_logic;
		chopper_ctrl : IN std_logic;    
		one_time_end		: out std_logic;
--		Dac_CLK : OUT std_logic;
		Dac_Ena : OUT std_logic;
		Dac_Data : OUT std_logic_vector(11 downto 0);
		half_wave_voltage : out std_logic_vector(11 downto 0);
		offset_voltage : out std_logic_vector(11 downto 0);
		tan_adj_voltage : out std_logic_vector(11 downto 0);
		Sys_Rst : OUT std_logic;
		POC_ctrl : OUT std_logic_vector(6 downto 0);
		POC_ctrl_en : OUT std_logic
--		lut_addr : OUT std_logic_vector(9 downto 0)
		);
	END COMPONENT;
--	COMPONENT DAC_control
--	PORT(
--		CLK : IN std_logic;
--		Dac_Ena : IN std_logic;
--		Dac_Data : IN std_logic_vector(15 downto 0);
--		Sys_Rst : IN std_logic;          
--		Dac_Finish : OUT std_logic;
--		Dac_Sclk : OUT std_logic;
--		Dac_Csn : OUT std_logic;
--		Dac_Din : OUT std_logic
--		);
--	END COMPONENT;
		COMPONENT PM_count
	PORT(
		sys_clk_80M : IN std_logic;
		sys_rst_n : IN std_logic;
		fifo_rst			:	in	std_logic;
		apd_fpga_hit : IN std_logic_vector(1 downto 0);
		--tdc_count_time_value : IN std_logic_vector(31 downto 0);
		dac_finish : IN std_logic;  
		
--		pm_data_store_en : in std_logic;
--		scan_data_store_en : in std_logic;
		offset_voltage		: in std_logic_vector(11 downto 0);--offset_voltage
		half_wave_voltage	: in std_logic_vector(11 downto 0);--half_wave_voltage
		result_ok : in std_logic;
		DAC_set_addr   : in std_logic_vector(6 downto 0);
		DAC_set_result : in std_logic_vector(11 downto 0);
		DAC_set_data : in std_logic_vector(11 downto 0);
		one_time_end		: in std_logic;
		use_8apd     : in std_logic;
		use_4apd     : in std_logic;
		pm_data_store_en	: in std_logic;
		wait_start	 :	in 	std_logic;
		wait_count 	 : in 	std_logic_vector(19 downto 0);
		wait_dac_cnt : in 	std_logic_vector(7 downto 0);
		wait_finish	 :	out 	std_logic;
		
		chnl_cnt_reg0_out : OUT std_logic_vector(9 downto 0);
		chnl_cnt_reg1_out : OUT std_logic_vector(9 downto 0);
		chnl_cnt_reg2_out : OUT std_logic_vector(9 downto 0);
		chnl_cnt_reg3_out : OUT std_logic_vector(9 downto 0);
		chnl_cnt_reg4_out : OUT std_logic_vector(9 downto 0);
		chnl_cnt_reg5_out : OUT std_logic_vector(9 downto 0);
		chnl_cnt_reg6_out : OUT std_logic_vector(9 downto 0);
		chnl_cnt_reg7_out : OUT std_logic_vector(9 downto 0);
--		chnl_cnt_reg8_out : OUT std_logic_vector(9 downto 0);
--		chnl_cnt_reg9_out : OUT std_logic_vector(9 downto 0);

		chopper_ctrl  : in std_logic;
		lut_ram_128_vld  : in std_logic;
		lut_ram_128_addr : in STD_LOGIC_vector(6 downto 0);
		lut_ram_128_data : in STD_LOGIC_vector(11 downto 0); 
		
		min_set_result_en : out std_logic;
		min_set_result : out std_logic_vector(11 downto 0);
		alg_data_wr : OUT std_logic;
		alg_data_wr_data : OUT std_logic_vector(47 downto 0)
		);
	END COMPONENT;
	
	signal use_8apd     : std_logic;
	signal use_4apd     : std_logic;
	signal alt_begin :  std_logic;
	signal result_ok :  std_logic;
	signal addr_reset :  std_logic;
--	signal Dac_Finish :  std_logic;
	signal one_time_end		: std_logic;
	signal Sys_Rst :  std_logic;
	signal DAC_set_addr   : std_logic_vector(6 downto 0);
	signal dac_set_result :std_logic_vector(11 downto 0);
	signal DAC_set_data :std_logic_vector(11 downto 0);
	signal min_set_result_en : std_logic;
	signal min_set_result : std_logic_vector(11 downto 0);
--	signal Dac_Data :std_logic_vector(11 downto 0);
	signal chnl_cnt_reg0_out : std_logic_vector(9 downto 0);
	signal chnl_cnt_reg1_out : std_logic_vector(9 downto 0);
	signal chnl_cnt_reg2_out : std_logic_vector(9 downto 0);
	signal chnl_cnt_reg3_out : std_logic_vector(9 downto 0);
	signal chnl_cnt_reg4_out : std_logic_vector(9 downto 0);
	signal chnl_cnt_reg5_out : std_logic_vector(9 downto 0);
	signal chnl_cnt_reg6_out : std_logic_vector(9 downto 0);
	signal chnl_cnt_reg7_out : std_logic_vector(9 downto 0);
--	signal chnl_cnt_reg8_out : std_logic_vector(9 downto 0);
--	signal chnl_cnt_reg9_out : std_logic_vector(9 downto 0);

	signal tan_adj_voltage : std_logic_vector(11 downto 0);
	signal half_wave_voltage : std_logic_vector(11 downto 0);
	signal offset_voltage : std_logic_vector(11 downto 0);
	
	signal lut_ram_128_data_sig : std_logic_vector(11 downto 0);
	
	signal	wait_start	 :	std_logic;
	signal	wait_count 	 : std_logic_vector(19 downto 0);
	signal	wait_dac_cnt : std_logic_vector(7 downto 0);
	signal	wait_finish	 :	std_logic;
begin
  ------------------------------
      
  Inst_atan_lut: atan_lut PORT MAP(
		sys_clk => sys_clk_80M,
		sys_rst => sys_rst,
		start => alt_begin,
		use_8apd => use_8apd,
		use_4apd => use_4apd,
		offset_voltage =>offset_voltage,
		half_wave_voltage =>half_wave_voltage,
		chnl_cnt_reg0_out =>chnl_cnt_reg0_out,
		chnl_cnt_reg1_out =>chnl_cnt_reg1_out,
		chnl_cnt_reg2_out =>chnl_cnt_reg2_out,
		chnl_cnt_reg3_out =>chnl_cnt_reg3_out,
		chnl_cnt_reg4_out =>chnl_cnt_reg4_out,
		chnl_cnt_reg5_out =>chnl_cnt_reg5_out,
		chnl_cnt_reg6_out =>chnl_cnt_reg6_out,
		chnl_cnt_reg7_out =>chnl_cnt_reg7_out,
		lut_ram_rd_addr => lut_ram_rd_addr,
		lut_ram_rd_data => lut_ram_rd_data,
		addr_reset => addr_reset,
		tan_adj_voltage => tan_adj_voltage,
		lut_ram_128_addr => lut_ram_128_addr,
		lut_ram_128_data => lut_ram_128_data_sig,
		result_ok => result_ok,
		DAC_set_addr => DAC_set_addr,
		DAC_set_result => Dac_set_result,
		min_set_result_en => min_set_result_en,
		min_set_result => min_set_result
	);
	dac_data	<= DAC_set_data;
	POC_ctrl <= DAC_set_addr;
	Inst_PM_control: PM_control PORT MAP(
		sys_clk_80M => sys_clk_80M,
		sys_rst_n => sys_rst_n,
		offset_voltage =>offset_voltage,
		half_wave_voltage =>half_wave_voltage,
		use_8apd => use_8apd,
		use_4apd => use_4apd,
		one_time_end => one_time_end,
		Dac_Ena => Dac_Ena,
		Dac_Data => DAC_set_data,
		Sys_Rst =>  Sys_Rst,
		Dac_set_result => Dac_set_result,
		tan_adj_voltage => tan_adj_voltage,
		wait_start => wait_start,
		wait_count => wait_count,
		wait_finish => wait_finish,
		wait_dac_cnt => wait_dac_cnt,
		POC_ctrl => DAC_set_addr,
		POC_ctrl_en => POC_ctrl_en,
		addr_reset => addr_reset,
		alt_begin => alt_begin,
		alt_end => result_ok,
		reg_wr => reg_wr,
		reg_wr_addr => reg_wr_addr,
		reg_wr_data => reg_wr_data,
		PM_steady_test => PM_steady_test,
		pm_data_store_en	=> pm_data_store_en,
		scan_data_store_en	=> scan_data_store_en,
		chopper_ctrl => chopper_ctrl
	);

	Inst_PM_count: PM_count PORT MAP(
		sys_clk_80M => sys_clk_80M,
		sys_rst_n => sys_rst_n,
		fifo_rst => fifo_rst,
		apd_fpga_hit => apd_fpga_hit,
		dac_finish => dac_finish,
		use_8apd => use_8apd,
		use_4apd => use_4apd,
		one_time_end => one_time_end,
		pm_data_store_en => pm_data_store_en,
		offset_voltage =>offset_voltage,
		half_wave_voltage =>half_wave_voltage,
		chnl_cnt_reg0_out => chnl_cnt_reg0_out,
		chnl_cnt_reg1_out => chnl_cnt_reg1_out ,
		chnl_cnt_reg2_out => chnl_cnt_reg2_out,
		chnl_cnt_reg3_out => chnl_cnt_reg3_out,
		chnl_cnt_reg4_out => chnl_cnt_reg4_out,
		chnl_cnt_reg5_out => chnl_cnt_reg5_out,
		chnl_cnt_reg6_out => chnl_cnt_reg6_out,
		chnl_cnt_reg7_out => chnl_cnt_reg7_out,
--		chnl_cnt_reg8_out => chnl_cnt_reg8_out,
--		chnl_cnt_reg9_out => chnl_cnt_reg9_out,
		lut_ram_128_vld => lut_ram_128_vld,
		lut_ram_128_addr => lut_ram_128_addr,
		lut_ram_128_data => lut_ram_128_data_sig,
		wait_start => wait_start,
		wait_finish => wait_finish,
		wait_dac_cnt		=> wait_dac_cnt,
		wait_count		=> wait_count,
		alg_data_wr => alg_data_wr,
		alg_data_wr_data => alg_data_wr_data,
--		alt_end => result_ok,
--		scan_data_store_en	=> scan_data_store_en,
--		pm_data_store_en	=> pm_data_store_en,
		result_ok => result_ok,
		DAC_set_addr => DAC_set_addr,
		DAC_set_result => Dac_set_result,
		DAC_set_data => DAC_set_data,
		min_set_result_en => min_set_result_en,
		min_set_result => min_set_result,
--		alt_begin => alt_begin,
		chopper_ctrl => chopper_ctrl
	);
	lut_ram_128_data	<= lut_ram_128_data_sig;
end Behavioral;

