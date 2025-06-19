`timescale 1ns / 1ps

module FC_AdderTree#(
    parameter datawidth = 16,
    parameter Mult_Add_Units = 16 
) (
    input  logic [datawidth*Mult_Add_Units-1:0] inputs, 
    output logic [datawidth-1:0] result
);
    localparam Padded_Units = 2**$clog2(Mult_Add_Units); 
    logic [datawidth*Padded_Units-1:0] padded_inputs; 
    logic [datawidth*Padded_Units-1:0] sum_stage [0:$clog2(Padded_Units)];

    always_comb begin
        for (int i = 0; i < Padded_Units; i = i + 1) begin
            if (i < Mult_Add_Units)
                padded_inputs[datawidth*i+:datawidth] = inputs[datawidth*i+:datawidth];
            else
                padded_inputs[datawidth*i+:datawidth] = {datawidth{1'b0}};
        end
    end

    always_comb begin
        for (int i = 0; i < Padded_Units; i = i + 1) begin
            sum_stage[0][datawidth*i+:datawidth] = padded_inputs[datawidth*i+:datawidth];
        end
    end

    genvar stage, j;
    generate
        for (stage = 0; stage < $clog2(Padded_Units); stage = stage + 1) begin : adder_stage
        localparam NUM_UNITS = Padded_Units >> (stage + 1);
            for (j = 0; j < NUM_UNITS; j = j + 1) begin : adder_units
                floatAdd16 FADD1 (
                    .floatA(sum_stage[stage][datawidth*(2*j+1+1)-1:datawidth*(2*j+1)]),
                    .floatB(sum_stage[stage][datawidth*(2*j+0+1)-1:datawidth*(2*j+0)]),
                    .sum(sum_stage[stage+1][datawidth*(j+1)-1:datawidth*j])
                );
            end
        end
    endgenerate

    assign result = sum_stage[$clog2(Padded_Units)][datawidth-1:0];

endmodule
