module bram_transfer (
    input  wire         clk,
    input  wire         rstn,    // Active-low reset
 
    // --- BRAM Port A: Read Port (Previously Write Port) ---
    (* X_INTERFACE_PARAMETER = "MASTER_TYPE BRAM_CTRL, FREQ_HZ 100000000" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_CTRLR CLK" *)  
    output wire         clka,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_CTRLR RST" *)  
    output wire         rsta,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_CTRLR EN" *)   
    output wire         ena,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_CTRLR ADDR" *) 
    output wire [31:0]  addra,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_CTRLR DIN" *)  
    output wire [31:0]  dina,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_CTRLR WE" *)   
    output wire [3:0]   wea,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_CTRLR DOUT" *) 
    input  wire [31:0]  douta,

    // --- BRAM Port B: Write Port (Previously Read Port) ---
    (* X_INTERFACE_PARAMETER = "MASTER_TYPE BRAM_CTRL, FREQ_HZ 100000000" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_CTRLW CLK" *)  
    output wire         clkb,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_CTRLW RST" *)  
    output wire         rstb,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_CTRLW EN" *)   
    output wire         enb,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_CTRLW ADDR" *) 
    output wire [31:0]  addrb,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_CTRLW DIN" *)  
    output wire [31:0]  dinb,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_CTRLW WE" *)   
    output wire [3:0]   web,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_CTRLW DOUT" *) 
    input  wire [31:0]  doutb
);

    //--------------------------------------------------------------------------
    // Parameters and internal registers
    //--------------------------------------------------------------------------
    parameter MAX_ADDR = 6400*4;  // Maximum address for the transfer

    // Address counter and data register
    reg [31:0] addr_counterA;
    reg [31:0] data_regA;
    reg        write_enable;
    reg [31:0] addr_counterB;
    reg [31:0] data_regB;

    //--------------------------------------------------------------------------
    // Synchronous process for transferring data.
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
        if (!rstn) begin
            addr_counterA  <= 32'd0;
            data_regA      <= 32'd0;
            addr_counterB  <= 32'd0;
            data_regB      <= 32'd0;
            write_enable  <= 1'b0;
        end else begin
            // Capture data from BRAM Port A (read port)
//            data_regA <= douta;
//            data_regB <= data_regA;
            // Enable write in the next cycle
            write_enable <= 1'b1;

            // Increment the address counter, wrap around at MAX_ADDR
            if (addr_counterA < MAX_ADDR && write_enable == 1'b1)
                addr_counterA <= addr_counterA + 4;
            else
                addr_counterA <= 32'd0;
                
            addr_counterB  <= addr_counterA;
        end
    end

    //--------------------------------------------------------------------------
    // BRAM Port A (Read) assignments
    //--------------------------------------------------------------------------
    assign clka  = clk;
    assign rsta  = ~rstn;
    assign ena   = 1'b1;                 // Always enabled for reading
    assign addra = addr_counterA;          // Read address driven by counter
    assign dina  = 32'd0;                 // Not used for reading
    assign wea   = 4'b0000;               // Write disabled on read port

    //--------------------------------------------------------------------------
    // BRAM Port B (Write) assignments
    //--------------------------------------------------------------------------
    assign clkb  = clk;
    assign rstb  = ~rstn;
    assign enb   = 1'b1;                 // Always enabled for writing
    assign addrb = addr_counterB;
    assign dinb  = douta;              // Write the latched data
    assign web   = (write_enable) ? 4'b1111 : 4'b0000; // Enable writing after valid read

endmodule


module bram_readSA (
    input  wire         clk,
    input  wire         rstn,    // Active-low reset
    //input  wire         w_busy,

    // --- BRAM Port A: Read Port ---
    (* X_INTERFACE_PARAMETER = "MASTER_TYPE BRAM_CTRL, FREQ_HZ 100000000" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_CTRLR CLK" *)  
    output wire         clka,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_CTRLR RST" *)  
    output wire         rsta,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_CTRLR EN" *)   
    output wire         ena,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_CTRLR ADDR" *) 
    output wire [31:0]  addra,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_CTRLR DIN" *)  
    output wire [31:0]  dina,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_CTRLR WE" *)   
    output wire [3:0]   wea,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_CTRLR DOUT" *) 
    input  wire [31:0]  douta,
    
    output [31:0] read_value,
    output [12:0] output_addr
);

    //--------------------------------------------------------------------------
    // Parameters and internal registers
    //--------------------------------------------------------------------------
    parameter MAX_ADDR = 7056*4;  // Maximum address for the transfer
    
    wire         start;
    wire [12:0] input_addr;
    
    //wire [12:0] output_addr;
    wire [12:0] out_temp_addr;
    wire last_data;

    
    SA_Addr_Ctrl a456(clk, rstn, start, input_addr, output_addr, out_temp_addr,last_data);

    //--------------------------------------------------------------------------
    // BRAM Port A (Read) assignments
    //--------------------------------------------------------------------------
    assign clka  = clk;
    assign rsta  = ~rstn;
    assign ena   = start;                 // Always enabled for reading
    assign start = 1'b1;
    assign addra = {input_addr,2'b00};    // Read address driven ay counter
    assign dina  = 32'd0;                 // Not used for reading
    assign wea   = 4'b0000;               // Write disaaled on read port
    
    reg [63:0] value_addr;
    reg [63:0] reg_addr;
    
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            reg_addr <= 7878;
            value_addr <= 7878;
        end
        else begin
            reg_addr <= input_addr;
            value_addr <= reg_addr;
        end
    end
    
    parameter MAX = 7056;
    
    assign read_value[31:24] = 8'd0;
    assign read_value[23:16]  = (value_addr < MAX)? douta[23:16]:8'd0;
    assign read_value[15:8] = (value_addr < MAX)? douta[15:8]:8'd0;
    assign read_value[7:0] = (value_addr < MAX)? douta[7:0]:8'd0;
    

endmodule

