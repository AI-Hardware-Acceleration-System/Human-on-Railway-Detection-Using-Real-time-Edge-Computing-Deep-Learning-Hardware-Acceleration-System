`timescale 1ns / 1ps
 
module Master_FSM_tb();
    
    parameter STATE_DATAWIDTH = 4;
    parameter ADDRESS_DATAWIDTH = 13; // for PS BRAM
    parameter INPUT_SIZE = 80;
    
    // total state
    parameter IDLE = 0;
    parameter CONV1_1_STATE = 1, CON1_2_STATE = 2, AVG_POOL1 = 3;
    parameter CONV2_1_STATE = 4, CON2_2_STATE = 5, AVG_POOL2 = 6;
    parameter CONV3_1_STATE = 7, CON3_2_STATE = 8, AVG_POOL3 = 9;
    parameter FC_STATE = 10;
    parameter JUDGE = 11;
    
    // input
    reg clk,reset;
    reg Conv_done, Avg_done, FC_done, Judge_done;
    reg [ADDRESS_DATAWIDTH - 1: 0] address;
    
    // output
    wire [STATE_DATAWIDTH - 1 : 0] state;
    
    // call the module
    Master_FSM
    MF1(
    .state(state),
    .clk(clk),
    .reset(reset),
    .Conv_done(Conv_done), 
    .Avg_done(Avg_done), 
    .FC_done(FC_done), 
    .Judge_done(Judge_done),
    .address(address)
    );
    
    //-------------------------------------------------------------------testcase--------------------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end 
    
    initial begin
        reset = 1; 
//        address = 0;
//        Conv_done = 0; Avg_done = 0; FC_done = 0; Judge_done = 0;
        #10 reset = 0;
        #5 reset = 1;  
        // round 1 
//        #10 address = 1;
//        #10 address = 6399;
//        #10 address = 1;
//        #10 Conv_done = 1;
//        #10 Conv_done = 0;
//        #10 Conv_done = 1;
//        #10 Conv_done = 0;
//        #10 Avg_done = 1;
//        #10 Avg_done = 0;
//        #10 Conv_done = 1;
//        #10 Conv_done = 0;
//        #10 Conv_done = 1;
//        #10 Conv_done = 0;
//        #10 Avg_done = 1;
//        #10 Avg_done = 0;
//        #10 Conv_done = 1;
//        #10 Conv_done = 0;
//        #10 Conv_done = 1;
//        #10 Conv_done = 0;
//        #10 Avg_done = 1;
//        #10 Avg_done = 0;
//        #10 FC_done = 1;
//        #10 FC_done = 0;
//        #10 Judge_done = 1;
//        #10 Judge_done = 0;
        // round 2
//        #10 address = 2;
//        #10 address = 6399;
//        #10 address = 1;
    end 
    
    reg [4:0] counter;
    always @(posedge clk, negedge reset) begin
        if(!reset) begin
            Conv_done <= 0; Avg_done <= 0; FC_done <= 0; Judge_done <= 0; address <= 0;
            counter <= 0;
        end else begin
            counter <= counter + 1;
            case(counter)
                0:  address <= 1;
                1:  address <= 6399;
                2:  address <= 1;
                3:  Conv_done <= 1;
                4:  Conv_done <= 0;
                5:  Conv_done <= 1;
                6:  Conv_done <= 0;
                7:  Avg_done <= 1;
                8:  Avg_done <= 0;
                9:  Conv_done <= 1;
                10:  Conv_done <= 0;
                11:  Conv_done <= 1;
                12:  Conv_done <= 0;
                13:  Avg_done <= 1;
                14:  Avg_done <= 0;
                15:  Conv_done <= 1;
                16:  Conv_done <= 0;
                17:  Conv_done <= 1;
                18:  Conv_done <= 0;
                19:  Avg_done <= 1;
                20:  Avg_done <= 0;
                21:  FC_done <= 1;
                22:  FC_done <= 0;
                23:  Judge_done <= 1;
                24:  Judge_done <= 0;
                25:  address <= 1;
                26:  address <= 6399;
                default:  address <= 1;
            endcase
        end 
    end 
    
endmodule
