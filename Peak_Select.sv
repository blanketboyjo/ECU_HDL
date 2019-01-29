//////////////////////////////////////////////////////////////////////////////
//
//					Peak Select Module
//		This module will take in a clock signal and enable to control a mux
//		The output signal goes high after a user defined number of clock cycles
//			Pins:
//				i_clock (this should be routed to the divided clock as we want to count
//							cycles of the total system not the input clock)
//
//				i_enable - allows for counting to start, value of 0 clears count
//
//				i_max		- max number of counts for the delay
//
//				o_muxControl - output for mux select signal
//
//////////////////////////////////////////////////////////////////////////////

module Peak_Select(
	i_clock,
	i_enable,
	o_muxControl
);

input 						i_clock;
input 						i_enable;
output	logic				o_muxControl;
			logic	[15:0]	m_clockCount	= 0;
parameter		[15:0]	c_MAX_COUNTS 	= 20;
always_ff @(posedge i_clock or negedge i_enable) begin

	//If enable is low, clear count
	if(i_enable == 1'b0)begin
		m_clockCount = 16'b0;
	end else begin
		//Count if o_muxControl is 1 (made it generate comparators instead of muxes)
		m_clockCount = m_clockCount + !o_muxControl;
	end

end
assign o_muxControl = (c_MAX_COUNTS == m_clockCount);

endmodule
