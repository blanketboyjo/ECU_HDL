`timescale 1ns / 1ps

module Clock_Sync_TB();

logic 			m_clock 			= 0;
logic				m_reset			= 0;
logic	[3:0]		m_clockPhased;
logic	[3:0]		m_periodPhased;

Clock_Sync uut(
	.i_reset(m_reset),
	.i_clock(m_clock),
	.o_clockPhased(m_clockPhased),
	.o_periodPhased(m_periodPhased));

	
always begin
	#5 m_clock = 1'b1;
	#5 m_clock = 1'b0;
end

initial begin
	m_reset = 1;
	#100 m_reset = 0;

end

endmodule