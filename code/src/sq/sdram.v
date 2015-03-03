`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module sdram(
nRESET,
nCLK_50,
//LMRCONF,
BEGIN_RAM,
//POWERDOWN_EN,
//REINITRAM_EN,//相关sdram配置数据和开始工作，powerdone和重新配置使能
W_BANK,W_ADDR_ROW,W_ADDR_COLUMN,R_BANK,R_ADDR_ROW,R_ADDR_COLUMN,DIN,DOUT,//读写的行列bank地址
INIT_DONE,ACTIONFORBID,//sdram初完成（上电后需00us才能工作），刷新禁止需时，用写WRITE_RAM_EN,WRITE_RAM_READY,WRITE_RAM_DONE,//读???僮???氖鼓埽迹瓿勺刺藕牛糜赾ontrol逻辑根据此状态控制sdram读写
READ_RAM_EN,READ_RAM_READY,READ_RAM_DONE,
WRITE_RAM_EN,WRITE_RAM_READY,WRITE_RAM_DONE,
//LOAD_RAM_EN,LOAD_RAM_DONE,//load mode register
DQ,DQML,DQMH,nWE,nCAS,nRAS,nCS,BA,A,
SDRAM2FifoReq,Fifo2SDramReq,
//LMRCONF_S,S_BANK,S_ADDR_ROW,S_ADDR_COLUMN,
//S_DATA,
//READ_S_EN,READ_S_READY,READ_S_DONE,//new for single read
CKE,
testsignal//sdram的输入输出管脚，数据（双向），地址，控制（输入） 
);
output [26:0] testsignal;
output SDRAM2FifoReq;
output Fifo2SDramReq;
reg Fifo2SDramReq;
reg SDRAM2FifoReq;
//from system
input	nRESET;
//input	[11:0]	LMRCONF;//////////////////////////////burst condition LMR configure
//input	[11:0]	LMRCONF_S;////////////////////////////signle read write condition LMR configure
input	BEGIN_RAM;/////////////////////////////////////sdram begin to work
//input	POWERDOWN_EN;//////////////////////////////////go into powerdown mode
//input	REINITRAM_EN;//////////////////////////////////re init sdram
input nCLK_50;///////////////////////////////////////50MHz, 25% period earlier than the RAM CLK
input	WRITE_RAM_EN;//////////////////////////////////topper module begin to write to sdram
input	READ_RAM_EN;///////////////////////////////////topper module begin to burst read from sdram
//input	READ_S_EN;/////////////////////////////////////topper module begin to single read from sdram
//input	LOAD_RAM_EN;///////////////////////////////////topper module begin to configure LMR
//data and address
input	[1:0]	W_BANK;//////////////////////////////////burst write address
input	[12:0]	W_ADDR_ROW;
input	[9:0]	W_ADDR_COLUMN;
input	[1:0]	R_BANK;//////////////////////////////////burst read address
input	[12:0]	R_ADDR_ROW;
input	[9:0]	R_ADDR_COLUMN;
//input	[1:0]	S_BANK;//////////////////////////////////single read address
//input	[11:0]	S_ADDR_ROW;
//input	[7:0]	S_ADDR_COLUMN;
input	[15:0]	DIN;//////////////////////////////////data read from sdram
output	[15:0]	DOUT;//////////////////////////////data write to sdram
//output	[31:0]	S_DATA;////////////////////////////single data from sdram
//control
output	READ_RAM_READY;/////////////////////////////burst read flag
output	READ_RAM_DONE;
output	WRITE_RAM_READY;////////////////////////////burst write flag
output	WRITE_RAM_DONE;
//output	READ_S_READY;///////////////////////////////single read flag
//output	READ_S_DONE;
output	INIT_DONE;//////////////////////////////////sdram init complete
//output	LOAD_RAM_DONE;//////////////////////////////this module LMR done
output	ACTIONFORBID;
//for sdram
//inout [31:0]	DQ;///////////////////////////////////sdram port
inout [15:0]	DQ;///////////////////////////////////sdram port
output	DQML;
output	DQMH;
output	nWE;
output	nCAS;
output	nRAS;
output	nCS;
output	[1:0]	BA;
output	[12:0]	A;
output	CKE;


reg	CKE;
//wire	[31:0]	DQ;
wire	[15:0]	DQ;
reg	DQML;
reg	DQMH;
reg	nWE;
reg	nCAS;
reg	nRAS;
reg	nCS;
reg	[1:0]	BA;
reg	[12:0]	A;
reg	DQ_OUTEN;
//reg	[31:0]	DQ_REG;
(* keep = "TRUE" *)
reg	[15:0]	DQ_REG;
reg	READ_RAM_READY;
reg	READ_RAM_DONE;
reg	WRITE_RAM_READY;
reg	WRITE_RAM_DONE;
reg	[15:0]	DOUT;
//reg	[15:0]	S_DATA;
//reg	READ_S_READY;
//reg	READ_S_DONE;
//reg	LOAD_RAM_DONE;

/////////////////////////////////////FSM for sdram state////////////////////////////////////
parameter	IDLE_0		= 8'b1,
				INIT_RAM		= 8'b10,
				AREF_RAM		= 8'b100,
				WRITE_RAM	= 8'b1000,
				READ_RAM		= 8'b10000,
				PD_RAM		=8'b100000,
				S_READ_RAM	=8'b1000000,
				LOAD_RAM		=8'b10000000;
reg	[7:0]	STATE_RAM;//总状态机，控制逻辑处于各种子状态机下
reg	[7:0]	NX_STATE_RAM;
reg	[6:0]	STATEMCR;
wire	BEGIN_INIT;
//wire	BEGIN_PD;
wire	BEGIN_AREF;
wire	BEGIN_WRB;
wire	BEGIN_RDB;
//wire	BEGIN_S;
//wire	BEGIN_LOAD;
assign	BEGIN_INIT = STATEMCR[0];///////////////////////init sdram
//assign	BEGIN_PD = STATEMCR[1];/////////////////////////powerdown
assign	BEGIN_AREF = STATEMCR[2];///////////////////////auto fresh
assign	BEGIN_WRB = STATEMCR[3];////////////////////////burst write
assign	BEGIN_RDB = STATEMCR[4];////////////////////////burst read
//assign	BEGIN_S = STATEMCR[5];//////////////////////////single read
//assign	BEGIN_LOAD=STATEMCR[6];/////////////////////////LMR
////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////FSM for initialization and load mode register//////////////////////
parameter	IDLE_1				= 10'b1,
				DELAYCOUNT_INIT	= 10'b10,
				PERCHARGE_INIT		= 10'b100,
				PERCHARGE_INIT_1	=	10'b1000,
				AREFRESH1_INIT		= 10'b10000,
				AREFRESH1_INIT_1	= 10'b100000,
				AREFRESH2_INIT		= 10'b1000000,
				AREFRESH2_INIT_1	= 10'b10000000,
				LMR_INIT				= 10'b100000000,
				LMR_INIT_1			= 10'b1000000000;
reg	[9:0]	STATE_INIT;
reg	[9:0]	NX_STATE_INIT;
reg	[14:0]	D_INIT_COUNTER;
reg	[2:0]	AREF1_INIT_COUNTER;
reg	[2:0]	AREF2_INIT_COUNTER;
reg	INIT_DONE;
//reg	[15:0]	DQ_1;
wire	[15:0]	DQ_1;
//reg	DQML_1;
//reg	DQMH_1;
wire	DQML_1;
wire	DQMH_1;
reg	nWE_1;
reg	nCAS_1;
reg	nRAS_1;
reg	nCS_1;
//reg	[1:0]	BA_1;
wire	[1:0]	BA_1;
reg	[12:0]	A_1;
reg	CKE_1;
//////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////FSM for auto refresh//////////////////////////////////
parameter	IDLE_3				=7'b1,
				PRECHARGE_AREF		=7'b10,
				PRECHARGE_AREF_1	=7'b100,
				AREFRESH_AREF		=7'b1000,
				AREFRESH_AREF_1	=7'b10000,
				WAITCOUNT_AREF		=7'b100000,
				FORBIDCOUNT_AREF	=7'b1000000;
reg	[6:0]	STATE_AREF;
reg	[6:0]	NX_STATE_AREF;
reg	[18:0]	REFRESH_AREF_COUNTER;
reg	[15:0]	DQ_3;
//reg	DQML_3;
//reg	DQMH_3;
wire	DQML_3;
wire	DQMH_3;
assign	DQML_3 = 1'b0;
assign	DQMH_3 = 1'b0;

reg	nWE_3;
reg	nCAS_3;
reg	nRAS_3;
reg	nCS_3;
reg	[1:0]	BA_3;
reg	[12:0]	A_3;
//reg	CKE_3;
wire	CKE_3;
assign	CKE_3 = 1'b1;
reg	ACTIONFORBID;//ahead of freshnow, let every action end
reg	FRESHNOW;//sdram into auto refresh 
//reg	WAKERAM;//wake up powerdone mode sdram to refresh
reg	[2:0]	AREF_COUNTER;
////////////////////////////////////////////////////////////////////////////////////
				
//////////////////////////////FSM for burst write///////////////////////////////////
parameter	IDLE_4			=10'b1,
				WAITACT_WRB		=10'b10,
				ACTIVE_WRB		=10'b100,
				ACTIVE_WRB_1	=10'b1000,
				WRITE_WRB		=10'b10000,
				WRITE_WRB_1		=10'b100000,//x20
				WAIT_PREC_WRB  =10'b1000000,
				APRECHARGE_WRB	=10'b10000000,//x80
				WAITNEXT_WRB	=10'b100000000;//x100
reg	[9:0]	STATE_WRB;
reg	[9:0]	NX_STATE_WRB;
reg	[9:0]	BL_WRB_COUNTER;
reg	[1:0]	APREC_WRB_COUNTER;
//reg	[15:0]	DQ_4;
wire	[15:0]	DQ_4;
reg	DQML_4;
reg	DQMH_4;
//wire	DQML_4;
//assign	DQML_4 = 1'b0;
//wire	DQMH_4;
//assign	DQMH_4 = 1'b0;
reg	nWE_4;
reg	nCAS_4;
reg	nRAS_4;
reg	nCS_4;
reg	[1:0]	BA_4;
reg	[12:0]	A_4;
//reg	CKE_4;
wire	CKE_4;
////////////////////////////////////////////////////////////////////////////////////
				
//////////////////////////////FSM for burst read////////////////////////////////////
parameter	IDLE_5			= 9'b1,
				WAITACT_RDB		=9'b10,
				ACTIVE_RDB		= 9'b100,
				ACTIVE_RDB_1	= 9'b1000,
				READ_RDB			= 9'b10000,
				CL_RDB			= 9'b100000,
				DATAIN_RDB		= 9'b1000000,
				WAITNEXT_RDB	= 9'b10000000,
				Precharge_RDB  = 9'b100000000;
reg	[8:0]	STATE_RDB;
reg	[8:0]	NX_STATE_RDB;
reg	[9:0]	BL_RDB_COUNTER;
//reg	[1:0]	CL_RDB_COUNTER;
reg	[2:0]	CL_RDB_COUNTER;
reg	DQML_5;
reg	DQMH_5;
reg	nWE_5;
reg	nCAS_5;
reg	nRAS_5;
reg	nCS_5;
reg	[1:0]	BA_5;
reg	[12:0]	A_5;
reg	CKE_5;
reg	[15:0]	DQ_5;    

reg DQ_OUTEN_1P;
reg DQML_1P		 ;
(* keep = "TRUE" *)
reg DQMH_1P;
reg nWE_1P			;
reg nCAS_1P		 ;
reg nRAS_1P		 ;
reg nCS_1P			;
reg [1:0] BA_1P			 ;
reg [12:0] A_1P				;
reg CKE_1P			;
reg [15:0] DQ_REG_1P	 ;
           
/////////////////////////////////////fro 80MHZ CLK
//parameter Inital_time_cnt = 10128; // 100us by 80MHZ
//parameter Time_forbid_cnt = 307904;//3.9ms- 12.5ns*8*512 by 80M
//parameter Time_fresh_cnt = 315904;//4ms- 12.5ns*8*512 by 80M
////////////////////////////////////for 40MHZ CLK
//parameter Inital_time_cnt = 20256; // 100us by 40MHZ
//parameter Time_forbid_cnt = 151904;//3.9ms- 25ns*8*512 by 40M
//parameter Time_fresh_cnt = 155904;//4ms- 25ns*8*512 by 40M
////////////////////////////////////for 60MHZ CLK
parameter Inital_time_cnt = 10256; // 100us by 60MHZ
parameter Time_forbid_cnt = 235668;//4ms-1200*clk- clk*8*512
parameter Time_fresh_cnt = 236868;//4ms- clk*8*512 
////////////////////////////////////for test bench
//parameter Inital_time_cnt = 10256; // 100us by 60MHZ
//parameter Time_forbid_cnt = 18800;//400us-1200*clk- clk*8*512
//parameter Time_fresh_cnt = 20000;//400us- clk*8*512 
////////////////////////////////////////////////////////////////////////////////////

assign testsignal[7:0] = STATE_RAM;
assign testsignal[16:8]= STATE_RDB;
assign testsignal[26:17] = STATE_WRB;

assign	DQ = DQ_OUTEN ? DQ_REG : 16'bz;//DQ是inout，需要做成三态，采用output使能


always@(posedge nCLK_50 or negedge nRESET)//ram state 1
begin
	if (!nRESET)
		STATE_RAM <= IDLE_0;
	else
		STATE_RAM <= NX_STATE_RAM;
end

always@(*)	//ram state 2
begin
	case(STATE_RAM)
		IDLE_0:	begin
			NX_STATE_RAM = BEGIN_RAM ? INIT_RAM : IDLE_0;
		end
		INIT_RAM:	begin
				if	(INIT_DONE)
					NX_STATE_RAM = AREF_RAM;
				else
					NX_STATE_RAM = INIT_RAM;
		end
		AREF_RAM:	begin
				if (WRITE_RAM_EN)
					NX_STATE_RAM = WRITE_RAM;
				else if (READ_RAM_EN)
					NX_STATE_RAM = READ_RAM;
				else
					NX_STATE_RAM = AREF_RAM;
		end
		WRITE_RAM:	begin
			NX_STATE_RAM = WRITE_RAM_DONE ? AREF_RAM : WRITE_RAM;
		end
		READ_RAM:	begin
			NX_STATE_RAM = READ_RAM_DONE ? AREF_RAM : READ_RAM;
		end
		default:	NX_STATE_RAM =AREF_RAM;
	endcase
end

always@(posedge nCLK_50 or negedge nRESET)
begin
	if(!nRESET)begin
		DQ_5 			<= 16'b0;
	end
	else begin
		DQ_5 			<= DQ;
	end
end
//always@(posedge nCLK_50 or negedge nRESET)
always@(negedge nCLK_50 or negedge nRESET)
begin
	if(!nRESET)begin
		DQ_OUTEN 	<= 1'b0;
		DQML 			<= 1'b0;
		DQMH	 		<= 1'b0;
		nWE 			<= 1'b1;
		nCAS 			<= 1'b1;
		nRAS 			<= 1'b1;
		nCS 			<= 1'b1;
		BA 				<= 2'b0;
		A 				<= 13'b0;
		CKE 			<= 1'b1;
		DQ_REG 		<= 16'b0;
	end
	else begin
		DQ_OUTEN 	<= DQ_OUTEN_1P;
		DQML 			<= DQML_1P		;
		DQMH	 		<= DQMH_1P		;
		nWE 			<= nWE_1P			;
		nCAS 			<= nCAS_1P		;
		nRAS 			<= nRAS_1P		;
		nCS 			<= nCS_1P			;
		BA 				<= BA_1P			;
		A 				<= A_1P				;
		CKE 			<= CKE_1P			;
		DQ_REG 		<= DQ_REG_1P	;
	end
end

always@(posedge nCLK_50 or negedge nRESET)
begin
	if(!nRESET)begin
		STATEMCR 	<= 7'b0;
		DQ_OUTEN_1P  	<= 1'b0;
		DQML_1P		  	<= 1'b0;
		DQMH_1P		  	<= 1'b0;
		nWE_1P				<= 1'b1;
		nCAS_1P		  	<= 1'b1;
		nRAS_1P		  	<= 1'b1;
		nCS_1P				<= 1'b1;
		BA_1P			  	<= 2'b0;
		A_1P					<= 13'b0;
		CKE_1P				<= 1'b1;
		DQ_REG_1P	  	<= 16'b0;
//		DQ_5 			<= 16'b0;
	end
	else if (STATE_RAM == IDLE_0) begin
		STATEMCR 	<= 7'b0;
		DQ_OUTEN_1P  	<= 1'b0;
		DQML_1P		  	<= 1'b0;
		DQMH_1P		  	<= 1'b0;
		nWE_1P				<= 1'b1;
		nCAS_1P		  	<= 1'b1;
		nRAS_1P		  	<= 1'b1;
		nCS_1P				<= 1'b1;
		BA_1P			  	<= 2'b0;
		A_1P					<= 13'b0;
		CKE_1P				<= 1'b1;
		DQ_REG_1P	  	<= 16'b0;
//		DQ_5 			<= 16'b0;
	end
	else if (STATE_RAM == INIT_RAM) begin
		STATEMCR 	<= 7'b1;
		DQ_OUTEN_1P  	<= 1'b1;
		DQML_1P		  	<= DQML_1;
		DQMH_1P		  	<= DQMH_1;
		nWE_1P				<= nWE_1;
		nCAS_1P		  	<= nCAS_1;
		nRAS_1P		  	<= nRAS_1;
		nCS_1P				<= nCS_1;
		BA_1P			  	<= BA_1;
		A_1P					<= A_1;
		CKE_1P				<= CKE_1;
		DQ_REG_1P	  	<= DQ_1;
//		DQ_5 			<= 16'b0;
	end
	else if (STATE_RAM == AREF_RAM) begin
		STATEMCR[2] <= 1'b1;		
		DQ_OUTEN_1P  		<= 1'b1;
		DQML_1P		  		<= DQML_3;
		DQMH_1P		  		<= DQMH_3;
		nWE_1P					<= nWE_3;
		nCAS_1P		  		<= nCAS_3;
		nRAS_1P		  		<= nRAS_3;
		nCS_1P					<= nCS_3;
		BA_1P			  		<= BA_3;
		A_1P						<= A_3;
		CKE_1P					<= CKE_3;
		DQ_REG_1P	  		<= DQ_3;
//		DQ_5 				<= 16'b0;
	end
	else if (STATE_RAM == WRITE_RAM) begin
		STATEMCR[4:2] <= 3'b11;
		if ( FRESHNOW==1'b1 ) begin
			
			DQ_OUTEN_1P  	<= 1'b1;
			DQML_1P		  	<= DQML_3;
			DQMH_1P		  	<= DQMH_3;
			nWE_1P				<= nWE_3;
			nCAS_1P		  	<= nCAS_3;
			nRAS_1P		  	<= nRAS_3;
			nCS_1P				<= nCS_3;
			BA_1P			  	<= BA_3;
			A_1P					<= A_3;
			CKE_1P				<= CKE_3;
			DQ_REG_1P	  	<= DQ_3;
//			DQ_5 			<= 16'b0;
		end
		else begin
			
			DQ_OUTEN_1P  	<= 1'b1;
			DQML_1P		  	<= DQML_4;
			DQMH_1P		  	<= DQMH_4;
			nWE_1P				<= nWE_4;
			nCAS_1P		  	<= nCAS_4;
			nRAS_1P		  	<= nRAS_4;
			nCS_1P				<= nCS_4;
			BA_1P			  	<= BA_4;
			A_1P					<= A_4;
			CKE_1P				<= CKE_4;
			DQ_REG_1P	  	<= DQ_4;
//			DQ_5 			<= 16'b0;
		end
	end
	else if (STATE_RAM == READ_RAM) begin	
		STATEMCR[4:2] <= 3'b101;//auto refresh is running
		if(FRESHNOW==1'b1)//此时需要刷新，将sdram输入端口交给刷新子状态机
			begin
			
			DQ_OUTEN_1P  	<= 1'b1;
			DQML_1P		  	<= DQML_3;
			DQMH_1P		  	<= DQMH_3;
			nWE_1P				<= nWE_3;
			nCAS_1P		  	<= nCAS_3;
			nRAS_1P		  	<= nRAS_3;
			nCS_1P				<= nCS_3;
			BA_1P			  	<= BA_3;
			A_1P					<= A_3;
			CKE_1P				<= CKE_3;
			DQ_REG_1P	  	<= DQ_3;
//			DQ_5 			<= 16'b0;
			end
		else begin
			
//			DQ_5 			<= DQ;
			DQ_OUTEN_1P  	<= 1'b0;
			DQML_1P		  	<= DQML_5;
			DQMH_1P		  	<= DQMH_5;
			nWE_1P				<= nWE_5;
			nCAS_1P		  	<= nCAS_5;
			nRAS_1P		  	<= nRAS_5;
			nCS_1P				<= nCS_5;
			BA_1P			  	<= BA_5;
			A_1P					<= A_5;
			CKE_1P				<= CKE_5;
			DQ_REG_1P	  	<= 16'b0;
		end
	end
	else begin
		STATEMCR 	<= 7'b0;
		DQ_OUTEN_1P  	<= 1'b0;
		DQML_1P		  	<= 1'b0;
		DQMH_1P		  	<= 1'b0;
		nWE_1P				<= 1'b1;
		nCAS_1P		  	<= 1'b1;
		nRAS_1P		  	<= 1'b1;
		nCS_1P				<= 1'b1;
		BA_1P			  	<= 2'b0;
		A_1P					<= 13'b0;
		CKE_1P				<= 1'b1;
		DQ_REG_1P	  	<= 16'b0;
//		DQ_5 			<= 16'b0;
	end	
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always@(posedge nCLK_50 or negedge nRESET)//initialization and load mode register state 1
begin
	if (!nRESET)
		STATE_INIT <= IDLE_1;
	else
		STATE_INIT <= NX_STATE_INIT;
end

always@(posedge nCLK_50 or negedge nRESET)//把相关计数器提取到组合逻辑外，防止成为latch 
begin
	if(!nRESET)
		begin
		D_INIT_COUNTER 	<= 15'b0;
		AREF1_INIT_COUNTER <= 3'b0;
		AREF2_INIT_COUNTER <= 3'b0;
		end
	else if(STATE_INIT == DELAYCOUNT_INIT)
		D_INIT_COUNTER <= D_INIT_COUNTER + 1'b1;//13'b1001110001000
	else if(STATE_INIT==AREFRESH1_INIT)
		AREF1_INIT_COUNTER <= 3'b0;
	else if(STATE_INIT==AREFRESH1_INIT_1)
		AREF1_INIT_COUNTER <= AREF1_INIT_COUNTER+1'b1;
	else if(STATE_INIT==AREFRESH2_INIT)
		AREF2_INIT_COUNTER <= 3'b0;
	else if(STATE_INIT==AREFRESH2_INIT_1)
		AREF2_INIT_COUNTER <= AREF2_INIT_COUNTER+1'b1;
	else if(STATE_INIT ==IDLE_1)
		begin
		D_INIT_COUNTER 		<= 15'b0;
		AREF1_INIT_COUNTER 	<= 3'b0;
		AREF2_INIT_COUNTER 	<= 3'b0;
		end
end

always@(*)//initialization state 2
begin
	case(STATE_INIT)
		IDLE_1:	begin
			NX_STATE_INIT = BEGIN_INIT ? DELAYCOUNT_INIT : IDLE_1;
		end
		DELAYCOUNT_INIT:	begin//wait for 100us@100MHz,200us@50MHz
//			NX_STATE_INIT = (D_INIT_COUNTER == 15'b10011110010000) ? PERCHARGE_INIT : DELAYCOUNT_INIT;//13'b1001110001000，100us用于init 
//			NX_STATE_INIT = (D_INIT_COUNTER == 10128) ? PERCHARGE_INIT : DELAYCOUNT_INIT;//13'b1001110001000，100us用于init 
			NX_STATE_INIT = (D_INIT_COUNTER == Inital_time_cnt) ? PERCHARGE_INIT : DELAYCOUNT_INIT;//13'b1001110001000，100us用于init 
		end									///15'b10011100010000
		PERCHARGE_INIT:	begin//for percharge
			NX_STATE_INIT=PERCHARGE_INIT_1;
		end
		PERCHARGE_INIT_1:	begin
			NX_STATE_INIT =AREFRESH1_INIT;
		end
		AREFRESH1_INIT:	begin//auto refresh 1st time
			NX_STATE_INIT = AREFRESH1_INIT_1;
		end
		AREFRESH1_INIT_1:	begin
			NX_STATE_INIT=(AREF1_INIT_COUNTER==3'b110)?AREFRESH2_INIT:AREFRESH1_INIT_1;
		end
		AREFRESH2_INIT:	begin//auto refresh 2nd time
			NX_STATE_INIT = AREFRESH2_INIT_1;
		end
		AREFRESH2_INIT_1:	begin
			NX_STATE_INIT=(AREF2_INIT_COUNTER==3'b110)?LMR_INIT:AREFRESH2_INIT_1;
		end
		LMR_INIT:	begin
			NX_STATE_INIT = LMR_INIT_1;
		end
		LMR_INIT_1:	begin
			NX_STATE_INIT = LMR_INIT_1;//初始化完成，此状??机滞留??状?证INIT_DONE=1'b1
		end
		default:	NX_STATE_INIT = IDLE_1;
	endcase
end

assign DQ_1   = 16'b0;
assign DQML_1 = 1'b0;
assign DQMH_1 = 1'b0;
assign BA_1   = 2'b0;
always@(posedge nCLK_50 or negedge nRESET)//initialization state 2
begin
	if (!nRESET) begin
//		DQ_1 			<= 16'b0;
//		DQML_1 		<= 1'b0;
//		DQMH_1 		<= 1'b0;
		CKE_1 		<= 1'b0;
		nCS_1 		<= 1'b1;
		nCAS_1 		<= 1'b1;
		nRAS_1 		<= 1'b1;
		nWE_1 		<= 1'b1;//commond inhibit
//		BA_1 			<= 2'b0;
		A_1 			<= 12'b0;
		INIT_DONE <= 1'b0;
	end
	else 
	case(STATE_INIT)
		IDLE_1:	begin
//			DQ_1 				<= 16'b0;
//			DQML_1 			<= 1'b0;
//			DQMH_1 			<= 1'b0;
			CKE_1  			<= 1'b0;
			nCS_1  			<= 1'b1;
			nCAS_1 			<= 1'b1;
			nRAS_1 			<= 1'b1;
			nWE_1 			<= 1'b1;//commond inhibit
//			BA_1  			<= 2'b0;
			A_1   			<= 12'b0;
			INIT_DONE 	<= 1'b0;
		end
		DELAYCOUNT_INIT:	begin//wait for 100us@100MHz,200us@50MHz
			//CKE_1 <= 1'b0;
			nCS_1 	<= 1'b0;
			nCAS_1 	<= 1'b1;
			nRAS_1 	<= 1'b1;
			nWE_1 	<= 1'b1;//NOP
//			CKE_1 <= (D_INIT_COUNTER > 15'b10011110001110) ? 1:0;	///15'b10011100001110
//			CKE_1 	<= (D_INIT_COUNTER > 10126) ? 1:0;	///15'b10011100001110
			CKE_1 	<= (D_INIT_COUNTER > (Inital_time_cnt-2)) ? 1:0;	///15'b10011100001110
			A_1 			<= 12'b0;
			INIT_DONE <= 1'b0;
		end									///15'b10011100010000
		PERCHARGE_INIT:	begin//for percharge
			CKE_1 	<= 1'b1;
			nCS_1 	<= 1'b0;
			nCAS_1 	<= 1'b1;
			nRAS_1 	<= 1'b0;
			nWE_1 	<= 1'b0;//percharge cmd
			A_1[10] <= 1'b1;//percharge all banks
			INIT_DONE <= 1'b0;
		end
		PERCHARGE_INIT_1:	begin
			CKE_1 	<= 1'b1;
			nCS_1 	<= 1'b0;
			nCAS_1 	<= 1'b1;
			nRAS_1 	<= 1'b1;
			nWE_1 	<= 1'b1;//NOP
			A_1 			<= 12'b0;
			INIT_DONE <= 1'b0;
		end
		AREFRESH1_INIT:	begin//auto refresh 1st time
			CKE_1 	<= 1'b1;
			nCS_1 	<= 1'b0;
			nCAS_1 	<= 1'b0;
			nRAS_1 	<= 1'b0;
			nWE_1 	<= 1'b1;//auto refresh cmd
			A_1 			<= 12'b0;
			INIT_DONE <= 1'b0;
		end
		AREFRESH1_INIT_1:	begin
			CKE_1 	<= 1'b1;
			nCS_1 	<= 1'b0;
			nCAS_1 	<= 1'b1;
			nRAS_1 	<= 1'b1;
			nWE_1 	<= 1'b1;//NOP
			A_1 			<= 12'b0;
			INIT_DONE <= 1'b0;
		end
		AREFRESH2_INIT:	begin//auto refresh 2nd time
			CKE_1 	<= 1'b1;
			nCS_1 	<= 1'b0;
			nCAS_1 	<= 1'b0;
			nRAS_1 	<= 1'b0;
			nWE_1 	<= 1'b1;//auto refresh
			A_1 			<= 12'b0;
			INIT_DONE <= 1'b0;
		end
		AREFRESH2_INIT_1:	begin
			CKE_1 	<= 1'b1;
			nCS_1 	<= 1'b0;
			nCAS_1 	<= 1'b1;
			nRAS_1 	<= 1'b1;
			nWE_1 	<= 1'b1;//NOP
			A_1 			<= 12'b0;
			INIT_DONE <= 1'b0;
		end
		LMR_INIT:	begin
			CKE_1 	<= 1'b1;
			nCS_1 	<= 1'b0;
			nCAS_1 	<= 1'b0;
			nRAS_1 	<= 1'b0;
			nWE_1  	<= 1'b0;//load mode register
			A_1    	<= 12'b100111;//LMRCONF;
			INIT_DONE <= 1'b0;
		end
		LMR_INIT_1:	begin
			CKE_1 		<= 1'b1;
			nCS_1 		<= 1'b0;
			nCAS_1 		<= 1'b1;
			nRAS_1 		<= 1'b1;
			nWE_1 		<= 1'b1;//NOP
			A_1 			<= 12'b0;
			INIT_DONE <= 1'b1;
		end
		default:	begin
//			DQ_1 			<= 16'b0;
//			DQML_1 		<= 1'b0;
//			DQMH_1 		<= 1'b0;
			CKE_1 		<= 1'b1;
			nCS_1 		<= 1'b1;
			nCAS_1 		<= 1'b1;
			nRAS_1 		<= 1'b1;
			nWE_1	 		<= 1'b1;//commond inhibit
//			BA_1  		<= 2'b0;
			A_1 			<= 12'b0;
			INIT_DONE <= 1'b0;
		end
	endcase
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg [9:0] AfreshCounter;
always@(posedge nCLK_50 or negedge nRESET)//auto refresh state 1
begin
	if (!nRESET)
		STATE_AREF <= IDLE_3;
	else
		STATE_AREF <= NX_STATE_AREF;
end

always@(posedge nCLK_50 or negedge nRESET)
begin
	if(!nRESET)
		begin
		AREF_COUNTER			<=0;
		REFRESH_AREF_COUNTER <= 9'b0;//begin to wait 7.81us-6*20ns(for a refresh)
		AfreshCounter <= 0;
		end
	else if(STATE_AREF==PRECHARGE_AREF)
		AfreshCounter <= 0;
	else if(STATE_AREF==AREFRESH_AREF)
	begin
		AREF_COUNTER	<=0;
		AfreshCounter	<=AfreshCounter+1;
	end
	else if(STATE_AREF==AREFRESH_AREF_1)
		begin
		AREF_COUNTER			<=AREF_COUNTER+1;
		REFRESH_AREF_COUNTER <= 9'b0;
		end
	else if((STATE_AREF==WAITCOUNT_AREF)||(STATE_AREF==FORBIDCOUNT_AREF))
		begin
		AREF_COUNTER			<=0;
		REFRESH_AREF_COUNTER <= REFRESH_AREF_COUNTER + 1'b1;
		end
	else if(STATE_AREF==IDLE_3)
		begin
		AREF_COUNTER			<=0;
		REFRESH_AREF_COUNTER <= 9'b0;
		end
end

always@(*)//auto refresh state 2,every 4ms refresh 512 times,
begin
	case(STATE_AREF)
		IDLE_3:	begin
			NX_STATE_AREF = (BEGIN_AREF) ? WAITCOUNT_AREF : IDLE_3;
		end
		PRECHARGE_AREF:	begin
			NX_STATE_AREF = PRECHARGE_AREF_1;
		end
		PRECHARGE_AREF_1:	begin
			NX_STATE_AREF = AREFRESH_AREF;
		end
		AREFRESH_AREF:	begin
			NX_STATE_AREF = AREFRESH_AREF_1;
		end
		AREFRESH_AREF_1:	begin
//			NX_STATE_AREF =(AREF_COUNTER==3'b110)?((AfreshCounter==9'b100000000)?WAITCOUNT_AREF:AREFRESH_AREF):AREFRESH_AREF_1;//66ns at least
			NX_STATE_AREF =(AREF_COUNTER==3'b110)?((AfreshCounter==512)?WAITCOUNT_AREF:AREFRESH_AREF):AREFRESH_AREF_1;//66ns at least          //51200ns needed for once
		end															
		WAITCOUNT_AREF:	begin
//			FRESHNOW=1'b0;
//				if (REFRESH_AREF_COUNTER == 19'b1011111001101110000)////3.9ms by 100MHZ,4us before to forbid read and write enable，提前4us发出信号之后不许开始读写操作 
//				if (REFRESH_AREF_COUNTER == 19'b1001100001011000000)////3.9ms by 80MHZ,4us before to forbid read and write enable，提前4us发出信号之后不许开始读写操作 
//				if (REFRESH_AREF_COUNTER == 307904)////3.9ms-51.2us by 80MHZ,4us before to forbid read and write enable，提前4us发出信号之后不许开始读写操作 
				if (REFRESH_AREF_COUNTER == Time_forbid_cnt)////3.9ms-51.2us by 80MHZ,4us before to forbid read and write enable，提前4us发出信号之后不许开始读写操作 
					NX_STATE_AREF = FORBIDCOUNT_AREF;				
				else
					NX_STATE_AREF = WAITCOUNT_AREF;
		end
		FORBIDCOUNT_AREF:	begin
//			ACTIONFORBID=1'b1;
//				if (REFRESH_AREF_COUNTER == 19'b1100001101010000000)//4.0ms by 100mhz,begin to wait 平均一次刷新需要
//				if (REFRESH_AREF_COUNTER == 19'b1101000111110110000)
//				if (REFRESH_AREF_COUNTER == 19'b1001110001000000000)//4.0ms by 80MHZ
//				if (REFRESH_AREF_COUNTER == 315904)//4.0ms-51.2us by 80MHZ
				if (REFRESH_AREF_COUNTER == Time_fresh_cnt)//4.0ms-51.2us by 80MHZ
					NX_STATE_AREF = PRECHARGE_AREF;					//4.0ms
				else
					NX_STATE_AREF = FORBIDCOUNT_AREF;
		end
		default:	NX_STATE_AREF = IDLE_3;
	endcase
end

always@(posedge nCLK_50 or negedge nRESET)//auto refresh state 2,every 7.81us
begin
	if(!nRESET) begin
		DQ_3 					<= 16'b0;
//		DQML_3 				<= 1'b0;
//		DQMH_3 				<= 1'b0;
//		CKE_3  				<= 1'b1;
		nCS_3  				<= 1'b0;
		nCAS_3 				<= 1'b1;
		nRAS_3 				<= 1'b1;
		nWE_3 				<= 1'b1;//commond inhibit
		BA_3 					<= 2'b0;
		A_3 					<= 13'b0;
		ACTIONFORBID	<=1'b0;
		FRESHNOW			<=1'b0;
	end
	else 
		case(STATE_AREF)
			IDLE_3:	begin
				DQ_3 					<= 16'b0;
//				DQML_3 				<= 1'b0;
//				DQMH_3 				<= 1'b0;
//				CKE_3 				<= 1'b1;
				nCS_3 				<= 1'b1;
				nCAS_3 				<= 1'b1;
				nRAS_3 				<= 1'b1;
				nWE_3 				<= 1'b1;//commond inhibit
				BA_3 					<= 2'b0;
				A_3 					<= 13'b0;
				ACTIONFORBID	<=1'b0;
				FRESHNOW			<=1'b0;
			end
			PRECHARGE_AREF:	begin
//				CKE_3 				<= 1'b1;
				nCS_3 				<= 1'b0;
				nCAS_3 				<= 1'b1;
				nRAS_3 				<= 1'b0;
				nWE_3 				<= 1'b0;//percharge cmd
				A_3[10] 			<= 1'b1;//percharge all banks
				ACTIONFORBID	<=1'b1;
				FRESHNOW			<=1'b1;
			end
			PRECHARGE_AREF_1:	begin
//				CKE_3 				<= 1'b1;
				nCS_3 				<= 1'b0;
				nCAS_3 				<= 1'b1;
				nRAS_3 				<= 1'b1;
				nWE_3 				<= 1'b1;//NOP
				ACTIONFORBID	<=1'b1;
				FRESHNOW			<=1'b1;
			end
			AREFRESH_AREF:	begin
//				CKE_3 				<= 1'b1;
				nCS_3 				<= 1'b0;
				nCAS_3 				<= 1'b0;
				nRAS_3 				<= 1'b0;
				nWE_3 				<= 1'b1;//auto refresh cmd
				ACTIONFORBID	<=1'b1;
				FRESHNOW			<=1'b1;
			end
			AREFRESH_AREF_1:	begin
//				CKE_3 				<= 1'b1;
				nCS_3 				<= 1'b0;
				nCAS_3 				<= 1'b1;
				nRAS_3 				<= 1'b1;
				nWE_3 				<= 1'b1;//NOP
				ACTIONFORBID	<=1'b1;
				FRESHNOW			<=1'b1;
			end															
			WAITCOUNT_AREF:	begin
				nCS_3 				<= 1'b0;
				nCAS_3 				<= 1'b1;
				nRAS_3 				<= 1'b1;
				nWE_3 				<= 1'b1;//NOP
				FRESHNOW			<=1'b0;
				ACTIONFORBID	<=1'b0;
			end
			FORBIDCOUNT_AREF:	begin
				nCS_3 				<= 1'b0;
				nCAS_3 				<= 1'b1;
				nRAS_3 				<= 1'b1;
				nWE_3 				<= 1'b1;//NOP
				FRESHNOW			<=1'b0;
				ACTIONFORBID	<=1'b1;
			end
			default:	begin
				DQ_3 					<= 16'b0;
//				DQML_3 				<= 1'b0;
//				DQMH_3 				<= 1'b0;
//				CKE_3 				<= 1'b1;
				nCS_3 				<= 1'b0;
				nCAS_3 				<= 1'b1;
				nRAS_3 				<= 1'b1;
				nWE_3 				<= 1'b1;//commond inhibit
				BA_3 					<= 2'b0;
				A_3 					<= 12'b0;
				ACTIONFORBID	<=1'b0;
				FRESHNOW			<=1'b0;
			end
		endcase
end
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////			
always@(posedge nCLK_50 or negedge nRESET)//burst write state 1
begin
	if (!nRESET)
		STATE_WRB <= IDLE_4;
	else
		STATE_WRB <= NX_STATE_WRB;
end

always@(posedge nCLK_50 or negedge nRESET)
begin
	if (!nRESET)
		begin
		BL_WRB_COUNTER 	<= 10'b0;
		APREC_WRB_COUNTER <= 2'b0;
		end
	else if(STATE_WRB==WRITE_WRB)
		BL_WRB_COUNTER <= 10'b0;
	else if(STATE_WRB==WRITE_WRB_1)
		begin
		BL_WRB_COUNTER <= BL_WRB_COUNTER + 1'b1;
		APREC_WRB_COUNTER <= 2'b0;
		end
	else if(STATE_WRB==APRECHARGE_WRB)
		APREC_WRB_COUNTER <= APREC_WRB_COUNTER + 1'b1;
	else if(STATE_WRB==IDLE_4)
		begin
		BL_WRB_COUNTER 	<= 10'b0;
		APREC_WRB_COUNTER <= 2'b0;
		end
end

always@(*)//burst write state 2,without auto precharge
begin
	case(STATE_WRB)
		IDLE_4:	begin
			NX_STATE_WRB = BEGIN_WRB?WAITACT_WRB: IDLE_4;
		end
		WAITACT_WRB:	begin
			NX_STATE_WRB = ACTIONFORBID?WAITACT_WRB:ACTIVE_WRB;
		end
		ACTIVE_WRB:	begin
			NX_STATE_WRB = ACTIVE_WRB_1;
		end
		ACTIVE_WRB_1:	begin
			NX_STATE_WRB = WRITE_WRB;
		end
		WRITE_WRB:	begin
			NX_STATE_WRB =WRITE_WRB_1;
		end
		WRITE_WRB_1:	begin
//				if(BL_WRB_COUNTER==10'b1111111110)//b11111110	254*10ns=2.54us
				if(BL_WRB_COUNTER==1022)//b11111110	254*10ns=2.54us
					begin
//					NX_STATE_WRB = APRECHARGE_WRB;
					NX_STATE_WRB = WAIT_PREC_WRB;
					end
				else
					NX_STATE_WRB = WRITE_WRB_1;
		end
		WAIT_PREC_WRB: begin
			NX_STATE_WRB = APRECHARGE_WRB;
		end
		APRECHARGE_WRB:	begin
			NX_STATE_WRB = WAITNEXT_WRB;		
		end
		WAITNEXT_WRB:	begin		
			NX_STATE_WRB =WRITE_RAM_EN?WAITACT_WRB:WAITNEXT_WRB;
		end
		default:	NX_STATE_WRB = IDLE_4;
	endcase
end

assign DQ_4 = DIN;
assign CKE_4 = 1'b1;

always@(posedge nCLK_50 or negedge nRESET)//burst write state 3,auto precharge
begin
	if(!nRESET)begin
		DQML_4 					<= 1'b0;
		DQMH_4 					<= 1'b0;
//		CKE_4 					<=	 1'b1;
		nCS_4 					<=	 1'b1;
		nCAS_4 					<= 1'b1;
		nRAS_4 					<= 1'b1;
		nWE_4 					<=	 1'b1;//commond inhibit
		BA_4 						<= 	2'b0;
		A_4 						<= 13'b0;
		WRITE_RAM_READY <= 1'b0;
		WRITE_RAM_DONE 	<= 1'b0;
		Fifo2SDramReq 	<=0;
//		DQ_4						<=16'b0;
	end
	else if(STATE_WRB == IDLE_4)begin
			DQML_4 						<= 1'b0;
			DQMH_4 						<= 1'b0;
//			CKE_4  						<= 1'b1;
			nCS_4  						<= 1'b1;
			nCAS_4 						<= 1'b1;
			nRAS_4 						<= 1'b1;
			nWE_4 						<= 1'b1;//commond inhibit
			BA_4 							<= 2'b0;
			A_4 							<= 13'b0;
			Fifo2SDramReq 		<=0;
			WRITE_RAM_READY 	<= 1'b0;
			WRITE_RAM_DONE 		<= 1'b0;
		end
	else if(STATE_WRB == WAITACT_WRB)begin
//		WAITACT_WRB:	begin
			DQML_4 						<= 1'b0;
			DQMH_4 						<= 1'b0;
//			CKE_4  						<= 1'b1;
			nCS_4  						<= 1'b1;
			nCAS_4 						<= 1'b1;
			nRAS_4 						<= 1'b1;
			nWE_4 						<= 1'b1;//commond inhibit
			BA_4              <= 2'b0;
			A_4               <= 13'b0;
			WRITE_RAM_READY 	<= 1'b0;
			WRITE_RAM_DONE  	<= 1'b0;
			Fifo2SDramReq 		<=0;
//			DQ_4							<=16'b0;
		end
	else if(STATE_WRB == ACTIVE_WRB)begin
			DQML_4 						<= 1'b0;
			DQMH_4 						<= 1'b0;
			nCS_4 						<= 1'b0;
			nCAS_4 						<= 1'b1;
			nRAS_4 						<= 1'b0;
			nWE_4 						<= 1'b1;//active
//			CKE_4 						<= 1'b1;
//			DQML_4 						<= 1'b0;
//			DQMH_4 						<= 1'b0;
			BA_4 							<= W_BANK;
			A_4 							<= W_ADDR_ROW;
			WRITE_RAM_READY 	<= 1'b1;
		end
	else if(STATE_WRB == ACTIVE_WRB_1)begin
			DQML_4 						<= 1'b0;
			DQMH_4 						<= 1'b0;
			nCS_4 						<= 1'b0;
			nCAS_4 						<= 1'b1;
			nRAS_4 						<= 1'b1;
			nWE_4 						<= 1'b1;//NOP
			BA_4 						<= 	2'b0;
			A_4 						<= 13'b0;
			WRITE_RAM_READY <= 1'b0;
			WRITE_RAM_DONE 	<= 1'b0;
			Fifo2SDramReq 	<=0;
//			DQ_4						<=16'b0;
		end
	else if(STATE_WRB == WRITE_WRB)begin
			DQML_4 						<= 1'b0;
			DQMH_4 						<= 1'b0;
			nCS_4  						<= 1'b0;
			nCAS_4 						<= 1'b0;
			nRAS_4 						<= 1'b1;
			nWE_4 						<= 1'b0;//write
			BA_4  						<= W_BANK;
			Fifo2SDramReq 		<=1;
			A_4[9:0]					<= 0;
			A_4[10] 					<= 1'b0;//disable auto precharge
//			DQ_4 							<= DIN;
		end
	else if(STATE_WRB == WRITE_WRB_1)begin
			DQML_4 						<= 1'b0;
			DQMH_4 						<= 1'b0;
			nCS_4 						<= 1'b0;
			nCAS_4 						<= 1'b1;
			nRAS_4 						<= 1'b1;
			nWE_4 						<= 1'b1;//NOP
			Fifo2SDramReq 		<=1;
			BA_4 							<= 2'b0;
			A_4 							<= 13'b0;
			WRITE_RAM_READY 	<= 1'b0;
			WRITE_RAM_DONE 		<= 1'b0;
//			DQ_4 							<= DIN;
		end
	else if(STATE_WRB == WAIT_PREC_WRB)begin
			DQML_4 						<= 1'b1;
			DQMH_4 						<= 1'b1;
		   nCS_4 						<= 1'b0;
			nCAS_4 						<= 1'b1;
			nRAS_4 						<= 1'b1;
			nWE_4 						<= 1'b1;//NOP
			BA_4 							<= 2'b0;
			A_4 							<= 13'b0;
			WRITE_RAM_READY 	<= 1'b0;
			WRITE_RAM_DONE 		<= 1'b0;
		end
	else if(STATE_WRB == APRECHARGE_WRB)begin
			DQML_4 						<= 1'b1;
			DQMH_4 						<= 1'b1;
			nCS_4 						<= 1'b0;
			nCAS_4 						<= 1'b1;
			nRAS_4 						<= 1'b0;
			nWE_4 						<= 1'b0;//precharge
			A_4[10] 					<= 1'b0;//disable auto precharge
//			DQ_4							<=16'b0;
			BA_4 							<= W_BANK;
			WRITE_RAM_DONE 		<= 1'b0;		
			WRITE_RAM_DONE 		<= 1'b1;		
		end
	else if(STATE_WRB == WAITNEXT_WRB)begin
			DQML_4 						<= 1'b0;
			DQMH_4 						<= 1'b0;
			nCS_4 						<= 1'b0;
			nCAS_4 						<= 1'b1;
			nRAS_4 						<= 1'b1;
			nWE_4	 						<= 1'b1;//NOP
			BA_4 							<= 2'b0;
			A_4 							<= 13'b0;
			WRITE_RAM_READY 	<= 1'b0;
			WRITE_RAM_DONE 		<= 1'b0;
		end
	else	begin
			DQML_4 						<= 1'b0;
			DQMH_4 						<= 1'b0;
//			CKE_4 						<= 1'b1;
			nCS_4 						<= 1'b1;
			nCAS_4 						<= 1'b1;
			nRAS_4 						<= 1'b1;
			nWE_4 						<= 1'b1;//commond inhibit
			BA_4 							<= 2'b0;
			A_4 							<= 13'b0;
			WRITE_RAM_READY 	<= 1'b0;
			WRITE_RAM_DONE 		<= 1'b0;
			Fifo2SDramReq 		<=0;
//			DQ_4							<=16'b0;
		end
end
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
always@(posedge nCLK_50 or negedge nRESET)//burst read state 1
begin
	if (!nRESET)
		STATE_RDB <= IDLE_5;
	else
		STATE_RDB <= NX_STATE_RDB;
end

always@(posedge nCLK_50 or negedge nRESET)
begin
	if (!nRESET)
		begin
		CL_RDB_COUNTER <= 3'b0;
		BL_RDB_COUNTER <= 10'b0;
		end
	else if(STATE_RDB ==READ_RDB)
		CL_RDB_COUNTER <= 3'b0;
	else if(STATE_RDB ==CL_RDB)
		begin
		CL_RDB_COUNTER <= CL_RDB_COUNTER + 1'b1;
		BL_RDB_COUNTER <= 10'b0;
		end
	else if(STATE_RDB ==DATAIN_RDB)
		BL_RDB_COUNTER <= BL_RDB_COUNTER + 1'b1;
	else if(STATE_RDB ==IDLE_5)
		begin
		CL_RDB_COUNTER <= 3'b0;
		BL_RDB_COUNTER <= 10'b0;
		end
end

always@(*)//burst read state 2,without auto precharge
begin
	case(STATE_RDB)
		IDLE_5:	begin
			NX_STATE_RDB = (BEGIN_RDB&&(!ACTIONFORBID))? WAITACT_RDB : IDLE_5;
		end
		WAITACT_RDB:	begin
			NX_STATE_RDB = ACTIONFORBID ? WAITACT_RDB : ACTIVE_RDB;
		end
		ACTIVE_RDB:	begin
			NX_STATE_RDB = ACTIVE_RDB_1;
		end
		ACTIVE_RDB_1:	begin
			NX_STATE_RDB = READ_RDB;
		end
		READ_RDB:	begin
			NX_STATE_RDB = CL_RDB;
		end
		CL_RDB:	begin
			if(CL_RDB_COUNTER == 3) //delay: CMD_5->CMD_1P->(negedge)CMD(1) + CL(2) + DQ->DQ_5(1)-STATE_NX(1), ie. 3clks
//			if(CL_RDB_COUNTER == 4) //delay: CMD_5->CMD_1P->CMD(2) + CL(2) + DQ->DQ_5(1)-STATE_NX(1), ie. 4clks
				NX_STATE_RDB = DATAIN_RDB;
			else
				NX_STATE_RDB = CL_RDB;
		end
		DATAIN_RDB:	begin
//			if(BL_RDB_COUNTER==10'b1111111110)//b11111111	//255*10ns=2.55us
			if(BL_RDB_COUNTER==1022)//b11111111	//255*10ns=2.55us
			begin
				NX_STATE_RDB = Precharge_RDB;
			end
			else
				NX_STATE_RDB = DATAIN_RDB;
		end
		Precharge_RDB:
		begin
			NX_STATE_RDB = WAITNEXT_RDB;
		end
		WAITNEXT_RDB:	begin
			NX_STATE_RDB = READ_RAM_EN?ACTIVE_RDB:WAITNEXT_RDB;				
		end
		default:	NX_STATE_RDB = IDLE_5;
	endcase
end

always@(posedge nCLK_50 or negedge nRESET)//burst read state 3, disable auto precharge
begin
	if(!nRESET)begin
		DQML_5 					<= 1'b0;
		DQMH_5 					<= 1'b0;
		CKE_5 					<= 1'b1;
		nCS_5 					<= 1'b1;
		nCAS_5 					<= 1'b1;
		nRAS_5 					<= 1'b1;
		nWE_5 					<= 1'b1;//commond inhibit
		BA_5 						<= 2'b0;
		A_5 						<= 13'b0;
		DOUT						<=16'b0;
		READ_RAM_READY 	<= 1'b0;
		READ_RAM_DONE 	<= 1'b0;
	end
	else
	case(STATE_RDB)
		IDLE_5:	begin		
			DQML_5 					<= 1'b0;
			DQMH_5 					<= 1'b0;
			CKE_5 					<= 1'b1;
			nCS_5 					<= 1'b1;
			nCAS_5 					<= 1'b1;
			nRAS_5 					<= 1'b1;
			nWE_5 					<= 1'b1;//commond inhibit
			BA_5 						<= 2'b0;
			A_5 						<= 13'b0;
			DOUT						<=16'b0;
			READ_RAM_READY 	<= 1'b0;
			READ_RAM_DONE 	<= 1'b0;
		end
		WAITACT_RDB:	begin
			DQML_5 					<= 1'b0;
			DQMH_5 					<= 1'b0;
			CKE_5 					<= 1'b1;
			nCS_5 					<= 1'b0;
			nCAS_5 					<= 1'b1;
			nRAS_5 					<= 1'b1;
			nWE_5 					<= 1'b1;//commond inhibit
			BA_5 						<= 2'b0;
			A_5 						<= 13'b0;
			DOUT						<=16'b0;
			READ_RAM_READY 	<= 1'b0;
			READ_RAM_DONE 	<= 1'b0;
		end
		ACTIVE_RDB:	begin
			DQML_5 					<= 1'b0;
			DQMH_5 					<= 1'b0;
			CKE_5 					<= 1'b1;
			nCS_5 					<= 1'b0;
			nCAS_5 					<= 1'b1;
			nRAS_5 					<= 1'b0;
			nWE_5 					<= 1'b1;//active
			BA_5 						<= R_BANK;
			A_5 						<= R_ADDR_ROW;
			DOUT						<=16'b0;
			READ_RAM_READY 	<= 1'b0;
			READ_RAM_DONE 	<= 1'b0;
		end
		ACTIVE_RDB_1:	begin
			DQML_5 					<= 1'b0;
			DQMH_5 					<= 1'b0;
			CKE_5 					<= 1'b1;
			nCS_5 					<= 1'b0;
			nCAS_5 					<= 1'b1;
			nRAS_5 					<= 1'b1;
			nWE_5 					<= 1'b1;//NOP
			BA_5 						<= 2'b0;
			A_5 						<= 13'b0;
			DOUT						<=16'b0;
			READ_RAM_READY 	<= 1'b0;
			READ_RAM_DONE 	<= 1'b0;
		end
		READ_RDB:	begin
			DQML_5 					<= 1'b0;
			DQMH_5 					<= 1'b0;
			CKE_5 					<= 1'b1;
			nCS_5 					<= 1'b0;
			nCAS_5 					<= 1'b0;
			nRAS_5 					<= 1'b1;
			nWE_5 					<= 1'b1;//read
			BA_5 						<= R_BANK;
			A_5[9:0] 				<= 10'b0;
			A_5[10] 				<= 1'b0;//disable auto precharge
			A_5[12:11] 			<= 2'b0;
			DOUT						<=16'b0;
			READ_RAM_READY 	<= 1'b0;
			READ_RAM_DONE 	<= 1'b0;
		end
		CL_RDB:	begin
			DQML_5 					<= 1'b0;
			DQMH_5 					<= 1'b0;
			CKE_5  					<= 1'b1;
			nCS_5  					<= 1'b0;
			nCAS_5 					<= 1'b1;
			nRAS_5 					<= 1'b1;
			nWE_5 					<= 1'b1;//NOP
			BA_5						<= 2'b0;
			A_5 						<= 13'b0;
			DOUT						<=16'b0;
			if(CL_RDB_COUNTER == 3)
//			if(CL_RDB_COUNTER == 4)
				READ_RAM_READY 	<= 1'b1;
			else
				READ_RAM_READY 	<= 1'b0;
			READ_RAM_DONE 	<= 1'b0;
		end
		DATAIN_RDB:	begin
			DQML_5 					<= 1'b0;
			DQMH_5 					<= 1'b0;
			CKE_5 					<= 1'b1;
			nCS_5 					<= 1'b0;
			nCAS_5 					<= 1'b1;
			nRAS_5 					<= 1'b1;
			nWE_5 					<= 1'b1;//nop
			BA_5 						<= 2'b0;
			A_5  						<= 13'b0;
			DOUT						<=DQ_5;
			READ_RAM_READY 	<= 1'b0;
//			if(BL_RDB_COUNTER==1022)
//				READ_RAM_DONE 	<= 1'b1;
//			else
				READ_RAM_DONE 	<= 1'b0;
		end
		Precharge_RDB:	begin
			DQML_5 					<= 1'b0;
			DQMH_5 					<= 1'b0;
			CKE_5  					<= 1'b1;
			nCS_5  					<= 1'b0;
			nCAS_5 					<= 1'b1;
			nRAS_5 					<= 1'b0;
			nWE_5 					<= 1'b0;//precharge command
			BA_5 						<= R_BANK;
			A_5[9:0] 				<= 10'b0;
			A_5[10] 				<= 1'b0;
			A_5[12:11] 			<= 2'b0;
			DOUT 						<= DQ_5;
			READ_RAM_READY 	<= 1'b0;
			READ_RAM_DONE 	<= 1'b1;
		end
		WAITNEXT_RDB:	begin
			DQML_5 					<= 1'b0;
			DQMH_5 					<= 1'b0;
			CKE_5  					<= 1'b1;
			nCS_5  					<= 1'b0;
			nCAS_5 					<= 1'b1;
			nRAS_5 					<= 1'b1;
			nWE_5  					<= 1'b1;
			BA_5						<= 2'b0;
			A_5 						<= 13'b0;
			DOUT						<=DQ_5;
			READ_RAM_READY 	<= 1'b0;
			READ_RAM_DONE 	<= 1'b0;
		end
		default:	begin
			DQML_5 					<= 1'b0;
			DQMH_5 					<= 1'b0;
			CKE_5  					<= 1'b1;
			nCS_5  					<= 1'b0;
			nCAS_5 					<= 1'b1;
			nRAS_5 					<= 1'b1;
			nWE_5  					<= 1'b1;
			BA_5   					<= 2'b0;
			A_5    					<= 13'b0;
			DOUT   					<=16'b0;
			READ_RAM_READY 	<= 1'b0;
			READ_RAM_DONE 	<= 1'b0;
		end
	endcase
end
endmodule
