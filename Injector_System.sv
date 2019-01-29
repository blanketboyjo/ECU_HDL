module Injector_System(
	i_clock,
	i_reset,
	i_enable,
	i_peakSense,
	i_holdSense,
	o_injectorDrive
);

input 						i_clock;
input							i_reset;
input 			[3:0]		i_enable;
input				[3:0]		i_peakSense;
input				[3:0]		i_holdSense;
output	logic	[3:0]		o_injectorDrive;

			logic	[3:0]		m_periodPhased;
			logic	[3:0]		m_clockPhased;

Clock_Sync clockSystem(
	.i_reset(i_reset),
	.i_clock(i_clock),
	.o_clockPhased(m_clockPhased),
	.o_periodPhased(m_periodPhased));

endmodule 