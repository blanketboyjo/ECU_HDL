/*
 *  Injector_Single:
 *    This module contains one peak and hold controller
 *
 *  Inputs:
 *    i_clk     - Input clock to be divided
 *    i_enable  - Enables injector
 *    i_peak    - Peak current detection
 *    i_hold    - Hold current detection
 *    i_period  - Period Start signal, used to set output during hold state
 *
 *  Outputs:
 *    o_drive   - Output for IGBT control
 *    o_flyback - Output for flyback control
 *
 *
 *  Author: Jordan Jones
 *
*/



module Injector_Single(
	o_flyback,
	o_drive,
	i_enable,
	i_peak,
	i_hold,
	i_period,
	i_clk
);
output 	logic	o_flyback;
output 	logic	o_drive;
input				i_enable;
input				i_peak;
input				i_hold;
input				i_period;
input				i_clk;


			logic	m_set;
			logic m_reset;

Injector_FSM FSM(
	.o_flyback(o_flyback),
	.o_set(m_set),
	.o_reset(m_reset),
	.i_enable(i_enable),
	.i_peak(i_peak),
	.i_hold(i_hold),
	.i_period(i_period),
	.i_clk(i_clk)
);
			
//Output register, only has set and reset signals
always_ff @(posedge i_clk)begin
	if(m_set)o_drive = 1;
	else if(m_reset)o_drive = 0;
end

endmodule