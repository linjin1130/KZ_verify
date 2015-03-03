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
		
		
		alg_done 				: 	out 	std_logic;--�㷨 ����ź�
		
		POC_ram_rd_addr		:	out	std_logic_vector(6 downto 0);---128 POC ���
		POC_ram_rd_data		:	out	std_logic_vector(15 downto 0);---PM��ѹ����ֵ
		
	);
end count_measure;

--�㷨��Ҫ�Ĳ���������λ�����ã�1-128��
---parameter interface
		--POC ״̬��
		--POC 1/4�벨��ѹ��16 bit��
		--����������ֵ������ÿһ�μ���ʱ�䣩��1ms��80Mʱ����Ϊ80K
		--�㷨������ĵȴ�ʱ��