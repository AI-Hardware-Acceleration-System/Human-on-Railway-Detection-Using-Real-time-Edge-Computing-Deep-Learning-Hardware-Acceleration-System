`timescale 1ns / 1ps

module Conv_Unit_tb();
    parameter DATA_WIDTH = 16;
    parameter SA_UNITS = 4;
    parameter KERNEL_SIZE = 3;
    parameter IN_SIZE = 6;
     
    logic clk;
    logic rst_n;
    logic calculate;
    logic [DATA_WIDTH-1:0] weight[SA_UNITS-1:0][KERNEL_SIZE-1:0][KERNEL_SIZE-1:0];
    logic [DATA_WIDTH-1:0] DP_data[SA_UNITS-1:0][KERNEL_SIZE-1:0];
    logic [DATA_WIDTH-1:0] bias;
    logic [DATA_WIDTH-1:0] output_temp;
    logic [DATA_WIDTH-1:0] real_output;
    logic [DATA_WIDTH-1:0] input_map[IN_SIZE-1:0][IN_SIZE-1:0];
    logic [DATA_WIDTH-1:0] in_rows[KERNEL_SIZE-1:0];
    logic [DATA_WIDTH-1:0] not_important;
    
    Conv_Unit #(
        .KERNEL_SIZE(KERNEL_SIZE),
        .SA_UNITS(SA_UNITS),
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .real_output(real_output),
        .weight(weight),
        .DP_data(DP_data),
        .bias(bias),
        .output_temp(output_temp),
        .clk(clk),
        .rst_n(rst_n),
        .calculate(calculate)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        calculate = 0;
        bias = 16'd0;
        output_temp = 16'd0;
        
        // Initialize weights to 1
        for (int i = 0; i < SA_UNITS; i++) begin
            for (int j = 0; j < IN_SIZE; j++) begin
                 weight[0][i][j] = 16'h3C00;
            end
        end
        
        for (int i = 0; i < SA_UNITS; i++) begin
            for (int j = 0; j < IN_SIZE; j++) begin
                 weight[1][i][j] = 16'h4000;
            end
        end
        
        for (int i = 0; i < SA_UNITS; i++) begin
            for (int j = 0; j < IN_SIZE; j++) begin
                 weight[2][i][j] = 16'h4200;
            end
        end
        
        for (int i = 0; i < SA_UNITS; i++) begin
            for (int j = 0; j < IN_SIZE; j++) begin
                 weight[3][i][j] = 16'h4400;
            end
        end
        
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
        
        // Reset pulse
        #10 rst_n = 1;
        
        // Wait for one clock cycle before setting calculate to 1
        #10 calculate = 1;
        for (int j = 0; j < (IN_SIZE + 2 * (KERNEL_SIZE - 1)); j++) begin
            for (int i = 0; i < KERNEL_SIZE; i++) begin
                if (j >= i && j < (IN_SIZE + i))
                    in_rows[i] = input_map[i][j - i];
                else
                    in_rows[i] = 0;
            end
            for(int i = 0; i < SA_UNITS; i++) begin
                DP_data[i] = in_rows;
            end
            #10;
        end
        // Run for some additional cycles to observe the output
        #100;
        
        // End simulation
        $stop;
    end
    
    initial begin
        $monitor("Time: %0t, real_output: %h, output_temp: %h", $time, real_output,output_temp);
    end
endmodule
