module Table(
	o_data,
	i_data,
	i_x,
	i_y,
	i_writeEnable,
	i_clk
);
output	logic	[15:0] 	o_data;
input				[15:0] 	i_data;
input				[5:0] 	i_x;
input				[5:0] 	i_y;
input							i_writeEnable;
input							i_clk;

logic [15:0] m_mem[1023:0];

always_ff @ (posedge i_clk)begin
	if(i_writeEnable)m_mem[{i_y, i_x}] <= i_data;
end

assign o_data = m_mem[{i_y, i_x}];
endmodule
