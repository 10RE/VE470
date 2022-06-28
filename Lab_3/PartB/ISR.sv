`timescale 1ns / 100ps

`define DEBUG

module ISR(
    input reset,
    input [63:0] value,
    input clock,
    output logic [31:0] result,
    output logic done
`ifdef DEBUG
    ,output logic [63:0] value_latch,
    output [63:0] mult_result,
    output logic [31:0] internal_result,
    output logic internal_done,
    output logic [2:0] state,
    output logic mult_reset,
    output logic mult_start,
    output logic mult_done,
    output logic [31:0] min,
    output logic [31:0] max,
    output logic reset_done,
    output logic [31:0] prev_result,
    
    output logic test_larger,
    output logic [31:0] func_ret
    
`endif
    );

`ifndef DEBUG
    logic [63:0] value_latch;
    logic [63:0] mult_result;
    logic [31:0] internal_result;
    logic internal_done;
    
    logic [2:0] state;
    
    logic mult_reset;
    logic mult_start;
    logic mult_done;
    
    logic [31:0] min;
    logic [31:0] max;
    logic [31:0] mid;
    
    logic reset_done;
    
    logic [31:0] prev_result;
    
    //logic first_reset;
    
    output logic test_larger;
    output logic [31:0] func_ret;
`endif
    
    mult8 m0(	.clock(clock),
                .reset(mult_reset),
                .mcand({32'b0, internal_result}),
                .mplier({32'b0, internal_result}),
                .start(mult_start),
                .product(mult_result),
                .done(mult_done));
    
    //assign result = internal_result;
    assign done = reset | (~reset & internal_done);
    
    
    assign test_larger = mult_result > value_latch;
    assign func_ret = max/2 - min/2 + (max[0] ^ min[0]);//(max - in) / 2 + in;
    
    always_ff @(negedge clock) begin
        if (reset) begin
            value_latch <= #1 value;
            if ((value >> 32) > 0) begin
                internal_result <= #1 32'hffff_ffff;
                max <=  #1 32'hffff_ffff;
            end
            else begin
                internal_result <= #1 value[31:0];
                max <=  #1 value[31:0];
            end
            internal_done <= #1 1'b0;
            min <= #1 32'b0;
            state <= #1 3'b001;
            //first_reset <= #1 1'b1;
            reset_done <= #1 1'b1;
        end
        else begin
            if (!internal_done) begin
                if (mult_done || reset_done) begin
                    if (state == 3'b000) begin
                        if (min > max || min == 32'hffff_ffff) begin
                            if (min == 32'hffff_ffff) begin
                                result <= #1 32'hffff_ffff;
                            end
                            //result <= #1 internal_result;
                            internal_done <= #1 1'b1;
                        end
                        else begin
                            internal_result <= #1 min + (max - min)/2; 
                            //internal_result <= #1 divide(internal_result, (mult_result > value_latch));
                        end
                        state <= #1 3'b001;
                        reset_done <= #1 1'b1;
                    end
                    else if (state == 3'b001) begin
                        //prev_result <= #1 internal_result;
                        mult_reset <= #1 1'b1;
                        state <= #1 3'b010;
                    end
                    else if (state == 3'b010) begin
                        mult_reset <= #1 1'b0;
                        state <= #1 3'b011;
                    end
                    else if (state == 3'b011) begin
                        mult_start <= #1 1'b1;
                        state <= #1 3'b100;
                        reset_done <= #1 1'b0;
                    end
                    else if (state == 3'b100) begin
                        if (mult_result > value_latch) begin
                            max <= #1 internal_result - 1;
                        end
                        else begin
                            result <= #1 internal_result;
                            min <= #1 internal_result + 1;
                        end
                        state <= #1 3'b0;
                        reset_done <= #1 1'b1;
                    end
                    else begin
                        state <= #1 3'b0;
                    end
                end
                else begin // if (mult_done || reset_done) begin
                    mult_start <= #1 1'b0;
                end
            end
            else begin //if (!internal_done) begin
                state <= #1 3'b001;
            end
        end
    end
    /*
    function bit [31:0] divide (logic [31:0] in, logic larger);
        if (larger) begin
            
            max = (in >> 1) + (min >> 1) + (in[0] & min[0]) - 1;
            return (in >> 1) + (min >> 1) + (in[0] & min[0]);
        end
        else begin
            internal_result = (max >> 1) - (min >> 1) + (max[0] ^ min[0]);
            min = (in >> 1) + (max >> 1) + (in[0] & max[0]) + 1;
            return (in >> 1) + (max >> 1) + (in[0] & max[0]);
        end
    endfunction
    */
    
    /*
    function bit [31:0] divide (logic [31:0] in, logic larger);
        if (larger) begin
            max = in - (in - min) / 2 - 1;
            return  in - (in - min) / 2;
        end
        else begin
            min = (max - in) / 2 + in + 1;
            return (max - in) / 2 + in;
        end
    endfunction
    */
    
    
    function bit [31:0] divide (logic [31:0] in, logic larger);
        if (larger) begin
            max = (in >> 1) + (min >> 1) + (in[0] & min[0]) - 1;
            return (in >> 1) + (min >> 1) + (in[0] & min[0]);
        end
        else begin
            min = (in >> 1) + (max >> 1) + (in[0] & max[0]) + 1;
            return (in >> 1) + (max >> 1) + (in[0] & max[0]);
        end
    endfunction
    
    
    
endmodule
