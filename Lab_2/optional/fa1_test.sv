//TESTBENCH FOR 1-BIT FULL ADDER
//Class:       ECE4700J
//Specific:    Lab 2
//Description: This file contains the testbench for a 1-bit full adder.

`timescale 1ns/100ps

module testbench;

// I/O of the full_adder_1bit module
logic        A, B, Cin;
logic        Sum, Cout;

logic        clock;
logic [1:0]  GOLDEN_SUM;
logic        correct;

logic [2:0] loop_cnt;

// Don't forget to wire in your signals to the module instantiation here!
full_adder_1bit DUT(
    .A(A),
    .B(B),
    .carry_in(Cin),
    .S(Sum),
    .carry_out(Cout)
);

// Golden output
assign GOLDEN_SUM = A + B + Cin;

// Comparison between the output of the module and golden output
assign correct = ( Sum === GOLDEN_SUM[0] ) && ( Cout === GOLDEN_SUM[1] );

always@(correct)
begin
    #2
    if(!correct)
    begin
        //Note that nothing will be displayed unless your adder produces 
        //    incorrect output
        $display("@@@ Incorrect at time %4.0f", $time);
        $display("@@@ Time:%4.0f clock:%b A:%h B:%h CIN:%b SUM:%h COUT:%b", 
            $time, clock, A, B, Cin, Sum, Cout);
        $display("@@@ expected sum=%b cout=%b", GOLDEN_SUM[0],GOLDEN_SUM[1] );
        $finish;
    end
end

//--- Clock Generation Block ---//
always
begin
    #5 clock=~clock;
end

//--- Value Setting Block ---//
initial
begin
    clock  =    0;
    A      =    0;
    B      =    0;
    Cin    =    0;

    // Remember that monitor statements change whenever *any argument* changes
    $monitor("Time:%4.0f clock:%b A:%h B:%h CIN:%b SUM:%h COUT:%b", $time, clock, A, B, Cin, Sum, Cout);
    
    // How many unique inputs are possible for a 1-bit full adder?
    // Would it be better to change them all by hand or to use some kind of test
    //    bench flow control?
    
    loop_cnt = 3'b000;
    while (loop_cnt < 3'b111)
    begin
        @(negedge clock)
        A = loop_cnt[2];
        B = loop_cnt[1];
        Cin = loop_cnt[0];
        loop_cnt += 1;
    end
    
    $finish;
end

endmodule
