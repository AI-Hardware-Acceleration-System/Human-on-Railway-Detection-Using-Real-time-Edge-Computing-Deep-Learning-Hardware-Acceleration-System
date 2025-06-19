`timescale 1ns / 1ps

module Avg_Pool_With_BRAM_tb();
 
    // Parameters
    parameter COMPUTING_CORES = 4;
    parameter number_datawidth = 16;
    parameter input_map_address_datawidth = 13;
    parameter output_map_address_datawidth = 11;
    parameter STATE_DATAWIDTH = 4;
    parameter COUNTER_DATAWIDTH = 3;
    parameter AVG1_STATE = 3;
    parameter AVG2_STATE = 6;
    parameter AVG3_STATE = 9;
    parameter AVG1_INPUT_SIZE = 80;
    parameter AVG2_INPUT_SIZE = 36;
    parameter AVG3_INPUT_SIZE = 14;
    
    // Inputs
    wire [COMPUTING_CORES * number_datawidth - 1:0] BRAM_Pool_In1; //to get data from input BRAM
    reg [STATE_DATAWIDTH - 1 : 0] state;
    reg clk, reset;
    
    //Outputs
    wire done;
    wire [COMPUTING_CORES - 1:0] wr_ena;
    wire [COUNTER_DATAWIDTH - 1:0] avg_loop;
    wire [COMPUTING_CORES * input_map_address_datawidth - 1:0] BRAM_Pool_In1_Address;
    wire [COMPUTING_CORES * number_datawidth - 1:0] BRAM_Pool_Out1; //to save data in output BRAM
    wire [COMPUTING_CORES * output_map_address_datawidth - 1:0] BRAM_Pool_Out1_Address;
    
    Avg_Pool_Multiple_Cores
    avg_pool_multiple_core1(
    .clk(clk),
    .reset(reset),
    .done(done),
    .wr_ena(wr_ena),
    .avg_loop(avg_loop),
    .state(state),
    .BRAM_Pool_In1(BRAM_Pool_In1), 
    .BRAM_Pool_In1_Address(BRAM_Pool_In1_Address),
    .BRAM_Pool_Out1(BRAM_Pool_Out1), 
    .BRAM_Pool_Out1_Address(BRAM_Pool_Out1_Address)
    );
    
    // BRAMs
    genvar i;
    generate
        for(i = 0; i < COMPUTING_CORES; i = i + 1) begin
            BRAM_80x80photo_16bits 
            ub0(
            .clka(clk), 
            .wea(0), 
            .addra(0),  
            .dina(0), 
            .clkb(clk), 
            .addrb(BRAM_Pool_In1_Address[input_map_address_datawidth - 1 : 0]), 
            .doutb(BRAM_Pool_In1[number_datawidth * i + (number_datawidth - 1) : number_datawidth * i]) 
            );
        end 
    endgenerate
    
    //  Clock Value
    initial begin
          clk = 0;
          forever #5 clk = !clk;
    end 
    
    // Testing Value
    initial begin
        reset = 1;
        #5 reset = 0;
        #10 reset = 1;
//        #30 state = 3;
//        #3930 state = 4;
//        #200 state = 6;
//        #5770 state = 7;
//        #200 state = 9;
//        #4010 state = 10;
//        #40 state = 1;
    end 
    
    integer count_tb;
    always @(posedge clk, negedge reset) begin
        if(!reset) begin
            state <= 0; count_tb <= 0;
        end else begin
            count_tb <= count_tb + 1;
            case(count_tb)
                4: state <= 3;
                12807: state <= 4;
                12827: state <= 6;
                18013: state <= 7;
                18017: state <= 9;
                18803: state <= 10;
            endcase 
        end 
    end 
    
endmodule
