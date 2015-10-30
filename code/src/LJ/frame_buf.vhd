----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity frame_buf is
port (
			fifo_wr_clk	:	in std_logic;-----------80M
			sys_clk	:	in std_logic;-----------80M
			sys_rst_n	:	in std_logic;-----------80M
			fifo_clr	:	in std_logic;-----------80M
			expe_enable	:	in std_logic;-----------80M

-------fifo interface-------
			tdc_cpldif_fifo_wr_en	:	out	std_logic;
			tdc_cpldif_fifo_wr_data	:	out	std_logic_vector(31 downto 0);
			cpldif_tdc_fifo_prog_full	:	in	std_logic;
			----dps qkd fifo data in
			tdc_fifo_wr_en				:	in std_logic;
			tdc_fifo_wr_data			:	in std_logic_vector(63 downto 0);
			tdc_fifo_prog_full		:	out std_logic
	  
		  );	  
end frame_buf;

architecture Behavioral of frame_buf is

COMPONENT dps_data_mux_fifo
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    almost_empty : OUT STD_LOGIC;
    prog_full : OUT STD_LOGIC
  );
END COMPONENT;

	COMPONENT FramePack
	PORT(
		sys_clk : IN std_logic;
		sys_rst_n : IN std_logic;
		fifo_rst : IN std_logic;
		frame_en : IN std_logic;
		tdc_frame_fifo_empty : IN std_logic;
		tdc_frame_fifo_dout : IN std_logic_vector(15 downto 0);
		frame_sdram_fifo_rd_en : IN std_logic;
		frame_sdram_fifo_rd_clk : IN std_logic;          
		tdc_frame_fifo_rd_en : OUT std_logic;
		frame_sdram_fifo_empty : OUT std_logic;
		frame_sdram_fifo_rd_data_count : OUT std_logic_vector(11 downto 0);
		frame_sdram_fifo_dout : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

COMPONENT sdram_cpldif_fifo
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full : OUT STD_LOGIC;
    almost_full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    almost_empty : OUT STD_LOGIC;
    wr_data_count : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
  );
END COMPONENT;

signal tdc_frame_fifo_dout: std_logic_vector(63 downto 0);
signal frame_sdram_fifo_rd_data_count: std_logic_vector(11 downto 0);
signal frame_sdram_fifo_dout: std_logic_vector(15 downto 0);
signal sdram_cpldif_fifo_din: std_logic_vector(15 downto 0);
signal sdram_cpldif_fifo_wr_data_count: std_logic_vector(11 downto 0);
signal sdram_cpldif_fifo_dout: std_logic_vector(31 downto 0);

signal dps_data_mux_fifo_din: std_logic_vector(63 downto 0);
signal dps_data_mux_fifo_dout: std_logic_vector(15 downto 0);
signal dps_data_mux_fifo_wr_en: std_logic;
signal dps_data_mux_fifo_wr_en_reg: std_logic;
signal dps_data_mux_fifo_rd_en: std_logic;
signal dps_data_mux_fifo_prog_full: std_logic;
signal dps_data_mux_fifo_empty: std_logic;

signal frame_sdram_fifo_rd_en: std_logic;
signal frame_sdram_fifo_rd_clk: std_logic;
signal sdram_cpldif_fifo_wr_en: std_logic;
signal sdram_cpldif_fifo_wr_clk: std_logic;
signal sdram_cpldif_fifo_rd_en: std_logic;
signal sdram_cpldif_fifo_rd_en_1d: std_logic;
signal sdram_cpldif_fifo_empty: std_logic;
--signal tdc_fifo_clear_n: std_logic;
signal sdram_cpldif_fifo_almost_full: std_logic;
signal frame_sdram_fifo_empty: std_logic;

signal sys_rst: std_logic;

		  
begin

--tdc_sdram_clk <= sdram_cpldif_fifo_wr_clk;
sys_rst <= not sys_rst_n;
  dps_data_mux_fifo_inst : dps_data_mux_fifo-------64bit-->16bit
  PORT MAP (
    rst => fifo_clr,
    wr_clk => fifo_wr_clk,
    rd_clk => sys_clk,
    din => tdc_fifo_wr_data,
    wr_en => tdc_fifo_wr_en,
    rd_en => dps_data_mux_fifo_rd_en,
    dout => dps_data_mux_fifo_dout,
    full => open,
    prog_full => tdc_fifo_prog_full,
    empty => dps_data_mux_fifo_empty,
    almost_empty => open
  );
  
  	Inst_FramePack: FramePack PORT MAP(
		sys_clk => sys_clk,
		sys_rst_n => sys_rst_n,
		fifo_rst => fifo_clr,
		frame_en => expe_enable,
		tdc_frame_fifo_empty => dps_data_mux_fifo_empty,
		tdc_frame_fifo_rd_en => dps_data_mux_fifo_rd_en,
		tdc_frame_fifo_dout => dps_data_mux_fifo_dout,
		frame_sdram_fifo_rd_en => frame_sdram_fifo_rd_en,
		frame_sdram_fifo_rd_clk => frame_sdram_fifo_rd_clk,
		frame_sdram_fifo_rd_data_count => frame_sdram_fifo_rd_data_count,
		frame_sdram_fifo_empty => frame_sdram_fifo_empty,
		frame_sdram_fifo_dout => frame_sdram_fifo_dout
	);
	
	frame_sdram_fifo_rd_en_process:process(sys_clk,sys_rst)
  begin
      if(sys_rst ='1')then
			  frame_sdram_fifo_rd_en <='0';
		elsif(sys_clk'event and sys_clk='1') then
		   if(frame_sdram_fifo_empty = '0' and sdram_cpldif_fifo_almost_full = '0' and frame_sdram_fifo_rd_en = '0' )then
		     frame_sdram_fifo_rd_en <='1';
			else
				frame_sdram_fifo_rd_en <='0';
         end if;
			sdram_cpldif_fifo_wr_en <= frame_sdram_fifo_rd_en;
		end if;
  end process;
sdram_cpldif_fifo_din <= frame_sdram_fifo_dout;
sdram_cpldif_fifo_wr_clk <= sys_clk;
frame_sdram_fifo_rd_clk <= sys_clk;
	
	sdram_cpldif_fifo_inst : sdram_cpldif_fifo
  PORT MAP (
    rst => fifo_clr,
    wr_clk => sdram_cpldif_fifo_wr_clk,
    rd_clk => sys_clk,
    din => sdram_cpldif_fifo_din,
    wr_en => sdram_cpldif_fifo_wr_en,
    rd_en => sdram_cpldif_fifo_rd_en,
    dout => sdram_cpldif_fifo_dout,
    full => open,
    almost_full => sdram_cpldif_fifo_almost_full,
    empty => sdram_cpldif_fifo_empty,
    almost_empty => open,
    wr_data_count => sdram_cpldif_fifo_wr_data_count
  );
  
  sdram_cpldif_fifo_rd_process:process(sys_clk,sys_rst)
  begin
      if(sys_rst ='1')then
			  sdram_cpldif_fifo_rd_en <='0';
		elsif(sys_clk'event and sys_clk='1') then
		   if(sdram_cpldif_fifo_empty = '0' and cpldif_tdc_fifo_prog_full = '0')then
		     sdram_cpldif_fifo_rd_en <='1' and (not sdram_cpldif_fifo_rd_en);
			else
				sdram_cpldif_fifo_rd_en <='0';
         end if;
		end if;
  end process;
  
  
cpldif_tdc_fifo_wr_process:process(sys_clk,sys_rst)
  begin
      if(sys_rst ='1')then
			sdram_cpldif_fifo_rd_en_1d <='0';
			tdc_cpldif_fifo_wr_en <='0';
		elsif(sys_clk'event and sys_clk='1') then
		   sdram_cpldif_fifo_rd_en_1d <= sdram_cpldif_fifo_rd_en;			  
		   tdc_cpldif_fifo_wr_en <= sdram_cpldif_fifo_rd_en_1d;			  
		end if;
  end process;

tdc_cpldif_fifo_wr_data_reverse_process:process(sys_clk,sys_rst)
  begin
      if(sys_rst ='1')then
			tdc_cpldif_fifo_wr_data <=(others => '0');
		elsif(sys_clk'event and sys_clk='1') then
		   tdc_cpldif_fifo_wr_data(31 downto 16) <= sdram_cpldif_fifo_dout(15 downto 0);			  
		   tdc_cpldif_fifo_wr_data(15 downto 0) <= sdram_cpldif_fifo_dout(31 downto 16);			  
		end if;
  end process; 

end Behavioral;

