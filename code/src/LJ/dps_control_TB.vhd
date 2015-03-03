--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:00:38 12/18/2014
-- Design Name:   
-- Module Name:   E:/Work/FPGA/ground_pro_all_DPS_QKD_test/ground_pro_use_PPG/dps_control_TB.vhd
-- Project Name:  ground_pro
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: DPS_control
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;  
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY dps_control_TB IS
END dps_control_TB;
 
ARCHITECTURE behavior OF dps_control_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DPS_control
    PORT(
         sys_clk_80M : IN  std_logic;
         sys_clk_250M : IN  std_logic;
         sys_rst_n : IN  std_logic;
         exp_running : IN  std_logic;
         Alice_H_Bob_L : IN  std_logic;
         gps_pulse : IN  std_logic;
--         pm_steady_test : IN  std_logic;
         GPS_period_cnt : IN  std_logic_vector(31 downto 0);
         DPS_send_PM_dly_cnt : IN  std_logic_vector(7 downto 0);
         DPS_send_AM_dly_cnt : IN  std_logic_vector(7 downto 0);
         DPS_syn_dly_cnt : IN  std_logic_vector(11 downto 0);
         DPS_round_cnt : IN  std_logic_vector(15 downto 0);
         DPS_chopper_cnt : IN  std_logic_vector(3 downto 0);
         set_send_enable_cnt : IN  std_logic_vector(31 downto 0);
         set_send_disable_cnt : IN  std_logic_vector(31 downto 0);
         set_chopper_enable_cnt : IN  std_logic_vector(31 downto 0);
         set_chopper_disable_cnt : IN  std_logic_vector(31 downto 0);
         GPS_pulse_int : OUT  std_logic;
         GPS_pulse_int_active : OUT  std_logic;
         PPG_start : OUT  std_logic;
         chopper_ctrl : OUT  std_logic;
         chopper_ctrl_80M : OUT  std_logic;
         syn_light : OUT  std_logic;
         send_en_AM : OUT  std_logic;
         send_en : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal sys_clk_80M : std_logic := '0';
   signal sys_clk_250M : std_logic := '0';
   signal sys_rst_n : std_logic := '0';
   signal exp_running : std_logic := '0';
   signal Alice_H_Bob_L : std_logic := '1';
   signal gps_pulse : std_logic := '0';
   signal pm_steady_test : std_logic := '0';
   signal GPS_period_cnt : std_logic_vector(31 downto 0) := x"8004B400";
   signal DPS_send_PM_dly_cnt : std_logic_vector(7 downto 0) := x"20";
   signal DPS_send_AM_dly_cnt : std_logic_vector(7 downto 0) := (others => '0');
   signal DPS_syn_dly_cnt : std_logic_vector(11 downto 0) := x"020";
   signal DPS_round_cnt : std_logic_vector(15 downto 0) := x"61A7";
   signal DPS_chopper_cnt : std_logic_vector(3 downto 0) := (others => '0');
   signal set_send_enable_cnt : std_logic_vector(31 downto 0) := X"00042400";
   signal set_send_disable_cnt : std_logic_vector(31 downto 0) := X"00000100";
   signal set_chopper_enable_cnt : std_logic_vector(31 downto 0) := X"00042400";
   signal set_chopper_disable_cnt : std_logic_vector(31 downto 0) := X"00042400";

 	--Outputs
   signal GPS_pulse_int : std_logic;
   signal GPS_pulse_int_active : std_logic;
   signal PPG_start : std_logic;
   signal chopper_ctrl : std_logic;
   signal chopper_ctrl_80M : std_logic;
   signal syn_light : std_logic;
   signal send_en_AM : std_logic;
   signal send_en : std_logic;
   -- No clocks detected in port list. Replace sys_clk_80M below with 
   -- appropriate port name 
 
   constant sys_clk_80M_period : time := 12.5 ns;
   constant sys_clk_250M_period : time := 4 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: DPS_control PORT MAP (
          sys_clk_80M => sys_clk_80M,
          sys_clk_250M => sys_clk_250M,
          sys_rst_n => sys_rst_n,
          exp_running => exp_running,
          Alice_H_Bob_L => Alice_H_Bob_L,
          gps_pulse => gps_pulse,
--          pm_steady_test => pm_steady_test,
          GPS_period_cnt => GPS_period_cnt,
          DPS_send_PM_dly_cnt => DPS_send_PM_dly_cnt,
          DPS_send_AM_dly_cnt => DPS_send_AM_dly_cnt,
          DPS_syn_dly_cnt => DPS_syn_dly_cnt,
          DPS_round_cnt => DPS_round_cnt,
          DPS_chopper_cnt => DPS_chopper_cnt,
          set_send_enable_cnt => set_send_enable_cnt,
          set_send_disable_cnt => set_send_disable_cnt,
          set_chopper_enable_cnt => set_chopper_enable_cnt,
          set_chopper_disable_cnt => set_chopper_disable_cnt,
          GPS_pulse_int => GPS_pulse_int,
          GPS_pulse_int_active => GPS_pulse_int_active,
          PPG_start => PPG_start,
          chopper_ctrl => chopper_ctrl,
          chopper_ctrl_80M => chopper_ctrl_80M,
          syn_light => syn_light,
          send_en_AM => send_en_AM,
          send_en => send_en
        );

   -- Clock process definitions
   sys_clk_80M_process :process
   begin
		sys_clk_80M <= '0';
		wait for sys_clk_80M_period/2;
		sys_clk_80M <= '1';
		wait for sys_clk_80M_period/2;
   end process;
	
	 sys_clk_250M_process :process
   begin
		sys_clk_250M <= '0';
		wait for sys_clk_250M_period/2;
		sys_clk_250M <= '1';
		wait for sys_clk_250M_period/2;
   end process;
	
	GPS_process :process
   begin
		wait until rising_edge(GPS_pulse_int);
		wait for 1000 ns;
		gps_pulse <= '1';
		wait for 56 ns;
		gps_pulse <= '0';
		wait for 50 ms;
		gps_pulse <= '0';
   end process;
	
	exp_running_process :process
   begin
--		wait until rising_edge(gps_pulse);
		wait until rising_edge(gps_pulse);
		wait for 20 ns;
		wait until rising_edge(sys_clk_80M);
		exp_running <= '1';
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		sys_rst_n	<= '1';
      wait for sys_clk_80M_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
