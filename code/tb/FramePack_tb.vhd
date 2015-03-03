--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:46:18 09/02/2013
-- Design Name:   
-- Module Name:   F:/13/GroundSystem/code/V2/ground_pro_all/FramePack_tb.vhd
-- Project Name:  ground_pro
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: FramePack
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 use IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY FramePack_tb IS
END FramePack_tb;
 
ARCHITECTURE behavior OF FramePack_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT FramePack
    PORT(
         sys_clk : IN  std_logic;
         sys_rst_n : IN  std_logic;
         frame_en : IN  std_logic;
         tdc_frame_fifo_almost_empty : IN  std_logic;
         tdc_frame_fifo_rd_en : OUT  std_logic;
         tdc_frame_fifo_dout : IN  std_logic_vector(15 downto 0);
         frame_sdram_fifo_rd_en : IN  std_logic;
         frame_sdram_fifo_data_count : OUT  std_logic_vector(11 downto 0);
         frame_sdram_fifo_dout : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal sys_clk : std_logic := '0';
   signal sys_rst_n : std_logic := '0';
   signal frame_en : std_logic := '0';
   signal tdc_frame_fifo_almost_empty : std_logic := '0';
   signal tdc_frame_fifo_dout : std_logic_vector(15 downto 0) := (others => '0');
   signal frame_sdram_fifo_rd_en : std_logic := '0';

 	--Outputs
   signal tdc_frame_fifo_rd_en : std_logic;
   signal frame_sdram_fifo_data_count : std_logic_vector(11 downto 0);
   signal frame_sdram_fifo_dout : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant sys_clk_period : time := 12.5 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: FramePack PORT MAP (
          sys_clk => sys_clk,
          sys_rst_n => sys_rst_n,
          frame_en => frame_en,
          tdc_frame_fifo_almost_empty => tdc_frame_fifo_almost_empty,
          tdc_frame_fifo_rd_en => tdc_frame_fifo_rd_en,
          tdc_frame_fifo_dout => tdc_frame_fifo_dout,
          frame_sdram_fifo_rd_en => frame_sdram_fifo_rd_en,
          frame_sdram_fifo_data_count => frame_sdram_fifo_data_count,
          frame_sdram_fifo_dout => frame_sdram_fifo_dout
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
		tdc_frame_fifo_almost_empty <= '0';
		sys_rst_n <= '0';
		frame_en <= '0';
      wait for 100 ns;	
		sys_rst_n <= '1';
		
      wait for sys_clk_period*10;
		frame_en <= '1';
      -- insert stimulus here 

      wait;
   end process;
	
	fifo_simu:process(sys_clk,sys_rst_n)
	begin
		if(sys_rst_n = '0')then
			tdc_frame_fifo_dout <= (others => '0');
		elsif(sys_clk'event and sys_clk = '1')then
			if(tdc_frame_fifo_rd_en = '1')then
				tdc_frame_fifo_dout <= tdc_frame_fifo_dout + '1';
			end if;
		end if;
	end process;

END;
