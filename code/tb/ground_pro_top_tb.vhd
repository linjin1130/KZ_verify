--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:29:14 09/03/2013
-- Design Name:   
-- Module Name:   F:/13/GroundSystem/code/V2/ground_pro_all/ground_pro_top_tb.vhd
-- Project Name:  ground_pro
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ground_pro_top
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
 
ENTITY ground_pro_top_tb IS
END ground_pro_top_tb;
 
ARCHITECTURE behavior OF ground_pro_top_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ground_pro_top
    PORT(
         clk_40M_I : IN  std_logic;
         clk_40M_IB : IN  std_logic;
         reset_in_n : IN  std_logic;
         cpld_fpga_clk : IN  std_logic;
         cpld_fpga_data : INOUT  std_logic_vector(31 downto 0);
         cpld_fpga_addr : IN  std_logic_vector(7 downto 0);
         cpld_fpga_sglrd : IN  std_logic;
         cpld_fpga_sglwr : IN  std_logic;
         cpld_fpga_brtrd_req : IN  std_logic;
         fpga_cpld_burst_act : OUT  std_logic;
         fpga_cpld_burst_en : OUT  std_logic;
         fpga_dac_data : INOUT  std_logic_vector(7 downto 0);
         fpga_dac_addr : OUT  std_logic_vector(3 downto 0);
         fpga_dac_rs_n : OUT  std_logic;
         fpga_dac_cs_n : OUT  std_logic;
         fpga_dac_rw_n : OUT  std_logic;
         fpga_dac_ld_n : OUT  std_logic;
         fpga_dac_en_n : OUT  std_logic;
         apd_fpga_hit_p : IN  std_logic_vector(3 downto 0);
         apd_fpga_hit_n : IN  std_logic_vector(3 downto 0);
        
         vauxp0 : IN  std_logic;
         vauxn0 : IN  std_logic;
         vauxp1 : IN  std_logic;
         vauxn1 : IN  std_logic;
         vauxp8 : IN  std_logic;
         vauxn8 : IN  std_logic;
         vauxp9 : IN  std_logic;
         vauxn9 : IN  std_logic;
         vauxp10 : IN  std_logic;
         vauxn10 : IN  std_logic;
         vauxp11 : IN  std_logic;
         vauxn11 : IN  std_logic;
         vauxp12 : IN  std_logic;
         vauxn12 : IN  std_logic;
         vauxp13 : IN  std_logic;
         vauxn13 : IN  std_logic;
         vauxp14 : IN  std_logic;
         vauxn14 : IN  std_logic;
         vauxp15 : IN  std_logic;
         vauxn15 : IN  std_logic;
         vp_in : IN  std_logic;
         vn_in : IN  std_logic;
         Tp : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    	
	COMPONENT mt48lc16m16a2
	PORT(
		Addr : IN std_logic_vector(12 downto 0);
		Ba : IN std_logic_vector(1 downto 0);
		Clk : IN std_logic;
		Cke : IN std_logic;
		Cs_n : IN std_logic;
		Ras_n : IN std_logic;
		Cas_n : IN std_logic;
		We_n : IN std_logic;
		Dqm : IN std_logic_vector(1 downto 0);       
		Dq : INOUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	
   --Inputs
   signal clk_40M_I : std_logic := '0';
   signal clk_40M_IB : std_logic := '0';
   signal reset_in_n : std_logic := '0';
   signal sys_rst_n : std_logic := '0';
   signal cpld_fpga_clk : std_logic := '0';
   signal cpld_fpga_addr : std_logic_vector(7 downto 0) := (others => '0');
   signal cpld_fpga_sglrd : std_logic := '0';
   signal cpld_fpga_sglwr : std_logic := '0';
   signal cpld_fpga_brtrd_req : std_logic := '0';
   signal apd_fpga_hit_p : std_logic_vector(15 downto 0) := (others => '0');
   signal apd_fpga_hit_n : std_logic_vector(15 downto 0) := (others => '0');
   signal vauxp0 : std_logic := '0';
   signal vauxn0 : std_logic := '0';
   signal vauxp1 : std_logic := '0';
   signal vauxn1 : std_logic := '0';
   signal vauxp8 : std_logic := '0';
   signal vauxn8 : std_logic := '0';
   signal vauxp9 : std_logic := '0';
   signal vauxn9 : std_logic := '0';
   signal vauxp10 : std_logic := '0';
   signal vauxn10 : std_logic := '0';
   signal vauxp11 : std_logic := '0';
   signal vauxn11 : std_logic := '0';
   signal vauxp12 : std_logic := '0';
   signal vauxn12 : std_logic := '0';
   signal vauxp13 : std_logic := '0';
   signal vauxn13 : std_logic := '0';
   signal vauxp14 : std_logic := '0';
   signal vauxn14 : std_logic := '0';
   signal vauxp15 : std_logic := '0';
   signal vauxn15 : std_logic := '0';
   signal vp_in : std_logic := '0';
   signal vn_in : std_logic := '0';

	--BiDirs
   signal cpld_fpga_data : std_logic_vector(31 downto 0);
   signal fpga_dac_data : std_logic_vector(7 downto 0);
   signal tdc_sdram_dq : std_logic_vector(15 downto 0);

 	--Outputs
   signal fpga_cpld_burst_act : std_logic;
   signal fpga_cpld_burst_en : std_logic;
   signal fpga_dac_addr : std_logic_vector(3 downto 0);
   signal fpga_dac_rs_n : std_logic;
   signal fpga_dac_cs_n : std_logic;
   signal fpga_dac_rw_n : std_logic;
   signal fpga_dac_ld_n : std_logic;
   signal fpga_dac_en_n : std_logic;
   signal tdc_sdram_dqml : std_logic;
   signal tdc_sdram_dqmh : std_logic;
   signal tdc_sdram_we_n : std_logic;
   signal tdc_sdram_cas_n : std_logic;
   signal tdc_sdram_ras_n : std_logic;
   signal tdc_sdram_cs_n : std_logic;
   signal tdc_sdram_ba : std_logic_vector(1 downto 0);
   signal tdc_sdram_a : std_logic_vector(12 downto 0);
   signal tdc_sdram_cke : std_logic;
   signal tdc_sdram_clk : std_logic;
   signal Tp : std_logic_vector(7 downto 0);
	
   signal Dqm : std_logic_vector(1 downto 0);

   -- Clock period definitions
   constant clk_40M_I_period : time := 25 ns;
--   constant clk_40M_IB_period : time := 10 ns;
   constant cpld_fpga_clk_period : time := 33 ns;
--   constant tdc_sdram_clk_period : time := 10 ns;
 
BEGIN

Dqm(0) <= tdc_sdram_dqml;
Dqm(1) <= tdc_sdram_dqmh;
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ground_pro_top PORT MAP (
          clk_40M_I => clk_40M_I,
          clk_40M_IB => clk_40M_IB,
          reset_in_n => sys_rst_n,
          cpld_fpga_clk => cpld_fpga_clk,
          cpld_fpga_data => cpld_fpga_data,
          cpld_fpga_addr => cpld_fpga_addr,
          cpld_fpga_sglrd => cpld_fpga_sglrd,
          cpld_fpga_sglwr => cpld_fpga_sglwr,
          cpld_fpga_brtrd_req => cpld_fpga_brtrd_req,
          fpga_cpld_burst_act => fpga_cpld_burst_act,
          fpga_cpld_burst_en => fpga_cpld_burst_en,
          fpga_dac_data => fpga_dac_data,
          fpga_dac_addr => fpga_dac_addr,
          fpga_dac_rs_n => fpga_dac_rs_n,
          fpga_dac_cs_n => fpga_dac_cs_n,
          fpga_dac_rw_n => fpga_dac_rw_n,
          fpga_dac_ld_n => fpga_dac_ld_n,
          fpga_dac_en_n => fpga_dac_en_n,
          apd_fpga_hit_p => apd_fpga_hit_p,
          apd_fpga_hit_n => apd_fpga_hit_n,
          tdc_sdram_dq => tdc_sdram_dq,
          tdc_sdram_dqml => tdc_sdram_dqml,
          tdc_sdram_dqmh => tdc_sdram_dqmh,
          tdc_sdram_we_n => tdc_sdram_we_n,
          tdc_sdram_cas_n => tdc_sdram_cas_n,
          tdc_sdram_ras_n => tdc_sdram_ras_n,
          tdc_sdram_cs_n => tdc_sdram_cs_n,
          tdc_sdram_ba => tdc_sdram_ba,
          tdc_sdram_a => tdc_sdram_a,
          tdc_sdram_cke => tdc_sdram_cke,
          tdc_sdram_clk => tdc_sdram_clk,
          vauxp0 => vauxp0,
          vauxn0 => vauxn0,
          vauxp1 => vauxp1,
          vauxn1 => vauxn1,
          vauxp8 => vauxp8,
          vauxn8 => vauxn8,
          vauxp9 => vauxp9,
          vauxn9 => vauxn9,
          vauxp10 => vauxp10,
          vauxn10 => vauxn10,
          vauxp11 => vauxp11,
          vauxn11 => vauxn11,
          vauxp12 => vauxp12,
          vauxn12 => vauxn12,
          vauxp13 => vauxp13,
          vauxn13 => vauxn13,
          vauxp14 => vauxp14,
          vauxn14 => vauxn14,
          vauxp15 => vauxp15,
          vauxn15 => vauxn15,
          vp_in => vp_in,
          vn_in => vn_in,
          Tp => Tp
        );
		  
		  Inst_mt48lc16m16a2: mt48lc16m16a2 PORT MAP(
		Dq => tdc_sdram_dq,
		Addr => tdc_sdram_a,
		Ba => tdc_sdram_ba,
		Clk => tdc_sdram_clk,
		Cke => tdc_sdram_cke,
		Cs_n => tdc_sdram_cs_n,
		Ras_n => tdc_sdram_ras_n,
		Cas_n => tdc_sdram_cas_n,
		We_n => tdc_sdram_we_n,
		Dqm => Dqm
	);

   -- Clock process definitions
   clk_40M_I_process :process
   begin
		clk_40M_I <= '0';
		wait for clk_40M_I_period/2;
		clk_40M_I <= '1';
		wait for clk_40M_I_period/2;
   end process;
 
 clk_40M_IB <= not clk_40M_I;
 
    apd_fpga_hit_p_1_process :process
   begin
		apd_fpga_hit_p(1) <= '0';
		wait for 100 ns/2;
		apd_fpga_hit_p(1) <= '1';
		wait for 100 ns/2;
   end process;
  apd_fpga_hit_n(1) <= not apd_fpga_hit_p(1);
  apd_fpga_hit_p(0) <= apd_fpga_hit_p(1);
  apd_fpga_hit_n(0) <= not apd_fpga_hit_p(1);
  
  
 
   cpld_fpga_clk_process :process
   begin
		cpld_fpga_clk <= '0';
		wait for cpld_fpga_clk_period/2;
		cpld_fpga_clk <= '1';
		wait for cpld_fpga_clk_period/2;
   end process;
 
--   tdc_sdram_clk_process :process
--   begin
--		tdc_sdram_clk <= '0';
--		wait for tdc_sdram_clk_period/2;
--		tdc_sdram_clk <= '1';
--		wait for tdc_sdram_clk_period/2;
--   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		sys_rst_n <= '0';
      wait for 2 us;	
		sys_rst_n <= '1';
      wait for clk_40M_I_period*10;
		
      -- insert stimulus here 

      wait;
   end process;
	
	process
   begin
		cpld_fpga_sglwr	<=	'0';
		wait until (sys_rst_n = '1');
--		for i in 0 to 7 loop
		wait for 120 us;
		wait until rising_edge(cpld_fpga_clk);
		
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"10";
		cpld_fpga_data <= x"0000000f";
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
		wait;
   end process;

END;
