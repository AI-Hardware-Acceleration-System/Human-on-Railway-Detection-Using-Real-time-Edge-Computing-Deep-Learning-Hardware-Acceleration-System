`timescale 1ns / 1ps

module Avg_Pool_Multiple_Cores(
    clk,reset,
    done,
    wr_ena,
    avg_loop,
    state,
    BRAM_Pool_In1, BRAM_Pool_In1_Address,
    BRAM_Pool_Out1, BRAM_Pool_Out1_Address 
    );
    
    // Parameters
    parameter input_map_address_datawidth = 13;
    parameter output_map_address_datawidth = 11;
    parameter number_datawidth = 16; // BRAM_Pool_Out uses direct value instead of parameter form
    parameter middle_data_index_datawidth = 6;
    parameter input_datawidth = 7;
    parameter STATE_DATAWIDTH = 4;
    parameter AVG1_STATE = 3;
    parameter AVG2_STATE = 6;
    parameter AVG3_STATE = 9;
    parameter AVG1_INPUT_SIZE = 80;
    parameter AVG2_INPUT_SIZE = 36;
    parameter AVG3_INPUT_SIZE = 14;
    parameter AVG1_OUTPUT_SIZE = 40;
    parameter AVG2_OUTPUT_SIZE = 18;
    parameter AVG3_OUTPUT_SIZE = 7;
    parameter AVG_LOOP_DATAWIDTH = 3;
    parameter COMPUTING_CORES = 4;
    
    // Inputs
    input [COMPUTING_CORES * number_datawidth - 1:0] BRAM_Pool_In1; //to get data from input BRAM
    input [STATE_DATAWIDTH - 1 : 0] state;
    input clk, reset;
    
    //Outputs
    output reg done;
    output [COMPUTING_CORES - 1:0] wr_ena;
    output reg [AVG_LOOP_DATAWIDTH - 1 : 0] avg_loop; // to record the present loop value
    output [COMPUTING_CORES * input_map_address_datawidth - 1:0] BRAM_Pool_In1_Address;
    output [COMPUTING_CORES * number_datawidth - 1:0] BRAM_Pool_Out1; //to save data in output BRAM
    output [COMPUTING_CORES * output_map_address_datawidth - 1:0] BRAM_Pool_Out1_Address;
    
    // Registers
    reg [COMPUTING_CORES - 1 : 0] enable;
    reg [AVG_LOOP_DATAWIDTH - 1 : 0] avg_loop_max; // to record the maximum loop value
    reg [input_map_address_datawidth - 1 : 0] In_Address_End;
    
    // Average Pooling Computing Cores
    genvar i;
    generate
        for(i = 0; i < COMPUTING_CORES; i = i + 1) begin
            Average_Pool1_With_Memory_Control #(
                .input_map_address_datawidth(input_map_address_datawidth),
                .output_map_address_datawidth(output_map_address_datawidth),
                .number_datawidth(number_datawidth),// BRAM_Pool_Out uses direct value instead of parameter form
                .middle_data_index_datawidth(middle_data_index_datawidth),
                .input_datawidth(input_datawidth),
                .STATE_DATAWIDTH(STATE_DATAWIDTH),
                .AVG1_STATE(STATE_DATAWIDTH),
                .AVG2_STATE(AVG2_STATE),
                .AVG3_STATE(AVG3_STATE),
                .AVG1_INPUT_SIZE(AVG1_INPUT_SIZE),
                .AVG2_INPUT_SIZE(AVG2_INPUT_SIZE),
                .AVG3_INPUT_SIZE(AVG3_INPUT_SIZE),
                .AVG1_OUTPUT_SIZE(AVG1_OUTPUT_SIZE),
                .AVG2_OUTPUT_SIZE(AVG2_OUTPUT_SIZE),
                .AVG3_OUTPUT_SIZE(AVG3_OUTPUT_SIZE)
            )uAvg0(
                .wr_ena(wr_ena[i]),
                .enable(enable[i]),
                .clk(clk),
                .reset(reset),
                .state(state),
                .BRAM_Pool_In1(BRAM_Pool_In1[number_datawidth * i + (number_datawidth - 1) : number_datawidth * i]),
                .BRAM_Pool_In1_Address(BRAM_Pool_In1_Address[input_map_address_datawidth * i + (input_map_address_datawidth - 1) : input_map_address_datawidth * i]),
                .BRAM_Pool_Out1(BRAM_Pool_Out1[number_datawidth * i + (number_datawidth - 1) : number_datawidth * i]),
                .BRAM_Pool_Out1_Address(BRAM_Pool_Out1_Address[output_map_address_datawidth * i + (output_map_address_datawidth - 1) : output_map_address_datawidth * i])
            );
        end 
    endgenerate
    
    // avg_loop_max & In_Address_End
    always @(*) begin
        if(!reset) begin
            avg_loop_max = 0;
            In_Address_End = AVG1_INPUT_SIZE * AVG1_INPUT_SIZE - 1;
        end else begin
            case(state)
                AVG1_STATE: // Avg1
                    begin
                    avg_loop_max = 2;
                    In_Address_End = AVG1_INPUT_SIZE * AVG1_INPUT_SIZE - 1;
                    end 
                AVG2_STATE: // Avg2
                    begin
                    avg_loop_max = 4; 
                    In_Address_End = AVG2_INPUT_SIZE * AVG2_INPUT_SIZE - 1;
                    end
                AVG3_STATE: // Avg3
                    begin
                    avg_loop_max = 4; 
                    In_Address_End = AVG3_INPUT_SIZE * AVG3_INPUT_SIZE - 1;
                    end
                default: // Not any Avg
                    begin
                    avg_loop_max = 0;
                    end
            endcase
        end 
    end 
    
    // avg_loop
    always @(posedge clk, negedge reset) begin
        if(!reset) begin
            avg_loop <= 0;
        end else begin
            if(avg_loop < avg_loop_max) begin
                if(BRAM_Pool_In1_Address[input_map_address_datawidth - 1 : 0] == In_Address_End) begin
                    avg_loop <= avg_loop + 1;
                end else begin
                    avg_loop <= avg_loop;
                end 
            end else begin
                avg_loop <= 0;
            end 
        end 
    end
    
    // enable
    always @(posedge clk, negedge reset) begin
        if(!reset) begin
            enable <= 4'd0;
        end else begin
            case(state)
                AVG1_STATE:
                    begin
                        if(avg_loop == (avg_loop_max - 1) ) begin
                            enable[3:2] <= 0; enable[1:0] <= 2'b11;
                        end else begin
                            enable <= 4'b1111;
                        end 
                    end
                AVG2_STATE: enable <= 4'b1111;
                AVG3_STATE: enable <= 4'b1111;
                default: enable <= 4'd0;
            endcase
        end 
    end 
    
    // done
    always @(posedge clk, negedge reset) begin
        if(!reset) begin
            done <= 0;
        end else begin
            if( (state == AVG1_STATE) || (state == AVG2_STATE) || (state == AVG3_STATE) ) begin
                if(avg_loop == avg_loop_max) begin
                    done <=1;
                end else begin
                    done <= 0;
                end 
            end else begin
                done <= 0;
            end 
        end 
    end 
    
endmodule
