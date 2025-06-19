`timescale 1ns / 1ps
 
module Conv_Unit #(
    parameter KERNEL_SIZE = 3,      // Kernel size (KERNEL_SIZE x KERNEL_SIZE)
    parameter SA_UNITS = 4,   // Stride for sliding window
    parameter DATA_WIDTH = 16        // Data width for input, output, and weight
)(
	output  logic  [DATA_WIDTH-1:0]real_output,
	output  logic  all_done,
	input   logic  [DATA_WIDTH-1:0]weight[SA_UNITS-1:0][KERNEL_SIZE-1:0][KERNEL_SIZE-1:0],
	input   logic  [DATA_WIDTH-1:0]DP_data[SA_UNITS-1:0][KERNEL_SIZE-1:0],
	input   logic  [DATA_WIDTH-1:0]bias,
	input   logic  [DATA_WIDTH-1:0]output_temp,
    input   logic  clk, rst_n,calculate
);
	
	logic [DATA_WIDTH-1:0] output_for_onechan[SA_UNITS-1:0][KERNEL_SIZE-1:0];
	logic done[SA_UNITS-1:0];
	logic [DATA_WIDTH-1:0] psum_in[SA_UNITS-1:0][KERNEL_SIZE-1:0];
	logic [DATA_WIDTH-1:0]add_output;
	
	always_comb begin
	   for (int i = 0; i < SA_UNITS; i++) begin
	       for (int j = 0; j < KERNEL_SIZE; j++) begin
                psum_in[i][j] = 16'd0;
           end
        end
	end
	
	generate
		genvar i;
        for (i = 0; i < SA_UNITS; i++) begin: conv_units
			conv2D_SA Conv2D_SA(
		        .psum_out(output_for_onechan[i]),
				.psum_in(psum_in[i]) ,
				.in_rows(DP_data[i]) ,      
				.weight(weight[i]) , // Kernel
				.clk(clk),
                .rst_n(rst_n),
				.calculate(calculate),
				.done(done[i])
			);
		end
	endgenerate

	logic [DATA_WIDTH-1:0] add_Result [SA_UNITS-1:0];
    logic [DATA_WIDTH-1:0] add_temp [SA_UNITS-1:0];
	
	generate
		genvar j;
        for (j = 0; j < SA_UNITS; j++) begin : adders
            floatAdd16 out_add1(output_for_onechan[j][0], output_for_onechan[j][1], add_temp[j]);
            floatAdd16 out_add2(output_for_onechan[j][2], add_temp[j], add_Result[j]);
        end
    endgenerate
	
	logic [DATA_WIDTH-1:0] add_temp_total[2]; 
	logic [DATA_WIDTH-1:0] add_res;
	logic [DATA_WIDTH-1:0] no_shift_output;
	logic [DATA_WIDTH-1:0] add_final;
	
    floatAdd16 out_add3(add_Result[0],add_Result[1],add_temp_total[0]);
    floatAdd16 out_add4(add_Result[2],add_Result[3],add_temp_total[1]);
	floatAdd16 out_add5(add_temp_total[0],add_temp_total[1],add_res);
	floatAdd16 out_add6(add_res,bias,add_output);
	floatAdd16 out_add7(add_output,output_temp,add_final);

	float16_comparator float16_comparator(out_compared,add_final,16'd0000);
	always_comb begin
        if (!out_compared) begin
            real_output = add_final;
        end else begin
            real_output = 16'd0000;
        end
    end
    
    always_comb begin
        all_done = 1'b1; 
        for (int i = 0; i < SA_UNITS; i++) begin
            all_done &= done[i];
        end
    end
    
endmodule	
