`timescale 1ns / 1ps

module Weight_Buffer_TB();
     
    // Parameters
    parameter KERNEL_SIZE = 3;
    parameter ROM_ADDRESS_DATAWIDTH = 12;
    parameter COUNTER_DATAWIDTH = 4;
    parameter NUMBER_DATAWIDTH = 16;
    
    //input
    reg clk, reset; // clk is normal clock
    reg enable, change;
//    reg clk_slow;
    
    //output
    wire [NUMBER_DATAWIDTH - 1 : 0] weight0, weight1, weight2, weight3, weight4, weight5, weight6, weight7, weight8;
    wire weight_OK;
    
    Weight_Buffer
    Weight_Buffer_1(
    .weight0(weight0),
    .weight1(weight1),
    .weight2(weight2),
    .weight3(weight3),
    .weight4(weight4),
    .weight5(weight5),
    .weight6(weight6),
    .weight7(weight7),
    .weight8(weight8),
    .clk(clk),
//    .clk_slow(clk_slow), 
    .reset(reset),
    .enable(enable), 
    .change(change), // change to another channel
    .weight_OK(weight_OK)
    );
    
    // clock_normal
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // clock_slow
//    initial begin
//        clk_slow = 0;
//        #5;
//        forever #15 clk_slow = ~ clk_slow;
//    end
    
    initial begin
        reset = 1;
        #15 reset = 0;
        #15 reset = 1;
//        #15 enable = 1;
//        #125 change = 1;
//        #30 change = 0;
    end 
    
    integer counter;
    // change
    always @(posedge clk, negedge reset) begin
        if(!reset) begin
            change <= 0;
        end else begin
            if( ( (counter % 15) == 0) && (counter != 0) ) begin
                change <= 1;
            end else begin
                change <= 0;
            end 
        end 
    end
    
//    always @(posedge clk, negedge reset) begin
//        if(!reset) begin
//            change <= 0;
//        end else begin
//            if( ( (counter % 4) == 0) && (counter != 0) ) begin
//                change <= 1;
//            end else begin
//                change <= 0;
//            end 
//        end 
//    end 
    
//    always @(posedge clk, negedge reset) begin
//        if(!reset) begin
//            enable <= 0;
//        end else begin
//            if( (counter % 9) == 0) begin
//                enable <= 0;
//            end else if( (counter % 12) == 0) begin
//                enable <= 1;
//            end else begin
//                if(counter == 0) begin
//                    enable <= 0;
//                end else if(counter == 1) begin
//                    enable <= 1;
//                end else begin
//                    enable <= enable;
//                end 
//            end
//        end 
//    end
    
    // enable
    always @(posedge clk, negedge reset) begin
        if(!reset) begin
            enable <= 0;
        end else begin
            if( (counter % 15) == 0) begin
                enable <= 1;
            end else if( (counter % 15) == 14) begin
                enable <= 0;
            end else begin
                enable <= enable;
            end
        end 
    end
    
    // counter
    always @(posedge clk, negedge reset) begin
        if(!reset) begin
            counter <= 0;
        end else begin
//            if(enable) begin
                counter <= counter + 1;
//            end else begin
//                counter <= 0;
//            end 
        end 
    end
    
endmodule
