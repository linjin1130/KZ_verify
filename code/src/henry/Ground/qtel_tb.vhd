--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:12:17 02/27/2014
-- Design Name:   
-- Module Name:   D:/Xilinx/ground_pro_all_outinLVDSCLK/qtel_tb.vhd
-- Project Name:  ground_pro
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: qtel
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

library UNISIM;
use UNISIM.VComponents.all;

ENTITY qtel_tb IS
END qtel_tb;
 
ARCHITECTURE behavior OF qtel_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT qtel
    PORT(
         sys_clk_160M 			: IN  std_logic;
         sys_rst_n 				: IN  std_logic;
		 tdc_qtel_hit			: in  std_logic_vector(8 downto 0);
         -- apd_fpga_hit_p 		: IN  std_logic_vector(9 downto 1);
         -- apd_fpga_hit_n 		: IN  std_logic_vector(9 downto 1);
         qtel_counter_match 	: OUT  std_logic_vector(7 downto 0);
         cpldif_qtel_addr 		: IN  std_logic_vector(7 downto 0);
         cpldif_qtel_wr_en 		: IN  std_logic;
         cpldif_qtel_rd_en 		: IN  std_logic;
         cpldif_qtel_wr_data 	: IN  std_logic_vector(31 downto 0);
         qtel_cpldif_rd_data 	: OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;  

	--inputs
	signal sys_clk_160M 		: std_logic := '0';
	signal sys_rst_n 			: std_logic := '0';
	signal apd_fpga_hit 		: std_logic_vector(8 downto 0) := (others => '0');
	signal tdc_qtel_hit 		: std_logic_vector(8 downto 0) := (others => '0');
	-- signal apd_fpga_hit_p 		: std_logic_vector(9 downto 1) := (others => '0');
	-- signal apd_fpga_hit_n 		: std_logic_vector(9 downto 1) := (others => '0');
	signal cpldif_qtel_addr 	: std_logic_vector(7 downto 0) := (others => '0');
	signal cpldif_qtel_wr_en 	: std_logic := '0';
	signal cpldif_qtel_rd_en 	: std_logic := '0';
	signal cpldif_qtel_wr_data 	: std_logic_vector(31 downto 0) := (others => '0');
	--Outputs
	signal qtel_counter_match 	: std_logic_vector(7 downto 0);
	signal qtel_cpldif_rd_data 	: std_logic_vector(31 downto 0);
	-- No clocks detected in port list. Replace <clock> below with 
	-- appropriate port name 
	signal sys_clk: std_logic;	
 
    constant clk_period 		: time := 6.25 ns;
	constant clk_80M 			: time := 12.5 ns;
	constant clk_rst_period 	: time := 250 us;
 
 
BEGIN
	sys_clk <= sys_clk_160M;
	tdc_qtel_hit <= apd_fpga_hit(7 downto 0) & apd_fpga_hit(8);
	-- Instantiate the Unit Under Test (UUT)
	uut: qtel 
	PORT MAP (
          sys_clk_160M => sys_clk_160M,
          sys_rst_n => sys_rst_n,
		  tdc_qtel_hit => tdc_qtel_hit,
          --apd_fpga_hit_p => apd_fpga_hit_p,
          --apd_fpga_hit_n => apd_fpga_hit_n,
          qtel_counter_match => qtel_counter_match,
          cpldif_qtel_addr => cpldif_qtel_addr,
          cpldif_qtel_wr_en => cpldif_qtel_wr_en,
          cpldif_qtel_rd_en => cpldif_qtel_rd_en,
          cpldif_qtel_wr_data => cpldif_qtel_wr_data,
          qtel_cpldif_rd_data => qtel_cpldif_rd_data
        );

	-- clock process 
	clk_process :process begin
		sys_clk_160M <= '0';
		wait for clk_period/2;
		sys_clk_160M <= '1';
		wait for clk_period/2;
	end process;
	
	-- qtel clk generation
	clk_80M_process : process begin
		apd_fpga_hit(8) <= '0';
		wait for clk_80M/2;
		apd_fpga_hit(8) <= '1';
		wait for clk_80M/2;
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
	
	-- cpldif_wr process
	cpld_wr_process : process begin
		wait until sys_rst_n ='1';
		wait until falling_edge(sys_clk);
		cpldif_qtel_addr	<=	X"30";
		cpldif_qtel_wr_data	<=	X"00060002";
		wait until falling_edge(sys_clk);
		cpldif_qtel_wr_en	<=	'1';
		wait for clk_period;
		wait until falling_edge(sys_clk);
		cpldif_qtel_wr_en <= '0';
		wait for clk_period*10;
		wait until falling_edge(sys_clk);
		cpldif_qtel_addr	<=	X"31";
		cpldif_qtel_wr_data	<=	X"0e000001";
		wait until falling_edge(sys_clk);
		cpldif_qtel_wr_en	<=	'1';
		wait for clk_period;
		wait until falling_edge(sys_clk);
		cpldif_qtel_wr_en <= '0';
		wait for clk_period*10;
		wait until falling_edge(sys_clk);
		cpldif_qtel_addr	<=	X"32";
		cpldif_qtel_wr_data	<=	X"00000001";
		wait until falling_edge(sys_clk);
		cpldif_qtel_wr_en	<=	'1';
		wait for clk_period;
		wait until falling_edge(sys_clk);
		cpldif_qtel_wr_en <= '0';
		wait ;
	end process;
	
	-- OBUFDS_inst : OBUFDS
		-- generic map (
			-- IOSTANDARD => "DEFAULT")
		-- port map (
			-- O => apd_fpga_hit_p(1),     -- Diff_p output (connect directly to top-level port)
			-- OB => apd_fpga_hit_n(1),   -- Diff_n output (connect directly to top-level port)
			-- I => apd_fpga_hit(8)      -- Buffer input 
	-- );
	
	-- signal_gen_inst: FOR i in 0 to 7 generate
	-- begin
		-- OBUFDS_inst : OBUFDS
		-- generic map (
			-- IOSTANDARD => "DEFAULT")
		-- port map (
			-- O => apd_fpga_hit_p(i + 2),     -- Diff_p output (connect directly to top-level port)
			-- OB => apd_fpga_hit_n(i + 2),   -- Diff_n output (connect directly to top-level port)
			-- I => apd_fpga_hit(i)      -- Buffer input 
		-- );
	-- end generate;
  	
	-- wirte apd_hit signal process:
	write_hitp_process : process begin
			apd_fpga_hit(7 downto 0) <= "00000000";
		wait until sys_rst_n = '1';
		for i in 0 to 40000 loop
			apd_fpga_hit(7 downto 0) <= apd_fpga_hit(7 downto 0) + '1';
		wait for clk_period;
		end loop;
	end process;	
	
	-- stim process
	stim_proc: process
	begin		
      -- hold reset state for 100 ns.
		wait for 50 ns;
		wait until sys_rst_n = '1';
		wait for clk_period*10;
      -- insert stimulus here 
		
      wait;
	end process;

END;
