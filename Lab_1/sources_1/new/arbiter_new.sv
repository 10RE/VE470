module arbiterFSM_new(
        input clock, reset, A, B,
        output logic grant_to_A, grant_to_B
        ); 

    //TODO: Start your design here
    //wire [1:0]clock, reset, A, B;
    logic local_grant_to_A;
    logic local_grant_to_B;
    //reg test_out;
    logic gA;
    logic gB;
    
    always_comb begin
        local_grant_to_A = (~reset) & ((A & (~gA & ~gB)) | (gA & A & ~gB));
        local_grant_to_B = (~reset) & (((~A) & B & (~gA & ~gB)) | (gB & B & ~gA));
        gA = local_grant_to_A;
        gB = local_grant_to_B;
    end
    
    always_ff @(posedge clock) begin
        grant_to_A <= #1 local_grant_to_A;
        grant_to_B <= #1 local_grant_to_B;
    end

endmodule