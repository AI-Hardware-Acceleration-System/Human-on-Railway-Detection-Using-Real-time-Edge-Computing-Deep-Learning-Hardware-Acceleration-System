`timescale 1ns / 1ps
 
module SA_Addr_Ctrl#(
    parameter KERNEL_SIZE = 3,
    parameter latency = 34,
    parameter out_latency = 4
)(
    input logic clk, rst_n,
    input logic start,
    input logic [6:0] IN_SIZE,
    output logic [12:0] input_addr,
    output logic [12:0] output_addr,
    output logic [12:0] out_temp_addr,
    output logic last_data
);

    logic [1:0] i;
    logic [1:0] j;
    logic [5:0] idle_cnt;
    logic [1:0] out_cnt;
    logic [6:0] row_cnt;
    logic [6:0] column_cnt;
    logic [12:0] out_addr_temp;
    logic [12:0] temp_addr_temp;
    logic done;

    assign out_addr_temp = (column_cnt <= 3 && column_cnt >= 0) ? 7878 : 
                         (row_cnt == 0) ? row_cnt * IN_SIZE + column_cnt - 4 : row_cnt * IN_SIZE + column_cnt - 4 - 2 * row_cnt;
    assign temp_addr_temp = ((column_cnt >= 0 && column_cnt <= 2)||column_cnt == IN_SIZE+1) ? 7878 : 
                           (column_cnt == 3)?(IN_SIZE-KERNEL_SIZE+1)*row_cnt:out_addr_temp + 1;
    assign last_data = (output_addr == (IN_SIZE-KERNEL_SIZE+1) * (IN_SIZE-KERNEL_SIZE+1) - 1) ? 1 : 0;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            row_cnt <= 7'b0;
            column_cnt <= 7'b0;
            i <= 0;
            done <= 0;
            idle_cnt <= 0;
            input_addr <= 7878;
            output_addr <= 7878;
            out_temp_addr <= 7878;
        end
        else begin
            if(start)begin
                if(!done)begin
                    idle_cnt <= 0;
                    if(i < 1) begin      //²Ä¤@­Óclk¤£°µ¨Æ
                        i <= i + 1;
                        j <= 0;
                    end
                    else begin
                        if(j < 2) j <= j + 1;
                        else j <= 0;
                    end
                    if(column_cnt>=j&&column_cnt<=IN_SIZE-1+j)
                        input_addr <= (row_cnt + j) * IN_SIZE + column_cnt - j;                           //NO PADDING
                    else input_addr <= 7878;
                    if(j == 2)begin
                        output_addr <= out_addr_temp;
                        out_temp_addr <= temp_addr_temp;
                        column_cnt <= (column_cnt < IN_SIZE - 1 + KERNEL_SIZE - 1) ? column_cnt + 1 : 0;
                        if(row_cnt < IN_SIZE-(KERNEL_SIZE-1))
                            row_cnt <= (column_cnt == IN_SIZE - 1 + KERNEL_SIZE - 1) ? row_cnt + 1 : row_cnt;
                        else begin
                            input_addr <= 7878;
                        end
                    end
                    else begin
                        column_cnt <= column_cnt;
                        row_cnt <= row_cnt;
                    end
                    if(row_cnt == IN_SIZE-(KERNEL_SIZE-1) && column_cnt == 0) begin
                        done <= 1;
                        input_addr <= 7878;
                    end
                    else done <= 0;
                end
                else begin
                    column_cnt <= 0;
                    row_cnt <= 0;
                    i <= 0;
                    if(idle_cnt < latency) idle_cnt <= idle_cnt + 1;
                    else begin 
                        done <= 0;
                    end
                end
            end
            else begin
                row_cnt <= 7'b0;
                column_cnt <= 7'b0;
                i <= 0;
                done <= 0;
                idle_cnt <= 0;
            end
        end
    end
    

    
endmodule

module SA_Addr_tb();
        
    logic clk, rst_n, start, clk_fast;
    logic [12:0] input_addr;
    logic [12:0] output_addr;
    logic [12:0] out_temp_addr;
    logic [6:0] IN_SIZE;
    logic last_data;
    
    SA_Addr_Ctrl a456(clk, rst_n, start, IN_SIZE,  input_addr, output_addr, out_temp_addr,last_data);
    
    initial begin
        clk_fast <= 0;
        start <= 0;
        rst_n <= 1;
        IN_SIZE <= 16;
        #5 rst_n <= 0;
        #10 rst_n <= 1;
        #30 start <= 1;
        
    end
    
    initial begin
        clk <= 0;
        #2;
        forever #5 clk <= ~clk;
    end
    
    initial begin
        forever #15 clk_fast <= ~clk_fast;
    end
    
endmodule
