
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity carrychain_plain is
port(
     Cin: in std_logic;
	  Aclear: in std_logic;
	  Enable: in std_logic;
	  CLK: in std_logic;
	  Cout: out std_logic;
	  stepdata_p: out std_logic_vector(299 downto 0)
	  );
end carrychain_plain;

architecture Behavioral of carrychain_plain is

component carrycell_min_first is
port(
     Cin: in std_logic;
	  Din: in std_logic_vector(3 downto 0);
	  Aclear: in std_logic;
	  Enable: in std_logic;
	  CLK: in std_logic;
	  Cout: out std_logic;
	  stepdata_o: out std_logic_vector(1 downto 0)
	  );
end component;

component carrycell_min_loop is
port(
     Cin: in std_logic;
	  Din: in std_logic_vector(3 downto 0);
	  Aclear: in std_logic;
	  Enable: in std_logic;
	  CLK: in std_logic;
	  Cout: out std_logic;
	  stepdata_o: out std_logic_vector(1 downto 0)
	  );
end component;

signal Cout_wire: std_logic;
constant STEP_NUM: integer := 149;
signal carry_inter: std_logic_vector(STEP_NUM+1 downto 0);
attribute keep : string;

attribute keep of carry_inter: signal is "true";


begin

carry_inter(0)<= Cin;
--Cout<= carry_inter(STEP_NUM+1);


carrycell_min_first_inst: carrycell_min_first
port map(
         Cin=> carry_inter(0),
			Din=>"1111",
			Aclear=> Aclear,
			Enable=> Enable,
			CLK=> CLK,
			Cout=> carry_inter(1),
			stepdata_o(1 downto 0)=> stepdata_p(1 downto 0)
			);
	
	
chain_plain_inst: for i in 1 to STEP_NUM generate
  begin
    carrycell_min_loop_inst: carrycell_min_loop
	     port map(
		           Cin=> carry_inter(i),
					  Din=> "1111",
					  Aclear=> Aclear,
			        Enable=> Enable,
			        CLK=> CLK,
					  Cout=> carry_inter(i+1),
					  stepdata_o(0)=> stepdata_p(2*i),
					  stepdata_o(1)=> stepdata_p(2*i+1)
					  );	
end generate;     	 


end Behavioral;
