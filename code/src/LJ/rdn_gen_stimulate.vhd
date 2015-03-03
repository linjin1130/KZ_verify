----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:30:37 01/20/2014 
-- Design Name: 
-- Module Name:    rdn_gen_stimulate - Behavioral 
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
use IEEE.math_real.ALL;
use IEEE.numeric_std.ALL;
use IEEE.std_logic_arith.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rdn_gen_stimulate is
port(
		------------WNG1 port------------------------------------------------------
		Rnd_Gen_WNG_Clk	:	in	 std_logic;
		Rnd_Gen_WNG_Rst	:	in	 std_logic;
		Rnd_Gen_WNG_Oe_n	:	in	 std_logic;	
		Rnd_Gen_WNG_Data	:	out std_logic
	);
end rdn_gen_stimulate;

architecture Behavioral of rdn_gen_stimulate is
shared variable rand_seed1:integer:=844396720;  -- uniform procedure seed1
shared variable rand_seed2:integer:=821616997;  -- uniform procedure seed2
impure function random_value_gen (constant lower_value : in integer := 0;
                                  constant upper_value : in integer:= 1) return std_logic is
   variable rand_result : integer;
   variable tmp_real : real;  -- return value from uniform procedure
begin
   uniform(rand_seed1,rand_seed2,tmp_real);
   rand_result:=integer(trunc((tmp_real * real(upper_value - lower_value)) + real(lower_value)));
   if(rand_result = 1) then
   	return '1';
   else
   	return '0';
   end if;
end;

begin
	process  begin
	
		wait until rising_edge(Rnd_Gen_WNG_Clk);
		wait for 1 ns;
		if(Rnd_Gen_WNG_Rst = '1' or Rnd_Gen_WNG_Oe_n = '1') then
			Rnd_Gen_WNG_Data	<= '0';
		else
			Rnd_Gen_WNG_Data	<= random_value_gen(0, 2);
--		if(Rnd_Gen_WNG_Oe_n = '0') then
--			Rnd_Gen_WNG_Data	<= random_value_gen(0, 2);
--		else
--			Rnd_Gen_WNG_Data	<= '0';
--		end if;
	end if;
	end process;

end Behavioral;

