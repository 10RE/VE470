`timescale 1ns / 1ps

module P1b(
    input [3:0] req,
    input en,
    output logic [3:0] gnt
    );
    
    always @(*) begin
        if (en)
            if (req[3])
                gnt = 4'b1000;
            else if (req[2])
                gnt = 4'b0100;
            else if (req[1])
                gnt = 4'b0010;
            else if (req[0])
                gnt = 4'b0001;
            else
                gnt = 4'b0;
        else
            gnt = 4'b0;
    end
    
endmodule
