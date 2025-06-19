`timescale 1ns / 1ps

module FC_MemCtrl#(
    parameter Fully_Connect = 11
)(
    input logic clk, rst,
    input logic [3:0] state,
    output logic [12:0] input_addr
);

    logic [6:0] cnt;
    logic start;
     
    assign start = (state == Fully_Connect) ? 1 : 0;
    
    always_ff @ (posedge clk or negedge rst) begin
        if(!rst) begin
            input_addr <= 7878;
            cnt <= 0;
        end
        else begin
            if(start) begin
                if((cnt >= 49 && cnt <= 51) || cnt >= 101) input_addr <= 7878;
                else if (cnt < 49) input_addr <= cnt;
                else input_addr <= cnt - 3;
                cnt <= cnt + 1;
            end
            else begin
                input_addr <= 7878;
                cnt <= 0;
            end
        end
    end
    
endmodule
