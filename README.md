## Greyscale Processor – MIPS-Based Load/Store Architecture
## 📌 Overview

This project implements a custom **MIPS-based processor in Verilog**, designed specifically for grayscale image processing. The architecture supports only **LOAD** and **STORE** instructions to minimize hardware complexity and is ideal for embedded systems where pixel-level memory manipulation is key.

---

## 🧠 1. What is MIPS?

**MIPS (Microprocessor without Interlocked Pipeline Stages)** is a classic RISC-based architecture that is:

- Simple and modular
- Widely used in academic and embedded environments
- Based on fixed 32-bit instruction size

**Instruction Types:**

- **R-Type** – Register operations (e.g., `add`, `sub`)
- **I-Type** – Immediate or memory instructions (e.g., `lw`, `addi`)
- **J-Type** – Jump instructions (e.g., `j`, `jal`)

---
![Screenshot 2025-06-29 113125](https://github.com/user-attachments/assets/1e0ef67f-0ee0-49b7-9e20-64993f887b3f)

## 🧩 2. MIPS 5-Stage Pipeline

The classic MIPS processor is divided into 5 pipeline stages:

### Instruction Fetch (IF)

- Fetch instruction from memory
- `IR = Mem[PC]`, then `PC = PC + 4`

### Instruction Decode (ID)

- Decode opcode, register fields
- Read registers
- Sign-extend immediate

### Execute (EX)

- ALU performs operation or address calculation

### Memory Access (MEM)

- Access memory (`lw`/`sw`)

### Write Back (WB)

- Write result back to register

![1_3Vz0lKtZR7c8l6YXRwUGDA](https://github.com/user-attachments/assets/e897b5d8-a36a-4e8e-96aa-03d494feaf6a)

## 3. Our Custom Minimalist MIPS Processor

This design removes non-essential logic and focuses on just two instructions:

- `LOAD` (opcode = 1)
- `STORE` (opcode = 0)

### Key Features:

- Reduced components and logic gates
- No need for ALU control or branch logic
- Minimal instruction format
- Fewer clock cycles per instruction

---

## 🧱 4. Components Used

- Program Counter (PC)
- Instruction Memory
- General Purpose Registers
- Data Memory (RAM)
- ALU (supports only addition)
- Sign Extend Unit
- Multiplexers (x3)
- Control Unit (1-bit opcode)
- Sequence Controller

![Screenshot 2025-06-29 120015](https://github.com/user-attachments/assets/beff74f3-0353-4519-b60b-4c11f69cdd59)
[31]        => Opcode (1-bit)
[30:26]     => Source Register (rs)
[25:24]     => (Removed - not needed)
[23:16]     => Target Register (rt)
[15:0]      => 16-bit Immediate (offset)
**Example Hex Instruction:** `80010041`

**Binary Representation:** `10000000_00000001_00000000_01000001`

---

## ⏱️ 6. Instruction Execution Flow

**LOAD Instruction Flow:**

```

FETCH → DECODE → READ → WRITEBACK → FETCH

```

**STORE Instruction Flow:**

```

FETCH → DECODE → WRITE → FETCH

```

---
![Screenshot 2025-06-29 113357](https://github.com/user-attachments/assets/89c12128-f69a-428e-9f16-4342e5c7264b)

## ⚙️ 7. Step-by-Step Operation

<details>
<summary><strong>Instruction Fetch (IF)</strong></summary>

- Program Counter sends address to Instruction Memory
- Instruction is fetched and loaded into Instruction Register
- PC is incremented by 4

</details>
<details>
<summary><strong>Instruction Decode (ID)</strong></summary>

- Decode `rs`, `rt`, and offset
- Fetch values from register file
- Sign-extend offset

</details>
<details>
<summary><strong>Execute / Address Calculation</strong></summary>

- ALU calculates:
    
    `Effective Address = Reg[rs] + SignExtend(offset)`
    

</details>
<details>
<summary><strong>Memory Access – LOAD</strong></summary>

- Memory is accessed using the calculated address
- Value is routed via multiplexer to register writeback

</details>
<details>
<summary><strong>Memory Access – STORE</strong></summary>

- Value from `Reg[rt]` is written to memory at calculated address

</details>
<details>
<summary><strong>Write Back (for LOAD only)</strong></summary>

- Data from memory is written to target register (`rt`)

</details>

## 🧮 8. Optimizations

- **Only 1-bit opcode** (LOAD = 1, STORE = 0)
- **Bits [25:24] removed** – not required for 64-pixel test
- Supports:
    - Up to 256 registers via 8-bit `rt`
    - 65,536 memory locations using 16-bit offset

---

## 🎯 9. Target Application – Grayscale Processing

This processor design is intended for use with a grayscale image unit, where only memory read/write operations are needed to process pixel data. It is extended or integrated with an image-processing pipeline on an FPGA or ASIC.

---



## 📝 10. Summary

This project demonstrates a stripped-down, efficient version of a MIPS processor tailored for a specific embedded task—**image data handling through LOAD/STORE instructions**. The custom design highlights how reducing instruction sets and pipeline stages can lead to a practical processor for grayscale computation, without unnecessary control logic or complex datapaths.
