`include "errno.svh"
`include "mem.svh"
`include "synth.svh"

/**
 * RISC-V top module. Connects the RISC-V CPU with external
 * memories.
 *
 * @param reg_we For debugging purposes. Register write-enable.
 * @param mem_we For debugging purposes. Memory write-enable.
 * @param imm_src For debugging purposes. @see{datapath.svh}
 * @param alu_op For debugging purposes. @see{datapath.svh}
 * @param alu_src For debugging purposes. @see{datapath.svh}
 * @param res_src For debugging purposes. @see{datapath.svh}
 * @param pc_src For debugging purposes. @see{datapath.svh}
 * @param instr For debugging purposes. Instruction being processed.
 * @param alu_out For debugging purposes. ALU result.
 * @param mem_rd_data For debugging purposes. Data read from mem. (if any)
 * @param mem_wd_data For debugging purposes. Data written to mem. (if any)
 * @param pc For debugging purposes. Program counter.
 *
 * @param tm Test-mode signal. Enables test mode, which disconnects the data
 *           memory from the CPU and connects it to the other test-mode signals,
 *           so it can be accessed from outside.
 *
 * @param tm_d_addr Test-mode signal. Data memory address.
 * @param tm_d_wd Test-mode signal. Data memory data to write (if any).
 * @param tm_d_we Test-mode signal. Data memory write enable.
 * @param tm_d_dt Test-mode signal. Data memory data type (to be read/write).
 * @param tm_d_rd Test-mode signal. Data memory data to read (if any).
 * @param tm_d_err Test-mode signal. Data memory error.
 *
 * @param rst Reset.
 * @param clk Clock.
 */
module riscv #(parameter DEFAULT_INSTR = 0) (
    // Signals exposed for debugging purposes
    output  wire        reg_we,
    output  wire        mem_we,
    output  imm_src_e   imm_src,
    output  alu_op_e    alu_op,
    output  alu_src_e   alu_src,
    output  res_src_e   res_src,
    output  pc_src_e    pc_src,
    output  wire [31:0] instr,
    output  wire [31:0] alu_out,
    output  wire [31:0] mem_rd_data,
    output  wire [31:0] mem_wd_data,
    output  wire [31:0] pc,
    ///////

    input   wire        tm,
    input   wire [31:0] tm_d_addr,
    input   wire [31:0] tm_d_wd,
    input   wire        tm_d_we,
    input   mem_dt_e    tm_d_dt,
    output  wire [31:0] tm_d_rd,
    output  errno_e     tm_d_err,

    input   wire        rst,
    input   wire        clk
);
    wire [3:0] alu_flags;

    datapath dp(
        instr,
        mem_rd_data,
        reg_we,
        imm_src,
        alu_op,
        alu_src,
        res_src, pc_src,
        pc,
        alu_out,
        alu_flags,
        mem_wd_data,
        rst,
        clk
    );

    controller co(
        instr,
        alu_flags,
        reg_we,
        mem_we,
        alu_src,
        res_src,
        pc_src,
        imm_src,
        alu_op
    );

    mem_dt_e dt_data;
    errno_e err_data;

    assign dt_data = `CAST(mem_dt_e, res_src[3:1]);


    //
    // Data memory logic (normal and test modes)
    //
    wire [31:0] d_addr, d_wd;
    wire d_we;
    mem_dt_e d_dt;

    wire [31:0] d_rd;
    errno_e d_err;

    assign d_addr       = (tm == 1'b0 ? alu_out : tm_d_addr);
    assign d_wd         = (tm == 1'b0 ? mem_wd_data : tm_d_wd);
    assign d_we         = (tm == 1'b0 ? mem_we : tm_d_we);
    assign d_dt         = (tm == 1'b0 ? dt_data : tm_d_dt);

    assign mem_rd_data  = (tm == 1'b0 ? d_rd : 32'h00);
    assign err_data     = (tm == 1'b0 ? d_err : ENONE);

    assign tm_d_rd      = (tm == 1'b0 ? 32'h00 : d_rd);
    assign tm_d_err     = (tm == 1'b0 ? ENONE : d_err);

    mem #(.N(256)) data_mem(d_addr, d_wd, d_we, d_dt, d_rd, d_err, clk);


    //
    // Instruction memory logic
    //
    mem_dt_e dt_instr;
    errno_e err_instr;

    assign dt_instr = MEM_DT_WORD;

    mem #(.N(512), .INIT_VALS(DEFAULT_INSTR)) instr_mem(
        pc, 32'b00, 1'b0, dt_instr, instr, err_instr, clk);
endmodule

/**
 * RISC-V top module. Connects the RISC-V CPU with external
 * memories.
 */
module riscv_legacy(
    // Signals exposed for debugging purposes
    output  wire        reg_we,
    output  wire        mem_we,
    output  imm_src_e   imm_src,
    output  alu_op_e    alu_op,
    output  alu_src_e   alu_src,
    output  res_src_e   res_src,
    output  pc_src_e    pc_src,
    output  wire [31:0] instr,
    output  wire [31:0] alu_out,
    output  wire [31:0] mem_rd_data,
    output  wire [31:0] mem_wd_data,
    output  wire [31:0] pc,
    ///////

    input   wire        rst,
    input   wire        clk
);
    wire tm, tm_d_we;
    wire [31:0] tm_d_addr, tm_d_wd, tm_d_rd;
    mem_dt_e tm_d_dt;
    errno_e tm_d_err;

    assign tm = 1'b0;
    assign tm_d_addr = 32'h00;
    assign tm_d_wd = 32'h00;
    assign tm_d_we = 1'b0;
    assign tm_d_dt = MEM_DT_WORD;

    riscv rv(
        reg_we,
        mem_we,
        imm_src,
        alu_op,
        alu_src,
        res_src,
        pc_src,
        instr,
        alu_out,
        mem_rd_data,
        mem_wd_data,
        pc,

        tm,
        tm_d_addr,
        tm_d_wd,
        tm_d_we,
        tm_d_dt,
        tm_d_rd,
        tm_d_err,

        rst,
        clk
    );
endmodule