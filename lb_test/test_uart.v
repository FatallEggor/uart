module test_uart 
 	#(
	parameter	DBIT = 		8,
			SB_TICK = 	16,
			DVSR = 		163,
			DVSR_BIT = 	8,
			FIFO_W =	2
	)
	(
	input wire		clk, reset,
	input wire		rd_uart, 
	input wire		rx_fem, rx_m,
	output wire		tx_full_fem, rx_full_fem, rx_empty_fem, 
	output wire		tx_full_m, rx_full_m, rx_empty_m, 
	output wire 		tx_fem, tx_m,
	output wire		led0, led1, led2, led3, led4, led5, led6, led7 
	);

	wire [7:0]	r_data_fem, r_data_m;
	wire		rd_uart_db, rd_uart_tick;
	
	db_fsm 		#(.N(19))db_fsm_ex2(.clk(clk), .sw(rd_uart), .db(rd_uart_db));

	sw_tick		sw_t(.clk(clk), .reset(reset), .sw(rd_uart_db), .sw_tick(rd_uart_tick));

	uart		#(.DBIT(DBIT), .SB_TICK(SB_TICK), .DVSR(DVSR), .DVSR_BIT(DVSR_BIT), .FIFO_W(FIFO_W)) uart_female (.clk(clk), .reset(reset), .rd_uart(rd_uart_tick), .wr_uart(1'b0), .rx(rx_fem), .w_data(8'b11111111), .tx_full(tx_full_fem), .rx_full(rx_full_fem), .rx_empty(rx_empty_fem), .tx(tx_fem), .r_data(r_data_fem));

	uart		#(.DBIT(DBIT), .SB_TICK(SB_TICK), .DVSR(DVSR), .DVSR_BIT(DVSR_BIT), .FIFO_W(FIFO_W)) uart_male (.clk(clk), .reset(reset), .rd_uart(rd_uart_tick), .wr_uart(1'b0), .rx(rx_m), .w_data(r_data_m), .tx_full(tx_full_m), .rx_full(rx_full_m), .rx_empty(rx_empty_m), .tx(tx_m), .r_data(r_data_m));

	assign {led0, led1, led2, led3, led4, led5, led6, led7} = r_data_fem;

endmodule

