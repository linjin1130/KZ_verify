----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:27:07 09/02/2013 
-- Design Name: 
-- Module Name:    FramePack - Behavioral 
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

entity FramePack is
Port(
sys_clk	:	in std_logic;
sys_rst_n:	in std_logic;
fifo_rst:	in std_logic;
frame_en:	in std_logic;
tdc_frame_fifo_empty	:	in std_logic;
tdc_frame_fifo_rd_en		:	out std_logic;
tdc_frame_fifo_dout		:	in std_logic_vector(15 downto 0);

frame_sdram_fifo_empty	:	out std_logic;
frame_sdram_fifo_rd_en	:	in std_logic;
frame_sdram_fifo_rd_clk	:	in std_logic;
frame_sdram_fifo_rd_data_count	:	out std_logic_vector(11 downto 0);
frame_sdram_fifo_dout	:	out std_logic_vector(15 downto 0)
);

end FramePack;

architecture Behavioral of FramePack is
	
	COMPONENT crc
	PORT(
		data_in : IN std_logic_vector(15 downto 0);
		crc_en : IN std_logic;
		rst_n : IN std_logic;
		clk : IN std_logic;          
		crc_out : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;
	
COMPONENT frame_sdram_fifo
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    full : OUT STD_LOGIC;
    almost_full : OUT STD_LOGIC;
	  prog_full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    almost_empty : OUT STD_LOGIC;
	 wr_data_count : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
    rd_data_count : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
  );
END COMPONENT;

type frame_fsm is (idle_frm,syn_frm,data_length_frm,data_frm,crc_frm,end_frm);
signal pr_state_frm,nx_state_frm	:	frame_fsm;
signal syn_frm_cnt	:	std_logic_vector(1 DOWNTO 0);
signal data_length_frm_cnt	:	std_logic_vector(1 DOWNTO 0);
signal crc_frm_cnt	:	std_logic_vector(1 DOWNTO 0);
signal data_frm_wr_cnt	:	std_logic_vector(15 DOWNTO 0);
signal data_frm_rd_cnt	:	std_logic_vector(15 DOWNTO 0);
signal end_frm_cnt	:	std_logic_vector(2 DOWNTO 0);
signal crc_data_in	:	std_logic_vector(15 DOWNTO 0);
signal frame_sdram_fifo_din	:	std_logic_vector(15 DOWNTO 0);
signal crc_data_out	:	std_logic_vector(15 DOWNTO 0);
signal frame_sdram_fifo_wr_data_count	:	std_logic_vector(11 DOWNTO 0);

signal frame_sdram_fifo_wr_en	:	std_logic;
signal frame_sdram_fifo_almost_full	:	std_logic;
signal frame_sdram_fifo_prog_full	:	std_logic;
signal crc_en	:	std_logic;
signal tdc_frame_fifo_rd_en_sig	:	std_logic;
signal tdc_frame_fifo_rd_en_sig_1d	:	std_logic;
--signal sys_rst	:	std_logic;
signal crc_local_rst_n	:	std_logic;
signal crc_rst_n	:	std_logic;

constant frame_length: integer := 1016;

begin
tdc_frame_fifo_rd_en <= tdc_frame_fifo_rd_en_sig;
--------------state 1
frm_state_reg:	process(sys_clk, sys_rst_n) begin
	if (sys_rst_n = '0')then
		pr_state_frm	<= idle_frm;
	elsif (sys_clk'event and sys_clk = '1') then
		pr_state_frm	<= nx_state_frm;
	end if;
end process;
------------------state 2
frm_state_transfer: process(pr_state_frm,frame_en,syn_frm_cnt,data_length_frm_cnt,data_frm_wr_cnt,crc_frm_cnt,end_frm_cnt,frame_sdram_fifo_prog_full,frame_sdram_fifo_wr_data_count)--
begin
	case pr_state_frm is
		when idle_frm =>
			if ((frame_en = '1') and (frame_sdram_fifo_wr_data_count < 3060)) then
				nx_state_frm <= syn_frm;
			else
				nx_state_frm <= idle_frm;
			end if;
		when syn_frm =>
			if(frame_sdram_fifo_prog_full = '0')then
				if (syn_frm_cnt < 1) then
					nx_state_frm <= syn_frm;
				else
					nx_state_frm <= data_length_frm;
				end if;
			else
				nx_state_frm <= syn_frm;
			end if;
		when data_length_frm =>
			if(frame_sdram_fifo_prog_full = '0')then
				if(data_length_frm_cnt < 1)then
					nx_state_frm <= data_length_frm;
				else
					nx_state_frm <= data_frm;
				end if;
			else
				nx_state_frm <= data_length_frm;
			end if;
		when data_frm =>
--			if(data_frm_wr_cnt < x"03F6") then---1016-1
--			if(data_frm_wr_cnt < x"0F") then---16-1
			if(data_frm_wr_cnt < (frame_length)) then---16-1
				nx_state_frm <= data_frm;
			else
				nx_state_frm <= crc_frm;
			end if;
		when crc_frm =>
			if(frame_sdram_fifo_prog_full = '0')then
				if (crc_frm_cnt < 1) then
					nx_state_frm <= crc_frm;
				else
					nx_state_frm <= end_frm;
				end if;
			else
				nx_state_frm <= crc_frm;
			end if;
		when end_frm =>
			if(frame_sdram_fifo_prog_full = '0')then
				if(end_frm_cnt < 2)then
					nx_state_frm <= end_frm;
				else
					nx_state_frm <= idle_frm;
				end if;
			else
				nx_state_frm <= end_frm;
			end if;
		when others =>
			nx_state_frm <= idle_frm;
	end case;
end process;
		
		
-----------------state 3
frm_state_out: process(sys_clk, sys_rst_n)
begin
	if(sys_rst_n = '0')then
		frame_sdram_fifo_wr_en <= '0';
		frame_sdram_fifo_din <= (others => '0');
		tdc_frame_fifo_rd_en_sig <= '0';
		tdc_frame_fifo_rd_en_sig_1d <= '0';
	elsif (sys_clk'event and sys_clk = '1') then
		if(pr_state_frm = idle_frm)then
			frame_sdram_fifo_wr_en <= '0';
			frame_sdram_fifo_din <= (others => '0');
			tdc_frame_fifo_rd_en_sig <= '0';
			tdc_frame_fifo_rd_en_sig_1d <= '0';			
		elsif(pr_state_frm = syn_frm)then
			if(frame_sdram_fifo_prog_full = '0')then
				frame_sdram_fifo_wr_en <= '1';
				frame_sdram_fifo_din <=	x"A5A5";
				tdc_frame_fifo_rd_en_sig <= '0';
				tdc_frame_fifo_rd_en_sig_1d <= '0';
			else
				frame_sdram_fifo_wr_en <= '0';
				frame_sdram_fifo_din <= (others => '0');
				tdc_frame_fifo_rd_en_sig <= '0';
				tdc_frame_fifo_rd_en_sig_1d <= '0';			
			end if;
		elsif(pr_state_frm = data_length_frm)then
			if(frame_sdram_fifo_prog_full = '0')then
				if(data_length_frm_cnt = 0)then
					frame_sdram_fifo_wr_en 	<= '1';
					frame_sdram_fifo_din 	<=	x"0000";
				elsif(data_length_frm_cnt = 1)then
					frame_sdram_fifo_wr_en <= '1';
					frame_sdram_fifo_din <=	x"07F0";--2032 Byte->1016 WrCnts-> 254 TDCdata
				end if;
			else
				frame_sdram_fifo_wr_en <= '0';
				frame_sdram_fifo_din <= (others => '0');
			end if;
			tdc_frame_fifo_rd_en_sig <= '0';
			tdc_frame_fifo_rd_en_sig_1d <= '0';
		elsif(pr_state_frm = data_frm)then
			if(frame_en = '1')then
--				if(nx_state_frm = data_frm) then
--				if(data_frm_rd_cnt < x"0F") then
				if(data_frm_rd_cnt < (frame_length)) then
					if(tdc_frame_fifo_empty = '0' and frame_sdram_fifo_prog_full = '0')then---may be read 2 more data,so use prog_full flag
						tdc_frame_fifo_rd_en_sig	<= '1' and (not tdc_frame_fifo_rd_en_sig);
					else
						tdc_frame_fifo_rd_en_sig <= '0';
					end if;
				else
					tdc_frame_fifo_rd_en_sig <= '0';
				end if;
				tdc_frame_fifo_rd_en_sig_1d <= tdc_frame_fifo_rd_en_sig;
				frame_sdram_fifo_wr_en <= tdc_frame_fifo_rd_en_sig_1d;
				frame_sdram_fifo_din <= tdc_frame_fifo_dout;
			else
				tdc_frame_fifo_rd_en_sig <= '0';
				tdc_frame_fifo_rd_en_sig_1d <= '0';
				frame_sdram_fifo_wr_en <= '1';
				frame_sdram_fifo_din <= x"ffff";
			end if;
		elsif(pr_state_frm = crc_frm)then
			if(frame_sdram_fifo_prog_full = '0')then
				if(crc_frm_cnt = 1)then
					frame_sdram_fifo_wr_en <= '1';
					frame_sdram_fifo_din <= crc_data_out;
				else
					frame_sdram_fifo_wr_en <= '0';
					frame_sdram_fifo_din <= frame_sdram_fifo_din;
				end if;
			else
				frame_sdram_fifo_wr_en <= '0';
				frame_sdram_fifo_din <= (others => '0');
			end if;
			tdc_frame_fifo_rd_en_sig <= '0';
			tdc_frame_fifo_rd_en_sig_1d <= '0';
		elsif(pr_state_frm = end_frm)then
			if(frame_sdram_fifo_prog_full = '0')then
				frame_sdram_fifo_wr_en <= '1';
				frame_sdram_fifo_din <= x"4747";
			else
				frame_sdram_fifo_wr_en <= '0';
				frame_sdram_fifo_din <= (others => '0');
			end if;
			tdc_frame_fifo_rd_en_sig <= '0';
			tdc_frame_fifo_rd_en_sig_1d <= '0';
		else
			frame_sdram_fifo_wr_en <= '0';
			frame_sdram_fifo_din <= (others => '0');
			tdc_frame_fifo_rd_en_sig <= '0';
			tdc_frame_fifo_rd_en_sig_1d <= '0';
		end if;
	end if;
end process;			

------------------
crc_pro: process(sys_clk, sys_rst_n)
begin
	if(sys_rst_n = '0')then
		crc_en		<= '0';
		crc_data_in	<= (others => '0');	
	elsif(sys_clk'event and sys_clk = '1') then
		if(pr_state_frm = data_length_frm) then
--			crc_en		<= '1';
--			crc_data_in <= x"07F0";
			if(frame_sdram_fifo_prog_full = '0')then
				if(data_length_frm_cnt = 0)then
					crc_en 	<= '1';
					crc_data_in 	<=	x"0000";
				elsif(data_length_frm_cnt = 1)then
					crc_en <= '1';
					crc_data_in <=	x"07F0";--2032 Byte->1016 WrCnts-> 254 TDCdata
				end if;
			else
				crc_en <= '0';
				crc_data_in <= (others => '0');
			end if;
		elsif(pr_state_frm = data_frm)then
			crc_en		<= tdc_frame_fifo_rd_en_sig_1d;
			crc_data_in <= tdc_frame_fifo_dout;
		else
			crc_en		<= '0';
			crc_data_in	<= (others => '0');
		end if;
	end if;
end process;

crc_local_rst_n_pro: process(sys_clk)
begin
	if(sys_clk'event and sys_clk = '1') then
		if(pr_state_frm = idle_frm) then
			crc_local_rst_n		<= '0';
		else
			crc_local_rst_n		<= '1';
		end if;
	end if;
end process;

------state cnt
syn_frm_cnt_pro: process(sys_clk, sys_rst_n)
begin
	if(sys_rst_n = '0')then
		syn_frm_cnt <= "00";
	elsif(sys_clk'event and sys_clk = '1') then
		if(pr_state_frm = syn_frm)then
			if(frame_sdram_fifo_prog_full = '0')then
				if(syn_frm_cnt < "11")then
					syn_frm_cnt <= syn_frm_cnt + '1';
				else
					syn_frm_cnt <= syn_frm_cnt;
				end if;
			else
				syn_frm_cnt <= syn_frm_cnt;
			end if;
		else
			syn_frm_cnt <= "00";
		end if;
	end if;
end process;

data_length_frm_cnt_pro: process(sys_clk, sys_rst_n)
begin
	if(sys_rst_n = '0')then
		data_length_frm_cnt <= "00";
	elsif(sys_clk'event and sys_clk = '1') then
		if(pr_state_frm = data_length_frm)then
			if(frame_sdram_fifo_prog_full = '0')then
				if(data_length_frm_cnt < "11")then
					data_length_frm_cnt <= data_length_frm_cnt + '1';
				else
					data_length_frm_cnt <= data_length_frm_cnt;
				end if;
			else
				data_length_frm_cnt <= data_length_frm_cnt;
			end if;
		else
			data_length_frm_cnt <= "00";
		end if;
	end if;
end process;

data_frm_wr_cnt_pro: process(sys_clk, sys_rst_n)
begin
	if(sys_rst_n = '0')then
		data_frm_wr_cnt <= (others => '0');
	elsif (sys_clk'event and sys_clk = '1') then
		if(pr_state_frm = data_frm)then
			if(frame_sdram_fifo_wr_en = '1')then
				data_frm_wr_cnt <= data_frm_wr_cnt + '1';
			else
				data_frm_wr_cnt <= data_frm_wr_cnt;
			end if;
		else
			data_frm_wr_cnt <= (others => '0');
		end if;
	end if;
end process;

data_frm_rd_cnt_pro: process(sys_clk, sys_rst_n)
begin
	if(sys_rst_n = '0')then
		data_frm_rd_cnt <= (others => '0');
	elsif (sys_clk'event and sys_clk = '1') then
		if(pr_state_frm = data_frm)then
			if(tdc_frame_fifo_rd_en_sig = '1')then
				data_frm_rd_cnt <= data_frm_rd_cnt + '1';
			else
				data_frm_rd_cnt <= data_frm_rd_cnt;
			end if;
		else
			data_frm_rd_cnt <= (others => '0');
		end if;
	end if;
end process;

crc_frm_cnt_pro: process(sys_clk, sys_rst_n)
begin
	if(sys_rst_n = '0')then
		crc_frm_cnt <= "00";
	elsif(sys_clk'event and sys_clk = '1') then
		if(pr_state_frm = crc_frm)then
			if(frame_sdram_fifo_prog_full = '0')then
				if(crc_frm_cnt < "11")then
					crc_frm_cnt <= crc_frm_cnt + '1';
				else
					crc_frm_cnt <= crc_frm_cnt;
				end if;
			else
				crc_frm_cnt <= crc_frm_cnt;
			end if;
		else
			crc_frm_cnt <= "00";
		end if;
	end if;
end process;

end_frm_cnt_pro: process(sys_clk, sys_rst_n)
begin
	if(sys_rst_n = '0')then
		end_frm_cnt <= "000";
	elsif(sys_clk'event and sys_clk = '1') then
		if(pr_state_frm = end_frm)then
			if(frame_sdram_fifo_prog_full = '0')then
				if(end_frm_cnt < "100")then
					end_frm_cnt <= end_frm_cnt + '1';
				else
					end_frm_cnt <= end_frm_cnt;
				end if;
			else
				end_frm_cnt <= end_frm_cnt;
			end if;
		else
			end_frm_cnt <= "000";
		end if;
	end if;
end process;

	Inst_crc: crc PORT MAP(
		data_in => crc_data_in,
		crc_en => crc_en,
		rst_n => crc_rst_n,
		clk => sys_clk,
		crc_out => crc_data_out
	);

  frame_sdram_fifo_inst : frame_sdram_fifo
  PORT MAP (
    rst => fifo_rst,
    wr_clk => sys_clk,
    rd_clk => frame_sdram_fifo_rd_clk,
    din => frame_sdram_fifo_din,
    wr_en => frame_sdram_fifo_wr_en,
    rd_en => frame_sdram_fifo_rd_en,
    dout => frame_sdram_fifo_dout,
    full => open,
    almost_full => frame_sdram_fifo_almost_full,
    prog_full =>  frame_sdram_fifo_prog_full,
    empty => frame_sdram_fifo_empty,
	 almost_empty => open,
    wr_data_count => frame_sdram_fifo_wr_data_count,
    rd_data_count => frame_sdram_fifo_rd_data_count
  );

--sys_rst <= not sys_rst_n;
crc_rst_n <= sys_rst_n and crc_local_rst_n;
end Behavioral;

