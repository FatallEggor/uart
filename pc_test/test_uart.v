module test_uart 
 	#(
	parameter	DBIT = 		8,
			SB_TICK = 	16,
			DVSR = 		163,
			DVSR_BIT = 	8,
			FIFO_W =	5
	)
	(
	input wire		clk, reset,
	input wire		uart_c, 
	input wire		rx_fem,
	output wire		tx_full_fem, rx_full_fem, rx_empty_fem, 
	output wire 		tx_fem,
	output wire		led0, led1, led2, led3, led4, led5, led6, led7 
	);

	wire [7:0]	loop;
	wire		uart_c_db, uart_c_tick;
	
	db_fsm 		#(.N(19))db_fsm_ex2(.clk(clk), .sw(uart_c), .db(uart_c_db));

	sw_tick		sw_t(.clk(clk), .reset(reset), .sw(uart_c_db), .sw_tick(uart_c_tick));

	uart		#(.DBIT(DBIT), .SB_TICK(SB_TICK), .DVSR(DVSR), .DVSR_BIT(DVSR_BIT), .FIFO_W(FIFO_W)) uart_female (.clk(clk), .reset(reset), .rd_uart(uart_c_tick), .wr_uart(uart_c_tick), .rx(rx_fem), .w_data(loop), .tx_full(tx_full_fem), .rx_full(rx_full_fem), .rx_empty(rx_empty_fem), .tx(tx_fem), .r_data(loop));


	assign {led0, led1, led2, led3, led4, led5, led6, led7} = loop;

endmodule

