--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:06:54 10/29/2014
-- Design Name:   
-- Module Name:   E:/Work/FPGA/ground_pro_all_outinLVDSCLK-160MHZdcm160Mhz_qtel_1.2_dual_test/ground_pro_all_outinLVDSCLK/ground_pro_top_tb_lj.vhd
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

use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY ground_pro_top_tb_lj IS
END ground_pro_top_tb_lj;
 
ARCHITECTURE behavior OF ground_pro_top_tb_lj IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ground_pro_top
    PORT(
         clk_40M_I : IN  std_logic;
         clk_40M_IB : IN  std_logic;
         GPS_pulse_in : IN  std_logic;
         cpld_fpga_clk : IN  std_logic;
			ext_clk_I : IN  std_logic;
         ext_clk_IB : IN  std_logic;
         syn_light_ext : IN  std_logic;
         cpld_fpga_data : INOUT  std_logic_vector(31 downto 0);
         cpld_fpga_addr : IN  std_logic_vector(7 downto 0);
         cpld_fpga_sglrd : IN  std_logic;
         cpld_fpga_sglwr : IN  std_logic;
         cpld_fpga_brtrd_req : IN  std_logic;
         fpga_cpld_burst_act : OUT  std_logic;
         fpga_cpld_burst_en : OUT  std_logic;
         fpga_cpld_rst_n : OUT  std_logic;
--         fpga_dac_data : INOUT  std_logic_vector(7 downto 0);
--         fpga_dac_addr : OUT  std_logic_vector(3 downto 0);
--         fpga_dac_rs_n : OUT  std_logic;
--         fpga_dac_cs_n : OUT  std_logic;
--         fpga_dac_rw_n : OUT  std_logic;
--         fpga_dac_ld_n : OUT  std_logic;
--         fpga_dac_en_n : OUT  std_logic;
         apd_fpga_hit_p : IN  std_logic_vector(3 downto 0);
         apd_fpga_hit_n : IN  std_logic_vector(3 downto 0);
         Rnd_Gen_WNG_Data : IN  std_logic_vector(3 downto 0);
         Rnd_Gen_WNG_Clk : OUT  std_logic_vector(3 downto 0);
         Rnd_Gen_WNG_Oe_n : OUT  std_logic_vector(3 downto 0);
         chopper_ctrl					: out  STD_LOGIC;
		  syn_light						: out  STD_LOGIC;
			
			SERIAL_OUT_p			:	out std_logic_vector(2 downto 0);--serial output
			SERIAL_OUT_n			:	out std_logic_vector(2 downto 0);--serial output
         Tp : OUT  std_logic_vector(8 downto 0)
        );
    END COMPONENT;
    
	COMPONENT rdn_gen_stimulate
	PORT(
		Rnd_Gen_WNG_Clk : IN std_logic;
		Rnd_Gen_WNG_Rst : IN std_logic;
		Rnd_Gen_WNG_Oe_n : IN std_logic;          
		Rnd_Gen_WNG_Data : OUT std_logic
		);
	END COMPONENT;
	signal rst_rnd : std_logic_vector(4-1 downto 0) := x"F";
   --Inputs
   signal clk_40M_I : std_logic := '0';
   signal clk_40M_IB : std_logic := '0';
	signal ext_clk_I : std_logic := '0';
   signal ext_clk_IB : std_logic := '0';
	signal syn_light_ext : std_logic := '0';
   signal reset_in_n : std_logic := '0';
   signal GPS_pulse_in : std_logic := '0';
   signal cpld_fpga_clk : std_logic := '0';
   signal cpld_fpga_addr : std_logic_vector(7 downto 0) := (others => '0');
   signal cpld_fpga_sglrd : std_logic := '0';
   signal cpld_fpga_sglwr : std_logic := '0';
   signal cpld_fpga_brtrd_req : std_logic := '0';
   signal apd_fpga_hit_p : std_logic_vector(3 downto 0) := (others => '0');
   signal apd_fpga_hit_n : std_logic_vector(3 downto 0) := (others => '0');
   signal Rnd_Gen_WNG_Data : std_logic_vector(3 downto 0) := (others => '0');

	--BiDirs
   signal cpld_fpga_data : std_logic_vector(31 downto 0);
--   signal fpga_dac_data : std_logic_vector(7 downto 0);

 	--Outputs
   signal fpga_cpld_burst_act : std_logic;
   signal fpga_cpld_burst_en : std_logic;
   signal fpga_cpld_rst_n : std_logic;
--   signal fpga_dac_addr : std_logic_vector(3 downto 0);
--   signal fpga_dac_rs_n : std_logic;
--   signal fpga_dac_cs_n : std_logic;
--   signal fpga_dac_rw_n : std_logic;
--   signal fpga_dac_ld_n : std_logic;
--   signal fpga_dac_en_n : std_logic;
   signal Rnd_Gen_WNG_Clk : std_logic_vector(3 downto 0);
   signal Rnd_Gen_WNG_Oe_n : std_logic_vector(3 downto 0);
   signal chopper_ctrl					:  STD_LOGIC;
   signal syn_light_ext_en				:  STD_LOGIC := '0';
	signal syn_light						:  STD_LOGIC;
	signal apd_en2						:  STD_LOGIC;
	signal apd_en3						:  STD_LOGIC;
	signal apd_en_clk						:  STD_LOGIC;
	
	signal lut_wr_en						:  STD_LOGIC;
	signal lut_wr_addr					:  STD_LOGIC_vector(9 downto 0) := (others => '0');
	signal lut_wr_data					:  STD_LOGIC_vector(15 downto 0) := x"0000";
	
--	signal gps_cnt_period					:  STD_LOGIC_vector(15 downto 0) := x"27100";
--	signal chopper_enable_cnt				:  STD_LOGIC_vector(15 downto 0) := x"00400";
--	signal chopper_disable_cnt				:  STD_LOGIC_vector(15 downto 0) := x"00400";
	
	signal	SERIAL_OUT_p			:	 std_logic_vector(2 downto 0);--serial output
	signal	SERIAL_OUT_n			:	 std_logic_vector(2 downto 0);--serial output
   signal Tp : std_logic_vector(8 downto 0);

   -- Clock period definitions
    -- Clock period definitions
   constant clk_40M_I_period : time := 12.5 ns;
--   constant clk_40M_IB_period : time := 10 ns;
   constant cpld_fpga_clk_period : time := 33 ns;
--   constant tdc_sdram_clk_period : time := 10 ns;
	constant clk_125M_I_period : time := 8 ns;
	
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ground_pro_top PORT MAP (
          clk_40M_I => clk_40M_I,
          clk_40M_IB => clk_40M_IB,
			 ext_clk_I => ext_clk_I,
          ext_clk_IB => ext_clk_IB,
			 syn_light_ext => syn_light_ext,
          GPS_pulse_in => GPS_pulse_in,
          cpld_fpga_clk => cpld_fpga_clk,
          cpld_fpga_data => cpld_fpga_data,
          cpld_fpga_addr => cpld_fpga_addr,
          cpld_fpga_sglrd => cpld_fpga_sglrd,
          cpld_fpga_sglwr => cpld_fpga_sglwr,
          cpld_fpga_brtrd_req => cpld_fpga_brtrd_req,
          fpga_cpld_burst_act => fpga_cpld_burst_act,
          fpga_cpld_burst_en => fpga_cpld_burst_en,
          fpga_cpld_rst_n => fpga_cpld_rst_n,
--          fpga_dac_data => fpga_dac_data,
--          fpga_dac_addr => fpga_dac_addr,
--          fpga_dac_rs_n => fpga_dac_rs_n,
--          fpga_dac_cs_n => fpga_dac_cs_n,
--          fpga_dac_rw_n => fpga_dac_rw_n,
--          fpga_dac_ld_n => fpga_dac_ld_n,
--          fpga_dac_en_n => fpga_dac_en_n,
          apd_fpga_hit_p => apd_fpga_hit_p,
          apd_fpga_hit_n => apd_fpga_hit_n,
          Rnd_Gen_WNG_Data => Rnd_Gen_WNG_Data,
          Rnd_Gen_WNG_Clk => Rnd_Gen_WNG_Clk,
          Rnd_Gen_WNG_Oe_n => Rnd_Gen_WNG_Oe_n,
          chopper_ctrl => chopper_ctrl,
          syn_light => syn_light,
          SERIAL_OUT_p => SERIAL_OUT_p,
          SERIAL_OUT_n => SERIAL_OUT_n,
          Tp => Tp
        );
		  
rdn_gen : for i in 0 to 4-1 generate
   Inst_rdn_gen_stimulate: rdn_gen_stimulate PORT MAP(
		Rnd_Gen_WNG_Rst => rst_rnd(i),
		Rnd_Gen_WNG_Clk => Rnd_Gen_WNG_Clk(i),
		Rnd_Gen_WNG_Oe_n => Rnd_Gen_WNG_Oe_n(i),
		Rnd_Gen_WNG_Data => Rnd_Gen_WNG_Data(i)
	);
  end generate rdn_gen;

  rst_rnd(0)<= '0' after 3 us;
  rst_rnd(1)<= '0' after 4 us;
  rst_rnd(2)<= '0' after 5 us;
  rst_rnd(3)<= '0' after 2 us;
   -- Clock process definitions
   clk_40M_I_process :process
   begin
		clk_40M_I <= '0';
		wait for clk_40M_I_period/2;
		clk_40M_I <= '1';
		wait for clk_40M_I_period/2;
   end process;
 
 clk_40M_IB <= not clk_40M_I;
	apd2_gen_stimulate: rdn_gen_stimulate PORT MAP(
		Rnd_Gen_WNG_Rst => rst_rnd(0),
		Rnd_Gen_WNG_Clk => apd_en_clk,
		Rnd_Gen_WNG_Oe_n => '0',
		Rnd_Gen_WNG_Data => apd_en2
	);
	apd3_gen_stimulate: rdn_gen_stimulate PORT MAP(
		Rnd_Gen_WNG_Rst => rst_rnd(0),
		Rnd_Gen_WNG_Clk => apd_en_clk,
		Rnd_Gen_WNG_Oe_n => '0',
		Rnd_Gen_WNG_Data => apd_en3
	);
    apd_fpga_hit_p_1_process :process
   begin
		wait for 10 us;
		loop
		apd_fpga_hit_p(1) <= '0';
		wait for 100 ns/2;
		apd_fpga_hit_p(1) <= apd_en3;
		wait for 100 ns/2;
		end loop;
   end process;
  apd_fpga_hit_n(1) <= not apd_fpga_hit_p(1);
  
  gps_process :process
   begin
		GPS_pulse_in <= '0';
		wait for 100 us;
		GPS_pulse_in <= '1';
		wait for 200 us;
		GPS_pulse_in <= '0';
		wait for 200 us;
		GPS_pulse_in <= '1';
		wait for 200 us;
		loop
			GPS_pulse_in <= '0';
			wait for 200 us;
			GPS_pulse_in <= '1';
			wait for 200 us;
		end loop;
   end process;
	apd_en_clk_process :process
   begin
		apd_en_clk <= '0';
		wait for 1 us;
		apd_en_clk <= '1';
		wait for 1 us;
   end process;
	apd_fpga_hit_p_0_process :process
   begin
		apd_fpga_hit_p(0) <= '0';
		wait for 80 ns/2;
		apd_fpga_hit_p(0) <= apd_en2;
		wait for 80 ns/2;
   end process;
-- GPS_pulse_in <= apd_fpga_hit_p(0);
  apd_fpga_hit_n(0) <= not apd_fpga_hit_p(0);
  
  apd_fpga_hit_p(2) <= apd_fpga_hit_p(0);
  apd_fpga_hit_n(2) <= apd_fpga_hit_n(0);
  
  apd_fpga_hit_p(3) <= apd_fpga_hit_p(1);
  apd_fpga_hit_n(3) <= apd_fpga_hit_n(1);
  
 syn_light_process :process
   begin
		wait for 200 us;
		loop
		syn_light_ext <= '0';
		wait for 99990 ns;
		syn_light_ext <= syn_light_ext_en;
		wait for 10 ns;
		end loop;
   end process;
	
	process
   begin
		wait for 525 us;---chopper first change high
		loop
		syn_light_ext_en <= '0';
		wait for 4925 us;--(5450-525)
		syn_light_ext_en <= '1';
		wait for 1800 us; --(7290-5450)
		syn_light_ext_en <= '0';
		wait for 45 us;-- 7295 - 525 
		end loop;
   end process;
	
--   lut_wr_process :process
--   begin
--		wait for 1 us;
--		
--		while (lut_wr_data < 1024) loop 
--			lut_wr_en 	<= '1';
--			wait for cpld_fpga_clk_period;
--			lut_wr_en <= '0';
--			lut_wr_data <= lut_wr_data + 1;
--			wait for cpld_fpga_clk_period * 3;--1024*3
--		end loop;
--		wait;
--   end process;
	
   cpld_fpga_clk_process :process
   begin
		cpld_fpga_clk <= '0';
		wait for cpld_fpga_clk_period/2;
		cpld_fpga_clk <= '1';
		wait for cpld_fpga_clk_period/2;
   end process;
 ext80M_clk_process :process
   begin
		ext_clk_I <= '0';
		wait for clk_125M_I_period/2;
		ext_clk_I <= '1';
		wait for clk_125M_I_period/2;
   end process;
	ext_clk_IB <= not ext_clk_I;
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
		reset_in_n <= '0';
      wait for 2 us;	
		reset_in_n <= '1';
      wait for clk_40M_I_period*10;
		
      -- insert stimulus here 

      wait;
   end process;

	process
   begin
		cpld_fpga_sglwr	<=	'0';
		wait for 200 ns;
		wait until (reset_in_n = '1');
		
		wait for 100 us;
		
		wait until rising_edge(cpld_fpga_clk);
		
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"A0";
--		cpld_fpga_data <= x"00000E00";
		cpld_fpga_data <= x"00000E69";
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
		

		wait for 200 ns;
		wait until rising_edge(cpld_fpga_clk);
--		
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"A5";
		cpld_fpga_data <= x"00030C00";--send enable 
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
		
		wait for 200 ns;
		wait until rising_edge(cpld_fpga_clk);
--		
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"A6";
		cpld_fpga_data <= x"00041000";--send disable
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
		
		wait for 200 ns;
		wait until rising_edge(cpld_fpga_clk);
		
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"A7";
		cpld_fpga_data <= x"00000400";--chopper enable
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
		
		wait for 200 ns;
		wait until rising_edge(cpld_fpga_clk);
		
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"A8";
		cpld_fpga_data <= x"00030800";--chopper disable
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
--		
		wait for 200 ns;
		wait until rising_edge(cpld_fpga_clk);
--		
		--设置实验运行周期计数
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"A3";
		cpld_fpga_data <= x"00041100";
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
--		
--		wait for 200 ns;
--		wait until rising_edge(cpld_fpga_clk);
--		
--		cpld_fpga_sglwr	<=	'1';
--		cpld_fpga_addr	<=	x"A9";
--		cpld_fpga_data <= x"C0000100";
--		wait for cpld_fpga_clk_period;
--		cpld_fpga_sglwr	<=	'0';
--		wait for cpld_fpga_clk_period*3;
--		
--		wait for 200 ns;
--		wait until rising_edge(cpld_fpga_clk);
--		
--		cpld_fpga_sglwr	<=	'1';
--		cpld_fpga_addr	<=	x"A9";
--		cpld_fpga_data <= x"00200100";
--		wait for cpld_fpga_clk_period;
--		cpld_fpga_sglwr	<=	'0';
--		wait for cpld_fpga_clk_period*3;
--		
		wait for 10 us;
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"A2";
		cpld_fpga_data <= x"00000000";--"00" & "00110" & "00011" & "00000" & "00000" & "00011" & "10110";
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
--		
--		wait for 1 us;
--		wait until rising_edge(cpld_fpga_clk);
--		
--		cpld_fpga_sglwr	<=	'1';
--		cpld_fpga_addr	<=	x"A4";
--		cpld_fpga_data <= x"00008040";
--		wait for cpld_fpga_clk_period;
--		cpld_fpga_sglwr	<=	'0';
--		wait for cpld_fpga_clk_period*3;
--		
--		wait for 1 us;
--		wait until rising_edge(cpld_fpga_clk);
		
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"13";
		cpld_fpga_data <= x"FFFFFFFF";
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
		
		wait for 1 us;
		wait until rising_edge(cpld_fpga_clk);
		
--		cpld_fpga_sglwr	<=	'1';
--		cpld_fpga_addr	<=	x"10";
--		cpld_fpga_data <= x"000000F0";
--		wait for cpld_fpga_clk_period;
--		cpld_fpga_sglwr	<=	'0';
--		wait for cpld_fpga_clk_period*3;
--		
--		wait for 1000 us;---must wait
--		wait until rising_edge(cpld_fpga_clk);
		
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"10";
		cpld_fpga_data <= x"0000000f";
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
		
		wait for 100 us;
		wait until rising_edge(cpld_fpga_clk);
		
		wait;
		wait for 1 us;
		wait until rising_edge(cpld_fpga_clk);
		cpld_fpga_sglrd	<=	'1';
		cpld_fpga_addr	<=	x"A0";
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglrd	<=	'0';
		wait for cpld_fpga_clk_period*3;
		
		wait for 1 us;
		wait until rising_edge(cpld_fpga_clk);
		cpld_fpga_sglrd	<=	'1';
		cpld_fpga_addr	<=	x"A1";
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglrd	<=	'0';
		wait for cpld_fpga_clk_period*3;
		
		wait for 1 us;
		wait until rising_edge(cpld_fpga_clk);
		cpld_fpga_sglrd	<=	'1';
		cpld_fpga_addr	<=	x"A2";
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglrd	<=	'0';
		wait for cpld_fpga_clk_period*3;
		
		wait for 1 us;
		wait until rising_edge(cpld_fpga_clk);
		cpld_fpga_sglrd	<=	'1';
		cpld_fpga_addr	<=	x"A3";
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglrd	<=	'0';
		wait for cpld_fpga_clk_period*3;
		
		wait for 1 us;
		wait until rising_edge(cpld_fpga_clk);
		cpld_fpga_sglrd	<=	'1';
		cpld_fpga_addr	<=	x"A4";
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglrd	<=	'0';
		wait for cpld_fpga_clk_period*3;
		
		wait;
		wait for 1000 us;
		wait until rising_edge(cpld_fpga_clk);
		
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"10";
		cpld_fpga_data <= x"000000F0";
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
		
		wait for 1001 us;---must wait
		wait until rising_edge(cpld_fpga_clk);
		
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"10";
		cpld_fpga_data <= x"0000000F";
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
		
		wait for 1000 us;
		wait until rising_edge(cpld_fpga_clk);
		
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"10";
		cpld_fpga_data <= x"000000F0";
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
		
		wait for 1001 us;---must wait
		wait until rising_edge(cpld_fpga_clk);
		
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"10";
		cpld_fpga_data <= x"0000000F";
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
		
		wait for 3000 us;
		wait until rising_edge(cpld_fpga_clk);
		
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"A0";
		cpld_fpga_data <= x"00000069";--Bob work
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
		wait;
   end process;

END;
