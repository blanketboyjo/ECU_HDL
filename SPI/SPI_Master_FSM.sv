module SPI_Master_FSM(
	o_LD_SR,
	o_LD_R,
	o_Shift,
	o_CLK_EN,
	o_CLK_DIV_EN,
	o_SS,
	i_New_Data,
	i_RCO,
	i_Fall_SCLK,
	i_Rise_SCLK,
	i_clk
);

output	logic			o_LD_SR;
output	logic			o_LD_R;
output	logic 		o_Shift;
output	logic			o_CLK_EN;
output	logic			o_CLK_DIV_EN;
output	logic			o_SS;
input		logic			i_New_Data;
input		logic			i_RCO;
input		logic			i_Fall_SCLK;
input		logic			i_Rise_SCLK;
input		logic			i_clk;

localparam 	IDLE 		= 	0,
				LOAD_SR	=	1,
				SHIFT		=	2,
				RELOAD	=	3,
				DONE		=	4,
				CHIPSEL	=	5;

reg[2:0] m_PS, m_NS;

always_ff@(posedge i_clk)begin
	m_PS = m_NS;
end

always_comb begin
	case(m_PS)
	IDLE:begin
		m_NS = IDLE;
		if(i_New_Data)
			m_NS = LOAD_SR;
	end
	
	LOAD_SR:begin
		m_NS = LOAD_SR;
		if(i_Fall_SCLK)
			m_NS = SHIFT;
	end
	
	SHIFT:begin
		m_NS = SHIFT;
		if(i_RCO && i_Fall_SCLK)begin
			if(i_New_Data)
				m_NS = RELOAD;
			else 
				m_NS = DONE;
		end
	end
	
	RELOAD:begin
		m_NS = RELOAD;
		if(i_Fall_SCLK)
			m_NS = SHIFT;
	end
	
	DONE:begin
		m_NS = DONE;
		
		if(i_Fall_SCLK)
			m_NS = CHIPSEL;
	end
	
	CHIPSEL:begin
		m_NS = CHIPSEL;
		if(i_Rise_SCLK)
			m_NS = IDLE;
	end
	
	default: m_NS = IDLE;
	endcase
end


always_comb begin
	o_LD_SR 			<= 0;
	o_LD_R			<= 0;
	o_Shift			<=	0;
	o_CLK_EN			<=	0;
	o_CLK_DIV_EN 	<= 0;
	o_SS				<= 0;
	case(m_PS)
	IDLE:begin
		o_SS				<= 1;
	end
	
	LOAD_SR:begin
		o_LD_SR 			<= 1;
		o_CLK_DIV_EN	<= 1;
	end
	
	SHIFT:begin
		o_Shift 			<= 1;
		o_CLK_EN			<= 1;
		o_CLK_DIV_EN	<= 1;
	end
	
	RELOAD:begin
		o_LD_SR 			<= 1;
		o_LD_R			<= 1;
		o_Shift			<= 1;
		o_CLK_EN			<= 1;
		o_CLK_DIV_EN	<= 1;
	end
	
	DONE:begin
		o_LD_R			<= 1;
		o_Shift			<= 1;
		o_CLK_EN			<= 1;
		o_CLK_DIV_EN	<= 1;
	end
	
	CHIPSEL:begin
		o_CLK_DIV_EN	<= 1;
		o_SS				<= 1;
	end
	
	default:;
	endcase
end

endmodule