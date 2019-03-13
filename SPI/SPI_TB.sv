`timescale 1ns / 1ps
module SPI_TB();

logic				MOSI;
logic	[7:0]		MISO_DATA;
logic				SCLK;
logic				SS;
logic				MISO			= 1'b0;
logic	[7:0]		DIN			= 8'b0;
logic				LD_DIN		= 1'b0;
logic				clk			= 1'b0;
logic				DIN_EMPTY;
logic				DATA_READ	= 1'b0;
logic				DATA_READY;

always begin
	#5 clk = ~clk;
end

SPI_Master uut(
	.o_MOSI(MOSI),
	.o_MISO_DATA(MISO_DATA),
	.o_SCLK(SCLK),
	.o_SS(SS),
	.o_DIN_EMPTY(DIN_EMPTY),
	.o_DATA_READY(DATA_READY),
	.i_MISO(MISO),
	.i_DIN(DIN),
	.i_LD_DIN(LD_DIN),
	.i_DATA_READ(DATA_READ),
	.i_clk(clk)
);

initial begin
	#30;
	MISO 		= 	1'b1;
	DIN		=	8'hAA;
	LD_DIN	=	1'b1;
	#10
	LD_DIN	=	1'b0;
	#120
	DIN		=	8'hA5;
	#10
	LD_DIN	=	1'b1;
	#10
	LD_DIN	=	1'b0;
	#1000
	MISO		=	1'b0;

	#3000;
	MISO 		= 	1'b1;
	DIN		=	8'hAA;
	LD_DIN	=	1'b1;
	#10
	LD_DIN	=	1'b0;
	#120
	DIN		=	8'hA5;
	#10
	LD_DIN	=	1'b1;
	#10
	LD_DIN	=	1'b0;
	#1000
	MISO		=	1'b0;

	
end

endmodule