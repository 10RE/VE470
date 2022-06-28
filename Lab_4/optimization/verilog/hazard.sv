`ifndef __HAZARD_V__
`define __HAZARD_V__

module hazard_control(         
	input         clock,              // system clock
	input         reset,              // system reset
	input [4:0]   rda_idx,
	input [4:0]   rdb_idx,
	input [4:0]   dst_idx,
	
	output FORWARD_TYPE hazard
);

logic [2:0][4:0] check_queue;
logic [1:0] check_pos;



endmodule