----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:52:04 08/05/2014 
-- Design Name: 
-- Module Name:    OSERDES_TEST - Behavioral 
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
-- error help: http://www.xilinx.com/support/answers/43559.html
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity DPS_QKD is
	generic(
   DATA_WIDTH             : integer := 32;     -- Data Width
   BURST_LEN              : integer := 1;      -- Burst Length
	RND_CHIP_NUM           : integer := 4;     -- No. of random chip wng-x		
	DPS_Base_Addr			  :	std_logic_vector(7 downto 0) := X"A0";
	DPS_High_Addr			  :	std_logic_vector(7 downto 0) := X"AF"
    );
    Port ( 
	        sys_clk	   : in std_logic;
	        sys_clk_10M : in std_logic;
			  ext_clk_I	:	in	std_logic;
			  ext_clk_IB	:	in	std_logic;
--	        sys_clk_500M : in std_logic;
--	        sys_clk_250m : in std_logic;
			  sys_rst_n 	: in  STD_LOGIC;
			  
			  fifo_clr		:	in	std_logic;
			---gps interface  
			exp_running	:	in std_logic;
			gps_pps		:	in std_logic;
			
		   GPS_pulse_int			:  out std_logic;--80M clock domain
		   GPS_pulse_int_active	:  out std_logic;--80M clock domain

			------------inside interface to cpldif module--------------------------
			cpldif_dps_addr	:	in	std_logic_vector(7 downto 0);
			cpldif_dps_wr_en	:	in	std_logic;--register write enable
			cpldif_dps_wr_data	:	in	std_logic_vector(31 downto 0);
			cpldif_dps_rd_en	:	in	std_logic;--refister read enable
			dps_cpldif_rd_data	:	out	std_logic_vector(31 downto 0);

-------fifo interface-------
			
			dps_cpldif_fifo_clr		:	in	std_logic;
			dps_cpldif_fifo_wr_en		:	out	std_logic;
			dps_cpldif_fifo_wr_data		:	out	std_logic_vector(63 downto 0);
			cpldif_dps_fifo_prog_full	:	in	std_logic;
			
			apd_fpga_hit	: 	in	std_logic_vector(1 downto 0);--apd pulse input
			  
			---WNG-X interface
			Rnd_Gen_WNG_Data 			: IN std_logic_vector(RND_CHIP_NUM-1 downto 0);
			Rnd_Gen_WNG_Clk 			: OUT std_logic_vector(RND_CHIP_NUM-1 downto 0);
			Rnd_Gen_WNG_Oe_n 			: OUT std_logic_vector(RND_CHIP_NUM-1 downto 0);
			
			tdc_data_store_en	: out std_logic;
         chopper_ctrl				:  out  STD_LOGIC;
			APD_tdc_en				:  out std_logic;--80M clock domain
--			chopper_ctrl_80M			:  out  std_logic;--80M clock domain, 1: disable tdc, 0 enable tdc
         syn_light					:  out  STD_LOGIC;
         PPG_start					:	OUT std_logic;--serial output enable
         PPG_clock					:	OUT std_logic;--10MHz
			
			-----Bob------
			syn_light_sel		:	out	std_logic;
			syn_light_ext		:	in	std_logic;
			POC_start			:	out std_logic_vector(6 downto 0);--serial output
			POC_stop				:	out std_logic_vector(6 downto 0);--serial output
			
			Dac_Sclk   			: out  STD_LOGIC; --DAC chip clock
			Dac_Csn    			: out  STD_LOGIC; --DAC chip select
			Dac_Din    			: out  STD_LOGIC; --DAC data input
			
			----end Bob---
			send_en_AM_p				:  out std_logic;--250M clock domain
			send_en_AM_n				:  out std_logic;--250M clock domain

			SERIAL_OUT_p			:	out std_logic_vector(2 downto 0);--serial output
			SERIAL_OUT_n			:	out std_logic_vector(2 downto 0)--serial output
			  );
end DPS_QKD;

architecture Behavioral of DPS_QKD is

COMPONENT clock_manage
	PORT(
		sys_clk 		: IN std_logic;
		ext_clk_I	:	in	std_logic;
		ext_clk_IB	:	in	std_logic;
		sys_rst_in 	: IN std_logic; 
--		sys_rst_n1	: out    std_logic;--generated reset low active
--		sys_rst_n3	: out    std_logic;--generated reset low active
--		sys_rst_h	: out    std_logic;--generated reset heigh activ
		CLK_OUT1 : OUT std_logic;
		CLK_OUT2 : OUT std_logic;
		CLK_OUT3 : OUT std_logic;
		CLK_OUT4 : OUT std_logic;
		CLK_OUT5 : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT Rnd_Gen_TOP
	generic
    (
     BURST_LEN 		: integer := 1;   -- Data Width
     DATA_WIDTH 		: integer := 32;   -- Data Width
     RND_CHIP_NUM   	: integer := 4     -- Byte Write Width
    );
	PORT(
		Sys_clk : IN std_logic;
		sys_rst_n : IN std_logic;
		fifo_clr : IN std_logic;
		test_rnd				:  IN std_logic;--80M clock domain
		test_rnd_data		:  IN std_logic_vector(15 downto 0);--80M clock domain
		random_fifo_rd_clk : IN std_logic;
		Rnd_Gen_WNG_Data : IN std_logic_vector(RND_CHIP_NUM-1 downto 0);
		random_fifo_rd_en : IN std_logic;          
		Rnd_Gen_WNG_Clk : OUT std_logic_vector(RND_CHIP_NUM-1 downto 0);
		Rnd_Gen_WNG_Oe_n : OUT std_logic_vector(RND_CHIP_NUM-1 downto 0);
		random_fifo_empty : OUT std_logic;
		random_fifo_vld : OUT std_logic;
		random_fifo_rd_data : OUT std_logic_vector(DATA_WIDTH*BURST_LEN-1 downto 0)
		);
	END COMPONENT;

	COMPONENT SRAM_RD_WR
	generic
    (
     BURST_LEN  : integer := 1;    -- Burst Length
--     ADDR_WIDTH : integer := 19;   -- Address Width
     DATA_WIDTH : integer := 32   -- Data Width
--     BW_WIDTH   : integer := 4    -- Byte Write Width
    );
	PORT(
		sys_clk : IN std_logic;
		sys_rst_n : IN std_logic;
		fifo_clr : IN std_logic;
		exp_running : IN std_logic;
		
		dps_cpldif_fifo_wr_en		:	out	std_logic;
	   dps_cpldif_fifo_wr_data		:	out	std_logic_vector(63 downto 0);
	   cpldif_dps_fifo_prog_full	:	in	std_logic;
		
		send_write_prepare		: 	in std_logic;
		send_write_back_en		: 	in std_logic;
		send_write_back_data		: 	in std_logic_VECTOR(63 downto 0);
		
		rnd_data_store_en	: in std_logic;
		PM_wr_en			:	in	std_logic;
	   PM_wr_data		:	in	std_logic_vector(47 downto 0);
		POC_fifo_rdy : IN std_logic;
		Alice_H_Bob_L : IN std_logic;
		serial_fifo_rdy : IN std_logic;
		random_fifo_empty : IN std_logic;
		random_fifo_vld : IN std_logic;
		random_fifo_rd_data : IN std_logic_vector(DATA_WIDTH*BURST_LEN-1 downto 0);          
		serial_fifo_wr_en : OUT std_logic;
		serial_fifo_wr_data : OUT std_logic_vector(DATA_WIDTH*BURST_LEN-1 downto 0);
		random_fifo_rd_en : OUT std_logic
		);
	END COMPONENT;

	COMPONENT serial_control
	generic
    (
     BURST_LEN  : integer := 1;    -- Burst Length
     DATA_WIDTH : integer := 32    -- Data Width
    );
	PORT(
		sys_clk_200M : IN std_logic;
--		sys_clk_100M : IN std_logic;
		sys_rst_n : IN std_logic;
		fifo_clr : IN std_logic;
		exp_running						:	in std_logic;--serial output enable
		test_signal_delay : IN std_logic;
		serial_fifo_wr_clk : IN std_logic;
		serial_fifo_rd_clk : IN std_logic;
		serial_out_clk : IN std_logic;
		rnd_data_store_en : IN std_logic;
		serial_fifo_wr_en : IN std_logic;
		serial_fifo_wr_data : IN std_logic_vector(DATA_WIDTH*BURST_LEN-1 downto 0);
		Alice_H_Bob_L					:	in std_logic;--serial output enable
		send_enable						:	in std_logic;--serial output enable
		send_en							:	in std_logic;--serial output enable
		send_en_AM						:	in std_logic;--serial output enable
		delay_load						:	in std_logic;--serial output enable
		delay_AM1						: in	std_logic_vector(31 downto 0);
--		delay_AM2						: in	std_logic_vector(4 downto 0);
--		delay_PM 						: in	std_logic_vector(4 downto 0);
		
		serial_fifo_rdy				:  out std_logic;--fifo has spare space
		
		send_write_prepare		: 	out std_logic;
		send_write_back_en		: 	out std_logic;
		send_write_back_data		: 	out std_logic_VECTOR(63 downto 0);
		
		delay_AM1_out			: out	std_logic_vector(29 downto 0);
--		delay_AM2_out			: out	std_logic_vector(4 downto 0);
--		delay_PM_out 			: out	std_logic_vector(4 downto 0);
		send_en_AM_p				:  out std_logic;--250M clock domain
	   send_en_AM_n				:  out std_logic;--250M clock domain
		SERIAL_OUT_p			:	out std_logic_vector(2 downto 0);--serial output
		SERIAL_OUT_n			:	out std_logic_vector(2 downto 0)--serial output
		);
	END COMPONENT;
	
	COMPONENT dps_reg_resolve
	generic(
		DPS_Base_Addr : std_logic_vector(7 downto 0) := X"A0";
		DPS_High_Addr : std_logic_vector(7 downto 0) := X"AF"
	);
	PORT(
		sys_clk_80M : IN std_logic;
		sys_rst_n : IN std_logic;
		cpldif_dps_addr : IN std_logic_vector(7 downto 0);
		cpldif_dps_wr_en : IN std_logic;
		cpldif_dps_rd_en : IN std_logic;
		cpldif_dps_wr_data : IN std_logic_vector(31 downto 0);          
		Alice_H_Bob_L : OUT std_logic;
--		exp_stopping : OUT std_logic;
		test_signal_delay: out std_logic;
		scan_data_store_en: out std_logic;
		rnd_data_store_en	: out std_logic;
		rdb_rnd_store_en	: out std_logic;
		pm_data_store_en	: out std_logic;
		tdc_data_store_en	: out std_logic;
		pm_steady_test 		: out std_logic;--80M clock domain
		poc_test_en 			: out	std_logic;	
		dac_test_en 			: out	std_logic;
		test_rnd				:  out std_logic;--80M clock domain
		test_rnd_data		:  out std_logic_vector(15 downto 0);--80M clock domain
		delay_load : OUT std_logic;
		DPS_send_AM_dly_cnt : OUT std_logic_vector(7 downto 0);
		DPS_send_PM_dly_cnt : OUT std_logic_vector(7 downto 0);
		DPS_syn_dly_cnt : OUT std_logic_vector(11 downto 0);
		DPS_chopper_cnt : OUT std_logic_vector(3 downto 0);
		DPS_round_cnt : OUT std_logic_vector(15 downto 0);
		delay_AM1 : OUT std_logic_vector(31 downto 0);
		set_send_enable_cnt			: out	std_logic_vector(31 downto 0);--for Alice
		set_send_disable_cnt			: out	std_logic_vector(31 downto 0);--for Alice
	   set_chopper_enable_cnt		: out	std_logic_vector(31 downto 0);--for Bob
	   set_chopper_disable_cnt		: out	std_logic_vector(31 downto 0);--for Bob
		
		lut_wr_addr			: out	std_logic_vector(9 downto 0);
		lut_wr_data			: out	std_logic_vector(15 downto 0);
		lut_wr_en 			: out	std_logic;
		
		reg_wr_addr			: out	std_logic_vector(3 downto 0);
		reg_wr_data			: out	std_logic_vector(15 downto 0);
		reg_wr_en 			: out	std_logic;
--		delay_AM2 : OUT std_logic_vector(4 downto 0);
--		delay_PM : OUT std_logic_vector(4 downto 0);
		delay_AM1_out			: in	std_logic_vector(29 downto 0);
		GPS_period_cnt			: out	std_logic_vector(31 downto 0);--bit 31: 1 use intenal gps; 0 use external gps
--		delay_AM2_out			: in	std_logic_vector(4 downto 0);
--		delay_PM_out 			: in	std_logic_vector(4 downto 0);
			
		dps_cpldif_rd_data : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	
	COMPONENT DPS_control
	PORT(
		sys_clk_80M : IN std_logic;
		sys_clk_250M : IN std_logic;
		sys_rst_n : IN std_logic;
		exp_running : IN std_logic;
		Alice_H_Bob_L : IN std_logic;
		gps_pulse : IN std_logic;
		syn_light_ext : IN std_logic;
--		pm_steady_test 		: in std_logic;--80M clock domain
		DPS_send_PM_dly_cnt : IN std_logic_vector(7 downto 0);
		DPS_send_AM_dly_cnt : IN std_logic_vector(7 downto 0);
		DPS_syn_dly_cnt : IN std_logic_vector(11 downto 0);
		DPS_round_cnt : IN std_logic_vector(15 downto 0);
		DPS_chopper_cnt : IN std_logic_vector(3 downto 0);  
		GPS_period_cnt			: in	std_logic_vector(31 downto 0);--bit 31: 1 use intenal gps; 0 use external gps
		set_send_enable_cnt			: in	std_logic_vector(31 downto 0);--for Alice
		set_send_disable_cnt			: in	std_logic_vector(31 downto 0);--for Alice
	   set_chopper_enable_cnt		: in	std_logic_vector(31 downto 0);--for Bob
	   set_chopper_disable_cnt		: in	std_logic_vector(31 downto 0);--for Bob
	   GPS_pulse_int			:  out std_logic;--80M clock domain
	   GPS_pulse_int_active	:  out std_logic;--80M clock domain
		exp_running_250M :	OUT std_logic;
		PPG_start :	OUT std_logic;
		syn_light : OUT std_logic;
		chopper_ctrl : OUT std_logic;
		chopper_ctrl_80M : OUT std_logic;
--		send_en_AM_p				:  out std_logic;--250M clock domain
--	   send_en_AM_n				:  out std_logic;--250M clock domain
		APD_tdc_en : OUT std_logic;
		send_en_AM : OUT std_logic;
		send_en : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT POC_output_control
	generic
    (
	  BURST_LEN  : integer := 1;    -- Burst Length
     DATA_WIDTH : integer := 32    -- Data Width
    );
	PORT(
		sys_clk : IN std_logic;
		sys_rst_n : IN std_logic;
		fifo_clr : IN std_logic;
		exp_running : IN std_logic;
		syn_light : IN std_logic;
		Alice_H_Bob_L : IN std_logic;
		POC_fifo_wr_en : IN std_logic;
		POC_fifo_wr_data : IN std_logic_vector(31 downto 0);
--		chopper_contrl : IN std_logic;
--		APD_tdc_en				:  out std_logic;--80M clock domain
		Dac_Ena : OUT std_logic;
		dac_data : OUT std_logic_vector(15 downto 0);
		poc_test_en 			: in	std_logic;
		poc_test_data		 	: IN std_logic_vector(6 downto 0);
		dac_test_en 			: in	std_logic;
		dac_test_data		 	: IN std_logic_vector(15 downto 0);
		pm_dac_en 			: in	std_logic;
		pm_dac_data		 	: IN std_logic_vector(11 downto 0);
		lut_ram_128_vld  : out std_logic;
		lut_ram_128_addr : out std_logic_vector(6 downto 0);
		lut_ram_128_data : IN std_logic_vector(11 downto 0);
		POC_control_en : IN std_logic;
		POC_control : IN std_logic_vector(6 downto 0);          
		POC_fifo_rdy : OUT std_logic;
		POC_start : OUT std_logic_vector(6 downto 0);
		POC_stop : OUT std_logic_vector(6 downto 0)
		);
	END COMPONENT;
	
	COMPONENT PM_receive
	PORT(
		sys_clk_80M : IN std_logic;
		sys_rst_n : IN std_logic;
		fifo_rst			:	in	std_logic;
		dac_finish : IN std_logic;
		reg_wr : IN std_logic;
		reg_wr_addr : IN std_logic_vector(3 downto 0);
		reg_wr_data : IN std_logic_vector(15 downto 0);
		apd_fpga_hit : IN std_logic_vector(1 downto 0);
		lut_ram_rd_data : IN std_logic_vector(15 downto 0);
		lut_ram_128_addr : IN std_logic_vector(6 downto 0);
		lut_ram_128_vld  : in std_logic;
		chopper_ctrl : IN std_logic;          
		pm_steady_test : IN std_logic; 
		scan_data_store_en: in std_logic;
		pm_data_store_en	: in std_logic;
		Dac_Ena : OUT std_logic;
		dac_data : OUT std_logic_vector(11 downto 0);
		POC_ctrl : OUT std_logic_vector(6 downto 0);
		POC_ctrl_en : OUT std_logic;
		lut_ram_rd_addr : OUT std_logic_vector(9 downto 0);
		lut_ram_128_data : OUT std_logic_vector(11 downto 0);
		alg_data_wr : OUT std_logic;
		alg_data_wr_data : OUT std_logic_vector(47 downto 0)
		);
	END COMPONENT;

	COMPONENT DAC_INTERFACE
	PORT(
		CLK : IN std_logic;
		Dac_Ena : IN std_logic;
		Dac_Data : IN std_logic_vector(15 downto 0);
		Sys_Rst_n : IN std_logic;          
		Dac_Finish : OUT std_logic;
		Dac_Sclk : OUT std_logic;
		Dac_Csn : OUT std_logic;
		Dac_Din : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT lut_ram
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    clkb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
	END COMPONENT;
	-- COMP_TAG_END ------ End COMPONENT Declaration ------------
	
--	signal sys_rst_n1 : std_logic;
--	signal sys_rst_n3 : std_logic;
--	signal sys_clk_80M : std_logic;
	signal exp_running_250M : std_logic;
	signal sys_clk_200M : std_logic;
	signal sys_clk_500M : std_logic;
--	signal sys_clk_100M : std_logic;
	signal sys_clk_250M : std_logic;
signal		Dac_Finish	 			: std_logic;		
signal		poc_test_en 			: std_logic;		
signal		dac_test_en 			: std_logic;	
signal		pm_dac_en 			: std_logic;
signal		pm_dac_data		 	: std_logic_vector(11 downto 0);
signal test_rnd_data		:   std_logic_vector(15 downto 0);--80M clock domain

signal SERIAL_OUT_p_reg		:	std_logic_vector(2 downto 0);--serial output
signal SERIAL_OUT_n_reg		:	std_logic_vector(2 downto 0);--serial output

signal		scan_data_store_en: std_logic;
signal		rdb_rnd_store_en	: std_logic;
signal		rnd_data_store_en	: std_logic;
signal		pm_data_store_en	: std_logic;

signal		dac_ena 			: std_logic;
signal		dac_data		 	: std_logic_vector(15 downto 0);

signal pm_steady_test 		: std_logic;--80M clock domain
signal test_signal_delay 		: std_logic;--80M clock domain

signal		lut_ram_128_addr : std_logic_vector(6 downto 0);
signal		lut_ram_128_data : std_logic_vector(11 downto 0);
--signal	exp_running_250M         :  std_logic;
signal	test_rnd             	:  std_logic;
signal	delay_load              :  std_logic;
----
signal	chopper_ctrl_sig        :  std_logic;
signal	send_enable             :  std_logic;
signal	send_en                 :  std_logic;
signal	send_en_AM              :  std_logic;

-----------------for Bob
signal		POC_control_en    :  std_logic:= '0';
signal		POC_control 		: std_logic_vector(6 downto 0):= "0000000";

signal		lut_rd_data			: std_logic_vector(15 downto 0):=(others => '0');
signal		lut_rd_addr			: std_logic_vector(9 downto 0):=(others => '0');
signal		lut_wr_addr			: std_logic_vector(9 downto 0);
signal		lut_wr_data			: std_logic_vector(15 downto 0);
signal		lut_wr_en 			: std_logic;
		
signal		reg_wr_addr			: std_logic_vector(3 downto 0);
signal		reg_wr_data			: std_logic_vector(15 downto 0);
signal		reg_wr_en 			: std_logic;

signal		PM_wr_en			:	std_logic:='0';
signal		PM_wr_data		:	std_logic_vector(47 downto 0):=(others => '0');
-----------------end for Bob

signal send_write_prepare			:  std_logic;
signal send_write_back_en			:  std_logic;
signal send_write_back_data		:  std_logic_VECTOR(63 downto 0);

signal		Alice_H_Bob_L 		: std_logic;
signal		POC_fifo_rdy 		: std_logic;
signal		serial_fifo_rdy 		: std_logic;
signal		random_fifo_empty 	: std_logic;
signal		random_fifo_vld 		: std_logic;
signal		random_fifo_rd_data 	: std_logic_vector(DATA_WIDTH*BURST_LEN-1 downto 0);          
signal		serial_fifo_wr_en 	:  std_logic;
signal		serial_fifo_wr_data 	:  std_logic_vector(DATA_WIDTH*BURST_LEN-1 downto 0);
signal		random_fifo_rd_en 	:  std_logic;
signal		temp_out_p 	:  std_logic;
signal		temp_out_n 	:  std_logic;

-- COMP_TAG_END ------ End COMPONENT Declaration ------------
--	signal	exp_running 		: std_logic;
--	signal	exp_stopping 		: std_logic;
	signal 	lut_ram_128_vld  : std_logic;
	signal	DPS_send_AM_dly_cnt 	: std_logic_vector(7 downto 0);
	signal	DPS_send_PM_dly_cnt 	: std_logic_vector(7 downto 0);
	signal	DPS_syn_dly_cnt 	: std_logic_vector(11 downto 0);
	signal	DPS_chopper_cnt 	: std_logic_vector(3 downto 0);
	signal	DPS_round_cnt 		: std_logic_vector(15 downto 0);
	signal	delay_AM1 			: std_logic_vector(31 downto 0);
--	signal	delay_AM2 			: std_logic_vector(4 downto 0);
--	signal	delay_PM 			: std_logic_vector(4 downto 0);
	signal   GPS_period_cnt		: std_logic_vector(31 downto 0);--bit 31: 1 use intenal gps; 0 use external gps
	signal	delay_AM1_out		: std_logic_vector(29 downto 0);
	signal	set_send_disable_cnt			: std_logic_vector(31 downto 0);--for Alice
	signal	set_send_enable_cnt			: std_logic_vector(31 downto 0);--for Alice
	signal   set_chopper_enable_cnt		: std_logic_vector(31 downto 0);--for Bob
	signal   set_chopper_disable_cnt		: std_logic_vector(31 downto 0);--for Bob
--	signal	delay_AM2_out		: std_logic_vector(4 downto 0);
--	signal	delay_PM_out		: std_logic_vector(4 downto 0);

begin

syn_light_sel	<= Alice_H_Bob_L;
-- <-----Cut code below this line and paste into the architecture body---->
--	sys_clk					<= CLK_OUT4;--200MHz
----	ui_clk					<= CLK_OUT4;--200MHz
--	random_fifo_rd_clk	<= ui_clk;--100MHz
--	random_control_clk	<= CLK_OUT1;--80MHz
--	serial_out_clk			<= CLK_OUT5;--500MHz
--	serial_fifo_rd_clk	<= CLK_OUT2;--83.33MHz
--	serial_fifo_wr_clk	<= ui_clk;--100MHz
--	serial_fifo_clr		<= ui_clk_sync_rst;
--	dps_cpldif_fifo_clr	<= '0';
Inst_clock_manage: clock_manage PORT MAP(
		sys_clk => sys_clk_10M,
		ext_clk_I => ext_clk_I,
		ext_clk_IB => ext_clk_IB,
		sys_rst_in => sys_rst_n,
--		sys_rst_n1 => sys_rst_n1,
--		sys_rst_n3 => sys_rst_n3,
--		sys_rst_h => open,
		CLK_OUT1 => sys_clk_200M,
		CLK_OUT2 => sys_clk_250M,--sys_clk_100M,
		CLK_OUT3 => sys_clk_500M,
		CLK_OUT4 => open,
		CLK_OUT5 => open
	);
	PPG_clock	<= send_en;
	
Inst_Rnd_Gen_TOP: Rnd_Gen_TOP 
generic map (
		BURST_LEN	=>	BURST_LEN,
		DATA_WIDTH	=>	DATA_WIDTH,
		RND_CHIP_NUM	=>	RND_CHIP_NUM
	)
PORT MAP(
		Sys_clk => sys_clk,
		sys_rst_n => sys_rst_n,
		fifo_clr => dps_cpldif_fifo_clr,
		test_rnd => test_rnd,
		test_rnd_data => test_rnd_data,
		random_fifo_rd_clk => sys_clk,
		Rnd_Gen_WNG_Data => Rnd_Gen_WNG_Data,
		Rnd_Gen_WNG_Clk => Rnd_Gen_WNG_Clk,
		Rnd_Gen_WNG_Oe_n => Rnd_Gen_WNG_Oe_n,
		random_fifo_empty => random_fifo_empty,
		random_fifo_vld => random_fifo_vld,
		random_fifo_rd_en => random_fifo_rd_en,
		random_fifo_rd_data => random_fifo_rd_data
	);

	Inst_SRAM_RD_WR: SRAM_RD_WR 
	generic map (
		BURST_LEN	=>	BURST_LEN,
		DATA_WIDTH	=>	DATA_WIDTH
	)
	PORT MAP(
		sys_clk => sys_clk,--200M
		sys_rst_n => sys_rst_n,
		exp_running => exp_running,
		fifo_clr => dps_cpldif_fifo_clr,
		Alice_H_Bob_L => Alice_H_Bob_L,
		cpldif_dps_fifo_prog_full => cpldif_dps_fifo_prog_full,
		POC_fifo_rdy => POC_fifo_rdy,
		send_write_prepare => send_write_prepare,
		send_write_back_en => send_write_back_en,
		send_write_back_data => send_write_back_data,
		rnd_data_store_en => rnd_data_store_en,
		serial_fifo_rdy => serial_fifo_rdy,
		serial_fifo_wr_en => serial_fifo_wr_en,
		serial_fifo_wr_data => serial_fifo_wr_data,
		dps_cpldif_fifo_wr_en		=> dps_cpldif_fifo_wr_en,
		dps_cpldif_fifo_wr_data		=> dps_cpldif_fifo_wr_data,
		PM_wr_en			=> PM_wr_en,
		PM_wr_data		=> PM_wr_data,
		
		random_fifo_empty => random_fifo_empty,
		random_fifo_vld => random_fifo_vld,
		random_fifo_rd_en => random_fifo_rd_en,
		random_fifo_rd_data => random_fifo_rd_data
	);
	
	
	Inst_serial_control: serial_control 
	generic map (
		BURST_LEN	=>	BURST_LEN,
		DATA_WIDTH	=>	DATA_WIDTH
	)
	PORT MAP(
		sys_rst_n => sys_rst_n,
--		sys_clk_100M => sys_clk_100M,
		sys_clk_200M => sys_clk_200M,
		fifo_clr => dps_cpldif_fifo_clr,
		exp_running => exp_running_250M,--200M
		serial_fifo_wr_clk => sys_clk,--200M
		serial_fifo_rd_clk => sys_clk_250m,--167M 500M/3
		serial_out_clk => sys_clk_500M,--500M
		serial_fifo_wr_en => serial_fifo_wr_en,
		Alice_H_Bob_L => Alice_H_Bob_L,
		serial_fifo_wr_data => serial_fifo_wr_data,
		send_write_prepare => send_write_prepare,
		send_write_back_en => send_write_back_en,
		send_write_back_data => send_write_back_data,
		rnd_data_store_en => rdb_rnd_store_en,
		send_en => send_en,
		send_en_AM => send_en_AM,
		delay_load => delay_load,
		serial_fifo_rdy => serial_fifo_rdy,
		test_signal_delay => test_signal_delay,
		delay_AM1 => delay_AM1,
--		delay_AM2 => delay_AM2,
--		delay_PM => delay_PM,
		delay_AM1_out => delay_AM1_out,
--		delay_AM2_out => delay_AM2_out,
--		delay_PM_out => delay_PM_out,
		send_enable => send_enable,
		send_en_AM_p => send_en_AM_p,
		send_en_AM_n => send_en_AM_n,
		SERIAL_OUT_p => SERIAL_OUT_p_reg,
		SERIAL_OUT_n => SERIAL_OUT_n_reg
	);
	
	Inst_dps_reg_resolve: dps_reg_resolve 
	generic map (
		DPS_Base_Addr	=>	DPS_Base_Addr,
		DPS_High_Addr	=>	DPS_High_Addr
	)
	PORT MAP(
		sys_clk_80M => sys_clk,
		sys_rst_n => sys_rst_n,
		Alice_H_Bob_L => Alice_H_Bob_L,
		test_rnd => test_rnd,
		test_rnd_data => test_rnd_data,
		delay_load => delay_load,
		DPS_chopper_cnt => DPS_chopper_cnt,
		DPS_syn_dly_cnt => DPS_syn_dly_cnt,
		DPS_send_PM_dly_cnt => DPS_send_PM_dly_cnt,
		DPS_send_AM_dly_cnt => DPS_send_AM_dly_cnt,
		DPS_round_cnt => DPS_round_cnt,
		pm_steady_test => pm_steady_test,
		delay_AM1 => delay_AM1,
		GPS_period_cnt => GPS_period_cnt,
		scan_data_store_en => scan_data_store_en,
		rdb_rnd_store_en => rdb_rnd_store_en,
		rnd_data_store_en => rnd_data_store_en,
		pm_data_store_en => pm_data_store_en,
		tdc_data_store_en => tdc_data_store_en,
		test_signal_delay => test_signal_delay,
--		delay_PM => delay_PM,
		delay_AM1_out => delay_AM1_out,
--		delay_AM2_out => delay_AM2_out,
--		delay_PM_out => delay_PM_out,
		poc_test_en => poc_test_en,
		dac_test_en => dac_test_en,
		lut_wr_en => lut_wr_en,
		lut_wr_addr => lut_wr_addr,
		lut_wr_data => lut_wr_data,
		reg_wr_en => reg_wr_en,
		reg_wr_addr => reg_wr_addr,
		reg_wr_data => reg_wr_data,
		set_send_disable_cnt		=> set_send_disable_cnt,
		set_send_enable_cnt		=> set_send_enable_cnt,
		set_chopper_enable_cnt	=> set_chopper_enable_cnt,
		set_chopper_disable_cnt	=> set_chopper_disable_cnt,
		cpldif_dps_addr => cpldif_dps_addr,
		cpldif_dps_wr_en => cpldif_dps_wr_en,
		cpldif_dps_rd_en => cpldif_dps_rd_en,
		cpldif_dps_wr_data => cpldif_dps_wr_data,
		dps_cpldif_rd_data => dps_cpldif_rd_data
	);
	
	PPG_start	<= chopper_ctrl_sig;
	Inst_DPS_control: DPS_control PORT MAP(
		sys_clk_80M => sys_clk,
		sys_clk_250M => sys_clk_250m,
		sys_rst_n => sys_rst_n,
		exp_running => exp_running,
		exp_running_250M => exp_running_250M,
		Alice_H_Bob_L => Alice_H_Bob_L,
		gps_pulse => gps_pps,
		GPS_period_cnt => GPS_period_cnt,
		GPS_pulse_int => GPS_pulse_int,
		APD_tdc_en => APD_tdc_en,
		GPS_pulse_int_active => GPS_pulse_int_active,
		DPS_syn_dly_cnt => DPS_syn_dly_cnt,
		DPS_send_PM_dly_cnt => DPS_send_PM_dly_cnt,
		DPS_send_AM_dly_cnt => DPS_send_AM_dly_cnt,
		DPS_round_cnt => DPS_round_cnt,
		DPS_chopper_cnt => DPS_chopper_cnt,
		set_send_disable_cnt		=> set_send_disable_cnt,
		set_send_enable_cnt		=> set_send_enable_cnt,
		set_chopper_enable_cnt	=> set_chopper_enable_cnt,
		set_chopper_disable_cnt	=> set_chopper_disable_cnt,
		PPG_start => send_enable,
		syn_light_ext => syn_light_ext,
		syn_light => syn_light,
		chopper_ctrl => chopper_ctrl,
		chopper_ctrl_80M => chopper_ctrl_sig,
--		send_en_AM_p => send_en_AM_p,
--		send_en_AM_n => send_en_AM_n,
		send_en_AM => send_en_AM,
		send_en => send_en
	);
--	chopper_ctrl_80M	<= chopper_ctrl_sig;
	Inst_POC_output_control: POC_output_control PORT MAP(
		sys_clk => sys_clk,
		sys_rst_n => sys_rst_n,
		fifo_clr => dps_cpldif_fifo_clr,
		exp_running => exp_running,
		Alice_H_Bob_L => Alice_H_Bob_L,
		syn_light => syn_light_ext,
		POC_fifo_wr_en => serial_fifo_wr_en,
		POC_fifo_wr_data => serial_fifo_wr_data,
		POC_fifo_rdy => POC_fifo_rdy,
		poc_test_en => poc_test_en,
		poc_test_data => lut_wr_data(6 downto 0),
		dac_test_en => dac_test_en,
		dac_test_data => lut_wr_data(15 downto 0),
		pm_dac_en => pm_dac_en,
		pm_dac_data => pm_dac_data,
		lut_ram_128_vld => lut_ram_128_vld,
		lut_ram_128_addr => lut_ram_128_addr,
		lut_ram_128_data => lut_ram_128_data,
--		chopper_contrl => chopper_ctrl_sig,
		Dac_Ena		=> dac_ena,
		Dac_Data 	=> dac_data,
		POC_control_en => POC_control_en,
		POC_control => POC_control,
		POC_start => POC_start,
		POC_stop => POC_stop
	);
--	POC_control_en	<= lut_wr_en;
--	POC_control		<= lut_wr_data(6 downto 0);
	Inst_DAC_INTERFACE: DAC_INTERFACE PORT MAP(
		CLK 			=> sys_clk,
		Dac_Ena		=> dac_ena,
		Dac_Data 	=> dac_data,
		Sys_Rst_n	=> sys_rst_n,
		Dac_Finish 	=> Dac_Finish,
		Dac_Sclk 	=> Dac_Sclk,
		Dac_Csn 		=> Dac_Csn,
		Dac_Din 		=> Dac_Din
	);
	
	Inst_PM_receive: PM_receive PORT MAP(
		sys_clk_80M => sys_clk,
		sys_rst_n => sys_rst_n,
		fifo_rst => fifo_clr,
		dac_finish => dac_finish,
		Dac_Ena => pm_dac_en,
		dac_data => pm_dac_data,
		POC_ctrl => POC_control,
		POC_ctrl_en => POC_control_en,
		pm_steady_test => pm_steady_test,
		scan_data_store_en => scan_data_store_en,
		pm_data_store_en => pm_data_store_en,
		reg_wr => reg_wr_en,
		reg_wr_addr => reg_wr_addr,
		reg_wr_data => reg_wr_data,
		apd_fpga_hit => apd_fpga_hit,
		lut_ram_rd_addr => lut_rd_addr,
		lut_ram_rd_data => lut_rd_data,
		lut_ram_128_vld => lut_ram_128_vld,
		lut_ram_128_addr => lut_ram_128_addr,
		lut_ram_128_data => lut_ram_128_data,
		alg_data_wr => PM_wr_en,
		alg_data_wr_data => PM_wr_data,
		chopper_ctrl => chopper_ctrl_sig
	);
	
	-- The following code must appear in the VHDL architecture
	-- body. Substitute your own instance name and net names.

	------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
	inst_lut_ram : lut_ram
	  PORT MAP (
		 clka 	=> sys_clk,
		 wea(0) 		=> lut_wr_en,
		 addra 	=> lut_wr_addr,
		 dina 	=> lut_wr_data,
		 clkb 	=> sys_clk,
		 addrb 	=> lut_rd_addr,
		 doutb 	=> lut_rd_data
	  );
	  
	
	SERIAL_OUT_p(0)	<= SERIAL_OUT_p_reg(0);
	SERIAL_OUT_n(0)	<= SERIAL_OUT_n_reg(0);
	
	SERIAL_OUT_p(1)	<= send_enable;
	SERIAL_OUT_n(1)	<= send_en_AM;
	
	SERIAL_OUT_p(2)	<= SERIAL_OUT_p_reg(2);
	SERIAL_OUT_n(2)	<= SERIAL_OUT_n_reg(2);
end Behavioral;

