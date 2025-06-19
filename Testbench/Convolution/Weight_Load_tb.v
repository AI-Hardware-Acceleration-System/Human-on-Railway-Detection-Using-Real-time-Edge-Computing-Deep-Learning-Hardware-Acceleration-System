`timescale 1ns / 1ps
 
module Weight_Load_tb();
    // Parameter definitions (modify based on your RAM configuration)
    parameter DATA_WIDTH = 16;
    parameter ADDR_WIDTH = 12;
    parameter MEM_DEPTH  = 1 << ADDR_WIDTH;

    // DUT input and output signals
    reg                  clk;
    reg                  ena;
    reg  [ADDR_WIDTH-1:0] addr;
    wire [DATA_WIDTH-1:0] dout;

    // Instantiate the DUT (Replace `dual_port_ram` with your module name)
     weight_total_5x5_kernel  
     uut_2(
     .clka(clk),
     .ena(ena),
     .addra(addr),
     .douta(dout)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk; // 10ns period
        end
    end

    // Testbench logic
    initial begin
        // Initialize signals
        ena = 0;
        addr = 0;

        // Wait for reset time
        #10;

        // Test Case 1: Write and Read from Port A
        ena = 1; // Enable and Write on Port A
        addr = 4'h3;     // Address 3
        #10;
        addr = 12'd2301;

        // End simulation
        # 30;
        $display("Testbench completed");
        $stop;
    end

endmodule
