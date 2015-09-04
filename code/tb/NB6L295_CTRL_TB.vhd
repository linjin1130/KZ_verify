--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:21:35 03/14/2015
-- Design Name:   
-- Module Name:   E:/Work/FPGA/KZ_verify/KZ_verify/NBL295_CTRL_TB.vhd
-- Project Name:  ground_pro
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: DAC_INTERFACE
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
 
ENTITY NB6L295_CTRL_TB IS
END NB6L295_CTRL_TB;
 
ARCHITECTURE behavior OF NB6L295_CTRL_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT NB6L295_CTRL
    PORT(
         CLK : IN  std_logic;
         Dac_Ena : IN  std_logic;
         Dac_Data : IN  std_logic_vector(15 downto 0);
         Sys_Rst_n : IN  std_logic;
         Dac_Finish : OUT  std_logic;
         Dac_en : OUT  std_logic;
         Dac_Sclk : OUT  std_logic;
         Dac_Csn : OUT  std_logic;
         Dac_Din : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal Dac_Ena : std_logic := '0';
   signal Dac_Data : std_logic_vector(15 downto 0) := (others => '0');
   signal Sys_Rst_n : std_logic := '0';

 	--Outputs
   signal Dac_Finish : std_logic;
   signal Dac_en : std_logic;
   signal Dac_Sclk : std_logic;
   signal Dac_Csn : std_logic;
   signal Dac_Din : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 12.5 ns;
   constant Dac_Sclk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: NB6L295_CTRL PORT MAP (
          CLK => CLK,
          Dac_Ena => Dac_Ena,
          Dac_Data => Dac_Data,
          Sys_Rst_n => Sys_Rst_n,
          Dac_Finish => Dac_Finish,
          Dac_en => Dac_en,
          Dac_Sclk => Dac_Sclk,
          Dac_Csn => Dac_Csn,
          Dac_Din => Dac_Din
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 
--   Dac_Sclk_process :process
--   begin
--		Dac_Sclk <= '0';
--		wait for Dac_Sclk_period/2;
--		Dac_Sclk <= '1';
--		wait for Dac_Sclk_period/2;
--   end process;
-- 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      Sys_Rst_n	<= '0';
		wait for 100 ns;	
		 Sys_Rst_n	<= '1';

      wait for CLK_period*1000;
		
		wait until rising_edge(CLK);
		Dac_Ena	<= '1';
		Dac_data	<= x"5555";
		
		wait for CLK_period*10;
		wait until rising_edge(CLK);
		Dac_Ena	<= '0';
		Dac_data	<= x"5555";
		wait for 30 us;	
		wait until rising_edge(CLK);
		Dac_Ena	<= '1';
		Dac_data	<= x"AAAA";
		
		wait for CLK_period*100;
		wait until rising_edge(CLK);
		Dac_Ena	<= '0';
		Dac_data	<= x"AAAA";
      -- insert stimulus here 

      wait;
   end process;

END;
