`timescale 1ns / 1ps

module FC_Ctrl_Unit #(
    parameter datawidth = 16,
    parameter input_nodes = 784,
    parameter output_nodes = 2,
    parameter Mult_Add_Units = 16
)(
    input logic clk, reset, start,
    input logic [datawidth*Mult_Add_Units-1:0] input_data,
    input logic [datawidth*Mult_Add_Units-1:0] weights,
    input logic [datawidth*output_nodes-1:0] bias,
    output logic [datawidth*output_nodes-1:0] output_data,
    output logic [6:0] weight_addr,
    output logic done
);
     
logic [datawidth*output_nodes-1:0] result_temp_A;
logic [datawidth*output_nodes-1:0] result_temp_T;
logic [datawidth*output_nodes-1:0] total_result;
logic [datawidth-1:0] accumulate_result;
logic [5:0] rounds;
logic [1:0]node, ready;
logic j;

FC_compute #(
    .DATAWIDTH(datawidth),
    .Mult_Add_Units(Mult_Add_Units)
)FC_CP_Unit(
    .clk(clk), 
    .reset(reset), 
    .start(start), 
    .input_data(input_data), 
    .weights(weights), 
    .output_data(accumulate_result)
);

genvar i;
generate
	for (i = 0; i < output_nodes ; i = i + 1) begin
	    floatAdd16 ACC_result (
            .floatA(result_temp_A[datawidth*(i+1)-1:datawidth*i]),
            .floatB(result_temp_T[datawidth*(i+1)-1:datawidth*i]),
            .sum(total_result[datawidth*(i+1)-1:datawidth*i])
        );
	end
endgenerate

assign weight_addr = (done) ? 99 : (node == 0) ? rounds : input_nodes / Mult_Add_Units + rounds;

always_ff @(posedge clk or negedge reset) begin
    if(!reset)begin
        rounds <= 0;
        node <= 0;
        result_temp_A <= 0;
        result_temp_T <= 0;
        done <= 0;
        output_data <= 0;
        ready <= 0;
        j <= 0;
    end
    else begin
        if(start && !done) begin
            if(!j) j <= 1;
            else begin
            ready <= (rounds < input_nodes / Mult_Add_Units ) ? 1 : 0;
            if(rounds <= input_nodes / Mult_Add_Units + 1) begin
                rounds <= rounds + 1;
                result_temp_A[datawidth*node+:datawidth] <= (rounds == input_nodes / Mult_Add_Units + 1) ? bias[datawidth*node+:datawidth] : accumulate_result;
                result_temp_T[datawidth*node+:datawidth] <= total_result[datawidth*node+:datawidth];
            end
            else begin
                if(node < output_nodes - 1) begin
                    node <= node + 1;
                end
                else begin
                    done <= 1;
                end
                output_data <= total_result;
                rounds <= 0;
            end
            end
        end
        else begin
                done <= 0;
                rounds <= 0;
                node <= 0;
                result_temp_A <= 0;
                result_temp_T <= 0;
                ready <= 0;
                output_data <= 0;
                j <= 0;
        end
    end
end
    
endmodule
