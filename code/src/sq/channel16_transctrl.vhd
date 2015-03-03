----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:21:35 12/26/2012 
-- Design Name: 
-- Module Name:    channel16_transctrl - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity channel16_transctrl is
port(
	Token_in		:	in	std_logic;
	Token_out	:	out	std_logic;
	clk			:	in	std_logic;
	nReset		:	in	std_logic;
	Hit_in		:	in	std_logic;
	Enable		:	in	std_logic;
	Triger		:	out	std_logic
	);
end channel16_transctrl;

architecture Behavioral of channel16_transctrl is

type	State_FSM is(Idle_State,WaitData_State,TokenOut_State,WaitTokenIn_State);
signal Pr_State,Nx_State	:	State_FSM;

--signal Hit_in_r1 : std_logic;
signal Hit_in_r2 : std_logic;
signal pulse1 : std_logic;
signal pulse2 : std_logic;
signal Triger_sig : std_logic;
signal Wait_Num : std_logic_vector(10 downto 0);

begin

Triger <= Triger_sig;
Hit_in_r2	<= Hit_in;
--process(clk) begin
--	Hit_in_r1	<= Hit_in;
--	Hit_in_r2	<= Hit_in_r1;
--end process;

  FDCE_inst1 : FDCE
   generic map (
      INIT => '0') -- Initial value of register ('0' or '1')  
   port map (
      Q => pulse1,      -- Data output
      C => Hit_in_r2,      -- Clock input
      CE => '1',    -- Clock enable input
      CLR => pulse2,  -- Asynchronous clear input
      D => '1'       -- Data input
   );

 FDCE_inst2 : FDCE
   generic map (
      INIT => '0') -- Initial value of register ('0' or '1')  
   port map (
      Q => pulse2,      -- Data output
      C => clk,      -- Clock input
      CE => '1',    -- Clock enable input
      CLR => '0',  -- Asynchronous clear input
      D => pulse1       -- Data input
   );
	
 FDCE_inst3 : FDCE
   generic map (
      INIT => '0') -- Initial value of register ('0' or '1')  
   port map (
      Q => Triger_sig,      -- Data output
      C => clk,      -- Clock input
      CE => '1',    -- Clock enable input
      CLR => '0',  -- Asynchronous clear input
      D => pulse2       -- Data input
   );
	
State_Reg: process(Clk, nReset) begin
	if nReset = '0' then
		Pr_State	<= Idle_State;
	elsif( Clk'event and Clk = '1' )then
		Pr_State	<= Nx_State;
	end if;
end process;

State_Transfer: process( Enable,Triger_sig,Wait_Num,Token_in,Pr_State,Hit_in)begin
	case Pr_State is
		when Idle_State =>
			if (Enable = '1' and Hit_in = '1') then --Triger_sig
				--Nx_State <= WaitData_State;
				Nx_State <= TokenOut_State;
			else
				Nx_State <= Idle_State;
			end if;
		when WaitData_State =>
			if (Wait_Num > "000000010") then
				Nx_State <= TokenOut_State;
			else
				Nx_State <= WaitData_State;
			end if;				
		when TokenOut_State=>
			Nx_State <= WaitTokenIn_State;
		when WaitTokenIn_State=>
			if Token_in = '1' then
				--Nx_State <= Idle_State;
				if (Enable = '1' and Hit_in = '1') then --Triger_sig
					--Nx_State <= WaitData_State;
					Nx_State <= TokenOut_State;
				else
					Nx_State <= Idle_State;
				end if;
			else
				Nx_State <= WaitTokenIn_State;
			end if;
	   when others =>
			Nx_State <= Idle_State;
	end case;
end process;

Wait_Num_pro: process(Clk,nReset) begin
	if nReset = '0' then     
   	Wait_Num	<= (others => '0');
  elsif(Clk'event and Clk = '1') then
		if(Pr_State = WaitData_State)then
			Wait_Num	<= Wait_Num + 1;
		else
			Wait_Num	<= (others => '0');
		end if;
  end if;
end process;

TokenOut_pro: process(Clk,nReset) begin
	if nReset = '0' then     
   	Token_out	<= '0';
  elsif(Clk'event and Clk = '1') then
		if(Pr_State = TokenOut_State)then
			Token_out	<= '1';
		else
			Token_out	<=	'0';
		end if;
  end if;
end process;

end Behavioral;

