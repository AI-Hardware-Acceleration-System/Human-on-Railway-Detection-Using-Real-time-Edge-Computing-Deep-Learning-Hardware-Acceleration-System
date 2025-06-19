`timescale 1ns / 1ps
 
module Conv_tb();
    parameter DATA_WIDTH = 16;
    parameter SA_UNITS = 4;
    parameter KERNEL_SIZE = 3;
    parameter IN_SIZE = 6;
    parameter STATE_DATAWIDTH = 4, ADDRESS_DATAWIDTH = 13;
    parameter LOOP_DATAWIDTH = 3, FILTER_DATAWIDTH = 5;
    parameter FEATURE_MAP = 84;
    logic  [DATA_WIDTH-1:0]real_output;
	logic  [LOOP_DATAWIDTH - 1 : 0] current_loop; // to record the present loop value
    logic  [FILTER_DATAWIDTH - 1 : 0] current_filter;
	logic  [DATA_WIDTH*SA_UNITS-1:0]input_data;
	logic  [DATA_WIDTH-1:0]output_temp;
    logic  [STATE_DATAWIDTH - 1 : 0]state;
    logic  [ADDRESS_DATAWIDTH - 1 : 0]Out_Address;
	logic  clk;
	logic  clk_3;
	logic  reset;
    logic [DATA_WIDTH-1:0] input_map[IN_SIZE-1:0][IN_SIZE-1:0];
    logic  last_data;
    
    Conv #(
        .KERNEL_SIZE(KERNEL_SIZE),
        .SA_UNITS(SA_UNITS),
        .DATA_WIDTH(DATA_WIDTH),
        .STATE_DATAWIDTH(STATE_DATAWIDTH),
        .ADDRESS_DATAWIDTH(ADDRESS_DATAWIDTH),
        .LOOP_DATAWIDTH(LOOP_DATAWIDTH),
        .FILTER_DATAWIDTH(FILTER_DATAWIDTH)
    )uut(
        .real_output(real_output),
        .current_loop(current_loop), 
        .current_filter(current_filter),
        .input_data(input_data),
        .output_temp(output_temp),
        .state(state),
        .Out_Address(Out_Address),
        .clk(clk),
        .reset(reset),
        .clk_3(clk_3),
        .last_data(last_data)
);

    // Clock generation
    initial begin
        clk = 0;
        #3 
        clk = 1;
        forever #15 clk <= ~clk;
    end
    
    initial begin
        clk_3 = 0;
        forever #5 clk_3 <= ~clk_3;
    end
    
    initial begin
        Out_Address = 1'd0;
        #483 Out_Address = 1'd1;
        forever #30 Out_Address += 1'd1;
    end
    
//    initial begin
//        last_data = 1'd0;
//        #202053 last_data = 1'd1;
//        #30 last_data = 1'd0;
//    end
    logic  clk_1;
    initial begin
        clk_1 = 0;
        forever #1 clk_1 <= ~clk_1;
    end
    
    logic [31:0] counter;
    always_ff @(posedge clk_1 or negedge reset) begin
        if (!reset) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end

    always_ff @(posedge clk_1 or negedge reset) begin
        if (!reset) begin
            last_data <= 1'd0;
        end else begin
            if (counter == 101004) begin
                last_data <= 1'd1;
            end else if (counter == 101019) begin
                last_data <= 1'd0;
            end
        end
    end
    
    initial begin
        // Initialize signals
        reset = 0;
        output_temp = 16'd0;
        state = 3'd1;
        input_data = 64'd0;
        #5  reset = 1'd0;
        #10 reset = 1'd1;
        
        #350
         //Initialize input_data with float16 values
        
        input_data = 64'h3C003C003C003C00;   
        for (int i = 0; i < 4000; i++)begin
            #10 input_data = 64'h4100410041004100;//1  
            #10 input_data = 64'h3800380038003800;//2
            #10 input_data = 64'h4000400040004000;//3
            #10 input_data = 64'h5100510051005100;//4  
            #10 input_data = 64'h4200420042004200;//5
            #10 input_data = 64'h5810581058105810;//6
            #10 input_data = 64'h3E003E003E003E00;//7
            #10 input_data = 64'h5100510051005100;//8  
            #10 input_data = 64'h5240524052405240;//9
            #10 input_data = 64'h5380538053805380;//10
		end
		#10 input_data = 64'h4100410041004100;//7052  
        #10 input_data = 64'h3800380038003800;//7053
        #10 input_data = 64'h4000400040004000;//7054
        #10 input_data = 64'h5100510051005100;//7055  
        #10 input_data = 64'h4200420042004200;//7056
        // Run for some additional cycles to observe the output
        #300;
        
        // End simulation
        $stop;
    end
    
    initial begin
        $monitor("Time: %0t, real_output: %h, output_temp: %h", $time, real_output,output_temp);
    end
endmodule
