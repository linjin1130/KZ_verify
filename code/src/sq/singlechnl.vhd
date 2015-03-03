----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:10:06 08/11/2011 
-- Design Name: 
-- Module Name:    singlechnl - Behavioral 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity singlechnl is
   port (
	     Clk : in std_logic;
		  InvClk : in std_logic;
		  FifoClk : in std_logic;
--		  RdFifoClk: in std_logic;
	     HitIn : in std_logic;
		  SysClear  : in std_logic;----SysClear
		  SysEnable : in std_logic;-----SysEnable
		  ChnlEnable : in std_logic;-----chnl Enable
		  fifo_rst	:	in std_logic;
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
end singlechnl;

architecture Behavioral of singlechnl is

component carrychain_whole is
port(
     Hit_in: in std_logic;
	  Cout: out std_logic;
	  AClear: in std_logic;
	  Enable: in std_logic;
	  ChnlEnable: in std_logic;
	  CLK: in std_logic;
     InvClk : in std_logic;	  
	  ChnlFifoWrite: out std_logic;
	  ChnlFifoDataOut: out std_logic_vector(36 downto 0)
	  );
end component;

component chnlfifo
	port (
	rst: IN std_logic;
	wr_clk: IN std_logic;
	rd_clk: IN std_logic;
	din: IN std_logic_VECTOR(63 downto 0);
	wr_en: IN std_logic;
	rd_en: IN std_logic;
	dout: OUT std_logic_VECTOR(63 downto 0);
	full: OUT std_logic;
	almost_full: OUT std_logic;
	empty: OUT std_logic;
	prog_full: OUT std_logic);
end component;

component tokenring_transfer
   port (
	Token_in : in std_logic;
   Token_out : out std_logic;
	clk : in std_logic;
	nReset : in std_logic;
	empty_out : in std_logic;
	rd_en : out std_logic;
	wr_en_out : out std_logic);
end component;

attribute syn_black_box : boolean;
attribute syn_black_box of chnlfifo: component is true;
signal ChnlFifoWrite : std_logic;
signal ChainDataOut : std_logic_vector(36 downto 0);
signal ChnlFifoDataCnts : std_logic_vector(7 downto 0):=(others=>'0');
signal ChnlFifoDataIn : std_logic_vector(63 downto 0);
signal AClear,Enable,ChnlFifoRdEn_tmp,ChnlFifoEmpty_tmp : std_logic;
signal InvSysClear : std_logic;

begin

Enable <= SysEnable;
AClear <= fifo_rst;
InvSysClear <= not fifo_rst;
ChnlFifoRdEn <= ChnlFifoRdEn_tmp;
ChnlFifoEmpty <= ChnlFifoEmpty_tmp;
carrychain_whole_inst: carrychain_whole
     port map(
               Hit_in => HitIn,
	            Cout => Cout,
	            AClear => AClear,
	            Enable => Enable,
	            ChnlEnable => ChnlEnable,
	            CLK => Clk,
               InvClk => InvClk,
	            ChnlFifoWrite => ChnlFifoWrite,
	            ChnlFifoDataOut => ChainDataOut
	          );

--chnlfifo_inst : chnlfifo
--		port map (
--			rst => SysClear,
--			wr_clk => InvClk,--------------------------------------------------------------1
--			rd_clk => FifoClk,
--			din => ChnlFifoDataIn,
--			wr_en => ChnlFifoWrite,
--			rd_en => ChnlFifoRdEn,
--			dout => TDCDataOut,
--			full => ChnlFifoFull,
--			almost_full => ChnlFifoAlmostFull,
--			empty => ChnlFifoEmpty,
--			prog_full => ChnlFifoProgFull
--			);

chnlfifo_inst : chnlfifo
		port map (
			rst => fifo_rst,--SysClear
			wr_clk => InvClk,
			rd_clk => FifoClk,
			din => ChnlFifoDataIn,
			wr_en => ChnlFifoWrite,
			rd_en => ChnlFifoRdEn_tmp,
			dout => TDCDataOut,
			full => ChnlFifoFull,
			almost_full => ChnlFifoAlmostFull,
			empty => ChnlFifoEmpty_tmp,
			prog_full => ChnlFifoProgFull);
-----------------------------------------------------------
        ChnlFifoDataIn(63 downto 56) <= x"FF";
        ChnlFifoDataIn(55 downto 48) <=ChnlFifoDataCnts;
		  ChnlFifoDataIn(47 downto 45)  <= "000";
		  ChnlFifoDataIn(44 downto 8)  <= ChainDataOut;
		  ChnlFifoDataIn(7 downto 0) <= ChnlFlags;
-----------------------------------------------------------

tokenring_transfer_inst : tokenring_transfer
        port map (
		     Token_in => Token_in,
           Token_out => Token_out,
	        clk => FifoClk,
	        nReset => (InvSysClear),
	        empty_out => ChnlFifoEmpty_tmp,
	        rd_en => ChnlFifoRdEn_tmp,
			  wr_en_out => RdFifoWren);
			  
ChnlFifoDataCounts_process: process(Clk,fifo_rst)
   begin
	  if(fifo_rst ='1')then
		    ChnlFifoDataCnts <=(others =>'0');
	  elsif(Clk'event and Clk='1')then	     
	        if(ChnlFifoWrite ='1')then
		           ChnlFifoDataCnts <= ChnlFifoDataCnts + '1';
		     end if;
	  end if;
end process;


end Behavioral;

