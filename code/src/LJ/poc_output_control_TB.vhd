--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:40:26 12/09/2014
-- Design Name:   
-- Module Name:   E:/Work/FPGA/ground_pro_all_DPS_QKD_test/ground_pro_use_PPG/code/src/LJ/poc_output_control_TB.vhd
-- Project Name:  ground_pro
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: POC_output_control
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY poc_output_control_TB IS
END poc_output_control_TB;
 
ARCHITECTURE behavior OF poc_output_control_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT POC_output_control
    PORT(
         sys_clk : IN  std_logic;
         sys_rst_n : IN  std_logic;
         fifo_clr : IN  std_logic;
         exp_running : IN  std_logic;
         syn_light : IN  std_logic;
         Alice_H_Bob_L : IN  std_logic;
         POC_fifo_wr_en : IN  std_logic;
         POC_fifo_wr_data : IN  std_logic_vector(31 downto 0);
         POC_fifo_rdy : OUT  std_logic;
         POC_control_en : IN  std_logic;
         POC_control : IN  std_logic_vector(6 downto 0);
         POC_start : OUT  std_logic_vector(6 downto 0);
         POC_stop : OUT  std_logic_vector(6 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal sys_clk : std_logic := '0';
   signal sys_rst_n : std_logic := '0';
   signal fifo_clr : std_logic := '0';
   signal exp_running : std_logic := '1';
   signal syn_light : std_logic := '0';
   signal Alice_H_Bob_L : std_logic := '0';
   signal POC_fifo_wr_en : std_logic := '0';
   signal POC_fifo_wr_data : std_logic_vector(31 downto 0) := (others => '0');
   signal POC_control_en : std_logic := '0';
   signal POC_control : std_logic_vector(6 downto 0) := (others => '0');

 	--Outputs
   signal POC_fifo_rdy : std_logic;
   signal POC_start : std_logic_vector(6 downto 0);
   signal POC_stop : std_logic_vector(6 downto 0);

   -- Clock period definitions
   constant sys_clk_period : time := 12.5 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: POC_output_control PORT MAP (
          sys_clk => sys_clk,
          sys_rst_n => sys_rst_n,
          fifo_clr => fifo_clr,
          exp_running => exp_running,
          syn_light => syn_light,
          Alice_H_Bob_L => Alice_H_Bob_L,
          POC_fifo_wr_en => POC_fifo_wr_en,
          POC_fifo_wr_data => POC_fifo_wr_data,
          POC_fifo_rdy => POC_fifo_rdy,
          POC_control_en => POC_control_en,
          POC_control => POC_control,
          POC_start => POC_start,
          POC_stop => POC_stop
        );

   -- Clock process definitions
   sys_clk_process :process
   begin
		sys_clk <= '0';
		wait for sys_clk_period/2;
		sys_clk <= '1';
		wait for sys_clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 us;	
		sys_rst_n	<= '1';
      wait for sys_clk_period*10;
		POC_control_en	<= '1';
		POC_control	<= (others => '1');
		wait for sys_clk_period;
		POC_control_en	<= '0';
		wait for 100 us;	
		POC_control_en	<= '1';
		POC_control	<= "0011010";
		wait for sys_clk_period;
		POC_control_en	<= '0';
      -- insert stimulus here 
		wait for 100 us;	
		POC_control_en	<= '1';
		POC_control	<= "0000000";
		wait for sys_clk_period;
		POC_control_en	<= '0';
      wait;
   end process;

END;
