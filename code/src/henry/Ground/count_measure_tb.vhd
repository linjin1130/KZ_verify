--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:55:22 03/19/2014
-- Design Name:   
-- Module Name:   D:/Xilinx/ground_pro_all_outinLVDSCLK/my_count_measure_tb.vhd
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY count_measure_tb IS
END count_measure_tb;
 
ARCHITECTURE behavior OF count_measure_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT count_measure
    PORT(
         sys_clk_160M : IN  std_logic;
         sys_rst_n : IN  std_logic;
         apd_fpga_hit : IN  std_logic_vector(15 downto 0);
         qtel_counter_match : IN  std_logic_vector(7 downto 0);
         tdc_count_time_value : IN  std_logic_vector(31 downto 0);
         cpldif_count_addr : IN  std_logic_vector(7 downto 0);
         cpldif_count_wr_en : IN  std_logic;
         cpldif_count_rd_en : IN  std_logic;
         cpldif_count_wr_data : IN  std_logic_vector(31 downto 0);
         count_cpldif_rd_data : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

	--Inputs
	signal sys_clk_160M : std_logic := '0';
	signal sys_rst_n : std_logic := '0';
	signal apd_fpga_hit : std_logic_vector(15 downto 0) := (others => '0');
	signal qtel_counter_match : std_logic_vector(7 downto 0) := (others => '0');
	signal tdc_count_time_value : std_logic_vector(31 downto 0) := (others => '0');
	signal cpldif_count_addr : std_logic_vector(7 downto 0) := (others => '0');
	signal cpldif_count_wr_en : std_logic := '0';
	signal cpldif_count_rd_en : std_logic := '0';
	signal cpldif_count_wr_data : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
	signal count_cpldif_rd_data : std_logic_vector(31 downto 0);
	-- No clocks detected in port list. Replace <clock> below with 
	-- appropriate port name 
	signal sys_clk: std_logic;
	constant clk_period : time := 6.25 ns;
	constant clk_rst_period 	: time := 40 us;
 
BEGIN
 	sys_clk <= sys_clk_160M;
	-- Instantiate the Unit Under Test (UUT)
	uut: count_measure PORT MAP (
          sys_clk_160M => sys_clk_160M,
          sys_rst_n => sys_rst_n,
          apd_fpga_hit => apd_fpga_hit,
          qtel_counter_match => qtel_counter_match,
          tdc_count_time_value => tdc_count_time_value,
          cpldif_count_addr => cpldif_count_addr,
          cpldif_count_wr_en => cpldif_count_wr_en,
          cpldif_count_rd_en => cpldif_count_rd_en,
          cpldif_count_wr_data => cpldif_count_wr_data,
          count_cpldif_rd_data => count_cpldif_rd_data
        );

	-- Clock process definitions
	clk_process :process
	begin
		sys_clk_160M <= '0';
		wait for clk_period/2;
		sys_clk_160M <= '1';
		wait for clk_period/2;
	end process;
 
 	-- sys_rst_n process definitions
	rst_process : process begin
		sys_rst_n <='0';
		wait for clk_period*10;
		sys_rst_n <='1';
		wait for clk_rst_period;
		sys_rst_n <='0';
		wait;
	end process;
	
	write_hitp_process : process begin
			apd_fpga_hit(15 downto 0) <= (others => '0');
		wait until sys_rst_n = '1';
		for i in 0 to 40000 loop
			tdc_count_time_value <= tdc_count_time_value + '1';
			apd_fpga_hit(15 downto 0) <= apd_fpga_hit(15 downto 0) + '1';
			wait for clk_period;
		end loop;
	end process;	

	-- counter match process
	counter_match_process : process begin
		wait until sys_rst_n ='1';
		for i in 0 to 10000 loop
			qtel_counter_match <= qtel_counter_match + '1';
			wait for clk_period;
		end loop;
	end process;
	
		-- cpldif_rd process
	cpld_wr_rd_process : process begin
		wait until sys_rst_n ='1';
		wait for clk_period*2;
		wait until falling_edge(sys_clk);
		cpldif_count_addr	<=	X"70";
		cpldif_count_wr_data	<=	X"00F90FFF";
		wait until falling_edge(sys_clk);
		cpldif_count_wr_en	<=	'1';
		wait for clk_period;
		wait until falling_edge(sys_clk);
		cpldif_count_wr_en <= '0';
		wait for clk_period*2;
		wait until falling_edge(sys_clk);
		cpldif_count_addr	<=	X"71";
		cpldif_count_wr_data	<=	X"00000004";
		wait until falling_edge(sys_clk);
		cpldif_count_wr_en	<=	'1';
		wait for clk_period;
		wait until falling_edge(sys_clk);
		cpldif_count_wr_en <= '0';

		wait until falling_edge(sys_clk);
		cpldif_count_addr	<=	X"50";
		wait until falling_edge(sys_clk);
		cpldif_count_rd_en	<=	'1';
		wait for clk_period;
		wait until falling_edge(sys_clk);
		cpldif_count_rd_en <= '0';
		wait for clk_period*2;
		wait until falling_edge(sys_clk);
		cpldif_count_addr	<=	X"70";
		wait until falling_edge(sys_clk);
		cpldif_count_rd_en	<=	'1';
		wait for clk_period;
		wait until falling_edge(sys_clk);
		cpldif_count_rd_en <= '0';
		wait for clk_period*2;
		wait until falling_edge(sys_clk);
		cpldif_count_addr	<=	X"71";
		wait until falling_edge(sys_clk);
		cpldif_count_rd_en	<=	'1';
		wait for clk_period;
		wait until falling_edge(sys_clk);
		cpldif_count_rd_en <= '0';
		wait for clk_period*2;
		wait until falling_edge(sys_clk);
		cpldif_count_addr	<=	X"72";
		wait until falling_edge(sys_clk);
		cpldif_count_rd_en	<=	'1';
		wait for clk_period;
		wait until falling_edge(sys_clk);
		cpldif_count_rd_en <= '0';
		wait for clk_period*2;
		
		wait for clk_rst_period/2;
		wait until falling_edge(sys_clk);
		cpldif_count_addr	<=	X"50";
		wait until falling_edge(sys_clk);
		cpldif_count_rd_en	<=	'1';
		wait for clk_period;
		wait until falling_edge(sys_clk);
		cpldif_count_rd_en <= '0';
		wait for clk_period*2;
		wait until falling_edge(sys_clk);
		cpldif_count_addr	<=	X"70";
		wait until falling_edge(sys_clk);
		cpldif_count_rd_en	<=	'1';
		wait for clk_period;
		wait until falling_edge(sys_clk);
		cpldif_count_rd_en <= '0';
		wait for clk_period*2;
		wait until falling_edge(sys_clk);
		cpldif_count_addr	<=	X"71";
		wait until falling_edge(sys_clk);
		cpldif_count_rd_en	<=	'1';
		wait for clk_period;
		wait until falling_edge(sys_clk);
		cpldif_count_rd_en <= '0';
		wait for clk_period*2;
		wait until falling_edge(sys_clk);
		cpldif_count_addr	<=	X"72";
		wait until falling_edge(sys_clk);
		cpldif_count_rd_en	<=	'1';
		wait for clk_period;
		wait until falling_edge(sys_clk);
		cpldif_count_rd_en <= '0';
		wait for clk_period*2;
		
		wait until falling_edge(sys_clk);
		cpldif_count_addr	<=	X"70";
		cpldif_count_wr_data	<=	X"00020000";
		wait until falling_edge(sys_clk);
		cpldif_count_wr_en	<=	'1';
		wait for clk_period;
		wait until falling_edge(sys_clk);
		cpldif_count_wr_en <= '0';
		wait ;
	end process;


	-- Stimulus process
	stim_proc: process
	begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
	end process;

END;
