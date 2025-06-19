`timescale 1ns / 1ps

module Conv_Control_tb();
    
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
    reg clk, reset;
//    reg weight_ok;
    reg [STATE_DATAWIDTH - 1 : 0] state;
    reg [ADDRESS_DATAWIDTH - 1 : 0] Out_Address;
//    reg [DATA_WIDTH * SA_Units - 1 : 0] Data_In;
    
    // Output
//    wire [DATA_WIDTH * KERNEL_SIZE * SA_Units - 1 : 0] DP_Data;
    wire [LOOP_DATAWIDTH - 1 : 0] current_loop; // to record the present loop value
    wire [FILTER_DATAWIDTH - 1 : 0] current_filter;
    wire last_loop, change, done;
//    wire DP_ok;
    
    // Use the Circuit
    Conv_Control
    CoCo1(
//    .DP_Data(DP_Data),
    .current_loop(current_loop),
    .current_filter(current_filter),
    .last_loop(last_loop),
    .change(change),
//    .DP_ok(DP_ok),
    .done(done),
    .clk(clk), 
    .reset(reset),
//    .weight_ok(weight_ok),
    .state(state),
    .Out_Address(Out_Address)
//    .Data_In(Data_In)
    );
    
    // clock
    initial 
        begin
            clk = 0;
            forever #5 clk = ~clk;
        end
    
    // testcase
    integer i;
    integer j;
    initial
        begin
            reset = 1;  
            // start
            #10 reset = 0;
            #15 reset = 1;
        end
    
    always @(posedge clk, negedge reset) begin                
            if(!reset) begin
                Out_Address <= 1;
                i <= 0;
                j <= 0;
                state <= 0;
            end else begin
                 case(state)
                    CONV1_1_STATE:
                        begin
                            if(Out_Address == 1) begin
                                Out_Address <= 6722;
                            end else if(Out_Address == 6722) begin
                                Out_Address <= 6723;
                            end else begin
                                Out_Address <= 1;
                            end 
                            
                            if(i == 0) begin
                                if(Out_Address == 6723) begin
                                    i <= 0;
                                end else begin
                                    i <= i;
                                end 
                            end else begin
                                if(Out_Address == 6723) begin
                                    i <= i + 1;
                                end else begin
                                    i <= i;
                                end
                            end
                            
                            if(j == 5) begin
                                if( (i == 0) && (Out_Address == 6723) ) begin
                                    j <= 0;
                                    state <= CONV1_2_STATE;
                                end else begin
                                    j <= j;
                                end 
                            end else begin
                                if( (i == 0) && (Out_Address == 6723) ) begin
                                    j <= j + 1;
                                end else begin
                                    j <= j;
                                end
                            end 
                        end
                    CONV1_2_STATE:
                        begin
                            if(Out_Address == 1) begin
                                Out_Address <= 6398;
                            end else if(Out_Address == 6398) begin
                                Out_Address <= 6399;
                            end else begin
                                Out_Address <= 1;
                            end 
                            
                            if(i == 1) begin
                                if(Out_Address == 6399) begin
                                    i <= 0;
                                end else begin
                                    i <= i;
                                end 
                            end else begin
                                if(Out_Address == 6399) begin
                                    i <= i + 1;
                                end else begin
                                    i <= i;
                                end
                            end
                            
                            if(j == 5) begin
                                if( (i == 1) && (Out_Address == 6399) ) begin
                                    j <= 0;
                                    state <= state + 1;
                                end else begin
                                    j <= j;
                                end 
                            end else begin
                                if( (i == 1) && (Out_Address == 6399) ) begin
                                    j <= j + 1;
                                end else begin
                                    j <= j;
                                end
                            end
                        end
                    CONV2_1_STATE:
                        begin
                            if(Out_Address == 1) begin
                                Out_Address <= 1442;
                            end else if(Out_Address == 1442) begin
                                Out_Address <= 1443;
                            end else begin
                                Out_Address <= 1;
                            end 
                            
                            if(i == 1) begin
                                if(Out_Address == 1443) begin
                                    i <= 0;
                                end else begin
                                    i <= i;
                                end 
                            end else begin
                                if(Out_Address == 1443) begin
                                    i <= i + 1;
                                end else begin
                                    i <= i;
                                end
                            end
                            
                            if(j == 15) begin
                                if( (i == 1) && (Out_Address == 1443) ) begin
                                    j <= 0;
                                    state <= CONV2_2_STATE;
                                end else begin
                                    j <= j;
                                end 
                            end else begin
                                if( (i == 1) && (Out_Address == 1443) ) begin
                                    j <= j + 1;
                                end else begin
                                    j <= j;
                                end
                            end
                        end
                    CONV2_2_STATE:
                        begin
                            if(Out_Address == 1) begin
                                Out_Address <= 1294;
                            end else if(Out_Address == 1294) begin
                                Out_Address <= 1295;
                            end else begin
                                Out_Address <= 1;
                            end 
                            
                            if(i == 3) begin
                                if(Out_Address == 1295) begin
                                    i <= 0;
                                end else begin
                                    i <= i;
                                end 
                            end else begin
                                if(Out_Address == 1295) begin
                                    i <= i + 1;
                                end else begin
                                    i <= i;
                                end
                            end
                            
                            if(j == 15) begin
                                if( (i == 3) && (Out_Address == 1295) ) begin
                                    j <= 0;
                                    state <= state + 1;
                                end else begin
                                    j <= j;
                                end 
                            end else begin
                                if( (i == 3) && (Out_Address == 1295) ) begin
                                    j <= j + 1;
                                end else begin
                                    j <= j;
                                end
                            end
                        end
                    CONV3_1_STATE:
                        begin
                            if(Out_Address == 1) begin
                                Out_Address <= 254;
                            end else if(Out_Address == 254) begin
                                Out_Address <= 255;
                            end else begin
                                Out_Address <= 1;
                            end 
                            
                            if(i == 3) begin
                                if(Out_Address == 255) begin
                                    i <= 0;
                                end else begin
                                    i <= i;
                                end 
                            end else begin
                                if(Out_Address == 255) begin
                                    i <= i + 1;
                                end else begin
                                    i <= i;
                                end
                            end
                            
                            if(j == 15) begin
                                if( (i == 3) && (Out_Address == 255) ) begin
                                    j <= 0;
                                    state <= CONV3_2_STATE;
                                end else begin
                                    j <= j;
                                end 
                            end else begin
                                if( (i == 3) && (Out_Address == 255) ) begin
                                    j <= j + 1;
                                end else begin
                                    j <= j;
                                end
                            end
                        end
                    CONV3_2_STATE:
                        begin
                            if(Out_Address == 1) begin
                                Out_Address <= 194;
                            end else if(Out_Address == 194) begin
                                Out_Address <= 195;
                            end else begin
                                Out_Address <= 1;
                            end 
                            
                            if(i == 3) begin
                                if(Out_Address == 195) begin
                                    i <= 0;
                                end else begin
                                    i <= i;
                                end 
                            end else begin
                                if(Out_Address == 195) begin
                                    i <= i + 1;
                                end else begin
                                    i <= i;
                                end
                            end
                            
                            if(j == 15) begin
                                if( (i == 3) && (Out_Address == 195) ) begin
                                    j <= 0;
                                    state <= state + 1;
                                end else begin
                                    j <= j;
                                end 
                            end else begin
                                if( (i == 3) && (Out_Address == 195) ) begin
                                    j <= j + 1;
                                end else begin
                                    j <= j;
                                end
                            end
                        end
                    default:
                        begin
                            state <= state + 1;
                        end
                 endcase
            end 
    end
          
//    always @(posedge clk, negedge reset) begin                
//            // Conv1_1
//            #10 state = 1;
//            for(i = 0;i < 6;i = i+1)
//                begin
//                    #10 Out_Address = 1;
//                    #10 Out_Address = 2;
//                    #20 Out_Address = 3;
//                    #50 Out_Address = 6722;
//                    #10 Out_Address = 6723;
//                end
            
//            // Conv1_2
//            #10 state = 2; Out_Address = 0;
//            for(i = 0;i < 6;i = i+1)
//                begin
//                    for(j = 0;j < 2;j = j+1) 
//                        begin
//                            #10 Out_Address = 1;
//                            #10 Out_Address = 2;
//                            #20 Out_Address = 3;
//                            #50 Out_Address = 6399;     
//                        end
//                end
            
//            // Conv2_1
//            #10 state = 4; Out_Address = 0;
//            for(i = 0;i < 16;i = i+1) // filter
//                begin
//                    for(j = 0;j < 2;j = j+1) // loop 
//                        begin
//                            #10 Out_Address = 1;
//                            #10 Out_Address = 2;
//                            #20 Out_Address = 3;
//                            #50 Out_Address = 1443;     
//                        end
//                end
            
//            // Conv2_2
//            #10 state = 5; Out_Address = 0;
//            for(i = 0;i < 16;i = i+1)
//                begin
//                    for(j = 0;j < 4;j = j+1) 
//                        begin
//                            #10 Out_Address = 1;
//                            #10 Out_Address = 2;
//                            #20 Out_Address = 3;
//                            #50 Out_Address = 1295;     
//                        end
//                end
                
//            // Conv3_1
//            #10 state = 7; Out_Address = 0;
//            for(i = 0;i < 16;i = i+1)
//                begin
//                    for(j = 0;j < 4;j = j+1) 
//                        begin
//                            #10 Out_Address = 1;
//                            #10 Out_Address = 2;
//                            #20 Out_Address = 3;
//                            #50 Out_Address = 255;     
//                        end
//                end
                
//            // Conv3_2
//            #10 state = 8; Out_Address = 0;
//            for(i = 0;i < 16;i = i+1)
//                begin
//                    for(j = 0;j < 4;j = j+1) 
//                        begin
//                            #10 Out_Address = 1;
//                            #10 Out_Address = 2;
//                            #20 Out_Address = 3;
//                            #50 Out_Address = 195;     
//                        end
//                end
//        end
    
endmodule
