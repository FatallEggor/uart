module tick_gen
	#( parameter	M = 1,
			N = 1
	)
	(
	input wire	clk,reset,
	output reg	tick
	);

	reg [N-1:0]count_reg, count_next;

	always @(posedge clk, posedge reset)
		if (reset)
			count_reg <= 0;
		else
			count_reg <= count_next;
	
	always @*
		begin
		count_next = count_reg;
		tick = 1'b0;

		if (count_reg == M)
			begin
			count_next = 0;
			tick = 1'b1;
			end
		else
			count_next = count_reg + 1;
		end
	
endmodule
