--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:21:25 12/10/2014
-- Design Name:   
-- Module Name:   F:/work/ground_pro_use_PPG-V1/ground_pro_use_PPG/PM_receive_th.vhd
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
 
ENTITY PM_receive_th IS
END PM_receive_th;
 
ARCHITECTURE behavior OF PM_receive_th IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PM_receive
    PORT(
         sys_clk_80M : IN  std_logic;
         sys_rst_n : IN  std_logic;
         Dac_Sclk : OUT  std_logic;
         Dac_Csn : OUT  std_logic;
         Dac_Din : OUT  std_logic;
         POC_ctrl : OUT  std_logic_vector(7 downto 0);
         POC_ctrl_en : OUT  std_logic;
         reg_wr : IN  std_logic;
         reg_wr_addr : IN  std_logic_vector(3 downto 0);
         reg_wr_data : IN  std_logic_vector(11 downto 0);
         apd_fpga_hit : IN  std_logic_vector(1 downto 0);
         lut_addr : OUT  std_logic_vector(9 downto 0);
         lut_data : IN  std_logic_vector(15 downto 0);
         alg_data_wr : OUT  std_logic;
         alg_data_wr_data : OUT  std_logic_vector(31 downto 0);
         chopper_ctrl : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal sys_clk_80M : std_logic := '0';
   signal sys_rst_n : std_logic := '0';
   signal reg_wr : std_logic := '0';
   signal reg_wr_addr : std_logic_vector(3 downto 0) := (others => '0');
   signal reg_wr_data : std_logic_vector(11 downto 0) := (others => '0');
   signal apd_fpga_hit : std_logic_vector(1 downto 0) := (others => '0');
   signal lut_data : std_logic_vector(15 downto 0) := (others => '0');
   signal chopper_ctrl : std_logic := '0';

 	--Outputs
   signal Dac_Sclk : std_logic;
   signal Dac_Csn : std_logic;
   signal Dac_Din : std_logic;
   signal POC_ctrl : std_logic_vector(7 downto 0);
   signal POC_ctrl_en : std_logic;
   signal lut_addr : std_logic_vector(9 downto 0);
   signal alg_data_wr : std_logic;
   signal alg_data_wr_data : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant sys_clk_period : time := 12.5 ns;
	constant apd_fpga_hit0_period : time := 1500ns;
	constant apd_fpga_hit1_period : time := 2500ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PM_receive PORT MAP (
          sys_clk_80M => sys_clk_80M,
          sys_rst_n => sys_rst_n,
			 
          Dac_Sclk => Dac_Sclk,
          Dac_Csn => Dac_Csn,
          Dac_Din => Dac_Din,
			 
          POC_ctrl => POC_ctrl,
          POC_ctrl_en => POC_ctrl_en,
			 
          reg_wr => reg_wr,
          reg_wr_addr => reg_wr_addr,
          reg_wr_data => reg_wr_data,
			 
          apd_fpga_hit => apd_fpga_hit,
			 
          lut_addr => lut_addr,
          lut_data => lut_data,
			 
          alg_data_wr => alg_data_wr,
          alg_data_wr_data => alg_data_wr_data,
			 
          chopper_ctrl => chopper_ctrl
        );

   -- Clock process definitions
   sys_clk_process :process
   begin
		sys_clk_80M <= '0';
		wait for sys_clk_period/2;
		sys_clk_80M <= '1';
		wait for sys_clk_period/2;
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

   -- Stimulus process
   stim_proc: process
   begin		
		sys_rst_n	<=	'1';
		wait for 100 ns;
		sys_rst_n	<=	'0';
		wait for 100 ns;	
		sys_rst_n	<=	'1';
		chopper_ctrl <= '0';
		wait for sys_clk_period*10;
		
	 wait until rising_edge(sys_clk_80M);
	 reg_wr        <= '1';
	 reg_wr_addr	<=	"0001";
	 reg_wr_data	<=	X"001";
	 wait until rising_edge(sys_clk_80M);
	 reg_wr        <= '1';
	 reg_wr_addr	<=	"0010";
	 reg_wr_data	<=	X"002";
	 wait until rising_edge(sys_clk_80M);
	 reg_wr        <= '1';
	 reg_wr_addr	<=	"0011";
	 reg_wr_data	<=	X"003";
	 wait until rising_edge(sys_clk_80M);
	 reg_wr        <= '1';
	 reg_wr_addr	<=	"0100";
	 reg_wr_data	<=	X"004";
	 
	 wait for sys_clk_period*5;
	 wait until falling_edge(sys_clk_80M);
	 
	 chopper_ctrl <= '1';
	 
    wait;	 
   
   end process;

END;
