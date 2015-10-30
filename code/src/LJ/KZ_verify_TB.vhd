--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:41:30 03/01/2015
-- Design Name:   
-- Module Name:   E:/Work/FPGA/KZ_verify/ground_pro_use_PPG_300m_300m/KZ_verify_TB.vhd
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
 
ENTITY KZ_verify_TB IS
END KZ_verify_TB;
 
ARCHITECTURE behavior OF KZ_verify_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ground_pro_top
    PORT(
         clk_40M_I : IN  std_logic;
         clk_40M_IB : IN  std_logic;
         ext_clk_I : IN  std_logic;
         ext_clk_IB : IN  std_logic;
         cpld_fpga_clk : IN  std_logic;
         cpld_fpga_data : INOUT  std_logic_vector(31 downto 0);
         cpld_fpga_addr : IN  std_logic_vector(7 downto 0);
         cpld_fpga_sglrd : IN  std_logic;
         cpld_fpga_sglwr : IN  std_logic;
         cpld_fpga_brtrd_req : IN  std_logic;
         fpga_cpld_burst_act : OUT  std_logic;
         fpga_cpld_burst_en : OUT  std_logic;
         fpga_cpld_rst_n : OUT  std_logic;
         LD_pulse_in_p : IN  std_logic_vector(19 downto 0);
         LD_pulse_in_n : IN  std_logic_vector(19 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk_40M_I : std_logic := '0';
   signal clk_40M_IB : std_logic := '0';
   signal ext_clk_I : std_logic := '0';
   signal ext_clk_IB : std_logic := '0';
   signal cpld_fpga_clk : std_logic := '0';
   signal cpld_fpga_addr : std_logic_vector(7 downto 0) := (others => '0');
   signal cpld_fpga_sglrd : std_logic := '0';
   signal cpld_fpga_sglwr : std_logic := '0';
   signal cpld_fpga_brtrd_req : std_logic := '0';
   signal ram_wr_enable : std_logic := '0';
   signal LD_pulse_in_p : std_logic_vector(19 downto 0) := (others => '1');
   signal LD_pulse_in_n : std_logic_vector(19 downto 0) := (others => '0');
   signal LD_pulse_cnt		: std_logic_vector(9 downto 0) := (others => '0');
   signal wr_ram_cnt		: std_logic_vector(31 downto 0) := x"00000000";
   signal wr_ram_en	: std_logic:='0';
   signal wr_ram_1	: std_logic:='0';
   signal en_error	: std_logic:='0';

	--BiDirs
   signal cpld_fpga_data : std_logic_vector(31 downto 0);

 	--Outputs
   signal fpga_cpld_burst_act : std_logic;
   signal fpga_cpld_burst_en : std_logic;
   signal fpga_cpld_rst_n : std_logic;

   -- Clock period definitions
	    -- Clock period definitions
   constant clk_40M_I_period : time := 6.25 ns;
--   constant clk_40M_IB_period : time := 10 ns;
   constant cpld_fpga_clk_period : time := 33 ns;
	
   constant LD_pulse_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ground_pro_top PORT MAP (
          clk_40M_I => clk_40M_I,
          clk_40M_IB => clk_40M_IB,
          ext_clk_I => ext_clk_I,
          ext_clk_IB => ext_clk_IB,
          cpld_fpga_clk => cpld_fpga_clk,
          cpld_fpga_data => cpld_fpga_data,
          cpld_fpga_addr => cpld_fpga_addr,
          cpld_fpga_sglrd => cpld_fpga_sglrd,
          cpld_fpga_sglwr => cpld_fpga_sglwr,
          cpld_fpga_brtrd_req => cpld_fpga_brtrd_req,
          fpga_cpld_burst_act => fpga_cpld_burst_act,
          fpga_cpld_burst_en => fpga_cpld_burst_en,
          fpga_cpld_rst_n => fpga_cpld_rst_n,
          LD_pulse_in_p => LD_pulse_in_p,
          LD_pulse_in_n => LD_pulse_in_n
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
  
 LD_pulse_in_p_16_process :process
   begin
		LD_pulse_in_p(16) <= '0';
		wait for LD_pulse_period/2;
		LD_pulse_in_p(16) <= '1';
		wait for LD_pulse_period/2;
   end process;
  LD_pulse_in_n(16) <= not LD_pulse_in_p(16);
  
  LD_pulse_in_p_18_process :process
   begin
		LD_pulse_in_p(18) <= '0';
		wait for LD_pulse_period/2;
		LD_pulse_in_p(18) <= '1';
		wait for LD_pulse_period/2;
   end process;
  LD_pulse_in_n(18) <= not LD_pulse_in_p(18);
  
  ld_gen_1_process :process
   begin
		wait for 100 us;
		wait for 10 ns;
		loop
		wait until rising_edge(LD_pulse_in_p(16));
		LD_pulse_cnt					<= LD_pulse_cnt + '1';
		if(LD_pulse_cnt = 50 and en_error = '1') then--少一个数
			LD_pulse_in_p(7 downto 0)	<= LD_pulse_in_p(7 downto 0) + 2;
		elsif(LD_pulse_cnt(7) = '0' and en_error = '1') then--多一个数
			LD_pulse_in_p(7 downto 0)	<= LD_pulse_in_p(7 downto 0);
		else
			LD_pulse_in_p(7 downto 0)	<= LD_pulse_in_p(7 downto 0) + '1';
		end if;
		end loop;
   end process;
	LD_pulse_in_p(15 downto 8)<= x"00";
	LD_pulse_in_n(15 downto 0)	<= not LD_pulse_in_p(15 downto 0);
	error_process :process
   begin
		wait for 100 us;
		wait for 10 ns;
		en_error	<= '0';
		
		wait for 1 ms;
		en_error	<= '1';
		wait for 4 ms;
   end process;
--	ld_gen_2_process :process
--   begin
--		wait for 100 us;
--		wait for 10 ns;
--		loop
--		wait until rising_edge(LD_pulse_in_p(18));
--		LD_pulse_in_p(15 downto 8)	<= LD_pulse_in_p(15 downto 8) + '1';
--		end loop;
--   end process;
--  LD_pulse_in_n(15 downto 8)	<= not LD_pulse_in_p(15 downto 8);
  
   cpld_fpga_clk_process :process
   begin
		cpld_fpga_clk <= '0';
		wait for cpld_fpga_clk_period/2;
		cpld_fpga_clk <= '1';
		wait for cpld_fpga_clk_period/2;
   end process;
	
	write_ram_process :process
   begin
		
		wait until rising_edge(ram_wr_enable);
		wait until rising_edge(cpld_fpga_clk);
		while (wr_ram_cnt < x"1000") loop
			wait for cpld_fpga_clk_period;
			wr_ram_en		<=	'1';
			wait for cpld_fpga_clk_period;
			wr_ram_en		<=	'0';
			wait for cpld_fpga_clk_period;
			wr_ram_cnt	<= wr_ram_cnt + '1';
		end loop;
		wait;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      cpld_fpga_sglwr	<=	'0';
		wait for 200 ns;
		wait for 5 us;
		--设置延时
		wait until rising_edge(cpld_fpga_clk);
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"B1";
		cpld_fpga_data <= x"00000105";--send enable 
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
		wait until rising_edge(cpld_fpga_clk);
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"B1";
		cpld_fpga_data <= x"00000805";--send enable 
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
		--写入 RAM
		wait for 10 us;
		wait until rising_edge(cpld_fpga_clk);
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"B1";
		cpld_fpga_data <= x"00000115";--send enable 
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
		ram_wr_enable <= '1';
		while (wr_ram_cnt < x"1000") loop
			wait until rising_edge(cpld_fpga_clk);
			cpld_fpga_sglwr	<=	wr_ram_en;
			cpld_fpga_addr		<=	x"B0";
			cpld_fpga_data(31 downto 16) 	<= wr_ram_cnt(15 downto 0);
			cpld_fpga_data(15 downto 8)  <=  x"00";
			cpld_fpga_data(7 downto 0)  <=  wr_ram_cnt(7 downto 0)+1;
			
		end loop;
--		wait for 30000 * cpld_fpga_clk_period;
--		wait for 1572864 * cpld_fpga_clk_period;
		
		wait until rising_edge(cpld_fpga_clk);

		wait for 20 us;
		--使能两个通道的比较
		wait until rising_edge(cpld_fpga_clk);
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"B2";
		cpld_fpga_data <= x"00000003";--send enable 
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
		
		wait for 20 us;
		--使能比较
		wait until rising_edge(cpld_fpga_clk);
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"10";
		cpld_fpga_data <= x"0000000F";--send enable 
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
		
		wait for 2 ms;
		--使能比较
		wait until rising_edge(cpld_fpga_clk);
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"B6";
		cpld_fpga_data <= x"00000002";--send enable 
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
		
		wait for 3 ms;
		--使能比较
		wait until rising_edge(cpld_fpga_clk);
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"B6";
		cpld_fpga_data <= x"00000003";--send enable 
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
		
		wait for 5  ms;
		--禁止比较
		wait until rising_edge(cpld_fpga_clk);
		cpld_fpga_sglwr	<=	'1';
		cpld_fpga_addr	<=	x"10";
		cpld_fpga_data <= x"000000F0";--send enable 
		wait for cpld_fpga_clk_period;
		cpld_fpga_sglwr	<=	'0';
		wait for cpld_fpga_clk_period*3;
   end process;

END;
