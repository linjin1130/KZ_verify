----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:53:51 02/27/2015 
-- Design Name: 
-- Module Name:    KZ_verify_top - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity KZ_verify_top is
generic(
     constant IODELAY_GRP    : string := "IODELAY_MIG";  -- May be assigned unique name when
		KZ_VRF_Base_Addr : std_logic_vector(7 downto 0) := X"B0";
		KZ_VRF_High_Addr : std_logic_vector(7 downto 0) := X"BF"
		);
	port(
	-- fix by herry make sys_clk_80M to sys_clk_160M
	   sys_clk_dcm	:	in	std_logic;--system clock,200MHz
	   sys_clk_80M		:	in	std_logic;--system clock,80MHz
		sys_clk_320M		:	in	std_logic;--system clock,320MHz
		sys_rst_n		:	in	std_logic;--system reset,low active
		tdc_cpldif_fifo_clr:	out	std_logic;--system reset,low active
		
		LD_pulse_in_p	:	in	std_logic_vector(19 downto 0);
		LD_pulse_in_n	:	in	std_logic_vector(19 downto 0);
		----delay chip NB6L295-D
		Dac_en	   : out  STD_LOGIC; --DAC chip enable
		Dac_Sclk   : out  STD_LOGIC; --DAC chip clock
		Dac_Csn    : out  STD_LOGIC; --DAC chip select
		Dac_Din    : out  STD_LOGIC; --DAC data input

		---cpldif module
		cpldif_kz_vrf_addr	:	in	std_logic_vector(7 downto 0);
		cpldif_kz_vrf_wr_en	:	in	std_logic;
		cpldif_kz_vrf_rd_en	:	in	std_logic;
		cpldif_kz_vrf_wr_data	:	in	std_logic_vector(31 downto 0);
		kz_vrf_cpldif_rd_data	:	out	std_logic_vector(31 downto 0);
		
		compare_total_cnt_1	:	out	std_logic_vector(31 downto 0);
		compare_error_cnt_1	:	out	std_logic_vector(31 downto 0);
		
		compare_total_cnt_2	:	out	std_logic_vector(31 downto 0);
		compare_error_cnt_2	:	out	std_logic_vector(31 downto 0);
		
		iodelay_ctrl_rdy  : out 	std_logic;
		
		compare_result_wr  : out 	std_logic;
		compare_result		 : out 	std_logic_vector(63 downto 0)
	);
end KZ_verify_top;

architecture Behavioral of KZ_verify_top is
COMPONENT kz_reg_resolve
	PORT(
		sys_clk_80M : IN std_logic;
		sys_rst_n : IN std_logic;
		fifo_clr : OUT std_logic;
		cpldif_kz_vrf_addr : IN std_logic_vector(7 downto 0);
		cpldif_kz_vrf_wr_en : IN std_logic;
		cpldif_kz_vrf_rd_en : IN std_logic;
		cpldif_kz_vrf_wr_data : IN std_logic_vector(31 downto 0);          
		verify_active_1 : OUT std_logic;
		verify_active_2 : OUT std_logic;
		Dac_Ena 		:  OUT std_logic;
		Dac_data		:	out std_logic_vector(15 downto 0);
		ram_wr_en_1 : OUT std_logic;
		ram_wr_en_2 : OUT std_logic;
		ram_wr_data : OUT std_logic_vector(7 downto 0);
		ram_wr_addr : OUT std_logic_vector(19 downto 0);
		kz_vrf_cpldif_rd_data : OUT std_logic_vector(31 downto 0);
		delay_load_en : OUT std_logic_vector(19 downto 0);
		delay_load_data : OUT std_logic_vector(4 downto 0)
		);
	END COMPONENT;
	
	COMPONENT IODELAY_CTRL
	generic(
     constant IODELAY_GRP    : string := "IODELAY_MIG"  -- May be assigned unique name when
	  );
	PORT(
		control_clk : IN std_logic;
		delay_in : IN std_logic;
		delay_load : IN std_logic;
		CNTVALUEIN : IN std_logic_vector(4 downto 0);          
		delay_out : OUT std_logic;
		CNTVALUEOUT : OUT std_logic_vector(4 downto 0)
		);
	END COMPONENT;

COMPONENT data_compare_unit
	PORT(
		sys_clk_80M : IN std_logic;
		sys_clk_320M		:	in	std_logic;--system clock,320MHz
		sys_rst_n : IN std_logic;
		flag_bit : IN std_logic;
		verify_active : IN std_logic;
		ram_wr_en : IN std_logic;
		ram_wr_data : IN std_logic_vector(7 downto 0);
		ram_wr_addr : IN std_logic_vector(19 downto 0);
		fifo_prog_empty : IN std_logic;
		fifo_rd_vld : IN std_logic;
		fifo_rd_data : IN std_logic_vector(7 downto 0);          
		compare_total_cnt : OUT std_logic_vector(31 downto 0);          
		compare_error_cnt : OUT std_logic_vector(31 downto 0);          
		fifo_rd_en : OUT std_logic;
		compare_result_wr : OUT std_logic;
		compare_result : OUT std_logic_vector(63 downto 0)
		);
	END COMPONENT;
	
	COMPONENT data_gen_unit
	PORT(
		sys_clk_80M : IN std_logic;
		sys_rst_n : IN std_logic;
		fifo_clr : IN std_logic;
		verify_active : IN std_logic;
		control_clk : IN std_logic;
		kz_data_in : IN std_logic_vector(7 downto 0);
		fifo_rd_en : IN std_logic;          
		fifo_prog_empty : OUT std_logic;
		fifo_rd_vld : OUT std_logic;
		fifo_rd_data : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT merge_fifo
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(129 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(64 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC
  );
END COMPONENT;

component kz_dcm
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic;
  -- Status and control signals
  RESET             : in     std_logic;
  LOCKED            : out    std_logic
 );
end component;

	COMPONENT NB6L295_CTRL
    PORT(
         CLK : IN  std_logic;
         Dac_Ena : IN  std_logic;
         Dac_Data : IN  std_logic_vector(15 downto 0);
         Sys_Rst_n : IN  std_logic;
         Dac_Finish : OUT  std_logic;
         Dac_en : OUT  std_logic;
         Dac_Sclk : OUT  std_logic;
         Dac_Csn : OUT  std_logic;
         Dac_Din : OUT  std_logic
        );
    END COMPONENT;

--COMP_TAG_END ------ End COMPONENT Declaration -----------
	
	signal verify_active_1 			: std_logic;
	signal verify_active_2			: std_logic;
	signal ram_wr_en_1 				: std_logic;
	signal ram_wr_en_2 				: std_logic;
	signal ram_wr_data 				: std_logic_vector(7 downto 0);
	signal ram_wr_addr 				: std_logic_vector(19 downto 0);
	signal delay_load_en 				: std_logic_vector(19 downto 0);
	signal delay_load_data 			: std_logic_vector(4 downto 0);
		
	signal delay_in 	:  std_logic_vector(15 downto 0);
	signal delay_out 	:  std_logic_vector(15 downto 0);
	
	signal Dac_Ena 		:  std_logic;
	signal Dac_data		:	std_logic_vector(15 downto 0);
	
	signal control_clk 		: std_logic_vector(19 downto 16);
	signal kz_data_in_1 		: std_logic_vector(7 downto 0);
	signal fifo_rd_en_1 		: std_logic;          
	signal fifo_prog_empty_1	: std_logic;
	signal fifo_rd_vld_1	 	: std_logic;
	signal fifo_rd_data_1 	: std_logic_vector(7 downto 0);
	
	signal kz_data_in_2 		: std_logic_vector(7 downto 0);
	signal fifo_rd_en_2 		: std_logic;          
	signal fifo_prog_empty_2	: std_logic;
	signal fifo_rd_vld_2	 	: std_logic;
	signal fifo_rd_data_2 	: std_logic_vector(7 downto 0);
	signal compare_result_wr_1 	: std_logic;
	signal compare_result_wr_2 	: std_logic;
	signal compare_result_1 	: std_logic_vector(63 downto 0);
	signal compare_result_2 	: std_logic_vector(63 downto 0);
	
	signal sys_clk_200M	: std_logic;
	signal sys_rst_h		: std_logic;
	signal fifo_clr		: std_logic;
	
	signal compare_result_vld_tmp		: std_logic;
	signal compare_result_empty_tmp	: std_logic;
	signal compare_result_rd_tmp		: std_logic;
	signal compare_result_wr_tmp		: std_logic;
	signal compare_result_tmp_in 		: std_logic_vector(129 downto 0);
	signal compare_result_tmp_out 	: std_logic_vector(64 downto 0);

  attribute IODELAY_GROUP : string;
  attribute IODELAY_GROUP of IDELAYCTRL_inst : label is IODELAY_GRP;
begin
------------------------------------------------------------
------apply IDELAYCTRL, data sheet require This design element 
------must be instantiated when using the IODELAYE1 in virtex 6
------but when using two IODELAYE1, this will be an error occur
------------------------------------------------------------
sys_rst_h	<= not sys_rst_n;
tdc_cpldif_fifo_clr	<= fifo_clr;
IDELAYCTRL_inst : IDELAYCTRL
port map (
RDY => iodelay_ctrl_rdy,
-- 1-bit output indicates validity of the REFCLK
REFCLK => sys_clk_200M, -- 1-bit reference clock input
RST => sys_rst_h
-- 1-bit reset input
);

-- COMP_TAG_END ------ End COMPONENT Declaration ------------
-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.
------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
kz_dcm_inst : kz_dcm
  port map
   (-- Clock in ports
    CLK_IN1 => sys_clk_dcm,
    -- Clock out ports
    CLK_OUT1 => sys_clk_200m,
    -- Status and control signals
    RESET  => '0',
    LOCKED => open);
-- INST_TAG_END ------ End INSTANTIATION Template ------------

-- 

Inst_kz_reg_resolve: kz_reg_resolve PORT MAP(
		sys_clk_80M => sys_clk_80M,
		sys_rst_n => sys_rst_n,
		fifo_clr 	=> fifo_clr,
		verify_active_1 => verify_active_1,
		verify_active_2 => verify_active_2,
		ram_wr_en_1 => ram_wr_en_1,
		ram_wr_en_2 => ram_wr_en_2,
		ram_wr_data => ram_wr_data,
		ram_wr_addr => ram_wr_addr,
		Dac_Ena => Dac_Ena,
		Dac_data => Dac_data,
		cpldif_kz_vrf_addr => cpldif_kz_vrf_addr,
		cpldif_kz_vrf_wr_en => cpldif_kz_vrf_wr_en,
		cpldif_kz_vrf_rd_en => cpldif_kz_vrf_rd_en,
		cpldif_kz_vrf_wr_data => cpldif_kz_vrf_wr_data,
		kz_vrf_cpldif_rd_data => kz_vrf_cpldif_rd_data,
		delay_load_en => delay_load_en,
		delay_load_data => delay_load_data
	);

bufds_in_inst: FOR i in 16 to 19 generate
begin
	IBUFGDS_inst : IBUFGDS
   generic map (
      DIFF_TERM => FALSE, -- Differential Termination 
      IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for refernced I/O standards
      IOSTANDARD => "DEFAULT")
   port map (
      O => control_clk(i),  -- Buffer output
      I => LD_pulse_in_p(i),  -- Diff_p buffer input (connect directly to top-level port)
      IB => LD_pulse_in_n(i) -- Diff_n buffer input (connect directly to top-level port)
   );
end generate;	

delay_unit_inst_1: FOR i in 0 to 7 generate
begin
	IBUFDS_inst : IBUFDS
   generic map (
      DIFF_TERM => FALSE, -- Differential Termination 
      IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for refernced I/O standards
      IOSTANDARD => "DEFAULT")
   port map (
      O => delay_in(i),  -- Buffer output
      I => LD_pulse_in_p(i),  -- Diff_p buffer input (connect directly to top-level port)
      IB => LD_pulse_in_n(i) -- Diff_n buffer input (connect directly to top-level port)
   );
	
	Inst_IODELAY_CTRL: IODELAY_CTRL PORT MAP(
		control_clk => control_clk(16),
		delay_in => delay_in(i),
		delay_load => delay_load_en(i),
		delay_out => delay_out(i),
		CNTVALUEIN => delay_load_data,
		CNTVALUEOUT =>open 
	);
end generate;

delay_unit_inst_2: FOR i in 8 to 15 generate
begin
	IBUFDS_inst : IBUFDS
   generic map (
      DIFF_TERM => FALSE, -- Differential Termination 
      IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for refernced I/O standards
      IOSTANDARD => "DEFAULT")
   port map (
      O => delay_in(i),  -- Buffer output
      I => LD_pulse_in_p(i),  -- Diff_p buffer input (connect directly to top-level port)
      IB => LD_pulse_in_n(i) -- Diff_n buffer input (connect directly to top-level port)
   );
	
	Inst_IODELAY_CTRL: IODELAY_CTRL PORT MAP(
		control_clk => control_clk(18),
		delay_in => delay_in(i),
		delay_load => delay_load_en(i),
		delay_out => delay_out(i),
		CNTVALUEIN => delay_load_data,
		CNTVALUEOUT =>open 
	);
end generate;

	kz_data_in_1	<= delay_out(7 downto 0);
	kz_data_in_2	<= delay_out(15 downto 8);
	Inst_data_gen_unit_1: data_gen_unit PORT MAP(
		sys_clk_80M => sys_clk_320M,
--		sys_clk_320M => sys_clk_320M,
		sys_rst_n => sys_rst_n,
		fifo_clr => fifo_clr,
		verify_active => verify_active_1,
		control_clk => control_clk(16),
		kz_data_in => kz_data_in_1,
		fifo_rd_en => fifo_rd_en_1,
		fifo_prog_empty => fifo_prog_empty_1,
		fifo_rd_vld => fifo_rd_vld_1,
		fifo_rd_data => fifo_rd_data_1
	);
	
	Inst_data_compare_unit_1: data_compare_unit PORT MAP(
		sys_clk_80M => sys_clk_80M,
		sys_clk_320M => sys_clk_320M,
		sys_rst_n => sys_rst_n,
		flag_bit => '0',
		verify_active => verify_active_1,
		ram_wr_en => ram_wr_en_1,
		ram_wr_data => ram_wr_data,
		ram_wr_addr => ram_wr_addr,
		fifo_prog_empty => fifo_prog_empty_1,
		fifo_rd_vld => fifo_rd_vld_1,
		fifo_rd_data => fifo_rd_data_1,
		fifo_rd_en => fifo_rd_en_1,
		compare_total_cnt => compare_total_cnt_1,
		compare_error_cnt => compare_error_cnt_1,
		compare_result_wr => compare_result_wr_1,
		compare_result => compare_result_1
	);

	Inst_data_gen_unit_2: data_gen_unit PORT MAP(
		sys_clk_80M => sys_clk_320M,
--		sys_clk_320M => sys_clk_320M,
		sys_rst_n => sys_rst_n,
		fifo_clr => fifo_clr,
		verify_active => verify_active_2,
		control_clk => control_clk(18),
		kz_data_in => kz_data_in_2,
		fifo_rd_en => fifo_rd_en_2,
		fifo_prog_empty => fifo_prog_empty_2,
		fifo_rd_vld => fifo_rd_vld_2,
		fifo_rd_data => fifo_rd_data_2
	);
	
	Inst_data_compare_unit_2: data_compare_unit PORT MAP(
		sys_clk_80M => sys_clk_80M,
		sys_clk_320M => sys_clk_320M,
		sys_rst_n => sys_rst_n,
		flag_bit => '1',
		verify_active => verify_active_2,
		ram_wr_en => ram_wr_en_2,
		ram_wr_data => ram_wr_data,
		ram_wr_addr => ram_wr_addr,
		fifo_prog_empty => fifo_prog_empty_2,
		fifo_rd_vld => fifo_rd_vld_2,
		fifo_rd_data => fifo_rd_data_2,
		fifo_rd_en => fifo_rd_en_2,
		compare_total_cnt => compare_total_cnt_2,
		compare_error_cnt => compare_error_cnt_2,
		compare_result_wr => compare_result_wr_2,
		compare_result => compare_result_2
	);
	
	compare_result_rd_tmp	<= not 	compare_result_empty_tmp;
	compare_result_wr_tmp	<= compare_result_wr_2 or compare_result_wr_1;	
	compare_result_tmp_in 	<= compare_result_wr_1 & compare_result_1 & compare_result_wr_2 & compare_result_2;	
	compare_result_wr			<= compare_result_tmp_out(64) and compare_result_vld_tmp;	
	compare_result				<= compare_result_tmp_out(63 downto 0);	
	
	-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
Inst_merge_fifo : merge_fifo
  PORT MAP (
    rst => fifo_clr,
    wr_clk => sys_clk_320M,
    rd_clk => sys_clk_80M,
    din => compare_result_tmp_in,
    wr_en => compare_result_wr_tmp,
    rd_en => compare_result_rd_tmp,
    dout => compare_result_tmp_out,
    full => open,
    empty => compare_result_empty_tmp,
    valid => compare_result_vld_tmp
  );
  
  NB6L295_CTRL_inst: NB6L295_CTRL PORT MAP (
          CLK => sys_clk_80M,
          Dac_Ena => Dac_Ena,
          Dac_Data => Dac_Data,
          Sys_Rst_n => Sys_Rst_n,
          Dac_Finish => open,
          Dac_en => Dac_en,
          Dac_Sclk => Dac_Sclk,
          Dac_Csn => Dac_Csn,
          Dac_Din => Dac_Din
        );
  
end Behavioral;

