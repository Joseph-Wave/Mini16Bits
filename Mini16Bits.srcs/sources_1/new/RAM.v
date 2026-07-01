`timescale 1ns / 1ps

`include "constants.vh"

module RAM( // MB84256A
	input wire CS, 			// Active low, Enable Standby
	input wire WE, 			// Active low, Enable Write
	input wire OE, 			// Active low, Enable Read | Z
	input wire [15:0] A,
	inout wire [7:0] D
);

	reg [7:0] ram_memory [0:`RAM_size-1];
	
	integer i;
	initial begin		
		for (i = 0; i < `RAM_size-1; i = i + 1) begin
        	ram_memory[i] = 8'h00;
    	end
    	
    	ram_memory[0] = 8'h0f;
    	ram_memory[1] = 8'hf0;
    	ram_memory[2] = 8'hf0;
    	ram_memory[3] = 8'h0f;
    	// ...
    	ram_memory[6] = 8'h88;
    	ram_memory[7] = 8'h99;
    	
	end
	
	assign D = (!CS && !OE && WE) ? ram_memory[A] : 8'bz;

    always @(posedge WE) begin
    	if (!CS && OE) begin
            ram_memory[A] <= D;
        end
    end
    
endmodule
