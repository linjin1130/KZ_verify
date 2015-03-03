library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity count_measure is
	generic(
		CNT_Base_Addr 			: 	std_logic_vector(7 downto 0) := X"50";
		CNT_High_Addr 			: 	std_logic_vector(7 downto 0) := X"79"
	);
	port(
		------ system clock and reset signal -------
		sys_clk_160M			:	in	std_logic;
		sys_rst_n				:	in	std_logic;
		------ 16 channel signal input ------
		apd_fpga_hit 			: 	in	std_logic_vector(15 downto 0);
		------ qtel module,8 channel coincidence signal input ------
		qtel_counter_match 		: 	in	std_logic_vector(7 downto 0);	
		------ time input ------
		tdc_count_time_value	:	in	std_logic_vector(31 downto 0);
		------ cpld module ------
		cpldif_count_addr		:	in	std_logic_vector(7 downto 0);
		cpldif_count_wr_en		:	in	std_logic;
		cpldif_count_rd_en		:	in	std_logic;
		cpldif_count_wr_data	:	in	std_logic_vector(31 downto 0);
		count_cpldif_rd_data	:	out	std_logic_vector(31 downto 0)
	);
end count_measure;


architecture Behavioral of count_measure is

	------ apd hit and qtel hit signal, to count ------
	signal apd_fpga_hit_1d 	: 	std_logic_vector(15 downto 0);
	signal apd_fpga_hit_2d 	: 	std_logic_vector(15 downto 0);
	signal apd_hit_cnt		: 	std_logic_vector(15 downto 0);
	signal qtel_hit_cnt		: 	std_logic_vector(7 downto 0);
	------ system clock and reset signal , address select signal -------
	signal sys_rst			:	std_logic;
	signal sys_clk			: 	std_logic;
	signal addr_sel 		: 	std_logic_vector(7 downto 0);
	------ count control register and count time range ------
	signal count_ctrl0		:	std_logic_vector(31 downto 0);--apd count control register
	signal count_ctrl1		:	std_logic_vector(31 downto 0);--qtel count control register
	signal count_time_range	:	std_logic_vector(31 downto 0);--count time range ,from 0.1s to 100s
	------ apd hit signal count and latch register ------
	signal chnl_cnt_reg0	:	std_logic_vector(31 downto 0);--latch apd hit signal count of channel 0
	signal chnl_cnt_reg1	:	std_logic_vector(31 downto 0);
	signal chnl_cnt_reg2	:	std_logic_vector(31 downto 0);
	signal chnl_cnt_reg3	:	std_logic_vector(31 downto 0);
	signal chnl_cnt_reg4	:	std_logic_vector(31 downto 0);
	signal chnl_cnt_reg5	:	std_logic_vector(31 downto 0);
	signal chnl_cnt_reg6	:	std_logic_vector(31 downto 0);
	signal chnl_cnt_reg7	:	std_logic_vector(31 downto 0);
	signal chnl_cnt_reg8	:	std_logic_vector(31 downto 0);
	signal chnl_cnt_reg9	:	std_logic_vector(31 downto 0);
	signal chnl_cnt_reg10	:	std_logic_vector(31 downto 0);
	signal chnl_cnt_reg11	:	std_logic_vector(31 downto 0);
	signal chnl_cnt_reg12	:	std_logic_vector(31 downto 0);
	signal chnl_cnt_reg13	:	std_logic_vector(31 downto 0);
	signal chnl_cnt_reg14	:	std_logic_vector(31 downto 0);
	signal chnl_cnt_reg15	:	std_logic_vector(31 downto 0);
	
	signal apd_cnt_reg0		:	std_logic_vector(31 downto 0);--apd hit signal count of channel 0
	signal apd_cnt_reg1		:	std_logic_vector(31 downto 0);
	signal apd_cnt_reg2		:	std_logic_vector(31 downto 0);
	signal apd_cnt_reg3		:	std_logic_vector(31 downto 0);
	signal apd_cnt_reg4		:	std_logic_vector(31 downto 0);
	signal apd_cnt_reg5		:	std_logic_vector(31 downto 0);
	signal apd_cnt_reg6		:	std_logic_vector(31 downto 0);
	signal apd_cnt_reg7		:	std_logic_vector(31 downto 0);
	signal apd_cnt_reg8		:	std_logic_vector(31 downto 0);
	signal apd_cnt_reg9		:	std_logic_vector(31 downto 0);
	signal apd_cnt_reg10	:	std_logic_vector(31 downto 0);
	signal apd_cnt_reg11	:	std_logic_vector(31 downto 0);
	signal apd_cnt_reg12	:	std_logic_vector(31 downto 0);
	signal apd_cnt_reg13	:	std_logic_vector(31 downto 0);
	signal apd_cnt_reg14	:	std_logic_vector(31 downto 0);
	signal apd_cnt_reg15	:	std_logic_vector(31 downto 0);
	------ qtel hit signal count and latch register ------
	signal chnl_match_reg0	:	std_logic_vector(31 downto 0);--latch qtel hit signal count of channel 0
	signal chnl_match_reg1	:	std_logic_vector(31 downto 0);
	signal chnl_match_reg2	:	std_logic_vector(31 downto 0);
	signal chnl_match_reg3	:	std_logic_vector(31 downto 0);
	signal chnl_match_reg4	:	std_logic_vector(31 downto 0);
	signal chnl_match_reg5	:	std_logic_vector(31 downto 0);
	signal chnl_match_reg6	:	std_logic_vector(31 downto 0);
	signal chnl_match_reg7	:	std_logic_vector(31 downto 0);
	
	signal qtel_cnt_reg0	:	std_logic_vector(31 downto 0);--qtel hit signal count of channel 0
	signal qtel_cnt_reg1	:	std_logic_vector(31 downto 0);
	signal qtel_cnt_reg2	:	std_logic_vector(31 downto 0);
	signal qtel_cnt_reg3	:	std_logic_vector(31 downto 0);
	signal qtel_cnt_reg4	:	std_logic_vector(31 downto 0);
	signal qtel_cnt_reg5	:	std_logic_vector(31 downto 0);
	signal qtel_cnt_reg6	:	std_logic_vector(31 downto 0);
	signal qtel_cnt_reg7	:	std_logic_vector(31 downto 0);	
	------ latch time of 16 apd count channel ------
	signal time_value_chnl0		:	std_logic_vector(31 downto 0);--latch time of apd channel 0
	signal time_value_chnl1		:	std_logic_vector(31 downto 0);
	signal time_value_chnl2		:	std_logic_vector(31 downto 0);
	signal time_value_chnl3		:	std_logic_vector(31 downto 0);
	signal time_value_chnl4		:	std_logic_vector(31 downto 0);
	signal time_value_chnl5		:	std_logic_vector(31 downto 0);
	signal time_value_chnl6		:	std_logic_vector(31 downto 0);
	signal time_value_chnl7		:	std_logic_vector(31 downto 0);
	signal time_value_chnl8		:	std_logic_vector(31 downto 0);
	signal time_value_chnl9		:	std_logic_vector(31 downto 0);
	signal time_value_chnl10	:	std_logic_vector(31 downto 0);
	signal time_value_chnl11	:	std_logic_vector(31 downto 0);
	signal time_value_chnl12	:	std_logic_vector(31 downto 0);
	signal time_value_chnl13	:	std_logic_vector(31 downto 0);
	signal time_value_chnl14	:	std_logic_vector(31 downto 0);
	signal time_value_chnl15	:	std_logic_vector(31 downto 0);
	
	------ apd and qtel signal channel enable signal ------
	signal apd_cnt_en			:	std_logic_vector(15 downto 0);
	signal qtel_cnt_en			:	std_logic_vector(7 downto 0);	
	------ count time management ------
	--constant one_second 		: std_logic_vector(27 downto 0) := X"9896800"; --*6.25=1s
	--constant time_100ms		: std_logic_vector(23 downto 0) := X"F42400";  --*6.25=0.1s
	constant time_100ms			: 	std_logic_vector(23 downto 0) := X"F42400";  --*6.25=0.1s
	signal time_100ms_cnt		: 	std_logic_vector(23 downto 0);
	signal clk_100ms			:	std_logic;--one clock cycle per 100ms
	signal clk_100ms_cnt		:	std_logic_vector(9 downto 0);
	signal latch_time_range 	: 	std_logic_vector(9 downto 0);--latch time range, from 0.1s to 100s
	------ count state management ------
	signal cnt_start_en 		: 	std_logic;--count start enable
	signal cnt_end_en 			: 	std_logic;--count end enable
	signal cnt_state 			: 	std_logic;
	signal cnt_en 				: 	std_logic;--count enable
	signal latch_cnt_en 		: 	std_logic;--latch enable	
	------ read and write register ------
	signal rd_data_reg 			: 	std_logic_vector(31 downto 0);
	signal wr_data_reg 			: 	std_logic_vector(31 downto 0);

	
begin
	------ system clock and reset generate ------
	sys_rst <= not sys_rst_n;
	sys_clk <= sys_clk_160M;
	------ read and write register ------
	count_cpldif_rd_data <= rd_data_reg;
	wr_data_reg <= cpldif_count_wr_data;
	------ count state management ------
	cnt_start_en	<=	count_ctrl0(16);
	cnt_end_en		<=	count_ctrl0(17);
	latch_time_range	<=	count_time_range(9 downto 0);
	apd_cnt_en		<=	count_ctrl0(15 downto 0);
	qtel_cnt_en 	<= 	count_ctrl1(7 downto 0);	
	qtel_hit_cnt	<= 	qtel_counter_match;
	------ clk_100ms generate ------
	clk_100ms_pro : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			time_100ms_cnt <= (others => '0');
			clk_100ms <= '0';
		elsif rising_edge(sys_clk) then
			if(cnt_start_en = '1' or cnt_state = '1') then
				if(time_100ms_cnt = time_100ms) then
					time_100ms_cnt <= (others => '0');
					clk_100ms <= '1';
				else
					time_100ms_cnt <= time_100ms_cnt + '1';
					clk_100ms <= '0';
				end if;
			else 
				time_100ms_cnt <= (others => '0');
				clk_100ms <= '0';
			end if;
		end if;
	end process;	
	
	------------ count control process------------
	------ generate latch_cnt_en signal ------
	cnt_range_pro : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			latch_cnt_en <= '0';
			clk_100ms_cnt <= (others => '0');
		elsif rising_edge(sys_clk) then
			if(cnt_en = '1') then
				if(clk_100ms = '1') then
					if(clk_100ms_cnt = 	latch_time_range) then 
						latch_cnt_en <=	'1';
						clk_100ms_cnt <= (others => '0');
					else
						latch_cnt_en <= '0';
						clk_100ms_cnt <= clk_100ms_cnt + '1';
					end if;
				else 
					clk_100ms_cnt <= clk_100ms_cnt;
					latch_cnt_en <= '0';
				end if;
			else
				clk_100ms_cnt <= (others => '0');
				latch_cnt_en <= '0';
			end if;
		end if;
	end process;
	------ generate cnt_en signal ------
	cnt_en_pro: process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
				cnt_en <= '0';
		elsif rising_edge(sys_clk) then
			if(cnt_state = '1') then
				if(clk_100ms = '1') then
					if(clk_100ms_cnt = latch_time_range) then 
						cnt_en <= '0';
					else
						cnt_en <= '1';
					end if;
				else
					cnt_en <= cnt_en;
				end if;
			else
					cnt_en <= '0';
			end if;
		end if;	
	end process;
	------------ end count control process------------
	
	------------ register manager ------------
	lock_addr : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			addr_sel	<=	X"FF";
		elsif rising_edge(sys_clk) then
			if(cpldif_count_addr >= CNT_Base_Addr and cpldif_count_addr <=	CNT_High_Addr) then
				addr_sel	<=	cpldif_count_addr	- CNT_Base_Addr;
			else
				addr_sel	<=	X"FF";
			end if;
		end if;
	end process;
	------ write count state register ------
	reg20_wr: process(sys_rst,sys_clk) 
	begin
		if(sys_rst = '1') then
			count_ctrl0 <= (others => '0');
			cnt_state <= '0';
		elsif rising_edge(sys_clk) then
			if(cnt_start_en = '1') then
					cnt_state	<=	'1';
					count_ctrl0(16)	<=	'0';--clear count start enable
					count_ctrl0(18)	<=	cnt_state;
			elsif(cnt_end_en = '1') then
					cnt_state	<=	'0';
					count_ctrl0(17)	<=	'0';--clear count end enable
					count_ctrl0(18)	<=	cnt_state;
			elsif(addr_sel = x"20") then
				if(cpldif_count_wr_en = '1') then
					count_ctrl0 <= wr_data_reg;
					count_ctrl0(18)	<=	cnt_state;
				else 
					count_ctrl0 <= count_ctrl0;
					count_ctrl0(18)	<=	cnt_state;
				end if;
			else
					cnt_state	<=	cnt_state;
					count_ctrl0(18)	<=	cnt_state;
					count_ctrl0 <= count_ctrl0;
			end if;
		end if;
	end process;	
	------ write qtel count enable register ------	
		reg2A_wr: process(sys_rst,sys_clk)
	begin
		if(sys_rst = '1') then
			count_ctrl1 <= (others => '0');
		elsif rising_edge(sys_clk) then
			if(addr_sel = x"2A") then
				if(cpldif_count_wr_en = '1') then
					count_ctrl1 <= wr_data_reg;
				else 
					count_ctrl1 <= count_ctrl1;
				end if;
			else
				count_ctrl1 <= count_ctrl1;
			end if;
		end if;
	end process;	
	------ write time range ------	
	reg21_wr: process(sys_rst,sys_clk)
	begin
		if(sys_rst = '1') then
			count_time_range <= (others => '0');
		elsif rising_edge(sys_clk) then
			if(addr_sel = x"21") then
				if(cpldif_count_wr_en = '1') then
					count_time_range <= wr_data_reg;
				else 
					count_time_range <= count_time_range;
				end if;
			else
				count_time_range <= count_time_range;
			end if;
		end if;
	end process;		
	------ read register ------
	reg_rd : process(sys_rst,sys_clk)
	begin
		if(sys_rst = '1') then
			rd_data_reg <= (others => '0');
		elsif rising_edge(sys_clk) then
			if(cpldif_count_rd_en = '1') then
				case addr_sel is
					when X"00"	=>	rd_data_reg	<=	chnl_cnt_reg0;--read apd count of channel 0
					when X"01"	=>	rd_data_reg	<=	chnl_cnt_reg1;
					when X"02"	=>	rd_data_reg	<=	chnl_cnt_reg2;
					when X"03"	=>	rd_data_reg	<=	chnl_cnt_reg3;
					when X"04"	=>	rd_data_reg	<=	chnl_cnt_reg4;
					when X"05"	=>	rd_data_reg	<=	chnl_cnt_reg5;
					when X"06"	=>	rd_data_reg	<=	chnl_cnt_reg6;
					when X"07"	=>	rd_data_reg	<=	chnl_cnt_reg7;
					when X"08"	=>	rd_data_reg	<=	chnl_cnt_reg8;
					when X"09"	=>	rd_data_reg	<=	chnl_cnt_reg9;
					when X"0A"	=>	rd_data_reg	<=	chnl_cnt_reg10;
					when X"0B"	=>	rd_data_reg	<=	chnl_cnt_reg11;
					when X"0C"	=>	rd_data_reg	<=	chnl_cnt_reg12;
					when X"0D"	=>	rd_data_reg	<=	chnl_cnt_reg13;
					when X"0E"	=>	rd_data_reg	<=	chnl_cnt_reg14;
					when X"0F"	=>	rd_data_reg	<=	chnl_cnt_reg15;
					when X"10"	=>	rd_data_reg	<=	time_value_chnl0;--read latch time of channel 0
					when X"11"	=>	rd_data_reg	<=	time_value_chnl1;
					when X"12"	=>	rd_data_reg	<=	time_value_chnl2;
					when X"13"	=>	rd_data_reg	<=	time_value_chnl3;
					when X"14"	=>	rd_data_reg	<=	time_value_chnl4;
					when X"15"	=>	rd_data_reg	<=	time_value_chnl5;
					when X"16"	=>	rd_data_reg	<=	time_value_chnl6;
					when X"17"	=>	rd_data_reg	<=	time_value_chnl7;
					when X"18"	=>	rd_data_reg	<=	time_value_chnl8;
					when X"19"	=>	rd_data_reg	<=	time_value_chnl9;
					when X"1A"	=>	rd_data_reg	<=	time_value_chnl10;
					when X"1B"	=>	rd_data_reg	<=	time_value_chnl11;
					when X"1C"	=>	rd_data_reg	<=	time_value_chnl12;
					when X"1D"	=>	rd_data_reg	<=	time_value_chnl13;
					when X"1E"	=>	rd_data_reg	<=	time_value_chnl14;
					when X"1F"	=>	rd_data_reg	<=	time_value_chnl15;
					when X"20"	=>	rd_data_reg	<=	count_ctrl0;	--read count control state
					when X"21"	=>	rd_data_reg	<=	count_time_range; --read count time range
					when X"22"  =>	rd_data_reg	<=	chnl_match_reg0;--read qtel count of channel 0;
					when X"23"  =>	rd_data_reg	<=	chnl_match_reg1;
					when X"24"  =>	rd_data_reg	<=	chnl_match_reg2;
					when X"25"  =>	rd_data_reg	<=	chnl_match_reg3;
					when X"26"  =>	rd_data_reg	<=	chnl_match_reg4;
					when X"27"  =>	rd_data_reg	<=	chnl_match_reg5;
					when X"28"  =>	rd_data_reg	<=	chnl_match_reg6;
					when X"29"  =>	rd_data_reg	<=	chnl_match_reg7;
					when X"2A"	=>	rd_data_reg	<=	count_ctrl1;
					when others	=>	rd_data_reg	<=	rd_data_reg;
				end case;
			else 
				rd_data_reg	<=	rd_data_reg;
			end if;
		end if;
	end process;
	------------ end register manager ------------
		
	------ apd hit signal synchronization ------
	apd_syn_pro : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			apd_hit_cnt <= (others => '0');
			apd_fpga_hit_1d	<=	(others => '0');
			apd_fpga_hit_2d	<=	(others => '0');
		elsif rising_edge(sys_clk)	then
			apd_fpga_hit_1d <= apd_fpga_hit;
			apd_fpga_hit_2d <= apd_fpga_hit_1d;
			apd_hit_cnt <= apd_fpga_hit_2d and (not apd_fpga_hit_1d);
		end if;
	end process;
	
	------------ apd hit signal count and latch process ------------
	------ channel 0 count ------
	apd0_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			apd_cnt_reg0		<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(apd_cnt_en(0) = '1') then --count enable
				if(cnt_en = '1') then --range enable
					if(apd_hit_cnt(0) = '1') then --hit enable
						apd_cnt_reg0	<=	apd_cnt_reg0 + '1';
					else
						apd_cnt_reg0	<=	apd_cnt_reg0;
					end if;
				else
					apd_cnt_reg0	<=	(others => '0');
				end if;
			else
				apd_cnt_reg0	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 0 latch ------
	latch_cnt0 : process(sys_clk,sys_rst) begin
		if(sys_rst = '1') then
			chnl_cnt_reg0	<=	(others => '0');
			time_value_chnl0	<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(cnt_end_en = '1') then
				chnl_cnt_reg0	<=	(others => '0');
				time_value_chnl0	<=	(others => '0');
			elsif(apd_cnt_en(0) = '1') then
				if(latch_cnt_en = '1') then
					chnl_cnt_reg0	<=	apd_cnt_reg0;
					time_value_chnl0	<=	tdc_count_time_value;
				else
					chnl_cnt_reg0	<=	chnl_cnt_reg0;
					time_value_chnl0	<=	time_value_chnl0;
				end if;
			else
				chnl_cnt_reg0	<=	(others => '0');
				time_value_chnl0	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 1 count ------
	apd1_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			apd_cnt_reg1		<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(apd_cnt_en(1) = '1') then
				if(cnt_en = '1') then
					if(apd_hit_cnt(1) = '1') then
						apd_cnt_reg1	<=	apd_cnt_reg1 + '1';
					else
						apd_cnt_reg1	<=	apd_cnt_reg1;
					end if;
				else
					apd_cnt_reg1	<=	(others => '0');
				end if;
			else
				apd_cnt_reg1	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 1 latch ------
	latch_cnt1 : process(sys_clk,sys_rst) begin
		if(sys_rst = '1') then
			chnl_cnt_reg1	<=	(others => '0');
			time_value_chnl1	<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(cnt_end_en = '1') then
				chnl_cnt_reg1	<=	(others => '0');
				time_value_chnl1	<=	(others => '0');
			elsif(apd_cnt_en(1) = '1') then
				if(latch_cnt_en = '1') then
					chnl_cnt_reg1	<=	apd_cnt_reg1;
					time_value_chnl1	<=	tdc_count_time_value;
				else
					chnl_cnt_reg1	<=	chnl_cnt_reg1;
					time_value_chnl1	<=	time_value_chnl1;
				end if;
			else
				chnl_cnt_reg1	<=	(others => '0');
				time_value_chnl1	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 2 count ------
	apd2_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			apd_cnt_reg2		<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(apd_cnt_en(2) = '1') then
				if(cnt_en = '1') then
					if(apd_hit_cnt(2) = '1') then
						apd_cnt_reg2	<=	apd_cnt_reg2 + '1';
					else
						apd_cnt_reg2	<=	apd_cnt_reg2;
					end if;
				else
					apd_cnt_reg2	<=	(others => '0');
				end if;
			else
				apd_cnt_reg2	<=	(others => '0');
			end if;
		end if;
	end process;

	latch_cnt2 : process(sys_clk,sys_rst) begin
		if(sys_rst = '1') then
			chnl_cnt_reg2	<=	(others => '0');
			time_value_chnl2	<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(cnt_end_en = '1') then
				chnl_cnt_reg2	<=	(others => '0');
				time_value_chnl2	<=	(others => '0');
			elsif(apd_cnt_en(2) = '1') then
				if(latch_cnt_en = '1') then
					chnl_cnt_reg2	<=	apd_cnt_reg2;
					time_value_chnl2	<=	tdc_count_time_value;
				else
					chnl_cnt_reg2	<=	chnl_cnt_reg2;
					time_value_chnl2	<=	time_value_chnl2;
				end if;
			else
				chnl_cnt_reg2	<=	(others => '0');
				time_value_chnl2	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 3 count ------
	apd3_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			apd_cnt_reg3	<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(apd_cnt_en(3) = '1') then
				if(cnt_en = '1') then
					if(apd_hit_cnt(3) = '1') then
						apd_cnt_reg3	<=	apd_cnt_reg3 + '1';
					else
						apd_cnt_reg3	<=	apd_cnt_reg3;
					end if;
				else
					apd_cnt_reg3	<=	(others => '0');
				end if;
			else
				apd_cnt_reg3	<=	(others => '0');
			end if;
		end if;
	end process;

	latch_cnt3 : process(sys_clk,sys_rst) begin
		if(sys_rst = '1') then
			chnl_cnt_reg3	<=	(others => '0');
			time_value_chnl3	<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(cnt_end_en = '1') then
				chnl_cnt_reg3	<=	(others => '0');
				time_value_chnl3	<=	(others => '0');
			elsif(apd_cnt_en(3) = '1') then
				if(latch_cnt_en = '1') then
					chnl_cnt_reg3	<=	apd_cnt_reg3;
					time_value_chnl3	<=	tdc_count_time_value;
				else
					chnl_cnt_reg3	<=	chnl_cnt_reg3;
					time_value_chnl3	<=	time_value_chnl3;
				end if;
			else
				chnl_cnt_reg3	<=	(others => '0');
				time_value_chnl3	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 4 count ------
	apd4_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			apd_cnt_reg4		<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(apd_cnt_en(4) = '1') then
				if(cnt_en = '1') then
					if(apd_hit_cnt(4) = '1') then
						apd_cnt_reg4	<=	apd_cnt_reg4 + '1';
					else
						apd_cnt_reg4	<=	apd_cnt_reg4;
					end if;
				else
					apd_cnt_reg4	<=	(others => '0');
				end if;
			else
				apd_cnt_reg4	<=	(others => '0');
			end if;
		end if;
	end process;

	latch_cnt4 : process(sys_clk,sys_rst) begin
		if(sys_rst = '1') then
			chnl_cnt_reg4	<=	(others => '0');
			time_value_chnl4	<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(cnt_end_en = '1') then
				chnl_cnt_reg4	<=	(others => '0');
				time_value_chnl4	<=	(others => '0');
			elsif(apd_cnt_en(4) = '1') then
				if(latch_cnt_en = '1') then
					chnl_cnt_reg4	<=	apd_cnt_reg4;
					time_value_chnl4	<=	tdc_count_time_value;
				else
					chnl_cnt_reg4	<=	chnl_cnt_reg4;
					time_value_chnl4	<=	time_value_chnl4;
				end if;
			else
				chnl_cnt_reg4	<=	(others => '0');
				time_value_chnl4	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 5 count ------
	apd5_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			apd_cnt_reg5		<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(apd_cnt_en(5) = '1') then
				if(cnt_en = '1') then
					if(apd_hit_cnt(5) = '1') then
						apd_cnt_reg5	<=	apd_cnt_reg5 + '1';
					else
						apd_cnt_reg5	<=	apd_cnt_reg5;
					end if;
				else
					apd_cnt_reg5	<=	(others => '0');
				end if;
			else
				apd_cnt_reg5	<=	(others => '0');
			end if;
		end if;
	end process;

	latch_cnt5 : process(sys_clk,sys_rst) begin
		if(sys_rst = '1') then
			chnl_cnt_reg5	<=	(others => '0');
			time_value_chnl5	<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(cnt_end_en = '1') then
				chnl_cnt_reg5	<=	(others => '0');
				time_value_chnl5	<=	(others => '0');
			elsif(apd_cnt_en(5) = '1') then
				if(latch_cnt_en = '1') then
					chnl_cnt_reg5	<=	apd_cnt_reg5;
					time_value_chnl5	<=	tdc_count_time_value;
				else
					chnl_cnt_reg5	<=	chnl_cnt_reg5;
					time_value_chnl5	<=	time_value_chnl5;
				end if;
			else
				chnl_cnt_reg5	<=	(others => '0');
				time_value_chnl5	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 6 count ------
	apd6_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			apd_cnt_reg6		<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(apd_cnt_en(6) = '1') then
				if(cnt_en = '1') then
					if(apd_hit_cnt(6) = '1') then
						apd_cnt_reg6	<=	apd_cnt_reg6 + '1';
					else
						apd_cnt_reg6	<=	apd_cnt_reg6;
					end if;
				else
					apd_cnt_reg6	<=	(others => '0');
				end if;
			else
				apd_cnt_reg6	<=	(others => '0');
			end if;
		end if;
	end process;

	latch_cnt6 : process(sys_clk,sys_rst) begin
		if(sys_rst = '1') then
			chnl_cnt_reg6	<=	(others => '0');
			time_value_chnl6	<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(cnt_end_en = '1') then
				chnl_cnt_reg6	<=	(others => '0');
				time_value_chnl6	<=	(others => '0');
			elsif(apd_cnt_en(6) = '1') then
				if(latch_cnt_en = '1') then
					chnl_cnt_reg6	<=	apd_cnt_reg6;
					time_value_chnl6	<=	tdc_count_time_value;
				else
					chnl_cnt_reg6	<=	chnl_cnt_reg6;
					time_value_chnl6	<=	time_value_chnl6;
				end if;
			else
				chnl_cnt_reg6	<=	(others => '0');
				time_value_chnl6	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 7 count ------
	apd7_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			apd_cnt_reg7		<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(apd_cnt_en(7) = '1') then
				if(cnt_en = '1') then
					if(apd_hit_cnt(7) = '1') then
						apd_cnt_reg7	<=	apd_cnt_reg7 + '1';
					else
						apd_cnt_reg7	<=	apd_cnt_reg7;
					end if;
				else
					apd_cnt_reg7	<=	(others => '0');
				end if;
			else
				apd_cnt_reg7	<=	(others => '0');
			end if;
		end if;
	end process;

	latch_cnt7 : process(sys_clk,sys_rst) begin
		if(sys_rst = '1') then
			chnl_cnt_reg7	<=	(others => '0');
			time_value_chnl7	<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(cnt_end_en = '1') then
				chnl_cnt_reg7	<=	(others => '0');
				time_value_chnl7	<=	(others => '0');
			elsif(apd_cnt_en(7) = '1') then
				if(latch_cnt_en = '1') then
					chnl_cnt_reg7	<=	apd_cnt_reg7;
					time_value_chnl7	<=	tdc_count_time_value;
				else
					chnl_cnt_reg7	<=	chnl_cnt_reg7;
					time_value_chnl7	<=	time_value_chnl7;
				end if;
			else
				chnl_cnt_reg7	<=	(others => '0');
				time_value_chnl7	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 8 count ------
	apd8_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			apd_cnt_reg8		<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(apd_cnt_en(8) = '1') then
				if(cnt_en = '1') then
					if(apd_hit_cnt(8) = '1') then
						apd_cnt_reg8	<=	apd_cnt_reg8 + '1';
					else
						apd_cnt_reg8	<=	apd_cnt_reg8;
					end if;
				else
					apd_cnt_reg8	<=	(others => '0');
				end if;
			else
				apd_cnt_reg8	<=	(others => '0');
			end if;
		end if;
	end process;

	latch_cnt8 : process(sys_clk,sys_rst) begin
		if(sys_rst = '1') then
			chnl_cnt_reg8	<=	(others => '0');
			time_value_chnl8	<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(cnt_end_en = '1') then
				chnl_cnt_reg8	<=	(others => '0');
				time_value_chnl8	<=	(others => '0');
			elsif(apd_cnt_en(8) = '1') then
				if(latch_cnt_en = '1') then
					chnl_cnt_reg8	<=	apd_cnt_reg8;
					time_value_chnl8	<=	tdc_count_time_value;
				else
					chnl_cnt_reg8	<=	chnl_cnt_reg8;
					time_value_chnl8	<=	time_value_chnl8;
				end if;
			else
				chnl_cnt_reg8	<=	(others => '0');
				time_value_chnl8	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 9 count ------
	apd9_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			apd_cnt_reg9		<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(apd_cnt_en(9) = '1') then
				if(cnt_en = '1') then
					if(apd_hit_cnt(9) = '1') then
						apd_cnt_reg9	<=	apd_cnt_reg9 + '1';
					else
						apd_cnt_reg9	<=	apd_cnt_reg9;
					end if;
				else
					apd_cnt_reg9	<=	(others => '0');
				end if;
			else
				apd_cnt_reg9	<=	(others => '0');
			end if;
		end if;
	end process;

	latch_cnt9 : process(sys_clk,sys_rst) begin
		if(sys_rst = '1') then
			chnl_cnt_reg9	<=	(others => '0');
			time_value_chnl9	<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(cnt_end_en = '1') then
				chnl_cnt_reg9	<=	(others => '0');
				time_value_chnl9	<=	(others => '0');
			elsif(apd_cnt_en(9) = '1') then
				if(latch_cnt_en = '1') then
					chnl_cnt_reg9	<=	apd_cnt_reg9;
					time_value_chnl9	<=	tdc_count_time_value;
				else
					chnl_cnt_reg9	<=	chnl_cnt_reg9;
					time_value_chnl9	<=	time_value_chnl9;
				end if;
			else
				chnl_cnt_reg9	<=	(others => '0');
				time_value_chnl9	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 10 count ------
	apd10_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			apd_cnt_reg10		<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(apd_cnt_en(10) = '1') then
				if(cnt_en = '1') then
					if(apd_hit_cnt(10) = '1') then
						apd_cnt_reg10	<=	apd_cnt_reg10 + '1';
					else
						apd_cnt_reg10	<=	apd_cnt_reg10;
					end if;
				else
					apd_cnt_reg10	<=	(others => '0');
				end if;
			else
				apd_cnt_reg10	<=	(others => '0');
			end if;
		end if;
	end process;

	latch_cnt10 : process(sys_clk,sys_rst) begin
		if(sys_rst = '1') then
			chnl_cnt_reg10	<=	(others => '0');
			time_value_chnl10	<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(cnt_end_en = '1') then
				chnl_cnt_reg10	<=	(others => '0');
				time_value_chnl10	<=	(others => '0');
			elsif(apd_cnt_en(10) = '1') then
				if(latch_cnt_en = '1') then
					chnl_cnt_reg10	<=	apd_cnt_reg10;
					time_value_chnl10	<=	tdc_count_time_value;
				else
					chnl_cnt_reg10	<=	chnl_cnt_reg10;
					time_value_chnl10	<=	time_value_chnl10;
				end if;
			else
				chnl_cnt_reg10	<=	(others => '0');
				time_value_chnl10	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 11 count ------
	apd11_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			apd_cnt_reg11		<=	(others => '0');
		elsif rising_edge(sys_clk) then		
			if(apd_cnt_en(11) = '1') then
				if(cnt_en = '1') then
					if(apd_hit_cnt(11) = '1') then
						apd_cnt_reg11	<=	apd_cnt_reg11 + '1';
					else
						apd_cnt_reg11	<=	apd_cnt_reg11;
					end if;
				else
					apd_cnt_reg11	<=	(others => '0');
				end if;
			else
				apd_cnt_reg11	<=	(others => '0');
			end if;
		end if;
	end process;

	latch_cnt11 : process(sys_clk,sys_rst) begin
		if(sys_rst = '1') then
			chnl_cnt_reg11	<=	(others => '0');
			time_value_chnl11	<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(cnt_end_en = '1') then
				chnl_cnt_reg11	<=	(others => '0');
				time_value_chnl11	<=	(others => '0');
			elsif(apd_cnt_en(11) = '1') then
				if(latch_cnt_en = '1') then
					chnl_cnt_reg11	<=	apd_cnt_reg11;
					time_value_chnl11	<=	tdc_count_time_value;
				else
					chnl_cnt_reg11	<=	chnl_cnt_reg11;
					time_value_chnl11	<=	time_value_chnl11;
				end if;
			else
				chnl_cnt_reg11	<=	(others => '0');
				time_value_chnl11	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 12 count ------
	apd12_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			apd_cnt_reg12		<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(apd_cnt_en(12) = '1') then
				if(cnt_en = '1') then
					if(apd_hit_cnt(12) = '1') then
						apd_cnt_reg12	<=	apd_cnt_reg12 + '1';
					else
						apd_cnt_reg12	<=	apd_cnt_reg12;
					end if;
				else
					apd_cnt_reg12	<=	(others => '0');
				end if;
			else
				apd_cnt_reg12	<=	(others => '0');
			end if;
		end if;
	end process;

	latch_cnt12 : process(sys_clk,sys_rst) begin
		if(sys_rst = '1') then
			chnl_cnt_reg12	<=	(others => '0');
			time_value_chnl12	<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(cnt_end_en = '1') then
				chnl_cnt_reg12	<=	(others => '0');
				time_value_chnl12	<=	(others => '0');
			elsif(apd_cnt_en(12) = '1') then
				if(latch_cnt_en = '1') then
					chnl_cnt_reg12	<=	apd_cnt_reg12;
					time_value_chnl12	<=	tdc_count_time_value;
				else
					chnl_cnt_reg12	<=	chnl_cnt_reg12;
					time_value_chnl12	<=	time_value_chnl12;
				end if;
			else
				chnl_cnt_reg12	<=	(others => '0');
				time_value_chnl12	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 13 count ------
	apd13_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			apd_cnt_reg13		<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(apd_cnt_en(13) = '1') then
				if(cnt_en = '1') then
					if(apd_hit_cnt(13) = '1') then
						apd_cnt_reg13	<=	apd_cnt_reg13 + '1';
					else
						apd_cnt_reg13	<=	apd_cnt_reg13;
					end if;
				else
					apd_cnt_reg13	<=	(others => '0');
				end if;
			else
				apd_cnt_reg13	<=	(others => '0');
			end if;
		end if;
	end process;

	latch_cnt13 : process(sys_clk,sys_rst) begin
		if(sys_rst = '1') then
			chnl_cnt_reg13	<=	(others => '0');
			time_value_chnl13	<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(cnt_end_en = '1') then
				chnl_cnt_reg13	<=	(others => '0');
				time_value_chnl13	<=	(others => '0');
			elsif(apd_cnt_en(13) = '1') then
				if(latch_cnt_en = '1') then
					chnl_cnt_reg13	<=	apd_cnt_reg13;
					time_value_chnl13	<=	tdc_count_time_value;
				else
					chnl_cnt_reg13	<=	chnl_cnt_reg13;
					time_value_chnl13	<=	time_value_chnl13;
				end if;
			else
				chnl_cnt_reg13	<=	(others => '0');
				time_value_chnl13	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 14 count ------
	apd14_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			apd_cnt_reg14		<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(apd_cnt_en(14) = '1') then
				if(cnt_en = '1') then
					if(apd_hit_cnt(14) = '1') then
						apd_cnt_reg14	<=	apd_cnt_reg14 + '1';
					else
						apd_cnt_reg14	<=	apd_cnt_reg14;
					end if;
				else
					apd_cnt_reg14	<=	(others => '0');
				end if;
			else
				apd_cnt_reg14	<=	(others => '0');
			end if;
		end if;
	end process;

	latch_cnt14 : process(sys_clk,sys_rst) begin
		if(sys_rst = '1') then
			chnl_cnt_reg14	<=	(others => '0');
			time_value_chnl14	<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(cnt_end_en = '1') then
				chnl_cnt_reg14	<=	(others => '0');
				time_value_chnl14	<=	(others => '0');
			elsif(apd_cnt_en(14) = '1') then
				if(latch_cnt_en = '1') then
					chnl_cnt_reg14	<=	apd_cnt_reg14;
					time_value_chnl14	<=	tdc_count_time_value;
				else
					chnl_cnt_reg14	<=	chnl_cnt_reg14;
					time_value_chnl14	<=	time_value_chnl14;
				end if;
			else
				chnl_cnt_reg14	<=	(others => '0');
				time_value_chnl14	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 15 count ------
	apd15_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			apd_cnt_reg15		<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(apd_cnt_en(15) = '1') then
				if(cnt_en = '1') then
					if(apd_hit_cnt(15) = '1') then
						apd_cnt_reg15	<=	apd_cnt_reg15 + '1';
					else
						apd_cnt_reg15	<=	apd_cnt_reg15;
					end if;
				else
					apd_cnt_reg15	<=	(others => '0');
				end if;
			else
				apd_cnt_reg15	<=	(others => '0');
			end if;
		end if;
	end process;

	latch_cnt15 : process(sys_clk,sys_rst) begin
		if(sys_rst = '1') then
			chnl_cnt_reg15	<=	(others => '0');
			time_value_chnl15	<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(cnt_end_en = '1') then
				chnl_cnt_reg15	<=	(others => '0');
				time_value_chnl15	<=	(others => '0');
			elsif(apd_cnt_en(15) = '1') then
				if(latch_cnt_en = '1') then
					chnl_cnt_reg15	<=	apd_cnt_reg15;
					time_value_chnl15	<=	tdc_count_time_value;
				else
					chnl_cnt_reg15	<=	chnl_cnt_reg15;
					time_value_chnl15	<=	time_value_chnl15;
				end if;
			else
				chnl_cnt_reg15	<=	(others => '0');
				time_value_chnl15	<=	(others => '0');
			end if;
		end if;
	end process;
	------------ end apd count and latch process ------------
	
	------------ qtel count and latch process ------------
	------ channel 0 count ------
	match00_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			qtel_cnt_reg0		<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(qtel_cnt_en(0) = '1') then
				if(cnt_en = '1') then
					if(qtel_hit_cnt(0) = '1') then
						qtel_cnt_reg0	<=	qtel_cnt_reg0 + '1';
					else
						qtel_cnt_reg0	<=	qtel_cnt_reg0;
					end if;
				else
					qtel_cnt_reg0	<=	(others => '0');
				end if;
			else
				qtel_cnt_reg0	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 0 latch ------	
	match00_latch : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			chnl_match_reg0	<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(cnt_end_en = '1') then
				chnl_match_reg0	<=	(others => '0');
			elsif(qtel_cnt_en(0) = '1') then
				if(latch_cnt_en = '1') then
					chnl_match_reg0	<=	qtel_cnt_reg0;
				else
					chnl_match_reg0 <= chnl_match_reg0;
				end if;
			else
				chnl_match_reg0	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 1 count ------
	match01_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			qtel_cnt_reg1		<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(qtel_cnt_en(1) = '1') then
				if(cnt_en = '1') then
					if(qtel_hit_cnt(1) = '1') then
						qtel_cnt_reg1	<=	qtel_cnt_reg1 + '1';
					else
						qtel_cnt_reg1	<=	qtel_cnt_reg1;
					end if;
				else
					qtel_cnt_reg1	<=	(others => '0');
				end if;
			else
				qtel_cnt_reg1	<=	(others => '0');
			end if;
		end if;
	end process;
	
	match01_latch : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			chnl_match_reg1	<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(cnt_end_en = '1') then
				chnl_match_reg1	<=	(others => '0');
			elsif(qtel_cnt_en(1) = '1') then
				if(latch_cnt_en = '1') then
					chnl_match_reg1	<=	qtel_cnt_reg1;
				else
					chnl_match_reg1 <= chnl_match_reg1;
				end if;
			else
				chnl_match_reg1	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 2 count ------
	match02_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			qtel_cnt_reg2		<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(qtel_cnt_en(2) = '1') then
				if(cnt_en = '1') then
					if(qtel_hit_cnt(2) = '1') then
						qtel_cnt_reg2	<=	qtel_cnt_reg2 + '1';
					else
						qtel_cnt_reg2	<=	qtel_cnt_reg2;
					end if;
				else
					qtel_cnt_reg2	<=	(others => '0');
				end if;
			else
				qtel_cnt_reg2	<=	(others => '0');
			end if;
		end if;
	end process;
	
	match02_latch : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			chnl_match_reg2	<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(cnt_end_en = '1') then
				chnl_match_reg2	<=	(others => '0');
			elsif(qtel_cnt_en(2) = '1') then
				if(latch_cnt_en = '1') then
					chnl_match_reg2	<=	qtel_cnt_reg2;
				else
					chnl_match_reg2 <= chnl_match_reg2;
				end if;
			else
				chnl_match_reg2	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 3 count ------
	match03_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			qtel_cnt_reg3		<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(qtel_cnt_en(3) = '1') then
				if(cnt_en = '1') then
					if(qtel_hit_cnt(3) = '1') then
						qtel_cnt_reg3	<=	qtel_cnt_reg3 + '1';
					else
						qtel_cnt_reg3	<=	qtel_cnt_reg3;
					end if;
				else
					qtel_cnt_reg3	<=	(others => '0');
				end if;
			else
				qtel_cnt_reg3	<=	(others => '0');
			end if;
		end if;
	end process;
	
	match03_latch : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			chnl_match_reg3	<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(cnt_end_en = '1') then
				chnl_match_reg3	<=	(others => '0');
			elsif(qtel_cnt_en(3) = '1') then
				if(latch_cnt_en = '1') then
					chnl_match_reg3	<=	qtel_cnt_reg3;
				else
					chnl_match_reg3 <= chnl_match_reg3;
				end if;
			else
				chnl_match_reg3	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 4 count ------
	match04_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			qtel_cnt_reg4		<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(qtel_cnt_en(4) = '1') then
				if(cnt_en = '1') then
					if(qtel_hit_cnt(4) = '1') then
						qtel_cnt_reg4	<=	qtel_cnt_reg4 + '1';
					else
						qtel_cnt_reg4	<=	qtel_cnt_reg4;
					end if;
				else
					qtel_cnt_reg4	<=	(others => '0');
				end if;
			else
				qtel_cnt_reg4	<=	(others => '0');
			end if;
		end if;
	end process;
	
	match04_latch : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			chnl_match_reg4	<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(cnt_end_en = '1') then
				chnl_match_reg4	<=	(others => '0');
			elsif(qtel_cnt_en(4) = '1') then
				if(latch_cnt_en = '1') then
					chnl_match_reg4	<=	qtel_cnt_reg4;
				else
					chnl_match_reg4 <= chnl_match_reg4;
				end if;
			else
				chnl_match_reg4	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 5 count ------
	match05_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			qtel_cnt_reg5		<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(qtel_cnt_en(5) = '1') then
				if(cnt_en = '1') then
					if(qtel_hit_cnt(5) = '1') then
						qtel_cnt_reg5	<=	qtel_cnt_reg5 + '1';
					else
						qtel_cnt_reg5	<=	qtel_cnt_reg5;
					end if;
				else
					qtel_cnt_reg5	<=	(others => '0');
				end if;
			else
				qtel_cnt_reg5	<=	(others => '0');
			end if;
		end if;
	end process;
	
	match05_latch : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			chnl_match_reg5	<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(cnt_end_en = '1') then
				chnl_match_reg5	<=	(others => '0');
			elsif(qtel_cnt_en(5) = '1') then
				if(latch_cnt_en = '1') then
					chnl_match_reg5	<=	qtel_cnt_reg5;
				else
					chnl_match_reg5 <= chnl_match_reg5;
				end if;
			else
				chnl_match_reg5	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 6 count ------
	match06_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			qtel_cnt_reg6		<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(qtel_cnt_en(6) = '1') then
				if(cnt_en = '1') then
					if(qtel_hit_cnt(6) = '1') then
						qtel_cnt_reg6	<=	qtel_cnt_reg6 + '1';
					else
						qtel_cnt_reg6	<=	qtel_cnt_reg6;
					end if;
				else
					qtel_cnt_reg6	<=	(others => '0');
				end if;
			else
				qtel_cnt_reg6	<=	(others => '0');
			end if;
		end if;
	end process;
	
	match06_latch : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			chnl_match_reg6	<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(cnt_end_en = '1') then
				chnl_match_reg6	<=	(others => '0');
			elsif(qtel_cnt_en(6) = '1') then
				if(latch_cnt_en = '1') then
					chnl_match_reg6	<=	qtel_cnt_reg6;
				else
					chnl_match_reg6 <= chnl_match_reg6;
				end if;
			else
				chnl_match_reg6	<=	(others => '0');
			end if;
		end if;
	end process;
	------ channel 7 count ------
	match07_cnt : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			qtel_cnt_reg7		<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(qtel_cnt_en(7) = '1') then
				if(cnt_en = '1') then
					if(qtel_hit_cnt(7) = '1') then
						qtel_cnt_reg7	<=	qtel_cnt_reg7 + '1';
					else
						qtel_cnt_reg7	<=	qtel_cnt_reg7;
					end if;
				else
					qtel_cnt_reg7	<=	(others => '0');
				end if;
			else
				qtel_cnt_reg7	<=	(others => '0');
			end if;
		end if;
	end process;
	
	match07_latch : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
			chnl_match_reg7	<=	(others => '0');
		elsif rising_edge(sys_clk) then	
			if(cnt_end_en = '1') then
				chnl_match_reg7	<=	(others => '0');
			elsif(qtel_cnt_en(7) = '1') then
				if(latch_cnt_en = '1') then
					chnl_match_reg7	<=	qtel_cnt_reg7;
				else
					chnl_match_reg7 <= chnl_match_reg7;
				end if;
			else
				chnl_match_reg7	<=	(others => '0');
			end if;
		end if;
	end process;
	------------ end qtel count and latch process ------------

end Behavioral;

