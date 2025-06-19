`timescale 1ns / 1ps

module TOP_confirm_tb;

    parameter PS_BRAM_DATAWIDTH = 64;
    parameter STATE_DATAWIDTH = 4;
    parameter BRAM_ADDR_WIDTH = 13; // 13-bit address for BRAM (8192 locations)
    parameter MAX = 7056;
    parameter OUT_LATENCY = 8;
    
    reg clk_fast, clk_slow;
    reg reset;
    reg PS_BRAM_busy;
    wire [PS_BRAM_DATAWIDTH - 1 : 0] PS_BRAM_rdata;

    // BRAM control signals
    reg en;
    reg [15:0] din;
    wire [15:0] dout_r, dout_g, dout_b;

    // SA_Addr_Ctrl control signals
    reg rst_n, start;
    reg [7:0] IN_SIZE; // Image size or any control param
    reg [BRAM_ADDR_WIDTH-1:0] value_addr;
    reg [BRAM_ADDR_WIDTH-1:0] reg_addr;
    wire [BRAM_ADDR_WIDTH-1:0] input_addr;
    wire [BRAM_ADDR_WIDTH-1:0] output_addr;
    wire [BRAM_ADDR_WIDTH-1:0] out_temp_addr;
    
    
    // Output wires from Top module
    wire judge_result;
    wire PS_data_start;
    wire [STATE_DATAWIDTH - 1 : 0] state;
    
    
    wire clk_compound;
    clock_switch clock_switch0(
        .clk3(clk_fast), .clk1(clk_slow),
        .rst(reset),
        .State(state),
        .clk_out(clk_compound)
    );
    
    wire [255:0] test_data;
    wire test_data_write_enable;
    // Instantiate the Top module
    Top TOP (
        .state(state),
        .judge_result(judge_result),
        .PS_data_start(PS_data_start),
        .clk_fast(clk_fast),
        .clk_slow(clk_slow),
        .reset(reset),
        .PS_BRAM_busy(PS_BRAM_busy),
        .PS_BRAM_rdata(PS_BRAM_rdata),
        .Conv1_1_Address(output_addr),
        .test_data(test_data),
        .test_data_write_enable(test_data_write_enable)
    );

    // Instantiate BRAM modules (VHDL BRAMs) with dynamic addressing from SA_Addr_Ctrl
    R_BRAM r_bram (
        .clka(clk_fast),
        .ena(en),
        .wea(1'b0),
        .addra(input_addr), // Controlled by SA_Addr_Ctrl
        .dina(din),
        .douta(dout_r)
    );

    G_BRAM g_bram (
        .clka(clk_fast),
        .ena(en),
        .wea(1'b0),
        .addra(input_addr), // Controlled by SA_Addr_Ctrl
        .dina(din),
        .douta(dout_g)
    );

    B_BRAM b_bram (
        .clka(clk_fast),
        .ena(en),
        .wea(1'b0),
        .addra(input_addr), // Controlled by SA_Addr_Ctrl
        .dina(din),
        .douta(dout_b)
    );

    // Instantiate SA_Addr_Ctrl
    SA_Addr_Ctrl #(
        .out_latency(OUT_LATENCY)
    )addr_ctrl(
        .clk(clk_compound),
        .rst_n(rst_n),
        .start(PS_data_start),
        .IN_SIZE(IN_SIZE),
        .input_addr(input_addr),
        .output_addr(output_addr),
        .out_temp_addr(out_temp_addr)
    );
    
    always @(posedge clk_fast or negedge reset) begin
        if(!reset)begin
            reg_addr <= 7878;
            value_addr <= 7878;
        end
        else begin
            reg_addr <= input_addr;
            value_addr <= reg_addr;
        end
    end
    
    assign PS_BRAM_rdata[63:48] = 16'd0;
    assign PS_BRAM_rdata[47:32] = (value_addr < MAX)? dout_r:16'd0;
    assign PS_BRAM_rdata[31:16] = (value_addr < MAX)? dout_g:16'd0;
    assign PS_BRAM_rdata[15:0] = (value_addr < MAX)? dout_b:16'd0;


    initial begin
        // Initialize signals
        clk_fast = 0;
        forever
            #5 clk_fast = ~clk_fast;
    end
    
    initial begin
        // Initialize signals
        clk_slow = 0;
        #3 clk_slow = 1;
        forever
           #15 clk_slow = ~clk_slow; // 10MHz clock`
    end

    // Testbench Process
    initial begin
        // Initialize signals
        reset = 1;
        rst_n = 0;
        start = 0;
        IN_SIZE = 84; // Assume 80x80 image
//        PS_BRAM_busy = 0;
        //PS_BRAM_rdata = 64'h0;
        en = 1;
        din = 16'h1234;

        // Apply Reset
        #20 reset = 0;
        rst_n = 1;
        #20 reset = 1;

        // Start Address Control
        #10 start = 1;
        //#10 start = 0;

        // End simulation
//        #100 PS_BRAM_busy = 0;
        //#100000000;
//        $finish;
    end
    
    initial begin
        PS_BRAM_busy = 0;
        #50 PS_BRAM_busy = 1;
        #50 PS_BRAM_busy = 0;
        
    end 
    
//    always @(*) begin
//    if (state == 4) begin
//      $display("[TCL_CONSOLE] @%0t: data_out = 0x%0h (enable=1)",
//               $time, test_data);
//    end
//  end
  
      integer outfile;
        // open file
      initial begin
        outfile = $fopen("Conv1_1_add_final.txt", "w");
        if (outfile == 0) begin
          $display("Failed to open file for writing!");
        end
      end
    
      // output to file
      always @(posedge clk_slow) begin
        if (state == 2) begin
//          $display("[TCL_CONSOLE] @%0t: data_out = 0x%0h (enable=1)", $time, data_out);
          if(test_data_write_enable) begin
                $fdisplay(outfile, "%h",  test_data);
          end 
        end
      end
    
      // 結束時關檔
      initial begin 
        wait(state==3); 
        $fclose(outfile); 
      end
endmodule
