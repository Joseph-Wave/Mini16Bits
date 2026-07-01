`timescale 1ns / 1ps

`ifndef INCLUDED_FILE

	// Standards

	`define STACK_ADDR 16'h001F // The PUSH op. decrece the Stack Pointer
	
	`define ROM_size 256 // in Bytes
	`define RAM_size 128
	
	`define Flag_Overflow F[3]
	`define Flag_Negative F[2]
	`define Flag_Zero 	  F[1]
	`define Flag_Carry    F[0]
	
	`define _Flag_Overflow _F[3]
	`define _Flag_Negative _F[2]
	`define _Flag_Zero     _F[1]
	`define _Flag_Carry    _F[0]
	
	`define update_F \
		`Flag_Carry    <= `_Flag_Carry; \
		`Flag_Zero     <= `_Flag_Zero; \
        `Flag_Negative <= `_Flag_Negative; \
        `Flag_Overflow <= `_Flag_Overflow;
	
	`define reg_lookup_fill \
		begin \
			assign reg_lookup[0] = A; \
			assign reg_lookup[1] = B; \
			assign reg_lookup[2] = C; \
			assign reg_lookup[3] = S; \
			assign reg_lookup[4] = X; \
			assign reg_lookup[5] = P; \
			assign reg_lookup[6] = {12'b0, F}; \
		end
	
	// CPU definitions
	
	`define update_TS(reset_value) \
		begin \
			if (TS == reset_value) begin TS <= 4'b0000; fetch_execute <= 0; end \
			else  TS <= TS + 1; \
		end

	`define parameter_fetch(target_reg) \
		begin \
			case(TS) \
				4'b0000: begin OUT_addr <= PC; _ROM_R <= 1; end \
				4'b0001: begin target_reg[7:0] <= data; PC <= PC + 1; end \
				4'b0010: _ROM_R <= 0; \
				4'b0011: begin OUT_addr <= PC; _ROM_R <= 1; end \
				4'b0100: begin target_reg[15:8] <= data; PC <= PC + 1; end \
				4'b0101: _ROM_R <= 0; \
			endcase \
		end 

	`define rom_to_register(target_reg) \
		begin \
			`parameter_fetch(target_reg) \
			`update_TS(4'b0101) \
		end 

	`define ram_to_register(target_reg) \
		begin \
			`parameter_fetch(X) \
			case(TS) \
				4'b0110: begin OUT_addr <= X; _RAM_R <= 1; end \
				4'b0111: target_reg[7:0] <= data; \
				4'b1000: _RAM_R <= 0; \
				4'b1001: begin OUT_addr <= OUT_addr + 1; _RAM_R <= 1; end \
				4'b1010: target_reg[15:8] <= data; \
				4'b1011: _RAM_R <= 0;\
			endcase \
			`update_TS(4'b1011) \
		end
	
	`define register_to_ram(source_reg) \
		begin \
			`parameter_fetch(X) \
			case(TS) \
				4'b0110: begin OUT_addr <= X; OUT_data <= source_reg[7:0]; end \
				4'b0111: _RAM_W <= 1; \
				4'b1000: PORT_DIR <= 1; \
				4'b1001: _RAM_W <= 0; \
				4'b1010: begin PORT_DIR <= 0; OUT_addr <= OUT_addr + 1; OUT_data <= source_reg[15:8]; end \
				4'b1011: _RAM_W <= 1; \
				4'b1100: PORT_DIR <= 1; \
				4'b1101: _RAM_W <= 0; \
				4'b1110: PORT_DIR <= 0; \
			endcase \
			`update_TS(4'b1110) \
		end
	
	`define check_and_jump(flag) \
		begin \
			if (flag) IR <= OP_JMP; \
        	else begin PC <= PC + 2; fetch_execute <= 0; end \
		end

	`define register_to_stack(source_reg) \
		begin \
			case(TS) \
				4'b0000: begin OUT_addr <= P; OUT_data <= source_reg[7:0]; end \
				4'b0001: _RAM_W <= 1; \
				4'b0010: PORT_DIR <= 1; \
				4'b0011: _RAM_W <= 0; \
				4'b0100: begin PORT_DIR <= 0; OUT_addr <= OUT_addr - 1; OUT_data <= source_reg[15:8]; end \
				4'b0101: _RAM_W <= 1; \
				4'b0110: PORT_DIR <= 1; \
				4'b0111: _RAM_W <= 0; \
				4'b1000: begin PORT_DIR <= 0; P <= P - 2; end \
			endcase \
			`update_TS(4'b1000) \
		end
		
	`define stack_to_register(target_reg) \
		begin \
			case(TS) \
				4'b0000: begin OUT_addr <= P + 2; _RAM_R <= 1; end \
				4'b0001: target_reg[7:0] <= data; \
				4'b0010: _RAM_R <= 0; \
				4'b0011: begin OUT_addr <= OUT_addr - 1; _RAM_R <= 1; end \
				4'b0100: target_reg[15:8] <= data; \
				4'b0101: begin _RAM_R <= 0; P <= P + 2; end \
			endcase \
			`update_TS(4'b0101) \
		end

`endif
