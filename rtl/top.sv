// --------------------------------------------------------
// Top-Level RISC-V Processor (Single-Cycle)
// --------------------------------------------------------
// Debug-visibility note: `top` only exposes clk/reset_n at its ports, so
// with nothing driven to an external pin, Vivado's synthesis has no reason
// to keep ANY of this internal logic -- it will optimize the whole core
// away as unused unless something forces retention. The (* mark_debug *)
// attributes added below to pc/instruction/opcode/rd_addr/wr_data/
// rf_wr_en/alu_res/branch_taken do exactly that, and as a side effect
// they're also exactly the signals the ILA needs to watch the core
// actually execute instructions: pc+instruction show what's running each
// cycle, and rd_addr+wr_data+rf_wr_en show what gets written to the
// register file and when (e.g. rf_wr_en=1, rd_addr=3, wr_data=12 is the
// `add x3,x1,x2` from the add-two-numbers test retiring).
import risc_pkg::*;

module top #(
  parameter RESET_PC = 32'h0000
)(
  input logic clk,
  input logic reset_n,
  
    // GPIO -- bit0/bit1 drive the KR260's two onboard LEDs
  output logic [1:0] led_out
);

  // --------------------------------------------------------
  // Instruction Memory Interface
  // --------------------------------------------------------
  logic        imem_req;
  logic [31:0] imem_addr;
  logic [31:0] imem_data;

  // --------------------------------------------------------
  // Data Memory Interface
  // --------------------------------------------------------
  logic        dmem_req;
  logic        dmem_wr_en;
  mem_size_t   dmem_size;
  logic        dmem_zero_extend;
  logic [31:0] dmem_addr;
  logic [31:0] dmem_wr_data;
  logic [31:0] dmem_rd_data;

  // --------------------------------------------------------
  // Core Datapath Signals
  // --------------------------------------------------------
  (* mark_debug = "true" *) logic [31:0] pc;
  logic [31:0] next_pc, next_seq_pc;
  logic        pc_sel, reset_seen;

  (* mark_debug = "true" *) logic [31:0] instruction;
  (* mark_debug = "true" *) logic [6:0]  opcode;
  logic [2:0]  funct3;
  logic [6:0]  funct7;

  logic [4:0]  rs1_addr, rs2_addr;
  (* mark_debug = "true" *) logic [4:0]  rd_addr;
  logic [31:0] rs1_data, rs2_data;
  (* mark_debug = "true" *) logic [31:0] wr_data;
  logic [31:0] immediate;

  logic        r_type, i_type, s_type, b_type, u_type, j_type;

  logic [31:0] alu_a, alu_b;
  (* mark_debug = "true" *) logic [31:0] alu_res;
  alu_op_t     alu_op;

  wb_src_t     rf_wr_data_sel;
  (* mark_debug = "true" *) logic        rf_wr_en;
  logic        op1_sel, op2_sel;
  (* mark_debug = "true" *) logic        branch_taken;

  // --------------------------------------------------------
  // Reset and PC logic
  // --------------------------------------------------------
  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n)
      reset_seen <= 1'b0;
    else
      reset_seen <= 1'b1;
  end

  assign next_seq_pc = pc + 32'd4;
  assign next_pc     = (branch_taken | pc_sel) ? {alu_res[31:1], 1'b0} : next_seq_pc;

  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n)
      pc <= RESET_PC;
    else if (reset_seen)
      pc <= next_pc;
  end


  // --------------------------------------------------------
  // Instruction Memory
  // --------------------------------------------------------
  instruction_memory u_instruction_memory (
    .imem_req     			(imem_req),
    .imem_addr    			(imem_addr),
    .imem_data    			(imem_data)
  );

  // --------------------------------------------------------
  // Fetch
  // --------------------------------------------------------
  fetch u_fetch (
    .clk               (clk),
    .reset_n           (reset_n),
    .pc     		   (pc),
    .imem_req    	   (imem_req),
    .imem_addr   	   (imem_addr),
    .imem_data         (imem_data),
    .instruction   	   (instruction)
  );

  // --------------------------------------------------------
  // Decode
  // --------------------------------------------------------
  decode u_decode (
    .instruction     (instruction),
    .rs1_addr        (rs1_addr),
    .rs2_addr        (rs2_addr),
    .rd_addr         (rd_addr),
    .opcode          (opcode),
    .funct3       	 (funct3),
    .funct7       	 (funct7),
    .r_type  	 	 (r_type),
    .i_type 		 (i_type),
    .s_type 		 (s_type),
    .b_type 		 (b_type),
    .u_type  		 (u_type),
    .j_type  	 	 (j_type),
    .immediate    	 (immediate)
  );

  // --------------------------------------------------------
  // Register File
  // --------------------------------------------------------
   always_comb begin
	 case (rf_wr_data_sel)
	   WB_SRC_ALU: wr_data = alu_res;
	   WB_SRC_MEM: wr_data = dmem_rd_data;
	   WB_SRC_IMM: wr_data = immediate;
	   WB_SRC_PC : wr_data = next_seq_pc;
	 endcase
   end


  register_file u_register_file (
    .clk        	 (clk),
    .reset_n    	 (reset_n),
    .rs1_addr  		 (rs1_addr),
    .rs2_addr 		 (rs2_addr),
    .rd_addr  		 (rd_addr),
    .rf_wr_en        (rf_wr_en),
    .wr_data     	 (wr_data),
    .rs1_data  		 (rs1_data),
    .rs2_data  		 (rs2_data)
  );

  // --------------------------------------------------------
  // Register-file debug taps -- hierarchical references into
  // u_register_file's internal `regs` array. These aren't real
  // signals in this module, just new wires that happen to be
  // driven by a hierarchical path, but mark_debug on them is
  // enough to force Vivado to keep them and offer them in the
  // Set Up Debug wizard, exactly like pc/instruction/etc. above.
  // Add/remove lines here for whichever registers you want to
  // watch continuously (not just the cycle they're written).
  // --------------------------------------------------------
  (* mark_debug = "true" *) wire [31:0] dbg_x1 = u_register_file.regs[1];
  (* mark_debug = "true" *) wire [31:0] dbg_x2 = u_register_file.regs[2];
  (* mark_debug = "true" *) wire [31:0] dbg_x3 = u_register_file.regs[3];

  // --------------------------------------------------------
  // Control Unit
  // --------------------------------------------------------
  control u_control (
  .r_type				(r_type),
  .i_type				(i_type),
  .s_type				(s_type),
  .b_type				(b_type),
  .u_type				(u_type),
  .j_type				(j_type),
  .funct3				(funct3),
  .funct7				(funct7),
  .opcode				(opcode),
  .pc_sel           	(pc_sel),
  .op1_sel          	(op1_sel),
  .op2_sel          	(op2_sel),
  .alu_op          		(alu_op),
  .rf_wr_data_sel 		(rf_wr_data_sel),
  .dmem_req         	(dmem_req),
  .dmem_size        	(dmem_size),
  .dmem_wr_en      	    (dmem_wr_en),
  .dmem_zero_extend 	(dmem_zero_extend),
  .rf_wr_en       	    (rf_wr_en)
  );

  // --------------------------------------------------------
  // Branch Control
  // --------------------------------------------------------
  branch_control u_branch_control (
    .opr_a        (rs1_data),
    .opr_b        (rs2_data),
    .is_b_type    (b_type),
    .funct3       (funct3),
    .branch_taken (branch_taken)
  );

  // --------------------------------------------------------
  // ALU
  // --------------------------------------------------------
  assign alu_a = op1_sel ? pc     		  : rs1_data;
  assign alu_b = op2_sel ? immediate      : rs2_data;

  alu u_alu (
    .alu_a      (alu_a),
    .alu_b	    (alu_b),
    .alu_op     (alu_op),
    .alu_res    (alu_res)
  );

  // --------------------------------------------------------
  // Data Memory
  // --------------------------------------------------------
  // We dont need to use assign but its easier
  // becouse now we give meaning to the Input
  assign dmem_addr     = alu_res;
  assign dmem_wr_data  = rs2_data;

  mem_bus u_mem_bus (
    .clk               (clk),
    .reset_n           (reset_n),
    .dmem_req          (dmem_req),
    .dmem_wr_en        (dmem_wr_en),
    .dmem_data_size    (dmem_size),
    .dmem_addr         (dmem_addr),
    .dmem_wr_data      (dmem_wr_data),
    .dmem_zero_extend  (dmem_zero_extend),
    .dmem_rd_data      (dmem_rd_data),
    .led_out           (led_out)
  );

endmodule