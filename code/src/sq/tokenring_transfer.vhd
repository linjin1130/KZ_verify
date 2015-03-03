----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:57:04 12/26/2012 
-- Design Name: 
-- Module Name:    tokenring_transfer - Behavioral 
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
--library UNISIM;
--use UNISIM.VComponents.all;

entity tokenring_transfer is
port(
	Token_in		:	in	std_logic;
	Token_out	:	out	std_logic;
	clk			:	in	std_logic;
	nReset		:	in	std_logic;
	empty_out	:	in	std_logic;
	rd_en			:	out	std_logic;
	wr_en_out	:	out	std_logic
	);
	
end tokenring_transfer;

architecture Behavioral of tokenring_transfer is

type	State_FSM is(Idle_State,GotToken_State,Rd_State,Wr_State,TokenOut_State);
signal Pr_State,Nx_State	:	State_FSM;

begin

State_Reg: process(Clk, nReset) begin
	if nReset = '0' then
		Pr_State	<= Idle_State;
	elsif( Clk'event and Clk = '1' )then
		Pr_State	<= Nx_State;
	end if;
end process;

State_Transfer: process( Token_in,empty_out,Pr_State )begin
	case Pr_State is
		when Idle_State =>
			if Token_in = '1' then
--				Nx_State <= GotToken_State;
				if empty_out = '0' then
					Nx_State <= Rd_State;
				else
					Nx_State <= TokenOut_State;
				end if;
			else
				Nx_State <= Idle_State;
			end if;
--		when GotToken_State =>
--			if empty_out = '0' then
--				Nx_State <= Rd_State;
--			else
--				Nx_State <= TokenOut_State;
--			end if;				
		when Rd_State=>
			Nx_State <= Wr_State;
		when Wr_State=>
--			Nx_State <= TokenOut_State;
			Nx_State <= Idle_State;
		when TokenOut_State=>
			Nx_State <= Idle_State;
	   when others =>
			Nx_State <= Idle_State;
	end case;
end process;

State_Out: process(Clk,nReset) begin
	if nReset = '0' then     
   	Token_out  <= '0';
		rd_en   <= '0';	
   	wr_en_out  <= '0';
  elsif(Clk'event and Clk = '1') then
    if(Pr_State = Rd_State)then
    	Token_out  <= '0';
		rd_en   <= '1';	
   	wr_en_out  <= '0';
	elsif(Pr_State = Wr_State) then
--		Token_out  <= '0';
		Token_out  <= '1';
		rd_en   <= '0';	
   	wr_en_out  <= '1';
	elsif(Pr_State = TokenOut_State) then
		Token_out  <= '1';
		rd_en   <= '0';	
   	wr_en_out  <= '0';
	else
		Token_out  <= '0';
		rd_en   <= '0';	
   	wr_en_out  <= '0';
	end if;
  end if;
end process;


end Behavioral;

