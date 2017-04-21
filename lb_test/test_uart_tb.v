`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:39:10 12/25/2016
// Design Name:   cpu
// Module Name:   /home/egor/Projects/verilog/contr_tests/final/mips1/cpu_tb.v
// Project Name:  mips1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: cpu
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_uart_tb;

localparam T = 20;

	// Inputs
	reg 		clk;
	reg 		reset;
	reg 		rd_uart;

	// Outputs
	wire	 	tx_full_fem, rx_full_fem, rx_empty_fem;
	wire	 	tx_full_m, rx_full_m, rx_empty_m;
	wire		loop1, loop2;
	wire		led0, led1, led2, led3, led4, led5, led6, led7; 

	// Instantiate the Unit Under Test (UUT)
	test_uart #(.DBIT(8), .SB_TICK(16), .DVSR(1), .DVSR_BIT(1), .FIFO_W(2)) uut
	(
		.clk(clk), 
		.reset(reset),
		.rd_uart(rd_uart),
		.rx_fem(loop1), .rx_m(loop2),
		.tx_full_fem(tx_full_fem), .rx_full_fem(rx_full_fem), .rx_empty_fem(rx_empty_fem),
		.tx_full_m(tx_full_m), .rx_full_m(rx_full_m), .rx_empty_m(rx_empty_m),
		.tx_fem(loop1), .tx_m(loop2),
		.led0(led0), .led1(led1), .led2(led2), .led3(led3), .led4(led4), .led5(led5), .led6(led6), .led7(led7) 
		//.bus(bus)
	);
	always
	begin
		clk = 1'b1;
		#(T/2);
		clk = 1'b0;
		#(T/2);
	end

	initial
	begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		#20;
		reset = 0;
		rd_uart = 1'b0;
		#25000000;

		rd_uart = 1'b1;
		#20;
		rd_uart = 1'b0;
		#100;

		rd_uart = 1'b1;
		#20;
		rd_uart = 1'b0;
		#100;
		rd_uart = 1'b1;
		#20;
		rd_uart = 1'b0;
		#100;
		rd_uart = 1'b1;
		#20;
		rd_uart = 1'b0;
		#100;

	end
      
endmodule

