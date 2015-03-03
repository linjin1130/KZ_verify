--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:44:26 08/21/2013
-- Design Name:   
-- Module Name:   F:/ground_project/ground_pro/count_test.vhd
-- Project Name:  ground_pro
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: count_measure
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
 
ENTITY count_test IS
END count_test;
 
ARCHITECTURE behavior OF count_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT count_measure
    PORT(
         sys_clk_80M : IN  std_logic;
         sys_rst_n : IN  std_logic;
         apd_fpga_hit_p : IN  std_logic_vector(15 downto 0);
         apd_fpga_hit_n : IN  std_logic_vector(15 downto 0);
         tdc_count_time_value : IN  std_logic_vector(31 downto 0);
         cpldif_count_addr : IN  std_logic_vector(7 downto 0);
         cpldif_count_wr_en : IN  std_logic;
         cpldif_count_rd_en : IN  std_logic;
         cpldif_count_wr_data : IN  std_logic_vector(31 downto 0);
         count_cpldif_rd_data : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal sys_clk_80M : std_logic := '0';
   signal sys_rst_n : std_logic := '0';
   signal apd_fpga_hit_p : std_logic_vector(15 downto 0) := (others => '0');
   signal apd_fpga_hit_n : std_logic_vector(15 downto 0) := (others => '0');
   signal tdc_count_time_value : std_logic_vector(31 downto 0) := (others => '0');
   signal cpldif_count_addr : std_logic_vector(7 downto 0) := (others => '0');
   signal cpldif_count_wr_en : std_logic := '0';
   signal cpldif_count_rd_en : std_logic := '0';
   signal cpldif_count_wr_data : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal count_cpldif_rd_data : std_logic_vector(31 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant <clock>_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: count_measure PORT MAP (
          sys_clk_80M => sys_clk_80M,
          sys_rst_n => sys_rst_n,
          apd_fpga_hit_p => apd_fpga_hit_p,
          apd_fpga_hit_n => apd_fpga_hit_n,
          tdc_count_time_value => tdc_count_time_value,
          cpldif_count_addr => cpldif_count_addr,
          cpldif_count_wr_en => cpldif_count_wr_en,
          cpldif_count_rd_en => cpldif_count_rd_en,
          cpldif_count_wr_data => cpldif_count_wr_data,
          count_cpldif_rd_data => count_cpldif_rd_data
        );

   -- Clock process definitions
   <clock>_process :process
   begin
		<clock> <= '0';
		wait for <clock>_period/2;
		<clock> <= '1';
		wait for <clock>_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for <clock>_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
