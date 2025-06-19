`timescale 1ns / 1ps

module Enable_Ctrl#(
    parameter BIGs = 12,
    parameter SMALLs = 32,
    parameter SA_Units = 4,
    parameter Pool_Units = 4,
    parameter RESET = 0, IDLE = 1,
    parameter CONV1_1_STATE = 2, CONV1_2_STATE = 3, AVG_POOL1 = 4,
    parameter CONV2_1_STATE = 5, CONV2_2_STATE = 6, AVG_POOL2 = 7,
    parameter CONV3_1_STATE = 8, CONV3_2_STATE = 9, AVG_POOL3 = 10,
    parameter FC_STATE = 11,
    parameter JUDGE = 12 
)(
    input logic clk, rst_n,
    input logic [3:0] state,
    input logic [1:0] current_loop,
    input logic [3:0] current_filter,
    input logic [1:0] Pool_loop,
    output logic [BIGs-1:0] ENA,     //?g
    output logic [BIGs-1:0] ENB,     //??
    output logic [SMALLs-1:0]ena,
    output logic [SMALLs-1:0]enb 
);
    
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ENA <= 0;
            ENB <= 0;
            ena <= 0;
            enb <= 0;
        end
        else begin
            case(state)
            ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                RESET: begin
                    ENA <= 0;
                    ENB <= 0;
                    ena <= 0;
                    enb <= 0;
                end
                IDLE: begin
                    ENA <= 0;
                    ENB <= 0;
                    ena <= 0;
                    enb <= 0;
                end
            ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                CONV1_1_STATE: begin
                    ENA <= 12'b1 << current_filter;    //?g
                    ENB <= 0;    //??(????)
                    ena <= 0;
                    enb <= 0;
                end
                CONV1_2_STATE: begin
                    ENA <= 12'b1 << current_filter + BIGs / 2;    //?g
                    ENB[BIGs/2-1:0] <= 6'b1111 << current_loop * SA_Units;    //??
                    ENB[BIGs-1:BIGs/2] <= 0;    //??
                    ena <= 0;
                    enb <= 0;
                end
                CONV2_1_STATE: begin
                    ENA <= 0;    //?g(????)
                    ENB[BIGs/2-1:0] <= 6'b1111 << current_loop * SA_Units;    //??
                    ENB[BIGs-1:BIGs/2] <= 0;    //??
                    ena <= 32'b1 << current_filter;
                    enb <= 0;
                end
                CONV2_2_STATE: begin
                    ENA <= 0;    //?g
                    ENB <= 0;    //??
                    ena <= 32'b1 << current_filter + SMALLs / 2;
                    enb[SMALLs/2-1:0] <= 16'b1111 << current_loop * SA_Units;
                    enb[SMALLs-1:SMALLs/2] <= 0;
                end
                CONV3_1_STATE: begin
                    ENA <= 0;    //?g
                    ENB <= 0;    //??
                    ena <= 32'b1 << current_filter + SMALLs / 2;
                    enb[SMALLs/2-1:0] <= 16'b1111 << current_loop * SA_Units;
                    enb[SMALLs-1:SMALLs/2] <= 0;
                end
                CONV3_2_STATE: begin
                    ENA <= 0;    //?g
                    ENB <= 0;    //??
                    ena <= 32'b1 << current_filter;
                    enb[SMALLs/2-1:0] <= 0;
                    enb[SMALLs-1:SMALLs/2] <= 16'b1111 << current_loop * SA_Units;
                end
            ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                AVG_POOL1: begin
                    ENA[BIGs/2-1:0] <= 6'b1111 << ((Pool_loop == 2) ? ((Pool_loop-1) * Pool_Units) : (Pool_loop * Pool_Units));
                    ENA[BIGs-1:BIGs/2] <= 0;
                    ENB[BIGs/2-1:0] <= 0;
                    ENB[BIGs-1:BIGs/2] <= 6'b1111 << ((Pool_loop == 2) ? ((Pool_loop-1) * Pool_Units) : (Pool_loop * Pool_Units));
                    ena <= 0;
                    enb <= 0;
                end
                AVG_POOL2: begin
                    ENA <= 0;
                    ENB <= 0;
                    ena[SMALLs/2-1:0] <= 16'b1111 << ((Pool_loop == 4) ? ((Pool_loop-1) * Pool_Units) : (Pool_loop * Pool_Units));
                    ena[SMALLs-1:SMALLs/2] <= 0;
                    enb[SMALLs/2-1:0] <= 0;
                    enb[SMALLs-1:SMALLs/2] <= 16'b1111 << ((Pool_loop == 4) ? ((Pool_loop-1) * Pool_Units) : (Pool_loop * Pool_Units));
                end
                AVG_POOL3: begin
                    ENA <= 0;
                    ENB <= 0;
                    ena[SMALLs/2-1:0] <= 0;
                    ena[SMALLs-1:SMALLs/2] <= 16'b1111 << ((Pool_loop == 4) ? ((Pool_loop-1) * Pool_Units) : (Pool_loop * Pool_Units));
                    enb[SMALLs/2-1:0] <= 16'b1111 << ((Pool_loop == 4) ? ((Pool_loop-1) * Pool_Units) : (Pool_loop * Pool_Units));
                    enb[SMALLs-1:SMALLs/2] <= 0;
                end
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                FC_STATE: begin
                    ENA <= 0;
                    ENB <= 0;
                    ena <= 0;
                    enb[SMALLs-1:SMALLs/2] <= 16'b1111111111111111;
                    enb[SMALLs/2 - 1:0] <= 16'b0;
                end
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                JUDGE: begin
                    ENA <= 0;
                    ENB <= 0;
                    ena <= 0;
                    enb <= 0;
                end
                default: begin
                    ENA <= 0;
                    ENB <= 0;
                    ena <= 0;
                    enb <= 0;
                end
            endcase
        end
    end
    
endmodule
