`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module RAMctrl(
sys_clk,
nRESET,
//PXI_CLK,
nRESET_RAM,
RF_DIN,
RF_WR_EN,
RF_WR_CLK,
RF_WR_DATA_COUNT,//sdram2fofo读使能//
WF_DOUT,
WF_RD_DATA_COUNT,
WF_RD_EN,
WF_RD_CLK,
//CLK_PLL,//WF_RD_EN fifo to sdram  写使能
//DOUT_RAM,	//for test
//READ_CMD,ALL_CMD,
//for cpu
DQ,DQML,DQMH,nWE,nCAS,nRAS,nCS,BA,A,CKE,
//for test
WRITE_RAM_EN,
READ_RAM_EN,
READ_RAM_READY,
READ_RAM_DONE,
WRITE_RAM_READY,
WRITE_RAM_DONE,
INIT_DONE,
ACTIONFORBID,
testsignal,
STATE_WR,
Read_Enable,
Write_Enable,
UsedWord
//Fifo2PXIReq,
//RF_FifoRdUsedW,
//RF_Fifoempty,
//RF_Fifofull
//,
//nRESET_WR
    );


//output	nRESET_WR;  
//output	[31:0]	DOUT_RAM;

//output	RF_Fifoempty;
//output	RF_Fifofull;
//output	[10:0]	RF_FifoRdUsedW;
//output	[11:0]	RF_FifoRdUsedW;
//input	Fifo2PXIReq;
output [21:0]  UsedWord;
output [15:0] STATE_WR;
output [31:0] testsignal;
output WRITE_RAM_EN,
READ_RAM_EN,
READ_RAM_READY,
READ_RAM_DONE,
WRITE_RAM_READY,
WRITE_RAM_DONE,
INIT_DONE,Read_Enable,Write_Enable,
ACTIONFORBID;


input	sys_clk;
//input	PXI_CLK;
input	nRESET;
input	nRESET_RAM;///////////////////////////////////////////////for reset random store address count

//for readdata fifo
output	[15:0]	RF_DIN;
//output CLK_PLL;
output RF_WR_CLK;
output WF_RD_CLK;

//output	[11:0]	RF_WR_DATA_COUNT;
//output	[10:0]	RF_WR_DATA_COUNT;
input		[11:0]	RF_WR_DATA_COUNT;
output	RF_WR_EN;

//for apdin fifo
input	[15:0]	WF_DOUT;
//input	[9:0]	WF_RD_DATA_COUNT;
//input	[10:0]	WF_RD_DATA_COUNT;
input	[11:0]	WF_RD_DATA_COUNT;
output	WF_RD_EN;
//input	READ_CMD;
//input	ALL_CMD;
//for sdram
//inout [31:0]	DQ;
inout [15:0]	DQ;
//output [3:0]	DQM;
output	DQMH;
output	DQML;
output	nWE;
output	nCAS;
output	nRAS;
output	nCS;
output	[1:0]	BA;
output	[12:0]	A;
output	CKE;
//input	[21:0]	READMESS;
//for cpu
//output	[3:0]	ASSIGNDATA;
//output	ASSIGN_FLAG;
//input	all_RD_EN;
//output	[31:0]	all_DOUT;
//output	all_EMPTY;
//output	ALL_FLAG;
wire CLK_PLL;
//wire	[31:0]	DQ;
wire	[15:0]	DQ;
wire	DQML;
wire	DQMH;
//wire [3:0] DQM;
//assign DQM =4'b00;
wire	nWE;
wire	nCAS;
wire	nRAS;
wire	nCS;
wire	[1:0]	BA;
wire	[12:0]	A;
wire	CKE;
wire	[15:0]	DOUT_RAM;
//wire	[31:0]	S_DATA;
//reg	BANK00;
//reg	BANK10;
//reg	[11:0]	ROW00;
//reg	[7:0]	COLUMN00;
//reg	[11:0]	ROW10;
//reg	[7:0]	COLUMN10;
//reg	[1:0]	HALFRAMFULL;
//reg	[1:0]	HALF_CLR;
reg	WF_RD_EN;
reg	RF_WR_EN;
wire	[15:0]	RF_DIN;
//reg	[11:0]	LMRCONF;
//reg	[11:0]	LMRCONF_S;
wire	INIT_DONE;
wire	ACTIONFORBID;
wire	READ_RAM_DONE;
wire	WRITE_RAM_DONE;
wire	WRITE_RAM_READY;
wire	READ_RAM_READY;
//wire	READ_S_DONE;
//wire	READ_S_READY;
//wire [9:0] wrusedw;
//assign  RF_WR_DATA_COUNT = wrusedw;
wire	POWERDOWN_EN;
assign	POWERDOWN_EN = 0;
//assign	POWERDOWN_EN = RAM_CMD[10];
wire	BEGIN_RAM;
assign	BEGIN_RAM = 1;
//assign	BEGIN_RAM = RAM_CMD[6];
wire	REINITRAM_EN;
//assign	REINITRAM_EN = RAM_CMD[5];
wire	RAM_nRESET;
assign	RAM_nRESET = nRESET;// & (!RAM_CMD[7]);
wire	SEND_EN;
//assign	SEND_EN = RAM_CMD[0];
reg	STORE_EN;//写使能。否则保持idle状态,读使能
//assign	STORE_EN = RAM_CMD[1]||RAM_CMD[15];
//assign STORE_EN = 1;
wire	RBCHOSE;
//assign	RBCHOSE = RAM_CMD[3];
wire	WBCHOSE;
//assign	WBCHOSE=RAM_CMD[4];
wire	[3:0]	BLENGTH;
//assign	BLENGTH = RAM_CONF[3:0];
wire	[1:0]	CLATENCY;
//assign	CLATENCY[0] = RAM_CONF[4];
assign	CLATENCY[1] = 1'b1;
wire	[3:0]	BLENGTH_S;
//assign	BLENGTH_S = RAM_CONF[11:8];
wire	[1:0]	CLATENCY_S;
//assign	CLATENCY_S[0] = RAM_CONF[12];
assign	CLATENCY_S[1] = 1'b1;
reg	READ_CMD_DELAY;
reg	WRITE_CMD_DELAY;
wire	PREPARE_EN;
//assign	PREPARE_EN=RAM_CMD[2];
wire	nRESET_WR;
assign	nRESET_WR=nRESET&(nRESET_RAM);
//assign	nRESET_WR=nRESET;

reg	LOAD_WR_EN;
reg	LOAD_RD_EN;
wire	LOAD_RAM_EN;
//assign	LOAD_RAM_EN=STORE_EN?LOAD_WR_EN:LOAD_RD_EN;
assign	LOAD_RAM_EN=0;

reg	[1:0]	R_BANK;
reg	[12:0]	R_ADDR_ROW;
reg	[9:0]	R_ADDR_COLUMN;
reg	[1:0]	W_BANK;
reg	[12:0]	W_ADDR_ROW;
reg	[9:0]	W_ADDR_COLUMN;

reg	READ_RAM_EN;
reg	WRITE_RAM_EN;
//reg	[15:0]	DIN_RAM;
wire	[15:0]	DIN_RAM;
reg	[10:0]	WRITE_BURST_COUNTER;
reg	[10:0]	READ_BURST_COUNTER;
reg	[1:0]	DATACHOSE;
reg	[31:0]	all_DIN;
reg	all_WR_EN;
wire	all_EMPTY;
wire	all_RST;
assign	all_RST=1;
//wire	[11:0]	RF_WR_DATA_COUNT;
wire	[11:0]	RF_WR_DATA_COUNT;
reg	[3:0]	ASSIGNDATA;//
reg	ASSIGN_FLAG;
reg	ALL_FLAG;
//wire PXI_CLK;
//reg	[21:0]	READADDR;
reg	READALL_DONE;
reg	ALL_BANK;
reg	[3:0]	DELAYCOUNT_ALL;
reg [24:0] WriteAddr;
reg [24:0] ReadAddr;
reg [24:0] UsedWord;
wire SDRAM2FifoReq;

parameter	IDLE_1			=16'b1,
				LMR_WR			=16'b10,
				LMR_WR_1			=16'b100,
				STORESTAT_WR	=16'b1000,
				START_WR			=16'b10000,
				WRITESTART_WR	=16'b100000,
				WRITERAM_WR		=16'b1000000,
				WRITERAM_WR_1	=16'b10000000,
				WRITERAM_WR_2	=16'b100000000,
				C_OPINION_WR	=16'b1000000000,
				COLUMN_WR		=16'b10000000000,
				R_OPINION_WR	=16'b100000000000,
				ROW_WR			=16'b1000000000000,
				B_OPINION_WR	=16'b10000000000000,
				BANK_WR			=16'b100000000000000,
				IDLE_WAIT		=16'b1000000000000000;
reg	[15:0]	STATE_WR;
reg	[15:0]	NX_STATE_WR;

parameter	IDLE_2			=15'b1,
				LMR_RD			=15'b10,
				LMR_RD_1			=15'b100,
				SENDSTAT_RD		=15'b1000,
				START_RD			=15'b10000,
				WAITFORFIFO_RD	=15'b100000,
				READSTART_RD	=15'b1000000,
				READRAM_RD		=15'b10000000,//80
				CLEARADDR_RD	=15'b100000000,
				C_OPINION_RD	=15'b1000000000,
				COLUMN_RD		=15'b10000000000,
				R_OPINION_RD	=15'b100000000000,
				ROW_RD			=15'b1000000000000,
				B_OPINION_RD	=15'b10000000000000,
				BANK_RD			=15'b100000000000000;
reg	[14:0]	STATE_RD;
reg	[14:0]	NX_STATE_RD;

parameter	IDLE_3		=7'b1,
				WAITLOW		=7'b10,	
				RECEIVEMESS	=7'b100,
				STARTASSIGN	=7'b1000,
				READASSIGN	=7'b10000,
				CHOSE1		=7'b100000,
				READYASSIGN	=7'b1000000;
reg	[6:0]	STATE_ASSIGN;
reg	[6:0]	NX_STATE_ASSIGN;

parameter	IDLE_4				=9'b1,
				WAITFIFO_ALL		=9'b10,
				START_ALL			=9'b100,
				READ2FIFO_ALL		=9'b1000,
				READ2FIFO_ALL_1		=9'b10000,
				ADDRPLUS_ALL		=9'b100000,
				READDONE_ALL		=9'b1000000,
				READDONE_ALL_1		=9'b10000000,
				READDONE_ALL_2		=9'b100000000;
reg	[8:0]	STATE_ALL;
reg	[8:0]	NX_STATE_ALL;

parameter	IDLE_5	=3'b1,
				CLRFLAG	=3'b10,
				STAY		=3'b100;
reg	[2:0]	HALF_STATE;
reg	[2:0]	NX_HALF_STATE;
wire	LOAD_RAM_DONE;
wire	Fifo2SDramReq;

(* IODELAY_GROUP = "group_sdram" *)
sdram	sdram_inst(
	.nRESET(nRESET_WR),
//	.LMRCONF(LMRCONF),
	.BEGIN_RAM(BEGIN_RAM),
//	.POWERDOWN_EN(POWERDOWN_EN),
//	.REINITRAM_EN(REINITRAM_EN),
	//.CLATENCY(CLATENCY),
	//.BLENGTH(BLENGTH),
	.nCLK_50(CLK_PLL),				//CLK_PLL
	.W_BANK(W_BANK),
	.W_ADDR_ROW(W_ADDR_ROW),
	.W_ADDR_COLUMN(W_ADDR_COLUMN),
	.R_BANK(R_BANK),
	.R_ADDR_ROW(R_ADDR_ROW),
	.R_ADDR_COLUMN(R_ADDR_COLUMN),
	.DIN(DIN_RAM),
	.DOUT(DOUT_RAM),
	.INIT_DONE(INIT_DONE),
	.ACTIONFORBID(ACTIONFORBID),
	.WRITE_RAM_EN(WRITE_RAM_EN),
	.READ_RAM_EN(READ_RAM_EN),
	.READ_RAM_READY(READ_RAM_READY),
	.READ_RAM_DONE(READ_RAM_DONE),
	.WRITE_RAM_READY(WRITE_RAM_READY),
	.WRITE_RAM_DONE(WRITE_RAM_DONE),
//	.LOAD_RAM_EN(LOAD_RAM_EN),
//	.LOAD_RAM_DONE(LOAD_RAM_DONE),
	.DQ(DQ),
	.DQML(DQML),
	.DQMH(DQMH),
	.nWE(nWE),
	.nCAS(nCAS),
	.nRAS(nRAS),
	.nCS(nCS),
	.BA(BA),
	.A(A),
	.CKE(CKE),
//	.LMRCONF_S(LMRCONF_S),
//	.S_BANK(S_BANK),
//	.S_ADDR_ROW(S_ADDR_ROW),
//	.S_ADDR_COLUMN(S_ADDR_COLUMN),
//	.S_DATA(),//S_DATA
//	.READ_S_EN(READ_S_EN),
//	.READ_S_READY(READ_S_READY),
//	.READ_S_DONE(READ_S_DONE),
//	.CKEHLGH(CKE),
	.SDRAM2FifoReq(SDRAM2FifoReq),
	.Fifo2SDramReq(Fifo2SDramReq),
	.testsignal(testsignal[26:0])
);
assign testsignal[29:27]= STATE_RD[7:5];

assign RF_DIN = DOUT_RAM;
assign DIN_RAM = WF_DOUT;

assign CLK_PLL = sys_clk;	 
assign RF_WR_CLK = CLK_PLL;
assign WF_RD_CLK = CLK_PLL;			       	

reg Write_Enable;
reg Read_Enable;
always @ (posedge CLK_PLL or negedge nRESET_WR)	//nRESET
begin
		if(!nRESET_WR)		//nRESET
		begin
			Write_Enable	<=0;
			Read_Enable 	<=0;
		end
		else
		if(WRITE_RAM_DONE||READ_RAM_DONE||!(Write_Enable||Read_Enable))
			if((WF_RD_DATA_COUNT>1024)&&(UsedWord<4000000))
//			if(WF_RD_DATA_COUNT>1024&&UsedWord<4000)//9000 for test bench
			begin	
				Write_Enable 	<= 1;
				Read_Enable 	<=0;
			end
			else if((RF_WR_DATA_COUNT <3000)&&(UsedWord>1024))
			begin	
				Read_Enable		<= 1;
				Write_Enable	<=0;
			end
			else
			begin
				Write_Enable	<=0;
				Read_Enable 	<=0;
			end
		else
		begin
			Write_Enable 		<= Write_Enable;
			Read_Enable 		<=Read_Enable;
		end
end

always@(posedge CLK_PLL or negedge nRESET_WR)//write state 1
begin
	if (!nRESET_WR)
		STATE_WR <= IDLE_1;
	else if(!INIT_DONE)
		STATE_WR <= IDLE_1;
	else if(!Write_Enable)
		STATE_WR <= IDLE_WAIT;
	else
		STATE_WR <= NX_STATE_WR;
end

always@(posedge CLK_PLL or negedge nRESET_WR)//nRESET
begin
if(!nRESET_WR)	//nRESET
	UsedWord <= 0;
else 
if(WriteAddr>=ReadAddr)
		UsedWord <= WriteAddr - ReadAddr;
	else
		UsedWord <= 33554432 + WriteAddr - ReadAddr;
end
always@(posedge CLK_PLL or negedge nRESET_WR)//nRESET
begin
	if(!nRESET_WR)//nRESET
	begin
		 WriteAddr<= 0;
		 ReadAddr <= 0;
	end
	else
	if(WRITE_RAM_DONE)
		WriteAddr <= WriteAddr+1024;
	else if(READ_RAM_DONE)
		begin
		ReadAddr <= ReadAddr +1024;
		end
	else
		begin
		ReadAddr	<= ReadAddr;
		WriteAddr <= WriteAddr;
		end
end
always@(posedge CLK_PLL or negedge nRESET_WR)
begin
	if (!nRESET_WR)
		begin
		W_BANK				<=2'b0;
		W_ADDR_ROW 		<= 13'b0;
		W_ADDR_COLUMN <= 10'b0;
		end
	else if (STATE_WR == IDLE_1)
		begin
		W_BANK				<=2'b0;
		W_ADDR_ROW 		<= 13'b0;
		W_ADDR_COLUMN <= 10'b0;
		end
	else if(STATE_WR==START_WR)
		begin
		W_BANK 							<= WriteAddr[24:23];
		W_ADDR_ROW 					<= WriteAddr[22:10];
		WRITE_BURST_COUNTER	<=11'b0;
		end
	else if(STATE_WR==WRITERAM_WR)
		WRITE_BURST_COUNTER	<=WRITE_BURST_COUNTER+1'b1;
end
	
//always@(STATE_WR or Write_Enable or WBCHOSE or WF_RD_DATA_COUNT or READ_RAM_READY or
//			WF_DOUT or WRITE_RAM_DONE or W_BANK or W_ADDR_COLUMN or W_ADDR_ROW or
//			WRITE_RAM_READY or ACTIONFORBID or WRITE_BURST_COUNTER or LOAD_RAM_DONE or HALFRAMFULL)//write state 2
always@(*)//write state 2
begin
//	WF_RD_EN = 1'b0;
//	WRITE_RAM_EN = 1'b0;
//	LOAD_WR_EN=1'b0;
//	DIN_RAM = 16'b0;
	case(STATE_WR)
		IDLE_1:	begin//powerup state	//0x1
			//DIN0_RAM = 16'b0;
//			WF_RD_EN = 1'b0;
//			WRITE_RAM_EN = 1'b0;
//			LOAD_WR_EN=1'b0;
			NX_STATE_WR = INIT_DONE ?STORESTAT_WR: IDLE_1;
		end
		STORESTAT_WR:	begin		//0x8
			if(~Write_Enable)
				NX_STATE_WR=IDLE_WAIT;
			else if(~ACTIONFORBID)
				NX_STATE_WR=START_WR;
			else
				NX_STATE_WR=STORESTAT_WR;
		end
		START_WR:	begin//transmition rest	//0x10
			//DIN0_RAM = 16'b0;
				if(~Write_Enable)
					NX_STATE_WR=IDLE_WAIT;
				else //if (WF_RD_DATA_COUNT >= 9'b100000000)//can finish a BL=8 transmit
					begin
//					WRITE_RAM_EN = 1'b1;
					NX_STATE_WR = WRITESTART_WR;
					end
				//else
					//NX_STATE_WR = START_WR;
		end
		WRITESTART_WR:	begin		//0x20
			if(~Write_Enable)
				NX_STATE_WR=IDLE_WAIT;
			else if(WRITE_RAM_READY)
				begin
//				WRITE_RAM_EN = 1'b1;
				//////////////////////////////////////add by sq
//				WF_RD_EN = 1'b1;
//				DIN_RAM = WF_DOUT;
				//////////////////////////////////////
				NX_STATE_WR =WRITERAM_WR;
				end
			else
				NX_STATE_WR =WRITESTART_WR;
		end
		WRITERAM_WR:	begin	//0x40
//			WF_RD_EN = 1'b1;
//			DIN_RAM = WF_DOUT;
			NX_STATE_WR = (WRITE_BURST_COUNTER==10'b1111111110)?WRITERAM_WR_1:WRITERAM_WR;//b11111111
		end
		WRITERAM_WR_1:	begin	//0x80
//			DIN_RAM = WF_DOUT;

			if (WRITE_RAM_DONE)
			begin
				NX_STATE_WR = C_OPINION_WR;//mark the write address
//				WF_RD_EN = 0;
//				WRITE_RAM_EN = 0;
			end
			else
				NX_STATE_WR = WRITERAM_WR_1;
		end
		C_OPINION_WR:	begin		//0x200
			NX_STATE_WR = STORESTAT_WR;
		end
		IDLE_WAIT:	begin
			NX_STATE_WR=Write_Enable?STORESTAT_WR:IDLE_WAIT;
		end
		default:	NX_STATE_WR=IDLE_1;
	endcase
end

always@(posedge CLK_PLL or negedge nRESET_WR)//write state 2
begin
	if(!nRESET_WR) begin
		WF_RD_EN 			<= 1'b0;
		WRITE_RAM_EN 	<= 1'b0;
//		DIN_RAM 			<= 16'b0;
	end
	else 
	case(STATE_WR)
		IDLE_1:	begin//powerup state	//0x1
//			DIN_RAM 			<= 16'b0;
			WF_RD_EN 			<= 1'b0;
			WRITE_RAM_EN 	<= 1'b0;
		end
		STORESTAT_WR:	begin		//0x8
			WF_RD_EN 			<= 1'b0;
			WRITE_RAM_EN 	<= 1'b0;
//			DIN_RAM 			<= 16'b0;
		end
		START_WR:	begin//transmition rest	//0x10
			WF_RD_EN 	<= 1'b0;
//			DIN_RAM	 	<= 16'b0;	
			if(~Write_Enable)
				WRITE_RAM_EN <= 1'b0;
			else 
				begin
				WRITE_RAM_EN <= 1'b1;
				end
		end
		WRITESTART_WR:	begin		//0x20
			if(~Write_Enable) begin
				WRITE_RAM_EN 	<= 1'b0;
				WF_RD_EN 			<= 1'b0;
//				DIN_RAM 			<= 16'b0;
			end
			else if(WRITE_RAM_READY) begin
				WRITE_RAM_EN 	<= 1'b1;
				WF_RD_EN 			<= 1'b1;
//				DIN_RAM 			<= WF_DOUT;
				end
			else begin
				WF_RD_EN 			<= 1'b0;
				WRITE_RAM_EN 	<= 1'b0;
//				DIN_RAM 			<= 16'b0;
			end
		end
		WRITERAM_WR:	begin	//0x40
			WF_RD_EN 			<= 1'b1;
//			DIN_RAM 			<= WF_DOUT;
			WRITE_RAM_EN 	<= 1'b0;
		end
		WRITERAM_WR_1:	begin	//0x80
			WF_RD_EN 			<= 0;
			WRITE_RAM_EN 		<= 0;
		end
		C_OPINION_WR:	begin		//0x200
			WF_RD_EN 			<= 1'b0;
			WRITE_RAM_EN 	<= 1'b0;
//			DIN_RAM 			<= 16'b0;
		end
		IDLE_WAIT:	begin
			WF_RD_EN 			<= 1'b0;
			WRITE_RAM_EN 	<= 1'b0;
//			DIN_RAM 			<= 16'b0;
		end
		default:	begin
			WF_RD_EN 			<= 1'b0;
			WRITE_RAM_EN 	<= 1'b0;
//			DIN_RAM 			<= 16'b0;
		end
	endcase
end
///////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////full page burst read///////////////////////////////////////////////////////////////
always@(posedge CLK_PLL or negedge nRESET_WR)//read state 1
begin
	if (!nRESET_WR)
		STATE_RD <= IDLE_2;
	else if (!INIT_DONE)
		STATE_RD <= IDLE_2;
	else
		STATE_RD <= NX_STATE_RD;
end

always@(posedge CLK_PLL or negedge nRESET_WR)
begin
	if (!nRESET_WR)
		begin
		R_BANK				<=2'b0;
		R_ADDR_ROW 		<= 13'b0;
		R_ADDR_COLUMN <= 10'b0;
		end
	else if (STATE_RD == IDLE_2)
		begin
		R_BANK				<=2'b0;
		R_ADDR_ROW 		<= 13'b0;
		R_ADDR_COLUMN <= 10'b0;
		end
	else if(STATE_RD==SENDSTAT_RD)
	begin
		R_BANK 			<= ReadAddr[24:23];
		R_ADDR_ROW 	<= ReadAddr[22:10];
	end
	else if(STATE_RD==READSTART_RD)
		READ_BURST_COUNTER	<=11'b0;
	else if(STATE_RD==READRAM_RD)
		READ_BURST_COUNTER	<=READ_BURST_COUNTER+1'b1;
	else if(STATE_RD==CLEARADDR_RD)
		begin
		R_BANK				<=2'b0;
		R_ADDR_ROW 		<= 13'b0;
		R_ADDR_COLUMN <= 10'b0;
		end
end
	
//always@(STATE_RD or SEND_EN or PREPARE_EN or RBCHOSE or RF_WR_DATA_COUNT or WRITE_RAM_READY or
//			DOUT_RAM or WRITE_RAM_DONE or R_BANK or BANK00 or R_ADDR_ROW or
//			ROW00 or R_ADDR_COLUMN or COLUMN00 or BANK10 or
//			ROW10 or COLUMN10 or READ_RAM_READY or READ_RAM_DONE or ACTIONFORBID or READ_BURST_COUNTER or
//			LOAD_RAM_DONE or Read_Enable)//read state 2
always@(*)//read state 2
begin
//	RF_WR_EN = 1'b0;
//	READ_RAM_EN = 1'b0;
//	LOAD_RD_EN=1'b0;
	case(STATE_RD)
		IDLE_2:	begin//powerup state
//			RF_WR_EN = 1'b0;
//			READ_RAM_EN = 1'b0;
//			LOAD_RD_EN=1'b0;
//			//ReadAddr = 0;
			NX_STATE_RD =INIT_DONE?LMR_RD_1:IDLE_2;
		end
		LMR_RD_1:	begin
			NX_STATE_RD=Read_Enable?SENDSTAT_RD:LMR_RD_1;
		end		
		SENDSTAT_RD:	begin
			if(!ACTIONFORBID)
				NX_STATE_RD=WAITFORFIFO_RD;
			else if(!Read_Enable)
				NX_STATE_RD =LMR_RD_1;
			else
				NX_STATE_RD =SENDSTAT_RD;
		end
		WAITFORFIFO_RD:	begin
//				READ_RAM_EN = 1'b1;
				NX_STATE_RD = READSTART_RD;
		end
		READSTART_RD:	begin
			if(READ_RAM_READY)
				NX_STATE_RD=READRAM_RD;
			else if(!Read_Enable)
				NX_STATE_RD =LMR_RD_1;
			else
				NX_STATE_RD=READSTART_RD;
		end
		READRAM_RD:	begin
//			RF_WR_EN = 1'b1;
			if	(READ_RAM_DONE)
			begin
				NX_STATE_RD = IDLE_2;
			end
			else
			begin
				NX_STATE_RD = READRAM_RD;
			end
		end
		R_OPINION_RD:	begin
			NX_STATE_RD =SENDSTAT_RD;			
		end
		default:	NX_STATE_RD = IDLE_2;
	endcase
end

always@(posedge CLK_PLL or negedge nRESET_WR)//read state 3
begin
	if(!nRESET_WR)begin
	RF_WR_EN 		<= 1'b0;
	READ_RAM_EN <= 1'b0;
	end
	else
	case(STATE_RD)
		IDLE_2:	begin//powerup state
			RF_WR_EN 		<= 1'b0;
			READ_RAM_EN <= 1'b0;
		end
		LMR_RD_1:	begin
			RF_WR_EN 		<= 1'b0;
			READ_RAM_EN <= 1'b0;
		end		
		SENDSTAT_RD:	begin
			RF_WR_EN 		<= 1'b0;
			READ_RAM_EN <= 1'b0;
		end
		WAITFORFIFO_RD:	begin
			READ_RAM_EN <= 1'b1;
			RF_WR_EN 		<= 1'b0;
		end
		READSTART_RD:	begin
			if(READ_RAM_READY) begin
				RF_WR_EN 		<= 1'b1;
				READ_RAM_EN <= 1'b0;
			end
			else begin
				RF_WR_EN 		<= 1'b0;
				READ_RAM_EN <= 1'b0;
			end
		end
		READRAM_RD:	begin
			if	(READ_RAM_DONE)
				RF_WR_EN 		<= 1'b0;
			else
				RF_WR_EN 		<= 1'b1;
			READ_RAM_EN <= 1'b0;
		end
		R_OPINION_RD:	begin
			RF_WR_EN 		<= 1'b0;
			READ_RAM_EN <= 1'b0;
		end
		default:	begin
			RF_WR_EN 		<= 1'b0;
			READ_RAM_EN <= 1'b0;
		end
	endcase
end
endmodule
