# Greyscale
A greyscaling unit design with a MIPS processor(ISA architecture) [verilog code and documentation]


Starting with the documentation first we need to understand the basics of MIPS architecture(with the neccessary basics of Computer Architecture as well)

What is MIPS?

MIPS (Microprocessor without Interlocked Pipeline Stages) is a RISC-based processor architecture developed in the early 1980s. It’s known for its simplicity, performance, and modularity, making it a popular choice in academic environments and embedded systems.
Instruction Size: 32 bits (fixed)

Registers: 32 General Purpose Registers (GPRs), each 32-bit wide
Memory Access: Through lw (load word), sw (store word)

Instruction Types:

R-type: Register-based (e.g., add, sub) 

I-type: Immediate or memory (e.g., lw, addi)

J-type: Jump (e.g., j, jal)

OKAY now coming to the stages of MIPS processor-HERE is an elaborated discussion about it:-

![nternal-Architecture-of-the-Pipelined-MIPS-5-Stages](https://github.com/user-attachments/assets/e820197c-a707-41a6-bb46-89776164d851)

1. IF – Instruction Fetch
Goal: Fetch the next instruction from memory

Inputs: Program Counter (PC)

Outputs: Instruction (IR), updated PC

Typical operations:

IR = Mem[PC]

PC = PC + 4
(📦 Happens in the Instruction Memory.)

        
2. ID – Instruction Decode and Register Fetch

Goal: Decode the instruction and fetch operands from registers

Inputs: Instruction (IR)

Outputs: Control signals, Read Data 1, Read Data 2, Sign-extended immediate

Typical operations:

Decode opcode, rs, rt, rd

Read registers: ReadData1 = Reg[rs], ReadData2 = Reg[rt]

Sign-extend immediate if needed

🧠 Happens in the Control Unit, Register File, and Sign-Extend Unit.


3. EX – Execute / Address Calculation
Goal: Perform ALU operation or calculate memory address

Inputs: Operands, ALU control signals

Outputs: ALU Result, Zero flag (for branches), calculated address

Typical operations:

Arithmetic/logic: ALUResult = A op B

Branch: BranchTarget = PC + (Immediate << 2)

🔧 Happens in the ALU and branch decision logic.


4. MEM – Memory Access
Goal: Access memory if it's a load (lw) or store (sw) instruction

Inputs: ALU result (address), write data (if storing), control signals

Outputs: Read data from memory or write confirmation

Typical operations:

lw: ReadData = Mem[ALUResult]

sw: Mem[ALUResult] = WriteData

📦 Happens in the Data Memory module.


5. WB – Write Back
Goal: Write the result back to a register (if needed)

Inputs: Data from ALU or Memory

Outputs: Register File updated

Typical operations:

Reg[rd] = ALUResult (R-type)

Reg[rt] = MemData (I-type load)

💾 Happens in the Register File.

 HERE is the full fledged Diagram of the MIPS Processor-![Screenshot 2025-06-29 113125](https://github.com/user-attachments/assets/2981af8c-52ad-495a-85bb-dd84ca370ef3)
 There are many operation of this processor mainly divided into 
 -R type,J type,I type and hence there are lots of different instruction set.Large numbers of instruction set leads to large number of multiplexer logic 
![Screenshot 2025-06-29 113357](https://github.com/user-attachments/assets/cd6ca211-f4d1-4347-b761-9da1b3f28bad)

 THE TOTAL COMPONENTS IN THE GIVEN PROCESSOR ARE-
 Register (8)
,Multiplexor (10)
,Random Access Memory (1)
,Sign Extend Module (8)
,Register File (1)
,Shift Module (1)
,Concatenate Module (1)
,Arithmetic Logic Unit (1)
,Arithmetic Logic Unit Controller (1)
,Sequence Controller (1) 

For our purpose we were working on a module which works on LOAD and STORE operations only.We did not need other commands and hence extra components.Hence we designed a Processor which works on  Reduced Instruction Set Computer Architecture-
![image](https://github.com/user-attachments/assets/b379c2d2-2846-4864-b49f-863a35b0929b)

Here are the main Takeaways
1)REDUCED COMPONENTS(dedicated for LOAD and STORE operations only)

Its consists of

Program Counter
,Instrution Memory
,Random Access Memory
,Sign Extend Module
,General Purpose Registers
,Arithmetic Logic Unit(minimal set of operation no need of ALU controller)
,Sequence controller(with 1 bit opcode judgement-LOAD or STORE)
,Multiplexer(3)

2)REDUCED INSTRUCTION SET
As there are just two instructions we are using only 1 bit
opcode(1)-LOAD
opcode(0)-STORE

80010041 is sample instruction 

generally when rs is 00000 for LOAD msb for instruction is 8 and STORE msb is 0

This is the binary representation  1000 0000 0000 0001 0000 0000 0100 0001 

opcode-instruction[31]

rs-instruction[30:26]

rt-instruction[23:16]

imm-instruction[15:0]

3)REDUCED CYCLES

FOR READ INSTRUCTION- FETCH->DECODE->READ->WRITEBACK->FETCH

FOR WRITE INSTRUCTION- FETCH->DECODE->WRITE->FETCH
(no need of execute cycle: working add instruction of ALU only)


WORKING of LOAD and STORE instructions:



🔄 Execution Flow for lw and sw
We’ll break it down by datapath stages:




🔹 1. Instruction Fetch (IF)
The PC sends the address to Instruction Memory.

The fetched instruction (lw or sw) goes to the Instruction Register.

PC is incremented (PC = PC + 4) using the adder for next instruction.

📦 Affected Units:

PC, Instruction Memory, Adder (+4)

🔹 2. Instruction Decode / Register Fetch (ID)
rs and rt fields are decoded.

Register values Read data 1 (rs) and Read data 2 (rt) are read from the Register File.

The immediate (offset) is sign-extended to 32 bits for address calculation.

📦 Affected Units:

Registers, Sign-extend block

🔹 3. Execution / Address Calculation (EX)
The ALU calculates:
Effective Address = Register[rs] + Sign-extended(offset)

The ALUSrc control signal selects between rt and the immediate for ALU operand 2 (set to use immediate in lw/sw).

📦 Affected Units:

ALU, Mux1 (selects between reg and immediate), Control Unit

🔹 4A. Memory Access – Load Word (lw)
The effective address goes to Data Memory.

The control signal MemRead is enabled.

Memory[Effective Address] is read and goes to the Mux before the Write-back stage.

📦 Affected Units:

Data Memory (read mode), Mux0, MemRead

🔹 4B. Memory Access – Store Word (sw)
The effective address goes to Data Memory.

Read data 2 (i.e., rt value) is sent as the data to store.

The control signal MemWrite is enabled.

📦 Affected Units:

Data Memory (write mode), MemWrite

🔹 5. Write Back (Only for lw)
The data read from memory is sent through Mux0.

Mux0 selects this data (controlled by MemtoReg).

The data is written to rt in the Register File.

RegWrite signal is enabled.

📦 Affected Units:

Register File, Mux0, RegWrite


Modifications We made to make it work:
opcode-instruction[31]

rs-instruction[30:26]

rt-instruction[23:16]

imm-instruction[15:0]

We removed some 2 bits (24 & 25 ) as it is not required for 64 pixeled image we are testing for.The user may add it purposefuly and make the changes in the register section of the processor code
it can select 2^8=256 register selections.And 2^16(offset+rs) registers select in the memory file.

