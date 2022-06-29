/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  id_stage.v                                          //
//                                                                     //
//  Description :  instruction decode (ID) stage of the pipeline;      // 
//                 decode the instruction fetch register operands, and // 
//                 compute immediate operand (if applicable)           // 
//                                                                     //
/////////////////////////////////////////////////////////////////////////
//`define DEBUG_TEST

`timescale 1ns/100ps


  // Decode an instruction: given instruction bits IR produce the
  // appropriate datapath control signals.
  //
  // This is a *combinational* module (basically a PLA).
  //
module decoder(

	//input [31:0] inst,
	//input valid_inst_in,  // ignore inst when low, outputs will
	                      // reflect noop (except valid_inst)
	//see sys_defs.svh for definition
	input IF_ID_PACKET if_packet,
	//input FORWARD_TYPE forward,
	
	output ALU_OPA_SELECT opa_select,
	output ALU_OPB_SELECT opb_select,
	output DEST_REG_SEL   dest_reg, // mux selects
	output ALU_FUNC       alu_func,
	output logic rd_mem, wr_mem, cond_branch, uncond_branch,
	output logic csr_op,    // used for CSR operations, we only used this as 
	                        //a cheap way to get the return code out
	output logic halt,      // non-zero on a halt
	output logic illegal,    // non-zero on an illegal instruction
	output logic valid_inst  // for counting valid instructions executed
	                        // and for making the fetch stage die on halts/
	                        // keeping track of when to allow the next
	                        // instruction out of fetch
	                        // 0 for HALT and illegal instructions (die on halt)
);

	INST inst;
	logic valid_inst_in;
	
	assign inst          = if_packet.inst;
	assign valid_inst_in = if_packet.valid;
	assign valid_inst    = valid_inst_in & ~illegal;
	
	always_comb begin
		// default control values:
		// - valid instructions must override these defaults as necessary.
		//	 opa_select, opb_select, and alu_func should be set explicitly.
		// - invalid instructions should clear valid_inst.
		// - These defaults are equivalent to a noop
		// * see sys_defs.vh for the constants used here
		opa_select = OPA_IS_RS1;
		opb_select = OPB_IS_RS2;
		alu_func = ALU_ADD;
		dest_reg = DEST_NONE;
		csr_op = `FALSE;
		rd_mem = `FALSE;
		wr_mem = `FALSE;
		cond_branch = `FALSE;
		uncond_branch = `FALSE;
		halt = `FALSE;
		illegal = `FALSE;
		if(valid_inst_in) begin //&& forward != WB_EX_A_HALT && forward != WB_EX_B_HALT) begin
			casez (inst) 
				`RV32_LUI: begin
					dest_reg   = DEST_RD;
					opa_select = OPA_IS_ZERO;
					opb_select = OPB_IS_U_IMM;
				end
				`RV32_AUIPC: begin
					dest_reg   = DEST_RD;
					opa_select = OPA_IS_PC;
					opb_select = OPB_IS_U_IMM;
				end
				`RV32_JAL: begin
					dest_reg      = DEST_RD;
					opa_select    = OPA_IS_PC;
					opb_select    = OPB_IS_J_IMM;
					uncond_branch = `TRUE;
				end
				`RV32_JALR: begin
					dest_reg      = DEST_RD;
					opa_select    = OPA_IS_RS1;
					opb_select    = OPB_IS_I_IMM;
					uncond_branch = `TRUE;
				end
				`RV32_BEQ, `RV32_BNE, `RV32_BLT, `RV32_BGE,
				`RV32_BLTU, `RV32_BGEU: begin
					opa_select  = OPA_IS_PC;
					opb_select  = OPB_IS_B_IMM;
					cond_branch = `TRUE;
				end
				`RV32_LB, `RV32_LH, `RV32_LW,
				`RV32_LBU, `RV32_LHU: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					rd_mem     = `TRUE;
				end
				`RV32_SB, `RV32_SH, `RV32_SW: begin
					opb_select = OPB_IS_S_IMM;
					wr_mem     = `TRUE;
				end
				`RV32_ADDI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
				end
				`RV32_SLTI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_SLT;
				end
				`RV32_SLTIU: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_SLTU;
				end
				`RV32_ANDI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_AND;
				end
				`RV32_ORI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_OR;
				end
				`RV32_XORI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_XOR;
				end
				`RV32_SLLI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_SLL;
				end
				`RV32_SRLI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_SRL;
				end
				`RV32_SRAI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_SRA;
				end
				`RV32_ADD: begin
					dest_reg   = DEST_RD;
				end
				`RV32_SUB: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_SUB;
				end
				`RV32_SLT: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_SLT;
				end
				`RV32_SLTU: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_SLTU;
				end
				`RV32_AND: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_AND;
				end
				`RV32_OR: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_OR;
				end
				`RV32_XOR: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_XOR;
				end
				`RV32_SLL: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_SLL;
				end
				`RV32_SRL: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_SRL;
				end
				`RV32_SRA: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_SRA;
				end
				`RV32_MUL: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_MUL;
				end
				`RV32_MULH: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_MULH;
				end
				`RV32_MULHSU: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_MULHSU;
				end
				`RV32_MULHU: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_MULHU;
				end
				`RV32_CSRRW, `RV32_CSRRS, `RV32_CSRRC: begin
					csr_op = `TRUE;
				end
				0: begin
				end
				`WFI: begin
					halt = `TRUE;
				end
				default: illegal = `TRUE;

		endcase // casez (inst)
		end // if(valid_inst_in)
	end // always
endmodule // decoder


module id_stage(         
	input         clock,              // system clock
	input         reset,              // system reset
	input         wb_reg_wr_en_out,    // Reg write enable from WB Stage
	input  [4:0] wb_reg_wr_idx_out,  // Reg write index from WB Stage
	input  [`XLEN-1:0] wb_reg_wr_data_out,  // Reg write data from WB Stage
	input  IF_ID_PACKET if_id_packet_in,
	
	output ID_EX_PACKET id_packet_out

`ifdef DEBUG_TEST
	,
	output logic EX_inst_use_mem_debug
`endif

);

`ifdef DEBUG_TEST
	assign EX_inst_use_mem_debug = inst_use_mem;
`endif

	logic local_halt;
	ID_EX_PACKET local_halt_id_packet_out;
	ID_EX_PACKET local_id_packet_out;

    assign local_id_packet_out.NPC  = if_id_packet_in.NPC;
    assign local_id_packet_out.PC   = if_id_packet_in.PC;
	DEST_REG_SEL dest_reg_select; 

	// Instantiate the register file used by this pipeline
	regfile regf_0 (
		.rda_idx(if_id_packet_in.inst.r.rs1),
		.rda_out(local_id_packet_out.rs1_value), 

		.rdb_idx(if_id_packet_in.inst.r.rs2),
		.rdb_out(local_id_packet_out.rs2_value),

		.wr_clk(clock),
		.wr_en(wb_reg_wr_en_out),
		.wr_idx(wb_reg_wr_idx_out),
		.wr_data(wb_reg_wr_data_out)
	);

	// instantiate the instruction decoder
	decoder decoder_0 (
		.if_packet(if_id_packet_in),
		//.forward(local_id_packet_out.forward),	 
		// Outputs
		.opa_select(local_id_packet_out.opa_select),
		.opb_select(local_id_packet_out.opb_select),
		.alu_func(local_id_packet_out.alu_func),
		.dest_reg(dest_reg_select),
		.rd_mem(local_id_packet_out.rd_mem),
		.wr_mem(local_id_packet_out.wr_mem),
		.cond_branch(local_id_packet_out.cond_branch),
		.uncond_branch(local_id_packet_out.uncond_branch),
		.csr_op(local_id_packet_out.csr_op),
		.halt(local_id_packet_out.halt),
		.illegal(local_id_packet_out.illegal),
		.valid_inst(local_id_packet_out.valid)
	);

	// mux to generate dest_reg_idx based on
	// the dest_reg_select output from decoder
	always_comb begin
		casez (dest_reg_select)
			DEST_RD:    local_id_packet_out.dest_reg_idx = if_id_packet_in.inst.r.rd;
			DEST_NONE:  local_id_packet_out.dest_reg_idx = `ZERO_REG;
			default:    local_id_packet_out.dest_reg_idx = `ZERO_REG; 
		endcase
	end

	logic EX_dest_equal_rs1;
	logic EX_dest_equal_rs2;
	logic MEM_dest_equal_rs1;
	logic MEM_dest_equal_rs2;
	logic inst_use_mem;
	logic EX_inst_load;
	logic EX_inst_read_only;
	logic MEM_inst_read_only;
	//logic opa_rs;
	//logic opb_rs;

	assign EX_dest_equal_rs1 = (if_id_packet_in.EX_dest_reg_idx == if_id_packet_in.inst.r.rs1) && !EX_inst_read_only && (if_id_packet_in.inst.r.rs1 != `ZERO_REG); //&& opa_rs;
	assign EX_dest_equal_rs2 = (if_id_packet_in.EX_dest_reg_idx == if_id_packet_in.inst.r.rs2) && !EX_inst_read_only && (if_id_packet_in.inst.r.rs2 != `ZERO_REG); //&& opb_rs;
	assign MEM_dest_equal_rs1 = (if_id_packet_in.MEM_dest_reg_idx == if_id_packet_in.inst.r.rs1) && !MEM_inst_read_only && (if_id_packet_in.inst.r.rs1 != `ZERO_REG); //&& opa_rs;
	assign MEM_dest_equal_rs2 = (if_id_packet_in.MEM_dest_reg_idx == if_id_packet_in.inst.r.rs2) && !MEM_inst_read_only && (if_id_packet_in.inst.r.rs2 != `ZERO_REG); //&& opb_rs;
	always_comb begin
		casez(if_id_packet_in.inst)
			`RV32_LB, `RV32_LH, `RV32_LW, `RV32_LBU, `RV32_LHU, `RV32_SB, `RV32_SH, `RV32_SW: inst_use_mem = 1;
			default: inst_use_mem = 0;
		endcase
		casez(if_id_packet_in.EX_inst)
			`RV32_LB, `RV32_LH, `RV32_LW, `RV32_LBU, `RV32_LHU: EX_inst_load = 1;
			default: EX_inst_load = 0;
		endcase
		casez(if_id_packet_in.EX_inst)
			`RV32_JAL, `RV32_JALR, `RV32_BEQ, `RV32_BNE, `RV32_BLT, `RV32_BGE, `RV32_BLTU, `RV32_BGEU, `RV32_SB, `RV32_SH, `RV32_SW: EX_inst_read_only = 1;
			default: EX_inst_read_only = 0;
		endcase
		casez(if_id_packet_in.MEM_inst)
			`RV32_JAL, `RV32_JALR, `RV32_BEQ, `RV32_BNE, `RV32_BLT, `RV32_BGE, `RV32_BLTU, `RV32_BGEU, `RV32_SB, `RV32_SH, `RV32_SW: MEM_inst_read_only = 1;
			default: MEM_inst_read_only = 0;
		endcase
	end
	/*
	assign EX_inst_use_mem = ((if_id_packet_in.EX_inst == `RV32_LB) |
							 (if_id_packet_in.EX_inst == `RV32_LH) |
							 (if_id_packet_in.EX_inst == `RV32_LW) |
							 (if_id_packet_in.EX_inst == `RV32_LBU) |
							 (if_id_packet_in.EX_inst == `RV32_LHU) |
							 (if_id_packet_in.EX_inst == `RV32_SB) |
							 (if_id_packet_in.EX_inst == `RV32_SH) |
							 (if_id_packet_in.EX_inst == `RV32_SW)) ? 1 : 0;
	assign EX_inst_load = ((if_id_packet_in.EX_inst == `RV32_LB) |
							 (if_id_packet_in.EX_inst == `RV32_LH) |
							 (if_id_packet_in.EX_inst == `RV32_LW) |
							 (if_id_packet_in.EX_inst == `RV32_LBU) |
							 (if_id_packet_in.EX_inst == `RV32_LHU)) ? 1 : 0;
	assign EX_inst_read_only = ((if_id_packet_in.EX_inst == `RV32_JAL) |
							 (if_id_packet_in.EX_inst == `RV32_JALR) |
							 (if_id_packet_in.EX_inst == `RV32_BEQ) |
							 (if_id_packet_in.EX_inst == `RV32_BNE) |
							 (if_id_packet_in.EX_inst == `RV32_BLT) |
							 (if_id_packet_in.EX_inst == `RV32_BGE) |
							 (if_id_packet_in.EX_inst == `RV32_BLTU) |
							 (if_id_packet_in.EX_inst == `RV32_BGEU) |
							 (if_id_packet_in.EX_inst == `RV32_SB) |
							 (if_id_packet_in.EX_inst == `RV32_SH) |
							 (if_id_packet_in.EX_inst == `RV32_SW)) ? 1 : 0;
	assign MEM_inst_read_only = ((if_id_packet_in.MEM_inst == `RV32_JAL) |
							 (if_id_packet_in.MEM_inst == `RV32_JALR) |
							 (if_id_packet_in.MEM_inst == `RV32_BEQ) |
							 (if_id_packet_in.MEM_inst == `RV32_BNE) |
							 (if_id_packet_in.MEM_inst == `RV32_BLT) |
							 (if_id_packet_in.MEM_inst == `RV32_BGE) |
							 (if_id_packet_in.MEM_inst == `RV32_BLTU) |
							 (if_id_packet_in.MEM_inst == `RV32_BGEU) |
							 (if_id_packet_in.MEM_inst == `RV32_SB) |
							 (if_id_packet_in.MEM_inst == `RV32_SH) |
							 (if_id_packet_in.MEM_inst == `RV32_SW)) ? 1 : 0;
	*/
	//assign opa_rs = local_id_packet_out.opa_select == OPA_IS_RS1;
	//assign opb_rs = local_id_packet_out.opb_select == OPB_IS_RS2;
	
	assign local_id_packet_out.inst = ( if_id_packet_in.inst == 0 ) ? `NOP : if_id_packet_in.inst;
	
	/*
	assign local_halt_id_packet_out.NPC = if_id_packet_in.NPC;
	assign local_halt_id_packet_out.PC = if_id_packet_in.PC;
	assign local_halt_id_packet_out.rs1_value = 0;
	assign local_halt_id_packet_out.rs2_value = 0;
	assign local_halt_id_packet_out.opa_select = OPA_IS_RS1;
	assign local_halt_id_packet_out.opb_select = OPB_IS_RS2;
	assign local_halt_id_packet_out.inst = `NOP;
	assign local_halt_id_packet_out.dest_reg_idx = `ZERO_REG;
	assign local_halt_id_packet_out.alu_func = ALU_ADD;
	assign local_halt_id_packet_out.rd_mem = `FALSE;
	assign local_halt_id_packet_out.wr_mem = `FALSE;
	assign local_halt_id_packet_out.cond_branch = `FALSE;
	assign local_halt_id_packet_out.uncond_branch = `FALSE;
	assign local_halt_id_packet_out.halt = `FALSE;
	assign local_halt_id_packet_out.illegal = `FALSE;
	assign local_halt_id_packet_out.csr_op = `FALSE;
	assign local_halt_id_packet_out.valid = `FALSE;
	//assign local_halt_id_packet_out.forward = WB_EX_A_HALT;
	assign local_halt_id_packet_out.s_hazard = local_id_packet_out.s_hazard;
	assign local_halt_id_packet_out.MEM_value = 0;
	assign local_halt_id_packet_out.WB_value = 0;
	*/
	

	always_comb begin
				
		local_halt_id_packet_out.NPC = if_id_packet_in.NPC;
		local_halt_id_packet_out.PC = if_id_packet_in.PC;
		local_halt_id_packet_out.rs1_value = 0;
		local_halt_id_packet_out.rs2_value = 0;
		local_halt_id_packet_out.opa_select = OPA_IS_RS1;
		local_halt_id_packet_out.opb_select = OPB_IS_RS2;
		local_halt_id_packet_out.inst = `NOP;
		local_halt_id_packet_out.dest_reg_idx = `ZERO_REG;
		local_halt_id_packet_out.alu_func = ALU_ADD;
		local_halt_id_packet_out.rd_mem = `FALSE;
		local_halt_id_packet_out.wr_mem = `FALSE;
		local_halt_id_packet_out.cond_branch = `FALSE;
		local_halt_id_packet_out.uncond_branch = `FALSE;
		local_halt_id_packet_out.halt = `FALSE;
		local_halt_id_packet_out.illegal = `FALSE;
		local_halt_id_packet_out.csr_op = `FALSE;
		local_halt_id_packet_out.valid = `FALSE;
		local_halt_id_packet_out.s_hazard = local_id_packet_out.s_hazard;
		local_halt_id_packet_out.MEM_value = 0;
		local_halt_id_packet_out.WB_value = 0;
		
		local_halt_id_packet_out.forward = N_FORWARD;
		local_id_packet_out.forward = N_FORWARD;
			
		if (inst_use_mem) begin
			local_id_packet_out.s_hazard = STRUCTURAL_HAZARD;
		end
		else begin
			local_id_packet_out.s_hazard = N_STRUCTURAL_HAZARD;
		end

		if (EX_inst_load) begin
			if (EX_dest_equal_rs1) begin
				local_halt = 1'b1;
				local_halt_id_packet_out.forward = WB_EX_A_HALT;
				/*
				local_halt_id_packet_out = '{
					if_id_packet_in.NPC,
					if_id_packet_in.PC,
					0,
					0,
					OPA_IS_RS1,
					OPB_IS_RS2,
					`NOP,
					`ZERO_REG,
					ALU_ADD,
					`FALSE,
					`FALSE,
					`FALSE,
					`FALSE,
					`FALSE,
					`FALSE,
					`FALSE,
					`FALSE, // valid
					WB_EX_A_HALT,
					local_id_packet_out.s_hazard,
					0,
					0
				};
				*/
			end
			else if (EX_dest_equal_rs2) begin
				local_halt = 1'b1;
				local_halt_id_packet_out.forward = WB_EX_B_HALT;
				/*
				local_halt_id_packet_out = '{
					if_id_packet_in.NPC,
					if_id_packet_in.PC,
					0,
					0,
					OPA_IS_RS1,
					OPB_IS_RS2,
					`NOP,
					`ZERO_REG,
					ALU_ADD,
					`FALSE,
					`FALSE,
					`FALSE,
					`FALSE,
					`FALSE,
					`FALSE,
					`FALSE,
					`FALSE, // valid
					WB_EX_B_HALT,
					local_id_packet_out.s_hazard,
					0,
					0
				};
				*/
			end
			else if (MEM_dest_equal_rs1 && MEM_dest_equal_rs2) begin
				local_halt = 1'b0;
				local_id_packet_out.forward = WB_A_WB_B;
				local_halt_id_packet_out.forward = N_FORWARD;
			end
			else if (MEM_dest_equal_rs1 && !MEM_dest_equal_rs2) begin
				local_halt = 1'b0;
				local_id_packet_out.forward = WB_EX_A;
				local_halt_id_packet_out.forward = N_FORWARD;
			end
			else if (MEM_dest_equal_rs2 && !MEM_dest_equal_rs1) begin
				local_halt = 1'b0;
				local_id_packet_out.forward = WB_EX_B;
				local_halt_id_packet_out.forward = N_FORWARD;
			end
			else begin
				local_halt = 1'b0;
				local_id_packet_out.forward = N_FORWARD;
				local_halt_id_packet_out.forward = N_FORWARD;
			end
		end
		else begin
			local_halt_id_packet_out.forward = N_FORWARD;
			if (EX_dest_equal_rs1 && EX_dest_equal_rs2) begin
				local_halt = 1'b0;
				local_id_packet_out.forward = MEM_A_MEM_B;
			end
			else if (EX_dest_equal_rs1 && MEM_dest_equal_rs2) begin
				local_halt = 1'b0;
				local_id_packet_out.forward = MEM_A_WB_B;
			end
			else if (EX_dest_equal_rs2 && MEM_dest_equal_rs1) begin
				local_halt = 1'b0;
				local_id_packet_out.forward = MEM_B_WB_A;
			end 
			else if (MEM_dest_equal_rs1 && MEM_dest_equal_rs2) begin
				local_halt = 1'b0;
				local_id_packet_out.forward = WB_A_WB_B;
			end
			else if (EX_dest_equal_rs1) begin
				local_halt = 1'b0;
				local_id_packet_out.forward = MEM_EX_A;
			end
			else if (EX_dest_equal_rs2) begin
				local_halt = 1'b0;
				local_id_packet_out.forward = MEM_EX_B;
			end
			else if (MEM_dest_equal_rs1) begin
				local_halt = 1'b0;
				local_id_packet_out.forward = WB_EX_A;
			end
			else if (MEM_dest_equal_rs2) begin
				local_halt = 1'b0;
				local_id_packet_out.forward = WB_EX_B;
			end
			else begin
				local_halt = 1'b0;
				local_id_packet_out.forward = N_FORWARD;
			end
		end

		/*
		if (if_id_packet_in.EX_dest_reg_idx == if_id_packet_in.inst.r.rs1) begin
			//id_packet_out.forward = MEM_EX_A;
			casez (if_id_packet_in.EX_inst)
				`RV32_LB, `RV32_LH, `RV32_LW, `RV32_LBU, `RV32_LHU: begin
					local_halt = 1'b1;
					local_halt_id_packet_out = '{
						if_id_packet_in.NPC,
						if_id_packet_in.PC,
						0,
						0,
						OPA_IS_RS1,
						OPB_IS_RS2,
						`NOP,
						`ZERO_REG,
						ALU_ADD,
						`FALSE,
						`FALSE,
						`FALSE,
						`FALSE,
						`FALSE,
						`FALSE,
						`FALSE,
						`TRUE, // valid
						WB_EX_A_HALT,
						local_id_packet_out.s_hazard,
						0,
						0
					};
				end
				default: begin
					local_halt = 1'b0;
					local_id_packet_out.forward = MEM_EX_A;
					if (if_id_packet_in.MEM_dest_reg_idx == if_id_packet_in.inst.r.rs2) begin
						local_id_packet_out.forward = WB_EX_B;
					end
				end
			endcase
		end
		else if (if_id_packet_in.EX_dest_reg_idx == if_id_packet_in.inst.r.rs2) begin
			casez (if_id_packet_in.EX_inst)
				`RV32_LB, `RV32_LH, `RV32_LW, `RV32_LBU, `RV32_LHU: begin
					local_halt = 1'b1;
					local_halt_id_packet_out = '{
						if_id_packet_in.NPC,
						if_id_packet_in.PC,
						0,
						0,
						OPA_IS_RS1,
						OPB_IS_RS2,
						`NOP,
						`ZERO_REG,
						ALU_ADD,
						`FALSE,
						`FALSE,
						`FALSE,
						`FALSE,
						`FALSE,
						`FALSE,
						`FALSE,
						`TRUE, // valid
						WB_EX_B_HALT,
						local_id_packet_out.s_hazard,
						0,
						0
					};
				end
				default: begin
					local_halt = 1'b0;
					local_id_packet_out.forward = MEM_EX_B;
				end
			endcase
		end
		else if (if_id_packet_in.MEM_dest_reg_idx == if_id_packet_in.inst.r.rs1) begin
			local_halt = 1'b0;
			local_id_packet_out.forward = WB_EX_A;
		end
		else if (if_id_packet_in.MEM_dest_reg_idx == if_id_packet_in.inst.r.rs2) begin
			local_halt = 1'b0;
			local_id_packet_out.forward = WB_EX_B;
		end
		else begin
			local_halt = 1'b0;
			local_id_packet_out.forward = N_FORWARD;
		end
		*/
	end

	assign id_packet_out = local_halt ? local_halt_id_packet_out : local_id_packet_out;
   
endmodule // module id_stage
