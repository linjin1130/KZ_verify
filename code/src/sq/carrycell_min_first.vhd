
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


library UNISIM;
use UNISIM.VComponents.all;

entity carrycell_min_first is
port(
     Cin: in std_logic;
	  Din: in std_logic_vector(3 downto 0);
	  Aclear: in std_logic;
	  Enable: in std_logic;
	  CLK: in std_logic;
--	  O_XOR: out std_logic_vector(3 downto 0);
	  Cout: out std_logic;
	  stepdata_o: out std_logic_vector(1 downto 0)
	  );
end carrycell_min_first;

architecture Behavioral of carrycell_min_first is

signal O_temp1: std_logic_vector(3 downto 0);
signal CO_temp1: std_logic_vector(3 downto 0);
signal CYINIT_temp :std_logic;
begin

CARRY4_inst_1 : CARRY4
   port map (
      CO => CO_temp1,         -- 4-bit carry out
      O => O_temp1,           -- 4-bit carry chain XOR data out
      CI => '0',         -- 1-bit carry cascade input
      CYINIT => Cin, -- 1-bit carry initialization
      DI => "1111",         -- 4-bit carry-MUX data in
      S => "1111"            -- 4-bit carry-MUX select input
   );
	
FDCPE_inst_1 : FDCPE
   generic map (
      INIT => '0') -- Initial value of register ('0' or '1')  
   port map (
      Q => stepdata_o(0),      -- Data output
      C => CLK,      -- Clock input
      CE => Enable,    -- Clock enable input
      CLR => AClear,  -- Asynchronous clear input
      D => CO_temp1(0),      -- Data input
      PRE => '0'   -- Asynchronous set input
   );

FDCPE_inst_2 : FDCPE
   generic map (
      INIT => '0') -- Initial value of register ('0' or '1')  
   port map (
      Q => stepdata_o(1),      -- Data output
      C => CLK,      -- Clock input
      CE => Enable,    -- Clock enable input
      CLR => AClear,  -- Asynchronous clear input
      D => CO_temp1(3),      -- Data input
      PRE => '0'   -- Asynchronous set input
   );	
	

Cout <= CO_temp1(3);

end Behavioral;

