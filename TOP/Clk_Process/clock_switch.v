`timescale 1ns / 1ps
 
//module clock_switch#(
//    parameter STATE_DATAWIDTH = 4,
//    parameter IDLE = 1,
//    parameter CONV1_1_STATE = 2, CONV1_2_STATE = 3, AVG_POOL1 = 4,
//    parameter CONV2_1_STATE = 5, CONV2_2_STATE = 6, AVG_POOL2 = 7,
//    parameter CONV3_1_STATE = 8, CONV3_2_STATE = 9, AVG_POOL3 = 10)
//(
//    input clk_fast, clk_slow, 
//    input reset,
//    input PS_BRAM_busy,
//    input Avg_done,
//    input [STATE_DATAWIDTH-1:0]state,
//    output reg clk_out
//);
////    reg flag_pos, flag_neg, 
//    reg [2:0] counter;  
//    // clock processed 
//    always @(*) begin
//        if(!reset) begin
//            clk_out = clk_slow;
//        end else begin
//            if(state == CONV1_1_STATE || state == CONV1_2_STATE || 
//                state == CONV2_1_STATE || state == CONV2_2_STATE ||
//                state == CONV3_1_STATE || state == CONV3_2_STATE) begin
//                if(counter == 2'd3) begin
//                    clk_out = clk_fast;
//                end else begin
//                    clk_out = clk_slow;
//                end 
//            end else begin
//                clk_out = clk_slow;
//            end 
//        end 
//    end 
    
//    // flag_pos
////    always @(posedge clk_fast, negedge reset) begin
////        if(!reset) begin
////            flag_pos <= 0;
////        end else begin
////            if(!counter) begin
////                if(!clk_fast) begin
////                    flag_pos <= 1;
////                end else begin
////                    flag_pos <= 0;
////                end 
////            end else begin
////                flag_pos <= 0;
////            end 
////        end 
////    end 
    
//    // flag_neg
////    always @(negedge clk_fast, negedge reset) begin
////        if(!reset) begin
////            flag_neg <= 0;
////        end else begin
////            if(!counter) begin
////                if(state == CONV1_1_STATE || state == CONV1_2_STATE || 
////                    state == CONV2_1_STATE || state == CONV2_2_STATE ||
////                    state == CONV3_1_STATE || state == CONV3_2_STATE) begin
////                    if(clk_fast) begin
////                        flag_neg <= 1;
////                    end else begin
////                        flag_neg <= 0;
////                    end     
////                end else begin
////                    flag_neg <= 0;
////                end 
////            end else begin
////                flag_neg <= 0;
////            end 
////        end 
////    end 
    
//    // counter
//    always @(posedge clk_fast, negedge reset) begin
//        if(!reset) begin
//            counter <= 0;
//        end else begin
//             case(state) 
//                IDLE:
//                    begin
//                        if(!PS_BRAM_busy) begin
//                            counter <= counter + 1;
//                        end else begin
//                            counter <= 0;
//                        end 
//                    end 
//                AVG_POOL1, AVG_POOL2:
//                    if(Avg_done) begin
//                        counter <= counter + 1;
//                    end else begin
//                        counter <= 0;
//                    end 
//                CONV1_1_STATE, CONV2_1_STATE, CONV3_1_STATE, 
//                CONV1_2_STATE, CONV2_2_STATE, CONV3_2_STATE: counter <= counter;
//                default: counter <= 0;
//             endcase 
//        end
//    end 
    
//endmodule

module clock_switch#(
    parameter STATE_DATAWIDTH = 4,
    parameter RESET = 0, IDLE = 1,
    parameter CONV1_1_STATE = 2, CONV1_2_STATE = 3, AVG_POOL1 = 4,
    parameter CONV2_1_STATE = 5, CONV2_2_STATE = 6, AVG_POOL2 = 7,
    parameter CONV3_1_STATE = 8, CONV3_2_STATE = 9, AVG_POOL3 = 10,
    parameter FC_STATE = 11,
    parameter JUDGE = 12)
(
    input clk3, clk1, //clk6,
    input rst,
    input [STATE_DATAWIDTH-1:0]State,
    output reg clk_out
);
    
    //wire clk_in;
    //assign clk_in = clk6;
    
    always@(*) begin
        
        // Check if state requires clk3 or clk1
        if (State == CONV1_1_STATE || State == CONV1_2_STATE || 
            State == CONV2_1_STATE || State == CONV2_2_STATE ||
            State == CONV3_1_STATE || State == CONV3_2_STATE) 
        begin
            clk_out = clk3;  // Use clk3 for convolution states
        end
        else begin
            clk_out = clk1;  // Use clk1 for other states
        end
        
    end

//    always@(posedge clk_in or posedge rst) begin
//        if(rst) begin
//            clk_out <= 1'b0;  // Default value, could be `clk3` or any default clock
//        end
//        else begin
//            // Check if state requires clk3 or clk1
//            if (State == CONV1_1_STATE || State == CONV1_2_STATE || 
//                State == CONV2_1_STATE || State == CONV2_2_STATE ||
//                State == CONV3_1_STATE || State == CONV3_2_STATE) 
//            begin
//                clk_out <= clk3;  // Use clk3 for convolution states
//            end
//            else begin
//                clk_out <= clk1;  // Use clk1 for other states
//            end
//        end
//    end
            
endmodule
