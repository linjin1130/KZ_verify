----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:37:00 08/12/2013 
-- Design Name: 
-- Module Name:    ground_pro_top - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;


entity ground_pro_top is
	generic(
		qtel_base_addr :	std_logic_vector(7 downto 0) := X"30";
		qtel_high_addr	 :	std_logic_vector(7 downto 0) := X"32";
		DAC_Base_Addr : std_logic_vector(7 downto 0) := X"40";
		DAC_High_Addr : std_logic_vector(7 downto 0) := X"43";
		CNT_Base_Addr : std_logic_vector(7 downto 0) := X"50";
		CNT_High_Addr : std_logic_vector(7 downto 0) := X"79";		
		CPLD_Base_Addr : std_logic_vector(7 downto 0):=X"80";
		CRG_Base_Addr : std_logic_vector(7 downto 0):=X"90";
		TDC_Base_Addr : std_logic_vector(7 downto 0) := X"10";
		TDC_High_Addr : std_logic_vector(7 downto 0) := X"14";
		TIME_Base_Addr : std_logic_vector(7 downto 0) := X"20";
		TIME_High_Addr : std_logic_vector(7 downto 0) := X"23"

		);
	port(
		clk_40M_I	:	in	std_logic;
		clk_40M_IB	:	in	std_logic;
--		sys_clk_80M	:	in	std_logic;--system clock,80MHz
		reset_in_n	:	in	std_logic;--system reset,high active;
		----cpld interface------
		cpld_fpga_clk	:	in	std_logic;--33MHz clock from cpld
		cpld_fpga_data	:	inout	std_logic_vector(31 downto 0);
		cpld_fpga_addr	:	in	std_logic_vector(7 downto 0);
		cpld_fpga_sglrd	:	in	std_logic;--single read enable,high active
		cpld_fpga_sglwr	:	in	std_logic;--single write enable,high active
		cpld_fpga_brtrd_req	:	in	std_logic;--burst read request,high active
		fpga_cpld_burst_act	:	out	std_logic;
		fpga_cpld_burst_en	:	out	std_logic;--burst enable,indicate fifo has stored a burst length	
		fpga_cpld_rst_n		:	out	std_logic;
		--*************************
		----dac interface---
		fpga_dac_data	:	inout	std_logic_vector(7 downto 0);
		fpga_dac_addr	:	out	std_logic_vector(3 downto 0);
		fpga_dac_rs_n	:	out	std_logic;--dac reset,low active
		fpga_dac_cs_n	:	out	std_logic;--chip select,low active
		fpga_dac_rw_n	:	out	std_logic;--dac write or read control,low active
		fpga_dac_ld_n	:	out	std_logic;--dac load control,low active
		fpga_dac_en_n	:	out	std_logic;--clock enable,rising edge active
		---apd interface--
		apd_fpga_hit_p	:	in	std_logic_vector(15 downto 0);
		apd_fpga_hit_n	:	in	std_logic_vector(15 downto 0);		
		----------------
		----SDRAM interface------------
		tdc_sdram_dq :	inout	std_logic_vector(15 downto 0);
		tdc_sdram_dqml :	out	std_logic;
		tdc_sdram_dqmh :	out	std_logic;
		tdc_sdram_we_n :	out	std_logic;
		tdc_sdram_cas_n :	out	std_logic;
		tdc_sdram_ras_n :	out	std_logic;
		tdc_sdram_cs_n :	out	std_logic;
		tdc_sdram_ba :	out	std_logic_vector(1 downto 0);
		tdc_sdram_a :	out	std_logic_vector(12 downto 0);
		tdc_sdram_cke :	out	std_logic;
		tdc_sdram_clk :	out	std_logic;
		
		----------------
		out_nim	: out std_logic;
		out_ttl	: out std_logic;
		----------------
		
		---analog input port(system voltage and current)------
		vauxp0              : in  std_logic;                         -- auxiliary channel 0:report the system power 2.5v current
		vauxn0              : in  std_logic;
		vauxp1              : in  std_logic;                         -- auxiliary channel 1:report the system power 2.5v voltage
		vauxn1              : in  std_logic; 
		vauxp8              : in  std_logic;                         -- auxiliary channel 8: report the system power 5v current
		vauxn8              : in  std_logic;
		vauxp9              : in  std_logic;                         -- auxiliary channel 9:report the system power 5v voltage
		vauxn9              : in  std_logic;
		vauxp10            : in  std_logic;                         -- auxiliary channel 10:report the system power 12v current
		vauxn10             : in  std_logic;
		vauxp11             : in  std_logic;                         -- auxiliary channel 11:report the system power 12v voltage
		vauxn11             : in  std_logic;
		vauxp12             : in  std_logic;                         -- auxiliary channel 12:report the system power 3.3v current
		vauxn12            : in  std_logic;
		vauxp13            : in  std_logic;                         -- auxiliary channel 13:report the system power 3.3v voltage
		vauxn13            : in  std_logic;
		vauxp14               : in  std_logic;                         -- auxiliary channel 14:report the system power 1v current
		vauxn14              : in  std_logic;
		vauxp15              : in  std_logic;                         -- auxiliary channel 15:report the system power 1v voltage
		vauxn15               : in  std_logic;	
		vp_in		                  : in  std_logic;                         -- dedicated analog input pair
		vn_in		                  : in  std_logic;
		Tp                  :out std_logic_vector(8 downto 0)
		);
end ground_pro_top;

architecture Behavioral of ground_pro_top is

--
--	COMPONENT qtel
--	generic(
--		qtel_base_addr	:	std_logic_vector(7 downto 0) := X"30";
--		qtel_high_addr	:	std_logic_vector(7 downto 0) := X"32"
--		);
--	port(
--	-- fix by herry make sys_clk_80M to sys_clk_160M
--	   sys_clk_160M			:	in	std_logic;--system clock,1600MHz
--		sys_rst_n				:	in	std_logic;--system reset,low active
--		--signal in
----		qtel_clk_80M 			: 	in	std_logic;
----		qtel_input				: 	in	std_logic_vector(7 downto 0);
--		apd_fpga_hit_p	:	in	std_logic_vector(15 downto 0);
--		apd_fpga_hit_n	:	in	std_logic_vector(15 downto 0);
--		--output to module counter
--		qtel_counter_match	:	out	std_logic_vector(7 downto 0);
--		---cpldif module
--		cpldif_qtel_addr		:	in	std_logic_vector(7 downto 0);
--		cpldif_qtel_wr_en		:	in	std_logic;
--		cpldif_qtel_rd_en		:	in	std_logic;
--		cpldif_qtel_wr_data	:	in	std_logic_vector(31 downto 0);
--		qtel_cpldif_rd_data	:	out	std_logic_vector(31 downto 0)
--		);
--	END COMPONENT;
	COMPONENT qtel
	generic(
		qtel_base_addr	:	std_logic_vector(7 downto 0) := X"30";
		qtel_high_addr	:	std_logic_vector(7 downto 0) := X"32"
		);
	PORT(
		sys_clk_160M : IN std_logic;
		sys_rst_n : IN std_logic;
		tdc_qtel_hit	: in  std_logic_vector(8 downto 0);
--		apd_fpga_hit_p : IN std_logic_vector(9 downto 1);
--		apd_fpga_hit_n : IN std_logic_vector(9 downto 1);
		cpldif_qtel_addr : IN std_logic_vector(7 downto 0);
		cpldif_qtel_wr_en : IN std_logic;
		cpldif_qtel_rd_en : IN std_logic;
		cpldif_qtel_wr_data : IN std_logic_vector(31 downto 0);          
		qtel_counter_match : OUT std_logic_vector(7 downto 0);   ---to counter module;
		qtel_cpldif_rd_data : OUT std_logic_vector(31 downto 0)  ---not used;
		);
	END COMPONENT;

	COMPONENT multichnlTDC
	generic(
		tdc_basic_addr	:	std_logic_vector(7 downto 0) := X"10";
		tdc_high_addr	:	std_logic_vector(7 downto 0) := X"14"
	);
	PORT(
		clk_160M : IN std_logic;
		invclk_160M : IN std_logic;
		sys_clk_60M : IN std_logic;
		sys_clk : IN std_logic;
		sys_rst_n : IN std_logic;
		HitIn_p : IN std_logic_vector(16 downto 1);
		HitIn_n : IN std_logic_vector(16 downto 1);
		cpldif_tdc_addr : IN std_logic_vector(7 downto 0);
		cpldif_tdc_wr_en : IN std_logic;
		cpldif_tdc_wr_data : IN std_logic_vector(31 downto 0);
		cpldif_tdc_rd_en : IN std_logic;
		cpldif_tdc_fifo_prog_full : IN std_logic;
		gps_pps	:	out std_logic;
		tdc_count_hit	: out std_logic_vector(15 downto 0);
		testsig : OUT std_logic_vector(15 downto 0);
		tdc_qtel_hit		: 	out std_logic_vector(8 downto 0);
		
		tdc_sdram_dq :	inout	std_logic_vector(15 downto 0);
		tdc_sdram_dqml :	out	std_logic;
		tdc_sdram_dqmh :	out	std_logic;
		tdc_sdram_we_n :	out	std_logic;
		tdc_sdram_cas_n :	out	std_logic;
		tdc_sdram_ras_n :	out	std_logic;
		tdc_sdram_cs_n :	out	std_logic;
		tdc_sdram_ba :	out	std_logic_vector(1 downto 0);
		tdc_sdram_a :	out	std_logic_vector(12 downto 0);
		tdc_sdram_cke :	out	std_logic;
		tdc_sdram_clk :	out	std_logic;
		tdc_cpldif_rd_data : OUT std_logic_vector(31 downto 0);
		tdc_cpldif_fifo_wr_en : OUT std_logic;
		tdc_cpldif_fifo_wr_data : OUT std_logic_vector(31 downto 0);
		tdc_cpldif_fifo_clr : OUT std_logic;
		tp : OUT std_logic_vector(6 downto 0)
		);
	END COMPONENT;
	
	COMPONENT TIME_CTRL
	generic(
		time_basic_addr	:	std_logic_vector(7 downto 0) := X"20";
		time_high_addr	:	std_logic_vector(7 downto 0) := X"23"
	);
	PORT(
		sys_clk : IN std_logic;
		sys_rst_n : IN std_logic;
		cpldif_time_addr : IN std_logic_vector(7 downto 0);
		cpldif_time_wr_en : IN std_logic;
		cpldif_time_rd_en : IN std_logic;
		cpldif_time_wr_data : IN std_logic_vector(31 downto 0);
		gps_pps : IN std_logic;          
		time_cpldif_rd_data : OUT std_logic_vector(31 downto 0);
		tp : OUT std_logic_vector(1 downto 0);
		time_local_cur : OUT std_logic_vector(47 downto 0)
		);
	END COMPONENT;
	
	COMPONENT DAC_Ctrl
	generic(
		DAC_Base_Addr	:	std_logic_vector(7 downto 0);
		DAC_High_Addr	:	std_logic_vector(7 downto 0)
		);
	PORT(
		sys_clk_80M : IN std_logic;
		sys_rst_n : IN std_logic;
		cpldif_dac_addr : IN std_logic_vector(7 downto 0);
		cpldif_dac_wr_en : IN std_logic;
		cpldif_dac_wr_data : IN std_logic_vector(31 downto 0);
		cpldif_dac_rd_en : IN std_logic;    
		fpga_dac_data : INOUT std_logic_vector(7 downto 0);      
		fpga_dac_addr : OUT std_logic_vector(3 downto 0);
		fpga_dac_rs_n : OUT std_logic;
		fpga_dac_cs_n : OUT std_logic;
		fpga_dac_rw_n : OUT std_logic;
		fpga_dac_ld_n : OUT std_logic;
		fpga_dac_en_n : OUT std_logic;
		dac_cpldif_rd_data : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	
	COMPONENT cpld_if
	generic(
		qtel_base_addr :	std_logic_vector(7 downto 0) := X"30";
		qtel_high_addr	 :	std_logic_vector(7 downto 0) := X"32";
		DAC_Base_Addr : std_logic_vector(7 downto 0) := X"40";
		DAC_High_Addr : std_logic_vector(7 downto 0) := X"43";
		CNT_Base_Addr : std_logic_vector(7 downto 0) := X"50";
		CNT_High_Addr : std_logic_vector(7 downto 0) := X"71";
		CPLD_Base_Addr : std_logic_vector(7 downto 0):=X"80";
		CRG_Base_Addr : std_logic_vector(7 downto 0):=X"90";
		TDC_Base_Addr : std_logic_vector(7 downto 0) := X"10";
		TDC_High_Addr : std_logic_vector(7 downto 0) := X"14";
		TIME_Base_Addr : std_logic_vector(7 downto 0) := X"20";
		TIME_High_Addr : std_logic_vector(7 downto 0) := X"23"
	);
	PORT(
		sys_clk_80M : IN std_logic;
		sys_rst_n : IN std_logic;
		cpld_fpga_clk : IN std_logic;
		cpld_fpga_addr : IN std_logic_vector(7 downto 0);
		cpld_fpga_sglrd : IN std_logic;
		cpld_fpga_sglwr : IN std_logic;
		cpld_fpga_brtrd_req : IN std_logic;
		dac_cpldif_rd_data : IN std_logic_vector(31 downto 0);
		count_cpldif_rd_data : IN std_logic_vector(31 downto 0);
		crg_cpldif_rd_data : IN std_logic_vector(31 downto 0);
		sysmon_cpldif_rd_data : IN std_logic_vector(31 downto 0);
		tdc_cpldif_rd_data : IN std_logic_vector(31 downto 0);
		time_cpldif_rd_data : IN std_logic_vector(31 downto 0);
		qtel_cpldif_rd_data :  std_logic_vector(31 downto 0);
		tdc_cpldif_fifo_wr_en : IN std_logic;
		tdc_cpldif_fifo_clr : IN std_logic;
		tdc_cpldif_fifo_wr_data : IN std_logic_vector(31 downto 0);    
		cpld_fpga_data : INOUT std_logic_vector(31 downto 0);      
		fpga_cpld_burst_act : OUT std_logic;
		fpga_cpld_burst_en : OUT std_logic;
		cpldif_addr : OUT std_logic_vector(7 downto 0);
		cpldif_rd_en : OUT std_logic;
		cpldif_wr_en : OUT std_logic;
		cpldif_wr_data : OUT std_logic_vector(31 downto 0);
		cpldif_tdc_fifo_almost_full : OUT std_logic;
		cpldif_tdc_fifo_prog_full : OUT std_logic;
		cpldif_tdc_fifo_full : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT count_measure
	generic(
		CNT_Base_Addr	:	std_logic_vector(7 downto 0);
		CNT_High_Addr	:	std_logic_vector(7 downto 0)
		);
	PORT(
		sys_clk_160M : IN std_logic;
		sys_rst_n : IN std_logic;
		qtel_counter_match : IN std_logic_vector(7 downto 0);
		apd_fpga_hit : IN std_logic_vector(15 downto 0);
		tdc_count_time_value : IN std_logic_vector(31 downto 0);
		cpldif_count_addr : IN std_logic_vector(7 downto 0);
		cpldif_count_wr_en : IN std_logic;
		cpldif_count_rd_en : IN std_logic;
		cpldif_count_wr_data : IN std_logic_vector(31 downto 0);          
		count_cpldif_rd_data : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	
	COMPONENT CRG
	generic(
		CRG_Base_Addr : std_logic_vector(7 downto 0)
	);
	PORT(
--		clk_in : IN std_logic;
		clk_40M_I : IN std_logic;
		clk_40M_IB : IN std_logic;
		reset_in_n : IN std_logic;
		cpldif_crg_addr : IN std_logic_vector(7 downto 0);
		cpldif_crg_wr_en : IN std_logic;
		cpldif_crg_wr_data : IN std_logic_vector(31 downto 0);
		cpldif_crg_rd_en : IN std_logic;          
		sys_clk_80M : OUT std_logic;
		sys_clk_60M : OUT std_logic;
		sys_clk_10M : OUT std_logic;
		sys_clk_160M : OUT std_logic;
		sys_clk_160M_inv : OUT std_logic;
		sys_rst_n : OUT std_logic;
		crg_cpldif_rd_data : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	
	COMPONENT sysmonitor

	PORT(
		rstn		             :	in std_logic;
		clk	                :	in std_logic;
		cpldif_sysmon_addr    : in std_logic_vector(7 downto 0);
		sysmon_cpldif_rd_data	  : out std_logic_vector(31 downto 0);
		vauxp0                : in  std_logic;                         
		vauxn0               : in  std_logic;
		vauxp1               : in  std_logic;                         
		vauxn1               : in  std_logic; 
		vauxp8                 : in  std_logic;                         
		vauxn8                : in  std_logic;
		vauxp9                 : in  std_logic;                        
		vauxn9                 : in  std_logic;
		vauxp10               : in  std_logic;                         
		vauxn10              : in  std_logic;
		vauxp11               : in  std_logic;                         
		vauxn11               : in  std_logic;
		vauxp12             : in  std_logic;                         
		vauxn12              : in  std_logic;
		vauxp13              : in  std_logic;                          
		vauxn13              : in  std_logic;
		vauxp14                : in  std_logic;                         
		vauxn14               : in  std_logic;
		vauxp15                : in  std_logic;                         
		vauxn15                : in  std_logic;
		vp_in		                 : in  std_logic;                         
		vn_in		                 : in  std_logic		
		);
	END COMPONENT;
	
-- signal from qtel module	
	signal qtel_counter_match :  std_logic_vector(7 downto 0);
	signal qtel_cpldif_rd_data :  std_logic_vector(31 downto 0);--- signal from qtel module to cpld
	signal apd_fpga_hit_qtel_p : std_logic_vector(8 downto 0);
	signal apd_fpga_hit_qtel_n : std_logic_vector(8 downto 0);
	signal dac_cpldif_rd_data : std_logic_vector(31 downto 0);
--	signal tdc_cpldif_rd_data : std_logic_vector(31 downto 0);
	signal crg_cpldif_rd_data : std_logic_vector(31 downto 0);
	signal sysmon_cpldif_rd_data : std_logic_vector(31 downto 0);
	----------
	signal cpldif_rd_data	:	std_logic_vector(31 downto 0);
	signal cpldif_addr	:	std_logic_vector(7 downto 0);
	signal cpldif_rd_en	:	std_logic;
	signal cpldif_wr_en	:	std_logic;
	signal cpldif_wr_data	:	std_logic_vector(31 downto 0);
	-----tdc module and time module
	signal tdc_cpldif_fifo_wr_en	:	std_logic;
	signal tdc_cpldif_fifo_wr_data	:	std_logic_vector(31 downto 0);
	signal cpldif_tdc_fifo_full	:	std_logic;
	signal cpldif_tdc_fifo_almost_full	:	std_logic;
	signal cpldif_tdc_fifo_prog_full	:	std_logic;
	signal tdc_cpldif_fifo_clr	:	std_logic;
	--------------
	signal tdc_cpldif_rd_data : std_logic_vector(31 downto 0);
	signal time_cpldif_rd_data : std_logic_vector(31 downto 0);
	signal time_local_cur : std_logic_vector(47 downto 0);
	signal gps_pps	:	std_logic;
	signal tdc_count_hit : std_logic_vector(15 downto 0);	
	signal tdc_qtel_hit		: std_logic_vector(8 downto 0);
	-------------------------------------------------------	

--	signal clk_40M_p : std_logic;
--	signal clk_40M_n : std_logic;
	signal sys_clk_80M : std_logic;
	signal sys_clk_60M : std_logic;
	signal sys_clk_10M : std_logic;
	signal sys_clk_160M : std_logic;
	signal sys_clk_160M_inv : std_logic;
	signal sys_rst_n : std_logic;
	signal fpga_cpld_rst_d : std_logic;
	signal cpldif_burst_len : std_logic_vector(10 downto 0);
	--count interface
--	signal tdc_count_time_value : std_logic_vector(31 downto 0);
	signal count_cpldif_rd_data : std_logic_vector(31 downto 0);
	signal cnt : std_logic_vector(3 downto 0) := X"0";
	signal apd_fpga_hit : std_logic_vector(15 downto 0);		
	signal burst_en : std_logic;
	signal burst_act : std_logic;
	
		
begin

--	apd_fpga_hit_qtel_p <= apd_fpga_hit_p(9 downto 1);
--	apd_fpga_hit_qtel_n <= apd_fpga_hit_n(9 downto 1);
	---Test point----
	fpga_cpld_burst_en<=burst_en;
	fpga_cpld_burst_act<= burst_act;
	out_ttl<= sys_clk_10M;
	out_nim<= sys_clk_10M;
--	Tp(0)<= cpld_fpga_clk;--TP15
--	Tp(1)<= burst_en;--TP14
--	Tp(2)<= cpld_fpga_brtrd_req;--TP13
--	Tp(3)<= burst_act;--TP16
--	Tp(4)<= cpld_fpga_sglwr;--TP12
--	Tp(5)<= cpld_fpga_sglrd;--TP22
	--Test point----
	
--	tdc_cpldif_fifo_clr	<=	'0';
	fpga_cpld_rst_n	<=	sys_rst_n;
		
	
---********** instantiation **************
--		Inst_qtel: qtel
--		generic map(
--		qtel_base_addr	=> qtel_base_addr,
--		qtel_high_addr	=> qtel_high_addr
--		)
--		port map(
--	-- fix by herry make sys_clk_80M to sys_clk_160M
--	   sys_clk_160M	=>	sys_clk_160M,	
--		sys_rst_n		=>	sys_rst_n,
--		apd_fpga_hit_p	=> apd_fpga_hit_p,
--		apd_fpga_hit_n	=> apd_fpga_hit_n,
--		qtel_counter_match => qtel_counter_match,	
--		cpldif_qtel_addr	 => cpldif_qtel_addr,
--		cpldif_qtel_wr_en		=> cpldif_qtel_wr_en,
--		cpldif_qtel_rd_en		=> cpldif_qtel_rd_en,
--		cpldif_qtel_wr_data	=> cpldif_qtel_wr_data,
--		qtel_cpldif_rd_data	=> qtel_cpldif_rd_data
--		);
		
		Inst_qtel: qtel 
		generic map(
		qtel_base_addr	=> qtel_base_addr,
		qtel_high_addr	=> qtel_high_addr
		)
		PORT MAP(
		sys_clk_160M => sys_clk_160M,
		sys_rst_n => sys_rst_n,
		tdc_qtel_hit => tdc_qtel_hit,
--		apd_fpga_hit_p => apd_fpga_hit_qtel_p,
--		apd_fpga_hit_n => apd_fpga_hit_qtel_n,
		qtel_counter_match => qtel_counter_match,	--
		cpldif_qtel_addr => cpldif_addr,				
		cpldif_qtel_wr_en => cpldif_wr_en,			
		cpldif_qtel_rd_en => cpldif_rd_en,			
		cpldif_qtel_wr_data => cpldif_wr_data,		
		qtel_cpldif_rd_data => qtel_cpldif_rd_data	--
		);
--		
		Inst_multichnlTDC: multichnlTDC 
		generic map(
		tdc_basic_addr	=> TDC_Base_Addr,
		tdc_high_addr	=> TDC_High_Addr
		)
		PORT MAP(
		clk_160M => sys_clk_160M,
		invclk_160M => sys_clk_160M_inv,
		sys_clk => sys_clk_80M,
		sys_clk_60M  => sys_clk_60M,
		sys_rst_n => sys_rst_n,
		HitIn_p => apd_fpga_hit_p,
		HitIn_n => apd_fpga_hit_n,
		gps_pps => gps_pps,
		tdc_count_hit => tdc_count_hit,
		tdc_qtel_hit => tdc_qtel_hit,
		testsig => open,
		tdc_sdram_dq => tdc_sdram_dq,
		tdc_sdram_dqml => tdc_sdram_dqml,
		tdc_sdram_dqmh => tdc_sdram_dqmh,
		tdc_sdram_we_n => tdc_sdram_we_n,
		tdc_sdram_cas_n => tdc_sdram_cas_n,
		tdc_sdram_ras_n => tdc_sdram_ras_n,
		tdc_sdram_cs_n => tdc_sdram_cs_n,
		tdc_sdram_ba => tdc_sdram_ba,
		tdc_sdram_a => tdc_sdram_a,
		tdc_sdram_cke => tdc_sdram_cke,
		tdc_sdram_clk =>tdc_sdram_clk,
		cpldif_tdc_addr => cpldif_addr,
		cpldif_tdc_wr_en => cpldif_wr_en,
		cpldif_tdc_wr_data => cpldif_wr_data,
		cpldif_tdc_rd_en => cpldif_rd_en,
		tdc_cpldif_rd_data => tdc_cpldif_rd_data,
		tdc_cpldif_fifo_wr_en => tdc_cpldif_fifo_wr_en,
		tdc_cpldif_fifo_wr_data => tdc_cpldif_fifo_wr_data,
		cpldif_tdc_fifo_prog_full => cpldif_tdc_fifo_prog_full,
		tdc_cpldif_fifo_clr => tdc_cpldif_fifo_clr,
		tp => Tp(6 downto 0)
	);
	
		Inst_TIME: TIME_CTRL 
		generic map(
		time_basic_addr	=> TIME_Base_Addr,
		time_high_addr	=> TIME_High_Addr
		)
		PORT MAP(
		sys_clk => sys_clk_80M,
		sys_rst_n => sys_rst_n,
		cpldif_time_addr => cpldif_addr,
		cpldif_time_wr_en => cpldif_wr_en,
		cpldif_time_rd_en => cpldif_rd_en,
		cpldif_time_wr_data => cpldif_wr_data,
		time_cpldif_rd_data => time_cpldif_rd_data,
		gps_pps => gps_pps,
		tp => Tp(8 downto 7),
		time_local_cur => time_local_cur
	);
	
	
	Inst_DAC_Ctrl: DAC_Ctrl 
	generic map(
		DAC_Base_Addr	=> DAC_Base_Addr,
		DAC_High_Addr	=> DAC_High_Addr)
	PORT MAP(
		sys_clk_80M => sys_clk_80M,
		sys_rst_n => sys_rst_n,
		fpga_dac_data => fpga_dac_data,
		fpga_dac_addr => fpga_dac_addr,
		fpga_dac_rs_n => fpga_dac_rs_n,
		fpga_dac_cs_n => fpga_dac_cs_n,
		fpga_dac_rw_n => fpga_dac_rw_n,
		fpga_dac_ld_n => fpga_dac_ld_n,
		fpga_dac_en_n => fpga_dac_en_n,
		cpldif_dac_addr => cpldif_addr,
		cpldif_dac_wr_en => cpldif_wr_en,
		cpldif_dac_wr_data => cpldif_wr_data,
		cpldif_dac_rd_en => cpldif_rd_en,
		dac_cpldif_rd_data => dac_cpldif_rd_data
	);
	
	Inst_cpld_if: cpld_if 
	generic map(
		qtel_base_addr => qtel_Base_Addr,
		qtel_high_addr	=> qtel_Base_Addr, 
		DAC_Base_Addr => DAC_Base_Addr,
		DAC_High_Addr => DAC_High_Addr,
		CNT_Base_Addr => CNT_Base_Addr,
		CNT_High_Addr => CNT_High_Addr,
		CPLD_Base_Addr => CPLD_Base_Addr,
		CRG_Base_Addr => CRG_Base_Addr,
		TDC_Base_Addr => TDC_Base_Addr,
		TDC_High_Addr => TDC_High_Addr,
		TIME_Base_Addr => TIME_Base_Addr,
		TIME_High_Addr => TIME_High_Addr
	)
	PORT MAP(
		sys_clk_80M => sys_clk_80M,
		sys_rst_n => sys_rst_n,
		cpld_fpga_clk => cpld_fpga_clk,
		cpld_fpga_data => cpld_fpga_data,
		cpld_fpga_addr => cpld_fpga_addr,
		cpld_fpga_sglrd => cpld_fpga_sglrd,
		cpld_fpga_sglwr => cpld_fpga_sglwr,
		cpld_fpga_brtrd_req => cpld_fpga_brtrd_req,
		fpga_cpld_burst_act => burst_act,
		fpga_cpld_burst_en => burst_en,
		dac_cpldif_rd_data => dac_cpldif_rd_data,
		count_cpldif_rd_data => count_cpldif_rd_data,
		crg_cpldif_rd_data => crg_cpldif_rd_data,
		sysmon_cpldif_rd_data => sysmon_cpldif_rd_data,
		tdc_cpldif_rd_data => tdc_cpldif_rd_data,
		time_cpldif_rd_data => time_cpldif_rd_data,
		qtel_cpldif_rd_data => qtel_cpldif_rd_data,
		cpldif_addr => cpldif_addr,
		cpldif_rd_en => cpldif_rd_en,
		cpldif_wr_en => cpldif_wr_en,
		cpldif_wr_data => cpldif_wr_data,
		tdc_cpldif_fifo_wr_en => tdc_cpldif_fifo_wr_en,
		tdc_cpldif_fifo_clr => tdc_cpldif_fifo_clr,
		tdc_cpldif_fifo_wr_data => tdc_cpldif_fifo_wr_data,
		cpldif_tdc_fifo_almost_full => cpldif_tdc_fifo_almost_full,
		cpldif_tdc_fifo_prog_full => cpldif_tdc_fifo_prog_full,
		cpldif_tdc_fifo_full => cpldif_tdc_fifo_full
	);
	-- ?mux for match-----------------------------------------
	
	
	---------------------------------------------------------
	Inst_count_measure: count_measure 
	generic map(
		CNT_Base_Addr	=> CNT_Base_Addr,
		CNT_High_Addr	=> CNT_High_Addr
	)
	PORT MAP(
		sys_clk_160M => sys_clk_160M,
		sys_rst_n => sys_rst_n,
		qtel_counter_match => qtel_counter_match,
		apd_fpga_hit => tdc_count_hit,
		tdc_count_time_value => time_local_cur(31 downto 0),
		cpldif_count_addr => cpldif_addr,
		cpldif_count_wr_en => cpldif_wr_en,
		cpldif_count_rd_en => cpldif_rd_en,
		cpldif_count_wr_data => cpldif_wr_data,
		count_cpldif_rd_data => count_cpldif_rd_data
	);
	
	Inst_CRG: CRG 
	generic map(
		CRG_Base_Addr => CRG_Base_Addr
	)
	PORT MAP(
--		clk_in => clk_40M_p,
		clk_40M_I => clk_40M_I,
		clk_40M_IB => clk_40M_IB,
		reset_in_n => reset_in_n,
		sys_clk_80M => sys_clk_80M,
		sys_clk_60M => sys_clk_60M,
		sys_clk_10M => sys_clk_10M,
		sys_clk_160M => sys_clk_160M,
		sys_clk_160M_inv => sys_clk_160M_inv,
		sys_rst_n => sys_rst_n,
		cpldif_crg_addr => cpldif_addr,
		cpldif_crg_wr_en => cpldif_wr_en,
		cpldif_crg_wr_data => cpldif_wr_data,
		cpldif_crg_rd_en => cpldif_rd_en,
		crg_cpldif_rd_data => crg_cpldif_rd_data
	);
	
   Inst_sysmonitor: sysmonitor
	PORT MAP(
		rstn		             => sys_rst_n,     
		clk	                => sys_clk_80M,
		cpldif_sysmon_addr	 => cpldif_addr,    
		sysmon_cpldif_rd_data	 => sysmon_cpldif_rd_data,    
		vauxp0          => vauxp0,                         
      vauxn0          => vauxn0,   
      vauxp1          => vauxp1,                          
      vauxn1          => vauxn1,  
      vauxp8            => vauxp8,                           
      vauxn8            => vauxn8,
      vauxp9            => vauxp9,                         
      vauxn9            => vauxn9,    
      vauxp10          => vauxp10,                          
      vauxn10          => vauxn10,    
      vauxp11          => vauxp11,                         
      vauxn11          => vauxn11,     
      vauxp12         => vauxp12,                          
      vauxn12         => vauxn12,  
      vauxp13         => vauxp13,                          
      vauxn13         => vauxn13,    
      vauxp14           => vauxp14,                      
      vauxn14           => vauxn14,    
      vauxp15           => vauxp15,                     
      vauxn15           => vauxn15,
		vp_in=>vp_in,
		vn_in=>vn_in		
		);
--	
--IBUFDS_DIFF_OUT_inst : IBUFGDS_DIFF_OUT
--generic map (
--DIFF_TERM => FALSE, -- Differential Termination
--IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for refernced I/O standards
--IOSTANDARD => "DEFAULT") -- Specify the input I/O standard
--port map (
--O => clk_40M_p, -- Buffer diff_p output
--OB => clk_40M_n, -- Buffer diff_n output
--I => clk_40M_I, -- Diff_p buffer input (connect directly to top-level port)
--IB => clk_40M_IB -- Diff_n buffer input (connect directly to top-level port)
--);
-- End of IBUFGDS_DIFF_OUT_inst instantiation

--io_gen : for i in 0 to 15 generate
--IBUFDS_inst : IBUFDS
--generic map (
--DIFF_TERM => FALSE, -- Differential Termination
--IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for refernced I/O standards
--IOSTANDARD => "DEFAULT")
--port map (
--O => apd_fpga_hit(i), -- Buffer output
--I => apd_fpga_hit_p(i), -- Diff_p buffer input (connect directly to top-level port)
--IB => apd_fpga_hit_n(i) -- Diff_n buffer input (connect directly to top-level port)
--);
--end generate;

-----for test--
--
--process(sys_clk_80M)
--begin
--	if rising_edge(sys_clk_80M) then
--		if(sys_rst_n = '0') then
--			cnt	<=	X"0";
--		elsif(cnt = X"F") then
--			cnt	<=	cnt;
--		else
--			cnt	<=	cnt + '1';
--		end if;
--	end if;
--end process;
--
--fifo_wr : process(sys_clk_80M)
--begin
--	if rising_edge(sys_clk_80M) then
--		if(sys_rst_n = '0') then
--			tdc_cpldif_fifo_wr_en	<=	'0';
--			tdc_cpldif_fifo_wr_data	<=	(others => '0');
--		elsif(cnt = X"F") then
--			if(cpldif_tdc_fifo_almost_full = '0') then
--				tdc_cpldif_fifo_wr_en	<=	'1';
--				tdc_cpldif_fifo_wr_data	<=	tdc_cpldif_fifo_wr_data + '1';
--			else
--				tdc_cpldif_fifo_wr_en	<=	'0';
--				tdc_cpldif_fifo_wr_data	<=	tdc_cpldif_fifo_wr_data;
--			end if;
--		else
--			tdc_cpldif_fifo_wr_en	<=	'0';
--			tdc_cpldif_fifo_wr_data	<=	(others => '0');
--		end if;
--	end if;
--end process;



end Behavioral;

