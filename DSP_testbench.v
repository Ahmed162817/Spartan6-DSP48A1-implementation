module spartan6_DSP_tb();

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
parameter CARRYINSEL="OPMODE5";       
parameter B_INPUT="DIRECT";          
parameter RSTTYPE="SYNC"; 

reg [SIZE1-1:0] A,B,D,BCIN ;
reg [SIZE3-1:0] C,PCIN ;
reg CLK,CARRYIN,RSTA,RSTB,RSTC,RSTD,RSTM,RSTP,RSTCARRYIN,RSTOPMODE ;
reg CEA,CEB,CEC,CED,CEM,CEP,CEOPMODE,CECARRYIN ;
reg [7:0] OPMODE ;

wire [SIZE1-1:0] BCOUT;
wire [SIZE2-1:0] M;
wire [SIZE3-1:0] P,PCOUT;
wire CARRYOUT,CARRYOUTF;

integer i = 0;

spartan6_DSP #(.SIZE1(SIZE1),.SIZE2(SIZE2),.SIZE3(SIZE3),.A0REG(A0REG),.A1REG(A1REG),.B0REG(B0REG),.B1REG(B1REG),.CREG(CREG),.DREG(DREG),.CARRYINREG(CARRYINREG),.OPMODEREG(OPMODEREG),.CARRYOUTREG(CARRYOUTREG),.MREG(MREG),.PREG(PREG),.CARRYINSEL(CARRYINSEL),.B_INPUT(B_INPUT),.RSTTYPE(RSTTYPE)) DUT (.A(A),.B(B),.C(C),.D(D),.BCIN(BCIN),.PCIN(PCIN),.CLK(CLK),.CARRYIN(CARRYIN),.RSTA(RSTA),.RSTB(RSTB),.RSTC(RSTC),.RSTD(RSTD),.RSTM(RSTM),.RSTP(RSTP),.RSTCARRYIN(RSTCARRYIN),.RSTOPMODE(RSTOPMODE),.CEA(CEA),.CEB(CEB),.CEC(CEC),.CED(CED),.CEM(CEM),.CEP(CEP),.CECARRYIN(CECARRYIN),.CEOPMODE(CEOPMODE),.OPMODE(OPMODE),.BCOUT(BCOUT),.M(M),.P(P),.PCOUT(PCOUT),.CARRYOUT(CARRYOUT),.CARRYOUTF(CARRYOUTF));

initial begin
	CLK=0;
	forever
	#25 CLK=~CLK;         // this mean that clock period = 50 ns 
end

initial begin
	RSTA = 1; RSTB = 1; RSTC = 1; RSTD = 1; RSTM = 1; RSTP = 1; RSTCARRYIN = 1; RSTOPMODE = 1;    // Reset all flipflops
	#100;    // delay for two periods 

	RSTA = 0; RSTB = 0; RSTC = 0; RSTD = 0; RSTM = 0; RSTP = 0; RSTCARRYIN = 0; RSTOPMODE = 0; 
	CEA = 1; CEB = 1; CEC = 1; CED = 1; CEM = 1; CEP = 1; CEOPMODE = 1; CECARRYIN = 1;            // active high all the clock enables for all inputs to sample the input of the f.f's 

	// as we know that all output will be ready after delay few clock cycles for example (P & PCOUT) will be ready after 5 clk cycles

	for(i=0;i<100;i=i+1) begin
		@(negedge CLK);
		A = $urandom_range(0,1000);             // here we randomize all inputs with small range from 0 to 1000 
		B = $urandom_range(0,1000);             // for simple and more readable testing
		C = $urandom_range(0,1000);
		D = $urandom_range(0,1000);
		BCIN = $urandom_range(0,1000);
		PCIN = $urandom_range(0,1000);
		OPMODE = $random;
		CARRYIN = $random;                  // here CARRYIN only one bit so we randomize it normally without certain range
	end

	$stop;

end

endmodule