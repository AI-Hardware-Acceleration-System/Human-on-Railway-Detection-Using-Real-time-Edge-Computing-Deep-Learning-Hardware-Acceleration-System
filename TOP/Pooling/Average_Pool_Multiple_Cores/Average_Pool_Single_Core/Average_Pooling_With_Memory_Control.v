`timescale 1ns / 1ps

module Average_Pool1_With_Memory_Control(
    wr_ena, enable, clk, reset,
    state,
    BRAM_Pool_In1, BRAM_Pool_In1_Address,
    BRAM_Pool_Out1, BRAM_Pool_Out1_Address 
    );
    
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
    
    // I/O port
//    input pool_start;
    input enable;
    input clk, reset; // Only using calculated_clk in this module is fine
    input [STATE_DATAWIDTH - 1 : 0] state;
    input [number_datawidth - 1:0] BRAM_Pool_In1; //to get data from input BRAM
    
//    output reg pool_end;
    output reg wr_ena;
    output reg [input_map_address_datawidth - 1:0] BRAM_Pool_In1_Address;
    output [number_datawidth - 1:0] BRAM_Pool_Out1; //to save data in output BRAM
    output reg [output_map_address_datawidth - 1:0] BRAM_Pool_Out1_Address;
    
    //Get last clock data from input BRAM
    reg [number_datawidth - 1:0] BRAM_Pool_In1_last_clock; 
    
    // middle data process
    reg [middle_data_index_datawidth - 1:0] Out_Middle_Index;
//    reg [middle_data_index_datawidth - 1:0] Out_Middle_Index_Vertical;
    reg [number_datawidth - 1:0] Out_Middle [AVG1_OUTPUT_SIZE - 1:0];
//    reg up_down_row; // to judge upper or lower row
//    reg enable; //to let this module work
    reg [input_datawidth - 1 : 0] input_size;
    reg [middle_data_index_datawidth - 1 : 0] output_size;
    
//--------------------------------------------------------------------------start calculating ----------------------------------------------------------------------------------
    
    // Adder and Multiplier
    
        //variable for first adder
//        reg [number_datawidth - 1:0] in1, in0;
        wire [number_datawidth - 1:0] out_middle_temp;
        //variable for second adder
//        reg [number_datawidth - 1:0] out_middle_1, out_middle_2;
        wire [number_datawidth - 1:0] out_for_multiplier;
        //variable for multiplier
//        wire [number_datawidth - 1:0] product;
        
        floatAdd16 pool1_add1(BRAM_Pool_In1, BRAM_Pool_In1_last_clock, out_middle_temp);
        floatAdd16 pool1_add2(out_middle_temp, Out_Middle[Out_Middle_Index], out_for_multiplier);
//        floatMult16 pool1_mult1(out_for_multiplier, 16'b0_01101_0000000000, BRAM_Pool_Out1); // 0_01101_0000000000 is float16 representation of 0.25
        assign BRAM_Pool_Out1 = { out_for_multiplier[15], (out_for_multiplier[14:10] - 2'd2), out_for_multiplier[9:0] };
        
//------------------------------------------------------------------------------input output size --------------------------------------------------------------------------------
    always @(*) begin
        if(!reset) begin
            input_size = AVG1_INPUT_SIZE;
            output_size = AVG1_OUTPUT_SIZE;
        end else begin
            case(state)
                AVG1_STATE:
                    begin
                        input_size = AVG1_INPUT_SIZE;
                        output_size = AVG1_OUTPUT_SIZE;
                    end
                AVG2_STATE:
                    begin
                        input_size = AVG2_INPUT_SIZE;
                        output_size = AVG2_OUTPUT_SIZE;
                    end
                AVG3_STATE:
                    begin
                        input_size = AVG3_INPUT_SIZE;
                        output_size = AVG3_OUTPUT_SIZE;
                    end
                default:
                    begin
                        input_size = AVG1_INPUT_SIZE;
                        output_size = AVG1_OUTPUT_SIZE;
                    end
            endcase
        end
    end 
    
    
//------------------------------------------------------------------------------variable process --------------------------------------------------------------------------------
    
    // enable judge
//    always @(*) begin
//        if(!reset) begin
//            enable = 0;
//        end else begin
//            if(pool_start) begin
//                enable = 1;
//            end else if(pool_end) begin
                
//            end else begin
            
//            end
//            enable = pool_start;
//        end 
//    end 
    
    // BRAM_Pool_In1_last_clock data process
    always @(posedge clk) begin
        BRAM_Pool_In1_last_clock <= BRAM_Pool_In1;
    end
    
//------------------------------------------------------------------------------address process --------------------------------------------------------------------------------
    // BRAM_Pool_In1_Address process
    always @(posedge clk, negedge reset) begin
        if(!reset) begin
            BRAM_Pool_In1_Address <= 0;
        end else begin
            if(enable) begin
                if(BRAM_Pool_In1_Address == (input_size * input_size - 1)/*need to test if it's decimal form*/ ) begin//finish one input_map
                    BRAM_Pool_In1_Address <= 0;
                end else begin
                    BRAM_Pool_In1_Address <= BRAM_Pool_In1_Address +1;
                end 
//                BRAM_Pool_In1_Address <= BRAM_Pool_In1_Address +1;
            end else begin
                BRAM_Pool_In1_Address <= 0;
            end  
        end 
    end 
    
    // Out_Middle_Index
    always @(posedge clk, negedge reset) begin
        if(!reset) begin 
            Out_Middle_Index <= 0;
        end else begin
            if( (BRAM_Pool_In1_Address % 2) == 1 ) begin
                if( (BRAM_Pool_In1_Address % input_size ) == 1 ) begin
                    Out_Middle_Index <= 0;
                end else begin
                    Out_Middle_Index <= Out_Middle_Index + 1; 
                end 
            end else begin
                Out_Middle_Index <= Out_Middle_Index;
            end
        end
    end
    
    // Out_Middle
//    reg [middle_data_index_datawidth - 1:0] i;
    always @(posedge clk) begin
        if( (BRAM_Pool_In1_Address % 2) == 0 ) begin
            Out_Middle[Out_Middle_Index] <= out_middle_temp; 
        end else begin
            Out_Middle[Out_Middle_Index] <= Out_Middle[Out_Middle_Index];
        end
    end
    
    // BRAM_Pool_Out1_Address
    always @(posedge clk, negedge reset) begin
        if(!reset) begin 
            BRAM_Pool_Out1_Address <= 0;
        end else begin
            if( (BRAM_Pool_In1_Address % 2) == 1 ) begin
                if( (BRAM_Pool_In1_Address % (2 * input_size) ) > input_size ) begin
                    if(BRAM_Pool_In1_Address != (input_size + 1) ) begin
                        if(BRAM_Pool_Out1_Address != (output_size * output_size - 1) ) begin
                            BRAM_Pool_Out1_Address <= BRAM_Pool_Out1_Address + 1;
                        end else begin
                            BRAM_Pool_Out1_Address <= 0;
                        end 
                    end else begin
                        BRAM_Pool_Out1_Address <= 0; 
                    end 
                end else begin
                    BRAM_Pool_Out1_Address <= BRAM_Pool_Out1_Address; 
                end 
            end else begin
                BRAM_Pool_Out1_Address <= BRAM_Pool_Out1_Address;
            end
        end
    end
    
    // pool_end
    
    
    // wr_ena
    always @(posedge clk, negedge reset) begin
        if (!reset) begin
            wr_ena <= 0;
        end else begin
            if ( ( (BRAM_Pool_In1_Address % 2) == 1 ) && ( (BRAM_Pool_In1_Address % (2*input_size) ) > input_size) ) begin
                wr_ena <= 1;
            end else begin
                wr_ena <= 0;
            end 
        end 
    end 
    
    // enable
//    always @(posedge clk, negedge reset) begin
//        if (!reset) begin
//            enable <= 0;
//        end else begin
//            if (pool_end) begin
//                enable <= 0;
//            end else if(pool_start) begin
//                enable <= 1;
//            end else begin
//                enable <= enable;
//            end 
//        end 
//    end
    
endmodule
