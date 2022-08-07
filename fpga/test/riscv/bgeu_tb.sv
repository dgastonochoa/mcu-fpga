`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "bltu_tb.vcd"
`endif

module bltu_tb;
    reg clk = 0, rst;

    always #10 clk = ~clk;


    wire reg_we, mem_we;
    res_src_e res_src;
    pc_src_e pc_src;
    alu_src_e alu_src;
    imm_src_e imm_src;
    alu_op_e alu_ctrl;

    wire [31:0] pc, alu_out, wdata;
    wire [31:0] instr, mem_rd_data, mem_wd_data;

    riscv_legacy dut(
        reg_we,
        mem_we,
        imm_src,
        alu_ctrl,
        alu_src,
        res_src, pc_src,
        instr,
        alu_out,
        mem_rd_data,
        mem_wd_data,
        pc,
        rst,
        clk
    );

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, bltu_tb);

        dut.rv.dp.rf._reg[0] = 32'd00;
        dut.rv.dp.rf._reg[4] = 32'd1;
        dut.rv.dp.rf._reg[5] = 32'hffffffff;


        `SET_MEM_I(0, 32'h02407a63);  // bgeu    x0, x4, .L2
        `SET_MEM_I(1, 32'h00007263);  // bgeu    x0, x0, .L4
        `SET_MEM_I(2, 32'h00027863);  // bgeu    x4, x0, .L1
        `SET_MEM_I(3, 32'h00000013);  // nop
        `SET_MEM_I(4, 32'h00000013);  // nop
        `SET_MEM_I(5, 32'h00000013);  // nop
        `SET_MEM_I(6, 32'h00507e63);  // bgeu    x0, x5, .L2
        `SET_MEM_I(7, 32'h0002f863);  // bgeu    x5, x0, .L5
        `SET_MEM_I(8, 32'h00000013);  // nop
        `SET_MEM_I(9, 32'h00000013);  // nop
        `SET_MEM_I(10, 32'h00000013);  // nop
        `SET_MEM_I(11, 32'h00407463);  // bgeu    x0, x4, .L2
        `SET_MEM_I(12, 32'hfc52f8e3);  // bgeu    x5, x5, .L3
        `SET_MEM_I(13, 32'h00000013);  // nop
        `SET_MEM_I(14, 32'h00000013);  // nop
        `SET_MEM_I(15, 32'h00000013);  // nop

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 32'd00);
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 32'd4);
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 32'd8);
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 32'd24);
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 32'd28);
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 32'd44);
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 32'd48);
        `WAIT_CLKS(clk, `B_I_CYC) assert(pc === 32'd00);

        #5;
        $finish;
    end

endmodule
