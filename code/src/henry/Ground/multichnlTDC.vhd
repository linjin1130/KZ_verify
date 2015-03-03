library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity multichnlTDC is
	generic(
			tdc_basic_addr		:	std_logic_vector(7 downto 0) := X"10";
			tdc_high_addr		:	std_logic_vector(7 downto 0) := X"14"
		);
	port (
			clk_160M			:	in std_logic;
			invclk_160M			:	in std_logic;
			sys_clk				:	in std_logic;-----------80M
			sys_clk_60M			:	in std_logic;-----------60M
			sys_rst_n 			: 	in std_logic;
	--		SysEnable 			: 	in std_logic;
			------------------input and output signal for TDC measurement----------------
			HitIn_p  			: 	in std_logic_vector(16 downto 1);
			HitIn_n  			: 	in std_logic_vector(16 downto 1);
			gps_pps				:	out std_logic;
			tdc_count_hit		: 	out std_logic_vector(15 downto 0);
			testsig 			: 	out std_logic_vector(15 downto 0);
			tdc_qtel_hit		: 	out std_logic_vector(8 downto 0);
	--		TestHitIn			:	in std_logic_vector(16 downto 1);
			------------inside interface to cpldif module--------------------------
			cpldif_tdc_addr		:	in	std_logic_vector(7 downto 0);
			cpldif_tdc_wr_en	:	in	std_logic;--register write enable
			cpldif_tdc_wr_data	:	in	std_logic_vector(31 downto 0);
			cpldif_tdc_rd_en	:	in	std_logic;--refister read enable
			tdc_cpldif_rd_data	:	out	std_logic_vector(31 downto 0);
		-------fifo interface-------
			tdc_cpldif_fifo_clr			:	out	std_logic;
			tdc_cpldif_fifo_wr_en		:	out	std_logic;
			tdc_cpldif_fifo_wr_data		:	out	std_logic_vector(31 downto 0);
			cpldif_tdc_fifo_prog_full	:	in	std_logic;
		--------------sdram------------------------------
			tdc_sdram_dq 		:	inout	std_logic_vector(15 downto 0);
			tdc_sdram_dqml 		:	out	std_logic;
			tdc_sdram_dqmh 		:	out	std_logic;
			tdc_sdram_we_n 		:	out	std_logic;
			tdc_sdram_cas_n 	:	out	std_logic;
			tdc_sdram_ras_n 	:	out	std_logic;
			tdc_sdram_cs_n 		:	out	std_logic;
			tdc_sdram_ba 		:	out	std_logic_vector(1 downto 0);
			tdc_sdram_a 		:	out	std_logic_vector(12 downto 0);
			tdc_sdram_cke 		:	out	std_logic;
			tdc_sdram_clk 		:	out	std_logic;
		--			RdoFifoProgFull : in std_logic;
		--			RdoFifoWrEn : out std_logic;
		--			Data2RdoFifo : out std_logic_vector(63 downto 0);
			tp 					: out std_logic_vector(6 downto 0)
			--		  tp_token_in : out std_logic_vector(16 downto 0);
			--        tp_token_out : out std_logic_vector(16 downto 0);
			--        tp_wren : out std_logic;
			--        tp_ChnlFifoRdEn : out std_logic_vector(15 downto 0);
			--        tp_ChnlFifoEmpty : out std_logic_vector(15 downto 0);
			--        tp_Triger : out std_logic		  
		  );	  
end multichnlTDC;

architecture Behavioral of multichnlTDC is
	
COMPONENT SimuHitGene
	PORT(
		Aclear : IN std_logic;
		Enable : IN std_logic;
		CLK : IN std_logic;          
		Cout : OUT std_logic;
		OscClk : OUT std_logic_vector(1 downto 0);
		stepdata_p : OUT std_logic_vector(299 downto 0)
		);
	END COMPONENT;

component singlechnl is
   port (
	     Clk : in std_logic;
		  InvClk : in std_logic;
		  FifoClk : in std_logic;
	     HitIn : in std_logic;
		  SysClear  : in std_logic;----SysClear
		  SysEnable : in std_logic;-----SysEnable
		  ChnlEnable : in std_logic;-----SysEnable
		  fifo_rst : IN std_logic;
		  ChnlFifoRdEn : out std_logic;
		  ChnlFlags    : in std_logic_vector(7 downto 0);
		  Cout : out std_logic;
		  ChnlFifoAlmostFull : out std_logic;
		  ChnlFifoEmpty : out std_logic;
		  ChnlFifoFull  : out std_logic;
		  --ChnlFifoProgEmpty : out std_logic;
		  ChnlFifoProgFull  : out std_logic;
		  TDCDataOut : out std_logic_vector(63 downto 0);
		  Token_in : in std_logic;
		  Token_out : out std_logic;
		  RdFifoWren : out std_logic
		  );	
end component;

COMPONENT channel16_transctrl
	PORT(
		clk : IN std_logic;
		nReset : IN std_logic;
		Hit_in : IN std_logic;
		Token_in : IN std_logic;
		Enable : IN std_logic;          
		Token_out : OUT std_logic;
		Triger : OUT std_logic
		);
END COMPONENT;

--COMPONENT DWidth_64to32_fifo
--  PORT (
--    rst : IN STD_LOGIC;
--    wr_clk : IN STD_LOGIC;
--    rd_clk : IN STD_LOGIC;
--    din : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
--    wr_en : IN STD_LOGIC;
--    rd_en : IN STD_LOGIC;
--    dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
--    full : OUT STD_LOGIC;
--    almost_full : OUT STD_LOGIC;
--    empty : OUT STD_LOGIC;
--    almost_empty : OUT STD_LOGIC
--  );
--END COMPONENT;

COMPONENT tdc_frame_fifo
	PORT (
		rst : IN STD_LOGIC;
		wr_clk : IN STD_LOGIC;
		rd_clk : IN STD_LOGIC;
		din : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
		wr_en : IN STD_LOGIC;
		rd_en : IN STD_LOGIC;
		dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		full : OUT STD_LOGIC;
		almost_full : OUT STD_LOGIC;
		empty : OUT STD_LOGIC;
		almost_empty : OUT STD_LOGIC
	);
END COMPONENT;
	COMPONENT FramePack
	PORT(
		sys_clk : IN std_logic;
		sys_rst_n : IN std_logic;
		fifo_rst : IN std_logic;
		frame_en : IN std_logic;
		tdc_frame_fifo_almost_empty : IN std_logic;
		tdc_frame_fifo_dout : IN std_logic_vector(15 downto 0);
		frame_sdram_fifo_rd_en : IN std_logic;
		frame_sdram_fifo_rd_clk : IN std_logic;          
		tdc_frame_fifo_rd_en : OUT std_logic;
		frame_sdram_fifo_almost_empty : OUT std_logic;
		frame_sdram_fifo_rd_data_count : OUT std_logic_vector(11 downto 0);
		frame_sdram_fifo_dout : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;
	COMPONENT RAMctrl
	PORT(
		sys_clk : IN std_logic;
		nRESET : IN std_logic;
		nRESET_RAM : IN std_logic;
		RF_WR_DATA_COUNT : IN std_logic_vector(11 downto 0);
		WF_DOUT : IN std_logic_vector(15 downto 0);
		WF_RD_DATA_COUNT : IN std_logic_vector(11 downto 0);    
		DQ : INOUT std_logic_vector(15 downto 0);      
		RF_DIN : OUT std_logic_vector(15 downto 0);
		RF_WR_EN : OUT std_logic;
		RF_WR_CLK : OUT std_logic;
		WF_RD_EN : OUT std_logic;
		WF_RD_CLK : OUT std_logic;
		DQML : OUT std_logic;
		DQMH : OUT std_logic;
		nWE : OUT std_logic;
		nCAS : OUT std_logic;
		nRAS : OUT std_logic;
		nCS : OUT std_logic;
		BA : OUT std_logic_vector(1 downto 0);
		A : OUT std_logic_vector(12 downto 0);
		CKE : OUT std_logic;
		WRITE_RAM_EN : OUT std_logic;
		READ_RAM_EN : OUT std_logic;
		READ_RAM_READY : OUT std_logic;
		READ_RAM_DONE : OUT std_logic;
		WRITE_RAM_READY : OUT std_logic;
		WRITE_RAM_DONE : OUT std_logic;
		INIT_DONE : OUT std_logic;
		ACTIONFORBID : OUT std_logic;
		testsignal : OUT std_logic_vector(31 downto 0);
		STATE_WR : OUT std_logic_vector(15 downto 0);
		Read_Enable : OUT std_logic;
		Write_Enable : OUT std_logic;
		UsedWord : OUT std_logic_vector(24 downto 0)
		);
	END COMPONENT;
COMPONENT sdram_cpldif_fifo
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full : OUT STD_LOGIC;
    almost_full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    almost_empty : OUT STD_LOGIC;
    wr_data_count : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
  );
END COMPONENT;

--attribute syn_black_box : boolean;
--attribute syn_black_box of RdoutFifo: component is true;
signal HitIn: std_logic_vector(16 downto 1);
signal tdc_qtel_sig : std_logic_vector(7 downto 0);
signal tdc_qtel_clk : std_logic;
signal FifoClk : std_logic;
signal Clk,InvClk,Clk_tmp,InvClk_tmp,InvClk_tmp0 : std_logic;
type MultiChnlDataType is array(0 to 15) of std_logic_vector(63 downto 0);
signal TDCDataOut : MultiChnlDataType;

--attribute KEEP: string;
--attribute KEEP of Clk: signal is "TRUE";
--attribute KEEP of InvClk: signal is "TRUE";


signal RdFifoClk : std_logic;
signal DataOut : std_logic_vector(63 downto 0);		  
signal DataOut_tmp,DataOut_tmp1 : std_logic_vector(63 downto 0);
signal ChnlFifoAlmostFull,ChnlFifoEmpty,ChnlFifoFull: std_logic_vector(15 downto 0);
signal ChnlFifoRdEn,RdFifoWren : std_logic_vector(15 downto 0);
signal Cout,ChnlFifoProgEmpty,ChnlFifoProgFull : std_logic_vector(15 downto 0);
--signal FifoDataSel : std_logic_vector(4 downto 0);
signal RdFifoRdEn :  std_logic;
signal WrEn_tmp,WrEn : std_logic;
--signal FifoDataOUt :  std_logic_vector(15 downto 0);
--signal RdfifoEmpty ,RdOutFifoFull:  std_logic;
signal RdOutFifoFull:  std_logic;
signal SysEnable: std_logic;
--signal SysReg : std_logic_vector(15 downto 0);
signal SysRegIn : std_logic_vector(31 downto 0);
signal dcm_clk:std_logic;
signal Token_in,Token_out : std_logic_vector(16 downto 0);
signal LOCKED : std_logic;
--signal SysClear : std_logic;
--signal SysEnable : std_logic;
signal DacClk : std_logic;
--signal RdoFifoProgFull : std_logic;
signal RdfifoEmpty : std_logic;
signal Rdfifo_prog_empty : std_logic;
signal trigger : std_logic;

--signal trigger,trigger_tmp1,trigger_tmp2,trigger_tmp3,trigger_tmp4 : std_logic;
signal HitIn_tmp : std_logic_vector(16 downto 1);
signal FifoDataOut : std_logic_vector(15 downto 0);
signal S_Clk_p,S_Clk_n : std_logic;
signal ClkDiv_Cnt: std_logic_vector(15 downto 0);
signal ClkDiv_Cnt2: std_logic_vector(15 downto 0);
signal ChnlEnable: std_logic_vector(7 downto 0);
signal OscClk: std_logic_vector(1 downto 0);
signal Token_hit: std_logic;
signal dw64to32_fifo_almost_full: std_logic;
signal dw64to32_fifo_rd_en: std_logic;
signal DW64to32_fifo_almost_empty: std_logic;
signal sys_rst: std_logic;
signal expe_enable: std_logic;
signal expe_sta: std_logic;
signal expe_stop: std_logic;
signal tdc_fifo_clear: std_logic;
signal fifo_rst: std_logic;

signal addr_sel: std_logic_vector(7 downto 0);

signal expe_stop_delay_cnt: std_logic_vector(19 downto 0);

---------------------tdc register---------------------------------------------
signal tdc_reg_comm_ctrl: std_logic_vector(31 downto 0);---rwsc,addr:x0
signal tdc_reg_expe_mode: std_logic_vector(31 downto 0);--rw;addr:x1
signal tdc_reg_in_level: std_logic_vector(31 downto 0);--rw;addr:x2
signal tdc_reg_channel_en: std_logic_vector(31 downto 0);--rw;addr:x3
signal tdc_reg_status: std_logic_vector(31 downto 0);--read only;addr:x4
signal rd_data_reg: std_logic_vector(31 downto 0);--read only;addr:x4

signal tdc_frame_fifo_dout: std_logic_vector(15 downto 0);
signal frame_sdram_fifo_rd_data_count: std_logic_vector(11 downto 0);
signal frame_sdram_fifo_dout: std_logic_vector(15 downto 0);
signal sdram_cpldif_fifo_din: std_logic_vector(15 downto 0);
signal sdram_cpldif_fifo_wr_data_count: std_logic_vector(11 downto 0);
signal sdram_cpldif_fifo_dout: std_logic_vector(31 downto 0);
signal HitIn_buf_p: std_logic_vector(16 downto 1);
signal HitIn_buf_n: std_logic_vector(16 downto 1);

signal tdc_frame_fifo_almost_full: std_logic;
signal tdc_frame_fifo_rd_en: std_logic;
signal tdc_frame_fifo_almost_empty: std_logic;
signal frame_sdram_fifo_rd_en: std_logic;
signal frame_sdram_fifo_rd_clk: std_logic;
signal sdram_cpldif_fifo_wr_en: std_logic;
signal sdram_cpldif_fifo_wr_clk: std_logic;
signal sdram_cpldif_fifo_rd_en: std_logic;
signal sdram_cpldif_fifo_rd_en_1d: std_logic;
signal sdram_cpldif_fifo_almost_empty: std_logic;
signal tdc_fifo_clear_n: std_logic;
signal sdram_cpldif_fifo_almost_full: std_logic;
signal frame_sdram_fifo_almost_empty: std_logic;
signal gps_pps_sig: std_logic;
signal expe_sta_delay_gps: std_logic;
signal gps_pps_sig_syn: std_logic;
signal gps_pps_sig_syn_1d: std_logic;
signal gps_pps_sig_syn_2d: std_logic;
signal gps_pps_sig_syn_pulse: std_logic;
signal expe_sta_cmd: std_logic;

--attribute keep: string;
--attribute keep of Inst_SimuHitGene: signal is "TRUE";
--attribute keep of Clk: signal is "TRUE";
--attribute keep of InvClk: signal is "TRUE";

		  
begin

tdc_qtel_hit <= tdc_qtel_sig & tdc_qtel_clk;
tdc_qtel_clk <= HitIn(1);
tdc_qtel_sig <= HitIn(9 downto 2);

tdc_sdram_clk <= sdram_cpldif_fifo_wr_clk;
sys_rst <= not sys_rst_n;
fifo_rst <= sys_rst or tdc_fifo_clear;
tdc_fifo_clear_n <= not tdc_fifo_clear;
Clk <=clk_160M;
InvClk <=invclk_160M;

--tdc_count_hit_pro : process(sys_clk)
--begin
--	if rising_edge(sys_clk) then
--		tdc_count_hit(15 downto 0) <= HitIn(16 downto 1);
--	end if;
--end process;
tdc_count_hit_inst: FOR i in 1 to 16 generate
begin
   FDCE_inst : FDCE -- Single Data Rate D Flip-Flop with Asynchronous Clear and Clock Enable (posedge clk).
   generic map (
      INIT => '0') -- Initial value of register ('0' or '1')  
   port map (
      Q => tdc_count_hit(i-1),      -- Data output
      C => clk_160M,      -- Clock input
      CE => '1',    -- Clock enable input
      CLR =>'0',   -- Asynchronous clear input
      D => HitIn(i)       -- Data input
   );
end generate;
--tdc_count_hit(15 downto 0) <= HitIn(16 downto 1);

gps_pps_sig <= HitIn(1);
gps_pps <= gps_pps_sig;
---------------------------------register manager-------------------------------------------------------
lock_addr : process(sys_clk,sys_rst)
begin
	if(sys_rst = '1') then
			addr_sel	<=	X"FF";
	elsif rising_edge(sys_clk) then
		if(cpldif_tdc_addr >= tdc_basic_addr and cpldif_tdc_addr <=	tdc_high_addr) then
			addr_sel	<=	cpldif_tdc_addr	- tdc_basic_addr;
		else
			addr_sel	<=	X"FF";
		end if;
	end if;
end process;
---write register0: tdc_reg_comm_ctrl: rwsc,ie.,write only one cylce
tdc_reg_comm_ctrl_wr : process(sys_clk,sys_rst)
begin
	if(sys_rst = '1') then
			tdc_reg_comm_ctrl	<=	(others => '0');
	elsif rising_edge(sys_clk) then
		if(addr_sel = X"00") then
			if(cpldif_tdc_wr_en = '1') then
				tdc_reg_comm_ctrl	<=	cpldif_tdc_wr_data;
			else
				tdc_reg_comm_ctrl	<=	(others => '0');
			end if;
		else
			tdc_reg_comm_ctrl	<=	(others => '0');
		end if;
	end if;
end process;
---write register1:tdc_reg_expe_mode
tdc_reg_expe_mode_wr : process(sys_clk,sys_rst)
begin
	if(sys_rst = '1') then
			tdc_reg_expe_mode	<=	(others => '0');
	elsif rising_edge(sys_clk) then
		if(addr_sel = X"01") then
			if(cpldif_tdc_wr_en = '1') then
				tdc_reg_expe_mode	<=	cpldif_tdc_wr_data;
			else
				tdc_reg_expe_mode	<=	tdc_reg_expe_mode;
			end if;
		else
			tdc_reg_expe_mode	<=	tdc_reg_expe_mode;
		end if;
	end if;
end process;
---write register2:tdc_reg_in_level
tdc_reg_in_level_wr : process(sys_clk,sys_rst)
begin
	if(sys_rst = '1') then
			tdc_reg_in_level	<=	(others => '1');
	elsif rising_edge(sys_clk) then
		if(addr_sel = X"02") then
			if(cpldif_tdc_wr_en = '1') then
				tdc_reg_in_level	<=	cpldif_tdc_wr_data;
			else
				tdc_reg_in_level	<=	tdc_reg_in_level;
			end if;
		else
			tdc_reg_in_level	<=	tdc_reg_in_level;
		end if;
	end if;
end process;
---write register3:tdc_reg_channel_en
tdc_reg_channel_en_wr : process(sys_clk,sys_rst)
begin
	if(sys_rst = '1') then
			tdc_reg_channel_en	<=	(others => '0');
	elsif rising_edge(sys_clk) then
		if(addr_sel = X"03") then
			if(cpldif_tdc_wr_en = '1') then
				tdc_reg_channel_en	<=	cpldif_tdc_wr_data;
			else
				tdc_reg_channel_en	<=	tdc_reg_channel_en;
			end if;
		else
			tdc_reg_channel_en	<=	tdc_reg_channel_en;
		end if;
	end if;
end process;

---register4:tdc_reg_status
tdc_reg_status(8) <= expe_enable;
tdc_reg_status(7 downto 0) <= tdc_reg_expe_mode(7 downto 0);

---read register
reg_rd : process(sys_clk)
begin
	if rising_edge(sys_clk) then
		if(cpldif_tdc_rd_en = '1') then
			if(addr_sel = X"00") then
				rd_data_reg	<=	tdc_reg_comm_ctrl;
			elsif(addr_sel = X"01") then
				rd_data_reg	<=	tdc_reg_expe_mode;
			elsif(addr_sel = X"02") then
				rd_data_reg	<=	tdc_reg_in_level;
			elsif(addr_sel = X"03") then
				rd_data_reg	<=	tdc_reg_channel_en;
			elsif(addr_sel = X"04") then
				rd_data_reg	<=	tdc_reg_status;
			else
				rd_data_reg	<=	rd_data_reg;
			end if;
		else
			rd_data_reg	<=	rd_data_reg;
		end if;
	end if;
end process;

tdc_cpldif_rd_data	<= 	rd_data_reg;
-----------------------------------end write read register control---------
--------------------------------------register analysis
--tdc_reg_comm_ctrl
expe_sta_cmd_proc : process(sys_clk,sys_rst)
begin
	if(sys_rst = '1')then
			expe_sta_cmd <= '0';
	elsif rising_edge(sys_clk) then
		if(tdc_reg_comm_ctrl = x"0F") then
			expe_sta_cmd <= '1';  ------------one cylce only
		else
			expe_sta_cmd <= '0';
		end if;
	end if;
end process;

--
------rise edge detect for gps_pps_sig
GPS_syn_pro : process(sys_clk,sys_rst)
begin
	if(sys_rst = '1') then
		gps_pps_sig_syn	<=	'0';
		gps_pps_sig_syn_1d	<=	'0';
		gps_pps_sig_syn_2d	<=	'0';
		gps_pps_sig_syn_pulse <= '0';
	elsif rising_edge(sys_clk) then
		gps_pps_sig_syn <= gps_pps_sig;
		gps_pps_sig_syn_1d	<=	gps_pps_sig_syn;
		gps_pps_sig_syn_2d	<=	gps_pps_sig_syn_1d;
		gps_pps_sig_syn_pulse <= gps_pps_sig_syn_1d and (not gps_pps_sig_syn_2d);
	end if;
end process;

Sta_latch_pro : process(sys_clk,sys_rst)
begin
	if(sys_rst = '1') then
		expe_sta_delay_gps	<=	'0';
	elsif rising_edge(sys_clk) then
		if( expe_sta_cmd =	'1')then
			expe_sta_delay_gps <= '1';
		elsif (gps_pps_sig_syn_pulse = '1')then
			expe_sta_delay_gps <= '0';
		else
			expe_sta_delay_gps <= expe_sta_delay_gps;
		end if;
	end if;
end process;

Sta_pulse_pro : process(sys_clk,sys_rst)
begin
	if(sys_rst = '1') then
		expe_sta	<=	'0';
	elsif rising_edge(sys_clk) then
		if( expe_sta_delay_gps ='1' and gps_pps_sig_syn_pulse = '1')then
			expe_sta <= '1';
		else
			expe_sta <= '0';
		end if;
	end if;
end process;

----

expe_stop_proc : process(sys_clk,sys_rst)
begin
	if(sys_rst = '1')then
			expe_stop <= '0';
	elsif rising_edge(sys_clk) then
		if(tdc_reg_comm_ctrl = x"F0") then
			expe_stop <= '1';  ------------one cylce only
		else
			expe_stop <= '0';
		end if;
	end if;
end process;

expe_enable_proc : process(sys_clk,sys_rst)
begin
	if(sys_rst = '1')then
			expe_enable <= '0';
	elsif rising_edge(sys_clk) then
		if(expe_sta = '1') then
			expe_enable <= '1';  
		elsif(expe_stop = '1') then
			expe_enable <= '0';
	   else
			expe_enable <= expe_enable;
		end if;
	end if;
end process;

expe_stop_delay_cnt_pro: process(sys_clk,sys_rst)
begin
	if(sys_rst = '1')then
		expe_stop_delay_cnt <= (others => '1');
	elsif(sys_clk'event and sys_clk = '1')then
		if(expe_stop = '1')then
			expe_stop_delay_cnt <= (others => '0');
		elsif( expe_stop_delay_cnt <= x"13880")then------delay 1ms by 80MHZ CLK
			expe_stop_delay_cnt <= expe_stop_delay_cnt + '1';
		end if;
	end if;
end process;

tdc_fifo_clear_pro: process(sys_clk,sys_rst)
begin
	if(sys_rst = '1')then
		tdc_fifo_clear <= '0';
	elsif(sys_clk'event and sys_clk = '1')then
		if((expe_stop_delay_cnt > x"1387a")and(expe_stop_delay_cnt < x"13880"))then
			tdc_fifo_clear <= '1';
		else
			tdc_fifo_clear <= '0';
		end if;
	end if;
end process;
tdc_cpldif_fifo_clr <= tdc_fifo_clear;
---------------------------------end of register manager------------------------------------------------

	Inst_SimuHitGene: SimuHitGene PORT MAP(
		Aclear => '0',
		Enable => '1',
		CLK => '0',
		Cout => Tp(6),
		OscClk => OscClk,
		stepdata_p => open
	);
	
ClkDiv_pro:process(OscClk(0))
  begin
      if(OscClk(0)'event and OscClk(0)='1') then
		   if(sys_rst = '1')then
				ClkDiv_Cnt <= (others => '0');
--			elsif(ChnlEnable(0)<= '1') then
			else
				ClkDiv_Cnt <= ClkDiv_Cnt + '1';
--			else
--				ClkDiv_Cnt <= (others => '0');
			end if;
		end if;
  end process;

ClkDiv2_pro:process(OscClk(1))
  begin
      if(OscClk(1)'event and OscClk(1)='1') then
		   if(sys_rst = '1')then
				ClkDiv_Cnt2 <= (others => '0');
--			elsif(ChnlEnable(0)<= '1') then
			else
				ClkDiv_Cnt2 <= ClkDiv_Cnt2 + '1';
--			else
--				ClkDiv_Cnt2 <= (others => '0');
			end if;
		end if;
  end process;

--IBUFGDS_inst : IBUFDS
--   generic map (
--      DIFF_TERM => TRUE, -- Differential Termination 
--		IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for refernced I/O standards
--      IOSTANDARD => "LVDS_25")
--   port map (
--      O => HitIn_tmp(1),  -- Clock buffer output
--      I => HitIn_p(1),  -- hit_p clock buffer input (connect directly to top-level port)
--      IB => HitIn_n(1) -- hit_n clock buffer input (connect directly to top-level port)
--   );

hitin_inst: FOR i in 1 to 16 generate
begin
--IBUFGDS_inst : IBUFDS
--   generic map (
--      DIFF_TERM => TRUE, -- Differential Termination 
--		IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for refernced I/O standards
--      IOSTANDARD => "LVDS_25")
--   port map (
--      O => HitIn_tmp(i),  -- Clock buffer output
--      I => HitIn_p(i),  -- hit_p clock buffer input (connect directly to top-level port)
--      IB => HitIn_n(i) -- hit_n clock buffer input (connect directly to top-level port)
--   );
	
	IBUFDS_DIFF_OUT_inst : IBUFDS_DIFF_OUT
   generic map (
      DIFF_TERM => TRUE, -- Differential Termination 
      IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for refernced I/O standards
      IOSTANDARD => "LVDS_25") -- Specify the input I/O standard
   port map (
      O => HitIn_buf_p(i),     -- Buffer diff_p output
      OB => HitIn_buf_n(i),   -- Buffer diff_n output
      I => HitIn_p(i),  -- Diff_p buffer input (connect directly to top-level port)
      IB => HitIn_n(i) -- Diff_n buffer input (connect directly to top-level port)
   );
end generate;

--hit_tmp_inst: for i in 1 to 16 generate
--begin
--HitIn_tmp(i) <= HitIn_buf_p(i) when (tdc_reg_in_level(i-1) = '1') else HitIn_buf_n(i);
--end generate;

--
--HitIn_tmp(6 downto 5) <= TestHitIn(6 downto 5);
--HitIn_tmp(6) <= ClkDiv_Cnt(9);
--HitIn_tmp(7) <= ClkDiv_Cnt2(9);
--HitIn_tmp(2 downto 1) <=	(others =>'0');
--HitIn_tmp(16 downto 7) <= 	(others =>'0');


hitin_bufg_inst: FOR i in 1 to 16 generate
begin
--BUFG_inst : BUFG
--port map (
--O => HitIn(i), -- 1-bit output: Clock buffer output
--I => HitIn_tmp(i) -- 1-bit input: Clock buffer input
--);
   BUFGMUX_CTRL_inst : BUFGMUX_CTRL
   port map (
      O => HitIn(i),   -- 1-bit output: Clock buffer output
      I0 => HitIn_buf_n(i), -- 1-bit input: Clock buffer input (S=0)
      I1 => HitIn_buf_p(i), -- 1-bit input: Clock buffer input (S=1)
      S => tdc_reg_in_level(i-1)    -- 1-bit input: Clock buffer select
   );
end generate;	
--hitin_bufg_inst_2: FOR i in 13 to 16 generate
--begin
--BUFG_inst : BUFG
--port map (
--O => HitIn(i), -- 1-bit output: Clock buffer output
--I => HitIn_tmp(i) -- 1-bit input: Clock buffer input
--);
--end generate;	

--BUFG_6_inst : BUFG
--port map (
--O => HitIn(6), -- 1-bit output: Clock buffer output
--I => ClkDiv_Cnt(9) -- 1-bit input: Clock buffer input
--);
--BUFG_7_inst : BUFG
--port map (
--O => HitIn(7), -- 1-bit output: Clock buffer output
--I => ClkDiv_Cnt2(9) -- 1-bit input: Clock buffer input
--);

--BUFG_8_inst : BUFG
--port map (
--O => HitIn(8), -- 1-bit output: Clock buffer output
--I => HitIn_tmp(8) -- 1-bit input: Clock buffer input
--);
--BUFG_9_inst : BUFG
--port map (
--O => HitIn(9), -- 1-bit output: Clock buffer output
--I => HitIn_tmp(9) -- 1-bit input: Clock buffer input
--);
--BUFG_10_inst : BUFG
--port map (
--O => HitIn(10), -- 1-bit output: Clock buffer output
--I => HitIn_tmp(10) -- 1-bit input: Clock buffer input
--);
--
--BUFG_11_inst : BUFG
--port map (
--O => HitIn(11), -- 1-bit output: Clock buffer output
--I => HitIn_tmp(11) -- 1-bit input: Clock buffer input
--);
--BUFG_12_inst : BUFG
--port map (
--O => HitIn(12), -- 1-bit output: Clock buffer output
--I => HitIn_tmp(12) -- 1-bit input: Clock buffer input
--);

--HitIn(8) <= HitIn_tmp(8);
--HitIn(10) <= HitIn_tmp(10);
--HitIn(12) <= HitIn_tmp(12);
--HitIn(7) <= ClkDiv_Cnt(9);
--HitIn(6) <= ClkDiv_Cnt2(9);
--hitin_bufio_inst: FOR i in 8 to 16 generate
--begin	
--	BUFIO_inst : BUFIO
--   port map (
--      O => HitIn(i), -- 1-bit output: Clock output port (connect to I/O clock loads)
--      I => HitIn_tmp(i)  -- 1-bit input: Clock input port (connect to IBUFG)
--   );
--end generate;


--hitin_bufr_inst: FOR i in 8 to 16 generate
--begin
--BUFR_inst : BUFR
--   generic map (
--      BUFR_DIVIDE => "BYPASS", -- Values: "BYPASS", "1", "2", "3", "4", "5", "6", "7", "8" 
--      SIM_DEVICE => "VIRTEX6"  -- Must be set to "VIRTEX6" 
--   )
--   port map (
--      O => HitIn(i),     -- 1-bit output: Clock buffer output
--      CE => '1',   -- 1-bit input: Active high clock enable input
--      CLR => '0', -- 1-bit input: Active high reset input
--      I => HitIn_tmp(i)      -- 1-bit input: Clock buffer input driven by an IBUFG, MMCM or local interconnect
--   );
--end generate;


Token_hit <= not (ChnlFifoEmpty(0) and ChnlFifoEmpty(1) and ChnlFifoEmpty(2)and ChnlFifoEmpty(3)and ChnlFifoEmpty(4)and ChnlFifoEmpty(5)
						and ChnlFifoEmpty(6)and ChnlFifoEmpty(7)and ChnlFifoEmpty(8)and ChnlFifoEmpty(9)and ChnlFifoEmpty(10)and ChnlFifoEmpty(11)
						and ChnlFifoEmpty(12)and ChnlFifoEmpty(13)and ChnlFifoEmpty(14)and ChnlFifoEmpty(15));

channel16_transctrl_inst : channel16_transctrl
port map(
         clk => sys_clk,
			nReset => sys_rst_n,				
			Hit_in => Token_hit,--HitIn(3)
			Token_in => Token_in(16),
			Enable => expe_enable,
			Token_out => Token_out(16),
			Triger => trigger
			);

Chnl_1_inst: singlechnl
 port map(
	     Clk => Clk,
		  InvClk => InvClk,
		  FifoClk => sys_clk,
	     HitIn => HitIn(1),--'0',--
		  SysClear => sys_rst,
		  SysEnable => expe_enable,
		  ChnlEnable => tdc_reg_channel_en(0),
		  fifo_rst => fifo_rst,
		  ChnlFifoRdEn => ChnlFifoRdEn(0),
		  ChnlFlags => "01000000",
		  Cout => testsig(0),
		  ChnlFifoAlmostFull => ChnlFifoAlmostFull(0),
		  ChnlFifoEmpty => ChnlFifoEmpty(0),
		  ChnlFifoFull => ChnlFifoFull(0),
		  ChnlFifoProgFull => ChnlFifoProgFull(0),
		  TDCDataOut => TDCDataOut(0),
		  Token_in => Token_in(0),
		  Token_out => Token_out(0),
		  RdFifoWren => RdFifoWren(0)
		  );

Chnl_2_inst: singlechnl
 port map (
	     Clk => Clk,
		  InvClk => InvClk,
		  FifoClk => sys_clk,
	     HitIn => HitIn(2),
		  SysClear => sys_rst,
		  SysEnable => expe_enable,
		  ChnlEnable => tdc_reg_channel_en(1),
		  fifo_rst => fifo_rst,
		  ChnlFifoRdEn => ChnlFifoRdEn(1),
		  ChnlFlags => "01000001",
		  Cout => testsig(1),
		  ChnlFifoAlmostFull => ChnlFifoAlmostFull(1),
		  ChnlFifoEmpty => ChnlFifoEmpty(1),
		  ChnlFifoFull => ChnlFifoFull(1),
		  ChnlFifoProgFull => ChnlFifoProgFull(1),
		  TDCDataOut => TDCDataOut(1),
		  Token_in => Token_in(1),
		  Token_out => Token_out(1),
		  RdFifoWren => RdFifoWren(1)
		  );
		  
Chnl_3_inst: singlechnl
 port map (
	     Clk => Clk,
		  InvClk => InvClk,
		  FifoClk => sys_clk,
	     HitIn => HitIn(3),
		  SysClear => sys_rst,
		  SysEnable => expe_enable,--'0',--
		  ChnlEnable => tdc_reg_channel_en(2),
		  fifo_rst => fifo_rst,
		  ChnlFifoRdEn => ChnlFifoRdEn(2),
		  ChnlFlags => "01000010",
		  Cout => testsig(2),
		  ChnlFifoAlmostFull => ChnlFifoAlmostFull(2),
		  ChnlFifoEmpty => ChnlFifoEmpty(2),
		  ChnlFifoFull => ChnlFifoFull(2),
		  ChnlFifoProgFull => ChnlFifoProgFull(2),
		  TDCDataOut => TDCDataOut(2),
		  Token_in => Token_in(2),
		  Token_out => Token_out(2),
		  RdFifoWren => RdFifoWren(2)
		  );

Chnl_4_inst: singlechnl
 port map(
	     Clk => Clk,
		  InvClk => InvClk,
		  FifoClk => sys_clk,
	     HitIn => HitIn(4),
		  SysClear => sys_rst,
		  SysEnable => expe_enable,--'0',--
		  ChnlEnable => tdc_reg_channel_en(3),
		  fifo_rst => fifo_rst,
		  ChnlFifoRdEn => ChnlFifoRdEn(3),
		  ChnlFlags => "01000011",
		  Cout => testsig(3),
		  ChnlFifoAlmostFull => ChnlFifoAlmostFull(3),
		  ChnlFifoEmpty => ChnlFifoEmpty(3),
		  ChnlFifoFull => ChnlFifoFull(3),
		  ChnlFifoProgFull => ChnlFifoProgFull(3),
		  TDCDataOut => TDCDataOut(3),
		  Token_in => Token_in(3),
		  Token_out => Token_out(3),
		  RdFifoWren => RdFifoWren(3)
		  );
		  
Chnl_5_inst: singlechnl
 port map(
	     Clk => Clk,
		  InvClk => InvClk,
		  FifoClk => sys_clk,
	     HitIn => HitIn(5),
		  SysClear => sys_rst,
		  SysEnable => expe_enable,--'0',--
		  ChnlEnable => tdc_reg_channel_en(4),
		  fifo_rst => fifo_rst,
		  ChnlFifoRdEn => ChnlFifoRdEn(4),
		  ChnlFlags => "01000100",
		  Cout => testsig(4),
		  ChnlFifoAlmostFull => ChnlFifoAlmostFull(4),
		  ChnlFifoEmpty => ChnlFifoEmpty(4),
		  ChnlFifoFull => ChnlFifoFull(4),
		  ChnlFifoProgFull => ChnlFifoProgFull(4),
		  TDCDataOut => TDCDataOut(4),
		  Token_in => Token_in(4),
		  Token_out => Token_out(4),
      RdFifoWren => RdFifoWren(4)
		  );

Chnl_6_inst: singlechnl
 port map(
	     Clk => Clk,
		  InvClk => InvClk,
		  FifoClk => sys_clk,
	     HitIn => HitIn(6),
		  SysClear => sys_rst,
		  SysEnable => expe_enable,--'0',--
		  ChnlEnable => tdc_reg_channel_en(5),
		  fifo_rst => fifo_rst,
		  ChnlFifoRdEn => ChnlFifoRdEn(5),
		  ChnlFlags => "01000101",
		  Cout => testsig(5),
		  ChnlFifoAlmostFull => ChnlFifoAlmostFull(5),
		  ChnlFifoEmpty => ChnlFifoEmpty(5),
		  ChnlFifoFull => ChnlFifoFull(5),
		  ChnlFifoProgFull => ChnlFifoProgFull(5),
		  TDCDataOut => TDCDataOut(5),
		  Token_in => Token_in(5),
		  Token_out => Token_out(5),
        RdFifoWren => RdFifoWren(5)
		  );

Chnl_7_inst: singlechnl
 port map(
	     Clk => Clk,
		  InvClk => InvClk,
		  FifoClk => sys_clk,
	     HitIn => HitIn(7),
		  SysClear => sys_rst,
		  SysEnable => expe_enable,--'0',--
		  ChnlEnable => tdc_reg_channel_en(6),
		  fifo_rst => fifo_rst,
		  ChnlFifoRdEn => ChnlFifoRdEn(6),
		  ChnlFlags => "01000110",
		  Cout => testsig(6),
		  ChnlFifoAlmostFull => ChnlFifoAlmostFull(6),
		  ChnlFifoEmpty => ChnlFifoEmpty(6),
		  ChnlFifoFull => ChnlFifoFull(6),
		  ChnlFifoProgFull => ChnlFifoProgFull(6),
		  TDCDataOut => TDCDataOut(6),
		  Token_in => Token_in(6),
		  Token_out => Token_out(6),
		  RdFifoWren => RdFifoWren(6)
		  );

Chnl_8_inst: singlechnl
 port map(
	     Clk => Clk,
		  InvClk => InvClk,
		  FifoClk => sys_clk,
	     HitIn => HitIn(8),
		  SysClear => sys_rst,
		  SysEnable => expe_enable,--'0',--
		  ChnlEnable => tdc_reg_channel_en(7),
		  fifo_rst => fifo_rst,
		  ChnlFifoRdEn => ChnlFifoRdEn(7),
		  ChnlFlags => "01000111",
		  Cout => testsig(7),
		  ChnlFifoAlmostFull => ChnlFifoAlmostFull(7),
		  ChnlFifoEmpty => ChnlFifoEmpty(7),
		  ChnlFifoFull => ChnlFifoFull(7),
		  ChnlFifoProgFull => ChnlFifoProgFull(7),
		  TDCDataOut => TDCDataOut(7),
		  Token_in => Token_in(7),
		  Token_out => Token_out(7),
		  RdFifoWren => RdFifoWren(7)
		  );

Chnl_9_inst: singlechnl
 port map(
	     Clk => Clk,
		  InvClk => InvClk,
		  FifoClk => sys_clk,
	     HitIn => HitIn(9),
		  SysClear => sys_rst,
		  SysEnable => expe_enable,--'0',--
		  ChnlEnable => tdc_reg_channel_en(8),
		  fifo_rst => fifo_rst,
		  ChnlFifoRdEn => ChnlFifoRdEn(8),
		  ChnlFlags => "01001000",
		  Cout => testsig(8),
		  ChnlFifoAlmostFull => ChnlFifoAlmostFull(8),
		  ChnlFifoEmpty => ChnlFifoEmpty(8),
		  ChnlFifoFull => ChnlFifoFull(8),
		  ChnlFifoProgFull => ChnlFifoProgFull(8),
		  TDCDataOut => TDCDataOut(8),
		  Token_in => Token_in(8),
		  Token_out => Token_out(8),
		  RdFifoWren => RdFifoWren(8)
		  );

Chnl_10_inst: singlechnl
 port map(
	     Clk => Clk,
		  InvClk => InvClk,
		  FifoClk => sys_clk,
	     HitIn => HitIn(10),--'0',--
		  fifo_rst => fifo_rst,
		  SysClear => sys_rst,
		  SysEnable => expe_enable,--'0',--
		  ChnlEnable => tdc_reg_channel_en(9),
		  ChnlFifoRdEn => ChnlFifoRdEn(9),
		  ChnlFlags => "01001001",
		  Cout => testsig(9),
		  ChnlFifoAlmostFull => ChnlFifoAlmostFull(9),
		  ChnlFifoEmpty => ChnlFifoEmpty(9),
		  ChnlFifoFull => ChnlFifoFull(9),
		  ChnlFifoProgFull => ChnlFifoProgFull(9),
		  TDCDataOut => TDCDataOut(9),
		  Token_in => Token_in(9),
		  Token_out => Token_out(9),
		  RdFifoWren => RdFifoWren(9)
		  );

Chnl_11_inst: singlechnl
 port map(
	     Clk => Clk,
		  InvClk => InvClk,
		  FifoClk => sys_clk,
	     HitIn => HitIn(11),
		  SysClear => sys_rst,
		  SysEnable => expe_enable,
		  ChnlEnable => tdc_reg_channel_en(10),
		  fifo_rst => fifo_rst,
		  ChnlFifoRdEn => ChnlFifoRdEn(10),
		  ChnlFlags => "01001010",
		  Cout => testsig(10),
		  ChnlFifoAlmostFull => ChnlFifoAlmostFull(10),
		  ChnlFifoEmpty => ChnlFifoEmpty(10),
		  ChnlFifoFull => ChnlFifoFull(10),
		  ChnlFifoProgFull => ChnlFifoProgFull(10),
		  TDCDataOut => TDCDataOut(10),
		  Token_in => Token_in(10),
		  Token_out => Token_out(10),
		  RdFifoWren => RdFifoWren(10)
		  );

Chnl_12_inst: singlechnl
 port map(
	     Clk => Clk,
		  InvClk => InvClk,
		  FifoClk => sys_clk,
	     HitIn => HitIn(12),--'0',--
		  SysClear => sys_rst,
		  SysEnable => expe_enable,--'0',--
		  ChnlEnable => tdc_reg_channel_en(11),
		  fifo_rst => fifo_rst,
		  ChnlFifoRdEn => ChnlFifoRdEn(11),
		  ChnlFlags => "01001011",
		  Cout => testsig(11),
		  ChnlFifoAlmostFull => ChnlFifoAlmostFull(11),
		  ChnlFifoEmpty => ChnlFifoEmpty(11),
		  ChnlFifoFull => ChnlFifoFull(11),
		  ChnlFifoProgFull => ChnlFifoProgFull(11),
		  TDCDataOut => TDCDataOut(11),
		  Token_in => Token_in(11),
		  Token_out => Token_out(11),
		  RdFifoWren => RdFifoWren(11)
		  );

Chnl_13_inst: singlechnl
 port map(
	     Clk => Clk,
		  InvClk => InvClk,
		  FifoClk => sys_clk,
	     HitIn => HitIn(13),
		  SysClear => sys_rst,
		  SysEnable => expe_enable,--'0',--
		  ChnlEnable => tdc_reg_channel_en(12),
		  fifo_rst => fifo_rst,
		  ChnlFifoRdEn => ChnlFifoRdEn(12),
		  ChnlFlags => "01001100",
		  Cout => testsig(12),
		  ChnlFifoAlmostFull => ChnlFifoAlmostFull(12),
		  ChnlFifoEmpty => ChnlFifoEmpty(12),
		  ChnlFifoFull => ChnlFifoFull(12),
		  ChnlFifoProgFull => ChnlFifoProgFull(12),
		  TDCDataOut => TDCDataOut(12),
		  Token_in => Token_in(12),
		  Token_out => Token_out(12),
		  RdFifoWren => RdFifoWren(12)
		  );

Chnl_14_inst: singlechnl
 port map(
	     Clk => Clk,
		  InvClk => InvClk,
		  FifoClk => sys_clk,
	     HitIn => HitIn(14),
		  SysClear => sys_rst,
		  SysEnable => expe_enable,--'0',--
		  ChnlEnable => tdc_reg_channel_en(13),
		  fifo_rst => fifo_rst,
		  ChnlFifoRdEn => ChnlFifoRdEn(13),
		  ChnlFlags => "01001101",
		  Cout => testsig(13),
		  ChnlFifoAlmostFull => ChnlFifoAlmostFull(13),
		  ChnlFifoEmpty => ChnlFifoEmpty(13),
		  ChnlFifoFull => ChnlFifoFull(13),
		  ChnlFifoProgFull => ChnlFifoProgFull(13),
		  TDCDataOut => TDCDataOut(13),
		  Token_in => Token_in(13),
		  Token_out => Token_out(13),
		  RdFifoWren => RdFifoWren(13)
		  );

Chnl_15_inst: singlechnl
 port map(
	     Clk => Clk,
		  InvClk => InvClk,
		  FifoClk => sys_clk,
	     HitIn => HitIn(15),--'0',--
		  SysClear => sys_rst,
		  SysEnable => expe_enable,--'0',--
		  ChnlEnable => tdc_reg_channel_en(14),
		  fifo_rst => fifo_rst,
		  ChnlFifoRdEn => ChnlFifoRdEn(14),
		  ChnlFlags => "01001110",
		  Cout => testsig(14),
		  ChnlFifoAlmostFull => ChnlFifoAlmostFull(14),
		  ChnlFifoEmpty => ChnlFifoEmpty(14),
		  ChnlFifoFull => ChnlFifoFull(14),
		  ChnlFifoProgFull => ChnlFifoProgFull(14),
		  TDCDataOut => TDCDataOut(14),
		  Token_in => Token_in(14),
		  Token_out => Token_out(14),
		  RdFifoWren => RdFifoWren(14)
		  );

Chnl_16_inst: singlechnl
 port map(
	     Clk => Clk,
		  InvClk => InvClk,
		  FifoClk => sys_clk,
	     HitIn => HitIn(16),
		  SysClear => sys_rst,
		  SysEnable => expe_enable,--'0',--
		  ChnlEnable => tdc_reg_channel_en(15),
		  fifo_rst => fifo_rst,
		  ChnlFifoRdEn => ChnlFifoRdEn(15),
		  ChnlFlags => "01001111",
		  Cout => testsig(15),
		  ChnlFifoAlmostFull => ChnlFifoAlmostFull(15),
		  ChnlFifoEmpty => ChnlFifoEmpty(15),
		  ChnlFifoFull => ChnlFifoFull(15),
		  ChnlFifoProgFull => ChnlFifoProgFull(15),
		  TDCDataOut => TDCDataOut(15),
		  Token_in => Token_in(15),
		  Token_out => Token_out(15),
		  RdFifoWren => RdFifoWren(15)
		  );
		  

					
--WrEn_tmp<= ChnlFifoRdEn(0) when FifoDataSel= "00001" else
--           ChnlFifoRdEn(1) when FifoDataSel= "00010" else
--			  ChnlFifoRdEn(2) when FifoDataSel= "00011" else
--			  ChnlFifoRdEn(3) when FifoDataSel= "00100" else
--			  ChnlFifoRdEn(4) when FifoDataSel= "00101" else
--			  ChnlFifoRdEn(5) when FifoDataSel= "00110" else
--			  ChnlFifoRdEn(6) when FifoDataSel= "00111" else
--			  ChnlFifoRdEn(7) when FifoDataSel= "01000" else
--			  ChnlFifoRdEn(8) when FifoDataSel= "01001" else
--			  ChnlFifoRdEn(9) when FifoDataSel= "01010" else
--			  ChnlFifoRdEn(10) when FifoDataSel= "01011" else
--			  ChnlFifoRdEn(11) when FifoDataSel= "01100" else
--			  ChnlFifoRdEn(12) when FifoDataSel= "01101" else
--			  ChnlFifoRdEn(13) when FifoDataSel= "01110" else
--			  ChnlFifoRdEn(14) when FifoDataSel= "01111" else
--			  ChnlFifoRdEn(15) when FifoDataSel= "10000" else
--			  '0';

WrEn_tmp <= '0' when RdFifoWren <="0000000000000000" else '1';			  
------------------------------------------------------------------------------------------------------
--------------------------------------direct to cpldif:tdc(64)->cpldif(32) begin-----------------------
--WrEn_Gen_process:process(sys_clk,sys_rst)
--  begin
--		if(sys_rst ='1')then
--			  WrEn <='0';
--      elsif(sys_clk'event and sys_clk='1') then
--		   if(DW64to32_fifo_almost_full='1')then
--			  WrEn <='0';
--			else
--		     WrEn<= WrEn_tmp;
--         end if;			  
--		end if;
--  end process;
--
--DW64to32_fifo_rd_process:process(sys_clk,sys_rst)
--  begin
--      if(sys_rst ='1')then
--			  DW64to32_fifo_rd_en <='0';
--		elsif(sys_clk'event and sys_clk='1') then
--		   if(DW64to32_fifo_almost_empty = '0' and cpldif_tdc_fifo_prog_full = '0')then
--		     DW64to32_fifo_rd_en <='1';
--			else
--				DW64to32_fifo_rd_en <='0';
--         end if;			  
--		end if;
--  end process;
--  
--  
--cpldif_tdc_fifo_wr_process:process(sys_clk,sys_rst)
--  begin
--      if(sys_rst ='1')then
--			tdc_cpldif_fifo_wr_en <='0';
--		elsif(sys_clk'event and sys_clk='1') then
--		   tdc_cpldif_fifo_wr_en <= DW64to32_fifo_rd_en;			  
--		end if;
--  end process;
--  
--  
--DWidth_64to32_fifo_inst : DWidth_64to32_fifo
--  PORT MAP (
--    rst => sys_rst,
--    wr_clk => sys_clk,
--    rd_clk => sys_clk,
--    din => DataOut_tmp1,
--    wr_en => WrEn,
--    rd_en => DW64to32_fifo_rd_en,
--    dout => tdc_cpldif_fifo_wr_data,
--    full => open,
--    almost_full => DW64to32_fifo_almost_full,
--    empty => open,
--	 almost_empty => DW64to32_fifo_almost_empty
--  );
--------------------------------------direct to cpldif:tdc(64)->cpldif(32) end----------------------- 
------------------------------------------------------------------------------------------------------
  
-----------------------------fifo ctrl:tdc(64b)->frame(16)->sdram(16)->cpldif(32) begin---------------------------------------------------

WrEn_Gen_process:process(sys_clk,sys_rst)
  begin
		if(sys_rst ='1')then
			  WrEn <='0';
      elsif(sys_clk'event and sys_clk='1') then
		   if(tdc_frame_fifo_almost_full = '1')then
			  WrEn <='0';
			else
		     WrEn<= WrEn_tmp;
         end if;			  
		end if;
  end process;

tdc_frame_fifo_inst : tdc_frame_fifo-------64bit-->16bit
  PORT MAP (
    rst => fifo_rst,
    wr_clk => sys_clk,
    rd_clk => sys_clk,
    din => DataOut_tmp1,
    wr_en => WrEn,
    rd_en => tdc_frame_fifo_rd_en,
    dout => tdc_frame_fifo_dout,
    full => open,
    almost_full => tdc_frame_fifo_almost_full,
    empty => open,
    almost_empty => tdc_frame_fifo_almost_empty
  );
  
  	Inst_FramePack: FramePack PORT MAP(
		sys_clk => sys_clk,
		sys_rst_n => sys_rst_n,
		fifo_rst => fifo_rst,
		frame_en => expe_enable,
		tdc_frame_fifo_almost_empty => tdc_frame_fifo_almost_empty,
		tdc_frame_fifo_rd_en => tdc_frame_fifo_rd_en,
		tdc_frame_fifo_dout => tdc_frame_fifo_dout,
		frame_sdram_fifo_rd_en => frame_sdram_fifo_rd_en,
		frame_sdram_fifo_rd_clk => frame_sdram_fifo_rd_clk,
		frame_sdram_fifo_rd_data_count => frame_sdram_fifo_rd_data_count,
		frame_sdram_fifo_almost_empty => frame_sdram_fifo_almost_empty,
		frame_sdram_fifo_dout => frame_sdram_fifo_dout
	);
	
--	  frame_sdram_fifo_rd_en_process:process(sys_clk,sys_rst)
--  begin
--      if(sys_rst ='1')then
--			  frame_sdram_fifo_rd_en <='0';
--		elsif(sys_clk'event and sys_clk='1') then
--		   if(frame_sdram_fifo_almost_empty = '0' and sdram_cpldif_fifo_almost_full = '0')then
--		     frame_sdram_fifo_rd_en <='1';
--			else
--				frame_sdram_fifo_rd_en <='0';
--         end if;
--			sdram_cpldif_fifo_wr_en <= frame_sdram_fifo_rd_en;
--		end if;
--  end process;
--sdram_cpldif_fifo_din <= frame_sdram_fifo_dout;
--sdram_cpldif_fifo_wr_clk <= sys_clk;
--frame_sdram_fifo_rd_clk <= sys_clk;

	Inst_RAMctrl: RAMctrl PORT MAP(
		sys_clk => sys_clk_60M,
		nRESET => sys_rst_n,
		nRESET_RAM => tdc_fifo_clear_n,
		RF_DIN => sdram_cpldif_fifo_din,
		RF_WR_EN => sdram_cpldif_fifo_wr_en,
		RF_WR_CLK => sdram_cpldif_fifo_wr_clk,
		RF_WR_DATA_COUNT => sdram_cpldif_fifo_wr_data_count,
		WF_DOUT => frame_sdram_fifo_dout,
		WF_RD_DATA_COUNT => frame_sdram_fifo_rd_data_count,
		WF_RD_EN => frame_sdram_fifo_rd_en,
		WF_RD_CLK => frame_sdram_fifo_rd_clk,
		DQ => tdc_sdram_dq,
		DQML => tdc_sdram_dqml,
		DQMH => tdc_sdram_dqmh,
		nWE => tdc_sdram_we_n,
		nCAS => tdc_sdram_cas_n,
		nRAS => tdc_sdram_ras_n,
		nCS => tdc_sdram_cs_n,
		BA => tdc_sdram_ba,
		A => tdc_sdram_a,
		CKE => tdc_sdram_cke,
		WRITE_RAM_EN => open,
		READ_RAM_EN => open,
		READ_RAM_READY => open,
		READ_RAM_DONE => open,
		WRITE_RAM_READY => open,
		WRITE_RAM_DONE => open,
		INIT_DONE => open,
		ACTIONFORBID => open,
		testsignal => open,
		STATE_WR => open,
		Read_Enable => open,
		Write_Enable => open,
		UsedWord => open
	);
	
	sdram_cpldif_fifo_inst : sdram_cpldif_fifo
  PORT MAP (
    rst => fifo_rst,
    wr_clk => sdram_cpldif_fifo_wr_clk,
    rd_clk => sys_clk,
    din => sdram_cpldif_fifo_din,
    wr_en => sdram_cpldif_fifo_wr_en,
    rd_en => sdram_cpldif_fifo_rd_en,
    dout => sdram_cpldif_fifo_dout,
    full => open,
    almost_full => sdram_cpldif_fifo_almost_full,
    empty => open,
    almost_empty => sdram_cpldif_fifo_almost_empty,
    wr_data_count => sdram_cpldif_fifo_wr_data_count
  );
  
  sdram_cpldif_fifo_rd_process:process(sys_clk,sys_rst)
  begin
      if(sys_rst ='1')then
			  sdram_cpldif_fifo_rd_en <='0';
		elsif(sys_clk'event and sys_clk='1') then
		   if(sdram_cpldif_fifo_almost_empty = '0' and cpldif_tdc_fifo_prog_full = '0')then
		     sdram_cpldif_fifo_rd_en <='1';
			else
				sdram_cpldif_fifo_rd_en <='0';
         end if;
		end if;
  end process;
  
  
cpldif_tdc_fifo_wr_process:process(sys_clk,sys_rst)
  begin
      if(sys_rst ='1')then
			sdram_cpldif_fifo_rd_en_1d <='0';
			tdc_cpldif_fifo_wr_en <='0';
		elsif(sys_clk'event and sys_clk='1') then
		   sdram_cpldif_fifo_rd_en_1d <= sdram_cpldif_fifo_rd_en;			  
		   tdc_cpldif_fifo_wr_en <= sdram_cpldif_fifo_rd_en_1d;			  
		end if;
  end process;

tdc_cpldif_fifo_wr_data_reverse_process:process(sys_clk,sys_rst)
  begin
      if(sys_rst ='1')then
			tdc_cpldif_fifo_wr_data <=(others => '0');
		elsif(sys_clk'event and sys_clk='1') then
		   tdc_cpldif_fifo_wr_data(31 downto 16) <= sdram_cpldif_fifo_dout(15 downto 0);			  
		   tdc_cpldif_fifo_wr_data(15 downto 0) <= sdram_cpldif_fifo_dout(31 downto 16);			  
		end if;
  end process;  
--  tdc_cpldif_fifo_wr_data <= sdram_cpldif_fifo_dout;
-----------------------------fifo ctrl:tdc(64b)->frame(16)->sdram(16)->cpldif(32) end-----------------------------------------------------  
--DataOut_tmp(48 downto 0)<= TDCDataOut(0) when FifoDataSel= "00001" else
--                           TDCDataOut(1) when FifoDataSel= "00010" else
--									TDCDataOut(2) when FifoDataSel= "00011" else
--									TDCDataOut(3) when FifoDataSel= "00100" else
--									TDCDataOut(4) when FifoDataSel= "00101" else
--									TDCDataOut(5) when FifoDataSel= "00110" else
--									TDCDataOut(6) when FifoDataSel= "00111" else
--									TDCDataOut(7) when FifoDataSel= "01000" else
--									TDCDataOut(8) when FifoDataSel= "01001" else
--									TDCDataOut(9) when FifoDataSel= "01010" else
--									TDCDataOut(10) when FifoDataSel= "01011" else
--									TDCDataOut(11) when FifoDataSel= "01100" else
--									TDCDataOut(12) when FifoDataSel= "01101" else
--									TDCDataOut(13) when FifoDataSel= "01110" else
--									TDCDataOut(14) when FifoDataSel= "01111" else
--									TDCDataOut(15) when FifoDataSel= "10000" else
--			                  (others =>'0');
DataOut_tmp(63 downto 0)<= TDCDataOut(0) when RdFifoWren(0)='1' else	
                           TDCDataOut(1) when RdFifoWren(1)='1' else
                           TDCDataOut(2) when RdFifoWren(2)='1' else
                           TDCDataOut(3) when RdFifoWren(3)='1' else
									TDCDataOut(4) when RdFifoWren(4)='1' else
									TDCDataOut(5) when RdFifoWren(5)='1' else
									TDCDataOut(6) when RdFifoWren(6)='1' else
                           TDCDataOut(7) when RdFifoWren(7)='1' else
									TDCDataOut(8) when RdFifoWren(8)='1' else
									TDCDataOut(9) when RdFifoWren(9)='1' else
									TDCDataOut(10) when RdFifoWren(10)='1' else
									TDCDataOut(11) when RdFifoWren(11)='1' else
									TDCDataOut(12) when RdFifoWren(12)='1' else
									TDCDataOut(13) when RdFifoWren(13)='1' else
									TDCDataOut(14) when RdFifoWren(14)='1' else
									TDCDataOut(15) when RdFifoWren(15)='1' else
                           (others =>'0');									
--DataOut_tmp(63 downto 49) <=(others =>'1');
--DataOut_tmp(63 downto 48) <="0101010101010101";
Token_in(16)<=Token_out(0);
Token_in(1)<=Token_out(16);
Token_in(2)<=Token_out(1);
Token_in(3)<=Token_out(2);
Token_in(4)<=Token_out(3);
--Token_in(0)<=Token_out(3);
--
Token_in(5)<=Token_out(4);
Token_in(6)<=Token_out(5);
Token_in(7)<=Token_out(6);
Token_in(8)<=Token_out(7);
Token_in(9)<=Token_out(8);
Token_in(10)<=Token_out(9);
Token_in(11)<=Token_out(10);
Token_in(12)<=Token_out(11);
Token_in(13)<=Token_out(12);
Token_in(14)<=Token_out(13);
Token_in(15)<=Token_out(14);
Token_in(0)<=Token_out(15);

re_compose_data: process(sys_clk,DataOut_tmp)-----------------------------------------？？？？
begin
   if(sys_clk'event and sys_clk='1')then
--     DataOut_tmp1(7 downto 0)<= DataOut_tmp(7 downto 0);
--     DataOut_tmp1(15 downto 8)<= DataOut_tmp(15 downto 8);---------细计数7-0
--     DataOut_tmp1(39 downto 16)<= DataOut_tmp(40 downto 17);
--     DataOut_tmp1(47 downto 40)<= DataOut_tmp(48 downto 41);
--     DataOut_tmp1(48)<= DataOut_tmp(16);-------------------------细计数第九位
--     DataOut_tmp1(63 downto 49)<= DataOut_tmp(63 downto 49);


----------------change the high 8bits and the low 8bits--------------------	  
--	  DataOut_tmp1(7 downto 0)<= DataOut_tmp(15 downto 8);
--     DataOut_tmp1(15 downto 8)<= DataOut_tmp(7 downto 0);---------细计数7-0
--     DataOut_tmp1(23 downto 16)<= DataOut_tmp(32 downto 25);
--	  DataOut_tmp1(31 downto 24)<= DataOut_tmp(24 downto 17);
--	  DataOut_tmp1(39 downto 32)<= DataOut_tmp(48 downto 41);
--	  DataOut_tmp1(47 downto 40)<= DataOut_tmp(40 downto 33);
--     DataOut_tmp1(55 downto 48)<= DataOut_tmp(63 downto 56);
--	  DataOut_tmp1(56)<= DataOut_tmp(16);-------------------------细计数第九位
--     DataOut_tmp1(63 downto 57)<= DataOut_tmp(55 downto 49);
     DataOut_tmp1<= DataOut_tmp;
	end if;
end process;					

--tdc_cpldif_fifo_wr_en <=  WrEn;
--Data2RdoFifo <= DataOut_tmp1; 


tp(0) <= sys_clk;
tp(1)	<= WrEn;
tp(2)	<= trigger;
tp(3)	<= LOCKED;
tp(4)	<= sys_rst;
tp(5)	<= expe_enable;
--testsig(0)	<= S_Clk_n;
--testsig(15 downto 1) <= (others => '0');
end Behavioral;

