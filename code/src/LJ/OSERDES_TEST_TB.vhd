--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:39:46 08/06/2014
-- Design Name:   
-- Module Name:   E:/Work/FPGA/OSERDES_TEST/OSERDES_TEST_TB.vhd
-- Project Name:  OSERDES_TEST
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: OSERDES_TEST
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
 
ENTITY OSERDES_TEST_TB IS
END OSERDES_TEST_TB;
 
ARCHITECTURE behavior OF OSERDES_TEST_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT OSERDES_TEST
    PORT(
         CLK_160M_p : IN  std_logic;
         CLK_160M_n : IN  std_logic;
         DATA_OUT : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK_160M_p : std_logic := '0';
   signal CLK_160M_n : std_logic := '0';

 	--Outputs
   signal DATA_OUT : std_logic;

   -- Clock period definitions
   constant CLK_160M_period : time := 12.5 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: OSERDES_TEST PORT MAP (
          CLK_160M_p => CLK_160M_p,
          CLK_160M_n => CLK_160M_n,
          DATA_OUT => DATA_OUT
        );

   -- Clock process definitions
   CLK_160M_process :process
   begin
		CLK_160M_p <= '0';
		CLK_160M_n <= '1';
		wait for CLK_160M_period/2;
		CLK_160M_p <= '1';
		CLK_160M_n <= '0';
		wait for CLK_160M_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLK_160M_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
