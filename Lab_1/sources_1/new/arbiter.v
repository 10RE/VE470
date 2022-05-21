module arbiterFSM(
        input clock, reset, A, B,
        output grant_to_A, grant_to_B
        ); 

    //TODO: Start your design here
    //wire [1:0]clock, reset, A, B;
    reg grant_to_A;
    reg grant_to_B;
    //reg test_out;
    reg gA;
    reg gB;
    
    always @(posedge clock) begin
        grant_to_A = (~reset) & ((A & (~gA & ~gB)) | (gA & A & ~gB));
        grant_to_B = (~reset) & (((~A) & B & (~gA & ~gB)) | (gB & B & ~gA));
        gA = grant_to_A;
        gB = grant_to_B;
    end

endmodule