library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;


entity qtel is
	generic(
		qtel_base_addr			:	std_logic_vector(7 downto 0) := X"30";
		qtel_high_addr			:	std_logic_vector(7 downto 0) := X"32"
		);
	port(
		------ system clock and reset signal -------
	    sys_clk_160M 			: 	in	std_logic;
		sys_rst_n 				: 	in	std_logic;
		------ 80M clock and 8 channel signal input ------
		tdc_qtel_hit			:	in 	std_logic_vector(8 downto 0);
		--apd_fpga_hit_p		: 	in	std_logic_vector(9 downto 1);
		--apd_fpga_hit_n		:	in	std_logic_vector(9 downto 1);
		------ cpld module ------
		cpldif_qtel_addr		:	in	std_logic_vector(7 downto 0);
		cpldif_qtel_wr_en		:	in	std_logic;
		cpldif_qtel_rd_en		:	in	std_logic;
		cpldif_qtel_wr_data		:	in	std_logic_vector(31 downto 0);
		qtel_cpldif_rd_data		:	out	std_logic_vector(31 downto 0);
		------ output to counter module ------
		qtel_counter_match		:	out	std_logic_vector(7 downto 0)
	);
end qtel;


architecture Behavioral of qtel is

	------ synchronization of input signal from qtel_clk module into sys_clk module ------
	COMPONENT Qtel_Input_Fifo
		PORT (
			rst : IN STD_LOGIC;
			wr_clk : IN STD_LOGIC;
			rd_clk : IN STD_LOGIC;
			din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			wr_en : IN STD_LOGIC;
			rd_en : IN STD_LOGIC;
			dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			full : OUT STD_LOGIC;
			empty : OUT STD_LOGIC
		);
	END COMPONENT;
	
	------ fifo signal ------
	signal din					:	std_logic_vector(7 downto 0);
	signal wr_en				:	std_logic;
	signal rd_en				:	std_logic;
	signal dout					:	std_logic_vector(7 downto 0);
	signal full					:	std_logic;
	signal empty				: 	std_logic;
	------ system clock and reset generate ------	
	signal sys_clk				:	std_logic;	
	signal sys_rst				:	std_logic;
	------ 80M clock and 8 channel signal input ------
	signal qtel_input			:	std_logic_vector(7 downto 0);
	signal qtel_clk				:	std_logic;
	------ address select and generate 8 coincidence state ------
	signal addr_sel				: 	std_logic_vector(7 downto 0);
	signal qtel_reg_comm_ctrl1	:	std_logic_vector(31 downto 0);
	signal qtel_reg_comm_ctrl2	:	std_logic_vector(31 downto 0);
	signal qtel_comm_ctrl0		:	std_logic_vector(7 downto 0);
	signal qtel_comm_ctrl1		:	std_logic_vector(7 downto 0);
	signal qtel_comm_ctrl2		:	std_logic_vector(7 downto 0);
	signal qtel_comm_ctrl3		:	std_logic_vector(7 downto 0);
	signal qtel_comm_ctrl4		:	std_logic_vector(7 downto 0);
	signal qtel_comm_ctrl5		:	std_logic_vector(7 downto 0);
	signal qtel_comm_ctrl6		:	std_logic_vector(7 downto 0);
	signal qtel_comm_ctrl7		:	std_logic_vector(7 downto 0);
	------ synchronization of  input qtel_clk signal ------
	signal qtel_input_1d		:	std_logic_vector(7 downto 0);
	signal qtel_input_2d		:	std_logic_vector(7 downto 0);
	signal qtel_syn_fifoin		:	std_logic_vector(7 downto 0);
	signal qtel_syn_fifoout		:	std_logic_vector(7 downto 0);
	------ coincidence signal output ------
	signal qtel_comm_match		:	std_logic_vector(7 downto 0);
	------ read and write register ------
	signal rd_data_reg 			: 	std_logic_vector(31 downto 0);
	signal wr_data_reg 			: 	std_logic_vector(31 downto 0);
	signal cpldif_wr_en			:	std_logic;
	signal cpldif_rd_en			:	std_logic;

begin

	------ system clock and reset generate ------	
	sys_clk <= sys_clk_160M;
	sys_rst <= not sys_rst_n;
	------ 80M clock and 8 channel signal input ------
	qtel_input <= tdc_qtel_hit(8 downto 1);
	qtel_clk <= tdc_qtel_hit(0);
	------ generate 8 coincidence state ------
	qtel_comm_ctrl0 <= qtel_reg_comm_ctrl1(7 downto 0);
	qtel_comm_ctrl1 <= qtel_reg_comm_ctrl1(15 downto 8);
	qtel_comm_ctrl2 <= qtel_reg_comm_ctrl1(23 downto 16);
	qtel_comm_ctrl3 <= qtel_reg_comm_ctrl1(31 downto 24);
	qtel_comm_ctrl4 <= qtel_reg_comm_ctrl2(7 downto 0);
	qtel_comm_ctrl5 <= qtel_reg_comm_ctrl2(15 downto 8);
	qtel_comm_ctrl6 <= qtel_reg_comm_ctrl2(23 downto 16);
	qtel_comm_ctrl7 <= qtel_reg_comm_ctrl2(31 downto 24);
	------ synchronization of  input qtel_clk signal ------
	din <= qtel_syn_fifoin;
	qtel_syn_fifoout <= dout;
	------ coincidence signal output ------
	qtel_counter_match <= qtel_comm_match;
	------ read and write register ------
	qtel_cpldif_rd_data <= rd_data_reg;
	wr_data_reg <= cpldif_qtel_wr_data; 
	cpldif_wr_en <= cpldif_qtel_wr_en;
	cpldif_rd_en <= cpldif_qtel_rd_en;
	
	------------ input signal lvds to single-ended transformation ------------
	-- IBUFGDS_inst : IBUFGDS
	-- generic map (
		-- DIFF_TERM => FALSE, -- Differential Termination 
		-- IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for refernced I/O standards
		-- IOSTANDARD => "DEFAULT")
	-- port map (
		-- O => qtel_clk,  -- Clock buffer output
		-- I => apd_fpga_hit_p(1),  -- Diff_p clock buffer input (connect directly to top-level port)
		-- IB => apd_fpga_hit_n(1)-- Diff_n clock buffer input (connect directly to top-level port)
	-- );
	
	-- hitin_inst: FOR i in 2 to 9 generate
	-- begin
		-- IBUFDS_inst : IBUFDS
		-- generic map (
			-- DIFF_TERM => FALSE, -- Differential Termination 
			-- IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
			-- IOSTANDARD => "DEFAULT")
		-- port map (
			-- O => qtel_input(i-2),  -- Buffer output
			-- I => apd_fpga_hit_p(i),  -- Diff_p buffer input (connect directly to top-level port)
			-- IB => apd_fpga_hit_n(i) -- Diff_n buffer input (connect directly to top-level port)
		-- );
	-- end generate;
	------------ end signal transformation ------------
	
	------------ register manager ------------
	lock_addr : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
				addr_sel	<=	X"FF";
		elsif rising_edge(sys_clk) then
			if(cpldif_qtel_addr >= qtel_base_addr and cpldif_qtel_addr <=	qtel_high_addr) then
				addr_sel	<=	cpldif_qtel_addr	- qtel_base_addr;
			else
				addr_sel	<=	X"FF";
			end if;
		end if;
	end process;

	------ write register1: qtel_reg_comm_ctrl_wr ------
	qtel_reg_comm_ctrl_wr1 : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
        qtel_reg_comm_ctrl1	<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(addr_sel = X"00") then
				if(cpldif_wr_en = '1') then
					qtel_reg_comm_ctrl1	<=	wr_data_reg;
				else
					qtel_reg_comm_ctrl1	<=	qtel_reg_comm_ctrl1;
				end if;
			else
				qtel_reg_comm_ctrl1	<=	qtel_reg_comm_ctrl1;
			end if;
		end if;
	end process;

	------ write register2: qtel_reg_comm_ctrl_wr ------
	qtel_reg_comm_ctrl_wr2 : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
				qtel_reg_comm_ctrl2	<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(addr_sel = X"01") then
				if(cpldif_wr_en = '1') then
					qtel_reg_comm_ctrl2	<=	wr_data_reg;
				else
					qtel_reg_comm_ctrl2	<=	qtel_reg_comm_ctrl2;
				end if;
			else
				qtel_reg_comm_ctrl2	<=	qtel_reg_comm_ctrl2;
			end if;
		end if;
	end process;

	------ read register ------
	qtel_reg_comm_ctrl_rd : process(sys_rst,sys_clk)
	begin
		if(sys_rst = '1') then
				rd_data_reg	<=	(others => '0');
		elsif rising_edge(sys_clk) then
			if(addr_sel = X"00") then
				if(cpldif_rd_en = '1') then
					rd_data_reg	<=	(others => '1');
				else
					rd_data_reg	<=	(others => '0');
				end if;
			else 
				rd_data_reg	<=	(others => '0');
			end if;
		end if;
	end process;
	------------ end write read register control ------------
	
	------------ synchronization ------------
	qtel_syn_fifooutorization : process(sys_rst,qtel_clk)
	begin	
		if(sys_rst = '1') then
				qtel_syn_fifoin <= (others => '0');
				qtel_input_1d 	<=	(others => '0');
				qtel_input_2d 	<=	(others => '0');
		elsif rising_edge(qtel_clk)	then
				qtel_input_1d 	<= qtel_input;
				qtel_input_2d 	<= qtel_input_1d;
				qtel_syn_fifoin  <=	qtel_input_2d and (not qtel_input_1d); 
		end if;																					
	end process;
	
	qtel_input_fifo_rst : process(sys_rst)
	begin
		if(sys_rst = '1') then
				rd_en <= '1';
				wr_en <= '1';
		else
				rd_en <= '1';
				wr_en <= '1';
		end if;
	end process;
	------------ end synchronization ------------
	
	------------ coincidence ------------
	qtel_comm_match0 : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
				qtel_comm_match(0)	<='0';
		elsif rising_edge(sys_clk) then
			if(qtel_comm_ctrl0 = x"00") then
				qtel_comm_match(0)	<='0';
			elsif(qtel_comm_ctrl0 = qtel_syn_fifoout) then
				qtel_comm_match(0)	<='1';
			else 
				qtel_comm_match(0)	<='0';
			end if;
		end if;
	end process;

	qtel_comm_match1 : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
				qtel_comm_match(1)	<='0';
		elsif rising_edge(sys_clk) then
			if(qtel_comm_ctrl1 = x"00") then
				qtel_comm_match(1)	<='0';
			elsif(qtel_comm_ctrl1 = qtel_syn_fifoout) then
				qtel_comm_match(1)	<='1';
			else 
				qtel_comm_match(1)	<='0';
			end if;
		end if;
	end process;

	qtel_comm_match2 : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
				qtel_comm_match(2)	<='0';
		elsif rising_edge(sys_clk) then
			if(qtel_comm_ctrl2 = x"00") then
				qtel_comm_match(2)	<='0';
			elsif(qtel_comm_ctrl2 = qtel_syn_fifoout) then
				qtel_comm_match(2)	<='1';
			else 
				qtel_comm_match(2)	<='0';
			end if;
		end if;
	end process;

	qtel_comm_match3 : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
				qtel_comm_match(3)	<='0';
		elsif rising_edge(sys_clk) then
			if(qtel_comm_ctrl3 = x"00") then
				qtel_comm_match(3)	<='0';
			elsif(qtel_comm_ctrl3 = qtel_syn_fifoout) then
				qtel_comm_match(3)	<='1';
			else 
				qtel_comm_match(3)	<='0';
			end if;
		end if;
	end process;

	qtel_comm_match4 : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
				qtel_comm_match(4)	<='0';
		elsif rising_edge(sys_clk) then
			if(qtel_comm_ctrl4 = x"00") then
				qtel_comm_match(4)	<='0';
			elsif(qtel_comm_ctrl4 = qtel_syn_fifoout) then
				qtel_comm_match(4)	<='1';
			else 
				qtel_comm_match(4)	<='0';
			end if;
		end if;
	end process;

	qtel_comm_match5 : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
				qtel_comm_match(5)	<='0';
		elsif rising_edge(sys_clk) then
			if(qtel_comm_ctrl5 = x"00") then
				qtel_comm_match(5)	<='0';
			elsif(qtel_comm_ctrl5 = qtel_syn_fifoout) then
				qtel_comm_match(5)	<='1';
			else 
				qtel_comm_match(5)	<='0';
			end if;
		end if;
	end process;

	qtel_comm_match6 : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
				qtel_comm_match(6)	<='0';
		elsif rising_edge(sys_clk) then
			if(qtel_comm_ctrl6 = x"00") then
				qtel_comm_match(6)	<='0';
			elsif(qtel_comm_ctrl6 = qtel_syn_fifoout) then
				qtel_comm_match(6)	<='1';
			else 
				qtel_comm_match(6)	<='0';
			end if;
		end if;
	end process;

	qtel_comm_match7 : process(sys_clk,sys_rst)
	begin
		if(sys_rst = '1') then
				qtel_comm_match(7)	<='0';
		elsif rising_edge(sys_clk) then
			if(qtel_comm_ctrl7 = x"00") then
				qtel_comm_match(7)	<='0';
			elsif(qtel_comm_ctrl7 = qtel_syn_fifoout) then
				qtel_comm_match(7)	<='1';
			else 
				qtel_comm_match(7)	<='0';
			end if;
		end if;
	end process;
	------------ end coincidence ------------
	
	------ fifo Instantiation -------
	Inst_Qtel_Input_Fifo : Qtel_Input_Fifo
		PORT MAP (
		rst => sys_rst,
		wr_clk => qtel_clk,
		rd_clk => sys_clk,
		din => din,
		wr_en => wr_en,
		rd_en => rd_en,
		dout => dout,
		full => full,
		empty => empty
	);
	
end Behavioral;

