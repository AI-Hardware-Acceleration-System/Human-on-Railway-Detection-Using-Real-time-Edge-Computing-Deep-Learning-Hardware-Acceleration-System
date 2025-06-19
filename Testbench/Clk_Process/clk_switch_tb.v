`timescale 1ns / 1ps
 
module clock_switch_tb;

    // Parameters
    parameter STATE_DATAWIDTH = 4;
    parameter RESET = 0, IDLE = 1;
    parameter CONV1_1_STATE = 2, CONV1_2_STATE = 3, AVG_POOL1 = 4;
    parameter CONV2_1_STATE = 5, CONV2_2_STATE = 6, AVG_POOL2 = 7;
    parameter CONV3_1_STATE = 8, CONV3_2_STATE = 9, AVG_POOL3 = 10;
    parameter FC_STATE = 11, JUDGE = 12;

    // Testbench signals
    reg clk3, clk1;
    reg rst;
    reg [STATE_DATAWIDTH-1:0] State;
    wire clk_out;

    // Instantiate the DUT (Device Under Test)
    clock_switch uut (
        .clk3(clk3),
        .clk1(clk1),
        .rst(rst),
        .State(State),
        .clk_out(clk_out)
    );

    // Clock generation with phase difference (clk1 leads clk3 by 2 units)
    initial begin
        clk1 = 0;
        clk3 = 0;
        #3 clk1 = 1;
        forever begin
            #15 clk1 = ~clk1;
        end
    end

    initial begin
        forever begin
            #5 clk3 = ~clk3;
        end
    end

    initial begin
        // Initialize signals
        rst = 1;
        State = RESET;

        // Apply reset
        #20;
        rst = 0;
        #43;

        // Sequential state transitions (each state lasts 200 time units)
        State = IDLE;       #100;
        State = CONV1_1_STATE; #100;
        State = CONV1_2_STATE; #100;
        State = AVG_POOL1;  #100;
        State = CONV2_1_STATE; #100;
        State = CONV2_2_STATE; #100;
        State = AVG_POOL2;  #100;
        State = CONV3_1_STATE; #100;
        State = CONV3_2_STATE; #100;
        State = AVG_POOL3;  #100;
        State = FC_STATE;   #100;
        State = JUDGE;      #100;

        // End simulation
        //#200;
        $finish;
    end

    // Monitor changes
    initial begin
        $monitor("Time=%0t | State=%0d | clk1=%b | clk3=%b | clk_out=%b", 
                 $time, State, clk1, clk3, clk_out);
    end

endmodule
