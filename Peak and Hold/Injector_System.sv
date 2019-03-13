/*
 *  Injector_System:
 *    This module contains four injector drivers
 *
 *  Inputs:
 *    i_clk     - Input clock to be divided
 *    i_enable  - 4 bit signal, enables injector, one per injector
 *    i_peak    - 4 bit signal, Peak current detection, one per injector
 *    i_hold    - 4 bit signal, Hold current detection, one per injector
 *
 *  Outputs:
 *    o_drive   - 4 bit signal, output for IGBT control, one per injector
 *    o_flyback - 4 bit signal, output for flyback control, one per injector
 *
 *
 *  Author: Jordan Jones
 *
*/




module Injector_System(
	o_drive,
	o_flyback,
	i_enable,
	i_peak,
	i_hold,
	i_clk
);

output 	logic	[3:0] o_drive;
output	logic	[3:0] o_flyback;
input 			[3:0] i_enable;
input 			[3:0] i_peak;
input 			[3:0] i_hold;
input						i_clk;

			logic	[3:0] m_phasedPeriod;

Period_Generator Phasor(
	.o_period(m_phasedPeriod),
	.i_clk(i_clk)
);

Injector_Single InjectorA(
	.o_flyback	(o_flyback[0]),
	.o_drive		(o_drive[0]),
	.i_enable	(i_enable[0]),
	.i_peak		(i_peak[0]),
	.i_hold		(i_hold[0]),
	.i_period	(m_phasedPeriod[0]),
	.i_clk		(i_clk)
);

Injector_Single InjectorB(
	.o_flyback	(o_flyback[1]),
	.o_drive		(o_drive[1]),
	.i_enable	(i_enable[1]),
	.i_peak		(i_peak[1]),
	.i_hold		(i_hold[1]),
	.i_period	(m_phasedPeriod[1]),
	.i_clk		(i_clk)
);

Injector_Single InjectorC(
	.o_flyback	(o_flyback[2]),
	.o_drive		(o_drive[2]),
	.i_enable	(i_enable[2]),
	.i_peak		(i_peak[2]),
	.i_hold		(i_hold[2]),
	.i_period	(m_phasedPeriod[2]),
	.i_clk		(i_clk)
);

Injector_Single InjectorD(
	.o_flyback	(o_flyback[3]),
	.o_drive		(o_drive[3]),
	.i_enable	(i_enable[3]),
	.i_peak		(i_peak[3]),
	.i_hold		(i_hold[3]),
	.i_period	(m_phasedPeriod[3]),
	.i_clk		(i_clk)
);


endmodule