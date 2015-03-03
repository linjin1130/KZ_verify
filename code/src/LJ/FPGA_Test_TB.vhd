--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:33:58 10/13/2014
-- Design Name:   
-- Module Name:   E:/Work/FPGA/FPGA_TEST/FPGA_Test_TB.vhd
-- Project Name:  FPGA_TEST
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: OSERDES_TEST
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY FPGA_Test_TB IS
END FPGA_Test_TB;
 
ARCHITECTURE behavior OF FPGA_Test_TB IS 
    -- Clock period definitions
--   constant Rnd_Gen_WNG_Clk_period : time := 10 ns;
	
	constant RND_CHIP_NUM : integer := 4;--number of random chip number
	 --============================================================================
  --                        Design Specific Parameters
  --============================================================================
  constant DATA_WIDTH            : integer := 36; -- # of data bits
  constant ADDR_WIDTH            : integer := 19; -- # of memory addr bits
  constant BURST_LEN             : integer := 4;  -- //Burst Length type
  constant BW_WIDTH              : integer := DATA_WIDTH/9; --# of Byte Write bits
  constant REFCLK_FREQ           : real    := 200.0; -- Iodelay clock freq (MHz)
  constant IODELAY_GRP           : string  := "IODELAY_MIG";
  constant NUM_DEVICES           : integer := 1; --# of clock outputs
  constant FIXED_LATENCY_MODE    : integer := 0; --Fixed latency disabled
  constant PHY_LATENCY           : integer := 0; -- Fixed Latency of 10
  constant CLK_STABLE            : integer := 2048; --Cycles until CQ is stable
  constant SIM_CAL_OPTION        : string  := "FAST_CAL"; --Skip various calib steps
  constant PHASE_DETECT          : string  := "OFF";  --Enable Phase detector
  constant DEBUG_PORT            : string  := "OFF"; --Disable debug port
  constant IBUF_LPWR_MODE        : string  := "OFF"; --Input buffer low power mode
  constant IODELAY_HP_MODE       : string  := "ON"; --IODELAY High Performance Mode
  --constant HIGH_PERFORMANCE_MODE : string  := "TRUE"; --Performance mode for IODELAYs
  constant MEMORY_WIDTH          : integer := DATA_WIDTH/NUM_DEVICES;
                                  --# of memory component's data width
  constant DLL_FREQ_MODE         : string  := "HIGH"; --DCM's DLL Frequency mode
  constant RST_ACT_LOW           : integer := 1; -- Reset Active Low
  constant INPUT_CLK_TYPE        : string  := "SINGLE_ENDED";
                                  --Differential/Single-Ended system clocks
  constant CLKFBOUT_MULT_F       : real    := 7.0; -- write PLL VCO multiplier
  constant CLKOUT_DIVIDE         : integer := 7; -- VCO output divisor for fast (memory) clocks
  constant DIVCLK_DIVIDE         : integer := 1; -- write PLL VCO divisor
  constant TCQ                   : integer := 1; --Simulation Register Delay
  constant SIM_INIT_OPTION       : string := "SIM_MODE"; -- Simulation only. "NONE", "SIM_MODE"

  constant BW_COMP               : integer := MEMORY_WIDTH/9;
  constant SYSCLK_PERIOD_TEMP    : integer := 5000; -- System Clock period (ps)
  constant SYSCLK_PERIOD         : time := SYSCLK_PERIOD_TEMP * 1000 fs; -- System Clock period (fs) for clock generation
  constant CLK_PERIOD            : integer := 5000*2; -- Internal Clock period (ps)
  constant TEMP1                 : real := 1000000.0 / 200; --Idelay Reference clock period (ps)
  constant TEMP2                 : time := 1 ps;
  constant REFCLK_PERIOD         : time := TEMP1*TEMP2; --Idelay Reference clock period (ps)
  constant TPROP_PCB_CTRL        : time := 0 ps; --Board delay value
  constant TPROP_PCB_DATA        : time := 0 ps;  -- DQ delay value
  constant TPROP_PCB_DATA_RD     : time := 0 ps;  -- READ DQ delay value
  constant RESET_PERIOD          : time := 200000 ps; -- in ps
    -- Component Declaration for the Unit Under Test (UUT)
	 
  function TERNARY_INT return time is
  variable temp : time := 0 ps;
  begin
    if(SIM_CAL_OPTION = "SKIP_CAL") then
      temp := SYSCLK_PERIOD/2;
    end if;
  return temp;
  end function;

  constant TPROP_PCB_CQ          : time := TERNARY_INT; --CQ delay to center of Q
 
 constant OSC_PERIOD         : time := 12500 ps;--oscillator period 80MHz
 
    COMPONENT OSERDES_TEST
	 generic(
      RND_CHIP_NUM       : integer;
      ADDR_WIDTH         : integer;
      DATA_WIDTH         : integer;
      BURST_LEN          : integer;
      BW_WIDTH           : integer;
      CLK_PERIOD         : integer ;
      REFCLK_FREQ        : real;
      IODELAY_GRP        : string;
      NUM_DEVICES        : integer;
      FIXED_LATENCY_MODE : integer;
      PHY_LATENCY        : integer;
      CLK_STABLE         : integer;
      RST_ACT_LOW        : integer;
      PHASE_DETECT       : string;
      DEBUG_PORT         : string;
      SIM_CAL_OPTION     : string;
      SIM_INIT_OPTION    : string;
      IBUF_LPWR_MODE     : string;
      IODELAY_HP_MODE    : string;
      INPUT_CLK_TYPE     : string;
      CLKFBOUT_MULT_F    : real;
      CLKOUT_DIVIDE      : integer;
      DIVCLK_DIVIDE      : integer;
      TCQ                : integer
      );
    PORT(
         sys_clk_p : IN  std_logic;
         sys_clk_n : IN  std_logic;
         sys_rst_in : IN  std_logic;
         qdriip_cq_p      : in  std_logic_vector(NUM_DEVICES-1 downto 0);
			qdriip_cq_n      : in  std_logic_vector(NUM_DEVICES-1 downto 0);
			qdriip_q         : in  std_logic_vector(DATA_WIDTH-1 downto 0);
			qdriip_k_p       : out std_logic_vector(NUM_DEVICES-1 downto 0);
			qdriip_k_n       : out std_logic_vector(NUM_DEVICES-1 downto 0);
			qdriip_d         : out std_logic_vector(DATA_WIDTH-1 downto 0);
			qdriip_sa        : out std_logic_vector(ADDR_WIDTH-1 downto 0);
			qdriip_w_n       : out std_logic;
			qdriip_r_n       : out std_logic;
			qdriip_bw_n      : out std_logic_vector(BW_WIDTH-1 downto 0);
			qdriip_dll_off_n : out std_logic;
         exp_running : IN  std_logic;
         exp_stopping : IN  std_logic;
         rnd_pre_fetch : IN  std_logic;
         send_en : IN  std_logic;
         Rnd_Gen_WNG_Data : IN  std_logic_vector(RND_CHIP_NUM-1 downto 0);
         Rnd_Gen_WNG_Clk : OUT  std_logic_vector(RND_CHIP_NUM-1 downto 0);
         Rnd_Gen_WNG_Oe_n : OUT  std_logic_vector(RND_CHIP_NUM-1 downto 0);
         SERIAL_OUT : OUT  std_logic
        );
    END COMPONENT;
	 
	component cyqdr2_b4
    port(
      TCK   : in    std_logic;
      TMS   : in    std_logic;
      TDI   : in    std_logic;
      TDO   : out   std_logic;
      D     : in    std_logic_vector(MEMORY_WIDTH-1 downto 0);
      Q     : inout std_logic_vector(MEMORY_WIDTH-1 downto 0);
      A     : in    std_logic_vector(ADDR_WIDTH-1 downto 0);
      K     : in    std_logic;
      Kb    : in    std_logic;
      RPSb  : in    std_logic;
      WPSb  : in    std_logic;
      BWS0b : in    std_logic;
      BWS1b : in    std_logic;
      BWS2b : in    std_logic;
      BWS3b : in    std_logic;
      CQ    : inout std_logic;
      CQb   : inout std_logic;
      ZQ    : in    std_logic;
      DOFF  : in    std_logic;
      QVLD  : out   std_logic
      );
  end component;
    
	COMPONENT rdn_gen_stimulate
	PORT(
		Rnd_Gen_WNG_Clk : IN std_logic;
		Rnd_Gen_WNG_Rst : IN std_logic;
		Rnd_Gen_WNG_Oe_n : IN std_logic;          
		Rnd_Gen_WNG_Data : OUT std_logic
		);
	END COMPONENT;

   --Inputs
   signal sys_clk_p : std_logic := '0';
   signal sys_clk_n : std_logic := '0';
   signal sys_clk	  : std_logic := '0';
   signal sys_rst_in : std_logic := '0';
   signal sys_rst_n    : std_logic := '0';
--   signal qdriip_cq_p : std_logic_vector(0 downto 0) := (others => '0');
--   signal qdriip_cq_n : std_logic_vector(0 downto 0) := (others => '0');
--   signal qdriip_q : std_logic_vector(35 downto 0) := (others => '0');
   signal exp_running : std_logic := '0';
   signal exp_stopping : std_logic := '0';
   signal rnd_pre_fetch : std_logic := '0';
   signal send_en : std_logic := '0';
   signal Rnd_Gen_WNG_Data : std_logic_vector(RND_CHIP_NUM-1 downto 0);

 	--Outputs
--   signal qdriip_k_p : std_logic_vector(0 downto 0);
--   signal qdriip_k_n : std_logic_vector(0 downto 0);
--   signal qdriip_d : std_logic_vector(35 downto 0);
--   signal qdriip_sa : std_logic_vector(18 downto 0);
--   signal qdriip_w_n : std_logic;
--   signal qdriip_r_n : std_logic;
--   signal qdriip_bw_n : std_logic_vector(3 downto 0);
--   signal qdriip_dll_off_n : std_logic;
   signal Rnd_Gen_WNG_Rst : std_logic_vector(RND_CHIP_NUM-1 downto 0):= (others => '0');
   signal Rnd_Gen_WNG_Clk : std_logic_vector(RND_CHIP_NUM-1 downto 0);
   signal Rnd_Gen_WNG_Oe_n : std_logic_vector(RND_CHIP_NUM-1 downto 0);
   signal rst_rnd : std_logic_vector(RND_CHIP_NUM-1 downto 0) := x"F";
   signal SERIAL_OUT : std_logic;
	
  signal qdriip_dll_off_n : std_logic;
  signal qdriip_cq_p      : std_logic_vector(NUM_DEVICES-1 downto 0);
  signal qdriip_cq_n      : std_logic_vector(NUM_DEVICES-1 downto 0);
  signal qdriip_q         : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal qdriip_k_p       : std_logic_vector(NUM_DEVICES-1 downto 0);
  signal qdriip_k_n       : std_logic_vector(NUM_DEVICES-1 downto 0);
  signal qdriip_d         : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal qdriip_sa        : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal qdriip_w_n       : std_logic;
  signal qdriip_r_n       : std_logic;
  signal qdriip_bw_n      : std_logic_vector(BW_WIDTH-1 downto 0);
	
  signal qdriip_dll_off_n_delay : std_logic;
  signal qdriip_cq_p_delay      : std_logic_vector(NUM_DEVICES-1 downto 0);
  signal qdriip_cq_n_delay      : std_logic_vector(NUM_DEVICES-1 downto 0);
  signal qdriip_q_delay         : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal qdriip_k_p_delay       : std_logic_vector(NUM_DEVICES-1 downto 0);
  signal qdriip_k_n_delay       : std_logic_vector(NUM_DEVICES-1 downto 0);
  signal qdriip_d_delay         : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal qdriip_sa_delay        : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal qdriip_w_n_delay       : std_logic;
  signal qdriip_r_n_delay       : std_logic;
  signal qdriip_bw_n_delay      : std_logic_vector(BW_WIDTH-1 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut_OSERDES_TEST: OSERDES_TEST 
	generic map (
      ADDR_WIDTH         => ADDR_WIDTH,
      DATA_WIDTH         => DATA_WIDTH,
      BURST_LEN          => BURST_LEN,
      BW_WIDTH           => BW_WIDTH,
      CLK_PERIOD         => CLK_PERIOD,
      REFCLK_FREQ        => REFCLK_FREQ,
      IODELAY_GRP        => IODELAY_GRP,
      NUM_DEVICES        => NUM_DEVICES,
      FIXED_LATENCY_MODE => FIXED_LATENCY_MODE,
      PHY_LATENCY        => PHY_LATENCY,
      CLK_STABLE         => CLK_STABLE,
      RST_ACT_LOW        => RST_ACT_LOW,
      PHASE_DETECT       => PHASE_DETECT,
      DEBUG_PORT         => DEBUG_PORT,
      SIM_CAL_OPTION     => SIM_CAL_OPTION,
      SIM_INIT_OPTION    => SIM_INIT_OPTION,
      IBUF_LPWR_MODE     => IBUF_LPWR_MODE,
      IODELAY_HP_MODE    => IODELAY_HP_MODE,
      INPUT_CLK_TYPE     => INPUT_CLK_TYPE,
      CLKFBOUT_MULT_F    => CLKFBOUT_MULT_F,
      CLKOUT_DIVIDE      => CLKOUT_DIVIDE,
      DIVCLK_DIVIDE      => DIVCLK_DIVIDE,
      TCQ                => TCQ,
      RND_CHIP_NUM       => RND_CHIP_NUM
      )
	PORT MAP (
          sys_clk_p => sys_clk_p,
          sys_clk_n => sys_clk_n,
          sys_rst_in => sys_rst_in,
          qdriip_cq_p => qdriip_cq_p,
          qdriip_cq_n => qdriip_cq_n,
          qdriip_q => qdriip_q,
          qdriip_k_p => qdriip_k_p,
          qdriip_k_n => qdriip_k_n,
          qdriip_d => qdriip_d,
          qdriip_sa => qdriip_sa,
          qdriip_w_n => qdriip_w_n,
          qdriip_r_n => qdriip_r_n,
          qdriip_bw_n => qdriip_bw_n,
          qdriip_dll_off_n => qdriip_dll_off_n,
          exp_running => exp_running,
          exp_stopping => exp_stopping,
          rnd_pre_fetch => rnd_pre_fetch,
          send_en => send_en,
          Rnd_Gen_WNG_Data => Rnd_Gen_WNG_Data,
          Rnd_Gen_WNG_Clk => Rnd_Gen_WNG_Clk,
          Rnd_Gen_WNG_Oe_n => Rnd_Gen_WNG_Oe_n,
          SERIAL_OUT => SERIAL_OUT
        );

		--============================================================================
  --                             Memory Model
  --============================================================================
  --Instantiate the QDRII+ Memory Modules - Cypress Verilog model
  -- Memory model instance name must be modified as per the model downloaded 
  -- from the memory vendor website
  COMP_INST : for i in 0 to NUM_DEVICES-1 generate
    QDR2PLUS_BL4_INST : if(BURST_LEN = 4) generate
      -- Cypress QDRII+ SRAM Burst Length 4 memory model instantiation for
      -- X36 controller design
      COMP_36 : if(MEMORY_WIDTH = 36) generate
        QDR2PLUS_MEM : cyqdr2_b4
          port map(
            TCK   => '0',
            TMS   => '1',
            TDI   => '1',
            TDO   => open,
            D     => qdriip_d_delay((MEMORY_WIDTH*(i+1))-1 downto (MEMORY_WIDTH*i)),
            Q     => qdriip_q ((MEMORY_WIDTH*(i+1))-1 downto (MEMORY_WIDTH*i)),
            A     => qdriip_sa_delay,
            K     => qdriip_k_p_delay(i),
            Kb    => qdriip_k_n_delay(i),
            RPSb  => qdriip_r_n_delay,
            WPSb  => qdriip_w_n_delay,
            BWS0b => qdriip_bw_n_delay((i*BW_COMP)),
            BWS1b => qdriip_bw_n_delay((i*BW_COMP)+1),
            BWS2b => qdriip_bw_n_delay((i*BW_COMP)+2),
            BWS3b => qdriip_bw_n_delay((i*BW_COMP)+3),
            CQ    => qdriip_cq_p(i),
            CQb   => qdriip_cq_n(i),
            ZQ    => '1',
            DOFF  => qdriip_dll_off_n_delay,
            QVLD  => open
           );
      end generate COMP_36;
    end generate QDR2PLUS_BL4_INST;
  end generate COMP_INST;
  
  rdn_gen : for i in 0 to RND_CHIP_NUM-1 generate
   Inst_rdn_gen_stimulate: rdn_gen_stimulate PORT MAP(
		Rnd_Gen_WNG_Rst => rst_rnd(i),
		Rnd_Gen_WNG_Clk => Rnd_Gen_WNG_Clk(i),
		Rnd_Gen_WNG_Oe_n => Rnd_Gen_WNG_Oe_n(i),
		Rnd_Gen_WNG_Data => Rnd_Gen_WNG_Data(i)
	);
  end generate rdn_gen;

		-- Generate Reset. The active low reset is generated.
  sys_rst_n <= '1' after RESET_PERIOD;
  
  rst_rnd(0)<= '0' after 3 us;
  rst_rnd(1)<= '0' after 4 us;
  rst_rnd(2)<= '0' after 5 us;
  rst_rnd(3)<= '0' after 2 us;
  -- Polarity of the reset for the memory controller instantiated can be changed
  -- by changing the parameter RST_ACT_LOW value.
  sys_rst_in <= (sys_rst_n) when (RST_ACT_LOW = 0) else (not sys_rst_n);

  -- Generate design clock
  sys_clk <= not sys_clk after OSC_PERIOD/2.0;

  sys_clk_p <= sys_clk;
  sys_clk_n <= not sys_clk;

  -- Generate 200MHz reference clock
 -- clk_ref <= not clk_ref after REFCLK_PERIOD/2;

--  clk_ref_p <= clk_ref;
--  clk_ref_n <= not clk_ref;
  
  --===========================================================================
  --                            BOARD Parameters
  --===========================================================================
  --These parameter values can be changed to model varying board delays
  --between the Virtex-6 device and the QDR II memory model

  qdriip_k_p_delay       <= transport qdriip_k_p after TPROP_PCB_CTRL;
  qdriip_k_n_delay       <= transport qdriip_k_n after TPROP_PCB_CTRL;
  qdriip_sa_delay        <= transport qdriip_sa after TPROP_PCB_CTRL;
  qdriip_bw_n_delay      <= transport qdriip_bw_n after TPROP_PCB_CTRL;
  qdriip_w_n_delay       <= transport qdriip_w_n after TPROP_PCB_CTRL;
  qdriip_d_delay         <= transport qdriip_d after TPROP_PCB_DATA;
  qdriip_r_n_delay       <= transport qdriip_r_n after TPROP_PCB_CTRL;
  qdriip_q_delay         <= transport qdriip_q after TPROP_PCB_DATA_RD;
  qdriip_cq_p_delay      <= transport qdriip_cq_p after TPROP_PCB_CQ;
  qdriip_cq_n_delay      <= transport qdriip_cq_n after TPROP_PCB_CQ;
  qdriip_dll_off_n_delay <= transport qdriip_dll_off_n after TPROP_PCB_CTRL;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for 80 us;
			exp_running	<= '1';
		wait for 1 us;	
			send_en		<= '1';
      -- insert stimulus here 

      wait;
   end process;

END;
