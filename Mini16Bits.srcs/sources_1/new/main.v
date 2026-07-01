`timescale 1ns / 1ps
`default_nettype none

`include "constants.vh"

module main(
	input wire clk,
	output wire [1:0] led
);

	wire [7:0]  BUS_DATA;
	wire [15:0] BUS_ADDR;
	wire ROM_R, RAM_W, RAM_R;
	wire MEM_ON;
	
	CPU CPU_inst (
		.clk(clk),
		.addr(BUS_ADDR),
		.data(BUS_DATA),
		.ROM_R(ROM_R),
		.MEM_ON(MEM_ON),
		.RAM_W(RAM_W),
		.RAM_R(RAM_R)
	);

    ROM ROM_inst (
		.E(!MEM_ON),	// Active low, Enable Standby
		.G(!ROM_R), 	// Active low, Enable Read | Z
		.A(BUS_ADDR),
		.Q(BUS_DATA)
	);		
	
	RAM RAM_inst (
		.CS(!MEM_ON),	// Active low, Enable Standby
		.WE(!RAM_W), 	// Active low, Enable Write
		.OE(!RAM_R), 	// Active low, Enable Read | Z
		.A(BUS_ADDR),
		.D(BUS_DATA)
	);
	
	assign led[1:0] = BUS_DATA[5:4];

endmodule
