`timescale 1ns / 1ps
 
module Conv_DP_Unit#(
    parameter KERNEL_SIZE = 3,
    parameter DATA_WIDTH = 16
)(
    input logic clk, reset, start,
    input logic [DATA_WIDTH-1:0] input_data,
    output logic [DATA_WIDTH*KERNEL_SIZE-1:0] in_rows,
    output logic DP_Unit_OK
);

    logic [DATA_WIDTH-1:0] data_temp [KERNEL_SIZE-1:0];
    logic [1:0] cnt;
    genvar a;
    for(a = 0 ; a < KERNEL_SIZE ; a++) begin
        assign in_rows[DATA_WIDTH*a+:DATA_WIDTH] = data_temp[a];
    end
    always_ff@(posedge clk or negedge reset) begin
        if(!reset || !start) begin
            for(int i = 0 ; i < KERNEL_SIZE ; i++) data_temp[i] <= 0;
            cnt <= 0;
            DP_Unit_OK <= 0;
        end
        else begin
            cnt <= (cnt == KERNEL_SIZE) ? 1 : cnt + 1;
            DP_Unit_OK <= (cnt == KERNEL_SIZE-1) ? 1 : 0;
            data_temp[KERNEL_SIZE-1] <= input_data;
            for(int i = 0 ; i < KERNEL_SIZE-1 ; i++) data_temp[i] <= data_temp[i+1];
        end
    end
endmodule

module Conv_DP#(
    parameter KERNEL_SIZE = 3,
    parameter DATA_WIDTH = 16,
    parameter SA_Units = 4
)(
    input logic clk, reset, start,
    input logic [DATA_WIDTH*SA_Units-1:0] input_data,
    output logic [DATA_WIDTH*SA_Units*KERNEL_SIZE-1:0] in_rows_SA,
    output logic DP_OK
);
    logic DP_Unit_OK[SA_Units-1:0];
    assign DP_OK = DP_Unit_OK[0];
    genvar i;
    generate
        for(i = 0 ; i < SA_Units ; i++) begin
            Conv_DP_Unit#(
                .KERNEL_SIZE(KERNEL_SIZE),
                .DATA_WIDTH(DATA_WIDTH)
            )DP(
                .clk(clk),
                .reset(reset),
                .start(start),
                .input_data(input_data[DATA_WIDTH*i+:DATA_WIDTH]),
                .in_rows(in_rows_SA[DATA_WIDTH*KERNEL_SIZE*i+:DATA_WIDTH*KERNEL_SIZE]),
                .DP_Unit_OK(DP_Unit_OK[i])
            );
        end
    endgenerate
endmodule

module DP_tb;
    
    reg clk, rst, start;
    reg [63:0]input_data;
    reg [191:0]in_rows;
    
    Conv_DP a789(clk, rst, start, input_data, in_rows);
    
    initial begin
        start <= 0;
        clk <= 0;
        rst <= 1;
        input_data <= 0;
        #5 rst <= 0;
        #10rst <= 1;
        #10 start <= 1;
        input_data <= 192'h1111222233334444;
        #10 input_data <= 192'h2222333344445555;
        #10 input_data <= 192'h3333444455556666;
        #10 input_data <= 192'h4444555566667777;
        #10 input_data <= 192'h5555666677778888;
        #10 input_data <= 192'h6666777788889999;
        #10 input_data <= 192'h0;
    end
    
    initial begin
        forever #5 clk <= ~clk;
    end
    
endmodule


