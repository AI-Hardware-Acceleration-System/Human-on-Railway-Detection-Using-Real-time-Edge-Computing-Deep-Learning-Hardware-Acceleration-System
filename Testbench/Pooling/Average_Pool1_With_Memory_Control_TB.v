`timescale 1ns / 1ps
 
module Average_Pool1_With_Memory_Control_TB();

    // Parameters
    parameter input_size = 20;
    parameter output_size = 10;
    parameter channel = 6;
    parameter input_map_address_datawidth = 13;
    parameter output_map_address_datawidth = 11;
    parameter number_datawidth = 16;
    parameter middle_data_index_datawidth = 6;

    // Inputs
    reg pool_start;
    reg clk;
    reg reset;
//    wire reset_bar;

    // Signals for BRAM Port B
//    reg clkb;
    reg enb;
    reg [0:0] web;
//    reg [input_map_address_datawidth - 1:0] addrb;
    reg [number_datawidth - 1:0] dinb;
    wire [number_datawidth - 1:0] doutb;
    wire [number_datawidth - 1:0] douta;
    
    // Variable for testbench
//    integer i;
    
    // Outputs
    wire pool_end, wr_ena;
    wire [input_map_address_datawidth - 1:0] BRAM_Pool_In1_Address;
    wire [number_datawidth - 1:0] BRAM_Pool_Out1;
    wire [output_map_address_datawidth - 1:0] BRAM_Pool_Out1_Address;

//    assign reset_bar = ~reset;
    // Instantiate the DUT (Device Under Test)
    Average_Pool1_With_Memory_Control 
    dut (
        .enable(pool_start),
        .clk(clk),
        .reset(reset),
        .BRAM_Pool_In1(doutb), // Connect BRAM Port B output to DUT input
        .BRAM_Pool_In1_Address(BRAM_Pool_In1_Address),
//        .pool_end(pool_end),
        .wr_ena(wr_ena),
        .BRAM_Pool_Out1(BRAM_Pool_Out1),
        .BRAM_Pool_Out1_Address(BRAM_Pool_Out1_Address)
    );

    // Instantiate the BRAM
    Avg_Pool_Input_One_Channel input_bram (
        .clka(1'b0), // Unused Port A signals
//        .rsta(reset),
        .ena(1'b0),
        .wea(1'b0),
        .addra(13'd0),
        .dina(16'd0),
        .douta(douta),

        // Port B (used for reading input data)
        .clkb(clk),
//        .rstb(reset_bar),
        .enb(enb),
        .web(web),
        .addrb(BRAM_Pool_In1_Address),
        .dinb(dinb),
        .doutb(doutb)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk; // 10ns period
        end
    end

    // Initialize the testbench
    initial begin
        // Initialize inputs
//        clk = 0;
        reset = 1;
        pool_start = 0;
        enb = 0;
        web = 0;
//        addrb = 0;
        dinb = 0;

        // Reset sequence
        #20;
        reset = 0;
        
        #20;
        reset = 1;
        
        // Enable BRAM Port B and start pooling
        #10;
        enb = 1;
        pool_start = 1;
        
        

        // Simulate sequential read from BRAM
//        for (i = 0; i < input_size * input_size; i = i + 1) begin
//            addrb = i; // Increment address
//            #10; // Wait one clock cycle
//        end

        // Wait for pooling operation to complete
//        wait (pool_end);

        // Stop pooling
//        pool_start = 0;

        // End simulation
//        $finish;
    end
endmodule
