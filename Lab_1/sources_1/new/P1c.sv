`timescale 1ns / 1ps

module ps2(
    input [1:0] req,
    input en,
    output logic [1:0] gnt,
    output logic req_up
    );
    
    assign gnt = {en & req[1], en & req[0] & ~req[1]};
    assign req_up =  en & (~(req[1] | req[0]));
    
endmodule

module ps4(
    input [3:0] req,
    input en,
    output logic [3:0] gnt,
    output logic req_up
    );
    
    logic transit_req;
    logic transit_req_in;
    
    ps2 left(.req(req[3:2]), .en(en), .gnt(gnt[3:2]), .req_up(transit_req));
    ps2 right(.req(req[1:0]), .en(transit_req), .gnt(gnt[1:0]), .req_up(req_up));
    
endmodule

module ps8(
    input [7:0] req,
    input en,
    output logic [7:0] gnt,
    output logic req_up
    );
    
    logic transit_req;
    logic transit_req_in;
    
    ps4 left(.req(req[7:4]), .en(en), .gnt(gnt[7:4]), .req_up(transit_req));
    ps4 right(.req(req[3:0]), .en(transit_req), .gnt(gnt[3:0]), .req_up(req_up));
    
endmodule

/*
module ps4(
    input [3:0] req,
    input en,
    output logic [3:0] gnt,
    output logic req_up,
    output logic [1:0] gnt_selector,
    output logic [3:0] transit_gnt
    );
    
    logic [1:0] transit_req;
    logic [1:0] gnt_selector;
    logic [3:0] transit_gnt;
    
    ps2 left(.req(req[3:2]), .en(en), .gnt(transit_gnt[3:2]), .req_up(transit_req[1]));
    ps2 right(.req(req[1:0]), .en(en), .gnt(transit_gnt[1:0]), .req_up(transit_req[0]));
    ps2 top(.req(transit_req), .en(en), .gnt(gnt_selector), .req_up(req_up));
    
    assign gnt = transit_gnt & (2'b11 << ((gnt_selector - 1)*2));
    
endmodule
*/