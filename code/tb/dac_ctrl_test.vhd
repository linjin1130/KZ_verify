--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:32:13 08/09/2013
-- Design Name:   
-- Module Name:   F:/ground_project/ground_pro/dac_ctrl_test.vhd
-- Project Name:  ground_pro
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: DAC_Ctrl
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY dac_ctrl_test IS
END dac_ctrl_test;
 
ARCHITECTURE behavior OF dac_ctrl_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DAC_Ctrl
    PORT(
         sys_clk_80M : IN  std_logic;
         sys_rst : IN  std_logic;
         fpga_dac_data : INOUT  std_logic_vector(7 downto 0);
         fpga_dac_addr : OUT  std_logic_vector(3 downto 0);
         fpga_dac_rs_n : OUT  std_logic;
         fpga_dac_cs_n : OUT  std_logic;
         fpga_dac_rw_n : OUT  std_logic;
         fpga_dac_ld_n : OUT  std_logic;
         fpga_dac_en_n : OUT  std_logic;
         cpldif_dac_addr : IN  std_logic_vector(7 downto 0);
         cpldif_dac_wr_en : IN  std_logic;
         cpldif_dac_wr_data : IN  std_logic_vector(31 downto 0);
         cpldif_dac_rd_en : IN  std_logic;
         cpldif_dac_rd_data : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal sys_clk_80M : std_logic := '0';
   signal sys_rst : std_logic := '0';
   signal cpldif_dac_addr : std_logic_vector(7 downto 0) := X"40";
   signal cpldif_dac_wr_en : std_logic := '0';
   signal cpldif_dac_wr_data : std_logic_vector(31 downto 0) := (others => '0');
   signal cpldif_dac_rd_en : std_logic := '0';

	--BiDirs
   signal fpga_dac_data : std_logic_vector(7 downto 0);

 	--Outputs
   signal fpga_dac_addr : std_logic_vector(3 downto 0);
   signal fpga_dac_rs_n : std_logic;
   signal fpga_dac_cs_n : std_logic;
   signal fpga_dac_rw_n : std_logic;
   signal fpga_dac_ld_n : std_logic;
   signal fpga_dac_en_n : std_logic;
   signal cpldif_dac_rd_data : std_logic_vector(31 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant clk_period : time := 12.5 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: DAC_Ctrl PORT MAP (
          sys_clk_80M => sys_clk_80M,
          sys_rst => sys_rst,
          fpga_dac_data => fpga_dac_data,
          fpga_dac_addr => fpga_dac_addr,
          fpga_dac_rs_n => fpga_dac_rs_n,
          fpga_dac_cs_n => fpga_dac_cs_n,
          fpga_dac_rw_n => fpga_dac_rw_n,
          fpga_dac_ld_n => fpga_dac_ld_n,
          fpga_dac_en_n => fpga_dac_en_n,
          cpldif_dac_addr => cpldif_dac_addr,
          cpldif_dac_wr_en => cpldif_dac_wr_en,
          cpldif_dac_wr_data => cpldif_dac_wr_data,
          cpldif_dac_rd_en => cpldif_dac_rd_en,
          cpldif_dac_rd_data => cpldif_dac_rd_data
        );

   -- Clock process definitions
   clk_process :process
   begin
		sys_clk_80M <= '0';
		wait for clk_period/2;
		sys_clk_80M <= '1';
		wait for clk_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
      sys_rst	<=	'1';
	  wait for clk_period*10;
	  sys_rst	<=	'0';
	  wait;
   end process;
   
--   process(sys_clk_80M)
--   begin
--		if rising_edge(sys_clk_80M) then
--			
--   end process;
   
   process
   begin
		wait until(sys_rst = '0');
		for i in 0 to 3 loop
		wait until rising_edge(sys_clk_80M);
			cpldif_dac_addr	<=	cpldif_dac_addr + '1';
			cpldif_dac_wr_data	<=	cpldif_dac_wr_data + X"10011001";
--			wait for clk_period;
			wait until rising_edge(sys_clk_80M);
			cpldif_dac_wr_en	<=	'1';
--			wait for clk_period;
			wait until rising_edge(sys_clk_80M);
			cpldif_dac_wr_en	<=	'0';
			wait for clk_period*200;
		end loop;
		cpldif_dac_addr	<= X"40";
		wait for clk_period;
		wait until rising_edge(sys_clk_80M);
		cpldif_dac_addr	<=	cpldif_dac_addr + '1';
		cpldif_dac_wr_data	<=	(others => '1');
		wait until rising_edge(sys_clk_80M);
		cpldif_dac_wr_en	<=	'1';
		wait until rising_edge(sys_clk_80M);
		cpldif_dac_wr_en	<=	'0';
		wait for clk_period*200;
		cpldif_dac_addr	<= X"40";
		wait for clk_period*100;
		for i in 0 to 3 loop
			cpldif_dac_addr	<=	cpldif_dac_addr + '1';
			wait for clk_period;
			cpldif_dac_rd_en	<=	'1';
			wait for clk_period;
			cpldif_dac_rd_en	<=	'0';
			wait for clk_period*5;
		end loop;
   end process;

END;
