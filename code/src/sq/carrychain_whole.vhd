----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity carrychain_whole is
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
end carrychain_whole;

architecture Behavioral of carrychain_whole is

component carrychain_plain is
port(
     Cin: in std_logic;
	  Aclear: in std_logic;
	  Enable: in std_logic;
	  CLK: in std_logic;
	  Cout: out std_logic;
	  stepdata_p: out std_logic_vector(299 downto 0)
	  );
end component;

component encoder_240 is
port(
      stepdata: in std_logic_vector(299 downto 0);
		Finedata: out std_logic_vector(8 downto 0)
	  );
end component;

component counter24 is
	port (
	clk: IN std_logic;
	ce: IN std_logic;
	sclr: IN std_logic;
	q: OUT std_logic_VECTOR(27 downto 0));
end component;

-- Synplicity black box declaration
attribute syn_black_box : boolean;
attribute syn_black_box of counter24: component is true;
signal stepdata_tmp: std_logic_vector(299 downto 0);
signal fifo_write_tmp, fifo_write: std_logic;
signal fifo_write_tmp2, fifo_write_tmp3: std_logic;
signal Enable_tmp: std_logic;
--signal coarsedata_tmp_n, coarsedata_tmp_p: std_logic_vector(23 downto 0);
signal coarsedata_tmp_n, coarsedata_tmp_p: std_logic_vector(27 downto 0);
--signal coarsedata_n, coarsedata_p: std_logic_vector(23 downto 0);
signal coarsedata_n, coarsedata_p: std_logic_vector(27 downto 0);
signal Finedata_tmp: std_logic_vector(8 downto 0);
signal dffclear: std_logic;
signal dffenable: std_logic;
signal FineData_n: std_logic_vector(8 downto 0); 
--signal CoarseData_Final: std_logic_vector(23 downto 0);
signal CoarseData_Final: std_logic_vector(27 downto 0);
signal coarsedata_tmp: std_logic_vector(27 downto 0);
signal coarsedata: std_logic_vector(27 downto 0);

signal InvHit_in: std_logic;
signal Hit_d1: std_logic;
signal Hit_En: std_logic;
signal Hit_En_d1: std_logic;
signal Hit_En_d2: std_logic;
signal ChnlEnable_tmp: std_logic;


begin

--InvHit_in <= not Hit_in;
---------------control signal-----------------------------------
--FDCPE_inst_1 : FDCPE
--   generic map (
--      INIT => '0') -- Initial value of register ('0' or '1')  
--   port map (
--      Q => fifo_write_tmp,      -- Data output
--      C => InvHit_in,      -- Clock input
--      CE => '1',    -- Clock enable input
--      CLR => fifo_write,  -- Asynchronous clear input
--      D => '1',      -- Data input
--      PRE => '0'   -- Asynchronous set input
--   );
--
--FDCPE_inst_2 : FDCPE
--   generic map (
--      INIT => '0') -- Initial value of register ('0' or '1')  
--   port map (
--      Q => fifo_write,      -- Data output
--      C => CLK,      -- Clock input
--      CE => '1',    -- Clock enable input
--      CLR => '0',  -- Asynchronous clear input
--      D => fifo_write_tmp,      -- Data input
--      PRE => '0'   -- Asynchronous set input
--   );	
--	
--process(CLK)
--begin
--  if(CLK'event and CLK='1')then
--     fifo_write_tmp1 <= fifo_write;
--     dffclr <= fifo_write_tmp1;
--	  dffclr_tmp <= dffclr;
--	  dffclr_tmp1 <= dffclr_tmp;
--	  dffclr_tmp2 <= dffclr_tmp1;
--  end if;
--end process;
--	
----dffclear <=dffclr_tmp2;       ------------------fine dff clear'0';--
----dffclear <=dffclr;      
--dffclear <=fifo_write_tmp1;      
--	
--process(CLK)
--begin
--   if(CLK'event and CLK='1') then
--	       Enable_tmp <= Enable;      --------coarse counter enable--------------------------------2
--   end if;
--end process;	
--
--dffenable<= '1' when stepdata_tmp(0)='0' else
--            '0';          --------------------fine dff enable
--				
--
--
--
--
------------fine data & encoder-----------------
--
--carrychain_plain_inst: carrychain_plain
--     port map(
--	            Cin =>Hit_in,
--	            Aclear => dffclear,
--	            Enable => dffenable,
--	            CLK => CLK,
--	            Cout =>Cout,
--	            stepdata_p =>stepdata_tmp
--					);
--
--encoder_240_inst: encoder_240
--     port map(
--	           stepdata => stepdata_tmp,
--		        Finedata => Finedata_tmp
--				  );
--				  
--FineData_n <= Finedata_tmp;
--
-------------------coarse data----------------
counter24_inst_p : counter24
		port map (
			clk => CLK,
			ce => Enable_tmp,
			sclr => AClear,
			q => coarsedata_tmp_p);
			
counter24_inst_n : counter24
		port map (
			clk => InvClk,
			ce => Enable_tmp,
			sclr => AClear,
			q => coarsedata_tmp_n);	

CoarseData_Latch_process_p: process(Hit_in)
   begin
	  if(Hit_in'event and Hit_in='1')then
	      coarsedata_p <= coarsedata_tmp_p;
			coarsedata_n <= coarsedata_tmp_n;
	 end if;
end process;

CoarseData_Final <= coarsedata_n when FineData_n >"011001000" else--200
                    coarsedata_p when FineData_n >"000111100" else--60
                    coarsedata_n - '1';--------------------------------change number?
							 
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
-----------------hit rise latch fifo write-------------------------------
process(CLK)
begin
  if(CLK'event and CLK='1')then
--     fifo_write_tmp1 <= fifo_write;
--     dffclr <= fifo_write_tmp1;
--	  dffclr_tmp <= dffclr;
--	  dffclr_tmp1 <= dffclr_tmp;
--	  dffclr_tmp2 <= dffclr_tmp1;
  end if;
end process;
	
--dffclear <=dffclr_tmp2;       ------------------fine dff clear'0';--
dffclear <= '0';       ------------------fine dff clear'0';--
	
process(CLK)
begin
   if(CLK'event and CLK='1') then
	       Enable_tmp <= Enable;      --------coarse counter enable--------------------------------2
	       ChnlEnable_tmp <= ChnlEnable;      --------enable fifowrite--------------------------------2
   end if;
end process;	

--dffenable<= '1' when stepdata_tmp(0)='0' else
--            '0';          --------------------fine dff enable

dffenable<= not (Hit_En or Hit_En_d1 or Hit_En_d2);

--process(CLK) begin
--	  if(CLK'event and CLK='0')then
--		dffenable<= not (Hit_En or Hit_En_d1 or Hit_En_d2);
--	 end if;
--end process;
----------fine data & encoder-----------------

carrychain_plain_inst: carrychain_plain
     port map(
	            Cin =>Hit_in,
	            Aclear => dffclear,
	            Enable => dffenable,
	            CLK => CLK,
	            Cout =>Cout,
	            stepdata_p =>stepdata_tmp
					);

encoder_240_inst: encoder_240
     port map(
	           stepdata => stepdata_tmp,
		        Finedata => Finedata_tmp
				  );
				  
FineData_n <= Finedata_tmp;
--------------------- 1 counter: coarse data----------------
Hit_Stepdata_delay: process(CLK)
   begin
	  if(CLK'event and CLK='1')then
	      Hit_d1 <= stepdata_tmp(0);
--			fifo_write <= Hit_En;
			fifo_write <= Hit_En_d1;
			Hit_En_d1 <= Hit_En;
			Hit_En_d2 <= Hit_En_d1;
--	      fifo_write_pre1 <= Hit_En;
--			fifo_write <= fifo_write_pre1;
	 end if;
end process;

Hit_En <= stepdata_tmp(0) and not Hit_d1;


--counter24_inst_p : counter24
--		port map (
--			clk => CLK,
--			ce => Enable_tmp,
--			sclr => AClear,
--			q => coarsedata_tmp);
--
--CoarseData_Latch_process_p: process(CLK)
--   begin
--	  if(CLK'event and CLK='1')then
--	      if(Hit_En = '1') then
--				coarsedata <= coarsedata_tmp;
--			end if;
--	 end if;
--end process;
--
--CoarseData_Final <= coarsedata;

------------------compose fine and coarse---------

 process(CLK)
 begin
 if(CLK'event and CLK='1')then
   if(fifo_write='1')then
--      ChnlFifoDataOut(8  downto 0) <= FineData_n;
--		ChnlFifoDataOut(36 downto 9) <= CoarseData_Final;
		ChnlFifoDataOut(7  downto 0) <= FineData_n(7 downto 0);
		ChnlFifoDataOut(35 downto 8) <= CoarseData_Final; 
		ChnlFifoDataOut(36) <= FineData_n(8); 
   end if;
 end if;
 end process;
 
 process(CLK)
 begin
 if(CLK'event and CLK='1')then
   if(Enable_tmp='1' and ChnlEnable_tmp='1')then
		Chnlfifowrite <= fifo_write;
	else
		Chnlfifowrite <= '0';
   end if;
 end if;
 end process;

--Chnlfifowrite <= fifo_write_tmp1;-----------------------------------dffclr_tmp1;--
		
end Behavioral;





