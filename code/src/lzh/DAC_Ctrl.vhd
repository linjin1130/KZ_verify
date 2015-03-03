----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:30:32 08/08/2013 
-- Design Name: 
-- Module Name:    DAC_Ctrl - Behavioral 
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
Library UNISIM;
use UNISIM.vcomponents.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DAC_Ctrl is
	generic(
		DAC_Base_Addr	:	std_logic_vector(7 downto 0) := X"40";
		DAC_High_Addr	:	std_logic_vector(7 downto 0) := X"43"
	);
	port(
		sys_clk_80M	:	in	std_logic;--system clock,80MHz
		sys_rst_n	:	in	std_logic;--system reset,high active
		----dac interface---
		fpga_dac_data	:	inout	std_logic_vector(7 downto 0);
		fpga_dac_addr	:	out	std_logic_vector(3 downto 0);
		fpga_dac_rs_n	:	out	std_logic;--dac reset,low active 
		fpga_dac_cs_n	:	out	std_logic;--chip select,low active
		fpga_dac_rw_n	:	out	std_logic;--dac write or read control,low active
		fpga_dac_ld_n	:	out	std_logic;--dac load control,low active
		fpga_dac_en_n	:	out	std_logic;--clock enable,rising edge active
		---inside interface to cpldif module
		cpldif_dac_addr	:	in	std_logic_vector(7 downto 0);
		cpldif_dac_wr_en	:	in	std_logic;--register write enable
		cpldif_dac_wr_data	:	in	std_logic_vector(31 downto 0);
		cpldif_dac_rd_en	:	in	std_logic;--refister read enable
		dac_cpldif_rd_data	:	out	std_logic_vector(31 downto 0)
	);
end DAC_Ctrl;

architecture Behavioral of DAC_Ctrl is

signal addr_sel : std_logic_vector(7 downto 0);
signal addr_latch : std_logic_vector(7 downto 0);--latch adrress,used for dac configure
signal dac_ind	:	std_logic;--1:write dac register;0:write other register
signal dac_set_ctrl0	:	std_logic_vector(31 downto 0);
signal dac_set_ctrl1	:	std_logic_vector(31 downto 0);
signal dac_set_ctrl2	:	std_logic_vector(31 downto 0);
signal dac_set_ctrl3	:	std_logic_vector(31 downto 0);
signal rd_data_reg	:	std_logic_vector(31 downto 0);
---
signal ctrl0_reg	:	std_logic_vector(7 downto 0);
signal ctrl1_reg	:	std_logic_vector(7 downto 0);
signal ctrl2_reg	:	std_logic_vector(7 downto 0);
signal ctrl3_reg	:	std_logic_vector(7 downto 0);
------------
constant con_div	:	std_logic_vector(7 downto 0) := X"50";
signal div_cnt	:	std_logic_vector(7 downto 0);
signal dac_addr_temp	:	std_logic_vector(3 downto 0);
signal dac_data_i	:	std_logic_vector(7 downto 0);
signal dac_data_o	:	std_logic_vector(7 downto 0);
signal dac_rs_temp	:	std_logic;
signal dac_cs_temp	:	std_logic;
signal dac_rw_temp	:	std_logic;
signal dac_ld_temp	:	std_logic;
signal dac_en_temp	:	std_logic;

begin

---IO generate
IO_gen : for i in 0 to 7 generate
IOBUF_inst : IOBUF
generic map (
DRIVE => 12,
IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E/3A only)
IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E/3A only)
IOSTANDARD => "DEFAULT",
SLEW => "SLOW")
port map (
O => dac_data_i(i), -- Buffer output
IO => fpga_dac_data(i), -- Buffer inout port (connect directly to top-level port)
I => dac_data_o(i), -- Buffer input
T => dac_cs_temp -- 
);
end generate;

---**********   register manage  *******
lock_addr : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		addr_sel	<=	X"FF";
		addr_latch	<=	X"FF";
		dac_ind	<=	'0';
	elsif rising_edge(sys_clk_80M) then		
		if(cpldif_dac_addr >= dac_base_addr and cpldif_dac_addr <=	dac_high_addr) then
			addr_sel	<=	cpldif_dac_addr	- dac_base_addr;
			addr_latch	<=	cpldif_dac_addr	- dac_base_addr;
			dac_ind	<=	'1';
		else
			addr_latch	<=	addr_latch;
			addr_sel	<=	X"FF";
			dac_ind	<=	'0';
		end if;
	end if;
end process;
---write register0
reg0_wr : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		dac_set_ctrl0	<=	(others => '0');
	elsif rising_edge(sys_clk_80M) then	
		if(addr_sel = X"00") then
			if(cpldif_dac_wr_en = '1') then
				dac_set_ctrl0	<=	cpldif_dac_wr_data;
			else
				dac_set_ctrl0	<=	dac_set_ctrl0;
			end if;
		else
			dac_set_ctrl0	<=	dac_set_ctrl0;
		end if;
	end if;
end process;
---write register1
reg1_wr : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		dac_set_ctrl1	<=	(others => '0');
	elsif rising_edge(sys_clk_80M) then		
		if(addr_sel = X"01") then
			if(cpldif_dac_wr_en = '1') then
				dac_set_ctrl1	<=	cpldif_dac_wr_data;
			else
				dac_set_ctrl1	<=	dac_set_ctrl1;
			end if;
		else
			dac_set_ctrl1	<=	dac_set_ctrl1;
		end if;
	end if;
end process;
---write register2
reg2_wr : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		dac_set_ctrl2	<=	(others => '0');
	elsif rising_edge(sys_clk_80M) then	
		if(addr_sel = X"02") then
			if(cpldif_dac_wr_en = '1') then
				dac_set_ctrl2	<=	cpldif_dac_wr_data;
			else
				dac_set_ctrl2	<=	dac_set_ctrl2;
			end if;
		else
			dac_set_ctrl2	<=	dac_set_ctrl2;
		end if;
	end if;
end process;
---write register3
reg3_wr : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		dac_set_ctrl3	<=	(others => '0');
	elsif rising_edge(sys_clk_80M) then		
		if(addr_sel = X"03") then
			if(cpldif_dac_wr_en = '1') then
				dac_set_ctrl3	<=	cpldif_dac_wr_data;
			else
				dac_set_ctrl3	<=	dac_set_ctrl3;
			end if;
		else
			dac_set_ctrl3	<=	dac_set_ctrl3;
		end if;
	end if;
end process;

---read register0
reg0_rd : process(sys_clk_80M)
begin
	if rising_edge(sys_clk_80M) then
		if(cpldif_dac_rd_en = '1') then
			if(addr_sel = X"00") then
				rd_data_reg	<=	dac_set_ctrl0;
			elsif(addr_sel = X"01") then
				rd_data_reg	<=	dac_set_ctrl1;
			elsif(addr_sel = X"02") then
				rd_data_reg	<=	dac_set_ctrl2;
			elsif(addr_sel = X"03") then
				rd_data_reg	<=	dac_set_ctrl3;
			else
				rd_data_reg	<=	rd_data_reg;
			end if;
		else
			rd_data_reg	<=	rd_data_reg;
		end if;
	end if;
end process;

dac_cpldif_rd_data	<= 	rd_data_reg;
---********* end ********************************

---***** dac interface control ************
--- count process---
---00~3F->write data;
---40~4F->load enable;
cnt_pro : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		div_cnt	<=	con_div;
	elsif rising_edge(sys_clk_80M) then
		if(cpldif_dac_wr_en = '1' and dac_ind = '1') then--has a data write into register
			div_cnt	<=	X"00";
		elsif(div_cnt = con_div) then
			div_cnt	<=	div_cnt;
		elsif(div_cnt >= X"40" and div_cnt < con_div) then
			div_cnt	<=	div_cnt + '1';
		else
			div_cnt	<=	div_cnt + '1';
		end if;
	end if;
end process;
----
ctrl0_reg	<=	dac_set_ctrl0((8*conv_integer(div_cnt(5 downto 4))+7) downto 8*conv_integer(div_cnt(5 downto 4)));
ctrl1_reg	<=	dac_set_ctrl1((8*conv_integer(div_cnt(5 downto 4))+7) downto 8*conv_integer(div_cnt(5 downto 4)));
ctrl2_reg	<=	dac_set_ctrl2((8*conv_integer(div_cnt(5 downto 4))+7) downto 8*conv_integer(div_cnt(5 downto 4)));
ctrl3_reg	<=	dac_set_ctrl3((8*conv_integer(div_cnt(5 downto 4))+7) downto 8*conv_integer(div_cnt(5 downto 4)));
---	generate 'dac_en_n'
dac_en_pro : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		dac_en_temp	<=	'1';
	elsif rising_edge(sys_clk_80M) then
		if(div_cnt >= X"00" and div_cnt	<= X"47") then
			dac_en_temp	<=	div_cnt(3);
		else
			dac_en_temp	<=	'1';
		end if;
	end if;
end process;
---generate 'dac_cs_n'
dac_cs_pro : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		dac_cs_temp	<=	'1';
	elsif rising_edge(sys_clk_80M) then	
		if(div_cnt >= X"00" and div_cnt < X"40") then	
			if(addr_latch = X"00") then
				if(ctrl0_reg = X"00") then--X"00" not been writen into dac chip
					dac_cs_temp	<=	'1';
				else
					dac_cs_temp	<=	'0';
				end if;
			elsif(addr_latch = X"01") then
				if(ctrl1_reg = X"00") then
					dac_cs_temp	<=	'1';
				else
					dac_cs_temp	<=	'0';
				end if;
			elsif(addr_latch = X"02") then
				if(ctrl2_reg = X"00") then
					dac_cs_temp	<=	'1';
				else
					dac_cs_temp	<=	'0';
				end if;
			elsif(addr_latch = X"03") then
				if(ctrl3_reg = X"00") then
					dac_cs_temp	<=	'1';
				else
					dac_cs_temp	<=	'0';
				end if;
			else
				dac_cs_temp	<=	'1';
			end if;
		else
			dac_cs_temp	<=	'1';
		end if;
	end if;
end process;
---generate 'dac_addr','dac_data'
dac_addr_pro : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		dac_addr_temp	<=	X"0";
		dac_data_o	<=	X"00";
	elsif rising_edge(sys_clk_80M) then
		if(addr_latch = X"00") then
			dac_addr_temp	<=	div_cnt(5 downto 4) + X"0";--channel 0~3
			dac_data_o	<=	ctrl0_reg;
		elsif(addr_latch = X"01") then
			dac_addr_temp	<=	div_cnt(5 downto 4)+ X"4";--channel 4~7
			dac_data_o	<=	ctrl1_reg;
		elsif(addr_latch = X"02") then
			dac_addr_temp	<=	div_cnt(5 downto 4)+ X"8";--channel 8~11
			dac_data_o	<=	ctrl2_reg;
		elsif(addr_latch = X"03") then
			dac_addr_temp	<=	div_cnt(5 downto 4)+ X"C";--channel 12~15
			dac_data_o	<=	ctrl3_reg;
		else
			dac_addr_temp	<=	dac_addr_temp;
			dac_data_o	<=	dac_data_o;
		end if;
	end if;
end process;
---generate load enable
ld_en_pro : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		dac_ld_temp	<=	'1';
	elsif rising_edge(sys_clk_80M) then
		if(div_cnt >= X"40" and div_cnt	<= X"47") then
			dac_ld_temp	<=	'0';
		else
			dac_ld_temp	<=	'1';
		end if;
	end if;
end process;

dac_rs_temp	<=	'1';
dac_rw_temp	<=	'0';--always wtite
fpga_dac_addr	<=	dac_addr_temp;
fpga_dac_rs_n	<=	dac_rs_temp;
fpga_dac_cs_n	<=	dac_cs_temp;
fpga_dac_rw_n	<=	dac_rw_temp;
fpga_dac_ld_n	<=	dac_ld_temp;
fpga_dac_en_n	<=	dac_en_temp;

end Behavioral;

