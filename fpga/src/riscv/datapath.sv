`include "riscv/datapath.vh"

/**
 * Register file. Writes sync. (pos. edge). Reads async.
 *
 * @param addr1 Address of source reg. 1
 * @param addr2 Address of source reg. 2
 * @param addr3 Address of dst. reg.
 * @param wd3 Value to write in the reg. whose address is @p addr3.
 * @param we Write enable. If 0, @p addr3 and @p wd3 are ignored. If 1,
 *           the data in @p wd3 will be written in the next clk. pos. edge
 *
 * @param rd1 Value of the regiser whose address is @p addr1
 * @param rd2 Value of the regiser whose address is @p addr2
 * @param clk
 */
module regfile(
    input   wire [4:0]  addr1,
    input   wire [4:0]  addr2,
    input   wire [4:0]  addr3,
    input   wire [31:0] wd3,
    input   wire        we,
    output  wire [31:0] rd1,
    output  wire [31:0] rd2,
    input   wire        clk
);
    reg [31:0] _reg [32];

    always_ff @(posedge clk) begin
        if (we) begin
            if (addr3 != 5'b00) begin
                _reg[addr3] <= wd3;
            end
        end
    end

    assign rd1 = addr1 == 5'b0 ? 32'b0 : _reg[addr1];
    assign rd2 = addr2 == 5'b0 ? 32'b0 : _reg[addr2];
endmodule

/**
 * CPU datapath.
 *
 * @param instr Instruction to be executed.
 * @param read_data Data read from memory.
 * @param reg_we Register write enable. Synchronous (pos. edge)
 * @param imm_src Type of immediate depending on the instruction.
 *                  0 = I-Type instruction
 *                  1 = S-Type instruction
 *
 * @param alu_ctrl Operation that the ALU will perform. See alu.vh.
 * @param alu_src ALU's second operand source. See datapath.vh.
 * @param result_src Source of the result to be written in the reg. file.
 *                   See datapath.vh.
 *
 * @param alu_out ALU output.
 * @param write_data Data to be written in memory.
 * @param rst Reset.
 * @param clk Clock signal
 */
module datapath(
    input   wire [31:0] instr,

    input   wire [31:0] read_data,
    input   wire        reg_we,

    input   wire [1:0]  imm_src,
    input   wire [1:0]  alu_ctrl,
    input   wire        alu_src,
    input   wire        result_src,
    input   wire        pc_src,

    output  wire [31:0] pc,

    output  wire [31:0] alu_out,
    output  wire [31:0] write_data,

    input   wire        rst,
    input   wire        clk
);
    wire [31:0] pc_next, pc_plus_4, pc_plus_off;
    dff pc_ff(pc_next, pc, rst, clk);

    assign pc_plus_4 = pc + 4;
    assign pc_plus_off = pc + ext_imm;
    assign pc_next = pc_src == 1'b1 ? pc_plus_off : pc_plus_4;


    wire [31:0] srca;
    wire [31:0] reg_wr_data;
    regfile rf(instr[19:15], instr[24:20], instr[11:7], reg_wr_data, reg_we, srca, write_data, clk);

    assign reg_wr_data = result_src == res_src_read_data ? read_data : alu_out;


    wire [31:0] ext_imm;
    extend ext(instr, imm_src, ext_imm);


    wire [3:0] alu_flags;
    wire [31:0] srcb;
    alu alu0(srca, srcb, alu_ctrl, alu_out, alu_flags);

    assign srcb = alu_src == alu_src_ext_imm ? ext_imm : write_data;
endmodule