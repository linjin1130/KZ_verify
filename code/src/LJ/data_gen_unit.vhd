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
--library UNISIM;
--use UNISIM.VComponents.all;

entity data_gen_unit is
port(
	-- fix by herry make sys_clk_80M to sys_clk_160M
	   sys_clk_80M		:	in	std_logic;--system clock,80MHz
		sys_rst_n	:	in	std_logic;--system reset,low active
		fifo_clr		:	in	std_logic;--system reset,low active
		
		---
	   verify_active	:	in		std_logic;--system clock,200MHz
	   control_clk		:	in		std_logic;--system clock,200MHz
		kz_data_in		:	in		std_logic_vector(7 downto 0);
		fifo_rd_en		:	in		std_logic;
		fifo_prog_empty:	out	std_logic;
		fifo_rd_vld		:	out	std_logic;
		fifo_rd_data	:	out	std_logic_vector(31 downto 0)
	);
end data_gen_unit;

architecture Behavioral of data_gen_unit is
	
COMPONENT kz_fifo
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC;
    prog_empty : OUT STD_LOGIC
  );
END COMPONENT;
--	signal verify_running : std_logic;
	
	signal fifo_rst : std_logic;
	signal fifo_wr : std_logic;
	signal fifo_wr_data : std_logic_vector(7 downto 0);
begin
	process (sys_rst_n, control_clk) begin
		if(sys_rst_n = '0') then
			fifo_wr	<= '0';
		elsif(control_clk'event and control_clk = '1') then
			fifo_wr_data	<= kz_data_in;
			if(kz_data_in /= 0 and verify_active = '1') then
				fifo_wr	<= '1';
			else
				fifo_wr	<= verify_active;
			end if;
		end if;
	end process;
	
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
fifo_rst	<= not sys_rst_n;
kz_fifo_inst : kz_fifo
  PORT MAP (
    rst => fifo_clr,
    wr_clk => control_clk,
    rd_clk => sys_clk_80M,
    din => fifo_wr_data,
    wr_en => fifo_wr,
    rd_en => fifo_rd_en,
    dout => fifo_rd_data,
    full => open,
    empty => open,
    valid => fifo_rd_vld,
    prog_empty => fifo_prog_empty
  );	

end Behavioral;

