`timescale 1ns / 1ps

module P1a(
    input [3:0] req,
    input en,
    output logic [3:0] gnt
    );
    
    assign gnt = {en & req[3], en & req[2] & ~req[3], en & req[1] & ~req[2] & ~req[3], en & req[0] & ~req[1] & ~req[2] & ~req[3]};
    
endmodule
