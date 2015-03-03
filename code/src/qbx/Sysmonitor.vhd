----------------------------------------------------------------------------------
-- Company: USTC
-- Engineer: Qi Binxiang
-- 
-- Create Date:    17:05:04 08/24/2013 
-- Design Name: 
-- Module Name:    SysMonitor - Behavioral 
-- Project Name: 

-- Revision 0.01 - File Created
-- Additional Comments: 
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


entity sysmonitor is
port(
		rstn		:	in std_logic;
		clk	    	:	in std_logic;
		
		---with cold_interface port------
		cpldif_sysmon_addr	: in std_logic_vector(7 downto 0);
		sysmon_cpldif_rd_data	: out std_logic_vector(31 downto 0);
		
		---with analog input port(system voltage and current)------
		vauxp0              : in  std_logic;                         -- auxiliary channel 0:report the system power 2.5v current
        vauxn0              : in  std_logic;
        vauxp1              : in  std_logic;                         -- auxiliary channel 1:report the system power 2.5v voltage
        vauxn1              : in  std_logic; 
        vauxp8                : in  std_logic;                         -- auxiliary channel 8: report the system power 5v current
        vauxn8                : in  std_logic;
        vauxp9                : in  std_logic;                         -- auxiliary channel 9:report the system power 5v voltage
        vauxn9                : in  std_logic;
        vauxp10              : in  std_logic;                         -- auxiliary channel 10:report the system power 12v current
        vauxn10              : in  std_logic;
        vauxp11              : in  std_logic;                         -- auxiliary channel 11:report the system power 12v voltage
        vauxn11              : in  std_logic;
        vauxp12             : in  std_logic;                         -- auxiliary channel 12:report the system power 3.3v current
        vauxn12             : in  std_logic;
        vauxp13             : in  std_logic;                         -- auxiliary channel 13:report the system power 3.3v voltage
        vauxn13             : in  std_logic;
        vauxp14               : in  std_logic;                         -- auxiliary channel 14:report the system power 1v current
        vauxn14               : in  std_logic;
        vauxp15              : in  std_logic;                         -- auxiliary channel 15:report the system power 1v voltage
        vauxn15               : in  std_logic;
        vp_in		                 : in  std_logic;                         -- dedicated analog input pair
		  vn_in		                 : in  std_logic
	  );
end sysmonitor;

architecture Behavioral of sysmonitor is

COMPONENT sysmonitor_ram
  PORT (
    a : in std_logic_vector(3 downto 0);
    d : in std_logic_vector(15 downto 0);
    dpra : in std_logic_vector(3 downto 0);
    clk : in std_logic;
    we : in std_logic;
    dpo : out std_logic_vector(15 downto 0)
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG

COMPONENT sysmonitor_core
    PORT (
          daddr_in            : in  std_logic_vector (6 downto 0);     -- address bus for the dynamic reconfiguration port
          dclk_in             : in  std_logic;                         -- clock input for the dynamic reconfiguration port
          den_in              : in  std_logic;                         -- enable signal for the dynamic reconfiguration port
          di_in               : in  std_logic_vector (15 downto 0);    -- input data bus for the dynamic reconfiguration port
          dwe_in              : in  std_logic;                         -- write enable for the dynamic reconfiguration port
          reset_in            : in  std_logic;                         -- reset signal for the system monitor control logic
          vauxp0              : in  std_logic;                         -- auxiliary channel 0
          vauxn0              : in  std_logic;
          vauxp1              : in  std_logic;                         -- auxiliary channel 1
          vauxn1              : in  std_logic;
          vauxp8              : in  std_logic;                         -- auxiliary channel 8
          vauxn8              : in  std_logic;
          vauxp9              : in  std_logic;                         -- auxiliary channel 9
          vauxn9              : in  std_logic;
          vauxp10             : in  std_logic;                         -- auxiliary channel 10
          vauxn10             : in  std_logic;
          vauxp11             : in  std_logic;                         -- auxiliary channel 11
          vauxn11             : in  std_logic;
          vauxp12             : in  std_logic;                         -- auxiliary channel 12
          vauxn12             : in  std_logic;
          vauxp13             : in  std_logic;                         -- auxiliary channel 13
          vauxn13             : in  std_logic;
          vauxp14             : in  std_logic;                         -- auxiliary channel 14
          vauxn14             : in  std_logic;
          vauxp15             : in  std_logic;                         -- auxiliary channel 15
          vauxn15             : in  std_logic;
          busy_out            : out  std_logic;                        -- adc busy signal
          do_out              : out  std_logic_vector (15 downto 0);   -- output data bus for dynamic reconfiguration port
          drdy_out            : out  std_logic;                        -- data ready signal for the dynamic reconfiguration port
          eoc_out             : out  std_logic;                        -- end of conversion signal
          eos_out             : out  std_logic;                        -- end of sequence signal
          jtagbusy_out        : out  std_logic;                        -- jtag drp transaction is in progress signal
          jtaglocked_out      : out  std_logic;                        -- drp port lock request has been made by jtag
          jtagmodified_out    : out  std_logic;                        -- indicates jtag write to the drp has occurred
          ot_out              : out  std_logic;                        -- over-temperature alarm output
          vccaux_alarm_out    : out  std_logic;                        -- vccaux-sensor alarm output
          vccint_alarm_out    : out  std_logic;                        -- vccint-sensor alarm output
          user_temp_alarm_out : out  std_logic;                        -- temperature-sensor alarm output
          vp_in               : in  std_logic;                         -- dedicated analog input pair
          vn_in               : in  std_logic
);
END COMPONENT;

signal den_in_sysmon : std_logic;
signal jtagbusy_out : std_logic;
signal jtaglocked_out : std_logic;
signal jtagmodified_out : std_logic;
signal eos_out : std_logic;
signal drdy_out : std_logic;
signal sysmon_ram_we : std_logic;
signal busy_out : std_logic;
signal eoc_out : std_logic;
signal ot_out : std_logic;
signal vccaux_alarm_out : std_logic;
signal vccint_alarm_out : std_logic;
signal user_temp_alarm_out : std_logic;
signal rst : std_logic;


signal sysmon_ram_wr_addr : std_logic_vector(3 downto 0);
signal sysmon_ram_wr_din : std_logic_vector(15 downto 0);
signal sysmon_ram_rd_dout : std_logic_vector(15 downto 0);
signal sysmon_ram_rd_addr : std_logic_vector(3 downto 0);

signal addr_sysmon : std_logic_vector(3 downto 0);
signal do_out_sysmon : std_logic_vector(15 downto 0);
signal daddr_in_sysmon : std_logic_vector(7 downto 0);

type sysmonstate_fsm is(idle_sysmonstate,rden_sysmonstate,wait_rddone_sysmonstate,
addradd_sysmonstate,addrjudge_sysmonstate);
signal pr_sysmonstate,nx_sysmonstate : sysmonstate_fsm;

begin
                    ----choose the sysmon data and addr-----
						  --------if cpldif_sysmon_addr=0X3-, show they select the sysmon addr. otherwise,the addr is invalid
sysmon_ram_rd_addr <=cpldif_sysmon_addr(3 downto 0) when ( cpldif_sysmon_addr(7 downto 4) = x"3") else  "0000"; 
						
sysmon_cpldif_rd_data (15 downto 0)<=	sysmon_ram_rd_dout;
sysmon_cpldif_rd_data (31 downto 16)<=	x"0000";					

-------------------SysMon state,readout the data from sysmonitor core----------
sysmonstate_reg:process(clk,rstn) begin
	if rstn = '0' then
		pr_sysmonstate <= idle_sysmonstate;
	elsif( clk'event and clk = '1') then
		pr_sysmonstate <= nx_sysmonstate;
	end if;
end process;

sysmonstate_transfer: process(pr_sysmonstate,jtagbusy_out,jtaglocked_out,jtagmodified_out,eos_out,drdy_out,addr_sysmon) begin
	case pr_sysmonstate is
		when idle_sysmonstate =>
			if ( jtagbusy_out = '0' and jtaglocked_out = '0' 
				and jtagmodified_out = '0' and eos_out = '1') then
				nx_sysmonstate	<= rden_sysmonstate;
			else
				nx_sysmonstate	<= idle_sysmonstate;
			end if;
		when rden_sysmonstate =>
			nx_sysmonstate	<= wait_rddone_sysmonstate;
		when wait_rddone_sysmonstate =>
			if(drdy_out = '1') then
				nx_sysmonstate <= addradd_sysmonstate;
			else
				nx_sysmonstate	<= wait_rddone_sysmonstate;
			end if;
		when addradd_sysmonstate =>
			nx_sysmonstate	<= addrjudge_sysmonstate;
		when addrjudge_sysmonstate =>
			if(addr_sysmon < x"e") then
				nx_sysmonstate	<= rden_sysmonstate;
			else
				nx_sysmonstate <= idle_sysmonstate;
			end if;
		when others =>
			nx_sysmonstate <= idle_sysmonstate;
	end case;
end process;

sysmonstate_out: process(clk,rstn) begin
	if rstn = '0' then
		den_in_sysmon	<= '0';			
		addr_sysmon		<= x"0";
		daddr_in_sysmon <= x"00";
	elsif(clk'event and clk = '1') then
		if(pr_sysmonstate = idle_sysmonstate) then
			den_in_sysmon	<= '0';			
			addr_sysmon		<= x"0";	
			daddr_in_sysmon <= x"00";
		elsif(pr_sysmonstate = rden_sysmonstate) then
			den_in_sysmon	<= '1';
			if(addr_sysmon = x"0") then
				daddr_in_sysmon		<= x"1b";--0x1b->sm11->+12v_v
			elsif(addr_sysmon = x"1") then
				daddr_in_sysmon		<= x"1a";--0x1a->sm10->+12v_c
			elsif(addr_sysmon = x"2") then
				daddr_in_sysmon		<= x"19";--0x19->sm9->+5v_v
			elsif(addr_sysmon = x"3") then
				daddr_in_sysmon		<= x"18";--0x18->sm8->+5v_c	
			elsif(addr_sysmon = x"4") then
				daddr_in_sysmon		<= x"1d";--0x1d->sm13->+3.3v_v
			elsif(addr_sysmon = x"5") then
				daddr_in_sysmon		<= x"1c";--0x1c->sm12->+3.3v_c
			elsif(addr_sysmon = x"6") then
				daddr_in_sysmon		<= x"11";--0x11->sm1->+2.5v_v	
			elsif(addr_sysmon = x"7") then
				daddr_in_sysmon		<= x"10";--0x10->sm0->+2.5v_c
			elsif(addr_sysmon = x"8") then
				daddr_in_sysmon		<= x"1f";--0x1f->sm15->+1v_v
			elsif(addr_sysmon = x"9") then
				daddr_in_sysmon		<= x"1e";--0x1e->sm14->+1v_c	
			elsif(addr_sysmon = x"a") then
				daddr_in_sysmon		<= x"00";--0x00->on-chip temperature sensor
			elsif(addr_sysmon = x"b") then
				daddr_in_sysmon		<= x"01";--0x01->vccint
			elsif(addr_sysmon = x"c") then
				daddr_in_sysmon		<= x"02";--0x02->vccaux	
			elsif(addr_sysmon = x"d") then
				daddr_in_sysmon		<= x"04";--0x04->VREP
			elsif(addr_sysmon = x"e") then
				daddr_in_sysmon		<= x"05";--0x04->VREN
			end if;
			addr_sysmon		<= addr_sysmon;
		elsif(pr_sysmonstate = wait_rddone_sysmonstate) then
			den_in_sysmon	<= '0';
			addr_sysmon		<= addr_sysmon;
			daddr_in_sysmon <= x"00";
		elsif(pr_sysmonstate = addradd_sysmonstate) then
			den_in_sysmon	<= '0';
			addr_sysmon	<= addr_sysmon + '1';
			daddr_in_sysmon <= x"00";
		elsif(pr_sysmonstate = addrjudge_sysmonstate) then
			den_in_sysmon	<= '0';
			addr_sysmon	<= addr_sysmon;
			daddr_in_sysmon <= x"00";
		else
			den_in_sysmon	<= '0';
			addr_sysmon	<= addr_sysmon;
			daddr_in_sysmon <= x"00";
		end if;
  end if;
end process;


sysmon_ram_wr_addr	<= addr_sysmon;
sysmon_ram_wr_din		<= do_out_sysmon;
sysmon_ram_we		<= drdy_out;

sysmonitor_ram_inst : sysmonitor_ram
  PORT MAP (
    a => sysmon_ram_wr_addr,
    d => sysmon_ram_wr_din,
    dpra => sysmon_ram_rd_addr,
    clk => clk,
    we => sysmon_ram_we,
    dpo => sysmon_ram_rd_dout
  );

rst <= not rstn;  
sysmonitor_core_inst : sysmonitor_core
  PORT MAP ( 
          daddr_in            => daddr_in_sysmon(6 downto 0), 
          dclk_in             => clk, 
          den_in              => den_in_sysmon, 
          di_in               => (others => '0'),
          dwe_in              => '0', 
          reset_in            => rst, 
          vauxp0              => vauxp0,  
          vauxn0              => vauxn0, 
          vauxp1              => vauxp1,
          vauxn1              => vauxn1,
          vauxp8              => vauxp8,
          vauxn8              => vauxn8,
          vauxp9              => vauxp9,
          vauxn9              => vauxn9,
          vauxp10             => vauxp10,
          vauxn10             => vauxn10,
          vauxp11             => vauxp11,
          vauxn11             => vauxn11,
          vauxp12             => vauxp12,
          vauxn12             => vauxn12,
          vauxp13             => vauxp13,
          vauxn13             => vauxn13,
          vauxp14             => vauxp14,
          vauxn14             => vauxn14,
          vauxp15             => vauxp15,
          vauxn15             => vauxn15,
          busy_out            => busy_out,
          do_out              => do_out_sysmon,
          drdy_out            => drdy_out,
          eoc_out             => eoc_out,
          eos_out             => eos_out,
          jtagbusy_out        => jtagbusy_out,
          jtaglocked_out      => jtaglocked_out,
          jtagmodified_out    => jtagmodified_out,
          ot_out              => ot_out,
          vccaux_alarm_out    => vccaux_alarm_out,
          vccint_alarm_out    => vccint_alarm_out,
          user_temp_alarm_out => user_temp_alarm_out,
			 vp_in=>vp_in,
			 vn_in=>vn_in
			 
         );
end Behavioral;

