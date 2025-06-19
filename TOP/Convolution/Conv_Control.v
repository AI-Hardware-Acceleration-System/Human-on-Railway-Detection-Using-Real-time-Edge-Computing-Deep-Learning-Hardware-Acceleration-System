`timescale 1ns / 1ps

module Conv_Control(
    current_loop, current_filter,
    last_loop, change, // change means changing the parameters
    done,
    clk, reset,
    state,
    Out_Address
    );
     
    // Parameters 
    parameter SA_Units = 4;
    parameter KERNEL_SIZE = 3;
    parameter DATA_WIDTH = 16, STATE_DATAWIDTH = 4, ADDRESS_DATAWIDTH = 13;
    parameter LOOP_DATAWIDTH = 3, FILTER_DATAWIDTH = 5;
    parameter CONV1_1_STATE = 2, CONV1_2_STATE = 3;
    parameter CONV2_1_STATE = 5, CONV2_2_STATE = 6;
    parameter CONV3_1_STATE = 8, CONV3_2_STATE = 9;
    parameter CONV1_1_OUTPUT_SIZE = 82, CONV1_2_OUTPUT_SIZE = 80;
    parameter CONV2_1_OUTPUT_SIZE = 38, CONV2_2_OUTPUT_SIZE = 36;
    parameter CONV3_1_OUTPUT_SIZE = 16, CONV3_2_OUTPUT_SIZE = 14;
    
    // Input
    input clk, reset;
    input [STATE_DATAWIDTH - 1 : 0] state;
    input [ADDRESS_DATAWIDTH - 1 : 0] Out_Address;
    
    // Output
    output reg [LOOP_DATAWIDTH - 1 : 0] current_loop; // to record the present loop value
    output reg [FILTER_DATAWIDTH - 1 : 0] current_filter;
    output reg last_loop, change, done;
    
    // Registers
    reg [LOOP_DATAWIDTH - 1 : 0] loop_max; // to record the maximum loop value
    reg [FILTER_DATAWIDTH - 1 : 0] filter_max; // to record the maximum filter value
    reg [ADDRESS_DATAWIDTH - 1 : 0] Out_Address_End;
    
//-------------------------------------------------------------------------Processing----------------------------------------------------------
    
    // loop_max & filter_max & Out_Address_End
    always @(*) begin
        if(!reset) begin
            loop_max = 0; filter_max = 0;
            Out_Address_End = CONV1_1_OUTPUT_SIZE * CONV1_1_OUTPUT_SIZE - 1;
        end else begin
            case(state)
                CONV1_1_STATE: // conv1_1
                    begin
                    loop_max = 0; filter_max = 5;
                    Out_Address_End = CONV1_1_OUTPUT_SIZE * CONV1_1_OUTPUT_SIZE - 1;
                    end
                CONV1_2_STATE: // conv1_2
                    begin
                    loop_max = 1; filter_max = 5;
                    Out_Address_End = CONV1_2_OUTPUT_SIZE * CONV1_2_OUTPUT_SIZE - 1;
                    end
                CONV2_1_STATE: // conv2_1
                    begin
                    loop_max = 1; filter_max = 15;
                    Out_Address_End = CONV2_1_OUTPUT_SIZE * CONV2_1_OUTPUT_SIZE - 1;
                    end
                CONV2_2_STATE: // conv2_2
                    begin
                    loop_max = 3; filter_max = 15;
                    Out_Address_End = CONV2_2_OUTPUT_SIZE * CONV2_2_OUTPUT_SIZE - 1;
                    end
                CONV3_1_STATE: // conv3_1
                    begin
                    loop_max = 3; filter_max = 15;
                    Out_Address_End = CONV3_1_OUTPUT_SIZE * CONV3_1_OUTPUT_SIZE - 1;
                    end
                 CONV3_2_STATE: // conv3_2
                    begin
                    loop_max = 3; filter_max = 15;
                    Out_Address_End = CONV3_2_OUTPUT_SIZE * CONV3_2_OUTPUT_SIZE - 1;
                    end
                default: // Not any Conv
                    begin
                    loop_max = 0; filter_max = 0;
                    Out_Address_End = CONV1_1_OUTPUT_SIZE * CONV1_1_OUTPUT_SIZE - 1;
                    end
            endcase
        end 
    end
    
    // last loop
    always @(posedge clk, negedge reset) begin
        if(!reset) begin
            last_loop <= 0;
        end else begin
//            if( (state == CONV1_1_STATE) || (state == CONV1_2_STATE) || (state == CONV2_1_STATE) || (state == CONV2_2_STATE) || (state == CONV3_1_STATE) || (state == CONV3_2_STATE) ) begin
//                if(last_loop) begin
//                    last_loop <= 0;
//                end else begin
//                    if(current_loop == loop_max ) begin
//                        if(Out_Address == (Out_Address_End - 1) ) begin
//                            last_loop <= 1;
//                        end else begin
//                            last_loop <= 0;
//                        end 
//                    end else begin
//                        last_loop <= 0;
//                    end 
//                end 
//            end else begin
//                last_loop <= 0;
//            end
            
            if(current_loop == loop_max) begin
                if(( (state == CONV1_1_STATE) || (state == CONV1_2_STATE) || (state == CONV2_1_STATE) || (state == CONV2_2_STATE) || (state == CONV3_1_STATE) || (state == CONV3_2_STATE) ) && change==1'd1)begin
                    last_loop = 1;
                end else begin
                    last_loop = 0;
                end 
            end else begin
                last_loop = 0;
            end
        end 
    end 
    
    // current_loop && current_filter && change;
    always @(posedge clk, negedge reset) begin
        if(!reset) begin
            current_loop <= 0; current_filter <= 0; //change <= 0;
        end else begin
            if(Out_Address == Out_Address_End) begin
                if(current_loop == loop_max) begin
                    current_loop <= 0; //change <= 1;
                    if(current_filter == filter_max) begin
                        current_filter <= 0;
                    end else begin
                        current_filter <= current_filter + 1;
                    end 
                end else begin
                    current_loop <= current_loop + 1;
                    //change <= 0;
                end 
            end else begin
                current_loop <= current_loop; 
                current_filter <= current_filter;
                //change <= 0;
            end 
        end
    end 
    
    // done
    always @(*) begin
        if( (Out_Address == Out_Address_End) && (current_loop == loop_max) && (current_filter == filter_max) ) begin
            done = 1; 
        end else begin
            done = 0;
        end 
    end
    
    // change
    always @(posedge clk, negedge reset) begin
        if(!reset) begin
            change <= 0;
        end else begin
            if(Out_Address == (Out_Address_End - 1) ) begin
                change <= 1;
            end else begin
                change <= 0;
            end 
        end 
    end 
    
endmodule
