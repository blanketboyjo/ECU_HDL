/*
 *  Period_Generator:
 *    This module takes in a clock signal and generates
 *    four period start signals at .001 the input frequency
 *
 *  Inputs:
 *    i_clk     - Input clock to be divided
 *
 *  Outputs:
 *    o_period  - 4 bit signal, one hot logic, 90 degree out of phase
 *              period signals
 *
 *  Author: Jordan Jones
 *
*/

module Period_Generator(
	o_period,
	i_clk
);
output logic [3:0] o_period;
input i_clk;

logic [9:0] m_count = 10'b0;

//Count to 1000 for 50Khz period
always_ff@(posedge i_clk) begin
	
	if(m_count == 10'd1000)	m_count = 10'd1;
	else 							m_count = m_count + 10'd1; 
end

//Create period start pulses 90 degrees out of phase
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