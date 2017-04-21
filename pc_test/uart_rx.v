
module uart_rx
	#(
	parameter	DBIT = 4'd8, //data bits
			SB_TICK = 5'd16	// tiks for stop bits
	)
	(
	input wire		clk, reset,
	input wire		rx, s_tick,
	output reg		rx_done_tick,
	output wire [7:0]	dout
	);

	localparam [1:0]
		idle	= 2'b00,
		start	= 2'b01,
		data	= 2'b10,
		stop	= 2'b11;

	reg [1:0]	state_reg, state_next;
	reg [3:0]	s_reg, s_next;
	reg [2:0]	n_reg, n_next;
	reg [7:0]	b_reg, b_next;

	always @(posedge clk, posedge reset)
		if (reset)
		begin
			state_reg 	<= idle;
			s_reg 		<= 4'b0;
			n_reg		<= 3'b0;
			b_reg		<= 8'b0;
		end
		else
		begin
			state_reg 	<= state_next;
			s_reg 		<= s_next;
			n_reg		<= n_next;
			b_reg		<= b_next;
		end
	
	always @*
	begin
		state_next = state_reg;
		rx_done_tick = 1'b0;
		s_next = s_reg;
		n_next = n_reg;
		b_next = b_reg;

		case (state_reg)
			idle:
				if (~rx)
				begin
					state_next = start;
					s_next = 4'b0;
				end
			start:
				if (s_tick)
					if (s_reg == 4'd7)
					begin
						state_next = data;
						s_next = 0;
						n_next = 0;
					end
					else
						s_next = s_reg + 4'b0001;
			data:
				if (s_tick)
					if (s_reg == 4'd15)
					begin
						s_next = 4'b0;
						b_next = {rx, b_reg[7:1]};

						if (n_reg == (DBIT - 1))
							state_next = stop;
						else
							n_next = n_reg + 3'b001;
					end
				else
					s_next = s_reg + 4'd1;
			stop:
				if (s_tick)
					if (s_reg == (SB_TICK - 1))
					begin
						state_next = idle;
						rx_done_tick = 1'b1;
					end
					else
						s_next = s_reg + 4'b0001;
		endcase
	end

	assign dout = b_reg;

endmodule
