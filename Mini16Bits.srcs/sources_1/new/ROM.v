`timescale 1ns / 1ps

module ROM( // M27c512
	input wire E, 			// Active low, Enable Standby
	input wire G, 			// Active low, Enable Read | Z
	input wire [15:0] A,
	inout wire [7:0] Q
);

	reg [7:0] rom_memory [0:`ROM_size-1];
	
	integer i;
	initial begin		
		for (i = 0; i < `ROM_size-1; i = i + 1) begin
        	rom_memory[i] = 8'hFF;
    	end
    	
    	rom_memory[0]  = 8'h00; // NOP
    	rom_memory[1]  = 8'h01; // LDA ..
    	rom_memory[2]  = 8'h00; // ... from RAM[0]L
    	rom_memory[3]  = 8'h00; // ... from RAM[0]H
    	rom_memory[4]  = 8'h02; // LDB ..
    	rom_memory[5]  = 8'h02; // ... from RAM[2]L
    	rom_memory[6]  = 8'h00; // ... from RAM[2]H
    	rom_memory[7]  = 8'h03; // LCA ..
    	rom_memory[8]  = 8'h21; // ...
    	rom_memory[9]  = 8'h43; // ... const : 4321
    	rom_memory[10] = 8'h04; // LCB ..
    	rom_memory[11] = 8'h34; // ...
    	rom_memory[12] = 8'h12; // ... const : 1234
    	rom_memory[13] = 8'h05; // STA ..
    	rom_memory[14] = 8'h04; // ... to RAM[4]L
    	rom_memory[15] = 8'h00; // ... to RAM[4]H
    	rom_memory[16] = 8'h06; // LDAX
    	rom_memory[17] = 8'h07; // STAX
    	rom_memory[18] = 8'h08; // LDRX
    	
    	rom_memory[19] = 8'h09; // JMP ..
    	rom_memory[20] = 8'h17; // ... to ROM[22]L
    	rom_memory[21] = 8'h00; // ... to ROM[22]H
    	rom_memory[22] = 8'h0A; // JMX
    	rom_memory[23] = 8'h0B; // JZ ..
    	rom_memory[24] = 8'h1A; // ... to ROM[26]L
    	rom_memory[25] = 8'h00; // ... to ROM[26]H
    	rom_memory[26] = 8'h0C; // JZN ..
    	rom_memory[27] = 8'h1D; // ... to ROM[29]L
    	rom_memory[28] = 8'h00; // ... to ROM[29]H
    	rom_memory[29] = 8'h0D; // JC ..
    	rom_memory[30] = 8'h20; // ... to ROM[32]L
    	rom_memory[31] = 8'h00; // ... to ROM[32]H
    	rom_memory[32] = 8'h0E; // JCN ..
    	rom_memory[33] = 8'h23; // ... to ROM[35]L
    	rom_memory[34] = 8'h00; // ... to ROM[35]H
    	rom_memory[35] = 8'h0F; // JN ..
    	rom_memory[36] = 8'h26; // ... to ROM[38]L
    	rom_memory[37] = 8'h00; // ... to ROM[38]H
    	rom_memory[38] = 8'h10; // JOV ..
    	rom_memory[39] = 8'h29; // ... to ROM[41]L
    	rom_memory[40] = 8'h00; // ... to ROM[41]H
    	rom_memory[41] = {2'b11, 3'b000, 3'b001}; // CPY A to B
    	
    	rom_memory[42] = 8'h12; // SEC
    	rom_memory[43] = 8'h11; // CLC
    	rom_memory[44] = 8'h03; // LCA ..
    	rom_memory[45] = 8'hFF; // ...
    	rom_memory[46] = 8'hFF; // ... const : FFFF (-1)
    	rom_memory[47] = 8'h04; // LCB ..
    	rom_memory[48] = 8'hFF; // ...
    	rom_memory[49] = 8'hFF; // ... const : FFFF (-1)
    	rom_memory[50] = 8'h13; // ADD
    	
    	rom_memory[51] = 8'h11; // CLC
    	rom_memory[52] = 8'h14; // SUB
    	
    	rom_memory[53] = 8'h03; // LCA ..
    	rom_memory[54] = 8'h00; // ...
    	rom_memory[55] = 8'h0F; // ... const : 3840
    	rom_memory[56] = 8'h15; // ADDC
    	rom_memory[57] = 8'h01; // ...
    	rom_memory[58] = 8'h00; // ... const : 1
    	
    	rom_memory[59] = 8'h16; // SCLR
    	rom_memory[60] = 8'h17; // SADD
    	
    	rom_memory[61] = 8'h18; // AND
    	rom_memory[62] = 8'h19; // OR
    	rom_memory[63] = 8'h1A; // XOR
    	rom_memory[64] = 8'h1B; // NOT
    	
    	rom_memory[65] = 8'h03; // LCA ..
    	rom_memory[66] = 8'b0101_0101; // ...
    	rom_memory[67] = 8'b0101_0101; // ... whatever to shift
    	rom_memory[68] = 8'h1C; // LSL
    	rom_memory[69] = 8'h1D; // ASL
    	rom_memory[70] = 8'h1E; // LSR
    	rom_memory[71] = 8'h1F; // ASR
    	rom_memory[72] = 8'h20; // ROL
    	rom_memory[73] = 8'h21; // ROR
    	
    	rom_memory[74] = 8'h03; // LCA ..
    	rom_memory[75] = 8'h0C; // ...
    	rom_memory[76] = 8'h00; // ... const : 12
    	rom_memory[77] = 8'h04; // LCB ..
    	rom_memory[78] = 8'hFD; // ...
    	rom_memory[79] = 8'hFF; // ... const : -3
    	rom_memory[80] = 8'hF0; // MUL
    	rom_memory[81] = 8'hF1; // DIV
    	
    	rom_memory[82] = 8'h22; // PUSH
    	rom_memory[83] = 8'h03; // LCA ..
    	rom_memory[84] = 8'h00; // ...
    	rom_memory[85] = 8'h00; // ... const : 0
    	rom_memory[86] = 8'h23; // POP
    	
    	rom_memory[87] = 8'h24; // CALL
    	rom_memory[88] = 8'h64; // ... to ROM[100]L
    	rom_memory[89] = 8'h00; // ... to ROM[100]H
    	// ..
    	rom_memory[90] = 8'h09;
    	rom_memory[91] = 8'hC8; // ... to ROM[200]L
    	rom_memory[92] = 8'h00; // ... to ROM[200]H
    	// ...
    	rom_memory[100] = 8'h22; // PUSH
    	rom_memory[101] = 8'h03; // LCA ..
    	rom_memory[102] = 8'hAA; // ...
    	rom_memory[103] = 8'hAA; // ... const : AAAA
    	rom_memory[104] = 8'h23; // POP
    	rom_memory[105] = 8'h25; // RET

	end
	
	assign Q = (!E && !G) ? rom_memory[A] : 8'bz;
    
endmodule


/*
add_force {/simusimu/MAIN_clk} -radix bin {0 0ns} {1 41667ps} -repeat_every 83333ps

open_wave_config {D:/Xilinx/Projects/Mini16Bits/simusimu_behav.wcfg}
add_force {/simusimu/MAIN_clk} -radix bin {0 0ns} {1 500ns} -repeat_every 1000ns
run 500 us

---------------------------------------------------------------------------------------------------
 Architectural Registers:
---------------------------------------------------------------------------------------------------

0 - A - Accumulator
1 - B - Auxiliary
2 - C - Result
3 - S - Summatory
4 - X - Index (Indirect Jump)
5 - P - Stack Pointer
6 - F - Flag Register (Status Register or Processor Status Word) 
	Flag_Overflow   : C overflow
	Flag_Negative   : C < 0
	Flag_Zero 		: C == 0
	Flag_Carry		: TODO

** - PC - Program Counter
** - IR - Instruction Register	
** - TS - Timing State Counter

---------------------------------------------------------------------------------------------------
 DATA MOVEMENT
---------------------------------------------------------------------------------------------------

 ** | CPY  | None | Copy register : {2'b11, 3'b(Source), 3'b(Destiny)} // "TODO: Swap"
 00 | NOP  | None | No operation

 01 | LDA  | Addr | Load A from RAM 
 02 | LDB  | Addr | Load B from RAM

 03 | LCA  | Cons | Load A with ROM constant
 04 | LCB  | Cons | Load B with ROM constant
 
 05 | STA  | Addr | Store A to RAM
 
 06 | LDAX | None | Load A from RAM with X as address
 07 | STAX | None | Store A to RAM with X as address
 
 08 | LDRX | None | Load A from ROM with X as address
  
---------------------------------------------------------------------------------------------------
 CONTROL FLOW, BRANCHES & FLAGS
---------------------------------------------------------------------------------------------------

 09 | JMP  | Addr | Jump to ROM
 0A | JMX  | None | Jump to ROM with X as address

 0B | JZ   | Addr | Jump if Zero Flag == 1
 0C | JZN  | Addr | *Jump if Zero Flag == 0
 0D | JC   | Addr | Jump if Carry Flag == 1
 0E | JCN  | Addr | *Jump if Carry Flag == 0
 0F | JN   | Addr | Jump if Negative Flag == 1
 10 | JOV  | Addr | Jump if Overflow Flag == 1 (Signed math error)

---------------------------------------------------------------------------------------------------
 ARITHMETIC & BOOLEAN (Bitwise)
---------------------------------------------------------------------------------------------------

 11 | CLC  | None | Forces Carry Flag to 0
 12 | SEC  | None | Forces Carry Flag to 1

 13 | ADD  | None | C = A + B + Carry : Compute Carry Flag
 14 | SUB  | None | C = A - B - Carry (Borrow): Compute Carry Flag

 15 | ADDC | Cons | C = A + Const
 16 | SCLR | None | S = 0
 17 | SADD | None | S = S + C
 
 18 | AND  | None | C = A & B
 19 | OR   | None | C = A | B
 1A | XOR  | None | C = A ^ B
 1B | NOT  | None | A = !A

 1C | LSL  | None | A = C = Shift left A: Zero-Pad the bottom, Carry <= Bit 15
 1D | ASL  | None | same as LSL
 1E | LSR  | None | A = C = Shift right logical A: Zero-Pad the top, Carry <= Bit 0 
 1F | ASR  | None | A = C = Shift right arithmetic A: Duplicate sign bit, Carry <= Bit 0
 
 20 | ROL  | None | A = C = Rotate Left A : Bit 0 <= Old Carry, New Carry <= Bit 15 
 21 | ROR  | None | A = C = Rotate Right A: Bit 15 <= Old Carry, New Carry <= Bit 0

 F0 | MUL  | None | C = A * B
 F1 | DIV  | None | C = A / B

---------------------------------------------------------------------------------------------------
 STACK & SYSTEM
---------------------------------------------------------------------------------------------------

 22 | PUSH | None | Push A onto Stack
 23 | POP  | None | Pop Stack into A

 24 | CALL | Addr | Go to Subroutine (Push PC to Stack, Jump to Addr,)
 25 | RET  | None | Return from Subroutine (Pop Stack into PC)

*/
