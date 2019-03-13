module Period_Generator(
	o_period,
	i_clk
);
output logic [3:0] o_period;
input i_clk;

logic [9:0] m_count = 10'b0;

always_ff@(posedge i_clk) begin
	
	if(m_count == 10'd1000)	m_count = 10'd1;
	else 							m_count = m_count + 10'd1; 
end

always_comb begin
	case(m_count)
		250:		o_period = 4'b0001;
		500:		o_period = 4'b0010;
		750:		o_period = 4'b0100;
		1000:		o_period = 4'b1000;
		default:	o_period = 4'b0000;
	endcase
end


endmodule 