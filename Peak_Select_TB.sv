`timescale 1ns / 1ps

module Peak_Select_TB();
logic m_clock = 0;
logic m_enable = 0;
logic m_muxControl;

Peak_Select uut(
	.i_clock(m_clock),
	.i_enable(m_enable),
	.o_muxControl(m_muxControl)
);

always begin
	#5 m_clock = 1'b1;
	#5 m_clock = 1'b0;
end

initial begin
	#20 m_enable = 1'b1;
	

end


endmodule