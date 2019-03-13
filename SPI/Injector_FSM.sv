module Injector_FSM(
	o_flyback,
	o_set,
	o_reset,
	i_enable,
	i_peak,
	i_hold,
	i_period,
	i_clk
);
output 	logic 			o_flyback;
output 	logic 			o_set;
output	logic 			o_reset;
input							i_enable;
input							i_peak;
input							i_hold;
input							i_period;
input							i_clk;
localparam 	IDLE = 0,
				PEAK = 1,
				HOLD = 2;

				
reg[1:0] m_PS, m_NS;

always_ff @(posedge i_clk)begin
	m_PS = m_NS;
end

always_comb begin
	case(m_PS)
		IDLE: begin
			m_NS  = IDLE;
			if(i_enable == 1)	m_NS 	= PEAK;
		end
		PEAK: begin
			m_NS	= PEAK;
			if(i_peak == 1)	m_NS 	= HOLD;
		end
		HOLD: begin
			m_NS	= HOLD;
			if(i_enable == 0) m_NS	= IDLE;
		end
		default: 				m_NS	= IDLE;
	endcase
end

always_comb begin
	o_flyback 	<= 0;
	o_set 		<= 0;
	o_reset 		<= 1;		
	case(m_PS)
		IDLE: begin
			o_reset 		<= 1;		
		end
		PEAK: begin
			o_set 		<= 1;
		end
		HOLD: begin
			o_flyback 	<= 1;
			o_set			<= i_period;
			o_reset		<= i_hold;
		end
		default: ;
		endcase
end



endmodule