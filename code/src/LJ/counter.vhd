----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:37:37 10/16/2014 
-- Design Name: 
-- Module Name:    counter - Behavioral 
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
use ieee.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity counter is
Port ( 	  sys_CLK_160M : in  STD_LOGIC;
			  sys_rst  		: in  STD_LOGIC;
			  
			  count_set  		: in  STD_LOGIC;
			  count_set_value : in  STD_LOGIC_VECTOR(31 downto 0);
			  
			  count_running: out  STD_LOGIC;
			  count_reach	: out  STD_LOGIC
			  );
end counter;

architecture Behavioral of counter is
signal data_count32 	: std_logic_vector(31 downto 0);
begin

process (sys_CLK_160M, sys_rst)
begin  
   if(sys_rst = '1') then
		data_count32	<= (others => '0');
		count_running	<= '0';
	else
		if (sys_CLK_160M'event and sys_CLK_160M = '1') then
			 if(count_set = '1') then
				data_count32	<= count_set_value;
				count_running	<= '1';
			 else
				if(data_count32 > 0) then
					data_count32	<= data_count32 - 1;
					count_running	<= '1';
				else
					count_running	<= '0';
				end if;
			 end if;
		end if;
   end if;
end process;

process (sys_CLK_160M, sys_rst)
begin  
   if(sys_rst = '1') then
		count_reach	<= '0';
	else
		if (sys_CLK_160M'event and sys_CLK_160M = '1') then
			if(data_count32 = 1) then
				count_reach	<= '1';
			else
				count_reach	<= '0';
			end if;
		end if;
   end if;
end process;

end Behavioral;

