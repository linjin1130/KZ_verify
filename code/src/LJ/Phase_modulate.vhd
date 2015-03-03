entity Phase_modulate is
	generic(
		CNT_POC_STATE : integer := X"B0";
		CNT_High_Addr : std_logic_vector(7 downto 0) := X"BF"
	);
	port(
		sys_clk_80M	:	in	std_logic;--system clock,80MHz
		sys_rst_n	:	in	std_logic;--system reset,low active
		
		alg_start 	: 	in 	std_logic;
		alg_stop 	: 	in 	std_logic;
		---apd count interface
		apd1_fpga_hit : 	in	std_logic;--apd1 pulse
		apd2_fpga_hit : 	in	std_logic;--apd2 pulse
		
		---
		cpldif_count_wr_en	:	in	std_logic;
		cpldif_count_addr		:	in	std_logic_vector(7 downto 0);
		cpldif_count_wr_data	:	in	std_logic_vector(31 downto 0);
		
		
		alg_done 				: 	out 	std_logic;--算法 完成信号
		
		POC_ram_rd_addr		:	out	std_logic_vector(6 downto 0);---128 POC 组合
		POC_ram_rd_data		:	out	std_logic_vector(15 downto 0);---PM电压设置值
		
	);
end count_measure;

--算法需要的参数，由上位机配置（1-128）
---parameter interface
		--POC 状态数
		--POC 1/4半波电压（16 bit）
		--计数器上限值（控制每一次计数时间），1ms在80M时钟下为80K
		--算法结束后的等待时间