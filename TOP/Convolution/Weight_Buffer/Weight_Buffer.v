`timescale 1ns / 1ps
 
module Weight_Buffer(
    weight0, weight1, weight2, weight3, weight4, weight5, weight6, weight7, weight8,
    clk, reset, //clk is normal clock
    enable, 
    change, // change to another channel,
    weight_OK
    );
    
    parameter KERNEL_SIZE = 3;
    parameter ROM_ADDRESS_DATAWIDTH = 12;
    parameter COUNTER_DATAWIDTH = 4;
    parameter NUMBER_DATAWIDTH = 16;
    
    //input
    input clk, reset;
    input enable,change;
    
    // output
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight0;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight1;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight2;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight3;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight4;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight5;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight6;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight7;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight8;
    output reg weight_OK;
    
    // Registers
    reg [ROM_ADDRESS_DATAWIDTH - 1 : 0] ROM_Address;
    reg [COUNTER_DATAWIDTH - 1 : 0] Address_Counter;
    reg flag; // to delay one clock of the first loop
    
    // Wire
    wire [NUMBER_DATAWIDTH - 1 : 0] Rom_out;
    
    // Load Weight Data
    Weight_Rom_Core1
    Weight_Rom_Core1_1(
    .clka(clk),
    .addra(ROM_Address),
    .douta(Rom_out)
    );
    
    // flag
    always @(posedge clk, negedge reset) begin
        if(!reset) begin
            flag <= 0;
        end else begin
            if(enable) begin
                flag <= 1;
            end else begin
                flag <= flag;
            end 
        end 
    end 
    
    // ROM_Address & flag
    always @(posedge clk, negedge reset) begin
        if (!reset) begin
            ROM_Address <= 0;
        end else begin
            if (enable) begin
                if ( (ROM_Address % (KERNEL_SIZE * KERNEL_SIZE) ) == (KERNEL_SIZE * KERNEL_SIZE - 1) ) begin
                    if (change) begin
                        ROM_Address <= ROM_Address + 1;
                    end else begin
                        ROM_Address <= ROM_Address;
                    end
                end else begin
                    if(flag) begin
                        ROM_Address <= ROM_Address + 1;
                    end else begin
                        ROM_Address <= ROM_Address;
                    end
                end 
            end else begin
                ROM_Address <= ROM_Address;
            end
        end 
    end 
    
    // Address_Counter
    always @ (posedge clk) begin
        Address_Counter <= ROM_Address % (KERNEL_SIZE * KERNEL_SIZE);
    end 
    
    // Weight Value
    always @ (*) begin
        case (Address_Counter)
            4'd1: weight1 = Rom_out;
            4'd2: weight2 = Rom_out;
            4'd3: weight3 = Rom_out;
            4'd4: weight4 = Rom_out;
            4'd5: weight5 = Rom_out;
            4'd6: weight6 = Rom_out;
            4'd7: weight7 = Rom_out;
            4'd8: weight8 = Rom_out;
            default: begin // 4'd0
                            weight0 = Rom_out;
                         end
        endcase
    end
    
    always @(*) begin
        if(!reset) begin
            weight_OK  = 0;
        end else begin
            if(enable) begin
                if( Address_Counter == (KERNEL_SIZE * KERNEL_SIZE - 1) )
                    if(change || ( (ROM_Address % KERNEL_SIZE * KERNEL_SIZE) == 0) ) begin
                        weight_OK  = 0;
                    end else begin
                        weight_OK  = 1;
                    end 
                else
                    weight_OK  = 0;
            end else begin
                weight_OK  = 0;
            end 
        end
    end 
    
endmodule

module Weight_Buffer_0(
    weight0, weight1, weight2, weight3, weight4, weight5, weight6, weight7, weight8,
    clk, reset, //clk is normal clock
    enable, 
    change, // change to another channel,
    weight_OK
    );
    
    parameter KERNEL_SIZE = 3;
    parameter ROM_ADDRESS_DATAWIDTH = 12;
    parameter COUNTER_DATAWIDTH = 4;
    parameter NUMBER_DATAWIDTH = 16;
    
    //input
    input clk, reset;
    input enable,change;
    
    // output
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight0;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight1;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight2;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight3;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight4;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight5;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight6;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight7;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight8;
    output reg weight_OK;
    
    // Registers
    reg [ROM_ADDRESS_DATAWIDTH - 1 : 0] ROM_Address;
    reg [COUNTER_DATAWIDTH - 1 : 0] Address_Counter;
    reg flag; // to delay one clock of the first loop
    
    // Wire
    wire [NUMBER_DATAWIDTH - 1 : 0] Rom_out;
    
    // Load Weight Data
    Weight_Rom_1
    Weight_Rom_1(
    .clka(clk),
    .addra(ROM_Address),
    .douta(Rom_out)
    );
    
    // flag
    always @(posedge clk, negedge reset) begin
        if(!reset) begin
            flag <= 0;
        end else begin
            if(enable) begin
                flag <= 1;
            end else begin
                flag <= flag;
            end 
        end 
    end 
    
    // ROM_Address & flag
    always @(posedge clk, negedge reset) begin
        if (!reset) begin
            ROM_Address <= 0;
        end else begin
            if (enable) begin
                if ( (ROM_Address % (KERNEL_SIZE * KERNEL_SIZE) ) == (KERNEL_SIZE * KERNEL_SIZE - 1) ) begin
                    if (change) begin
                        ROM_Address <= ROM_Address + 1;
                    end else begin
                        ROM_Address <= ROM_Address;
                    end
                end else begin
                    if(flag) begin
                        ROM_Address <= ROM_Address + 1;
                    end else begin
                        ROM_Address <= ROM_Address;
                    end
                end 
            end else begin
                ROM_Address <= ROM_Address;
            end
        end 
    end 
    
    // Address_Counter
    always @ (posedge clk) begin
        Address_Counter <= ROM_Address % (KERNEL_SIZE * KERNEL_SIZE);
    end 
    
    // Weight Value
    always @ (*) begin
        case (Address_Counter)
            4'd1: weight1 = Rom_out;
            4'd2: weight2 = Rom_out;
            4'd3: weight3 = Rom_out;
            4'd4: weight4 = Rom_out;
            4'd5: weight5 = Rom_out;
            4'd6: weight6 = Rom_out;
            4'd7: weight7 = Rom_out;
            4'd8: weight8 = Rom_out;
            default: begin // 4'd0
                            weight0 = Rom_out;
                         end
        endcase
    end
    
    always @(*) begin
        if(!reset) begin
            weight_OK  = 0;
        end else begin
            if(enable) begin
                if( Address_Counter == (KERNEL_SIZE * KERNEL_SIZE - 1) )
                    if(change || ( (ROM_Address % KERNEL_SIZE * KERNEL_SIZE) == 0) ) begin
                        weight_OK  = 0;
                    end else begin
                        weight_OK  = 1;
                    end 
                else
                    weight_OK  = 0;
            end else begin
                weight_OK  = 0;
            end 
        end
    end 
    
endmodule

module Weight_Buffer_1(
    weight0, weight1, weight2, weight3, weight4, weight5, weight6, weight7, weight8,
    clk, reset, //clk is normal clock
    enable, 
    change, // change to another channel,
    weight_OK
    );
    
    parameter KERNEL_SIZE = 3;
    parameter ROM_ADDRESS_DATAWIDTH = 12;
    parameter COUNTER_DATAWIDTH = 4;
    parameter NUMBER_DATAWIDTH = 16;
    
    //input
    input clk, reset;
    input enable,change;
    
    // output
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight0;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight1;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight2;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight3;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight4;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight5;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight6;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight7;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight8;
    output reg weight_OK;
    
    // Registers
    reg [ROM_ADDRESS_DATAWIDTH - 1 : 0] ROM_Address;
    reg [COUNTER_DATAWIDTH - 1 : 0] Address_Counter;
    reg flag; // to delay one clock of the first loop
    
    // Wire
    wire [NUMBER_DATAWIDTH - 1 : 0] Rom_out;
    
    // Load Weight Data
    Weight_Rom_2
    Weight_Rom_2(
    .clka(clk),
    .addra(ROM_Address),
    .douta(Rom_out)
    );
    
    // flag
    always @(posedge clk, negedge reset) begin
        if(!reset) begin
            flag <= 0;
        end else begin
            if(enable) begin
                flag <= 1;
            end else begin
                flag <= flag;
            end 
        end 
    end 
    
    // ROM_Address & flag
    always @(posedge clk, negedge reset) begin
        if (!reset) begin
            ROM_Address <= 0;
        end else begin
            if (enable) begin
                if ( (ROM_Address % (KERNEL_SIZE * KERNEL_SIZE) ) == (KERNEL_SIZE * KERNEL_SIZE - 1) ) begin
                    if (change) begin
                        ROM_Address <= ROM_Address + 1;
                    end else begin
                        ROM_Address <= ROM_Address;
                    end
                end else begin
                    if(flag) begin
                        ROM_Address <= ROM_Address + 1;
                    end else begin
                        ROM_Address <= ROM_Address;
                    end
                end 
            end else begin
                ROM_Address <= ROM_Address;
            end
        end 
    end 
    
    // Address_Counter
    always @ (posedge clk) begin
        Address_Counter <= ROM_Address % (KERNEL_SIZE * KERNEL_SIZE);
    end 
    
    // Weight Value
    always @ (*) begin
        case (Address_Counter)
            4'd1: weight1 = Rom_out;
            4'd2: weight2 = Rom_out;
            4'd3: weight3 = Rom_out;
            4'd4: weight4 = Rom_out;
            4'd5: weight5 = Rom_out;
            4'd6: weight6 = Rom_out;
            4'd7: weight7 = Rom_out;
            4'd8: weight8 = Rom_out;
            default: begin // 4'd0
                            weight0 = Rom_out;
                         end
        endcase
    end
    
    always @(*) begin
        if(!reset) begin
            weight_OK  = 0;
        end else begin
            if(enable) begin
                if( Address_Counter == (KERNEL_SIZE * KERNEL_SIZE - 1) )
                    if(change || ( (ROM_Address % KERNEL_SIZE * KERNEL_SIZE) == 0) ) begin
                        weight_OK  = 0;
                    end else begin
                        weight_OK  = 1;
                    end 
                else
                    weight_OK  = 0;
            end else begin
                weight_OK  = 0;
            end 
        end
    end 
    
endmodule

module Weight_Buffer_2(
    weight0, weight1, weight2, weight3, weight4, weight5, weight6, weight7, weight8,
    clk, reset, //clk is normal clock
    enable, 
    change, // change to another channel,
    weight_OK
    );
    
    parameter KERNEL_SIZE = 3;
    parameter ROM_ADDRESS_DATAWIDTH = 12;
    parameter COUNTER_DATAWIDTH = 4;
    parameter NUMBER_DATAWIDTH = 16;
    
    //input
    input clk, reset;
    input enable,change;
    
    // output
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight0;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight1;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight2;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight3;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight4;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight5;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight6;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight7;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight8;
    output reg weight_OK;
    
    // Registers
    reg [ROM_ADDRESS_DATAWIDTH - 1 : 0] ROM_Address;
    reg [COUNTER_DATAWIDTH - 1 : 0] Address_Counter;
    reg flag; // to delay one clock of the first loop
    
    // Wire
    wire [NUMBER_DATAWIDTH - 1 : 0] Rom_out;
    
    // Load Weight Data
    Weight_Rom_3
    Weight_Rom_3(
    .clka(clk),
    .addra(ROM_Address),
    .douta(Rom_out)
    );
    
    // flag
    always @(posedge clk, negedge reset) begin
        if(!reset) begin
            flag <= 0;
        end else begin
            if(enable) begin
                flag <= 1;
            end else begin
                flag <= flag;
            end 
        end 
    end 
    
    // ROM_Address & flag
    always @(posedge clk, negedge reset) begin
        if (!reset) begin
            ROM_Address <= 0;
        end else begin
            if (enable) begin
                if ( (ROM_Address % (KERNEL_SIZE * KERNEL_SIZE) ) == (KERNEL_SIZE * KERNEL_SIZE - 1) ) begin
                    if (change) begin
                        ROM_Address <= ROM_Address + 1;
                    end else begin
                        ROM_Address <= ROM_Address;
                    end
                end else begin
                    if(flag) begin
                        ROM_Address <= ROM_Address + 1;
                    end else begin
                        ROM_Address <= ROM_Address;
                    end
                end 
            end else begin
                ROM_Address <= ROM_Address;
            end
        end 
    end 
    
    // Address_Counter
    always @ (posedge clk) begin
        Address_Counter <= ROM_Address % (KERNEL_SIZE * KERNEL_SIZE);
    end 
    
    // Weight Value
    always @ (*) begin
        case (Address_Counter)
            4'd1: weight1 = Rom_out;
            4'd2: weight2 = Rom_out;
            4'd3: weight3 = Rom_out;
            4'd4: weight4 = Rom_out;
            4'd5: weight5 = Rom_out;
            4'd6: weight6 = Rom_out;
            4'd7: weight7 = Rom_out;
            4'd8: weight8 = Rom_out;
            default: begin // 4'd0
                            weight0 = Rom_out;
                         end
        endcase
    end
    
    always @(*) begin
        if(!reset) begin
            weight_OK  = 0;
        end else begin
            if(enable) begin
                if( Address_Counter == (KERNEL_SIZE * KERNEL_SIZE - 1) )
                    if(change || ( (ROM_Address % KERNEL_SIZE * KERNEL_SIZE) == 0) ) begin
                        weight_OK  = 0;
                    end else begin
                        weight_OK  = 1;
                    end 
                else
                    weight_OK  = 0;
            end else begin
                weight_OK  = 0;
            end 
        end
    end 
    
endmodule

module Weight_Buffer_3(
    weight0, weight1, weight2, weight3, weight4, weight5, weight6, weight7, weight8,
    clk, reset, //clk is normal clock
    enable, 
    change, // change to another channel,
    weight_OK
    );
    
    parameter KERNEL_SIZE = 3;
    parameter ROM_ADDRESS_DATAWIDTH = 12;
    parameter COUNTER_DATAWIDTH = 4;
    parameter NUMBER_DATAWIDTH = 16;
    
    //input
    input clk, reset;
    input enable,change;
    
    // output
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight0;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight1;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight2;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight3;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight4;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight5;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight6;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight7;
    output reg [NUMBER_DATAWIDTH - 1 : 0] weight8;
    output reg weight_OK;
    
    // Registers
    reg [ROM_ADDRESS_DATAWIDTH - 1 : 0] ROM_Address;
    reg [COUNTER_DATAWIDTH - 1 : 0] Address_Counter;
    reg flag; // to delay one clock of the first loop
    
    // Wire
    wire [NUMBER_DATAWIDTH - 1 : 0] Rom_out;
    
    // Load Weight Data
    Weight_Rom_4
    Weight_Rom_4(
    .clka(clk),
    .addra(ROM_Address),
    .douta(Rom_out)
    );
    
    // flag
    always @(posedge clk, negedge reset) begin
        if(!reset) begin
            flag <= 0;
        end else begin
            if(enable) begin
                flag <= 1;
            end else begin
                flag <= flag;
            end 
        end 
    end 
    
    // ROM_Address & flag
    always @(posedge clk, negedge reset) begin
        if (!reset) begin
            ROM_Address <= 0;
        end else begin
            if (enable) begin
                if ( (ROM_Address % (KERNEL_SIZE * KERNEL_SIZE) ) == (KERNEL_SIZE * KERNEL_SIZE - 1) ) begin
                    if (change) begin
                        ROM_Address <= ROM_Address + 1;
                    end else begin
                        ROM_Address <= ROM_Address;
                    end
                end else begin
                    if(flag) begin
                        ROM_Address <= ROM_Address + 1;
                    end else begin
                        ROM_Address <= ROM_Address;
                    end
                end 
            end else begin
                ROM_Address <= ROM_Address;
            end
        end 
    end 
    
    // Address_Counter
    always @ (posedge clk) begin
        Address_Counter <= ROM_Address % (KERNEL_SIZE * KERNEL_SIZE);
    end 
    
    // Weight Value
    always @ (*) begin
        case (Address_Counter)
            4'd1: weight1 = Rom_out;
            4'd2: weight2 = Rom_out;
            4'd3: weight3 = Rom_out;
            4'd4: weight4 = Rom_out;
            4'd5: weight5 = Rom_out;
            4'd6: weight6 = Rom_out;
            4'd7: weight7 = Rom_out;
            4'd8: weight8 = Rom_out;
            default: begin // 4'd0
                            weight0 = Rom_out;
                         end
        endcase
    end
    
    always @(*) begin
        if(!reset) begin
            weight_OK  = 0;
        end else begin
            if(enable) begin
                if( Address_Counter == (KERNEL_SIZE * KERNEL_SIZE - 1) )
                    if(change || ( (ROM_Address % KERNEL_SIZE * KERNEL_SIZE) == 0) ) begin
                        weight_OK  = 0;
                    end else begin
                        weight_OK  = 1;
                    end 
                else
                    weight_OK  = 0;
            end else begin
                weight_OK  = 0;
            end 
        end
    end 
    
endmodule
