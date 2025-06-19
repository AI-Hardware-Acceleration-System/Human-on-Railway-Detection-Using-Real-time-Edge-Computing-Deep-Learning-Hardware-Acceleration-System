`timescale 1ns / 1ps

module Fully_Connect#(
    parameter datawidth = 16,
    parameter input_nodes = 784,
    parameter output_nodes = 2,
    parameter Mult_Add_Units = 16,
    parameter Fully_Connect = 11
)(
    input logic clk, reset,
    input logic [3:0] state,
    input logic [datawidth*Mult_Add_Units-1:0] input_data,
    output logic [datawidth*output_nodes-1:0] output_data,
    output logic done
);
 
    logic [datawidth*Mult_Add_Units-1:0] weights;
    logic [6:0] weight_addr;
    logic [datawidth*output_nodes-1:0] bias;
    logic start;
    
    assign bias = 32'h379c_b7b4;
    assign start = (state == Fully_Connect) ? 1 : 0;
    
    FC_Ctrl_Unit #(
        .datawidth(datawidth),
        .input_nodes(input_nodes),
        .output_nodes(output_nodes),
        .Mult_Add_Units(Mult_Add_Units)
    ) FC_Run (
        .clk(clk), 
        .reset(reset), 
        .start(start),
        .input_data(input_data),
        .weights(weights),
        .bias(bias),
        .output_data(output_data),
        .weight_addr(weight_addr),
        .done(done)
    );
    
    FC_Weight Weight(    //?}?@??256*100??Single Port ROM
        .clka(clk),
        .ena(start),
        .addra(weight_addr),
        .douta(weights)
    );
    
endmodule
