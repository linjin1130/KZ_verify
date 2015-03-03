----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:56:23 08/29/2013 
-- Design Name: 
-- Module Name:    TIME - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TIME_CTRL is
	generic(
			time_basic_addr	:	std_logic_vector(7 downto 0) := X"20";
			time_high_addr	:	std_logic_vector(7 downto 0) := X"23"
		);
    Port ( sys_clk : in  STD_LOGIC;
           sys_rst_n : in  STD_LOGIC;
           cpldif_time_addr : in  STD_LOGIC_VECTOR (7 downto 0);
           cpldif_time_wr_en : in  STD_LOGIC;
           cpldif_time_rd_en : in  STD_LOGIC;
           cpldif_time_wr_data : in  STD_LOGIC_VECTOR (31 downto 0);
           time_cpldif_rd_data : out  STD_LOGIC_VECTOR (31 downto 0);
           gps_pps : in  STD_LOGIC;
			  tp		: out std_logic_vector(1 downto 0);
           time_local_cur : out  STD_LOGIC_VECTOR (47 downto 0));
end TIME_CTRL;

architecture Behavioral of TIME_CTRL is

signal gps_pps_syn: std_logic;
signal gps_pps_syn_1d: std_logic;
signal gps_pps_syn_2d: std_logic;
signal gps_pps_syn_pulse: std_logic;
signal time_given_valid: std_logic;
signal time_given_valid_1d: std_logic;
signal time_given_valid_rise_pulse: std_logic;
signal time_given_valid_fall_pulse: std_logic;
signal time_cnt_en: std_logic;
signal gps_pps_ok: std_logic;
signal time_given_valid_cnt: std_logic;
signal time_cnt_rst: std_logic;
signal time_cnt_wait_en: std_logic;
signal time_givened: std_logic;
signal gps_pps_syn_pulse_1p: std_logic;

signal addr_sel: std_logic_vector(7 downto 0);
signal time_reg_given_l: std_logic_vector(31 downto 0);
signal time_reg_given_h: std_logic_vector(31 downto 0);
signal time_reg_local_cur_l: std_logic_vector(31 downto 0);
signal time_reg_local_cur_h: std_logic_vector(31 downto 0);
signal rd_data_reg: std_logic_vector(31 downto 0);
signal time_local_cnt_cur: std_logic_vector(47 downto 0);
signal time_local_gps_cur: std_logic_vector(47 downto 0);
signal time_local_cur_sig: std_logic_vector(47 downto 0);


signal time_cnt: std_logic_vector(27 downto 0);
signal time_cnt_wait: std_logic_vector(27 downto 0);
signal gps_pps_ok_cnt: std_logic_vector(27 downto 0);

signal par_time_pps: std_logic_vector(27 downto 0):= x"4C4B3FF";--1s
signal par_time_pps_timeout: std_logic_vector(27 downto 0):= x"7270E00";--1.5s
---FOR TEST
--signal par_time_pps: std_logic_vector(27 downto 0):= x"000031F";--10us by 80M
--signal par_time_pps_timeout: std_logic_vector(27 downto 0):= x"00004AF";--15us by 80M


begin

tp(0) <= gps_pps_syn_pulse;
tp(1) <= time_given_valid;

---------------------------------register manager-------------------------------------------------------
lock_addr : process(sys_clk)
begin
	if rising_edge(sys_clk) then
		if(sys_rst_n = '0') then
			addr_sel	<=	X"FF";
		elsif(cpldif_time_addr >= time_basic_addr and cpldif_time_addr <=	time_high_addr) then
			addr_sel	<=	cpldif_time_addr	- time_basic_addr;
		else
			addr_sel	<=	X"FF";
		end if;
	end if;
end process;
---write register0: time_given_l: rw,
reg_time_given_l : process(sys_clk)
begin
	if rising_edge(sys_clk) then
		if(sys_rst_n = '0') then
			time_reg_given_l	<=	(others => '0');
		elsif(addr_sel = X"00") then
			if(cpldif_time_wr_en = '1') then
				time_reg_given_l	<=	cpldif_time_wr_data;
			else
				time_reg_given_l	<=	time_reg_given_l;
			end if;
		else
			time_reg_given_l	<=	time_reg_given_l;
		end if;
	end if;
end process;

---write register1: time_given_h: rw,
reg_time_given_h : process(sys_clk)
begin
	if rising_edge(sys_clk) then
		if(sys_rst_n = '0') then
			time_reg_given_h	<=	(others => '0');
		elsif(addr_sel = X"01") then
			if(cpldif_time_wr_en = '1') then
				time_reg_given_h	<=	cpldif_time_wr_data;
			else
				time_reg_given_h	<=	time_reg_given_h;
			end if;
		else
			time_reg_given_h	<=	time_reg_given_h;
		end if;
	end if;
end process;
---------------------------------------------------------
-------------------read--------------------------------------
---read register
reg_rd : process(sys_clk)
begin
	if rising_edge(sys_clk) then
		if(cpldif_time_rd_en = '1') then
			if(addr_sel = X"00") then
				rd_data_reg	<=	time_reg_given_l;
			elsif(addr_sel = X"01") then
				rd_data_reg	<=	time_reg_given_h;
			elsif(addr_sel = X"02") then
				rd_data_reg	<=	time_reg_local_cur_l;
			elsif(addr_sel = X"03") then
				rd_data_reg	<=	time_reg_local_cur_h;
			else
				rd_data_reg	<=	rd_data_reg;
			end if;
		else
			rd_data_reg	<=	rd_data_reg;
		end if;
	end if;
end process;

time_cpldif_rd_data	<= 	rd_data_reg;
-----------------------------------end write read register control---------
--------------------------------------register analysis
reg_time_given_h_valid_cnt : process(sys_clk)
begin
	if rising_edge(sys_clk) then
		if(addr_sel = X"01") then
			if(cpldif_time_wr_en = '1') then
				time_given_valid_cnt	<=	'1';
			else
				time_given_valid_cnt	<=	'0';
			end if;
		else
			time_given_valid_cnt	<=	'0';
		end if;
	end if;
end process;
----
time_local_cnt_cur_pro : process(sys_clk)
begin
	if rising_edge(sys_clk) then
		if(sys_rst_n = '0') then
			time_local_cnt_cur	<=	(others => '0');
		elsif(time_given_valid_cnt = '1')then
			time_local_cnt_cur(31 downto 0)	<= time_reg_given_l;
			time_local_cnt_cur(47 downto 32)	<= time_reg_given_h(15 downto 0);
		elsif(time_cnt = par_time_pps)then -----12.5ns clk, 1s time
			time_local_cnt_cur(31 downto 0)	<= time_local_cnt_cur(31 downto 0) + '1';
		else
			time_local_cnt_cur	<= time_local_cnt_cur;
		end if;
	end if;
end process;

time_cnt_en_pro : process(sys_clk)
begin
	if rising_edge(sys_clk) then
		if(time_given_valid_cnt = '1')then
			time_cnt_en	<=	'1';
			time_cnt_rst <= '1';
		else
			time_cnt_en	<=	time_cnt_en;
			time_cnt_rst <= '0';
		end if;
	end if;
end process;

time_cnt_pro : process(sys_clk)
begin
	if rising_edge(sys_clk) then
		if(time_cnt_rst = '1') then
			time_cnt	<=	(others => '0');
		elsif(time_cnt_en = '1' and time_cnt < par_time_pps)then
			time_cnt	<=	time_cnt + '1';
--		elsif(time_cnt >= par_time_pps)then
--			time_cnt <= (others => '0');
		else
			time_cnt <= (others => '0');
--			time_cnt	<=	time_cnt;
		end if;
	end if;
end process;

time_cnt_wait_en_pro : process(sys_clk)
begin
	if rising_edge(sys_clk) then
		if(time_given_valid_cnt = '1')then
			time_cnt_wait_en	<=	'1';
		elsif(gps_pps_syn_pulse = '1')then
			time_cnt_wait_en	<=	'0';
		else
			time_cnt_wait_en	<=	time_cnt_wait_en;
		end if;
	end if;
end process;

time_cnt_wait_pro : process(sys_clk)
begin
	if rising_edge(sys_clk) then
		if(time_cnt_rst = '1') then
			time_cnt_wait	<=	(others => '0');
		elsif(time_cnt_wait_en = '1' and time_cnt_wait <= par_time_pps_timeout)then
			time_cnt_wait	<=	time_cnt_wait + '1';
--		elsif(time_cnt_wait = par_time_pps_timeout)then   ------->1.5s time
--			time_cnt_wait <= time_cnt_wait;
----		elsif(gps_pps_syn_pulse = '1')then
----			time_cnt_wait	<=	(others => '0');
		else
			time_cnt_wait	<=	time_cnt_wait;
		end if;
	end if;
end process;

-----------------------------------------------------------------------
------------------------------gps--------------------------------------
reg_time_given_h_valid : process(sys_clk)
begin
	if rising_edge(sys_clk) then
--		if(sys_rst_n = '0') then
--			time_given_valid	<=	'0';
--		els
		if(gps_pps_syn_pulse = '1') then
				time_given_valid	<=	'0';
		elsif(addr_sel = X"01") then
			if(cpldif_time_wr_en = '1') then
				time_given_valid	<=	'1';
			elsif(gps_pps_syn_pulse = '1') then
				time_given_valid	<=	'0';
			else
				time_given_valid	<=	time_given_valid;
			end if;
		else
			time_given_valid	<=	time_given_valid;
		end if;
	end if;
end process;

time_givened_pro : process(sys_clk,sys_rst_n)
begin
	if (sys_rst_n = '0') then
		time_givened	<=	'0';
	elsif rising_edge(sys_clk) then
		if(time_given_valid = '1') then
			time_givened	<=	'1';
		else
			time_givened	<=	time_givened;
		end if;
	end if;
end process;

------rise edge detect
GPS_syn_pro : process(sys_clk)
begin
	if rising_edge(sys_clk) then
		if(sys_rst_n = '0') then
			gps_pps_syn	<=	'0';
			gps_pps_syn_1d	<=	'0';
			gps_pps_syn_2d	<=	'0';
			gps_pps_syn_pulse_1p <= '0';
			gps_pps_syn_pulse <= '0';
		else
			gps_pps_syn <= gps_pps;
			gps_pps_syn_1d	<=	gps_pps_syn;
			gps_pps_syn_2d	<=	gps_pps_syn_1d;
			gps_pps_syn_pulse_1p <= gps_pps_syn_1d and (not gps_pps_syn_2d);
			gps_pps_syn_pulse <= gps_pps_syn_pulse_1p;
		end if;
	end if;
end process;



---rise edge of time_given_valid detect
time_given_valid_rise_pro : process(sys_clk)
begin
	if rising_edge(sys_clk) then
		if(sys_rst_n = '0') then
			time_given_valid_1d	<=	'0';
			time_given_valid_rise_pulse	<=	'0';
			time_given_valid_fall_pulse	<=	'0';
		else
			time_given_valid_1d <= time_given_valid;
			time_given_valid_rise_pulse	<=	time_given_valid and (not time_given_valid_1d);
			time_given_valid_fall_pulse	<=	not time_given_valid and (time_given_valid_1d);
		end if;
	end if;
end process;


-----------------------------------------------------------------------
--------------------------time local by gps pps---------------------------------------------
time_local_gps_cur_pro : process(sys_clk,sys_rst_n)
begin
	if(sys_rst_n = '0') then
			time_local_gps_cur	<=	(others => '0');
	elsif rising_edge(sys_clk) then
		if(gps_pps_syn_pulse = '1' and time_given_valid = '1')then
			time_local_gps_cur(31 downto 0)	<= time_reg_given_l;
			time_local_gps_cur(47 downto 32)	<= time_reg_given_h(15 downto 0);
		elsif(time_givened = '1' and gps_pps_syn_pulse = '1')then
			time_local_gps_cur(31 downto 0)	<= time_local_gps_cur(31 downto 0) + '1';
		else
			time_local_gps_cur	<= time_local_gps_cur;
		end if;
	end if;
end process;
-------------------------gps pps ok cnt----------------------------
gps_pps_ok_cnt_pro : process(sys_clk)
begin
	if rising_edge(sys_clk) then
		if(sys_rst_n = '0') then
			gps_pps_ok_cnt	<=	(others => '0');
		elsif(gps_pps_syn_pulse = '1')then
			gps_pps_ok_cnt	<=	(others => '0');
		elsif(gps_pps_ok_cnt < par_time_pps_timeout)then
			gps_pps_ok_cnt	<=	gps_pps_ok_cnt + '1';
		else
			gps_pps_ok_cnt	<=	gps_pps_ok_cnt;
		end if;
	end if;
end process;

gps_pps_ok_pro : process(sys_clk)
begin
	if rising_edge(sys_clk) then
		if(sys_rst_n = '0') then
			gps_pps_ok <= '1';
		elsif(gps_pps_ok_cnt >= par_time_pps_timeout)then--------1.5S TIME
			gps_pps_ok	<=	'0';
		elsif(time_cnt_wait >= par_time_pps_timeout) then
			gps_pps_ok  <= '0';
		else
			gps_pps_ok	<=	'1';
		end if;
	end if;
end process;

-----choose time_local_cur

time_local_cur_pro : process(sys_clk)
begin
	if rising_edge(sys_clk) then
		if(gps_pps_ok = '1')then--------1.5S TIME
			time_local_cur_sig	<=	time_local_gps_cur;
		else
			time_local_cur_sig	<=	time_local_cnt_cur;
		end if;
	end if;
end process;

time_reg_local_cur_l <= time_local_cur_sig(31 downto 0);
time_reg_local_cur_h(15 downto 0) <= time_local_cur_sig(47 downto 32);
time_reg_local_cur_h(30 downto 16) <= (others => '0');
time_reg_local_cur_h(31) <= gps_pps_ok;

time_local_cur <= time_local_cur_sig;
end Behavioral;

