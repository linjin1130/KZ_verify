--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:54:14 08/09/2013
-- Design Name:   
-- Module Name:   F:/ground_project/ground_pro/cpld_if_test.vhd
-- Project Name:  ground_pro
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: cpld_if
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
Library UNISIM;
use UNISIM.vcomponents.all;
LIBRARY XilinxCoreLib;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY cpld_if_test IS
END cpld_if_test;
 
ARCHITECTURE behavior OF cpld_if_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cpld_if
    PORT(
         sys_clk_80M : IN  std_logic;
         sys_rst : IN  std_logic;
         cpld_fpga_clk : IN  std_logic;
         cpld_fpga_data : INOUT  std_logic_vector(31 downto 0);
         cpld_fpga_addr : IN  std_logic_vector(7 downto 0);
         cpld_fpga_sglrd : IN  std_logic;
         cpld_fpga_sglwr : IN  std_logic;
         cpld_fpga_brtrd_req : IN  std_logic;
         fpga_cpld_burst_act : OUT  std_logic;
         fpga_cpld_burst_en : OUT  std_logic;
         cpldif_rd_data : IN  std_logic_vector(31 downto 0);
         cpldif_addr : OUT  std_logic_vector(7 downto 0);
         cpldif_rd_en : OUT  std_logic;
         cpldif_wr_en : OUT  std_logic;
         cpldif_wr_data : OUT  std_logic_vector(31 downto 0);
         tdc_cpldif_fifo_wr_en : IN  std_logic;
         tdc_cpldif_fifo_wr_data : IN  std_logic_vector(31 downto 0);
         cpldif_tdc_fifo_full : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal sys_clk_80M : std_logic := '0';
   signal sys_rst : std_logic := '0';
   signal cpld_fpga_clk : std_logic := '0';
   signal cpld_fpga_addr : std_logic_vector(7 downto 0) := (others => '0');
   signal cpld_fpga_sglrd : std_logic := '0';
   signal cpld_fpga_sglwr : std_logic := '0';
   signal cpld_fpga_brtrd_req : std_logic := '0';
   signal cpldif_rd_data : std_logic_vector(31 downto 0) := (others => '0');
   signal tdc_cpldif_fifo_wr_en : std_logic := '0';
   signal tdc_cpldif_fifo_wr_data : std_logic_vector(31 downto 0) := (others => '0');

	--BiDirs
   signal cpld_fpga_data : std_logic_vector(31 downto 0);

 	--Outputs
   signal fpga_cpld_burst_act : std_logic;
   signal fpga_cpld_burst_en : std_logic;
   signal cpldif_addr : std_logic_vector(7 downto 0);
   signal cpldif_rd_en : std_logic;
   signal cpldif_wr_en : std_logic;
   signal cpldif_wr_data : std_logic_vector(31 downto 0);
   signal cpldif_tdc_fifo_full : std_logic;

   -- Clock period definitions
   constant cpld_fpga_clk_period : time := 30.3 ns;
   constant	clk80_period	:	time := 12.5 ns;
   signal rw_ctrl : std_logic := '0';
   signal data_i : std_logic_vector(31 downto 0);
   signal data_o : std_logic_vector(31 downto 0) := (others => '0');
   signal rd_cnt : std_logic_vector(7 downto 0) := X"80";
   signal burst_data : std_logic_vector(31 downto 0);
 
BEGIN
 
 IO_gen : for i in 0 to 31 generate
IOBUF_inst : IOBUF
port map (
O => data_i(i), -- Buffer output
IO => cpld_fpga_data(i), -- Buffer inout port (connect directly to top-level port)
I => data_o(i), -- Buffer input
T => rw_ctrl -- 3-state enable input
);
end generate;
 
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cpld_if PORT MAP (
          sys_clk_80M => sys_clk_80M,
          sys_rst => sys_rst,
          cpld_fpga_clk => cpld_fpga_clk,
          cpld_fpga_data => cpld_fpga_data,
          cpld_fpga_addr => cpld_fpga_addr,
          cpld_fpga_sglrd => cpld_fpga_sglrd,
          cpld_fpga_sglwr => cpld_fpga_sglwr,
          cpld_fpga_brtrd_req => cpld_fpga_brtrd_req,
          fpga_cpld_burst_act => fpga_cpld_burst_act,
          fpga_cpld_burst_en => fpga_cpld_burst_en,
          cpldif_rd_data => cpldif_rd_data,
          cpldif_addr => cpldif_addr,
          cpldif_rd_en => cpldif_rd_en,
          cpldif_wr_en => cpldif_wr_en,
          cpldif_wr_data => cpldif_wr_data,
          tdc_cpldif_fifo_wr_en => tdc_cpldif_fifo_wr_en,
          tdc_cpldif_fifo_wr_data => tdc_cpldif_fifo_wr_data,
          cpldif_tdc_fifo_full => cpldif_tdc_fifo_full
        );

   -- Clock process definitions
   cpld_fpga_clk_process :process
   begin
		cpld_fpga_clk <= '0';
		wait for cpld_fpga_clk_period/2;
		cpld_fpga_clk <= '1';
		wait for cpld_fpga_clk_period/2;
   end process;
 --80M Clock
 clk_80 : process
 begin
	sys_clk_80M	<=	'0';
	wait for clk80_period/2;
	sys_clk_80M	<=	'1';
	wait for clk80_period/2;
 end process;

   -- Stimulus process
   stim_proc: process
   begin		
		sys_rst	<=	'1';
		wait for cpld_fpga_clk_period*10;
		sys_rst	<=	'0';
		wait;
   end process;
   
   
--   ---singal read
--   process
--   begin
--		cpld_fpga_sglrd	<=	'0';
--		wait until (sys_rst = '0');
--		for i in 0 to 7 loop
--		wait until rising_edge(cpld_fpga_clk);
--		rw_ctrl	<=	'1';
--		cpld_fpga_sglrd	<=	'1';
--		cpld_fpga_addr	<=	cpld_fpga_addr + '1';
--		wait for cpld_fpga_clk_period;
--		cpld_fpga_sglrd	<=	'0';
--		wait for cpld_fpga_clk_period*3;
--		end loop;
--		wait for cpld_fpga_clk_period*10;
--		for i in 0 to 7 loop
--		wait until rising_edge(cpld_fpga_clk);
--		rw_ctrl	<=	'0';
--		cpld_fpga_sglwr	<=	'1';
--		data_o	<=	data_o + '1';
--		cpld_fpga_addr	<=	cpld_fpga_addr + '1';
--		wait for cpld_fpga_clk_period;
--		cpld_fpga_sglwr	<=	'0';
--		wait for cpld_fpga_clk_period*3;
--		end loop;
--		rw_ctrl	<=	'1';
--		wait;
--   end process;
--   
--   process(sys_clk_80M)
--   begin
--		if rising_edge(sys_clk_80M) then
--			if(cpldif_rd_en = '1') then
--				cpldif_rd_data	<=	cpldif_rd_data + '1';
--			else
--				cpldif_rd_data	<=	cpldif_rd_data;
--			end if;
--		end if;
--   end process;
   
   ---***** burst read *****************
   process(sys_clk_80M)
   begin
		if rising_edge(sys_clk_80M) then
			if(sys_rst = '1') then
				tdc_cpldif_fifo_wr_en	<=	'0';
				tdc_cpldif_fifo_wr_data	<=	(others => '1');
			elsif(cpldif_tdc_fifo_full = '0') then
				tdc_cpldif_fifo_wr_en	<=	'1';
				tdc_cpldif_fifo_wr_data	<=	tdc_cpldif_fifo_wr_data + '1';
			else
				tdc_cpldif_fifo_wr_en	<=	'0';
				tdc_cpldif_fifo_wr_data	<=	tdc_cpldif_fifo_wr_data;
			end if;
		end if;
   end process;
	
	process(cpld_fpga_clk)
	begin
		if rising_edge(cpld_fpga_clk) then
			if(fpga_cpld_burst_act = '1') then
				burst_data	<=	data_i;
			else
				burst_data	<=	burst_data;
			end if;
		end if;				
	end process;
	
	process(cpld_fpga_clk)
	begin
		if rising_edge(cpld_fpga_clk) then
			if(sys_rst = '1') then
				rd_cnt	<=	X"80";
			else
				if(fpga_cpld_burst_en = '1' and rd_cnt = X"80") then
					rd_cnt	<=	X"00";
				elsif(rd_cnt = X"80") then
					rd_cnt	<=	rd_cnt;
				else
					rd_cnt	<=	rd_cnt + '1';
				end if;
			end if;
		end if;				
	end process;
	
	process(rd_cnt)
	begin
		if(rd_cnt >= X"00" and rd_cnt < X"80") then
			cpld_fpga_brtrd_req	<=	'1';
		else	
			cpld_fpga_brtrd_req	<=	'0';
		end if;
	end process;
	
	rw_ctrl	<=	'1';
END;
