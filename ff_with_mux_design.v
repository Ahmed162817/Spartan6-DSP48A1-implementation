module ff_with_mux(D,clk,rst,sel,CE,out);       

parameter SIZE = 1;
parameter RSTTYPE = "SYNC";

input [SIZE-1:0] D;
input clk,rst,CE,sel;           // CE stands for clock enable
output [SIZE-1:0] out;

reg [SIZE-1:0] D_reg;

generate 
 case(RSTTYPE)
	"SYNC": begin
		always @(posedge clk) begin
			if(rst)
				D_reg <= 0;
			else if(CE)
				D_reg <= D;
			end
		end

	"ASYNC": begin
		always @(posedge clk or posedge rst) begin
			if(rst)
				D_reg <= 0;
			else if(CE)
				D_reg <= D;
			end
		end
 endcase
endgenerate

assign out = (sel)? D_reg : D ;

endmodule