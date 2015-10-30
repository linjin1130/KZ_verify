----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:39:16 02/27/2015 
-- Design Name: 
-- Module Name:    data_gen_unit - Behavioral 
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

use ieee.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity data_gen_unit is
port(
	-- fix by herry make sys_clk_200M to sys_clk_160M
	   sys_clk_600M		:	in	std_logic;--system clock,80MHz
	   sys_clk_200M		:	in	std_logic;--system clock,80MHz
		sys_rst_n	:	in	std_logic;--system reset,low active
		fifo_clr		:	in	std_logic;--system reset,low active
		
		---
	   verify_active	:	in		std_logic;--system clock,200MHz
	   control_clk		:	in		std_logic;--system clock,200MHz
		kz_data_in		:	in		std_logic_vector(15 downto 0);
		fifo_rd_en		:	in		std_logic;
		fifo_prog_empty:	out	std_logic;
		fifo_rd_vld		:	out	std_logic;
		clk_delay		:	in 	std_logic_vector(5 downto 0);
		fifo_rd_data	:	out	std_logic_vector(7 downto 0)
	);
end data_gen_unit;

architecture Behavioral of data_gen_unit is
	
COMPONENT kz_fifo
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC;
    prog_empty : OUT STD_LOGIC
  );
END COMPONENT;
--	signal verify_running : std_logic;
	
	signal control_clk_reg1 : std_logic;
	signal control_clk_reg2 : std_logic;
	signal control_clk_reg3 : std_logic;
	signal control_clk_reg4 : std_logic;
	signal data_all_0_1 : std_logic;
--	signal data_all_0_1_r : std_logic;
	signal data_all_0_r : std_logic;
	signal data_all_0 : std_logic;
	signal data_all_1 : std_logic;
	signal data_all_1_r : std_logic;
	signal fifo_rst : std_logic;
	signal head_filtered : std_logic := '0';
	signal data_en : std_logic;
	signal fifo_wr : std_logic;
	signal control_clk_rising : std_logic;
	signal control_clk_r : std_logic_vector(4 downto 0);
	signal data 			: std_logic_vector(15 downto 0) := x"0000";
	signal fifo_wr_data : std_logic_vector(15 downto 0) := x"0000";
	signal kz_data_reg1 : std_logic_vector(15 downto 0);
	signal kz_data_reg2 : std_logic_vector(15 downto 0);
	signal kz_data_reg3 : std_logic_vector(15 downto 0);
begin

--	process (sys_rst_n, control_clk) begin
--		if(sys_rst_n = '0') then
--			kz_data_reg	<= (others => '0');
--		elsif(control_clk'event and control_clk = '1') then
--			kz_data_reg	<= kz_data_in;
--		end if;
--	end process;
--	
--	process (sys_rst_n, control_clk) begin
--		if(sys_rst_n = '0') then
--			fifo_wr	<= '0';
--			head_filtered	<= '0';
--		elsif(control_clk'event and control_clk = '1') then
--			fifo_wr_data	<= kz_data_reg;
--			
--			if(data_all_0_1 = '0' and verify_active = '1' and head_filtered = '0') then
--				fifo_wr			<= '1';
--				head_filtered 	<= '1';
--			else
--				fifo_wr	<= verify_active;
--				if(verify_active = '0') then
--					head_filtered	<= '0';
--				else
--					head_filtered	<= head_filtered;
--				end if;
--			end if;
--		end if;
--	end process;
--	
--	process (sys_rst_n, control_clk) begin
--		if(sys_rst_n = '0') then
--			data_all_0_1	<= '0';
--		elsif(control_clk'event and control_clk = '1') then
--			data_all_0_1	<= (not data_all_0) or data_all_1;
--		end if;
--	end process;
	
	data_all_0 <= 	kz_data_reg2(0) or kz_data_reg2(1) or kz_data_reg2(2) or kz_data_reg2(3) or kz_data_reg2(4) or kz_data_reg2(5) or kz_data_reg2(6) or kz_data_reg2(7) or
						kz_data_reg2(8) or kz_data_reg2(9) or kz_data_reg2(10) or kz_data_reg2(11) or kz_data_reg2(12) or kz_data_reg2(13) or kz_data_reg2(14) or kz_data_reg2(15);
	data_all_1 <= 	kz_data_reg2(0) and kz_data_reg2(1) and kz_data_reg2(2) and kz_data_reg2(3) and kz_data_reg2(4) and kz_data_reg2(5) and kz_data_reg2(6) and kz_data_reg2(7) and
						kz_data_reg2(8) and kz_data_reg2(9) and kz_data_reg2(10) and kz_data_reg2(11) and kz_data_reg2(12) and kz_data_reg2(13) and kz_data_reg2(14) and kz_data_reg2(15);
	
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
fifo_rst	<= not sys_rst_n;
kz_fifo_inst : kz_fifo
  PORT MAP (
    rst => fifo_clr,
    wr_clk => sys_clk_600M,
    rd_clk => sys_clk_200M,
    din => fifo_wr_data,
    wr_en => fifo_wr,
    rd_en => fifo_rd_en,
    dout => fifo_rd_data,
    full => open,
    empty => open,
    valid => fifo_rd_vld,
    prog_empty => fifo_prog_empty
  );	
  
   process (sys_clk_600M) begin
		if(sys_clk_600M'event and sys_clk_600M = '1') then
			control_clk_reg1	<= control_clk;
			control_clk_reg2	<= control_clk_reg1;
			control_clk_reg3	<= control_clk_reg2;
			control_clk_reg4	<= control_clk_reg3;
			
			kz_data_reg1	<= kz_data_in;
			kz_data_reg2	<= kz_data_reg1;
			kz_data_reg3	<= kz_data_reg2;
			
			data_all_0_r	<= data_all_0;
			data_all_1_r	<= data_all_1;
			
			data_all_0_1	<= (not data_all_0_r) or data_all_1_r;
			control_clk_r(0)	<= not control_clk_reg4 and control_clk_reg3;
			control_clk_r(4 downto 1)	<= control_clk_r(3 downto 0);
			
			if(control_clk_rising = '1') then
				data_en			<= head_filtered;
				data				<= kz_data_reg3;
			else
				data_en			<= '0';
			end if;
		end if;
	end process;
	
	process (sys_clk_600M) begin
		if(sys_clk_600M'event and sys_clk_600M = '1') then
			fifo_wr			<= data_en;
			fifo_wr_data	<= data;
		end if;
	end process;
	
	process (sys_clk_600M) begin
		if(sys_clk_600M'event and sys_clk_600M = '1') then
			if(clk_delay(0) = '1') then
				control_clk_rising <= not control_clk_reg4 and control_clk_reg3;
			end if;
			if(clk_delay(1) = '1') then
				control_clk_rising <= control_clk_r(0);
			end if;
			if(clk_delay(2) = '1') then
				control_clk_rising <= control_clk_r(1);
			end if;
			if(clk_delay(3) = '1') then
				control_clk_rising <= control_clk_r(2);
			end if;
			if(clk_delay(4) = '1') then
				control_clk_rising <= control_clk_r(3);
			end if;
			if(clk_delay(5) = '1') then
				control_clk_rising <= control_clk_r(4);
			end if;
		end if;
	end process;
	
	process (sys_rst_n, sys_clk_600M) begin
	if(sys_rst_n = '0') then
		head_filtered	<= '0';
		
	elsif(sys_clk_600M'event and sys_clk_600M = '1') then
		if(data_all_0_1 = '0' and verify_active = '1' and head_filtered = '0') then
			head_filtered 	<= '1';
		else
			if(verify_active = '0') then
				head_filtered	<= '0';
			else
				head_filtered	<= head_filtered;
			end if;
		end if;
	end if;
	end process;
	
--	fdpe_gen: for i in 0 to 15 generate
--	begin
--		FDPE_inst0 : FDPE
--		generic map (
--			INIT => '0') -- Initial value of register ('0' or '1')  
--		port map (
--			Q => kz_data_reg2(i),      -- Data output
--			C => sys_clk_600M,      -- Clock input
--			CE => '1',    -- Clock enable input
--			PRE => '0',  -- Asynchronous preset input
--			D => kz_data_reg1(i)       -- Data input
--		);
--	end generate;

end Behavioral;

