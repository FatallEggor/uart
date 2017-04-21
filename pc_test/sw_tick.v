module sw_tick 
	(
	input wire clk,
	input wire reset,
	input wire sw,

	output reg sw_tick
	);
	
	reg sw_reg, sw_next; //sw0_tick;
	
	
	always @(posedge clk, posedge reset)
		begin
		if (reset)
			sw_reg = 0;
		else 
			sw_reg = sw_next;
		end


	always @*
		begin
		sw_next = sw;
		sw_tick = 0;
		if (!sw_reg & sw)
			sw_tick = 1;
		end
endmodule
