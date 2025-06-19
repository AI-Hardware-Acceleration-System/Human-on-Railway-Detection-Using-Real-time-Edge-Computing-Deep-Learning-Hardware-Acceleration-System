module float16_comparator(
    output reg out_compared,
    input [15:0] first_comp, second_comp
);
     
    always @(*) begin
        if(first_comp[15] < second_comp[15]) begin // first is positive, second is negative
            out_compared = 1'b0;
        end else if(first_comp[15] > second_comp[15]) begin // first is negative, second is positive
            out_compared = 1'b1;
        end else begin
            if(first_comp[15] == 0) begin // both are positive
                if(first_comp[14:10] > second_comp[14:10]) begin //The exponent of first_comp is bigger than that of second_comp
                    out_compared = 1'b0;
                end else if(first_comp[14:10] < second_comp[14:10]) begin //The exponent of first_comp is smaller than that of second_comp
                    out_compared = 1'b1;
                end else begin //Both expenents are the same
                    if(first_comp[9:0] > second_comp[9:0]) begin //The mantissa of first_comp is bigger than that of second_comp
                        out_compared = 1'b0;
                    end else if(first_comp[9:0] < second_comp[9:0]) begin //The mantissa of first_comp is smaller than that of second_comp
                        out_compared = 1'b1;
                    end else begin //Both mantissas are the same, which means that two numbers are the same
                        out_compared = 1'b0;
                    end 
                end
            end else begin // both are negative
                if(first_comp[14:10] > second_comp[14:10]) begin //The exponent of first_comp is bigger than that of second_comp
                    out_compared = 1'b1;
                end else if(first_comp[14:10] < second_comp[14:10]) begin //The exponent of first_comp is smaller than that of second_comp
                    out_compared = 1'b0;
                end else begin //Both expenents are the same
                    if(first_comp[9:0] > second_comp[9:0]) begin //The mantissa of first_comp is bigger than that of second_comp
                        out_compared = 1'b1;
                    end else if(first_comp[9:0] < second_comp[9:0]) begin //The mantissa of first_comp is smaller than that of second_comp
                        out_compared = 1'b0;
                    end else begin //Both mantissas are the same, which means that two numbers are the same
                        out_compared = 1'b0;
                    end 
                end
            end
        end
    end

endmodule
