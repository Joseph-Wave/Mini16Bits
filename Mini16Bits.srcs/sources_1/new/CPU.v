`timescale 1ns / 1ps

`include "constants.vh"

module CPU(
	input wire clk,
	output wire [15:0] addr,
	inout wire [7:0] data,
	output wire MEM_ON,
	output wire ROM_R,
	output wire RAM_R,
	output wire RAM_W
);
	
//-----------------------------------------------------------------------------
// Main Registers
//-----------------------------------------------------------------------------

	reg [15:0] A = 0; 	// 0 - Accumulator
	reg [15:0] B = 0; 	// 1 - Auxiliary
	reg [15:0] C = 0;   // 2 - Result
	reg [15:0] S = 0; 	// 3 - Summatory
	reg [15:0] X = 0; 	// 4 - Index (Indirect Jump)
	reg [15:0] P = `STACK_ADDR; 	// 5 - Stack Pointer
	reg [3:0]  F = { 	// 6 - Flag Register (Status Register or Processor Status Word)
		1'b0, 		// Flag_Overflow
		1'b0, 		// Flag_Negative
		1'b0, 		// Flag_Zero
		1'b0};		// Flag_Carry
	reg [15:0] PC = 0;	// ** - Program Counter
	reg [7:0]  IR = 0; 	// ** - Instruction Register
	reg [3:0]  TS = 0; 	// ** - Timing State Counter
	
	reg [15:0] OUT_addr = 0;	// Output Address Register
	reg [7:0] OUT_data = 0;		// Output Data Register
	
	reg PORT_DIR = 0; 
	assign data = (PORT_DIR) ? OUT_data : 8'bz; // 1 : output, 0 : input
	assign addr = OUT_addr;
	
	reg _MEM_ON = 0; assign MEM_ON = _MEM_ON;	// Enable RAM and ROM chips
	always @(posedge clk) _MEM_ON <= 1; 		// just wait to initialize de CPU
	reg _ROM_R = 0; assign ROM_R = _ROM_R;		// RAM/ROM timing registers
	reg _RAM_R = 0; assign RAM_R = _RAM_R;
	reg _RAM_W = 0; assign RAM_W = _RAM_W;
	
	reg fetch_execute = 0;
		
//-----------------------------------------------------------------------------
// Instrucction Fetch and Execute
//-----------------------------------------------------------------------------
	
	localparam [7:0]
		OP_CPY		= 8'hC0,
	    OP_NOP		= 8'h00, 
	    OP_LDA		= 8'h01,
	    OP_LDB		= 8'h02,
	    OP_LCA		= 8'h03,
	    OP_LCB 		= 8'h04,
	    OP_STA		= 8'h05,
	    OP_LDAX		= 8'h06,
	    OP_STAX		= 8'h07,
	    OP_LDRX 	= 8'h08,
	    OP_JMP		= 8'h09,
	    OP_JMX		= 8'h0A,
	    OP_JZ		= 8'h0B,
	    OP_JZN		= 8'h0C,
	    OP_JC		= 8'h0D,
	    OP_JCN		= 8'h0E,
	    OP_JN		= 8'h0F,
	    OP_JOV		= 8'h10,
	    OP_CLC		= 8'h11,
	    OP_SEC		= 8'h12,
	    OP_ADD		= 8'h13,
	    OP_SUB		= 8'h14,
	    OP_ADDC		= 8'h15,
	    OP_SCLR		= 8'h16,
	    OP_SADD		= 8'h17,
	    OP_AND		= 8'h18,
	    OP_OR		= 8'h19,
	    OP_XOR		= 8'h1A,
	    OP_NOT		= 8'h1B,	    
	    OP_LSL		= 8'h1C,
	    OP_ASL		= 8'h1D,
		OP_LSR	 	= 8'h1E,
		OP_ASR		= 8'h1F,	
		OP_ROL		= 8'h20,
		OP_ROR		= 8'h21,
		OP_MUL		= 8'hF0,
		OP_DIV		= 8'hF1,
		OP_PUSH 	= 8'h22,
    	OP_POP 		= 8'h23,
    	OP_CALL		= 8'h24,
    	OP_REG		= 8'h25;
		
//-----------------------------------------------------------------------------
// Combinational block, ALU, Flag update
//-----------------------------------------------------------------------------
	
	// These are wires. Calculate on wires, save on clock (doorstep)	
	reg [16:0] ALU_out;
	reg [3:0] _F;
	
	always @(*) begin
	
		ALU_out = {`Flag_Carry, C};
		
		`_Flag_Overflow = 1'b0;
		`_Flag_Carry = 1'b0;
			
		case (IR)
			OP_ADD: begin
				ALU_out = {1'b0, A} + {1'b0, B} + {16'b0, `Flag_Carry};
				`_Flag_Overflow = (A[15] == B[15]) && (ALU_out[15] != A[15]);
			end
			   	
			OP_SUB: begin
				ALU_out = {1'b0, A} - {1'b0, B} - {16'b0, `Flag_Carry};
				`_Flag_Overflow = (A[15] != B[15]) && (ALU_out[15] == B[15]);
			end
			
			OP_AND: ALU_out = {`Flag_Carry, A & B};
            OP_OR:  ALU_out = {`Flag_Carry, A | B};
            OP_XOR: ALU_out = {`Flag_Carry, A ^ B};
            OP_NOT: ALU_out = {`Flag_Carry, ~A};
            
            OP_LSL, // TODO: Flag_Overflow for these shifters
            OP_ASL: ALU_out = {A[15], A[14:0], 1'b0}; 
			OP_LSR: ALU_out = {A[0], 1'b0, A[15:1]};
			OP_ASR: ALU_out = {A[0], A[15], A[15:1]};
			OP_ROL: ALU_out = {A[15], A[14:0], `Flag_Carry};
			OP_ROR: ALU_out = {A[0], `Flag_Carry, A[15:1]};
				
			default:;
			
		endcase
		
		`_Flag_Carry = ALU_out[16];
		`_Flag_Zero = (ALU_out[15:0] == 16'b0);
		`_Flag_Negative = ALU_out[15];
	end

//-----------------------------------------------------------------------------
// Main State Machine
//-----------------------------------------------------------------------------
	
	wire [15:0] reg_lookup [0:6]; `reg_lookup_fill

	always @(posedge clk) begin
	
		if (fetch_execute == 0) begin // Fetch phase // TODO: posedge pair to reduce clock cycles 
			case(TS)
				4'b0000: begin PORT_DIR <= 0; OUT_addr <= PC; _ROM_R <= 1; end
				4'b0001: begin IR <= data; PC <= PC + 1; end 
				4'b0010: _ROM_R <= 0;
			endcase
			if (TS == 4'b0010) begin TS <= 4'b0000; fetch_execute <= 1; end
			else  TS <= TS + 1;
	    
	    end else begin // Execute phase
	    
			case(IR)
			
				OP_NOP: fetch_execute <= 0;
				
				// DATA MOVEMENT
				
				default: begin
            		// OP_CPY
            		if (IR[7:6] == OP_CPY[7:6]) begin 
						case (IR[2:0])
							3'h0: A <= reg_lookup[IR[5:3]];
							3'h1: B <= reg_lookup[IR[5:3]];
							3'h2: C <= reg_lookup[IR[5:3]];
							3'h3: S <= reg_lookup[IR[5:3]];
							3'h4: X <= reg_lookup[IR[5:3]];
							3'h5: P <= reg_lookup[IR[5:3]];
							3'h6: F <= reg_lookup[IR[5:3]][3:0];
							default:;
						endcase
						fetch_execute <= 0;
            		end
            	end
				
				OP_LDA: `ram_to_register(A)
				OP_LDB: `ram_to_register(B)
				OP_LCA: `rom_to_register(A)
            	OP_LCB: `rom_to_register(B)

            	OP_STA: `register_to_ram(A)
           	
            	OP_LDAX: begin
            		TS <= 4'b0110; // skip parameter fetch
					IR <= OP_LDA;
            	end

            	OP_STAX: begin
            		TS <= 4'b0110;
					IR <= OP_STA;
            	end

            	OP_LDRX: begin 
					case(TS)
						4'b0000: begin OUT_addr <= X; _ROM_R <= 1; end
						4'b0001: A[7:0] <= data;
						4'b0010: _ROM_R <= 0;
						4'b0011: begin OUT_addr <= OUT_addr + 1; _ROM_R <= 1; end
						4'b0100: A[15:8] <= data;
						4'b0101: _ROM_R <= 0;
					endcase
					`update_TS(4'b0101)
            	end
            	
            	// CONTROL FLOW & FLAGS
            	
            	OP_JMP: begin
            		`parameter_fetch(X)
            		if (TS == 4'b0110) PC <= X; 
            		`update_TS(4'b0110)
            	end
            	    	
            	OP_JMX: begin PC <= X; fetch_execute <= 0; end

            	OP_JZ:	`check_and_jump(`Flag_Zero)
				OP_JZN: `check_and_jump(!`Flag_Zero)
				OP_JC:	`check_and_jump(`Flag_Carry)
				OP_JCN: `check_and_jump(!`Flag_Carry)
				OP_JN:	`check_and_jump(`Flag_Negative)
				OP_JOV: `check_and_jump(`Flag_Overflow)

            	// ARITHMETIC & BOOLEAN (Bitwise)
            	
            	OP_CLC: begin `Flag_Carry <= 0; fetch_execute <= 0;	end
            	OP_SEC: begin `Flag_Carry <= 1; fetch_execute <= 0;	end            	
            	
            	OP_ADD, OP_SUB, OP_AND, OP_OR, OP_XOR, OP_NOT: begin
            		C <= ALU_out;
					`update_F
					fetch_execute <= 0;
            	end
            	
            	OP_LSL, OP_ASL, OP_LSR, OP_ASR, OP_ROL, OP_ROR: begin
					A <= ALU_out[15:0];
					C <= ALU_out[15:0];
					`update_F
					fetch_execute <= 0;
				end
            	
            	OP_ADDC: begin
            		`parameter_fetch(B)
            		if (TS == 4'b0101) begin IR <= OP_ADD; TS <= 4'b0000; end
            		else TS <= TS + 1;
            	end
            	
            	OP_SCLR: begin S <= 16'b0; fetch_execute <= 0;	end
            	OP_SADD: begin S <= S + C; fetch_execute <= 0;	end

				OP_MUL: begin C <= $signed(A) * $signed(B); fetch_execute <= 0; end // Temporal, Will be done in software anyway
         		OP_DIV: begin C <= $signed(A) / $signed(B); fetch_execute <= 0; end
          
          		OP_PUSH: `register_to_stack(A)
          		
          		OP_POP: `stack_to_register(A)
          		
          		OP_CALL: begin
          			`parameter_fetch(X)
          			case(TS)
						4'b0110: begin OUT_addr <= P; OUT_data <= PC[7:0]; end
						4'b0111: _RAM_W <= 1;
						4'b1000: PORT_DIR <= 1;
						4'b1001: _RAM_W <= 0;
						4'b1010: begin PORT_DIR <= 0; OUT_addr <= OUT_addr - 1; OUT_data <= PC[15:8]; end
						4'b1011: _RAM_W <= 1;
						4'b1100: PORT_DIR <= 1;
						4'b1101: _RAM_W <= 0;
						4'b1110: begin PORT_DIR <= 0; P <= P - 2; PC <= X; end
					endcase
					`update_TS(4'b1110)
          		end
       
          		OP_REG: `stack_to_register(PC)
          	
            endcase   

	    end // if else
	end // always
	


endmodule
