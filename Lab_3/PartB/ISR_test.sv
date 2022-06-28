`define HALF_CYCLE 250

`timescale 1ns / 100ps

module ISR_test();
    logic [63:0] value;
	logic clock, reset;

	logic [31:0] result;
	logic done;
	
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
    
    logic reset_done;
    
    logic [31:0] prev_result;
    
    logic test_larger;
    logic [31:0] func_ret;
    
    logic initializing;
    
    int clock_cycle_count;
    int random_steps;
    
    //int result_square;
    logic [32:0] result_plus;
    logic [64:0] result_plus_square;
    
    assign result_plus = {1'b0, result};
    assign result_plus_square = (result_plus + 1) * (result_plus + 1);
	wire correct = ((result * result <= value) & (result_plus_square > value)) | ~done | reset;


    ISR ISR0(
        .reset(reset),
        .value(value),
        .clock(clock),
        .result(result),
        .done(done),
        .value_latch(value_latch),
        .mult_result(mult_result),
        .internal_result(internal_result),
        .internal_done(internal_done),
        .state(state),
        .mult_reset(mult_reset),
        .mult_start(mult_start),
        .mult_done(mult_done),
        .min(min),
        .max(max),
        .reset_done(reset_done),
        .prev_result(prev_result),
        .test_larger(test_larger),
        .func_ret(func_ret)
        );
    
	always @(posedge clock)
		#(`HALF_CYCLE-5) if(!correct && !initializing) begin 
			$display("Incorrect at time %4.0f",$time);
			$display("value = %d result = %d",value, result);
			$finish;
		end

	always begin
		#`HALF_CYCLE;
		clock=~clock;
	end
	
	always @(posedge clock) begin
       clock_cycle_count = clock_cycle_count + 1;
    end
	

	// Some students have had problems just using "@(posedge done)" because their
	// "done" signals glitch (even though they are the output of a register). This
	// prevents that by making sure "done" is high at the clock edge.
	task wait_until_done;
	   clock_cycle_count = 0;
		forever begin
			@(posedge done);
			@(negedge clock);
			if(done) disable wait_until_done;
		end
	endtask

    always @(done) begin
        if (done) begin
            $display("Time:%4.0f done:%b value:%d result:%d cycles",$time, done, value, result, clock_cycle_count);
            clock_cycle_count = 0;
        end
    end

	initial begin
        clock_cycle_count = 0;
        clock=0;
        initializing = 1'b1;
        
        $dumpvars;
        //$monitor("Time:%4.0f done:%b value:%d result:%d",$time,done,value,result);
        value=15;
        reset=1;
        
        #2000;
        
        @(negedge clock);
        reset=0;
        initializing = 1'b0;
        //@(negedge clock);
        wait_until_done();
        
        @(negedge clock);
        reset=1;
        value = 17;
        @(negedge clock);
        reset=0;
        //@(negedge clock);
        wait_until_done();
        
        @(negedge clock);
        reset=1;
        value = 38;
        @(negedge clock);
        reset=0;
        //@(negedge clock);
        wait_until_done();
        
        @(negedge clock);
        reset=1;
        value = 38;
        @(negedge clock);
        reset=0;
        //@(negedge clock);
        wait_until_done();
        
        @(negedge clock);
        reset=1;
        value = 64;
        @(negedge clock);
        reset=0;
        //@(negedge clock);
        wait_until_done();
        
        @(negedge clock);
        reset=1;
        value = 38;
        @(negedge clock);
        reset=0;
        @(negedge clock);
        @(negedge clock);
        @(negedge clock);
        @(negedge clock);
        value = 46;
        
        @(negedge clock);
        @(negedge clock);
        reset = 1;
        @(negedge clock);
        reset = 0;
        //@(negedge clock);
        wait_until_done();
        
        @(negedge clock);
        reset=1;
        value = 64'h0fff_ffff_ffff_ffff;
        @(negedge clock);
        reset=0;
        //@(negedge clock);
        wait_until_done();
        
        @(negedge clock);
        reset=1;
        value = 64'hffff_ffff_ffff_ffff;
        @(negedge clock);
        reset=0;
        //@(negedge clock);
        wait_until_done();
        
        @(negedge clock);
        reset=1;
        value = 64'h0;
        @(negedge clock);
        reset=0;
        //@(negedge clock);
        wait_until_done();
        
        @(negedge clock);
        reset=1;
        value = 64'h1;
        @(negedge clock);
        reset=0;
        //@(negedge clock);
        wait_until_done();    
        
        random_steps = 100;
        for (int i = 0; i < random_steps; i ++) begin
            @(negedge clock);
            reset=1;
            value = i;
            @(negedge clock);
            reset=0;
            //@(negedge clock);
            wait_until_done();
        end
                
        random_steps = 1000;
        for (int i = 0; i < random_steps; i ++) begin
            @(negedge clock);
            reset=1;
            value = {$random,$random};
            /*
            if (value > 64'hfffffffe00000001) begin
                value = 64'hfffffffe00000000;
            end
            */
            @(negedge clock);
            reset=0;
            //@(negedge clock);
            wait_until_done();
        end
        
        $finish;
	end
endmodule
