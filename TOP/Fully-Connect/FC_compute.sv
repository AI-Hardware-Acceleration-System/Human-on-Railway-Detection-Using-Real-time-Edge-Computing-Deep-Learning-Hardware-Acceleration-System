`timescale 1ns / 1ps

module FC_compute#(
    parameter DATAWIDTH = 16,
    parameter Mult_Add_Units = 16
)(
    clk, reset, start, input_data, weights, output_data
);

input logic clk, reset, start;
input logic [DATAWIDTH*Mult_Add_Units-1:0] input_data;
input logic [DATAWIDTH*Mult_Add_Units-1:0] weights;
output logic [DATAWIDTH-1:0] output_data;

integer a,b;

logic [DATAWIDTH*Mult_Add_Units-1:0] temp;
 
genvar i;
generate
	for (i = 0; i < Mult_Add_Units ; i = i + 1) begin
		floatMult16 FM (
            .floatA(input_data[DATAWIDTH*(i+1)-1:DATAWIDTH*i]),
            .floatB(weights[DATAWIDTH*(i+1)-1:DATAWIDTH*i]),
            .product(temp[DATAWIDTH*(i+1)-1:DATAWIDTH*i])
        );
	end
endgenerate

FC_AdderTree #(
    .datawidth(DATAWIDTH),
    .Mult_Add_Units(Mult_Add_Units)
) Add_result (
    .inputs(temp),
    .result(output_data)
);

    
endmodule
