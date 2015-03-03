----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:01:17 12/05/2014 
-- Design Name: 
-- Module Name:    POC_ouput_control - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity POC_output_control is
generic
    (
	  BURST_LEN  : integer := 1;    -- Burst Length
     DATA_WIDTH : integer := 32    -- Data Width
    );
    Port ( 
		   sys_clk	   : in std_logic;
		   sys_rst_n 	: in  STD_LOGIC;

         fifo_clr						:  in  STD_LOGIC;
         exp_running					:  in  STD_LOGIC;
         syn_light					:  in  STD_LOGIC;
         Alice_H_Bob_L				:  in  STD_LOGIC;
         
			POC_fifo_wr_en				:  in std_logic;--fifo write enable
			POC_fifo_wr_data			:  in std_logic_vector(BURST_LEN*DATA_WIDTH-1 downto 0);--fifo write data
			
			POC_fifo_rdy				:  out std_logic;--fifo has spare space
			
			Dac_Ena : OUT std_logic;
			dac_data : OUT std_logic_vector(15 downto 0);
			poc_test_en 			: in	std_logic;
			poc_test_data		 	: IN std_logic_vector(6 downto 0);
			dac_test_en 			: in	std_logic;
			dac_test_data		 	: IN std_logic_vector(15 downto 0);
			pm_dac_en 			: in	std_logic;
			pm_dac_data		 	: IN std_logic_vector(11 downto 0);
			lut_ram_128_vld  : out std_logic;
			lut_ram_128_addr : out std_logic_vector(6 downto 0);
			lut_ram_128_data : IN std_logic_vector(11 downto 0);
			
--			chopper_contrl				:  in  STD_LOGIC;
			POC_control_en				:	in std_logic;
			POC_control					:	in std_logic_vector(6 downto 0);
	
			POC_start					:	out std_logic_vector(6 downto 0);
			POC_stop						:	out std_logic_vector(6 downto 0)
			
			  );
end POC_output_control;

architecture Behavioral of POC_output_control is
component random_fifo
	port (
	rst: in std_logic;
	wr_clk: in std_logic;
	rd_clk: in std_logic;
	din: in std_logic_vector(BURST_LEN*DATA_WIDTH-1 downto 0);
	wr_en: in std_logic;
	rd_en: in std_logic;
	dout: out std_logic_vector(7 downto 0);
	full: out std_logic;
	empty: out std_logic;
	valid: out std_logic;
	prog_full: out std_logic);
end component;

signal rnd_rd_data				:	std_logic_vector(7 downto 0);
signal rnd_rd_en					:	std_logic;
signal rnd_rd_vld					:	std_logic;
signal pm_rd_vld					:	std_logic;
signal prog_full					:	std_logic;
signal pm_dac_en_d1				:	std_logic;
signal syn_light_d1				:	std_logic;
signal syn_light_d2				:	std_logic;
signal POC_control_reg			:	std_logic_vector(6 downto 0);
signal POC_control_reg_d1		:	std_logic_vector(6 downto 0);
signal POC_start_reg				:	std_logic_vector(6 downto 0);
signal POC_stop_reg				:	std_logic_vector(6 downto 0);

type count_stop_regType is array(0 to 6) of std_logic_vector(3 downto 0);
signal count_stop : count_stop_regType;

type count_start_regType is array(0 to 6) of std_logic_vector(8 downto 0);--512 5us
signal count_start : count_start_regType;

begin
--fifo interface
	random_fifo_inst : random_fifo
	port map (
		rst => fifo_clr,
		wr_clk => sys_clk,--80MHz
		rd_clk => sys_clk,--80MHz
		din => POC_fifo_wr_data,
		wr_en => POC_fifo_wr_en,
		rd_en => rnd_rd_en,
		dout => rnd_rd_data,
		full => open,
		valid => rnd_rd_vld,
		prog_full => prog_full,
		empty => open
	);
	POC_fifo_rdy <= not prog_full;

---syn_light is asynchronus
 process(sys_clk, sys_rst_n)
 begin
	if(sys_rst_n = '0') then
		syn_light_d1	<= '0';
		syn_light_d2	<= '0';
		rnd_rd_en		<= '0';
		rnd_rd_en		<= '0';
		lut_ram_128_vld<= '0';
	elsif rising_edge(sys_clk) then
		syn_light_d1	<= syn_light;
		syn_light_d2	<= syn_light_d1;
		rnd_rd_en		<= syn_light_d1 and (not syn_light_d2) and (not Alice_H_Bob_L);--rising edge
		pm_rd_vld		<= rnd_rd_vld;
		lut_ram_128_vld<= pm_rd_vld;
	end if;
 end process;
 
 lut_ram_128_addr	<= rnd_rd_data(6 downto 0);
 process(sys_clk, sys_rst_n)
 begin
	if(sys_rst_n = '0') then
		pm_dac_en_d1	<= '0';
		dac_ena			<= '0';
		dac_data			<= (others => '0');
	elsif rising_edge(sys_clk) then
		pm_dac_en_d1	<= pm_dac_en;
		if(pm_rd_vld = '1') then---random data control pm voltage
			dac_data	<=	x"4" & lut_ram_128_data;
			dac_ena	<= '1';
		else
			if(pm_dac_en_d1 = '0' and pm_dac_en = '1') then --rising edge  pm steady control dac write
				dac_ena	<= '1';
				dac_data	<= x"4" & pm_dac_data;
			else
				if(dac_test_en = '1') then --test enable
					dac_ena	<= '1';
					dac_data	<= dac_test_data;
				else
					dac_ena	<= '0';
				end if;
			end if;
		end if;
	end if;
 end process;
 
 process(sys_clk, sys_rst_n)
 begin
	if(sys_rst_n = '0') then
		POC_control_reg		<= "0000000";
		POC_control_reg_d1	<= "0000000";
	elsif rising_edge(sys_clk) then
		POC_control_reg_d1	<= POC_control_reg;
		if(exp_running = '1') then
			if(rnd_rd_vld = '1') then---random control
				POC_control_reg	<= rnd_rd_data(6 downto 0);
			else
				if(POC_control_en = '1') then--PM steady control
					POC_control_reg	<= POC_control;	
				else
					if(poc_test_en = '1') then--PM test control
						POC_control_reg	<= poc_test_data;	
					else
						null;
					end if;
				end if;
			end if;
		else
			POC_control_reg		<= "0000000";
		end if;
	end if;
 end process;
 
 poc_gen: for i in 0 to 6 generate
	 POC_start_reg(i)	<= (not POC_control_reg_d1(i)) and (    POC_control_reg(i));--rising edge
	 POC_stop_reg(i)	<= (    POC_control_reg_d1(i)) and (not POC_control_reg(i));--falling edge
	 
	 ---generate poc stop count
	 process(sys_clk, sys_rst_n)
	 begin
		if(sys_rst_n = '0') then
			count_start(i)		<= (others => '1');
		elsif rising_edge(sys_clk) then
			if(POC_start_reg(i) = '1') then
				count_start(i)		<= (others => '0');
			else
				if(POC_stop_reg(i) = '1') then
					count_start(i)		<= (others => '1');
				else
					if(count_start(i) = 400) then
						count_start(i)		<= (others => '0');
					else
						if(count_start(i) < 400) then
							count_start(i)	<= count_start(i) + 1;
						else
							null;
						end if;
					end if;
				end if;
			end if;
		end if;
	 end process;
	  ---generate poc start pulse about 100ns 
	 process(sys_clk, sys_rst_n)
	 begin
		if(sys_rst_n = '0') then
			POC_start(i)		<= '0';
		elsif rising_edge(sys_clk) then
			if(count_start(i) < 8) then
				POC_start(i)		<= '1';
			else
				POC_start(i)		<= '0';
			end if;			
		end if;
	 end process;
	  ---generate poc stop count
	 process(sys_clk, sys_rst_n)
	 begin
		if(sys_rst_n = '0') then
			count_stop(i)		<= (others => '1');
		elsif rising_edge(sys_clk) then
			if(POC_stop_reg(i) = '1') then
				count_stop(i)		<= (others => '0');
			else
				if(count_stop(i) < x"F") then
					count_stop(i)	<= count_stop(i) + 1;
				else
					null;
				end if;
			end if;
		end if;
	 end process;
	 ---generate poc stop pulse about 100ns 
	 process(sys_clk, sys_rst_n)
	 begin
		if(sys_rst_n = '0') then
			POC_stop(i)		<= '0';
		elsif rising_edge(sys_clk) then
			if(count_stop(i) < 8) then
				POC_stop(i)		<= '1';
			else
				POC_stop(i)		<= '0';
			end if;			
		end if;
	 end process;
end generate;

end Behavioral;

