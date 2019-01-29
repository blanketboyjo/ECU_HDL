//////////////////////////////////////////////////////////////////////////////
//
//					Clock Sync Module
//		This module will take in a clock (Needs to be divided first) and create 4 out of phase clock
//		signals.
// 	
//		The signals are as follows:
//			i_clock					- Initial Clock Value
//			o_clockPhased[3:0]	- Series of staggered clocks that share frequency but
//								  		have equally spaced phases
//
//		Author: Jordan Jones
//
//
//		Known Issues:
//		1/15/19 - None
//
//		Log:
//		1/15/19 - Initial Creation
//
//////////////////////////////////////////////////////////////////////////////

module Clock_Sync(
	i_reset,
	i_clock,
	o_clockPhased,
	o_periodPhased);

input 						i_clock;
input							i_reset;
output 	logic	[3:0] 	o_clockPhased			= 4'b0;
output	logic	[3:0]		o_periodPhased			= 4'b0;


//Interal 2 bit signal for clocks;
			logic	[1:0]		m_clockCount			= 2'b0;

//Parameter for periods, needs to be divisible by 4
//Final count will be twice this value
parameter 		[7:0]		c_HALF_PERIOD_COUNTS = 8'd99;
parameter		[7:0]		c_PERIOD_ZERO_START	= 8'd49;
parameter		[7:0]		c_PERIOD_ONE_START	= 8'd0;
parameter		[7:0]		c_PERIOD_TWO_START	= 8'd49;
parameter		[7:0]		c_PERIOD_THREE_START	= 8'd0;

//Internal registers for tracking phased clocks
			logic [3:0]		m_clockPhasedLast		= 4'b0;
//Internal signal for checking if rising edge of phased clocks
			logic [3:0]		m_clockPhasedRising;

//Internal registers for tracking periods, these need to be changed if 
//counts per period is changed
			logic [7:0]		m_periodCount0			= 8'd0;
			logic [7:0]		m_periodCount1 		= 8'd0;
			logic	[7:0]		m_periodCount2 		= 8'd0;
			logic [7:0]		m_periodCount3 		= 8'd0;



//Two bit counter for clock phasing
always_ff @ (posedge i_clock)begin
	m_clockCount <= m_clockCount + 2'b1;
	case(m_clockCount)
		0: o_clockPhased 			= 4'b0001;
		1:	o_clockPhased 			= 4'b0010;
		2: o_clockPhased 			= 4'b0100;
		3: o_clockPhased 			= 4'b1000;
		default: o_clockPhased 	= 4'b0000;
	endcase
end
	

//Period Counter for period0
always_ff @(posedge o_clockPhased[0]) begin
	if(i_reset == 1)begin
		m_periodCount0 = c_PERIOD_ZERO_START;
		o_periodPhased[0] = 1'b0;
	end else begin
		if(m_periodCount0 >= c_HALF_PERIOD_COUNTS)begin
			o_periodPhased[0] = ~o_periodPhased[0];
			m_periodCount0 = 8'd0;
		end else begin
			m_periodCount0 = m_periodCount0 + 8'd1;
		end
	end
end

always_ff @(posedge o_clockPhased[1]) begin
	if(i_reset == 1)begin
		m_periodCount1 = c_PERIOD_ONE_START;
		o_periodPhased[1] = 1'b0;
	end else begin
		if(m_periodCount1 >= c_HALF_PERIOD_COUNTS)begin
			o_periodPhased[1] = ~o_periodPhased[1];
			m_periodCount1 = 8'd0;
		end else begin
			m_periodCount1 = m_periodCount1 + 8'd1;
		end
	end
end


always_ff @(posedge o_clockPhased[2]) begin
	if(i_reset == 1)begin
		m_periodCount2 = c_PERIOD_TWO_START;
		o_periodPhased[2] = 1'b1;
	end else begin
		if(m_periodCount2 >= c_HALF_PERIOD_COUNTS)begin
			o_periodPhased[2] = ~o_periodPhased[2];
			m_periodCount2 = 8'd0;
		end else begin
			m_periodCount2 = m_periodCount2 + 8'd1;
		end
	end
end


always_ff @(posedge o_clockPhased[3]) begin
	if(i_reset == 1)begin
		m_periodCount3 = c_PERIOD_THREE_START;
		o_periodPhased[3] = 1'b1;
	end else begin
		if(m_periodCount3 >= c_HALF_PERIOD_COUNTS)begin
			o_periodPhased[3] = ~o_periodPhased[3];
			m_periodCount3 = 8'd0;
		end else begin
			m_periodCount3 = m_periodCount3 + 8'd1;
		end
	end
end

endmodule
