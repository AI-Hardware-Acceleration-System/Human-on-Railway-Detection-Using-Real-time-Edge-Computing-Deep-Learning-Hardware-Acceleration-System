`timescale 1ns / 1ps

module Final_Judge#(
    parameter STATE_DATAWIDTH = 4,
    parameter JUDGE_STATE = 11,
    parameter PICTURES = 35
)
    (
    output reg bool,
    output reg judge_done,
    output reg all_done,
    input clk, rst,
    input [15:0] human, 
    input [15:0] no_human, 
    input [STATE_DATAWIDTH-1:0] State
    );
     
    wire [15:0] threshold = 16'h4065; //ln0.9-ln(1-0.9) in float 16 //softmax reverse
    wire [15:0] nohuman_add_threshold;
    wire compare;
    reg [5:0] counter;
    
    floatAdd16 ADD(.floatA(no_human), .floatB(threshold), .sum(nohuman_add_threshold));
    float16_comparator COMPARE (.out_compared(compare),.first_comp(nohuman_add_threshold), .second_comp(human));
    //compare if second_comp if bigger
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            bool <= 1'b0;
            judge_done <= 1'b0;
            counter <= 6'd0;
            all_done <= 1'b0;
        end
        else begin
            if(State == JUDGE_STATE)begin
                bool <= compare;
                judge_done <= 1'b1;                
                if(counter < PICTURES)begin
                    if(!bool)begin
                        counter <= counter + 6'd1;
                        all_done <= 1'b0;
                    end
                    else begin
                        counter <= 6'd0;
                        all_done <= 1'b1;
                    end
                end
                else begin
                    counter <= 6'd0;
                    all_done <= 1'b1;
                end
            end
            else begin
                bool <= 1'b0;
                judge_done <= 1'b0;
                all_done <= 1'b0;
            end
        end
    end
    
endmodule
