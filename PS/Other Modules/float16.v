module uint8_to_float16 (
    input [7:0] u8_input,    // Unsigned 8-bit integer
    output reg [15:0] f16_output // Float16 output
);
    reg [4:0] exponent;     // 5-bit exponent
    //reg [10:0] fraction;    // 11-bit fraction (10-bit mantissa + hidden bit)
    reg sign;               // Sign bit (always 0 for unsigned input)
    reg [9:0] mantissa;     // 10-bit mantissa for FP16
    reg [15:0] sum;         // Final FP16 result
 
    always @(*) begin
        // Initialize outputs
        sign = 1'b0;        // Always positive since input is unsigned

        //if (u8_input == 0) begin
        //    f16_output = 16'b0; // Zero case
        //end else begin
            //exponent = 5'd15;  // Bias of 15
            //fraction = {1'b0, u8_input, 2'b00}; // Left-align u8_input in fraction (8-bit input → 11-bit fraction)

            // Normalize the fraction (shift left until MSB is 1)
            if (u8_input[7] == 1'b1) begin
                mantissa = {u8_input[6:0], 3'd0};
                exponent = 5'd22;
            end else if (u8_input[6] == 1'b1) begin
                mantissa = {u8_input[5:0], 4'd0};
                exponent = 5'd21;
            end else if (u8_input[5] == 1'b1) begin
                mantissa = {u8_input[4:0], 5'd0};
                exponent = 5'd20;
            end else if (u8_input[4] == 1'b1) begin
                mantissa = {u8_input[3:0], 6'd0};
                exponent = 5'd19;
            end else if (u8_input[3] == 1'b1) begin
                mantissa = {u8_input[2:0], 7'd0};
                exponent = 5'd18;
            end else if (u8_input[2] == 1'b1) begin
                mantissa = {u8_input[1:0], 8'd0};
                exponent = 5'd17;
            end else if (u8_input[1] == 1'b1) begin
                mantissa = {u8_input[0], 9'd0};
                exponent = 5'd16;
            end else if (u8_input[0] == 1'b1) begin
                mantissa = 10'd0;
                exponent = 5'd15;
            end else begin
                mantissa = 10'd0;
                exponent = 5'd0;
            end 
        
            // Extract the 10-bit mantissa (ignore hidden bit)
            //mantissa = u8_input[9:0];

            sum = {sign, exponent[4:0], mantissa}; // Construct FP16 result	

            f16_output = sum;
        //end	
    end	
endmodule

module int2float_bus(
    input [31:0] read_int,    // Unsigned 8-bit integer
    output [63:0] send_f16 // Float16 output
);
    assign send_f16[63:48] = 16'd0;
    uint8_to_float16 R (.u8_input(read_int[23:16]),.f16_output(send_f16[47:32]));
    uint8_to_float16 G (.u8_input(read_int[15:0]),.f16_output(send_f16[31:16]));
    uint8_to_float16 B (.u8_input(read_int[7:0]),.f16_output(send_f16[15:0]));

endmodule
