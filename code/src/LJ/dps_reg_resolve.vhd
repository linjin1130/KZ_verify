----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:28:20 10/27/2014 
-- Design Name: 
-- Module Name:    dps_reg_resolve - Behavioral 
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

entity dps_reg_resolve is
generic(
		DPS_Base_Addr : std_logic_vector(7 downto 0) := X"A0";
		DPS_High_Addr : std_logic_vector(7 downto 0) := X"AF"
	);
	port(
	-- fix by herry make sys_clk_80M to sys_clk_160M
	   sys_clk_80M	:	in	std_logic;--system clock,80MHz
		sys_rst_n	:	in	std_logic;--system reset,low active
		
		test_signal_delay : out std_logic;
		scan_data_store_en: out std_logic;
		rdb_rnd_store_en	: out std_logic;
		rnd_data_store_en	: out std_logic;
		pm_data_store_en	: out std_logic;
		tdc_data_store_en	: out std_logic;
		Alice_H_Bob_L		: out std_logic;
--		exp_running 		: OUT std_logic;
--		exp_stopping 		: OUT std_logic;
		test_rnd				:  out std_logic;--80M clock domain
		test_rnd_data		:  out std_logic_vector(15 downto 0);--fifo read clock
		delay_load	 		: OUT std_logic;
		DPS_syn_dly_cnt	: out	std_logic_vector(11 downto 0);
		DPS_send_PM_dly_cnt	: out	std_logic_vector(7 downto 0);
		DPS_send_AM_dly_cnt	: out	std_logic_vector(7 downto 0);
		DPS_chopper_cnt	: out	std_logic_vector(3 downto 0);
		DPS_round_cnt		: out	std_logic_vector(15 downto 0);
		delay_AM1			: out	std_logic_vector(31 downto 0);
--		delay_AM2			: out	std_logic_vector(4 downto 0);
--		delay_PM 			: out	std_logic_vector(4 downto 0);
		GPS_period_cnt		: out	std_logic_vector(31 downto 0);--bit 31: 1 use intenal gps; 0 use external gps
		delay_AM1_out		: in	std_logic_vector(29 downto 0);
--		delay_AM2_out		: in	std_logic_vector(4 downto 0);
--		delay_PM_out		: in	std_logic_vector(4 downto 0);
		
		lut_wr_addr			: out	std_logic_vector(9 downto 0);
		lut_wr_data			: out	std_logic_vector(15 downto 0);
		lut_wr_en 			: out	std_logic;
		
		reg_wr_addr			: out	std_logic_vector(3 downto 0);
		reg_wr_data			: out	std_logic_vector(15 downto 0);
		reg_wr_en 			: out	std_logic;
		pm_steady_test 		: out std_logic;--80M clock domain
		poc_test_en 			: out	std_logic;
		
		dac_test_en 			: out	std_logic;

		set_send_disable_cnt			: out	std_logic_vector(31 downto 0);--for Alice
		set_send_enable_cnt			: out	std_logic_vector(31 downto 0);--for Alice
	   set_chopper_enable_cnt		: out	std_logic_vector(31 downto 0);--for Bob
	   set_chopper_disable_cnt		: out	std_logic_vector(31 downto 0);--for Bob
		
		---cpldif module
		cpldif_dps_addr		:	in	std_logic_vector(7 downto 0);
		cpldif_dps_wr_en	:	in	std_logic;
		cpldif_dps_rd_en	:	in	std_logic;
		cpldif_dps_wr_data	:	in	std_logic_vector(31 downto 0);
		dps_cpldif_rd_data	:	out	std_logic_vector(31 downto 0)
	);
end dps_reg_resolve;

architecture Behavioral of dps_reg_resolve is
--signal apd_fpga_hit : std_logic_vector(15 downto 0);
--signal apd_fpga_hit_1d : std_logic_vector(15 downto 0);
--signal apd_fpga_hit_2d : std_logic_vector(15 downto 0);
--signal hit_cnt_en	:	std_logic_vector(15 downto 0);
-----
signal rd_data_reg			: std_logic_vector(31 downto 0);
signal addr_sel 				: std_logic_vector(7 downto 0);
signal dps_round_cnt_reg	: std_logic_vector(15 downto 0);
signal DPS_syn_dly_cnt_reg	: std_logic_vector(11 downto 0);
signal DPS_chopper_cnt_reg	: std_logic_vector(3 downto 0);
signal delay_am1_reg			: std_logic_vector(31 downto 0);

signal DPS_send_PM_dly_cnt_reg	: std_logic_vector(7 downto 0);
signal DPS_send_AM_dly_cnt_reg	: std_logic_vector(7 downto 0);
signal GPS_period_cnt_reg		: std_logic_vector(31 downto 0);
signal rnd_ctrl_reg		: std_logic_vector(31 downto 0);

signal set_send_disable_cnt_reg			: std_logic_vector(31 downto 0);--for Alice
signal set_send_enable_cnt_reg			: std_logic_vector(31 downto 0);--for Alice
signal set_chopper_enable_cnt_reg		: std_logic_vector(31 downto 0);--for Bob
signal set_chopper_disable_cnt_reg		: std_logic_vector(31 downto 0);--for Bob

signal lut_wr_reg		: std_logic_vector(31 downto 0);--for Bob

--signal delay_am2_reg			: std_logic_vector(4 downto 0);
--signal delay_pm_reg			: std_logic_vector(4 downto 0);
--signal exp_run_start 		: std_logic;
--signal exp_run_stop 			: std_logic;

--signal cpldif_dps_wr_en_d1	: std_logic;


begin


--****** register manager ***
lock_addr : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		addr_sel	<=	X"FF";
	elsif rising_edge(sys_clk_80M) then
		if(cpldif_dps_addr >= DPS_Base_Addr and cpldif_dps_addr <=	DPS_High_Addr) then
			addr_sel	<=	cpldif_dps_addr	- DPS_Base_Addr;
		else
			addr_sel	<=	X"FF";
		end if;
	end if;
end process;
---generate run and stop start
--process(addr_sel,cpldif_dps_wr_data(7 downto 0),exp_run_start, exp_run_stop)
--begin
--	if(addr_sel = x"00" ) then--CONTROL REG
--		if( cpldif_dps_wr_data(7 downto 0) = x"3C") then--exp running
--			exp_run_start	<= '1';
--			exp_run_stop	<= '0';
--		else
--			if( cpldif_dps_wr_data(7 downto 0) = x"C3") then--exp stopping
--				exp_run_start	<= '0';
--				exp_run_stop	<= '1';
--			else
--				exp_run_start	<= '0';
--				exp_run_stop	<= '0';
--			end if;
--		end if;
--	else
--		exp_run_start	<= '0';
--		exp_run_stop	<= '0';
--	end if;
--end process;
process(sys_clk_80M, sys_rst_n)
begin
	if(sys_rst_n = '0') then
		rnd_ctrl_reg	<= (others => '0');
		test_rnd			<= '0';
		Alice_H_Bob_L	<= '1';---default is Alice
		pm_steady_test	<= '0';---default is low
		tdc_data_store_en	<= '0';
		pm_data_store_en	<= '0';
		rdb_rnd_store_en	<= '0';
		rnd_data_store_en	<= '0';
		scan_data_store_en<= '0';
		test_signal_delay<= '0';
		test_rnd_data<= (others => '0');
	elsif rising_edge(sys_clk_80M) then
		if(addr_sel = x"00" and cpldif_dps_wr_en = '1') then--CONTROL REG
			rnd_ctrl_reg	<= cpldif_dps_wr_data;
			if( cpldif_dps_wr_data(7 downto 0) = x"3C" ) then--exp running
				test_rnd			<= '1';
				test_rnd_data	<= cpldif_dps_wr_data(31 downto 16);
			else
				if( cpldif_dps_wr_data(7 downto 0) = x"C3" ) then--exp running
					test_rnd	<= '0';
				else
					null;
				end if;
			end if;
			
			if( cpldif_dps_wr_data(7 downto 0) = x"20" ) then--exp running
				test_signal_delay	<= '1';
			else
				if( cpldif_dps_wr_data(7 downto 0) = x"02" ) then--exp running
					test_signal_delay	<= '0';
				else
					null;
				end if;
			end if;
			
			if(cpldif_dps_wr_data(7 downto 0) = x"69") then
				Alice_H_Bob_L	<= '0';--- is Bob
			else
				if(cpldif_dps_wr_data(7 downto 0) = x"96") then
					Alice_H_Bob_L	<= '1';--- is Alice
				else
					null;
				end if;
			end if;
			
			if( cpldif_dps_wr_data(8) = '1' ) then--exp running
				pm_steady_test	<= '1';
			else
				pm_steady_test	<= '0';
			end if;
			
			tdc_data_store_en	<= cpldif_dps_wr_data(9);
			pm_data_store_en	<= cpldif_dps_wr_data(10);
			rdb_rnd_store_en	<= cpldif_dps_wr_data(11);
			scan_data_store_en<= cpldif_dps_wr_data(12);
			rnd_data_store_en <= cpldif_dps_wr_data(13);
		else
			pm_steady_test	<= '0';
		end if;
	end if;
end process;

--generate DPS_round_cnt
process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		DPS_round_cnt_reg				<=	x"61A7";
		DPS_chopper_cnt_reg			<=	(others => '0');
		DPS_syn_dly_cnt_reg			<=	x"020";
	elsif rising_edge(sys_clk_80M) then
		if(addr_sel = x"01"  and cpldif_dps_wr_en = '1') then--DPS_round_cnt REG
			DPS_round_cnt_reg		<= cpldif_dps_wr_data(15 downto 0);
			DPS_chopper_cnt_reg	<= cpldif_dps_wr_data(19 downto 16);
			DPS_syn_dly_cnt_reg	<= cpldif_dps_wr_data(31 downto 20);
		end if;
	end if;
end process;
DPS_round_cnt		<= DPS_round_cnt_reg;
DPS_chopper_cnt	<= DPS_chopper_cnt_reg;
DPS_syn_dly_cnt	<= DPS_syn_dly_cnt_reg;

--generate delay_AM1
process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		delay_AM1_reg			<=	x"C0000000";--default pm is 0110
--		delay_AM2_reg			<=	"01111";
--		delay_PM_reg			<=	"01111";
	elsif rising_edge(sys_clk_80M) then
		if(addr_sel = x"02"  and cpldif_dps_wr_en = '1') then--DPS_round_cnt REG
			delay_AM1_reg	<= cpldif_dps_wr_data;
--			delay_AM2_reg	<= cpldif_dps_wr_data(12 downto 8);
--			delay_PM_reg	<= cpldif_dps_wr_data(20 downto 16);
		end if;
	end if;
end process;
delay_AM1	<= delay_AM1_reg;
--delay_AM2	<= delay_AM2_reg;
--delay_PM		<= delay_PM_reg;

process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		delay_load				<=	'0';
--		cpldif_dps_wr_en_d1	<=	'0';
	elsif rising_edge(sys_clk_80M) then
--		cpldif_dps_wr_en_d1	<= cpldif_dps_wr_en;
		if(addr_sel = x"02"  and cpldif_dps_wr_en = '1') then--DPS_round_cnt REG
			delay_load			<=	'1';
		else
			delay_load			<=	'0';
		end if;
	end if;
end process;

process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		GPS_period_cnt_reg			<=	x"02DC6C00";---600ms 300MS phase steady 300ms test
	elsif rising_edge(sys_clk_80M) then
		if(addr_sel = x"03" and cpldif_dps_wr_en = '1' ) then--GPS period count REG
			GPS_period_cnt_reg	<= cpldif_dps_wr_data;
		end if;
	end if;
end process;
GPS_period_cnt	<= GPS_period_cnt_reg;

process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		DPS_send_PM_dly_cnt_reg			<=	x"F0";
		DPS_send_AM_dly_cnt_reg			<=	x"00";
	elsif rising_edge(sys_clk_80M) then
		if(addr_sel = x"04" and cpldif_dps_wr_en = '1' ) then--GPS period count REG
			DPS_send_PM_dly_cnt_reg	<= cpldif_dps_wr_data(7 downto 0);
			DPS_send_AM_dly_cnt_reg	<= cpldif_dps_wr_data(15 downto 8);
		end if;
	end if;
end process;

DPS_send_PM_dly_cnt	<= DPS_send_PM_dly_cnt_reg;
DPS_send_AM_dly_cnt	<= DPS_send_AM_dly_cnt_reg;
	
process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		set_send_enable_cnt_reg			<=	x"016E0000";--
	elsif rising_edge(sys_clk_80M) then
		if(addr_sel = x"05" and cpldif_dps_wr_en = '1' ) then--GPS period count REG
			set_send_enable_cnt_reg	<= cpldif_dps_wr_data;
		end if;
	end if;
end process;
set_send_enable_cnt	<= set_send_enable_cnt_reg;
	
process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		set_send_disable_cnt_reg			<=	x"02DC2C00";--50us ÓàÁ¿
	elsif rising_edge(sys_clk_80M) then
		if(addr_sel = x"06" and cpldif_dps_wr_en = '1' ) then--GPS period count REG
			set_send_disable_cnt_reg	<= cpldif_dps_wr_data;
		end if;
	end if;
end process;
set_send_disable_cnt	<= set_send_disable_cnt_reg;

process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		set_chopper_enable_cnt_reg			<=	x"00004000";---50us ÓàÁ¿
	elsif rising_edge(sys_clk_80M) then
		if(addr_sel = x"07" and cpldif_dps_wr_en = '1' ) then--GPS period count REG
			set_chopper_enable_cnt_reg	<= cpldif_dps_wr_data;
		end if;
	end if;
end process;
set_chopper_enable_cnt	<= set_chopper_enable_cnt_reg;

process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		set_chopper_disable_cnt_reg			<=	x"016D3600";--16E3600 is 300ms 200usÓàÁ¿
	elsif rising_edge(sys_clk_80M) then
		if(addr_sel = x"08" and cpldif_dps_wr_en = '1' ) then--GPS period count REG
			set_chopper_disable_cnt_reg	<= cpldif_dps_wr_data;
		end if;
	end if;
end process;
set_chopper_disable_cnt	<= set_chopper_disable_cnt_reg;

process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		lut_wr_reg			<=	x"00000000";
		lut_wr_en			<=	'0';
		reg_wr_en			<=	'0';
		dac_test_en			<=	'0';
		poc_test_en			<=	'0';
	elsif rising_edge(sys_clk_80M) then
		if(addr_sel = x"09" and cpldif_dps_wr_en = '1' ) then--lut ram REG
			lut_wr_reg	<= cpldif_dps_wr_data;
			if(cpldif_dps_wr_data(31 downto 30) = "00") then--PM steady alg reg
				reg_wr_en	<= '1';
			end if;
			if(cpldif_dps_wr_data(31 downto 30) = "01") then
				lut_wr_en	<=	'1';
			end if;
			if(cpldif_dps_wr_data(31 downto 30) = "10") then
				dac_test_en	<=	'1';
			end if;
			if(cpldif_dps_wr_data(31 downto 30) = "11") then
				poc_test_en	<=	'1';
			end if;
		else
			lut_wr_en		<=	'0';
			reg_wr_en		<= '0';
			dac_test_en			<=	'0';
			poc_test_en			<=	'0';
		end if;
	end if;
end process;
lut_wr_addr	<= lut_wr_reg(25 downto 16);
lut_wr_data	<= lut_wr_reg(15 downto  0);
reg_wr_addr	<= lut_wr_reg(29 downto 26);
reg_wr_data	<= lut_wr_reg(15 downto  0);
--process(sys_clk_80M,sys_rst_n)
--begin
--	if(sys_rst_n = '0') then
--		delay_AM1_reg			<=	"01111";
--	elsif rising_edge(sys_clk_80M) then
--		if(addr_sel = x"02" ) then--DPS_round_cnt REG
--			delay_AM1_reg	<= cpldif_dps_wr_data(4 downto 0);
--		end if;
--	end if;
--end process;
--delay_AM1	<= delay_AM1_reg;
--
----generate delay_AM2
--process(sys_clk_80M,sys_rst_n)
--begin
--	if(sys_rst_n = '0') then
--		delay_AM2_reg			<=	(others => '0');
--	elsif rising_edge(sys_clk_80M) then
--		if(addr_sel = x"03" ) then--DPS_round_cnt REG
--			delay_AM2_reg	<= cpldif_dps_wr_data(4 downto 0);
--		end if;
--	end if;
--end process;
--delay_AM2	<= delay_AM2_reg;
--
----generate delay_PM
--process(sys_clk_80M,sys_rst_n)
--begin
--	if(sys_rst_n = '0') then
--		delay_PM_reg			<=	(others => '0');
--	elsif rising_edge(sys_clk_80M) then
--		if(addr_sel = x"04" ) then--DPS_round_cnt REG
--			delay_PM_reg	<= cpldif_dps_wr_data(4 downto 0);
--		end if;
--	end if;
--end process;
--delay_PM	<= delay_PM_reg;

--generate pc write data
--process(addr_sel,cpldif_dps_wr_en)
--begin
--	if(addr_sel = x"00" and cpldif_dps_wr_en = '1') then--CONTROL REG
--		pc_wr_en_reg	<= '1';
--	else
--		pc_wr_en_reg	<= '0';
--	end if;
--end process;
--generate pc write data
--process(sys_clk_80M,sys_rst_n)
--begin
--	if(sys_rst_n = '0') then
--		pc_wr_en			<=	 '0';
--		pc_wr_data		<=	(others => '0');
--		pc_wr_addr		<=	(others => '0');
--	elsif rising_edge(sys_clk_80M) then
--		pc_wr_en			<=	 pc_wr_en_reg;
--		pc_wr_data		<=	cpldif_dps_wr_data(15 downto 0);
--		pc_wr_addr		<=	cpldif_dps_wr_data(31 downto 16);
--	end if;
--end process;

read_ram : process(sys_clk_80M, sys_rst_n)
begin
if(sys_rst_n = '0') then	
	rd_data_reg		<= (others => '0');
else
	if rising_edge(sys_clk_80M) then
		if(cpldif_dps_rd_en = '1') then
			case addr_sel is
				when X"00"	=>	rd_data_reg	<=	rnd_ctrl_reg;
				when X"01"	=>	rd_data_reg	<=	DPS_syn_dly_cnt_reg & DPS_chopper_cnt_reg & DPS_round_cnt_reg;--read count of channel 0
				when X"02"	=>	rd_data_reg	<=	delay_AM1_reg(31 downto 30) & delay_AM1_out;
				when X"03"	=>	rd_data_reg	<=	GPS_period_cnt_reg;
				when X"04"	=>	rd_data_reg	<=	X"DaDa" & DPS_send_AM_dly_cnt_reg & DPS_send_PM_dly_cnt_reg;--read count of channel 1
				when X"05"	=>	rd_data_reg	<=	set_send_enable_cnt_reg;--read count of channel 1
				when X"06"	=>	rd_data_reg	<=	set_send_disable_cnt_reg;--read count of channel 1
				when X"07"	=>	rd_data_reg	<=	set_chopper_enable_cnt_reg;--read count of channel 1
				when X"08"	=>	rd_data_reg	<=	set_chopper_disable_cnt_reg;--read count of channel 1
				when X"09"	=>	rd_data_reg	<=	lut_wr_reg;--read count of channel 1
--				when others	=>	rd_data_reg	<=	x"5A" & "000" & delay_AM1_out & "000" & delay_AM2_out & "000" & delay_PM_out;
				when others	=>	rd_data_reg	<= (others => '0');
			end case;
		end if;
	end if;
end if;
end process;
--**** end ********


dps_cpldif_rd_data	<=	rd_data_reg;



end Behavioral;

