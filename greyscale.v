`timescale 1ns/1ps
module system_top (
    input clk,
    input reset,
  input [31:0] ext_data_9,
  input [31:0] ext_data_10,
  input [31:0] ext_data_11,
  input [31:0] ext_data_12,
  output wire [31:0] mips_out,
  output wire [31:0] pc_out,
  output wire [31:0] instruction_out,
  output wire [31:0] reg_data1_out,
  output wire [31:0] reg_data2_out,
  output wire [31:0] read_data_out,
  output wire [31:0] address_out,
    output wire [7:0]  final_grayscale,
    output wire done,
  output reg [31:0] register2,
  output reg [31:0] register3,
  output reg [31:0] register4,
  output reg [31:0] register5,
  output reg [31:0] register9,
  output wire [23:0]rgb,
  output wire store_pix_out,
  output wire load_pix_out,
  output wire [7:0]gray_ipu_out,
  output reg [6:0] rgb_index_check,
  output reg[31:0] grayscale_9c, 
  output reg[31:0] grayscale_10c, 
  output reg[31:0] grayscale_11c,
  output reg[31:0] grayscale_12c,
  output reg [2047:0] array,
  output reg [2047:0] grayscale_flat_out,
  output reg [2047:0] flat_mem_data_out
  
);

  reg [31:0] register_2, register_3, register_4, register_5,register_9;//not req
   reg [23:0] rgb_pixel;
    wire [23:0] rgb_to_ipu_wire;
  reg  [6:0]  rgb_index;
    wire [7:0]  gray_ipu;
    wire [7:0]  gray_bus;
    wire        done_signal;
    reg         load_pixel, store_pixel;
// Declare grayscale storage registers
  reg [31:0] grayscale_9, grayscale_10, grayscale_11, grayscale_12;//not req
  reg [31:0] grayscale_array [0:63]; 



    
  
    mips_top1 mips_core (
        .clk(clk),
        .reset(reset),
      .grayscale_flat_out(grayscale_flat_out),
        .ext_data_9(grayscale_9),
        .ext_data_10(grayscale_10),
        .ext_data_11(grayscale_11),
        .ext_data_12(grayscale_12),
        .out(mips_out),
        .reg_data1_out(reg_data1_out),
        .reg_data2_out(reg_data2_out),
        .read_data_out(read_data_out),
        .address_out(address_out),
        .instruction_out(instruction_out),
        .register_2(register_2),
        .register_3(register_3),
        .register_4(register_4),
      .register_5(register_5),
      .register_9(register_9),
      .array(array),
      .flat_mem_data_out(flat_mem_data_out)
      
    );
    
    bus_interface bus_if (
        .clk(clk),
        .reset(reset),
        .reg_data_in(rgb_pixel),
        .load_pixel(load_pixel),
        .store_pixel(store_pixel),
        .gray_data_out(gray_bus),
        .done(done_signal),
        .rgb_to_ipu(rgb_to_ipu_wire),
        .gray_from_ipu(gray_ipu)
    );

    rgb_to_grayscale ipu (
        .rgb_in(rgb_to_ipu_wire),
        .gray_out(gray_ipu)
    );

    reg [3:0] cycle;
    always @(posedge clk or posedge reset) begin
       
        if (reset) begin
            cycle <= 0;
            rgb_index <= 0;
            load_pixel <= 0;
            store_pixel <= 0;
        end else begin
            case (cycle)
                0: begin
                    load_pixel <= 0;
                    store_pixel <= 0;
                    cycle <= 1;
                end
                1: begin
                    load_pixel <= 1;
                  store_pixel<=1;
                    cycle <= 2;
                end
                2: begin
                  
                    if (done_signal) begin
                        store_pixel <= 1;
                      load_pixel <= 0;
                        cycle <= 3;
                    end
                end
                3: begin
                    store_pixel <= 0;
                  if (rgb_index < 64) begin                          //change here
                        rgb_index <= rgb_index + 1;
                        cycle <= 0;
                    end else begin
                        cycle <= 4;  // Done processing all pixels
                    end
                end
            endcase
        end
    end
 integer i;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < 64; i = i + 1) begin
          grayscale_array[i] <= 32'd0;
        end
    end else if (done_signal && gray_bus != 0) begin
      grayscale_array[rgb_index+1] <= {24'd0, gray_bus};  // Pack 8-bit grayscale into 32-bit
    end
end

 always @(*) begin
    rgb_pixel = array[(rgb_index)*32 +: 24];
end
  
  genvar j;
generate
  for (j = 0; j < 64; j = j + 1) begin : flatten_loop_32
    assign grayscale_flat_out[(j+1)*32-1 -: 32] = grayscale_array[j];
  end
endgenerate

    
    assign final_grayscale = gray_bus;
    assign done = done_signal;
assign register2 = register_2;
    assign register3 = register_3;
    assign register4 = register_4;
    assign register5 = register_5;
  assign register9 = register_9;
  assign rgb=rgb_pixel;
    assign load_pix_out=load_pixel;
    assign store_pix_out=store_pixel;
    assign gray_ipu_out=gray_ipu;
  assign rgb_index_check=rgb_index;
assign grayscale_9c=grayscale_9;
  assign grayscale_10c=grayscale_10;
  assign grayscale_11c=grayscale_11;
  assign grayscale_12c=grayscale_12;
endmodule

module mips_top1 (
  	input clk,
    input reset,
  input reg [2047:0] grayscale_flat_out,
  input wire [31:0] ext_data_9,
  input wire [31:0] ext_data_10,
  input wire [31:0] ext_data_11,
  input wire [31:0] ext_data_12,
  output wire [31:0] out,
  output wire [31:0] reg_data1_out,
  output wire [31:0] reg_data2_out,
  output wire [31:0] read_data_out,
  output wire [31:0] address_out,
  output wire [31:0] instruction_out,
  output wire [31:0] register_2,
  output wire [31:0] register_3,
  output wire [31:0] register_4,
  output wire [31:0] register_5,
  output wire [31:0] register_9,
  output reg [2047:0] array,
  output wire pc_fin,
  output reg [2047:0] flat_mem_data_out
  
);

  wire [31:0] pc_out, instruction;
    wire [5:0] opcode;
  wire [4:0] rs;
  wire [7:0] rt;
  wire [4:0] rd;
    wire [2:0] alu_op;
    wire alusrc, regdst, regwrite, memread, memwrite, memtoreg;
  wire [31:0] reg_data1, reg_data2;
  wire [7:0] write_reg;
  wire [31:0] sign_ext_imm;
  wire [31:0] alu_input2, alu_result;
  wire [31:0] mem_data_out;
  wire [31:0] write_data;

  assign opcode = instruction[31];
  assign rs = instruction[30:26];
  assign rt = instruction[23:16];
  assign rd = instruction[20:16];
 
   // Program Counter
   ProgramCounter pc_inst (
        .clk(clk),
        .reset(reset),
        .pc_new(pc_out)
       
    );
 
    // Instruction Memory
    instr_mem imem (
        .address(pc_out),
        .instruction(instruction)
    );
    
    
    //sequence controller
     seq_control control_unit (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .RegDst(regdst),
        .RegWrite(regwrite),
        .ALUSrc(alusrc),
        .ALUOp(alu_op),
        .MemRead(memread),
        .MemWrite(memwrite),
        .MemtoReg(memtoreg)
    );
    
    //register selct mux
        reg_write_mux regdst_mux (
        .rt(rt),
        .rd(rd),
        .sel(regdst),
        .write_reg(write_reg)
    );
    
    //registers 32*32
    register regs (
        .clk(clk),
        .reg_write_en(regwrite),
        .rs(rs),
        .rt(rt),
        .write_reg(write_reg),
        .rd_data(write_data),
        .reg1_data(reg_data1),
        .reg2_data(reg_data2),
        .reg_out_2(register_2),
        .reg_out_3(register_3),
        .reg_out_4(register_4),
        .reg_out_5(register_5),
      .reg_out_9(register_9),
        .ext_data_9(ext_data_9),
        .ext_data_10(ext_data_10),
        .ext_data_11(ext_data_11),
      .ext_data_12(ext_data_12),
      .reg_flat_out(array),
      .grayscale_flat_out(grayscale_flat_out)
    );

 // Sign Extend
    sign_extend sext (
      .in(instruction[15:0]),
        .out(sign_ext_imm)
    );


// ALU Src Mux
    alu_source_mux alusrc_mux (
        .reg_data2(reg_data2),
        .immediate(sign_ext_imm),
        .alusrc(alusrc),
        .alu_input_b(alu_input2)
    );
    
     // ALU
    alu alu_unit (
        .a(reg_data1),
        .b(alu_input2),
        .alu_control(alu_op),
        .result(alu_result)
    );
    
     // Data Memory
   memory_reg dmem (
        .address(alu_result),
        .write_data(reg_data2),
        .MemRead(memread),
        .MemWrite(memwrite),
        .clk(clk),
     .read_data( mem_data_out),
     .flat_mem_data_out(flat_mem_data_out)
    );
    
    
    // MemtoReg Mux
    memtoreg memtoreg_mux (
        .alu_result(alu_result),
        .mem_data(mem_data_out),
        .mem_to_reg(memtoreg),
        .write_back_data(write_data)
    );
  
assign address_out = alu_result; // Already assigned at the bottom
assign out = write_data; 
     assign instruction_out = instruction;
assign reg_data1_out = reg_data1;
assign reg_data2_out = reg_data2;
assign read_data_out = mem_data_out;
endmodule



   
module ProgramCounter (
    input         clk,
    input         reset,
  output wire[31:0] pc_new
);

  reg [31:0] pc_reg;

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_reg <= 31'b1;
        else 
            pc_reg <= pc_reg+31'h1;
    end

    assign pc_new = pc_reg;

endmodule






module instr_mem (
  input wire [31:0] address,        // PC input
  output wire [31:0] instruction    // 32-bit instruction output
);

    // 256 words (1024 bytes), word-aligned
  reg [31:0] memory [0:2199];

    // Word address = address[9:2] (because address is byte-addressed)
  assign instruction = memory[address[31:0]];

    // Optional: initialize from file
    initial begin
        $readmemh("instructions.hex", memory); // You can use .mem or .hex
    end

endmodule






module seq_control (
    input clk,
    input reset,
    input  opcode,  // From instruction register
    output reg RegDst,
    output reg RegWrite,
    output reg ALUSrc,
    output reg [2:0] ALUOp,
    output reg MemRead,
    output reg MemWrite,
    output reg MemtoReg
);

    // Define states as parameters instead of enum
    localparam [2:0] 
        FETCH     = 3'b000,
        DECODE    = 3'b001,
        EXECUTE   = 3'b010,
        MEM_READ  = 3'b011,
        MEM_WRITE = 3'b100,
        WB        = 3'b101;

    reg [2:0] state, next_state;

    // State register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= FETCH;
        else
            state <= next_state;
    end

    // Next state logic and control signals
    always @(*) begin
        // Default values
        RegDst = 0; RegWrite = 0; ALUSrc = 0; ALUOp = 2'b00;
        MemRead = 0; MemWrite = 0; MemtoReg = 0;
        next_state = state;

        case (state)
            FETCH: begin
              if (opcode == 1'b0) begin
                    ALUSrc=1;
                
            end
                MemRead = 1;
                next_state = DECODE;
              
            end

            DECODE: begin
                ALUSrc = 1;
              if (opcode == 6'b1) begin
                MemRead = 1;// lw
                    next_state = MEM_READ;
              end
              else if (opcode == 6'b0)  // sw
                    next_state = MEM_WRITE;
             
            end

            MEM_READ: begin
               ALUSrc = 1;
                MemRead = 1;
              MemtoReg = 1;
               RegWrite = 1;
                next_state = WB;
            end

            MEM_WRITE: begin
              ALUSrc=1;
                MemWrite = 1;
                next_state =FETCH;
            end
			
            WB: begin
               
                RegWrite = 0;
                next_state = FETCH;
            end
        endcase
    end
endmodule




module reg_write_mux(
  input wire [7:0] rt,     // instruction[20:16]
    input wire [4:0] rd,     // instruction[15:11], unused for load/store
    input wire sel,          // 0 = rt (Load), 1 = rd (R-type; not used here)
  output reg [7:0] write_reg
);

always @(*) begin
    case (sel)
        1'b0: write_reg = rt;  // Load
        1'b1: write_reg = rd;  // R-type (unused in this load/store scenario)
    endcase
end

endmodule




module register (
    input wire clk,
    input wire reg_write_en,
    input wire [4:0] rs,       // Read register 1
  	input wire [7:0] rt,       // Read register 2
  	input wire [7:0] write_reg, // Write register (from RegDst mux)
  input wire [31:0] rd_data, // Write data
	input wire [2047:0] grayscale_flat_out,
	

    // External inputs to force values into specific registers
  input wire [31:0] ext_data_9,
  input wire [31:0] ext_data_10,
  input wire [31:0] ext_data_11,
  input wire [31:0] ext_data_12,

  output wire [31:0] reg1_data, // Output from rs
  output wire [31:0] reg2_data, // Output from rt

  output wire [31:0] reg_out_2,
  output wire [31:0] reg_out_3,
  output wire [31:0] reg_out_4,
  output wire [31:0] reg_out_5,
  output wire [31:0] reg_out_9,

  	output reg [2047:0] reg_flat_out
  // 64 registers * 64 bits = 4096-bit wide output
);

  reg [31:0] registers [0:255];

    integer i;

    initial begin
        $readmemh("registers.hex", registers);  // Load initial register values
    end

    // Asynchronous reads
    assign reg1_data = registers[rs];
    assign reg2_data = registers[rt];

    assign reg_out_2 = registers[1];
    assign reg_out_3 = registers[2];
    assign reg_out_4 = registers[3];
    assign reg_out_5 = registers[4];
  assign reg_out_9 = registers[128];

    // Synchronous write
    always @(posedge clk) begin
        if (reg_write_en && write_reg != 0)
            registers[write_reg] <= rd_data;
 		for (i = 0; i < 64; i = i + 1) begin
    		if (grayscale_flat_out[(i+1)*32 - 1 -: 32] != 32'd0)
        	registers[66 + i] <= grayscale_flat_out[(i+1)*32 - 1 -: 32];
		end

       
    end

                                                         // -------change system verilog---------
   genvar idx;
generate
    for (idx = 0; idx < 64; idx = idx + 1) begin : flatten_32
        assign reg_flat_out[(idx * 32) + 31 : idx * 32] = registers[idx];
    end
endgenerate


endmodule




module sign_extend(
    input [15:0] in,
  output [31:0] out
);
  assign out = {16'b0, in};
endmodule




module alu_source_mux(
  input [31:0] reg_data2,       // Read data from second register (rt)
  input [31:0] immediate,       // Sign-extended immediate value
    input alusrc,                 // Control signal: 0 = reg_data2, 1 = immediate
  output [31:0] alu_input_b     // Output to ALU
);
    assign alu_input_b = alusrc ? immediate : reg_data2;
endmodule





module alu(
  input [31:0] a,              // Operand A
  input [31:0] b,              // Operand B
    input [2:0] alu_control,     // Control signal
  output reg [31:0] result,    // ALU result
    output zero                 // Zero flag (1 if result is 0)
);
    always @(*) begin
        case (alu_control)
            3'b000: result = a + b;   // AND
            3'b001: result = a | b;   // OR
            3'b010: result = a & b;   // ADD
            3'b110: result = a - b;   // SUB
          3'b111: result = (a < b) ? 32'b1 : 32'b0; // SLT
            default: result = 32'b0;
        endcase
    end

    assign zero = (result == 0);
endmodule




module memory_reg(
    input clk,
    input MemWrite,
    input MemRead,
    input [31:0] address,
    input [31:0] write_data,
    output [31:0] read_data,
  output [2047:0] flat_mem_data_out  // 85 * 32 bits
);

    reg [31:0] memory [0:2199];  // 2200 words

    // Read logic
    assign read_data = (MemRead) ? memory[address[31:0]] : 32'b0;

    // Write logic
    always @(posedge clk) begin
        if (MemWrite)
            memory[address[31:0]] <= write_data;
    end

    // Memory initialization
    initial begin
        $readmemh("data_mem.hex", memory);
    end

    // Flatten memory[66] to memory[150] into flat_mem_data_out
   genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : mem_flatten
            assign flat_mem_data_out[(i+1)*32-1 -: 32] = memory[1 + i];
        end
    endgenerate

endmodule

module memtoreg(
  input [31:0] alu_result,
  input [31:0] mem_data,
    input mem_to_reg,              // Control signal: 0 = alu_result, 1 = mem_data
  output [31:0] write_back_data
);
    assign write_back_data = mem_to_reg ? mem_data : alu_result;
endmodule




module bus_interface (
    input wire clk,
    input wire reset,

    // MIPS interface
    input wire [23:0] reg_data_in,   // RGB data from register
    input wire load_pixel,           // Trigger to load new pixel to IPU
    input wire store_pixel,          // Trigger to store output to register

    output reg [7:0] gray_data_out,  // Grayscale output to register
    output reg done,                 // Done signal

    // IPU interface
    output reg [23:0] rgb_to_ipu,
    input wire [7:0] gray_from_ipu
);

    // State encoding
    parameter IDLE    = 2'b00;
    parameter LOAD    = 2'b01;
    parameter PROCESS = 2'b10;
    parameter STORE   = 2'b11;

    reg [1:0] current_state, next_state;

    // FSM: State transition
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // FSM: Next state logic
    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (load_pixel)
                    next_state = LOAD;
            end
            LOAD: begin
                next_state = PROCESS;
            end
            PROCESS: begin
                if (store_pixel)
                    next_state = STORE;
            end
            STORE: begin
                next_state = IDLE;
            end
        endcase
    end

    // Output logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rgb_to_ipu     <= 24'd0;
            gray_data_out  <= 8'd0;
            done           <= 1'b0;
        end else begin
            case (current_state)
                LOAD: begin
                    rgb_to_ipu <= reg_data_in;
                    done       <= 1'b0;
                end
                PROCESS: begin
                    // No action needed for combinational IPU
                end
                STORE: begin
                    gray_data_out <= gray_from_ipu;
                    done <= 1'b1;
                end
                default: begin
                    done <= 1'b0;
                end
            endcase
        end
    end

endmodule


 module rgb_to_grayscale (

    input  wire [23:0] rgb_in,     // {R[7:0], G[7:0], B[7:0]}

    output wire [7:0]  gray_out    // 8-bit grayscale output

);

    wire [7:0] R = rgb_in[23:16];

    wire [7:0] G = rgb_in[15:8];

    wire [7:0] B = rgb_in[7:0];

    wire [17:0] R_mul = R * 18'd299;   // 8x10 = 18 bits

    wire [17:0] G_mul = G * 18'd587;

    wire [17:0] B_mul = B * 18'd114;

    wire [19:0] gray_temp = R_mul + G_mul + B_mul;

    assign gray_out = gray_temp / 1000;  // Final grayscale value

endmodule
