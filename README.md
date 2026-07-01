# 16-Bit Homebrew CPU

A small hobby project developed over the course of a week to explore and better understand the architectural decisions behind classic microprocessors.

The system implements a custom 16-bit CPU designed to interface with a 8-bit bus of a **27C256 EPROM** and **MB84256 SRAM**. The instruction set draws inspiration from the **MOS 6502** while incorporating concepts commonly found in scientific calculators of the era.


# Architecture

## Register Set

| ID | Register | Description |
|----|----------|-------------|
| 0 | A | Primary accumulator |
| 1 | B | Auxiliary register |
| 2 | C | Result register |
| 3 | S | Summation accumulator |
| 4 | X | Index register (indirect addressing and jumps) |
| 5 | P | Stack pointer |
| 6 | F | Status / Flag register |
| — | PC | Program counter |
| — | IR | Instruction register |
| — | TS | Timing state counter |

### Status Flags

| Flag | Description |
|--------|-------------|
| Overflow | Arithmetic overflow detected in register C |
| Negative | Result in C is negative |
| Zero | Result in C is zero |
| Carry | Carry/Borrow flag |

---

# Instruction Set

## Data Movement

| Opcode | Mnemonic | Operand | Description |
|---------|---------|----------|-------------|
| ** | CPY | None | Copy register (`{2'b11, Source[2:0], Destination[2:0]}`) |
| 00 | NOP | None | No operation |
| 01 | LDA | Addr | Load A from RAM |
| 02 | LDB | Addr | Load B from RAM |
| 03 | LCA | Const | Load immediate constant into A |
| 04 | LCB | Const | Load immediate constant into B |
| 05 | STA | Addr | Store A to RAM |
| 06 | LDAX | None | Load A from RAM using X as address |
| 07 | STAX | None | Store A to RAM using X as address |
| 08 | LDRX | None | Load A from ROM using X as address |

---

## Control Flow and Branching

| Opcode | Mnemonic | Operand | Description |
|---------|---------|----------|-------------|
| 09 | JMP | Addr | Unconditional jump |
| 0A | JMX | None | Jump using X as ROM address |
| 0B | JZ | Addr | Jump if Zero flag is set |
| 0C | JZN | Addr | Jump if Zero flag is clear |
| 0D | JC | Addr | Jump if Carry flag is set |
| 0E | JCN | Addr | Jump if Carry flag is clear |
| 0F | JN | Addr | Jump if Negative flag is set |
| 10 | JOV | Addr | Jump if Overflow flag is set |

---

## Arithmetic, Flag and Logical Operations

| Opcode | Mnemonic | Operand | Description |
|---------|---------|----------|-------------|
| 11 | CLC | None | Clear Carry flag |
| 12 | SEC | None | Set Carry flag |
| 13 | ADD | None | `C = A + B + Carry` |
| 14 | SUB | None | `C = A - B - Carry(Borrow)` |
| 15 | ADDC | Const | `C = A + Constant` |
| 16 | SCLR | None | Clear summation register (`S = 0`) |
| 17 | SADD | None | `S = S + C` |
| 18 | AND | None | `C = A & B` |
| 19 | OR | None | `C = A | B` |
| 1A | XOR | None | `C = A ^ B` |
| 1B | NOT | None | `A = ~A` |
| 1C | LSL | None | A = C = Logical Shift Left A: Zero-Pad the bottom, Carry <= Bit 15 |
| 1D | ASL | None | Arithmetic shift left *(identical to LSL)* |
| 1E | LSR | None | A = C = Logical Shift right A: Zero-Pad the top, Carry <= Bit 0  |
| 1F | ASR | None | A = C = Arithmetic Shift right A: Duplicate sign bit, Carry <= Bit 0 |
| 20 | ROL | None | Rotate left through Carry |
| 21 | ROR | None | Rotate right through Carry |
| F0 | MUL | None | `C = A × B` |
| F1 | DIV | None | `C = A ÷ B` |

---

## Stack and System Operations

| Opcode | Mnemonic | Operand | Description |
|---------|---------|----------|-------------|
| 22 | PUSH | None | Push A onto stack |
| 23 | POP | None | Pop stack into A |
| 24 | CALL | Addr | Call subroutine (push PC and jump) |
| 25 | RET | None | Return from subroutine (pop PC) |

---

# Future Work

Planned improvements include:
- Floating-point arithmetic support
- Interrupt handling
- Hardware multiply/divide synth
- Assembler improvements
