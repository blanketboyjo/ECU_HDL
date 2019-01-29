module SDRAM_Driver(
	i_Clock,
	io_DQ,
	o_Address,
	o_BA,
	o_nCAS,
	o_CLKE,
	o_CLK,
	o_nCS,
	o_DQM,
	o_nRAS,
	o_nWE,
	m_Address
);

input		logic 			i_Clock;
inout 	logic [15:0] 	io_DQ;
output	logic [12:0]	o_Address;
output	logic [1:0]		o_BA;
output	logic				o_nCAS;
output 	logic				o_CLKE;
output	logic				o_CLK;
output 	logic				o_nCS;
output	logic	[1:0]		o_DQM;
output	logic				o_nRAS;
output	logic				o_nWE;

parameter 	p_COMMAND_PRECHARGE_ALL 	= 3'd0, 
				p_COMMAND_AUTO_REFRESH 		= 3'd1, 
				p_COMMAND_NOP 					= 3'd2,
				p_COMMAND_MODE_SET 			= 3'd3;
			logic	[2:0]		m_CommandSet 	= 3'd0;
input		logic	[12:0]	m_Address		;
			logic	[12:0]	m_AddressConst;
			logic				m_UseConstAddr = 1'b0;
//Controls command outputs
always_comb begin
	case(m_CommandSet)
	p_COMMAND_PRECHARGE_ALL: begin
		o_CLKE 			= 1'b1;
		o_nCS 			= 1'b0;
		o_nCAS 			= 1'b1;
		o_nRAS 			= 1'b0;
		o_nWE 			= 1'b0;
		m_AddressConst	= 13'b0;
		m_UseConstAddr = 1'b1;
	end
	
	p_COMMAND_AUTO_REFRESH: begin
		o_CLKE 			= 1'b1;
		o_nCS 			= 1'b0;
		o_nCAS 			= 1'b0;
		o_nRAS 			= 1'b0;
		o_nWE 			= 1'b1;
		m_AddressConst	= 13'b0;
		m_UseConstAddr = 1'b1;
		
	end
	
	p_COMMAND_NOP: begin
		o_CLKE 			= 1'b1;
		o_nCS 			= 1'b0;
		o_nCAS 			= 1'b1;
		o_nRAS 			= 1'b1;
		o_nWE 			= 1'b1;
		m_AddressConst	= 13'b0;
		m_UseConstAddr = 1'b1;

	end
	
	p_COMMAND_MODE_SET: begin
		o_CLKE 			= 1'b1;
		o_nCS 			= 1'b0;
		o_nCAS 			= 1'b0;
		o_nRAS 			= 1'b0;
		o_nWE 			= 1'b0;	
		m_AddressConst	= 13'b0000000100111;//Cas 2, Sequential, Full Page mode
		m_UseConstAddr = 1'b1;
	end
	
	
	default: begin
		o_CLKE 			= 1'b0;
		o_nCS 			= 1'b0;
		o_nCAS 			= 1'b0;
		o_nRAS 			= 1'b0;
		o_nWE 			= 1'b0;
		m_AddressConst	= 13'd0;
		m_UseConstAddr = 1'b0;
	end
	endcase

end

always_comb begin
	if(m_UseConstAddr == 1'b1) begin
		o_Address = m_AddressConst;
	end else begin
		o_Address = m_Address;
	end
end

parameter [3:0] 	p_INIT						= 3'd0,
						p_INIT_NOP					= 3'd1,
						p_INIT_PRECHARGE			= 3'd2,
						p_INIT_AUTO_REFRESH_ONE	= 3'd3,
						p_INIT_AUTO_REFRESH_TWO	= 3'd4,
						p_INIT_MODE_SET			= 3'd5,
						p_IDLE						= 3'd6;
logic 	[4:0]		m_StatePresent 			= p_INIT;
logic		[4:0]		m_StateNext;

//Loads next state
always_ff @ (posedge i_Clock)begin
	m_StatePresent = m_StateNext;
end

//FSM outputs and state changes
always_comb begin
	m_StateNext  = p_INIT;
	m_ResetDelay = 1'b0;
	m_CommandSet = p_COMMAND_NOP;
	
	case(m_StatePresent)
	p_INIT: begin
		m_ResetDelay = 1'b1;
	end
	
	//Set NOP Commands until it boots
	p_INIT_NOP: begin
		//If delay is met, move on
		if(m_DelayMet == 1'b1) begin
			m_StateNext 	= p_INIT_PRECHARGE;
			m_ResetDelay	= 1'b1;
		//If not keep going in this state
		end else begin
			m_StateNext 	= p_INIT_NOP;
			m_ResetDelay	= 1'b0;			
		end
	end
	
	//Send a single precharge command then wait
	p_INIT_PRECHARGE: begin		
		//If delay is met move on
		if(m_DelayMet == 1'b1) begin
			m_StateNext		= p_INIT_AUTO_REFRESH_ONE;
			m_ResetDelay	= 1'b1;
		end else begin
			m_StateNext		= p_INIT_PRECHARGE;
		end
		//First clock is precharge
		if(m_DelayStart == 1'b1)begin
			m_CommandSet  = p_COMMAND_PRECHARGE_ALL;
		//All else are NOPs
		end else begin
			m_CommandSet  = p_COMMAND_NOP;
		end
	end
	
	//Send a single Autorefresh command then wait
	p_INIT_AUTO_REFRESH_ONE: begin
		
		//If delay is met move on
		if(m_DelayMet == 1'b1) begin
			m_StateNext		= p_INIT_AUTO_REFRESH_TWO;
			m_ResetDelay	= 1'b1;
		end else begin
			m_StateNext		= p_INIT_AUTO_REFRESH_ONE;
		end
		
		//First clock is auto refresh
		if(m_DelayStart == 1'b1)begin
			m_CommandSet  = p_COMMAND_AUTO_REFRESH;
		//All else are NOPs
		end else begin
			m_CommandSet  = p_COMMAND_NOP;
		end
		
	end
	
		//Send a single Autorefresh command then wait
	p_INIT_AUTO_REFRESH_TWO: begin

		
		//If delay is met move on
		if(m_DelayMet == 1'b1) begin
			m_StateNext		= p_INIT_MODE_SET;
			m_ResetDelay	= 1'b1;
		end else begin
			m_StateNext		= p_INIT_AUTO_REFRESH_TWO;
		end
		
		//First clock is auto refresh
		if(m_DelayStart == 1'b1)begin
			m_CommandSet  = p_COMMAND_AUTO_REFRESH;
		//All else are NOPs
		end else begin
			m_CommandSet  = p_COMMAND_NOP;
		end
		
	end
	
	p_INIT_MODE_SET: begin
		
		//If delay is met move on
		if(m_DelayMet == 1'b1)begin
			m_StateNext = p_IDLE;
		
		end else begin
			m_StateNext = p_INIT_MODE_SET;
		end
		
		//First clock is MODE set
		if(m_DelayStart == 1'b1)begin
			m_CommandSet = p_COMMAND_MODE_SET;
		//All else are NOPS
		end else begin
			m_CommandSet = p_COMMAND_NOP;
		end
		
	end
	
	p_IDLE: begin
		m_StateNext = p_IDLE;
	end
	
	default: begin
		m_StateNext  = p_INIT;
		m_ResetDelay = 1'b1;
		m_CommandSet = p_COMMAND_NOP;
	end
	endcase
end		

//For counter delay
always_comb begin
	m_TargetDelay = 16'd0;
	case(m_StatePresent)
		p_INIT:begin
			m_TargetDelay = 16'd0;		
		end		
		
		p_INIT_NOP:begin
			//Wait for 200 us
			m_TargetDelay = 16'd10000;
		end
		
		p_INIT_PRECHARGE:begin
			//Wait for 3 clocks for CAS
			m_TargetDelay = 16'd3;
		end
		
		p_INIT_AUTO_REFRESH_ONE:begin
			//Wait for 9 clocks for CAS
			m_TargetDelay = 16'd9;
		end
		
		p_INIT_AUTO_REFRESH_TWO:begin
			//Wait for 9 clocks for CAS
			m_TargetDelay = 16'd9;
		end
		
		p_INIT_MODE_SET:begin
			//Wait for 2 clocks based on MRD
			m_TargetDelay = 16'd1;
		end
		
		p_IDLE:begin
			
		end
		
		default:begin
			m_TargetDelay = 16'd0;
		end
	endcase
end

logic 			m_ResetDelay = 1'b0;
logic [15:0]	m_DelayCount = 16'b0;
logic [15:0]   m_TargetDelay;
logic 			m_DelayMet;
logic				m_DelayStart;
logic				m_CounterRunning;

assign m_DelayMet 		= m_DelayCount == m_TargetDelay;
assign m_DelayStart 		= m_DelayCount == 16'b0;
assign m_CounterRunning = m_DelayCount != m_TargetDelay;

//Counter for delays
always_ff @ (posedge i_Clock) begin
	//Reset count if signal is present
	if(m_ResetDelay == 1'b1)begin
		m_DelayCount = 16'b0;
	//Only count if not at max
	end else begin
		m_DelayCount = m_DelayCount + m_CounterRunning;
	end
end

endmodule
