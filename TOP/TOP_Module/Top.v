`timescale 1ns / 1ps

module Top(
    state,
    judge_result, // to control LED
    PS_data_start,
    clk_fast, clk_slow,
    reset,
    PS_BRAM_busy, // 1 for still passing 0 for passing done
//    PS_BRAM_waddr, 
//    PS_BRAM_raddr, 
    PS_BRAM_rdata,
    Conv1_1_Address 
    );
    
    // -------------------------------------------------------------Parameters--------------------------------------------------------------
//    parameter PS_BRAM_NUMBER = 3;
    parameter PL_BRAM_BIG_NUMBER = 6;
    parameter PL_BRAM_SMALL_NUMBER = 16;
    parameter ADDR_DATAWIDTH = 13;
    parameter PS_BRAM_DATAWIDTH = 64;
    parameter DATAWIDTH = 16;
    parameter SA_UNITS = 4;
    parameter STATE_DATAWIDTH = 4;
    parameter LOOP_DATAWIDTH = 3, FILTER_DATAWIDTH = 5;
    parameter LATENCY = 34;
    parameter OUT_LATENCY = 4;
    
    // Convolution Parameters
    parameter KERNEL_SIZE = 3;      // Kernel size (KERNEL_SIZE x KERNEL_SIZE)
    
    // Avg Pool Parameters
    parameter input_map_address_datawidth = 13;
    parameter output_map_address_datawidth = 11;
    parameter middle_data_index_datawidth = 6;
    parameter input_datawidth = 7;
    parameter AVG1_INPUT_SIZE = 80;
    parameter AVG2_INPUT_SIZE = 36;
    parameter AVG3_INPUT_SIZE = 14;
    parameter AVG1_OUTPUT_SIZE = 40;
    parameter AVG2_OUTPUT_SIZE = 18;
    parameter AVG3_OUTPUT_SIZE = 7;
    parameter AVG_LOOP_DATAWIDTH = 3;
    parameter COMPUTING_CORES = 4;
    
    // Fully Connect Parameters
    parameter FC_INPUT_NODES = 784;
    parameter FC_OUTPUT_NODES = 2;
    parameter FC_MULT_ADD_UNITS = 16;
    
    // Final Judge Parameters
//    parameter THRESHOLD = 16'h55a0; //90 in float 16
    parameter PICTURES = 35;
    
    // State Parameters
    parameter RESET = 0, IDLE = 1;
    parameter CONV1_1_STATE = 2, CONV1_2_STATE = 3, AVG_POOL1 = 4;
    parameter CONV2_1_STATE = 5, CONV2_2_STATE = 6, AVG_POOL2 = 7;
    parameter CONV3_1_STATE = 8, CONV3_2_STATE = 9, AVG_POOL3 = 10;
    parameter FC_STATE = 11;
    parameter JUDGE = 12;
    
    // -------------------------------------------------------------------I/O-------------------------------------------------------------------
    // input
    input clk_fast, clk_slow;
    input reset;
    input PS_BRAM_busy;
//    input [PS_BRAM_ADDR_DATAWIDTH - 1 : 0] PS_BRAM_waddr;
//    input [ADDR_DATAWIDTH - 1 : 0] PS_BRAM_raddr;
    input [PS_BRAM_DATAWIDTH - 1 : 0] PS_BRAM_rdata;
    input [ADDR_DATAWIDTH - 1 : 0] Conv1_1_Address;
    
    // output
    output judge_result; // for one 80x80 photo
    output PS_data_start;
    output [STATE_DATAWIDTH - 1 : 0] state;
//    output reg [STATE_DATAWIDTH - 1 : 0] state;
     
    // Separate PS_BRAM_data to R, G, B
//    wire [DATAWIDTH - 1 : 0] PS_BRAM_data_R, PS_BRAM_data_G, PS_BRAM_data_B;
//    assign PS_BRAM_data_R = PS_BRAM_rdata[DATAWIDTH * 2 + (DATAWIDTH - 1) : DATAWIDTH * 2];
//    assign PS_BRAM_data_G = PS_BRAM_rdata[DATAWIDTH * 1 + (DATAWIDTH - 1) : DATAWIDTH * 1];
//    assign PS_BRAM_data_B = PS_BRAM_rdata[DATAWIDTH * 0 + (DATAWIDTH - 1) : DATAWIDTH * 0];
    
    // ---------------------------------------------------------wires & registers-------------------------------------------------------------------
    
    // clock switch
    wire clk_compound;
    
    // -------BRAM--------
        // BRAM input data
        reg [PL_BRAM_BIG_NUMBER * DATAWIDTH - 1 + DATAWIDTH : 0] In_big_1;
        reg [PL_BRAM_BIG_NUMBER * DATAWIDTH - 1 + DATAWIDTH : 0] In_big_2;
        reg [PL_BRAM_SMALL_NUMBER * DATAWIDTH - 1 + DATAWIDTH : 0] In_small_1;
        reg [PL_BRAM_SMALL_NUMBER * DATAWIDTH - 1 + DATAWIDTH : 0] In_small_2;
        
        // BRAM output data
        wire [PL_BRAM_BIG_NUMBER * DATAWIDTH  - 1+ DATAWIDTH: 0] Out_big_1;
        wire [PL_BRAM_BIG_NUMBER * DATAWIDTH - 1 + DATAWIDTH: 0] Out_big_2;
        wire [PL_BRAM_SMALL_NUMBER * DATAWIDTH - 1 + DATAWIDTH : 0] Out_small_1;
        wire [PL_BRAM_SMALL_NUMBER * DATAWIDTH - 1 + DATAWIDTH : 0] Out_small_2;
        
        // BRAM write enable
        reg [PL_BRAM_SMALL_NUMBER :0] BRAM_wr_ena;
        
        // BRAM input address
        reg [ADDR_DATAWIDTH - 1 : 0] In_big_1_addr;
        reg [ADDR_DATAWIDTH - 1 : 0] In_big_2_addr;
        reg [ADDR_DATAWIDTH - 1 : 0] In_small_1_addr;
        reg [ADDR_DATAWIDTH - 1 : 0] In_small_2_addr;
        
        // BRAM address
//        reg [ADDR_DATAWIDTH - 1 : 0] BRAM_In_Address;
        reg [ADDR_DATAWIDTH - 1 : 0] BRAM_Out_Address;
        
        // BRAM_Control(Address)
        wire [PL_BRAM_BIG_NUMBER * 2 - 1 : 0] ENA;
        wire [PL_BRAM_BIG_NUMBER * 2 - 1 : 0] ENB;
        wire [PL_BRAM_SMALL_NUMBER * 2 - 1 : 0] ena;
        wire [PL_BRAM_SMALL_NUMBER * 2 - 1 : 0] enb;
        
        wire [PL_BRAM_BIG_NUMBER * 2 : 0] BRAM_Big_Write_Enable;
        wire [PL_BRAM_BIG_NUMBER * 2 : 0] BRAM_Big_Read_Enable;
        wire [PL_BRAM_SMALL_NUMBER * 2 : 0] BRAM_Small_Write_Enable;
        wire [PL_BRAM_SMALL_NUMBER * 2 : 0] BRAM_Small_Read_Enable;
            assign BRAM_Big_Write_Enable = {ENA, 1'b0};
            assign BRAM_Big_Read_Enable = {ENB, 1'b0};
            assign BRAM_Small_Write_Enable = {ena, 1'b0};
            assign BRAM_Small_Read_Enable = {enb, 1'b0};
            
        wire [ADDR_DATAWIDTH - 1 : 0] BRAM_Control_In_Address;
        wire [ADDR_DATAWIDTH - 1 : 0] BRAM_Control_Out_Address;
        wire [ADDR_DATAWIDTH - 1 : 0] BRAM_Control_Out_temp_Address;
    
    // Convolution
    wire Conv_done, calculate;
    wire [DATAWIDTH - 1 : 0] conv_out;
    wire [LOOP_DATAWIDTH - 1 : 0] current_loop;
    wire [FILTER_DATAWIDTH - 1 : 0] current_filter;
    reg [DATAWIDTH * SA_UNITS - 1 : 0]Conv_din;
    reg [DATAWIDTH - 1 : 0]output_temp;
    
    // Average Pooling
    wire Avg_done;
    reg [COMPUTING_CORES * DATAWIDTH - 1:0] BRAM_Pool_In1; // Data from input BRAM
    wire [COMPUTING_CORES - 1:0] Avg_wr_ena;
    wire [AVG_LOOP_DATAWIDTH - 1 : 0] avg_loop; // to record the present loop value
    wire [COMPUTING_CORES * input_map_address_datawidth - 1:0] BRAM_Pool_In1_Address;
    wire [COMPUTING_CORES * DATAWIDTH - 1:0] BRAM_Pool_Out1; //to save data in output BRAM
    wire [COMPUTING_CORES * output_map_address_datawidth - 1:0] BRAM_Pool_Out1_Address;
    
    // Fully Connect
    wire FC_done; 
    wire [DATAWIDTH*FC_OUTPUT_NODES-1:0] FC_dout;
    reg [DATAWIDTH*FC_OUTPUT_NODES-1:0] FC_dout_store;
    
    // Final Judge
//    wire LED_Judge;
    wire Judge_done, Judge_all_done;
    
    // ---------------------------------------------------------Compound Clock-------------------------------------------------------------------
    clock_switch#(
    .STATE_DATAWIDTH(STATE_DATAWIDTH),
    .CONV1_1_STATE(CONV1_1_STATE), .CONV1_2_STATE(CONV1_2_STATE),
    .CONV2_1_STATE(CONV2_1_STATE), .CONV2_2_STATE(CONV2_2_STATE),
    .CONV3_1_STATE(CONV3_1_STATE), .CONV3_2_STATE(CONV3_2_STATE)
    )clock_switch0(
    .clk3(clk_fast), .clk1(clk_slow),
    .rst(reset),
    .State(state),
    .clk_out(clk_compound)
    );
    
    
    // ---------------------------------------------------------------BRAM-------------------------------------------------------------------
    
//    wire [271:0] store_data;
//    reg [12:0] test_addr;
//    always @(posedge clk_slow, negedge reset) begin
//        if(!reset) begin
//            test_addr <= -1;
//        end else begin
//            if(state == FC_STATE) begin
//                test_addr <= test_addr + 1;
//            end else begin
//                test_addr <= test_addr;
//            end 
//        end 
//    end 
    
//    reg test_enable_2;
//    always @(*) begin
//        if( (state == CONV3_1_STATE) || (state == FC_STATE) ) begin
//            test_enable_2 = 1;
//        end else begin
//            test_enable_2 = 0;
//        end 
//    end
    
//    reg [16:0] pool_enable;
//    always @(*) begin
//        if(state == AVG_POOL1) begin
//            if(avg_loop == 0) begin
//                pool_enable = 17'b0000_0000_0000_1111_1;
//            end else begin
//                pool_enable = 17'b0000_0000_0011_0000_1;
//            end 
//        end else if( (state == AVG_POOL2) || (state == AVG_POOL3) ) begin
//            if(avg_loop == 0) begin
//                pool_enable = 17'b0000_0000_0000_1111_1;
//            end else if(avg_loop == 1) begin
//                pool_enable = 17'b0000_0000_1111_0000_1;
//            end else if(avg_loop == 2) begin
//                pool_enable = 17'b0000_1111_0000_0000_1;
//            end else begin
//                pool_enable = 17'b1111_0000_0000_0000_1;
//            end
//        end else if(state == CONV2_1_STATE) begin
//            pool_enable = 17'b0000_0000_0011_1111_1;
//        end else if(state == CONV3_1_STATE) begin
//            pool_enable = 17'b1111_1111_1111_1111_1;
//        end  else begin
//            pool_enable = 0;
//        end 
//    end 
    
    // BRAM_Big 1 to 6
    genvar big_index_1;
    generate
        for(big_index_1 = 1; big_index_1 < PL_BRAM_BIG_NUMBER + 1; big_index_1 = big_index_1 + 1) begin
            BRAM_Big
            ubb_first_0(
            .clka(clk_slow),
            .ena(/*pool_enable*/BRAM_Big_Write_Enable[big_index_1]),
            .wea(BRAM_wr_ena[big_index_1]),
            .addra(BRAM_Out_Address),
            .dina(In_big_1[DATAWIDTH * big_index_1 + (DATAWIDTH - 1) : DATAWIDTH * big_index_1]),
            .douta(), // not valid
            .clkb(clk_compound),
            .enb(/*pool_enable*/BRAM_Big_Read_Enable[big_index_1]),
            .web(0), // I'm not sure if it's ok to feed 0 directly
            .addrb(/*test_addr*/In_big_1_addr),
            .dinb(), // not valid
            .doutb(Out_big_1[DATAWIDTH * big_index_1 + (DATAWIDTH - 1) : DATAWIDTH * big_index_1]/*store_data[DATAWIDTH * big_index_1 + (DATAWIDTH - 1) : DATAWIDTH * big_index_1]*/)
            );
        end 
    endgenerate
    
    // test enable
//    reg [16:0] test_enable;
//    always @(*) begin
//        if( (state == AVG_POOL2) || (state == AVG_POOL3) ) begin
//            case(avg_loop)
//                5'd0: test_enable = 17'b0000_0000_0000_1111_0;
//                5'd1: test_enable = 17'b0000_0000_1111_0000_0;
//                5'd2: test_enable = 17'b0000_1111_0000_0000_0;
//                5'd3, 5'd4: test_enable = 17'b1111_0000_0000_0000_0;
//                default: test_enable = 0;
//            endcase
//        end else begin
//            test_enable = 0;
//        end 
//    end
    
    
    
    // BRAM_Big 7 to 12
    genvar big_index_2;
    generate
        for(big_index_2 = 1; big_index_2 < PL_BRAM_BIG_NUMBER + 1; big_index_2 = big_index_2 + 1) begin
            BRAM_Big
            ubb_second_0(
            .clka(clk_slow),
            .ena(BRAM_Big_Write_Enable[big_index_2 + PL_BRAM_BIG_NUMBER]),
            .wea(BRAM_wr_ena[big_index_2]),
            .addra(BRAM_Out_Address),
            .dina(In_big_2[DATAWIDTH * big_index_2 + (DATAWIDTH - 1) : DATAWIDTH * big_index_2]),
            .douta(), // not valid
            .clkb(clk_compound),
            .enb(/*test_enable*/BRAM_Big_Read_Enable[big_index_2 + PL_BRAM_BIG_NUMBER]),
            .web(0), // I'm not sure if it's ok to feed 0 directly
            .addrb(/*test_addr*/In_big_2_addr),
            .dinb(), // not valid
            .doutb(/*test_data*/Out_big_2[DATAWIDTH * big_index_2 + (DATAWIDTH - 1) : DATAWIDTH * big_index_2])
            );
        end 
    endgenerate 
    
    // BRAM_small 1 to 16
    genvar small_index_1;
    generate
        for(small_index_1 = 1; small_index_1 < PL_BRAM_SMALL_NUMBER + 1; small_index_1 = small_index_1 + 1) begin
            BRAM_small
            ubs0(
            .clka(clk_slow),
            .ena(/*pool_enable*/BRAM_Small_Write_Enable[small_index_1]),
            .wea(BRAM_wr_ena[small_index_1]),
            .addra(BRAM_Out_Address),
            .dina(In_small_1[DATAWIDTH * small_index_1 + (DATAWIDTH - 1) : DATAWIDTH * small_index_1]),
            .douta(), // not valid
            .clkb(clk_compound),
            .enb(/*test_enable[small_index_1]*/BRAM_Small_Read_Enable[small_index_1]),
            .web(0), // I'm not sure if it's ok to feed 0 directly
            .addrb(In_small_1_addr),
            .dinb(), // not valid
            .doutb(Out_small_1[DATAWIDTH * small_index_1 + (DATAWIDTH - 1) : DATAWIDTH * small_index_1]/*store_data[DATAWIDTH * small_index_1 + (DATAWIDTH - 1) : DATAWIDTH * small_index_1]*/)
            );
        end 
    endgenerate
    
    // BRAM_small 17 to 32
    genvar small_index_2;
    generate
        for(small_index_2 = 1; small_index_2 < PL_BRAM_SMALL_NUMBER + 1; small_index_2 = small_index_2 + 1) begin
            BRAM_small
            ubs0(
            .clka(clk_slow),
            .ena(/*pool_enable*/BRAM_Small_Write_Enable[small_index_2 + PL_BRAM_SMALL_NUMBER]),
            .wea(BRAM_wr_ena[small_index_2]),
            .addra(BRAM_Out_Address),
            .dina(In_small_2[DATAWIDTH * small_index_2 + (DATAWIDTH - 1) : DATAWIDTH * small_index_2]),
            .douta(/*store_data[DATAWIDTH * small_index_2 + (DATAWIDTH - 1) : DATAWIDTH * small_index_2]*/), // not valid
            .clkb(clk_compound),
            .enb(/*test_enable_2*/BRAM_Small_Read_Enable[small_index_2 + PL_BRAM_SMALL_NUMBER]),
            .web(0), // I'm not sure if it's ok to feed 0 directly
            .addrb(/*test_addr*/In_small_2_addr),
            .dinb(), // not valid
            .doutb(Out_small_2[DATAWIDTH * small_index_2 + (DATAWIDTH - 1) : DATAWIDTH * small_index_2]/*store_data[DATAWIDTH * small_index_2 + (DATAWIDTH - 1) : DATAWIDTH * small_index_2]*/)
            );
        end 
    endgenerate
    
    // BRAM_Ctrl
    BRAM_Ctrl#(
    .BIGs(PL_BRAM_BIG_NUMBER * 2),
    .SMALLs(PL_BRAM_SMALL_NUMBER * 2),
    .SA_Units(SA_UNITS),
    .Pool_Units(COMPUTING_CORES),
    
    .RESET(RESET), .IDLE(IDLE),
    .CONV1_1_STATE(CONV1_1_STATE), .CONV1_2_STATE(CONV1_2_STATE), .AVG_POOL1(AVG_POOL1),
    .CONV2_1_STATE(CONV2_1_STATE), .CONV2_2_STATE(CONV2_2_STATE), .AVG_POOL2(AVG_POOL2),
    .CONV3_1_STATE(CONV3_1_STATE), .CONV3_2_STATE(CONV3_1_STATE), .AVG_POOL3(AVG_POOL3),
    .FC_STATE(FC_STATE),
    .JUDGE(JUDGE),
    
    .KERNEL_SIZE(KERNEL_SIZE),
    .latency(LATENCY),
    .out_latency(OUT_LATENCY)
    )bram_ctrl0(
    .clk(clk_compound), .rst(reset),
    .calculate(calculate),                //Conv的calculate
    .state(state),              //當前state  (idle, Conv1_1......)
    .current_loop(current_loop),       //Convolution的current loop
    .current_filter(current_filter),     //Convolution的current filter
    .Pool_loop(avg_loop),          //Pool在第幾個loop
    .ENA(ENA),          //大BRAM的A port enable (寫)   (BIGs是parameter = 12)
    .ENB(ENB),          //大BRAM的B port enable (讀)
    .ena(ena),        //小BRAM的A port enable (寫)   (SMALLs是parameter = 32)
    .enb(enb),       //小BRAM的B port enable (讀)
    .input_addr(BRAM_Control_In_Address),       //讀取input data用的address
    .out_temp_addr(BRAM_Control_Out_temp_Address),    //讀取output temp data用的address
    .output_addr(BRAM_Control_Out_Address)      //寫入output data用的address
//    .Conv_last_data()
    );
    
    // BRAM_Big 1 to 6 Input Selection
    always @(*) begin
        if(!reset) begin
            In_big_1 = 0;
        end else begin
            case(state) 
                CONV1_1_STATE: 
                    begin
                        In_big_1[(DATAWIDTH - 1) : 0] = 0;
                        In_big_1[PL_BRAM_BIG_NUMBER * DATAWIDTH - 1 + DATAWIDTH : DATAWIDTH] = {(PL_BRAM_BIG_NUMBER){conv_out}};
                    end 
                AVG_POOL1:// In_big_1 = {BRAM_Pool_Out1[2 * DATAWIDTH - 1 : 0], BRAM_Pool_Out1, 4'b0000};
                    begin
                        In_big_1[(DATAWIDTH - 1) : 0] = 0;
                        In_big_1[DATAWIDTH + (COMPUTING_CORES * DATAWIDTH - 1) : DATAWIDTH] = BRAM_Pool_Out1;
                        In_big_1[DATAWIDTH * 5 + (2 * DATAWIDTH - 1) : DATAWIDTH * 5] = BRAM_Pool_Out1[2 * DATAWIDTH - 1 : 0];
                    end
                default: In_big_1 = 0;
            endcase
        end 
    end 
    
    // BRAM_Big 7 to 12 Input Selection
    always @(*) begin
        if(!reset) begin
            In_big_2 = 0;
        end else begin
            case(state) 
                CONV1_2_STATE: 
                    begin
                        In_big_2[(DATAWIDTH - 1) : 0] = 0;
                        In_big_2[PL_BRAM_BIG_NUMBER * DATAWIDTH - 1 + DATAWIDTH : DATAWIDTH] = {(PL_BRAM_BIG_NUMBER){conv_out}};
                    end 
                default: In_big_2 = 0;
            endcase
        end 
    end
    
    // BRAM_small 1 to 16 Input Selection
    always @(*) begin
        if(!reset) begin
            In_small_1 = 0;
        end else begin
            case(state) 
                CONV2_1_STATE, CONV3_2_STATE: 
                    begin
                        In_small_1[(DATAWIDTH - 1) : 0] = 0;
                        In_small_1[PL_BRAM_SMALL_NUMBER * DATAWIDTH - 1 + DATAWIDTH  : DATAWIDTH] = {PL_BRAM_SMALL_NUMBER{conv_out}};
                    end
                AVG_POOL2: 
                    begin
                        In_small_1[(DATAWIDTH - 1) : 0] = 0;
                        In_small_1[PL_BRAM_SMALL_NUMBER * DATAWIDTH - 1 + DATAWIDTH  : DATAWIDTH] = {4{BRAM_Pool_Out1}};
                    end 
                default: In_small_1 = 0;
            endcase
        end 
    end
    
    // BRAM_small 17 to 32 Input Selection
    always @(*) begin
        if(!reset) begin
            In_small_2 = 0;
        end else begin
            case(state) 
                CONV2_2_STATE, CONV3_1_STATE: 
                    begin
                        In_small_2[(DATAWIDTH - 1) : 0] = 0;
                        In_small_2[PL_BRAM_SMALL_NUMBER * DATAWIDTH - 1 + DATAWIDTH  : DATAWIDTH] = {PL_BRAM_SMALL_NUMBER{conv_out}};
                    end 
                AVG_POOL3: 
                    begin
                        In_small_2[(DATAWIDTH - 1) : 0] = 0;
                        In_small_2[PL_BRAM_SMALL_NUMBER * DATAWIDTH - 1 + DATAWIDTH  : DATAWIDTH] = {4{BRAM_Pool_Out1}};
                    end 
                default: In_small_2 = 0;
            endcase
        end 
    end
    
    // In_big_1_addr
    always @(*) begin
        if( (state == CONV1_2_STATE) || (state == CONV2_1_STATE) ) begin
            In_big_1_addr = BRAM_Control_In_Address;
        end else begin
            In_big_1_addr = 7878; 
        end 
    end 
    
    // In_big_2_addr
    always @(*) begin
        if(state == AVG_POOL1) begin
            In_big_2_addr = BRAM_Pool_In1_Address; 
        end else begin
            In_big_2_addr = 7878;
        end 
    end
    
    // In_small_1_addr
    always @(*) begin
        if( (state == CONV2_2_STATE) || (state == CONV3_1_STATE) ) begin
            In_small_1_addr = BRAM_Control_In_Address;
        end else if(state == AVG_POOL3) begin
            In_small_1_addr = BRAM_Pool_In1_Address; 
        end else begin
            In_small_1_addr = 0;
        end 
    end
    
    // In_small_2_addr
    always @(*) begin
        if(state == CONV3_2_STATE) begin
            In_small_2_addr = BRAM_Control_In_Address;
        end else if(state == AVG_POOL2) begin
            In_small_2_addr = BRAM_Pool_In1_Address; 
        end else if(state == FC_STATE) begin
            In_small_2_addr = BRAM_Control_In_Address;
        end else begin
            In_small_2_addr = 0;
        end 
    end
    
    // BRAM Output Address
    always @(*) begin
        if(!reset) begin
            BRAM_Out_Address = BRAM_Control_Out_Address;
        end else begin
            if( (state == AVG_POOL1) || (state == AVG_POOL2) || (state == AVG_POOL3) ) begin
                BRAM_Out_Address = BRAM_Pool_Out1_Address[output_map_address_datawidth - 1:0];
            end else if(state == CONV1_1_STATE) begin
                BRAM_Out_Address = Conv1_1_Address;
            end else begin
                BRAM_Out_Address = BRAM_Control_Out_Address;
            end 
        end 
    end
    
    // BRAM write_enable
    always @(*) begin
        if( (state == AVG_POOL1) || (state == AVG_POOL2) || (state == AVG_POOL3) ) begin
//            BRAM_wr_ena[COMPUTING_CORES - 1 : 0] = Avg_wr_ena;
//            BRAM_wr_ena[COMPUTING_CORES * 2 - 1 : COMPUTING_CORES] = Avg_wr_ena;
//            BRAM_wr_ena[COMPUTING_CORES * 3 - 1 : COMPUTING_CORES * 2] = Avg_wr_ena;
//            BRAM_wr_ena[COMPUTING_CORES * 4 - 1 : COMPUTING_CORES * 3] = Avg_wr_ena;
            BRAM_wr_ena = {{4{Avg_wr_ena}}, 1'b0};
        end else begin
            BRAM_wr_ena = 17'b1111_1111_1111_1111_0;
        end  
    end 
    
    // BRAM_Address & Enable Control
    
    
    //--------------------------------------------------------------Master_FSM-------------------------------------------------------------------
    Master_FSM #(
        .STATE_DATAWIDTH(STATE_DATAWIDTH),
        .ADDRESS_DATAWIDTH(ADDR_DATAWIDTH),
        .RESET(RESET),
        .IDLE(IDLE),
        .CONV1_1_STATE(CONV1_1_STATE), .CONV1_2_STATE(CONV1_2_STATE),
        .CONV2_1_STATE(CONV2_1_STATE), .CONV2_2_STATE(CONV2_2_STATE),
        .CONV3_1_STATE(CONV3_1_STATE), .CONV3_2_STATE(CONV3_2_STATE),
        .AVG_POOL1(AVG_POOL1), .AVG_POOL2(AVG_POOL2), .AVG_POOL3(AVG_POOL3),
        .FC_STATE(FC_STATE), .JUDGE(JUDGE)
    )mf0(
    .state(state),
    .clk(clk_slow), 
    .reset(reset),
    .Conv_done(Conv_done), 
    .Avg_done(Avg_done), 
    .FC_done(FC_done), 
    .Judge_done(Judge_done), 
    .Judge_all_done(Judge_all_done),
    .PS_BRAM_busy(PS_BRAM_busy)
    );
    
    
//    always @(posedge clk_slow, negedge reset) begin
//        if(!reset) begin
//            state <= 9;
//        end else begin
//            if(Avg_done) begin
//                state <= state + 1;
//            end else if(state == 9) begin
//                state <= state + 1;
//            end else begin
//                state <= state;
//            end
//        end 
//    end
    
    //--------------------------------------------------------------Convolution-------------------------------------------------------------------
    Conv #(
    .KERNEL_SIZE(KERNEL_SIZE),      // Kernel size (KERNEL_SIZE x KERNEL_SIZE)
    .SA_UNITS(SA_UNITS),   // Stride for sliding window
    .DATA_WIDTH(DATAWIDTH),        // Data width for input, output, and weight
	.STATE_DATAWIDTH(STATE_DATAWIDTH),
	.ADDRESS_DATAWIDTH(ADDR_DATAWIDTH),
    .LOOP_DATAWIDTH(LOOP_DATAWIDTH),
	.FILTER_DATAWIDTH(FILTER_DATAWIDTH)
    )conv0(
	.real_output(conv_out),
	.current_loop(current_loop), // to record the present loop value
    .current_filter(current_filter),
    .done(Conv_done),
    .start(PS_data_start),
    .calculate(calculate),
	.input_data(Conv_din),
	.output_temp(output_temp),
    .state(state),
    .Out_Address(BRAM_Control_Out_Address),
	.clk(clk_slow), 
	.reset(reset),
	.clk_3(clk_fast)
    );
    
    // Conv_din
    always @(posedge clk_fast, negedge reset) begin
        if(!reset) begin
            Conv_din <= 0;
        end else begin
            if(state == CONV1_1_STATE) begin
                Conv_din <= PS_BRAM_rdata;
            end else begin
                if( (BRAM_Control_In_Address == 13'd7878) || (BRAM_Control_Out_temp_Address == 13'd7878) ) begin
                    Conv_din <= 0;
                end else begin
                    case(state)
                        CONV1_2_STATE, CONV2_1_STATE: 
                            begin
                                case(current_loop)
                                    3'd0: Conv_din <= Out_big_1[SA_UNITS * DATAWIDTH - 1 + DATAWIDTH: 0 + DATAWIDTH];
                                    default://3'd1
                                        begin
                                            Conv_din[2 * DATAWIDTH - 1 : 0] <= Out_big_1[SA_UNITS * DATAWIDTH + (2 * DATAWIDTH - 1) + DATAWIDTH : SA_UNITS * DATAWIDTH + DATAWIDTH];
                                            Conv_din[2 * DATAWIDTH + (2 * DATAWIDTH - 1) : 2 * DATAWIDTH] <= 32'd0;
                                        end 
                                endcase
                            end
                        CONV2_2_STATE, CONV3_1_STATE:
                            begin
                                case(current_loop)
                                    3'd0: Conv_din <= Out_small_1[SA_UNITS * DATAWIDTH - 1 + DATAWIDTH: 0 + DATAWIDTH];
                                    3'd1: Conv_din <= Out_small_1[SA_UNITS * DATAWIDTH + (SA_UNITS * DATAWIDTH - 1) + DATAWIDTH : SA_UNITS * DATAWIDTH + DATAWIDTH];
                                    3'd2: Conv_din <= Out_small_1[SA_UNITS * DATAWIDTH * 2 + (SA_UNITS * DATAWIDTH - 1) + DATAWIDTH : SA_UNITS * DATAWIDTH * 2 + DATAWIDTH];
                                    default/*3'd3*/: Conv_din <= Out_small_1[SA_UNITS * DATAWIDTH * 3 + (SA_UNITS * DATAWIDTH - 1) + DATAWIDTH : SA_UNITS * DATAWIDTH * 3 + DATAWIDTH]; 
                                endcase
                            end
                        CONV3_2_STATE:
                            begin
                                case(current_loop)
                                    3'd0: Conv_din <= Out_small_2[SA_UNITS * DATAWIDTH - 1 + DATAWIDTH: 0 + DATAWIDTH];
                                    3'd1: Conv_din <= Out_small_2[SA_UNITS * DATAWIDTH + (SA_UNITS * DATAWIDTH - 1) + DATAWIDTH : SA_UNITS * DATAWIDTH + DATAWIDTH];
                                    3'd2: Conv_din <= Out_small_2[SA_UNITS * DATAWIDTH * 2 + (SA_UNITS * DATAWIDTH - 1) + DATAWIDTH : SA_UNITS * DATAWIDTH * 2 + DATAWIDTH];
                                    default/*3'd3*/: Conv_din <= Out_small_2[SA_UNITS * DATAWIDTH * 3 + (SA_UNITS * DATAWIDTH - 1) + DATAWIDTH : SA_UNITS * DATAWIDTH * 3 + DATAWIDTH];
                                endcase
                            end 
                        default: Conv_din <= 0; // not Convolution state
                    endcase
                end 
            end 
        end 
    end 
    
    //output_temp value
    always @(posedge clk_slow, negedge reset) begin
        if(!reset) begin
            output_temp <= 0;
        end else begin
            case(state)
                CONV1_1_STATE: 
                    begin
                        case(current_filter)
                            5'd0: output_temp <= Out_big_1[DATAWIDTH - 1 + DATAWIDTH: 0 + DATAWIDTH];
                            5'd1: output_temp <= Out_big_1[DATAWIDTH + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH + DATAWIDTH];
                            5'd2: output_temp <= Out_big_1[DATAWIDTH * 2 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 2 + DATAWIDTH];
                            5'd3: output_temp <= Out_big_1[DATAWIDTH * 3 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 3 + DATAWIDTH];
                            5'd4: output_temp <= Out_big_1[DATAWIDTH * 4 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 4 + DATAWIDTH];
                            default/*5'd5*/: output_temp <= Out_big_1[DATAWIDTH * 5 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 5 + DATAWIDTH];
                        endcase
                    end 
                CONV1_2_STATE: 
                    begin
                        case(current_filter)
                            5'd0: output_temp <= Out_big_2[DATAWIDTH - 1 + DATAWIDTH: 0 + DATAWIDTH];
                            5'd1: output_temp <= Out_big_2[DATAWIDTH + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH + DATAWIDTH];
                            5'd2: output_temp <= Out_big_2[DATAWIDTH * 2 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 2 + DATAWIDTH];
                            5'd3: output_temp <= Out_big_2[DATAWIDTH * 3 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 3 + DATAWIDTH];
                            5'd4: output_temp <= Out_big_2[DATAWIDTH * 4 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 4 + DATAWIDTH];
                            default/*5'd5*/: output_temp <= Out_big_2[DATAWIDTH * 5 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 5 + DATAWIDTH];
                        endcase
                    end
                CONV2_1_STATE, CONV3_2_STATE:
                    begin
                        case(current_filter)
                            5'd0: output_temp <= Out_small_1[DATAWIDTH - 1 + DATAWIDTH: 0 + DATAWIDTH];
                            5'd1: output_temp <= Out_small_1[DATAWIDTH + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH + DATAWIDTH];
                            5'd2: output_temp <= Out_small_1[DATAWIDTH * 2 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 2 + DATAWIDTH];
                            5'd3: output_temp <= Out_small_1[DATAWIDTH * 3 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 3 + DATAWIDTH];
                            5'd4: output_temp <= Out_small_1[DATAWIDTH * 4 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 4 + DATAWIDTH];
                            5'd5: output_temp <= Out_small_1[DATAWIDTH * 5 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 5 + DATAWIDTH];
                            5'd6: output_temp <= Out_small_1[DATAWIDTH * 6 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 6 + DATAWIDTH];
                            5'd7: output_temp <= Out_small_1[DATAWIDTH * 7 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 7 + DATAWIDTH];
                            5'd8: output_temp <= Out_small_1[DATAWIDTH * 8 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 8 + DATAWIDTH];
                            5'd9: output_temp <= Out_small_1[DATAWIDTH * 9 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 9 + DATAWIDTH];
                            5'd10: output_temp <= Out_small_1[DATAWIDTH * 10 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 10 + DATAWIDTH];
                            5'd11: output_temp <= Out_small_1[DATAWIDTH * 11 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 11 + DATAWIDTH];
                            5'd12: output_temp <= Out_small_1[DATAWIDTH * 12 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 12 + DATAWIDTH];
                            5'd13: output_temp <= Out_small_1[DATAWIDTH * 13 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 13 + DATAWIDTH];
                            5'd14: output_temp <= Out_small_1[DATAWIDTH * 14 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 14 + DATAWIDTH];
                            default/*5'd15*/: output_temp <= Out_small_1[DATAWIDTH * 15 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 15 + DATAWIDTH];
                        endcase
                    end
                CONV2_2_STATE, CONV3_1_STATE:
                    begin
                        case(current_filter)
                            5'd0: output_temp <= Out_small_2[DATAWIDTH - 1 + DATAWIDTH: 0 + DATAWIDTH];
                            5'd1: output_temp <= Out_small_2[DATAWIDTH + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH + DATAWIDTH];
                            5'd2: output_temp <= Out_small_2[DATAWIDTH * 2 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 2 + DATAWIDTH];
                            5'd3: output_temp <= Out_small_2[DATAWIDTH * 3 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 3 + DATAWIDTH];
                            5'd4: output_temp <= Out_small_2[DATAWIDTH * 4 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 4 + DATAWIDTH];
                            5'd5: output_temp <= Out_small_2[DATAWIDTH * 5 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 5 + DATAWIDTH];
                            5'd6: output_temp <= Out_small_2[DATAWIDTH * 6 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 6 + DATAWIDTH];
                            5'd7: output_temp <= Out_small_2[DATAWIDTH * 7 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 7 + DATAWIDTH];
                            5'd8: output_temp <= Out_small_2[DATAWIDTH * 8 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 8 + DATAWIDTH];
                            5'd9: output_temp <= Out_small_2[DATAWIDTH * 9 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 9 + DATAWIDTH];
                            5'd10: output_temp <= Out_small_2[DATAWIDTH * 10 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 10 + DATAWIDTH];
                            5'd11: output_temp <= Out_small_2[DATAWIDTH * 11 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 11 + DATAWIDTH];
                            5'd12: output_temp <= Out_small_2[DATAWIDTH * 12 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 12 + DATAWIDTH];
                            5'd13: output_temp <= Out_small_2[DATAWIDTH * 13 + (DATAWIDTH - 1) + DATAWIDTH + DATAWIDTH: DATAWIDTH * 13 + DATAWIDTH];
                            5'd14: output_temp <= Out_small_2[DATAWIDTH * 14 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 14 + DATAWIDTH];
                            default/*5'd15*/: output_temp <= Out_small_2[DATAWIDTH * 15 + (DATAWIDTH - 1) + DATAWIDTH: DATAWIDTH * 15 + DATAWIDTH];
                        endcase
                    end 
                default: output_temp <= 0; // not Convolution state
            endcase
        end 
    end 
    
    //--------------------------------------------------------------Avg_Pool-------------------------------------------------------------------
    Avg_Pool_Multiple_Cores #(
        .input_map_address_datawidth(input_map_address_datawidth),
        .output_map_address_datawidth(output_map_address_datawidth),
        .number_datawidth(DATAWIDTH),
        .middle_data_index_datawidth(middle_data_index_datawidth),
        .input_datawidth(input_datawidth),
        .STATE_DATAWIDTH(STATE_DATAWIDTH),
        .AVG1_STATE(AVG_POOL1),
        .AVG2_STATE(AVG_POOL2),
        .AVG3_STATE(AVG_POOL3),
        .AVG1_INPUT_SIZE(AVG1_INPUT_SIZE),
        .AVG2_INPUT_SIZE(AVG2_INPUT_SIZE),
        .AVG3_INPUT_SIZE(AVG3_INPUT_SIZE),
        .AVG1_OUTPUT_SIZE(AVG1_OUTPUT_SIZE),
        .AVG2_OUTPUT_SIZE(AVG2_OUTPUT_SIZE),
        .AVG3_OUTPUT_SIZE(AVG3_OUTPUT_SIZE),
        .AVG_LOOP_DATAWIDTH(AVG_LOOP_DATAWIDTH),
        .COMPUTING_CORES(COMPUTING_CORES)
    )avg0(
    .clk(clk_slow),
    .reset(reset),
    .done(Avg_done),
    .wr_ena(Avg_wr_ena),
    .avg_loop(avg_loop),
    .state(state),
    .BRAM_Pool_In1(BRAM_Pool_In1), 
    .BRAM_Pool_In1_Address(BRAM_Pool_In1_Address),
    .BRAM_Pool_Out1(BRAM_Pool_Out1), 
    .BRAM_Pool_Out1_Address(BRAM_Pool_Out1_Address)
    );
    
    // Avg_Pool_In value
    always @(*) begin
        if(!reset) begin
            BRAM_Pool_In1 = 0;
        end else begin
            case(state)
                AVG_POOL1: 
                    begin
                        case(avg_loop)
                            3'd0: BRAM_Pool_In1 = Out_big_2[COMPUTING_CORES * DATAWIDTH - 1+ DATAWIDTH: 0 + DATAWIDTH];
                            3'd1: 
                                begin
                                    if(BRAM_Pool_In1_Address == 0) begin
                                        BRAM_Pool_In1 = Out_big_2[COMPUTING_CORES * DATAWIDTH - 1+ DATAWIDTH: 0 + DATAWIDTH];
                                    end else begin
                                        BRAM_Pool_In1[2 * DATAWIDTH - 1 : 0] = Out_big_2[COMPUTING_CORES * DATAWIDTH + (2 * DATAWIDTH - 1) : COMPUTING_CORES * DATAWIDTH];
                                        BRAM_Pool_In1[2 * DATAWIDTH + (2 * DATAWIDTH - 1) : 2 * DATAWIDTH] = 32'd0;
                                    end 
                                end
                            3'd2: 
                                begin
                                    if(BRAM_Pool_In1_Address == 0) begin
                                        BRAM_Pool_In1[2 * DATAWIDTH - 1 : 0] = Out_big_2[COMPUTING_CORES * DATAWIDTH + (2 * DATAWIDTH - 1) : COMPUTING_CORES * DATAWIDTH];
                                        BRAM_Pool_In1[2 * DATAWIDTH + (2 * DATAWIDTH - 1) : 2 * DATAWIDTH] = 32'd0;
                                    end else begin
                                        BRAM_Pool_In1 = 0;
                                    end 
                                end
                            default: BRAM_Pool_In1 = 0;
                        endcase
                    end 
                AVG_POOL2:
                    begin
                        case(avg_loop)
                            3'd0: BRAM_Pool_In1 = Out_small_2[COMPUTING_CORES * DATAWIDTH - 1 + DATAWIDTH: 0 + DATAWIDTH];
                            3'd1: 
                                begin
                                    if(BRAM_Pool_In1_Address == 0) begin
                                        BRAM_Pool_In1 = Out_small_2[COMPUTING_CORES * DATAWIDTH - 1 + DATAWIDTH: 0 + DATAWIDTH];
                                    end else begin
                                        BRAM_Pool_In1 = Out_small_2[COMPUTING_CORES * DATAWIDTH * 2 - 1 + DATAWIDTH: COMPUTING_CORES * DATAWIDTH + DATAWIDTH];
                                    end
                                end 
                            3'd2: 
                                begin
                                    if(BRAM_Pool_In1_Address == 0) begin
                                        BRAM_Pool_In1 = Out_small_2[COMPUTING_CORES * DATAWIDTH * 2 - 1 + DATAWIDTH: COMPUTING_CORES * DATAWIDTH + DATAWIDTH];
                                    end else begin
                                        BRAM_Pool_In1 = Out_small_2[COMPUTING_CORES * DATAWIDTH * 3 - 1 + DATAWIDTH: COMPUTING_CORES * DATAWIDTH * 2 + DATAWIDTH];
                                    end
                                end
                            3'd3: 
                                begin
                                    if(BRAM_Pool_In1_Address == 0) begin
                                        BRAM_Pool_In1 = Out_small_2[COMPUTING_CORES * DATAWIDTH * 3 - 1 + DATAWIDTH: COMPUTING_CORES * DATAWIDTH * 2 + DATAWIDTH];
                                    end else begin
                                        BRAM_Pool_In1 = Out_small_2[COMPUTING_CORES * DATAWIDTH * 4 - 1 + DATAWIDTH: COMPUTING_CORES * DATAWIDTH * 3 + DATAWIDTH];
                                    end
                                end 
                            3'd4: 
                                begin
                                    if(BRAM_Pool_In1_Address == 0) begin
                                        BRAM_Pool_In1 = Out_small_2[COMPUTING_CORES * DATAWIDTH * 4 - 1 + DATAWIDTH: COMPUTING_CORES * DATAWIDTH * 3 + DATAWIDTH];
                                    end else begin
                                        BRAM_Pool_In1 = 0;
                                    end
                                end
                            default: BRAM_Pool_In1 = 0;
                        endcase
                    end
                AVG_POOL3:
                    begin
                        case(avg_loop)
                            3'd0: BRAM_Pool_In1 = Out_small_1[COMPUTING_CORES * DATAWIDTH - 1 + DATAWIDTH: 0 + DATAWIDTH];
                            3'd1: 
                                begin
                                    if(BRAM_Pool_In1_Address == 0) begin
                                        BRAM_Pool_In1 = Out_small_1[COMPUTING_CORES * DATAWIDTH - 1 + DATAWIDTH: 0 + DATAWIDTH];
                                    end else begin
                                        BRAM_Pool_In1 = Out_small_1[COMPUTING_CORES * DATAWIDTH * 2 - 1 + DATAWIDTH: COMPUTING_CORES * DATAWIDTH + DATAWIDTH];
                                    end
                                end 
                            3'd2: 
                                begin
                                    if(BRAM_Pool_In1_Address == 0) begin
                                        BRAM_Pool_In1 = Out_small_1[COMPUTING_CORES * DATAWIDTH * 2 - 1 + DATAWIDTH: COMPUTING_CORES * DATAWIDTH + DATAWIDTH];
                                    end else begin
                                        BRAM_Pool_In1 = Out_small_1[COMPUTING_CORES * DATAWIDTH * 3 - 1 + DATAWIDTH: COMPUTING_CORES * DATAWIDTH * 2 + DATAWIDTH];
                                    end
                                end
                            3'd3: 
                                begin
                                    if(BRAM_Pool_In1_Address == 0) begin
                                        BRAM_Pool_In1 = Out_small_1[COMPUTING_CORES * DATAWIDTH * 3 - 1 + DATAWIDTH: COMPUTING_CORES * DATAWIDTH * 2 + DATAWIDTH];
                                    end else begin
                                        BRAM_Pool_In1 = Out_small_1[COMPUTING_CORES * DATAWIDTH * 4 - 1 + DATAWIDTH: COMPUTING_CORES * DATAWIDTH * 3 + DATAWIDTH];
                                    end
                                end 
                            3'd4: 
                                begin
                                    if(BRAM_Pool_In1_Address == 0) begin
                                        BRAM_Pool_In1 = Out_small_1[COMPUTING_CORES * DATAWIDTH * 4 - 1 + DATAWIDTH: COMPUTING_CORES * DATAWIDTH * 3 + DATAWIDTH];
                                    end else begin
                                        BRAM_Pool_In1 = 0;
                                    end
                                end
                            default: BRAM_Pool_In1 = 0;
                        endcase
                    end
                default: BRAM_Pool_In1 = 0; // not Avg_Pool state
            endcase
        end 
    end
    
    //--------------------------------------------------------------Fully Connect-------------------------------------------------------------------
    Fully_Connect#(
        .datawidth(DATAWIDTH),
        .input_nodes(FC_INPUT_NODES),
        .output_nodes(FC_OUTPUT_NODES),
        .Mult_Add_Units(FC_MULT_ADD_UNITS),
        .Fully_Connect(FC_STATE)
    )fc0(
        .clk(clk_slow), 
        .reset(reset),
        .state(state),
        .input_data(Out_small_2[PL_BRAM_SMALL_NUMBER * DATAWIDTH - 1 + DATAWIDTH : DATAWIDTH]),
        .output_data(FC_dout),
        .done(FC_done)
    );
    
    // FC_dout_store
    always @(posedge clk_slow, negedge reset) begin
        if(!reset) begin
            FC_dout_store <= 0;
        end else begin
            if(FC_done) begin
                FC_dout_store <= FC_dout;
            end else begin
                FC_dout_store <= FC_dout_store;
            end 
        end 
    end 
    
    //----------------------------------------------------------------Final Judge-------------------------------------------------------------------
    Final_Judge #(
    .STATE_DATAWIDTH(STATE_DATAWIDTH),
    .JUDGE_STATE(JUDGE),
    .PICTURES(PICTURES)
    )FJ0(
    .bool(judge_result),
    .judge_done(Judge_done),
    .all_done(Judge_all_done),
    .clk(clk_slow), 
    .rst(reset),
    .human(FC_dout_store[(DATAWIDTH - 1) : 0]), 
    .no_human(FC_dout_store[DATAWIDTH + (DATAWIDTH - 1) : DATAWIDTH]),
    .State(state)
    );
    
    
endmodule
