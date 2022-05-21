`timescale 1ns / 1ps

module testC;
    logic [3:0] req;
    logic  en;
    logic [3:0] gnt;
    logic [3:0] tb_gnt;
    logic req_up;
    logic correct;

    ps4 pe4(req, en, gnt, req_up);

    assign tb_gnt[3]=en&req[3];
    assign tb_gnt[2]=en&req[2]&~req[3];
    assign tb_gnt[1]=en&req[1]&~req[2]&~req[3];
    assign tb_gnt[0]=en&req[0]&~req[1]&~req[2]&~req[3];
    assign correct=(tb_gnt==gnt);

    always @(correct)
    begin
        #2
        if(!correct)
        begin
            $display("@@@ Incorrect at time %4.0f", $time);
            $display("@@@ gnt=%b, en=%b, req=%b",gnt,en,req);
            $display("@@@ expected result=%b", tb_gnt);
            $finish;
        end
    end

    initial 
    begin
		$dumpvars;
        $monitor("Time:%4.0f req:%b en:%b gnt:%b", $time, req, en, gnt);
        req=8'b00000000;
        en=1'b1;
        #5    
        req=8'b10000000;
        #5
        req=8'b01000000;
        #5
        req=8'b00100000;
        #5
        req=8'b00010000;
        #5
        req=8'b00001000;
        #5
        req=8'b00000100;
        #5
        req=8'b00000010;
        #5
        req=8'b00000001;
        #5
        req=8'b01010000;
        #5
        req=8'b01100000;
        #5
        req=8'b11100000;
        #5
        req=8'b11110000;
        #5
        req=8'b00010010;
        #5
        req=8'b00011000;
        #5
        req=8'b00000011;
        #5
        req=8'b11111111;
        #5
        en=0;
        #5
        req=8'b01100000;
        #5
        req=8'b00011000;
        #5
        req=8'b00000011;
        #5
        req=8'b11111111;
        $finish;
     end // initial
endmodule

module testC8;
    logic [7:0] req;
    logic  en;
    logic [7:0] gnt;
    logic [7:0] tb_gnt;
    logic req_up;
    logic correct;

    ps8 pe8(req, en, gnt, req_up);
    
    assign tb_gnt[7]=en&req[7];
    assign tb_gnt[6]=en&req[6]&~req[7];
    assign tb_gnt[5]=en&req[5]&~req[6]&~req[7];
    assign tb_gnt[4]=en&req[4]&~req[5]&~req[6]&~req[7];
    assign tb_gnt[3]=en&req[3]&~req[4]&~req[5]&~req[6]&~req[7];
    assign tb_gnt[2]=en&req[2]&~req[3]&~req[4]&~req[5]&~req[6]&~req[7];
    assign tb_gnt[1]=en&req[1]&~req[2]&~req[3]&~req[4]&~req[5]&~req[6]&~req[7];
    assign tb_gnt[0]=en&req[0]&~req[1]&~req[2]&~req[3]&~req[4]&~req[5]&~req[6]&~req[7];
    assign correct=(tb_gnt==gnt);

    always @(correct)
    begin
        #2
        if(!correct)
        begin
            $display("@@@ Incorrect at time %4.0f", $time);
            $display("@@@ gnt=%b, en=%b, req=%b",gnt,en,req);
            $display("@@@ expected result=%b", tb_gnt);
            $finish;
        end
    end

    initial 
    begin
		$dumpvars;
        $monitor("Time:%4.0f req:%b en:%b gnt:%b", $time, req, en, gnt);
        req=8'b00000000;
        en=1'b1;
        #5    
        req=4'b1000;
        #5
        req=4'b0100;
        #5
        req=4'b0010;
        #5
        req=4'b0001;
        #5
        req=4'b0101;
        #5
        req=4'b0110;
        #5
        req=4'b1110;
        #5
        req=4'b1111;
        #5
        en=0;
        #5
        req=4'b0110;
        #5
        $finish;
     end // initial
endmodule

module testCminor;
    logic [1:0] req;
    logic  en;
    logic [1:0] gnt;
    logic req_up;
    
    ps2 ps2(req, en, gnt, req_up);
    
    initial begin
        req=2'b00;
        en=1'b1;
        #5    
        req=2'b10;
        #5
        req=2'b01;
        #5
        req=2'b11;
        #5
        en=1'b0;
    end
endmodule
