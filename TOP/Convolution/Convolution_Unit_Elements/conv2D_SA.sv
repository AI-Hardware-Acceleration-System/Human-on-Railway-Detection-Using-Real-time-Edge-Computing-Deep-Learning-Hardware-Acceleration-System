`timescale 1ns / 1ps
 
module tb_conv2D_SA;

    // Parameters
    parameter IN_SIZE = 6;
    parameter KERNEL_SIZE = 3;
    parameter STRIDE = 1;
    parameter PADDING = 0;
    parameter DATA_WIDTH = 16;

    // Testbench Signals
    localparam CLK_PERIOD = 10;
    logic [DATA_WIDTH-1:0] input_map [IN_SIZE-1:0][IN_SIZE-1:0];  // Input feature map
    logic [DATA_WIDTH-1:0] in_rows [KERNEL_SIZE-1:0];
    logic [DATA_WIDTH-1:0] psum_in [KERNEL_SIZE-1:0];
    logic [DATA_WIDTH-1:0] psum_out [KERNEL_SIZE-1:0];
    logic [DATA_WIDTH-1:0] weight [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0];
    logic clk, rst_n, calculate;
    logic done;

    // DUT Instantiation
    conv2D_SA #(
        .IN_SIZE(IN_SIZE),
        .KERNEL_SIZE(KERNEL_SIZE),
        .STRIDE(STRIDE),
        .PADDING(PADDING),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .psum_out(psum_out),
        .psum_in(psum_in),
        .in_rows(in_rows),
        .weight(weight),
        .clk(clk),
        .rst_n(rst_n),
        .calculate(calculate),
        .done(done)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Test Vectors
    initial begin
        // Initialize signals
        rst_n = 0;
        calculate = 0;
        for (int i = 0; i < KERNEL_SIZE; i++) begin
            in_rows[i] = 0;
            psum_in[i] = 0;
        end

        // Reset
        #10 rst_n = 1; calculate = 1;

        // Initialize weight array with float16 values
        weight[0][0] = 16'h3C00;  // 1.0 (float16)
        weight[0][1] = 16'h4000;  // 2.0 (float16)
        weight[0][2] = 16'h3C00;  // 1.0 (float16)
        weight[1][0] = 16'h4000;  // 2.0 (float16)
        weight[1][1] = 16'h4200;  // 3.0 (float16)
        weight[1][2] = 16'h4000;  // 2.0 (float16)
        weight[2][0] = 16'h3C00;  // 1.0 (float16)
        weight[2][1] = 16'h4000;  // 2.0 (float16)
        weight[2][2] = 16'h3C00;  // 1.0 (float16)

        // Initialize input_map array with float16 values
        input_map[0][0] = 16'h3C00;  // 1.0 (float16)
        input_map[0][1] = 16'h4000;  // 2.0 (float16)
        input_map[0][2] = 16'h3800;  // 0.5 (float16)
        input_map[0][3] = 16'h4200;  // 3.0 (float16)
        input_map[0][4] = 16'h4100;  // 2.5 (float16)
        input_map[0][5] = 16'h3E00;  // 1.5 (float16)
        
        input_map[1][0] = 16'h3800;  // 0.5 (float16)
        input_map[1][1] = 16'h3E00;  // 1.5 (float16)
        input_map[1][2] = 16'h4000;  // 2.0 (float16)
        input_map[1][3] = 16'h3C00;  // 1.0 (float16)
        input_map[1][4] = 16'h4200;  // 3.0 (float16)
        input_map[1][5] = 16'h3800;  // 0.5 (float16)
        
        input_map[2][0] = 16'h4100;  // 2.5 (float16)
        input_map[2][1] = 16'h3C00;  // 1.0 (float16)
        input_map[2][2] = 16'h4000;  // 2.0 (float16)
        input_map[2][3] = 16'h3E00;  // 1.5 (float16)
        input_map[2][4] = 16'h3800;  // 0.5 (float16)
        input_map[2][5] = 16'h4200;  // 3.0 (float16)
        
        input_map[3][0] = 16'h3800;  // 0.5 (float16)
        input_map[3][1] = 16'h3C00;  // 1.0 (float16)
        input_map[3][2] = 16'h3800;  // 0.5 (float16)
        input_map[3][3] = 16'h4100;  // 2.5 (float16)
        input_map[3][4] = 16'h4200;  // 3.0 (float16)
        input_map[3][5] = 16'h3E00;  // 1.5 (float16)
        
        input_map[4][0] = 16'h4200;  // 3.0 (float16)
        input_map[4][1] = 16'h3800;  // 0.5 (float16)
        input_map[4][2] = 16'h3C00;  // 1.0 (float16)
        input_map[4][3] = 16'h4000;  // 2.0 (float16)
        input_map[4][4] = 16'h3E00;  // 1.5 (float16)
        input_map[4][5] = 16'h4100;  // 2.5 (float16)
        
        input_map[5][0] = 16'h3800;  // 0.5 (float16)
        input_map[5][1] = 16'h4200;  // 3.0 (float16)
        input_map[5][2] = 16'h4000;  // 2.0 (float16)
        input_map[5][3] = 16'h3C00;  // 1.0 (float16)
        input_map[5][4] = 16'h3E00;  // 1.5 (float16)
        input_map[5][5] = 16'h4100;  // 2.5 (float16)
        
        
        // Input sliding window logic
        for (int j = 0; j < (IN_SIZE + 2 * (KERNEL_SIZE - 1)); j++) begin
            for (int i = 0; i < KERNEL_SIZE; i++) begin
                if (j >= i && j < (IN_SIZE + i))
                    in_rows[i] = input_map[i][j-i];
                else
                    in_rows[i] = 0;
            end
            #CLK_PERIOD;
        end

        // Wait for computation to complete
        #100 calculate = 0;

        // End simulation
        #20 $finish;
    end

    // Monitor
    initial begin
        $monitor("Time=%0t | psum_out=%p | done=%b", $time, psum_out, done);
    end

endmodule

module conv2D_SA #(
    parameter IN_SIZE = 6,          // Input feature map size (IN_SIZE x IN_SIZE)
    parameter KERNEL_SIZE = 3,      // Kernel size (KERNEL_SIZE x KERNEL_SIZE)
    parameter STRIDE = 1,   // Stride for sliding window
    parameter PADDING = 0,        
    parameter DATA_WIDTH = 16        // Data width for input, output, and weight
)(
    //output logic [DATA_WIDTH-1:0] out, 
    output logic [DATA_WIDTH-1:0] psum_out [KERNEL_SIZE-1:0],
    input logic [DATA_WIDTH-1:0] psum_in [KERNEL_SIZE-1:0],
    input logic [DATA_WIDTH-1:0] in_rows [KERNEL_SIZE-1:0],      
    input logic [DATA_WIDTH-1:0] weight [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0], // Kernel
    input logic clk, rst_n, calculate,
    output logic done
);

    localparam OUT_SIZE = (IN_SIZE + 2*PADDING - KERNEL_SIZE) / STRIDE + 1;
    logic [DATA_WIDTH-1:0] in_pe [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0];
    logic [DATA_WIDTH-1:0] psum [KERNEL_SIZE:0][KERNEL_SIZE-1:0];
  
    
    assign psum_out = psum [KERNEL_SIZE];
    assign psum[0] = psum_in;      
    
    generate
        genvar i, j;
        for (i = 0; i < KERNEL_SIZE; i++) begin: OUT_ROW
            for (j = 0; j < KERNEL_SIZE; j++) begin: OUT_COL        
                PE16 pe16 (
                    .clk(clk),
                    .rst_n(rst_n),
                    .floatA(in_pe[i][j]),
                    .floatB(weight[i][j]),
                    .sum_in(psum[i][j]),
                    .sum_out(psum[i+1][j])
                );
            end
        end
    endgenerate

    // Control logic to slide window and store results
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done <= 1'b1;
            for (int i = 0; i < KERNEL_SIZE; i++) begin
                for (int j = 0; j < KERNEL_SIZE; j++) begin
                    in_pe[i][j] <= 0;  // Initialize in_pe to 0
                end
            end
        end else begin
            if (!calculate) begin
                done <= 1'b1;
                for (int i = 0; i < KERNEL_SIZE; i++) begin
                    for (int j = 0; j < KERNEL_SIZE; j++) begin
                        in_pe[i][j] <= 0;  // Initialize in_pe to 0
                    end
                end
            end else begin  
                for (int i = 0; i < KERNEL_SIZE; i++) begin
                    for (int j = 0; j < KERNEL_SIZE-1; j++) begin
                        in_pe[i][j] <= in_pe[i][j+1];
                    end
                    in_pe[i][KERNEL_SIZE-1] <= in_rows[i];
                end
                done <= 1'b0;
            end
        end
    end

endmodule

module conv3D_SA #(
    parameter IN_SIZE = 6,
    parameter KERNEL_SIZE = 3,
    parameter STRIDE = 1,
    parameter PADDING = 0,
    parameter DATA_WIDTH = 16,
    parameter CHANNEL = 3 // Number of conv2D_SA instances
)(
    output logic [DATA_WIDTH-1:0] final_psum_out [KERNEL_SIZE-1:0],
    input logic [DATA_WIDTH-1:0] input_map [IN_SIZE-1:0][IN_SIZE-1:0],
    input logic [DATA_WIDTH-1:0] weight [CHANNEL-1:0][KERNEL_SIZE-1:0][KERNEL_SIZE-1:0],
    input logic clk,
    input logic rst_n,
    input logic calculate,    
    output logic done
);

    // Internal signals
    logic [DATA_WIDTH-1:0] psum [CHANNEL:0][KERNEL_SIZE-1:0];
    logic [DATA_WIDTH-1:0] in_rows [CHANNEL-1:0][KERNEL_SIZE-1:0];
    logic [CHANNEL-1:0] done_signals;

    assign psum[0] = '{default: 0}; 
    assign done = &done_signals; //all modules are done  

    // Generate multiple conv2D_SA instances
    generate
        genvar i;
        for (i = 0; i < CHANNEL; i++) begin : CONV_INSTANCES
            conv2D_SA #(
                .IN_SIZE(IN_SIZE),
                .KERNEL_SIZE(KERNEL_SIZE),
                .STRIDE(STRIDE),
                .PADDING(PADDING),
                .DATA_WIDTH(DATA_WIDTH)
            ) conv_inst (
                .psum_out(psum[i+1]),
                .psum_in(psum[i]),
                .in_rows(in_rows[i]),
                .weight(weight[i]),
                .clk(clk),
                .rst_n(rst_n),
                .calculate(calculate),
                .done(done_signals[i])
            );
        end
    endgenerate

    assign final_psum_out = psum[CHANNEL]; // Output of last conv2D_SA
    //final output =  psum[CHANNEL]¦U¶µ¬Û¥[+bias
    
endmodule

