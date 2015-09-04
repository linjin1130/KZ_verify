----------------------------------------------------------------------------------
-- Company:  USTC
-- Engineer: HuangHuaZhu
-- 
-- Create Date     :    09:28:12 09/21/2011 
-- Design Name     :    DAC_LOGIC
-- Module Name     :    DAC_INTERFACE - RTL 
-- Version         :    1.0
-- Project Name    :    DAC_INTERFACE
-- Test Bench Name :
-- Target Devices  : 
-- Tool versions   :    ISE10.1
-- Description     :    Interface with dac(TLV5618A)
-- Structure       :  
-- History         :  
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity NB6L295_CTRL is
	Port ( 
		CLK        : in   STD_LOGIC;--80M
		Dac_Ena    : in   STD_LOGIC;--DAC set enable
		Dac_Data   : in   STD_LOGIC_VECTOR (15 downto 0);--DAC value
		Sys_Rst_n    : in   STD_LOGIC;--System reset,high active
		Dac_Finish : out  STD_LOGIC;	--it has output 16 bit data
		Dac_en	   : out  STD_LOGIC; --DAC chip enable
		Dac_Sclk   : out  STD_LOGIC; --DAC chip clock
		Dac_Csn    : out  STD_LOGIC; --DAC chip select
		Dac_Din    : out  STD_LOGIC); --DAC data input
end NB6L295_CTRL;

architecture RTL of NB6L295_CTRL is
	constant DA_SCLK_FREQ	: integer := 8;----DAC frequancy = clk frequancy / DA_SCLK_FREQ
	signal DA_SCLK_Cnt      :  integer range DA_SCLK_FREQ downto 0 := 0;--clock count
	signal DA_SCLK_SIG:   STD_LOGIC ;    --DAC CLOCK
	signal DA_SCLK_en:   STD_LOGIC ;    --DAC CLOCK enable
	signal Dac_Data_reg :  STD_LOGIC_VECTOR (15 downto 0) := (others => '0'); --DAC value
	
	signal Dac_Ena_reg      :  STD_LOGIC;--one clock delay of 'Dac_Ena'
	signal Dac_Ena_reg2     :  STD_LOGIC;--two clock delay of 'Dac_Ena'
	signal Dac_Ena_Rising        :  STD_LOGIC;--rising edge
--	signal Dac_Ena_falling       :  STD_LOGIC;--rising edge
	signal DA_SCLK_Rising:    STD_LOGIC ;  --DAC DATA IN
	signal DA_Start_Cnt	:  STD_LOGIC_VECTOR (4 downto 0) := (others => '0');  --DAC CHIP SELECT
	signal Dac_Finish_SIG   :  STD_LOGIC;--dac setting finished
	--state machine
--	type CNT_STATE is( IDLE, START, ENDS) ;
--	signal CURR_STATE : CNT_STATE ;
--	signal NEXT_STATE : CNT_STATE ;
	
begin
--generate the dac sclk
	process(CLK, Sys_Rst_n)	
	begin
		if Sys_Rst_n='0' then
			DA_SCLK_Cnt <= 0 ;
		elsif rising_edge ( CLK ) then
			if(DA_SCLK_Cnt < DA_SCLK_FREQ) then
				DA_SCLK_Cnt	<= DA_SCLK_Cnt + 1;
			else
				DA_SCLK_Cnt <= 0 ;
			end if;
		end if;
	end process ;
---generate da_sclk, one clock width
	process(CLK, Sys_Rst_n)	
	begin
		if Sys_Rst_n='0' then
			DA_SCLK_SIG <= '0' ;
			Dac_Sclk		<= '0' ;
		elsif rising_edge ( CLK ) then
			if(DA_SCLK_Cnt < (DA_SCLK_FREQ/2)) then
				DA_SCLK_SIG	<= '0';
			else
				DA_SCLK_SIG <= '1';
			end if;
			
			Dac_Sclk <=  DA_SCLK_SIG and DA_SCLK_en;
		end if;
	end process ;
	
--generate 'DA_SCLK_Rising'	
	process(CLK, Sys_Rst_n)	
	begin
		if Sys_Rst_n='0' then
			DA_SCLK_Rising <= '0' ;
		elsif rising_edge ( CLK ) then
--			if(DA_SCLK_Cnt = ((DA_SCLK_FREQ/2) - 1)) then
--				DA_SCLK_Rising	<= '1';
--			else
--				DA_SCLK_Rising	<= '0';
--			end if;
			if(DA_SCLK_Cnt = 0) then
				DA_SCLK_Rising	<= '1';
			else
				DA_SCLK_Rising	<= '0';
			end if;
		end if;
	end process ;
  --generate the posedge of Dac_Ena
	process(CLK, Sys_Rst_n)
	begin
		if Sys_Rst_n='0' then
			Dac_Ena_reg <= '0' ;
			Dac_Ena_reg2<= '0' ;
		elsif rising_edge ( CLK ) then
			Dac_Ena_reg <= Dac_Ena ;
			Dac_Ena_reg2<= Dac_Ena_reg ;
		end if;
	end process;
  
---*******************************************
--generate 'Dac_Ena_Rising' on the rising of 'Dac_Ena'
-------------------------------------------
	process(CLK, Sys_Rst_n)
	begin
		if Sys_Rst_n='0' then
			Dac_Ena_Rising <= '0' ;
		elsif rising_edge ( CLK ) then
			if((Dac_Ena_reg ='1') and (Dac_Ena_reg2 ='0') ) then
				Dac_Ena_Rising <= '1' ;
			else 
				if(DA_SCLK_Rising = '1') then
					Dac_Ena_Rising <= '0' ;
				else
					Dac_Ena_Rising <= Dac_Ena_Rising ;
				end if;
			end if;
		end if ;
	end process ;
--	 DA_Start 		<= DA_SCLK_Rising and Dac_Ena_Rising;
---******************************************************
---***************************************************
---Latch generate DAC set count
---from count 2 to count 17, we output dac data
----------------------------------------------
--sync process
	process(CLK, Sys_Rst_n)
	begin
		if Sys_Rst_n='0' then
			DA_Start_Cnt <= "00000" ;
		elsif rising_edge ( CLK ) then
			if ((DA_SCLK_Rising = '1') and (Dac_Ena_Rising = '1')) then
				DA_Start_Cnt <=  "00001";
			else
				if((DA_Start_Cnt > 0) and (DA_SCLK_Rising = '1')) then
					DA_Start_Cnt	<= DA_Start_Cnt + 1;
				else
					if(DA_Start_Cnt > 20) then
						DA_Start_Cnt <= "00000" ;
					else
						DA_Start_Cnt	<= DA_Start_Cnt;
					end if;
				end if;
			end if;
		end if;
	end process ;
			
---***************************************		
	--generate the Dac_Finish_SIG
------------------------------------------
	process(DA_Start_Cnt)
	begin
		if  ((DA_Start_Cnt <= 12) and (DA_Start_Cnt >= 2) ) then
			DA_SCLK_en 	<= '1' ;
		else
			DA_SCLK_en	<= '0' ;
		end if;
	end process ;
	
	process(CLK, Sys_Rst_n)
	begin
		if Sys_Rst_n='0' then
			Dac_Din 		<= '0' ;
		elsif rising_edge ( CLK ) then
			if  ((DA_Start_Cnt <= 12) and (DA_Start_Cnt >= 2) ) then
				Dac_Din 		<= Dac_Data_reg(0) ;
			else
				Dac_Din 		<= '0' ;
			end if;
		end if ;			
	end process ;
	
	process(CLK, Sys_Rst_n)
	begin
		if Sys_Rst_n='0' then
			Dac_Csn 	<= '0' ;
			Dac_en 	<= '0' ;
		elsif rising_edge ( CLK ) then
			if  ((DA_Start_Cnt = 13) ) then
				Dac_Csn <= '1' ;
			else
				Dac_Csn <= '0' ;
			end if;
			
			if  ((DA_Start_Cnt <= 14) and (DA_Start_Cnt >= 1) ) then
				Dac_en 	<= '1' ;
			else
				Dac_en 		<= '0' ;
			end if;
		end if ;			
	end process ;
--data shift
	process(CLK, Sys_Rst_n)
	begin
		if Sys_Rst_n='0' then
			Dac_Data_reg 	<= (others => '0') ;
		elsif rising_edge ( CLK ) then
			if((Dac_Ena_reg ='1') and (Dac_Ena_reg2 ='0')) then
				Dac_Data_reg <= Dac_Data ; ----latch input dac data
			else
				if((DA_Start_Cnt <= 17) and (DA_Start_Cnt >= 2)  and (DA_SCLK_Rising = '1')) then
					Dac_Data_reg <= '0'  & Dac_Data_reg(15 downto 1);
				else
					Dac_Data_reg <= Dac_Data_reg;
				end if;
			end if;
		end if ;			
	end process ;
--generate dac finished	
	process(CLK, Sys_Rst_n)
	begin
		if Sys_Rst_n='0' then
			Dac_Finish_SIG <= '0' ;
		elsif rising_edge ( CLK ) then
			if((DA_Start_Cnt = 0) or (DA_Start_Cnt > 20)) then
				Dac_Finish_SIG <= '1';
			else
				Dac_Finish_SIG	<=	'0';
			end if;
		end if ;			
	end process ;
----*****************************************************
	Dac_Finish <= Dac_Finish_SIG ;
	
end RTL;

