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
			
//Output register
always_ff @(posedge i_clk)begin
	if(m_set)o_drive = 1;
	else if(m_reset)o_drive = 0;
end

endmodule