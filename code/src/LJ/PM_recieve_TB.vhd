--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:51:31 12/19/2014
-- Design Name:   
-- Module Name:   E:/Work/FPGA/ground_pro_all_DPS_QKD_test/ground_pro_use_PPG/PM_recieve.vhd
-- Project Name:  ground_pro
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: PM_receive
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
 
ENTITY PM_recieve_TB IS
END PM_recieve_TB;
 
ARCHITECTURE behavior OF PM_recieve_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PM_receive
    PORT(
         sys_clk_80M : IN  std_logic;
         sys_rst_n : IN  std_logic;
         dac_finish : IN  std_logic;
         fifo_rst : IN  std_logic;
         Dac_Ena : OUT  std_logic;
         dac_data : OUT  std_logic_vector(11 downto 0);
         POC_ctrl : OUT  std_logic_vector(6 downto 0);
         POC_ctrl_en : OUT  std_logic;
			pm_steady_test : IN std_logic;
			scan_data_store_en : in  STD_LOGIC; 
			pm_data_store_en : in  STD_LOGIC; 
         lut_ram_128_vld : IN  std_logic;
         reg_wr : IN  std_logic;
         reg_wr_addr : IN  std_logic_vector(3 downto 0);
         reg_wr_data : IN  std_logic_vector(15 downto 0);
         apd_fpga_hit : IN  std_logic_vector(1 downto 0);
         lut_ram_rd_addr : OUT  std_logic_vector(9 downto 0);
         lut_ram_rd_data : IN  std_logic_vector(15 downto 0);
         lut_ram_128_addr : IN  std_logic_vector(6 downto 0);
         lut_ram_128_data : OUT  std_logic_vector(11 downto 0);
         alg_data_wr : OUT  std_logic;
         alg_data_wr_data : OUT  std_logic_vector(47 downto 0);
         chopper_ctrl : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal sys_clk_80M : std_logic := '0';
   signal sys_rst_n : std_logic := '0';
   signal fifo_rst : std_logic := '0';
   signal dac_finish : std_logic := '0';
   signal reg_wr : std_logic := '0';
   signal pm_steady_test : std_logic := '0';
   signal lut_ram_128_vld : std_logic := '0';
   signal scan_data_store_en : std_logic := '0';
   signal pm_data_store_en : std_logic := '0';
   signal reg_wr_addr : std_logic_vector(3 downto 0) := (others => '0');
   signal reg_wr_data : std_logic_vector(15 downto 0) := (others => '0');
   signal apd_fpga_hit : std_logic_vector(1 downto 0) := (others => '0');
   signal lut_ram_rd_data : std_logic_vector(15 downto 0) := (others => '0');
   signal lut_ram_128_addr : std_logic_vector(6 downto 0) := (others => '0');
   signal chopper_ctrl : std_logic := '0';

 	--Outputs
   signal Dac_Ena : std_logic;
   signal dac_data : std_logic_vector(11 downto 0);
   signal POC_ctrl : std_logic_vector(6 downto 0);
   signal POC_ctrl_en : std_logic;
   signal lut_ram_rd_addr : std_logic_vector(9 downto 0);
   signal lut_ram_128_data : std_logic_vector(11 downto 0);
   signal alg_data_wr : std_logic;
   signal alg_data_wr_data : std_logic_vector(47 downto 0);
   -- No clocks detected in port list. Replace sys_clk_80M below with 
   -- appropriate port name 
 
   constant sys_clk_80M_period : time := 12.5 ns;
	constant apd_fpga_hit0_period : time := 8 us;
	constant apd_fpga_hit1_period : time := 13 us;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PM_receive PORT MAP (
          sys_clk_80M => sys_clk_80M,
          sys_rst_n => sys_rst_n,
          fifo_rst => fifo_rst,
          lut_ram_128_vld => lut_ram_128_vld,
          dac_finish => dac_finish,
          Dac_Ena => Dac_Ena,
          dac_data => dac_data,
          POC_ctrl => POC_ctrl,
          POC_ctrl_en => POC_ctrl_en,
          reg_wr => reg_wr,
          pm_steady_test => pm_steady_test,
          pm_data_store_en => pm_data_store_en,
          scan_data_store_en => scan_data_store_en,
          reg_wr_addr => reg_wr_addr,
          reg_wr_data => reg_wr_data,
          apd_fpga_hit => apd_fpga_hit,
          lut_ram_rd_addr => lut_ram_rd_addr,
          lut_ram_rd_data => lut_ram_rd_data,
          lut_ram_128_addr => lut_ram_128_addr,
          lut_ram_128_data => lut_ram_128_data,
          alg_data_wr => alg_data_wr,
          alg_data_wr_data => alg_data_wr_data,
          chopper_ctrl => chopper_ctrl
        );

   -- Clock process definitions
   sys_clk_80M_process :process
   begin
		sys_clk_80M <= '0';
		wait for sys_clk_80M_period/2;
		sys_clk_80M <= '1';
		wait for sys_clk_80M_period/2;
   end process;
	
	apd_fpga_hit0: process
	begin
		apd_fpga_hit(0) <= '0';
		wait for apd_fpga_hit0_period/2;
		apd_fpga_hit(0) <= '1';
		wait for apd_fpga_hit0_period/2;
   end process;
	apd_fpga_hit1: process
	begin
		apd_fpga_hit(1) <= '0';
		wait for apd_fpga_hit1_period/2;
		apd_fpga_hit(1) <= '1';
		wait for apd_fpga_hit1_period/2;
   end process;
 
 dac_finish_process :process
   begin
		dac_finish <= '1';
		wait until rising_edge(Dac_Ena);
		dac_finish <= '0';
		wait for 500 ns;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 1 us;	
		sys_rst_n	<= '1';
      wait for sys_clk_80M_period*10;
		wait for 10 us;	
		wait until rising_edge(sys_clk_80m);
		wait for 100 ns ;
		pm_data_store_en	<= '1';
--		
--		wait until rising_edge(sys_clk_80m);
--		pm_steady_test	<= '1';
--		wait for 100 ns ;
		wait for 10 ms;
		wait until rising_edge(sys_clk_80m);
		chopper_ctrl	<= '1';
		
		wait for 10 ms;
		chopper_ctrl	<= '0';
		
		wait for 10 ms;
		wait until rising_edge(sys_clk_80m);
		chopper_ctrl	<= '1';
		
		wait for 10 ms;
		chopper_ctrl	<= '0';
		
		wait for 10 ms;
		wait until rising_edge(sys_clk_80m);
		chopper_ctrl	<= '1';
		
		wait for 10 ms;
		chopper_ctrl	<= '0';
		
		wait for 10 ms;
		wait until rising_edge(sys_clk_80m);
		chopper_ctrl	<= '1';
		
		wait for 10 ms;
		chopper_ctrl	<= '0';

--		pm_steady_test	<= '1';
--		wait for 100 ns ;
--		
--		pm_data_store_en	<= '1';
--		
		pm_steady_test	<= '0';
		wait for 105 ms ;
		wait until rising_edge(sys_clk_80m);
		
		pm_steady_test	<= '1';
		wait for 100 ns ;
		
		pm_data_store_en	<= '1';
		
		pm_steady_test	<= '0';
		wait for 1000 ms ;
		
		wait;
		
		chopper_ctrl	<= '1';
      -- insert stimulus here 
		wait for 1ms ;
		pm_data_store_en	<= '1';
		
		wait for 1ms ;
		chopper_ctrl	<= '0';
		
		wait for 1ms ;
		chopper_ctrl	<= '1';
		wait for 30ms ;
		pm_data_store_en	<= '0';
		wait for 1ms ;
		chopper_ctrl	<= '0';
		
		wait for 1ms ;
		scan_data_store_en	<= '1';
		
		
		wait for 1ms ;
		pm_steady_test	<= '1';
		
		wait for 12.5ns ;
		pm_steady_test	<= '0';

		wait for 1ms ;
		scan_data_store_en	<= '0';
		pm_data_store_en	<= '1';
		wait for 10ms ;
		pm_steady_test	<= '1';
		
		wait for 12.5ns ;
		pm_steady_test	<= '0';
		
		wait for 10ms ;
		pm_steady_test	<= '1';
		
		wait for 12.5ns ;
		pm_steady_test	<= '0';
		
		wait for 10ms ;
		pm_steady_test	<= '1';
		
		wait for 12.5ns ;
		pm_steady_test	<= '0';
		
      wait;
   end process;

END;
