----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:49:24 09/27/2014 
-- Design Name: 
-- Module Name:    SRAM_RD_WR - Behavioral 
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SRAM_RD_WR is
generic
    (
     BURST_LEN  : integer := 1;    -- Burst Length
     DATA_WIDTH : integer := 31
    );
  port
    (
     sys_clk       : in  std_logic;
     sys_rst_n       : in  std_logic;
     fifo_clr       : in  std_logic;
	  
	  exp_running					:  in std_logic;--fifo has spare space
	  POC_fifo_rdy  : IN std_logic;
	  Alice_H_Bob_L : IN std_logic;
	  
	  rnd_data_store_en	: in std_logic;
		
	  serial_fifo_rdy				:  in std_logic;--fifo has spare space
	  serial_fifo_wr_en			:  out std_logic;--fifo write enable
	  serial_fifo_wr_data		:  out std_logic_vector(BURST_LEN*DATA_WIDTH-1 downto 0);--fifo write data

	  random_fifo_empty			:  in std_logic;--fifo has data
	  random_fifo_vld				:  in std_logic;--fifo read data valid
	  
	  send_write_prepare		: 	in std_logic;
	  send_write_back_en		: 	in std_logic;
	  send_write_back_data		: 	in std_logic_VECTOR(63 downto 0);
	  
	  dps_cpldif_fifo_wr_en		:	out	std_logic;
	  dps_cpldif_fifo_wr_data		:	out	std_logic_vector(63 downto 0);
	  cpldif_dps_fifo_prog_full	:	in	std_logic;
	  
	  PM_wr_en			:	in	std_logic;
	  PM_wr_data		:	in	std_logic_vector(47 downto 0);
	  
	  random_fifo_rd_en			:  out std_logic;--fifo read enable
	  random_fifo_rd_data		:  in std_logic_vector(BURST_LEN*DATA_WIDTH-1 downto 0)--fifo read data

	  );
end SRAM_RD_WR;

architecture Behavioral of SRAM_RD_WR is

  signal dps_cpldif_fifo_wr_en_reg	  : std_logic;
  signal serial_fifo_rdy_reg	  : std_logic;
  signal random_fifo_rd_reg	  : std_logic;
  signal fifo_operate_permit	  : std_logic;
  signal PM_wr_en_reg1	  : std_logic;
--  signal PM_wr_en_reg2	  : std_logic;
  	
--  signal fill_data		:	std_logic_vector(15 downto 0);
  signal dps_cpldif_fifo_wr_cnt		:	std_logic_vector(7 downto 0);
  signal fifo_rd_cnt		:	std_logic_vector(15 downto 0);
--  signal data_reg1		:	std_logic_vector(31 downto 0);
--  signal data_reg2		:	std_logic_vector(31 downto 0);
--  signal PM_wr_data_reg	:	std_logic_vector(47 downto 0);
begin
 
  ---generate random fifo read permit
  ---sram not full
  ---random fifo not empty
  ---calibreation is done
  process(exp_running, random_fifo_empty, serial_fifo_rdy_reg, cpldif_dps_fifo_prog_full) 
  begin 
		if(exp_running = '1' and random_fifo_empty = '0' and serial_fifo_rdy_reg = '1' and send_write_prepare = '0') then
			fifo_operate_permit	<= '1';
		else
			fifo_operate_permit	<= '0';
		end if;
  end process;
  
  --generate sram read request
  process(sys_clk, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			random_fifo_rd_reg	<= '0';
		else
			if(sys_clk'event and sys_clk = '1') then
				if(fifo_operate_permit = '1') then
					if(random_fifo_rd_reg = '0') then--read random fifo 
						random_fifo_rd_reg	<= '1';
					else
						random_fifo_rd_reg	<= '0';
					end if;
				else
					random_fifo_rd_reg	<= '0';
				end if;
			end if;
		end if;
  end process;
  
  process(sys_clk, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			PM_wr_en_reg1	<= '0';
--			PM_wr_en_reg2	<= '0';
--			fill_data	<= x"5555";
		else
			if(sys_clk'event and sys_clk = '1') then
				PM_wr_en_reg1	<= PM_wr_en and random_fifo_vld;
--				PM_wr_en_reg2	<= PM_wr_en_reg1;
--				if(Alice_H_Bob_L = '1') then
--					fill_data	<= x"5555";
--				else
--					fill_data	<= x"AAAA";
--				end if;
			end if;
		end if;
  end process;
  
  process(sys_clk, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			serial_fifo_rdy_reg	<= '0';
		else
			if(sys_clk'event and sys_clk = '1') then
				if(Alice_H_Bob_L = '1') then --Alice
					serial_fifo_rdy_reg	<= serial_fifo_rdy;
				else--Bob
					serial_fifo_rdy_reg	<= POC_fifo_rdy;
				end if;
			end if;
		end if;
  end process;
  
  process(sys_clk, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			dps_cpldif_fifo_wr_cnt	<= x"00";
		else
			if(sys_clk'event and sys_clk = '1') then
				if(fifo_clr = '1') then
					dps_cpldif_fifo_wr_cnt	<= x"00";
				else
					if(dps_cpldif_fifo_wr_en_reg = '1' ) then
						dps_cpldif_fifo_wr_cnt	<= dps_cpldif_fifo_wr_cnt + 1;
					end if;
				end if;
			end if;
		end if;
  end process;
  
  random_fifo_rd_en		<= random_fifo_rd_reg;
  serial_fifo_wr_en		<= random_fifo_vld ; 		
  serial_fifo_wr_data	<= random_fifo_rd_data;
  
  --generate sram read request
  process(sys_clk, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			fifo_rd_cnt	<= (others => '0');
		else
			if(sys_clk'event and sys_clk = '1') then
				if(fifo_clr = '1') then
					fifo_rd_cnt	<= (others => '0');
				else
					if(random_fifo_rd_reg = '1') then
--						if(fifo_rd_cnt < 13) then
							fifo_rd_cnt	<= fifo_rd_cnt + 1;
--						else
--							fifo_rd_cnt	<= (others => '0');
--						end if;
					end if;
				end if;
			end if;
		end if;
  end process;
  
  --generate sram read request
    process(sys_clk, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			dps_cpldif_fifo_wr_data	<= (others => '0');
			dps_cpldif_fifo_wr_en_reg	<= '0';
		else
			if(sys_clk'event and sys_clk = '1') then
				if(random_fifo_vld = '1' and rnd_data_store_en = '1') then
				  dps_cpldif_fifo_wr_data	   <= x"AA" & dps_cpldif_fifo_wr_cnt & fifo_rd_cnt & random_fifo_rd_data; 
				  dps_cpldif_fifo_wr_en_reg	<= '1';
				else
					if(PM_wr_en_reg1 = '1' or PM_wr_en = '1' ) then
						dps_cpldif_fifo_wr_en_reg	<= '1';
						dps_cpldif_fifo_wr_data	<= x"BB" & dps_cpldif_fifo_wr_cnt & PM_wr_data;
					else
						dps_cpldif_fifo_wr_en_reg	<= send_write_back_en;
						dps_cpldif_fifo_wr_data	<= send_write_back_data;
					end if;
				end if;
			end if;
		end if;
  end process;
	dps_cpldif_fifo_wr_en	<= dps_cpldif_fifo_wr_en_reg;
end Behavioral;

