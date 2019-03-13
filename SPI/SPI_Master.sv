module SPI_Master(
	o_MOSI,
	o_MISO_DATA,
	o_SCLK,
	o_SS,
	o_DIN_EMPTY,
	o_DATA_READY,
	i_MISO,
	i_DIN,
	i_LD_DIN,
	i_DATA_READ,
	i_clk
);
output	logic				o_MOSI;
output	logic	[7:0]		o_MISO_DATA;
output	logic				o_SCLK;
output	logic				o_SS					= 1'b1;
output	logic				o_DIN_EMPTY;
output	logic				o_DATA_READY		= 1'b0;
input							i_MISO;
input				[7:0]		i_DIN;
input							i_LD_DIN;
input							i_DATA_READ;
input							i_clk;

			logic 			m_SCLK_LAST;
			logic 			m_SCLK_RISING;
			logic				m_SCLK_FALLING;
			logic				m_SS;
			logic				m_LD_R;
			logic				m_LD_SR;
			logic				m_CLK_EN;
			logic				m_CLK_DIV_EN;
			logic				m_SCLK;
			logic				m_SHIFT;
			logic				m_RCO;
			logic				m_NEW_DATA 			= 1'b0;
			logic	[7:0]		m_DIN_R				= 8'b0;
			logic	[7:0]		m_MOSI_SR			= 8'b0;
			logic	[7:0]		m_MISO_SR			= 8'b0;
			logic	[2:0]		m_SHIFT_COUNT		= 3'b0;
			logic	[2:0]		m_CLK_DIV_COUNT	= 3'b0;
	

SPI_Master_FSM FSM(
	.o_LD_SR(m_LD_SR),
	.o_LD_R(m_LD_R),
	.o_Shift(m_SHIFT),
	.o_CLK_EN(m_CLK_EN),
	.o_CLK_DIV_EN(m_CLK_DIV_EN),
	.o_SS(m_SS),
	.i_New_Data(m_NEW_DATA),
	.i_RCO(m_RCO),
	.i_Fall_SCLK(m_SCLK_FALLING),
	.i_Rise_SCLK(m_SCLK_RISING),
	.i_clk(i_clk)
);
//Clock Divider for SPI SCLK
always_ff@(posedge i_clk)begin
	m_SCLK_LAST 				<=	m_SCLK;
	//Only count/toggle if enabled
	if(m_CLK_DIV_EN) begin
		m_CLK_DIV_COUNT = m_CLK_DIV_COUNT + 3'b1;
		
		//If at max count, reset, toggle SCLK
		if(m_CLK_DIV_COUNT == 3'd5)begin
			m_CLK_DIV_COUNT 	= 3'b0;
			m_SCLK				= ~m_SCLK;
		end
	end
	//If disabled, clear count and clear SCLK
	else begin
		m_CLK_DIV_COUNT 		= 	3'b0;
		m_SCLK					=	1'b0;
	end
end		
assign o_SCLK = m_SCLK & m_CLK_EN;
assign m_SCLK_RISING 		=	m_SCLK 		& (m_SCLK ^ m_SCLK_LAST); 
assign m_SCLK_FALLING 		=  m_SCLK_LAST & (m_SCLK ^ m_SCLK_LAST);


//New data and Din Buffer
always_ff@(posedge i_clk)begin
	if(i_LD_DIN)begin
		m_NEW_DATA 		= 	1'b1;
		m_DIN_R			=	i_DIN;
	end
	else if(m_LD_SR && m_SCLK_FALLING) begin
		m_NEW_DATA		= 1'b0;
	end
end
assign o_DIN_EMPTY = ~m_NEW_DATA;
//SHIFT Counter
always_ff@(posedge m_SCLK)begin
	//Count if shifting reset to 0 if not
	if(m_SHIFT)begin
		m_SHIFT_COUNT = m_SHIFT_COUNT + 3'b1;
	end
	else begin
		m_SHIFT_COUNT = 3'b0;
	end
end
assign m_RCO = m_SHIFT_COUNT == 3'b111;
	
//MOSI Shift Register
always_ff@(negedge m_SCLK)begin
	//Load if needed
	if(m_LD_SR)
		m_MOSI_SR 	= m_DIN_R;
	//Shift if needed
	else if(m_SHIFT)
		m_MOSI_SR 	= {m_MOSI_SR[6:0], m_MOSI_SR[7]};
end
assign o_MOSI = m_MOSI_SR[7];

//MISO Shift Register
always_ff@(posedge m_SCLK)begin
	if(m_SHIFT)
		m_MISO_SR	= {m_MISO_SR[6:0],i_MISO};
end

//MISO Data Latch
always_ff@(negedge m_SCLK)begin
	if(m_LD_R)
		o_MISO_DATA <= m_MISO_SR;
end

//Slave Select Register
always_ff@(posedge m_SCLK)begin
	o_SS = m_SS;
end

//Data Ready Register
always_ff@(posedge i_clk)begin
	//Clear if data being read
	if(i_DATA_READ)begin
		o_DATA_READY <= 1'b0;
	end
	//Set when data register is loaded
	else if(m_LD_R && m_SCLK_FALLING)begin
		o_DATA_READY <= 1'b1;
	end
	
end
endmodule