--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:15:48 12/25/2014
-- Design Name:   
-- Module Name:   E:/Work/FPGA/ground_pro_all_DPS_QKD_test/ground_pro_use_PPG/atan_lut_TB.vhd
-- Project Name:  ground_pro
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: atan_lut
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
use ieee.std_logic_arith.all; 
--use ieee.std_logic_signed.all; 
 use ieee.std_logic_unsigned.all; 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY atan_lut_TB IS
END atan_lut_TB;
 
ARCHITECTURE behavior OF atan_lut_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT atan_lut
    PORT(
         sys_clk : IN  std_logic;
         sys_rst : IN  std_logic;
         start : IN  std_logic;
         offset_voltage : IN  std_logic_vector(11 downto 0);
         half_wave_voltage : IN  std_logic_vector(11 downto 0);
         chnl_cnt_reg0_out : IN  std_logic_vector(9 downto 0);
         chnl_cnt_reg1_out : IN  std_logic_vector(9 downto 0);
         chnl_cnt_reg2_out : IN  std_logic_vector(9 downto 0);
         chnl_cnt_reg3_out : IN  std_logic_vector(9 downto 0);
         chnl_cnt_reg4_out : IN  std_logic_vector(9 downto 0);
         chnl_cnt_reg5_out : IN  std_logic_vector(9 downto 0);
         chnl_cnt_reg6_out : IN  std_logic_vector(9 downto 0);
         chnl_cnt_reg7_out : IN  std_logic_vector(9 downto 0);
         lut_ram_rd_addr : OUT  std_logic_vector(9 downto 0);
         lut_ram_rd_data : IN  std_logic_vector(15 downto 0);
			tan_adj_voltage		: in std_logic_vector(11 downto 0);--offset_voltage
--         lut_ram_128_addr_wr : IN  std_logic_vector(6 downto 0);
         lut_ram_128_addr : IN  std_logic_vector(6 downto 0);
         lut_ram_128_data : OUT  std_logic_vector(11 downto 0);
         addr_reset : IN  std_logic;
         use_8apd : IN  std_logic;
         use_4apd : IN  std_logic;
         result_ok : OUT  std_logic;
         DAC_set_addr : OUT  std_logic_vector(6 downto 0);
         DAC_set_result : OUT  std_logic_vector(11 downto 0)
        );
    END COMPONENT;
	 
	 COMPONENT lut_ram
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    clkb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
	END COMPONENT;
    

   --Inputs
   signal sys_clk : std_logic := '0';
   signal sys_rst : std_logic := '1';
   signal start : std_logic := '0';
   signal temp : std_logic_vector(9 downto 0) := (others => '0');
   signal tan_adj_voltage : std_logic_vector(11 downto 0) := (others => '0');
   signal offset_voltage : std_logic_vector(11 downto 0) := (others => '0');
   signal half_wave_voltage : std_logic_vector(11 downto 0) := (others => '0');
   signal chnl_cnt_reg0_out : std_logic_vector(9 downto 0) := (others => '0');
   signal chnl_cnt_reg1_out : std_logic_vector(9 downto 0) := (others => '0');
   signal chnl_cnt_reg2_out : std_logic_vector(9 downto 0) := (others => '0');
   signal chnl_cnt_reg3_out : std_logic_vector(9 downto 0) := (others => '0');
   signal chnl_cnt_reg4_out : std_logic_vector(9 downto 0) := (others => '0');
   signal chnl_cnt_reg5_out : std_logic_vector(9 downto 0) := (others => '0');
   signal chnl_cnt_reg6_out : std_logic_vector(9 downto 0) := (others => '0');
   signal chnl_cnt_reg7_out : std_logic_vector(9 downto 0) := (others => '0');
   signal lut_ram_rd_data : std_logic_vector(15 downto 0) := (others => '0');
   signal lut_ram_128_addr : std_logic_vector(6 downto 0) := (others => '0');
--   signal lut_ram_128_addr_wr : std_logic_vector(6 downto 0) := (others => '0');
   signal use_8apd : std_logic := '0';
   signal use_4apd : std_logic := '0';
   signal addr_reset : std_logic := '0';

 	--Outputs
   signal lut_ram_rd_addr : std_logic_vector(9 downto 0);
   signal lut_ram_128_data : std_logic_vector(11 downto 0);
   signal result_ok : std_logic;
   signal DAC_set_addr : std_logic_vector(6 downto 0);
   signal DAC_set_result : std_logic_vector(11 downto 0);

   -- Clock period definitions
   constant sys_clk_period : time := 4 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: atan_lut PORT MAP (
          sys_clk => sys_clk,
          sys_rst => sys_rst,
          start => start,
          addr_reset => addr_reset,
			 tan_adj_voltage => 	tan_adj_voltage,
          offset_voltage => offset_voltage,
          half_wave_voltage => half_wave_voltage,
          chnl_cnt_reg0_out => chnl_cnt_reg0_out,
          chnl_cnt_reg1_out => chnl_cnt_reg1_out,
          chnl_cnt_reg2_out => chnl_cnt_reg2_out,
          chnl_cnt_reg3_out => chnl_cnt_reg3_out,
          chnl_cnt_reg4_out => chnl_cnt_reg4_out,
          chnl_cnt_reg5_out => chnl_cnt_reg5_out,
          chnl_cnt_reg6_out => chnl_cnt_reg6_out,
          chnl_cnt_reg7_out => chnl_cnt_reg7_out,
          lut_ram_rd_addr => lut_ram_rd_addr,
          lut_ram_rd_data => lut_ram_rd_data,
--          lut_ram_128_addr_wr => lut_ram_128_addr_wr,
          lut_ram_128_addr => lut_ram_128_addr,
          lut_ram_128_data => lut_ram_128_data,
          use_8apd => use_8apd,
          use_4apd => use_4apd,
          result_ok => result_ok,
          DAC_set_addr => DAC_set_addr,
          DAC_set_result => DAC_set_result
        );
		  
		 inst_lut_ram : lut_ram
	  PORT MAP (
		 clka 	=> sys_clk,
		 wea(0) 		=> '0',
		 addra 	=> "0000000000",
		 dina 	=> x"0000",
		 clkb 	=> sys_clk,
		 addrb 	=> lut_ram_rd_addr,
		 doutb 	=> lut_ram_rd_data
	  );

   -- Clock process definitions
   sys_clk_process :process
   begin
		sys_clk <= '0';
		wait for sys_clk_period/2;
		sys_clk <= '1';
		wait for sys_clk_period/2;
   end process;
 
	process
   begin
		start <= '0';
		wait for 2 us;
		start <= '1';
		wait for 2 us;
   end process;
	
	process
   begin
		start <= '0';
		wait for 2 us;
		start <= '1';
--		lut_ram_128_addr_wr		<= lut_ram_128_addr_wr + 1;
		lut_ram_128_addr		<= lut_ram_128_addr + 1;
		chnl_cnt_reg0_out		<= chnl_cnt_reg0_out + 121;
		chnl_cnt_reg1_out		<= temp+218;--chnl_cnt_reg1_out + 221;
		chnl_cnt_reg2_out		<= chnl_cnt_reg2_out + 171;
		chnl_cnt_reg3_out		<= temp+425;--chnl_cnt_reg3_out + 321;
		chnl_cnt_reg4_out		<= chnl_cnt_reg4_out + 521;
		chnl_cnt_reg5_out		<= temp+523;--chnl_cnt_reg5_out + 421;
		chnl_cnt_reg6_out		<= chnl_cnt_reg6_out + 621;
		chnl_cnt_reg7_out		<= temp+343;--chnl_cnt_reg7_out + 921;
		wait for 2 us;
   end process;
	
--	lut_ram_rd_data(9 downto 0)	<= lut_ram_rd_addr;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		sys_rst	<= '0';
		half_wave_voltage	<= x"385";
		offset_voltage		<= x"BD7";
--		tan_adj_voltage	<= x"265";
      wait for sys_clk_period*10;
		wait for 2ms;
		use_8apd	<= '1';
		
		wait for 2ms;
		use_8apd	<= '0';
		use_4apd	<= '1';
		wait for 2ms;
      
		wait for 2ms;
		--half_wave_voltage	<= x"22E";
		
		wait for 2ms;
		-- insert stimulus here 
		offset_voltage	<= x"345";
		
		wait for 2ms;
		offset_voltage	<= x"A45";
		
		addr_reset	<= '1';
      wait;
   end process;

END;
