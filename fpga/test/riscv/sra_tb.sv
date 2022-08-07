`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "sra_tb.vcd"
`endif

module sra_tb;
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
        $dumpvars(1, sra_tb);

        dut.rv.dp.rf._reg[4] = 32'b00;
        dut.rv.dp.rf._reg[5] = 32'h08;
        dut.rv.dp.rf._reg[6] = 32'd2;
        dut.rv.dp.rf._reg[7] = 32'hfffffff8;
        dut.rv.dp.rf._reg[8] = 32'd2;

        `SET_MEM_I(0, 32'h4062d233);   // sra x4, x5, x6
        `SET_MEM_I(1, 32'h4083d233);   // sra x4, x7, x8

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        `WAIT_INIT_CYCLES(clk);
        `WAIT_CLKS(clk, `R_I_CYC) assert(dut.rv.dp.rf._reg[4] === 32'd8 >> 2);
        `WAIT_CLKS(clk, `R_I_CYC) assert(dut.rv.dp.rf._reg[4] === 32'hfffffffe);

        #5;
        $finish;
    end

endmodule
