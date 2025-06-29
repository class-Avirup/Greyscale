`timescale 1ns / 1ps

module system_top_tb;

    // Clock and reset
    reg clk;
    reg reset;

    // External pixel inputs to registers 9–12
  reg [31:0] ext_data_9;
  reg [31:0] ext_data_10;
  reg [31:0] ext_data_11;
  reg [31:0] ext_data_12;
  reg [6:0] rgb_index_tb;
  reg [31:0] grayscale_9tb, grayscale_10tb, grayscale_11tb, grayscale_12tb;
  reg [2047:0] grayscale_flat_out;
    // Outputs from system_top
  wire [31:0] mips_out;
  wire [31:0] pc_out;
  wire [31:0] instruction_out;
  wire [31:0] reg_data1_out;
  wire [31:0] reg_data2_out;
  wire [31:0] read_data_out;
  wire [31:0] address_out;
    wire [7:0]  final_grayscale;
    wire        done;
  wire [31:0] reg2, reg3, reg4, reg5,reg9;
  wire[23:0] rgb_tb;
  wire load;
  wire store;
  wire [7:0] gray_out;
  reg [2047:0] array;
  reg [2047:0] flat_mem_data_out;

  
    // Instantiate system_top
    system_top uut (
        .clk(clk),
        .reset(reset),
        .ext_data_9(ext_data_9),
        .ext_data_10(ext_data_10),
        .ext_data_11(ext_data_11),
        .ext_data_12(ext_data_12),
        .mips_out(mips_out),
        .pc_out(pc_out),
        .instruction_out(instruction_out),
        .reg_data1_out(reg_data1_out),
        .reg_data2_out(reg_data2_out),
        .read_data_out(read_data_out),
        .address_out(address_out),
        .final_grayscale(final_grayscale),
      .done(done),
      .register2(reg2),
        .register3(reg3),
        .register4(reg4),
      .register5(reg5),
      .register9(reg9),
      .rgb(rgb_tb),
      .store_pix_out(store),
      .load_pix_out(load),
      .gray_ipu_out(gray_out),
      .rgb_index_check(rgb_index_tb),
      .grayscale_9c(grayscale_9tb),
      .grayscale_10c(grayscale_10tb),
      .grayscale_11c(grayscale_11tb),
      .grayscale_12c(grayscale_12tb),
      .array(array),
      .grayscale_flat_out(grayscale_flat_out),
      .flat_mem_data_out(flat_mem_data_out)
     
    );

    // Clock generation (10 ns period)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("system_top_tb.vcd");
        $dumpvars(0, system_top_tb);

        // Initialize inputs
        clk = 0;
        reset=1;

       // White pixel (truncated 24b RGB)

        #15 reset = 0; // Release reset

        // Wait long enough for FSM to process all 4 pixels
        #6000;

        $display("Simulation complete.");
        $finish;
    end


    // Monitor outputs
   initial begin
     $display("Time\tPC\t\tInstruction\tReg1\t\tReg2\t\tReg3\t\tReg4\t\tAddress\t\tRT_data\t\tWr_data\t\tGrayBus\tDone\tRGB\tLoad\tStore\tGrayIPU\tIndex\tReg9\t\tGrayscale_Array");

     $monitor("%0dns\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h", 
             $time, pc_out, instruction_out,reg2, reg3, reg4, reg5,address_out,reg_data2_out, mips_out, final_grayscale, done,
              rgb_tb, load, store, gray_out, rgb_index_tb ,reg9,array,flat_mem_data_out);
end

 
endmodule
