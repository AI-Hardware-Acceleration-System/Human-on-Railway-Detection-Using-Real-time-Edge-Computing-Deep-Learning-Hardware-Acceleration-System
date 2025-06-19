`timescale 1ns / 1ps

module Master_FSM(
    state,
    clk, reset,
    Conv_done, Avg_done, FC_done, Judge_done, Judge_all_done,
//    address // from PS BRAM
    PS_BRAM_busy
    );
    
    parameter STATE_DATAWIDTH = 4;
    parameter ADDRESS_DATAWIDTH = 13; // for PS BRAM
//    parameter INPUT_SIZE = 80;
    
    // total state 
    parameter RESET = 0, IDLE = 1;
    parameter CONV1_1_STATE = 2, CONV1_2_STATE = 3, AVG_POOL1 = 4;
    parameter CONV2_1_STATE = 5, CONV2_2_STATE = 6, AVG_POOL2 = 7;
    parameter CONV3_1_STATE = 8, CONV3_2_STATE = 9, AVG_POOL3 = 10;
    parameter FC_STATE = 11;
    parameter JUDGE = 12;
    
    // input
    input clk,reset;
    input Conv_done, Avg_done, FC_done, Judge_done, Judge_all_done;
    input PS_BRAM_busy;
//    input [ADDRESS_DATAWIDTH - 1: 0] address;
    
    // output
    output reg [STATE_DATAWIDTH - 1 : 0] state;
    
    // ---------------------------------------------------------processing-------------------------------------------------------------------
    always @(posedge clk, negedge reset) begin
        if(!reset) begin
            state <= RESET;
        end else begin
            if(state == RESET) begin
                if(PS_BRAM_busy) begin
                    state <= state + 1;
                end else begin
                    state <= state;
                end 
            end else if(state == IDLE) begin
                if(!PS_BRAM_busy) begin
                    state <= state + 1;
                end else begin
                    state <= state;
                end 
            end else if(state == JUDGE) begin // not yet finished, needing one more signal
                if(Judge_all_done) begin
                    state <= RESET;
                end else if(Judge_done) begin
                    state <= IDLE;
                end else begin
                    state <= state;
                end 
            end else begin // other states
                if(Conv_done || Avg_done || FC_done) begin
                    state <= state + 1;
                end else begin
                    state <= state;
                end 
            end
        end 
    end 
    
endmodule
