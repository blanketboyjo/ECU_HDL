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
 *    o_set     - Output for turning on IGBT
 *    o_reset   - Output for turning off IGBT
 *    o_flyback - Output for flyback control
 *
 *
 *  Author: Jordan Jones
 *
*/

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

//State switching
always_ff @(posedge i_clk)begin
	m_PS = m_NS;
end


//Next state processing
always_comb begin
	case(m_PS)
    //Only leave idle if enable is high
		IDLE: begin
			m_NS  = IDLE;
			if(i_enable == 1)	m_NS 	= PEAK;
		end
    //Stay in peak until peak current achieved
		PEAK: begin
			m_NS	= PEAK;
			if(i_peak == 1)	m_NS 	= HOLD;
		end
    //Stay in hold state until enable is lowered
		HOLD: begin
			m_NS	= HOLD;
			if(i_enable == 0) m_NS	= IDLE;
		end
		default: 				m_NS	= IDLE;
	endcase
end


//Outputs
always_comb begin
  //Default values, to turn everything off
	o_flyback 	<= 0;
	o_set 		<= 0;
	o_reset 		<= 1;		
	case(m_PS)
    //Ensure output is off during IDLE
		IDLE: begin
			o_reset 		<= 1;		
		end
    //Keep output on during peak mode
		PEAK: begin
			o_set 		<= 1;
		end
    //Turn on flybacks during Hold
    //Turn off igbt if hold current reached
    //Turn on igbt at start of period
		HOLD: begin
			o_flyback 	<= 1;
			o_set			<= i_period;
			o_reset		<= i_hold;
		end
		default: ;
		endcase
end



endmodule