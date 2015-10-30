----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:51:11 02/27/2015 
-- Design Name: 
-- Module Name:    kz_reg_resolve - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- 完成LD触发脉冲验证模块的寄存器解析功能
-- 1.验证起始与停止功能，寄存器地址
-- 2.验证随机数写入功能
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

entity kz_reg_resolve is
	generic(
			tdc_base_addr	:	std_logic_vector(7 downto 0) := X"10";
			tdc_high_addr	:	std_logic_vector(7 downto 0) := X"14";
			KZ_VRF_base_addr	:	std_logic_vector(7 downto 0) := X"B0";
			KZ_VRF_high_addr	:	std_logic_vector(7 downto 0) := X"BF"
		);
	port(
	-- fix by herry make sys_clk_80M to sys_clk_160M
	   sys_clk_80M	:	in	std_logic;--system clock,80MHz
		sys_rst_n	:	in	std_logic;--system reset,low active
		
		fifo_clr : OUT std_logic;
		verify_active_1 : OUT std_logic;
		verify_active_2 : OUT std_logic;
		control_clk_sel : OUT std_logic;
		
		Dac_Ena 		:  OUT std_logic;
		Dac_data		:	out std_logic_vector(15 downto 0);
		
		store_en			:	out		std_logic;--system clock,200MHz
		flag_bit			:	out		std_logic;--system clock,200MHz
		ram_wr_en		:	out		std_logic;--system clock,200MHz
--		ram_wr_en_2		:	out		std_logic;--system clock,200MHz
		ram_wr_data		:	out		std_logic_vector(15 downto 0);
		ram_wr_addr		:	out		std_logic_vector(15 downto 0);
		---cpldif module
		clk_delay					:	out	std_logic_vector(5 downto 0);
		cpldif_kz_vrf_addr		:	in	std_logic_vector(7 downto 0);
		cpldif_kz_vrf_wr_en		:	in	std_logic;
		cpldif_kz_vrf_rd_en		:	in	std_logic;
		cpldif_kz_vrf_wr_data	:	in	std_logic_vector(31 downto 0);
		kz_vrf_cpldif_rd_data	:	out	std_logic_vector(31 downto 0);
		
		delay_load_en		:	out	std_logic_vector(19 downto 0);
		delay_load_data	:	out	std_logic_vector(4 downto 0)
	);
end kz_reg_resolve;

architecture Behavioral of kz_reg_resolve is
	signal addr_sel : std_logic_vector(7 downto 0);
	signal pulse_data : std_logic_vector(7 downto 0);

	signal verify_1 : std_logic;
	signal verify_2 : std_logic;
begin

kz_vrf_cpldif_rd_data	<= (others => '1');
--****** register manager ***
lock_addr : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		addr_sel	<=	X"FF";
	elsif rising_edge(sys_clk_80M) then
		if(cpldif_kz_vrf_addr >= kz_vrf_Base_Addr and cpldif_kz_vrf_addr <=	kz_vrf_High_Addr) then
			addr_sel	<=	cpldif_kz_vrf_addr - KZ_VRF_base_addr;
		else
			addr_sel	<=	X"FF";
		end if;
	end if;
end process;


process(cpldif_kz_vrf_wr_data(3 downto 0))
begin
	case cpldif_kz_vrf_wr_data(3 downto 0) is
		when x"0" => pulse_data <= x"00";
		when x"4" => pulse_data <= x"00";
		when x"8" => pulse_data <= x"00";
		when x"C" => pulse_data <= x"00";
		when x"1" => pulse_data <= x"01";
		when x"5" => pulse_data <= x"02";
		when x"9" => pulse_data <= x"04";
		when x"D" => pulse_data <= x"08";
		when x"2" => pulse_data <= x"10";
		when x"3" => pulse_data <= x"10";
		when x"6" => pulse_data <= x"20";
		when x"7" => pulse_data <= x"20";
		when x"A" => pulse_data <= x"40";
		when x"B" => pulse_data <= x"40";
		when x"E" => pulse_data <= x"80";
		when x"F" => pulse_data <= x"80";
		when others => pulse_data <= x"00";
	end case;
end process;

process(sys_clk_80M, sys_rst_n)
begin
	if(sys_rst_n = '0') then
		ram_wr_addr	<= (others => '0');
		ram_wr_data	<= (others => '0');
		ram_wr_en	<= '0';
	elsif rising_edge(sys_clk_80M) then
		if(addr_sel = x"00" and cpldif_kz_vrf_wr_en = '1') then--CONTROL REG
			ram_wr_en	<= '1';
			ram_wr_addr	<= cpldif_kz_vrf_wr_data(31 downto 16);
			ram_wr_data	<= cpldif_kz_vrf_wr_data(15 downto 0);
		else
			ram_wr_en	<= '0';
		end if;
	end if;
end process;

process(sys_clk_80M, sys_rst_n)
begin
	if(sys_rst_n = '0') then
		delay_load_en		<= (others => '0');
		delay_load_data	<= (others => '0');
	elsif rising_edge(sys_clk_80M) then
		if(addr_sel = x"01" and cpldif_kz_vrf_wr_en = '1') then--CONTROL REG
			delay_load_en		<= cpldif_kz_vrf_wr_data(27 downto 8);
			delay_load_data	<= cpldif_kz_vrf_wr_data(4 downto 0);
		else
			delay_load_en		<= (others => '0');
		end if;
	end if;
end process;

process(sys_clk_80M, sys_rst_n)
begin
	if(sys_rst_n = '0') then
		verify_1		<= '1';
		verify_2		<= '0';
	elsif rising_edge(sys_clk_80M) then
		if(addr_sel = x"02" and cpldif_kz_vrf_wr_en = '1') then--CONTROL REG
			verify_1		<= cpldif_kz_vrf_wr_data(0);
			verify_2		<= cpldif_kz_vrf_wr_data(1);
		end if;
	end if;
end process;

process(sys_clk_80M, sys_rst_n)
begin
	if(sys_rst_n = '0') then
		Dac_Ena		<= '0';
		Dac_data		<= (others => '0');
	elsif rising_edge(sys_clk_80M) then
		if(addr_sel = x"03" and cpldif_kz_vrf_wr_en = '1') then--CONTROL REG
			Dac_Ena		<= '1';
			Dac_data		<= cpldif_kz_vrf_wr_data(15 downto 0);
		else
			Dac_Ena		<= '0';
		end if;
	end if;
end process;

process(sys_clk_80M, sys_rst_n)
begin
	if(sys_rst_n = '0') then
		control_clk_sel		<= '0';
	elsif rising_edge(sys_clk_80M) then
		if(addr_sel = x"04" and cpldif_kz_vrf_wr_en = '1') then--CONTROL REG
			control_clk_sel		<= cpldif_kz_vrf_wr_data(0);
		end if;
	end if;
end process;
process(sys_clk_80M, sys_rst_n)
begin
	if(sys_rst_n = '0') then
		flag_bit		<= '0';
		store_en		<= '0';
	elsif rising_edge(sys_clk_80M) then
		if(addr_sel = x"06" and cpldif_kz_vrf_wr_en = '1') then--CONTROL REG
			flag_bit		<= cpldif_kz_vrf_wr_data(0);
			store_en		<= cpldif_kz_vrf_wr_data(1);
		end if;
	end if;
end process;
process(sys_clk_80M, sys_rst_n)
begin
	if(sys_rst_n = '0') then
		clk_delay		<= "001000";
	elsif rising_edge(sys_clk_80M) then
		if(addr_sel = x"05" and cpldif_kz_vrf_wr_en = '1') then--CONTROL REG
			clk_delay		<= cpldif_kz_vrf_wr_data(5 downto 0);
		end if;
	end if;
end process;
---generate run and stop start
process(sys_clk_80M, sys_rst_n)
begin
	if(sys_rst_n = '0') then
		verify_active_1			<= '0';
		verify_active_2			<= '0';
		fifo_clr						<= '0';
	elsif rising_edge(sys_clk_80M) then
		if(cpldif_kz_vrf_addr = x"10" and cpldif_kz_vrf_wr_en = '1') then--CONTROL REG
			if(cpldif_kz_vrf_wr_data(7 downto 0) = x"0F") then
				fifo_clr	<= '1';
				verify_active_1	<= verify_1;
				verify_active_2	<= verify_2;
			elsif(cpldif_kz_vrf_wr_data(7 downto 0) = x"F0") then
				verify_active_1	<= '0';
				verify_active_2	<= '0';
			end if;
		else
			fifo_clr	<= '0';
		end if;
	end if;
end process;
end Behavioral;

