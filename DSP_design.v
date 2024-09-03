module spartan6_DSP(A,B,C,D,CLK,CARRYIN,OPMODE,BCIN,RSTA,RSTB,RSTC,RSTD,RSTM,RSTP,RSTCARRYIN,RSTOPMODE,CEA,CEB,CEC,CED,CEM,CEP,CEOPMODE,CECARRYIN,PCIN,BCOUT,PCOUT,P,M,CARRYOUT,CARRYOUTF);   

// all parameters declaration

parameter SIZE1=18;
parameter SIZE2=36;
parameter SIZE3=48;
parameter A0REG=0;
parameter A1REG=1;
parameter B0REG=0;
parameter B1REG=1;
parameter CREG=1;
parameter DREG=1;
parameter CARRYINREG=1;
parameter OPMODEREG=1;
parameter CARRYOUTREG=1;
parameter MREG=1;
parameter PREG=1;
parameter CARRYINSEL="OPMODE5";       // may be carry in or opmode[5]
parameter B_INPUT="DIRECT";          // may be direct to produce B or cascade to produce BCIN
parameter RSTTYPE="SYNC";           // may be SYNC "stands for synchronous" or ASYNC "stands for asynchronous" 

// all input ports declaration

input [SIZE1-1:0] A,B,D,BCIN ;
input [SIZE3-1:0] C,PCIN ;
input CLK,CARRYIN,RSTA,RSTB,RSTC,RSTD,RSTM,RSTP,RSTCARRYIN,RSTOPMODE ;
input CEA,CEB,CEC,CED,CEM,CEP,CEOPMODE,CECARRYIN ;
input [7:0] OPMODE ;

// all output ports declaration

output [SIZE1-1:0] BCOUT;
output [SIZE2-1:0] M;
output [SIZE3-1:0] P,PCOUT;
output CARRYOUT,CARRYOUTF;

// all internal wires declaration

wire [SIZE1-1:0] A0,B0,D0,result_pre,result_pre_mux,A1,B1 ;
reg [SIZE1-1:0] B_mux ;
wire [SIZE2-1:0] result_mult,result_mult_mux ;
wire [SIZE3-1:0] C0 ;
wire [7:0] OPMODE_REG ;
wire carryin_mux_out ;
reg [SIZE3-1:0] MUX_X,MUX_Z,result_post ;
reg carryout , carryin_mux;

// All module instantiations from ff_with_mux module

ff_with_mux #(.SIZE(SIZE1),.RSTTYPE(RSTTYPE)) D_REG (.D(D),.sel(DREG),.clk(CLK),.rst(RSTD),.CE(CED),.out(D0));
ff_with_mux #(.SIZE(SIZE1),.RSTTYPE(RSTTYPE)) A0_REG (.D(A),.sel(A0REG),.clk(CLK),.rst(RSTA),.CE(CEA),.out(A0));
ff_with_mux #(.SIZE(SIZE3),.RSTTYPE(RSTTYPE)) C_REG (.D(C),.sel(CREG),.clk(CLK),.rst(RSTC),.CE(CEC),.out(C0));
ff_with_mux #(.SIZE(SIZE1),.RSTTYPE(RSTTYPE)) B0_REG (.D(B_mux),.sel(B0REG),.clk(CLK),.rst(RSTB),.CE(CEB),.out(B0));
ff_with_mux #(.SIZE(8),.RSTTYPE(RSTTYPE)) OPMOD (.D(OPMODE),.sel(OPMODEREG),.clk(CLK),.rst(RSTOPMODE),.CE(CEOPMODE),.out(OPMODE_REG));

ff_with_mux #(.SIZE(SIZE1),.RSTTYPE(RSTTYPE)) A1_REG (.D(A0),.sel(A1REG),.clk(CLK),.rst(RSTA),.CE(CEA),.out(A1));
ff_with_mux #(.SIZE(SIZE1),.RSTTYPE(RSTTYPE)) B1_REG (.D(result_pre_mux),.sel(B1REG),.clk(CLK),.rst(RSTB),.CE(CEB),.out(B1));

ff_with_mux #(.SIZE(SIZE2),.RSTTYPE(RSTTYPE)) M_REG (.D(result_mult),.sel(MREG),.clk(CLK),.rst(RSTM),.CE(CEM),.out(result_mult_mux));

ff_with_mux #(.SIZE(1),.RSTTYPE(RSTTYPE)) CYI (.D(carryin_mux),.sel(CARRYINREG),.clk(CLK),.rst(RSTCARRYIN),.CE(CECARRYIN),.out(carryin_mux_out));
ff_with_mux #(.SIZE(1),.RSTTYPE(RSTTYPE)) CYO (.D(carryout),.sel(CARRYOUTREG),.clk(CLK),.rst(RSTCARRYIN),.CE(CECARRYIN),.out(CARRYOUT));

ff_with_mux #(.SIZE(SIZE3),.RSTTYPE(RSTTYPE)) P_REG (.D(result_post),.sel(PREG),.clk(CLK),.rst(RSTP),.CE(CEP),.out(P));


// always block to check the B_INPUT parameter

always @(*) begin 
	case(B_INPUT)
		"DIRECT" : B_mux = B ;
		"CASCADE" : B_mux = BCIN ;
		default : B_mux = 0 ;
	endcase
end

// always block to check the CARRYINSEL parameter

always @(*) begin 
	case(CARRYINSEL)
		"OPMODE5" : carryin_mux = OPMODE_REG[5] ;
		"CARRYIN" : carryin_mux = CARRYIN ;
		default : carryin_mux = 0 ;
	endcase
end

assign result_pre = (OPMODE_REG[6])? (D0 - B0) : (D0 + B0) ;

assign result_pre_mux = (OPMODE_REG[4])? result_pre : B0 ;

assign BCOUT = B1 ;

assign result_mult = A1 * B1 ;

assign M = result_mult_mux ;

always @(*) begin
	case({OPMODE_REG[1],OPMODE_REG[0]})
		2'b00 : MUX_X = 0 ;
		2'b01 : MUX_X = {12'b0 , result_mult_mux} ;
		2'b10 : MUX_X = P ;
		2'b11 : MUX_X = { D0[11:0] , A1 , B1 } ;
	endcase

end

always @(*) begin
	case({OPMODE_REG[3],OPMODE_REG[2]})
		2'b00 : MUX_Z = 0 ;
		2'b01 : MUX_Z = PCIN ; 
		2'b10 : MUX_Z = P ;
		2'b11 : MUX_Z = C0 ;
	endcase

end

always @(*) begin
	if(OPMODE_REG[1:0] == 2'b00)
	{carryout,result_post} = MUX_Z ;
	else if(OPMODE_REG[3:2] == 2'b00)
	{carryout,result_post} = MUX_X ;
	else if (OPMODE_REG[7])
	{carryout,result_post} = MUX_Z - (MUX_X + carryin_mux_out) ;
	else 
	{carryout,result_post} = MUX_Z + MUX_X + carryin_mux_out ;
end

assign CARRYOUTF = CARRYOUT ;

assign PCOUT = P ;

endmodule