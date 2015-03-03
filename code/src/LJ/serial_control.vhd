----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:48:22 09/28/2014 
-- Design Name: 
-- Module Name:    OSERDES - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity serial_control is
generic
    (
     constant IODELAY_GRP    : string := "IODELAY_MIG";  -- May be assigned unique name when
                                              -- multiple IP cores used in design
	  BURST_LEN  : integer := 1;    -- Burst Length
     DATA_WIDTH : integer := 32    -- Data Width
    );
port(
--		sys_clk_100M					: in std_logic;--reset in active low
		sys_clk_200M					: in std_logic;--reset in active low
		sys_rst_n						: in std_logic;--reset in active low
		fifo_clr							: in std_logic;--reset in
		
		serial_fifo_wr_clk			: in std_logic;--fifo write clock
		serial_fifo_rd_clk			: in std_logic;--fifo read clock, also is serial input clock
		serial_out_clk					: in std_logic;--6 times as serial_fifo_rd_clk
		
		delay_load				: in std_logic;--load delay value enable
		test_signal_delay				: in std_logic;--load delay value enable
		
		serial_fifo_wr_en				:  in std_logic;--fifo write enable
		serial_fifo_wr_data			:  in std_logic_vector(BURST_LEN*DATA_WIDTH-1 downto 0);--fifo write data
		
		exp_running						:	in std_logic;--serial output enable
		send_en							:	in std_logic;--serial output enable
		Alice_H_Bob_L					:	in std_logic;--serial output enable
		send_en_AM						:	in std_logic;--serial output enable
		send_enable						:	in std_logic;--serial output enable
		delay_AM1						: in	std_logic_vector(31 downto 0);
--		delay_AM2						: in	std_logic_vector(4 downto 0);
--		delay_PM 						: in	std_logic_vector(4 downto 0);
		rnd_data_store_en	: in std_logic;
		serial_fifo_rdy				:  out std_logic;--fifo has spare space
		iodelay_ctrl_rdy				:  out std_logic;
		
		send_write_prepare		: 	out std_logic;
		send_write_back_en		: 	out std_logic;
		send_write_back_data		: 	out std_logic_VECTOR(63 downto 0);
		
		delay_AM1_out			: out	std_logic_vector(29 downto 0);
--		delay_AM2_out			: out	std_logic_vector(4 downto 0);
--		delay_PM_out 			: out	std_logic_vector(4 downto 0);
		
		send_en_AM_p				:  out std_logic;--250M clock domain
		send_en_AM_n				:  out std_logic;--250M clock domain
			
		SERIAL_OUT_p			:	out std_logic_vector(2 downto 0);--serial output
		SERIAL_OUT_n			:	out std_logic_vector(2 downto 0)--serial output
		
);
end serial_control;

architecture Behavioral of serial_control is
component Serial_FIFO
	port (
	rst: in std_logic;
	wr_clk: in std_logic;
	rd_clk: in std_logic;
	din: in std_logic_vector(BURST_LEN*DATA_WIDTH-1 downto 0);
	wr_en: in std_logic;
	rd_en: in std_logic;
	dout: out std_logic_vector(15 downto 0);
	full: out std_logic;
	empty: out std_logic;
	valid: out std_logic;
	prog_full: out std_logic);
end component;

component Serial_FIFO_2
	port (
	rst: in std_logic;
	wr_clk: in std_logic;
	rd_clk: in std_logic;
	din: in std_logic_vector(15 downto 0);
	wr_en: in std_logic;
	rd_en: in std_logic;
	dout: out std_logic_vector(1 downto 0);
	full: out std_logic;
	empty: out std_logic;
	valid: out std_logic;
	prog_full: out std_logic;
	almost_full: out std_logic
	);
end component;

COMPONENT serial_unit
	PORT(
		sys_clk_500M : IN std_logic;
		sys_clk_250M : IN std_logic;
		sys_rst_h : IN std_logic;
		parallel : IN std_logic_vector(3 downto 0);          
		serial_out : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT delay_unit
	generic(
   IODELAY_GRP             : string  := "IODELAY_MIG" -- May be assigned unique name 
                                                       -- when mult IP cores in design
  );
	PORT(
--		sys_clk_500M : IN std_logic;
--		sys_clk_200M : IN std_logic;
		sys_clk_250M : IN std_logic;
		delay_load : IN std_logic;
		delay_in : IN std_logic;
		CNTVALUEIN : IN std_logic_vector(4 downto 0);          
		delay_out : OUT std_logic;
--		delay_out_n : OUT std_logic;
		CNTVALUEOUT : OUT std_logic_vector(4 downto 0)
		);
	END COMPONENT;
signal 	send_en_sync: 	std_logic;
signal 	rd_en			: 	std_logic;
signal 	dout			: 	std_logic_VECTOR(15 downto 0);
signal 	prog_full	: 	std_logic;
signal 	valid			: 	std_logic;
signal 	valid1_d1	: 	std_logic;
signal 	valid1_d2	: 	std_logic;
signal 	empty			: 	std_logic;

signal 	serial_out	: 	std_logic_VECTOR(0 downto 0);
signal 	delay_out	: 	std_logic_vector(1 downto 0);
signal 	delay_in		: 	std_logic_VECTOR(1 downto 0);

signal 	almost_full	: 	std_logic;
signal 	valid2			: 	std_logic;
signal 	wr_en_2			: 	std_logic;
signal 	rd_en2			: 	std_logic;
signal 	dout2			: 	std_logic_VECTOR(1 downto 0);


signal 	test_signal_delay_reg	: 	std_logic;
signal 	fifo_2_rdy_wr_clk	: 	std_logic;
signal 	fifo_2_rdy_rd_clk	: 	std_logic;
signal 	AM1_clk	: 	std_logic;
signal 	AM2_clk	: 	std_logic;
signal 	serial_AM1	: 	std_logic;
signal 	serial_AM2	: 	std_logic;
signal 	sys_rst_h	: 	std_logic;

signal 	Out_clk				: 	std_logic;
signal 	send_en_AM_d1				: 	std_logic;
signal 	send_en_80M_d1				: 	std_logic;
signal 	send_en_80M_d2				: 	std_logic;
signal 	send_write_en				: 	std_logic;
signal 	send_write_en_ds			: 	std_logic_vector(7 downto 0);
--signal 	send_write_en_d2			: 	std_logic;
--signal 	send_write_en_d3			: 	std_logic;

signal 	send_write_data			: 	std_logic_VECTOR(127 downto 0);
signal 	send_syn_cnt				: 	std_logic_VECTOR(23 downto 0);

--signal 	send_cnt		: 	std_logic_VECTOR(1 downto 0);

--signal 	serial_in		: 	std_logic_VECTOR(1 downto 0);
type serial_in_regType is array(0 to 0) of std_logic_vector(3 downto 0);
signal serial_in_reg : serial_in_regType;

--type dlycntType is array(0 to 2) of std_logic_vector(4 downto 0);
--signal dlycnt_in : dlycntType;
--signal dlycnt_out : dlycntType;

-- Synplicity black box declaration
attribute syn_black_box : boolean;
attribute syn_black_box of Serial_FIFO: component is true;
	attribute IODELAY_GROUP : string;
  attribute IODELAY_GROUP of IDELAYCTRL_inst : label is IODELAY_GRP;
begin
------------------------------------------------------------
------apply IDELAYCTRL, data sheet require This design element 
------must be instantiated when using the IODELAYE1 in virtex 6
------but when using two IODELAYE1, this will be an error occur
------------------------------------------------------------
IDELAYCTRL_inst : IDELAYCTRL
port map (
RDY => iodelay_ctrl_rdy,
-- 1-bit output indicates validity of the REFCLK
REFCLK => sys_clk_200M, -- 1-bit reference clock input
RST => sys_rst_h
-- 1-bit reset input
);

--dlycnt_in(0)	<= delay_AM1;
--dlycnt_in(1)	<= delay_AM2;
--dlycnt_in(2)	<= delay_PM;

delay_in(0)	<= serial_out(0);
delay_in(1)	<= send_en_AM;
--delay_in(2)	<= send_en_AM;
--delay_in(3)	<= send_en_AM;
--delay_in(4)	<= serial_out_clk;
--delay_in(5)	<= serial_out_clk;

--delay_AM1_out	<= dlycnt_out(0);
--delay_AM2_out	<= dlycnt_out(1);
--delay_PM_out	<= dlycnt_out(2);

serial_gen: for i in 0 to 0 generate
	Inst_serial_unit: serial_unit PORT MAP(
		sys_clk_500M => serial_out_clk,
		sys_clk_250M => serial_fifo_rd_clk,
		sys_rst_h => sys_rst_h,
		parallel => serial_in_reg(i),
		serial_out =>  serial_out(i)
	);
	
end generate;
delay_AM1_out(29 downto 5*2) <= (others => '1');
delay_gen: for i in 0 to 1 generate	
	Inst_delay_unit: delay_unit 
	generic map(
        IODELAY_GRP             => IODELAY_GRP
      )  
	PORT MAP(
--		sys_clk_200M => sys_clk_200M,
		sys_clk_250M => serial_fifo_rd_clk,
		delay_load => delay_load,
		delay_in => delay_in(i),
		delay_out => delay_out(i),
		CNTVALUEIN => delay_AM1((i+1)*5-1 downto i*5),
		CNTVALUEOUT => delay_AM1_out((i+1)*5-1 downto i*5)
	);
end generate;

--	MUXF8_inst1 : MUXF7
--	port map (
--		O => serial_AM1, -- Output of MUX to general routing
--		I0 => '0', -- Input (tie to MUXF6 LO out or LUT6 O6 pin)
--		I1 => delay_out(0), -- Input (tie to MUXF6 LO out or LUT6 O6 pin)
--		S => AM1_clk -- Input select to MUX
--	);
	
--	SERIAL_OUT_p(0)	<= delay_out(2);
--	SERIAL_OUT_p(1)	<= AM2_clk;
--	SERIAL_OUT_p(2)	<= AM1_clk;
--	SERIAL_OUT_n(0)	<= '0';
--	SERIAL_OUT_n(1)	<= '0';
--	SERIAL_OUT_n(2)	<= '0';
	
	send_en_AM_p	<= '0';
	send_en_AM_n	<= '0';
	
	PM_OBUFDS_inst : OBUFDS
   generic map (
      IOSTANDARD => "DEFAULT")
   port map (
      O => SERIAL_OUT_p(0),     -- Diff_p output (connect directly to top-level port)
      OB => SERIAL_OUT_n(0),   -- Diff_n output (connect directly to top-level port)
      I => delay_out(0)      -- Buffer input 
   );

--	MUXF8_inst2 : MUXF7
--	port map (
--		O => serial_AM2, -- Output of MUX to general routing
--		I0 => '0', -- Input (tie to MUXF6 LO out or LUT6 O6 pin)
--		I1 => delay_out(1), -- Input (tie to MUXF6 LO out or LUT6 O6 pin)
--		S => AM2_clk -- Input select to MUX
--	);

	AM_EN_OBUFDS_inst : OBUFDS
   generic map (
      IOSTANDARD => "DEFAULT")
   port map (
      O => SERIAL_OUT_p(1),     -- Diff_p output (connect directly to top-level port)
      OB => SERIAL_OUT_n(1),   -- Diff_n output (connect directly to top-level port)
      I => delay_out(1)      -- Buffer input 
   );
	
	CLOCK_OBUFDS_inst : OBUFDS
   generic map (
      IOSTANDARD => "DEFAULT")
   port map (
      O => SERIAL_OUT_p(2),     -- Diff_p output (connect directly to top-level port)
      OB => SERIAL_OUT_n(2),   -- Diff_n output (connect directly to top-level port)
--      I => delay_in(3)      -- Buffer input 
      I => serial_out_clk      -- Buffer input 
   );
	
--	BUFGMUX_inst : BUFGMUX
--   port map (
--      O => Out_clk,   -- 1-bit output: Clock buffer output
--      I0 => '0', -- 1-bit input: Clock buffer input (S=0)
--      I1 => serial_out_clk, -- 1-bit input: Clock buffer input (S=1)
--      S => send_enable    -- 1-bit input: Clock buffer select
--   );
--	
--	AM1_clk <= delay_out(3) xor delay_out(4);
--	AM2_clk <= delay_out(3) xor delay_out(5);
	
	--fifo interface
	FIFO_inst : Serial_FIFO
		port map (
			rst => fifo_clr,
			wr_clk => serial_fifo_wr_clk,--80MHz
			rd_clk => serial_fifo_wr_clk,--100MHz
			din => serial_fifo_wr_data,
			wr_en => serial_fifo_wr_en,
			rd_en => rd_en,
			dout => dout,
			full => open,
			valid => valid,
			prog_full => prog_full,
			empty => empty
		);
		
		FIFO_2_inst : Serial_FIFO_2
		port map (
			rst => fifo_clr,
			wr_clk => serial_fifo_rd_clk,--100MHz sys_clk_100M
			rd_clk => serial_fifo_rd_clk,--250MHz
			din 	=> dout,--X"0202",
			wr_en => wr_en_2,
--			wr_en => rd_en,
			rd_en => rd_en2,
			dout 	=> dout2,
			full 	=> open,
			valid => valid2,
			almost_full => open,
			prog_full => almost_full,
			empty => open
		);
	
	process (serial_fifo_wr_clk,sys_rst_n)
	begin  
		if sys_rst_n = '0' then
			serial_fifo_rdy	<= '1';
		elsif (serial_fifo_wr_clk'event and serial_fifo_wr_clk = '1') then
			serial_fifo_rdy		<= not prog_full;
		end if;
	end process;
	
	process (serial_fifo_rd_clk,sys_rst_n)
	begin  
		if sys_rst_n = '0' then
			fifo_2_rdy_rd_clk	<= '0';
		elsif (serial_fifo_rd_clk'event and serial_fifo_rd_clk = '1') then
			fifo_2_rdy_rd_clk <= (not almost_full);
		end if;
	end process;
	
	process (serial_fifo_wr_clk,sys_rst_n)
	begin  
		if sys_rst_n = '0' then
			fifo_2_rdy_wr_clk	<= '0';
		elsif (serial_fifo_wr_clk'event and serial_fifo_wr_clk = '1') then
			fifo_2_rdy_wr_clk <= fifo_2_rdy_rd_clk;
		end if;
	end process;
	
	process (serial_fifo_wr_clk,sys_rst_n)
	begin  
		if sys_rst_n = '0' then
			rd_en	<= '0';
		elsif (serial_fifo_wr_clk'event and serial_fifo_wr_clk = '1') then
			rd_en <= (not empty) and (not rd_en) and fifo_2_rdy_wr_clk;
--			rd_en <= (not rd_en) and fifo_2_rdy_wr_clk;
		end if;
	end process;
	
	process (serial_fifo_rd_clk,sys_rst_n)
	begin  
		if sys_rst_n = '0' then
			valid1_d1	<= '0';
			valid1_d2	<= '0';
			wr_en_2	<= '0';
		elsif (serial_fifo_rd_clk'event and serial_fifo_rd_clk = '1') then
			valid1_d1	<= valid;
			valid1_d2	<= valid1_d1;
			wr_en_2		<= not valid1_d2 and valid1_d1;
		end if;
	end process;
	
process (valid2,dout2,delay_AM1,test_signal_delay_reg,exp_running)
	begin  
		if(test_signal_delay_reg = '1') then
			if(valid2 = '1') then
				serial_in_reg(0)	<= x"0";--"0" & dout2(3) & "0" & dout2(0);
			else
				serial_in_reg(0)	<= x"F";
			end if;
		else
			if(exp_running = '1') then
				if(valid2 = '1') then
					serial_in_reg(0)	<= dout2(0) & dout2(0) & dout2(1) & dout2(1);--"0" & dout2(3) & "0" & dout2(0);
				else
					serial_in_reg(0)	<= delay_AM1(31 downto 28);
				end if;
			else
				serial_in_reg(0)	<= x"0";
			end if;
		end if;
	end process;
	--generate fifo read enable
	--if send_cnt = 11 and send_en = 1 read fisys_rst data, data active in next clock, then send_cnt chage to 00
	--if send_cnt = 10 and send_en = 1 read succesive data, data active in next clock, then send_cnt chage to 00
--	rd_en <= send_en;
	sys_rst_h	<= not sys_rst_n;
--	rd_en2 <= '1';
	process (serial_fifo_rd_clk,sys_rst_n)
	begin  
		if sys_rst_n = '0' then
			rd_en2	<= '0';
			test_signal_delay_reg	<= '0';
		elsif (serial_fifo_rd_clk'event and serial_fifo_rd_clk = '1') then
			rd_en2 <= send_en;
			test_signal_delay_reg	<= test_signal_delay;
		end if;
	end process;
	
	process (serial_fifo_rd_clk,sys_rst_n)
	begin  
		if sys_rst_n = '0' then
			send_en_AM_d1	<= '0';
			send_write_data	<= (others => '0');
		elsif (serial_fifo_rd_clk'event and serial_fifo_rd_clk = '1') then
			send_en_AM_d1	<= send_en_AM;
			if(valid2= '1') then
				send_write_data <= send_write_data(125 downto 0) & dout2;
			else
				if(send_en_AM_d1 = '0' and send_en_AM = '1') then
					send_write_data	<= (others => '0');
				end if;
			end if;
		end if;
	end process;
	
	send_write_back_data(63 downto 32) <= x"CC" & send_syn_cnt;
	process (serial_fifo_wr_clk,sys_rst_n)
	begin  
		if sys_rst_n = '0' then
			send_en_80M_d1	<= '0';
			send_en_80M_d2	<= '0';
			send_write_back_en	<= '0';
			send_syn_cnt	<= (others => '0');
			send_write_en_ds	<= (others => '0');
			send_write_prepare<= '0';
			send_write_back_data(31 downto 0)	<= (others => '0');
		elsif (serial_fifo_wr_clk'event and serial_fifo_wr_clk = '1') then
			send_en_80M_d1	<= send_en_AM and Alice_H_Bob_L;
			send_en_80M_d2	<= send_en_80M_d1;
			if(send_en_80M_d1 = '0' and send_en_80M_d2 = '1') then---falling edge
				send_write_en	<= '1';
			else
				send_write_en	<= '0';
			end if;
			
			if(send_en_80M_d1 = '1' and send_en_80M_d2 = '0') then---rising edge
				send_syn_cnt	<= send_syn_cnt + 1;
			elsif(exp_running = '0') then
				send_syn_cnt	<= (others => '0');
			end if;
			
			send_write_en_ds	<= send_write_en_ds(6 downto 0) & send_write_en;
			if(send_write_en_ds = 0) then
				send_write_prepare<= '0';
			else
				send_write_prepare<= '1';
			end if;
			
			if(send_write_en_ds(6) = '1') then
				send_write_back_data(31 downto 0) <= send_write_data(31 downto 0);
			elsif(send_write_en_ds(5) = '1') then
				send_write_back_data(31 downto 0) <= send_write_data(63 downto 32);
			elsif(send_write_en_ds(4) = '1') then
				send_write_back_data(31 downto 0) <= send_write_data(95 downto 64);
			elsif(send_write_en_ds(3) = '1') then
				send_write_back_data(31 downto 0) <= send_write_data(127 downto 96);
			end if;
			
			send_write_back_en	<= (send_write_en_ds(6) or send_write_en_ds(5) or send_write_en_ds(4) or send_write_en_ds(3)) and rnd_data_store_en;
		end if;
	end process;
	
end Behavioral;

