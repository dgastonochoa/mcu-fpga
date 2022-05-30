`timescale 10ps/1ps

`include "alu.vh"
`include "riscv/datapath.vh"

`ifndef VCD
    `define VCD "slt_tb.vcd"
`endif

module slt_tb;
    wire reg_we, mem_we, alu_src, pc_src;
    wire [1:0] imm_src, res_src;
    wire [3:0] alu_ctrl;

    wire [31:0] pc, alu_out, wdata;
    wire [31:0] instr, mem_rd_data, mem_wd_data;

    reg clk = 0, rst;

    riscv_single_top dut(
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

    always #10 clk = ~clk;


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, slt_tb);

        dut.dp.rf._reg[4] = 32'b00;

        dut.dp.rf._reg[5] = 32'h08;
        dut.dp.rf._reg[6] = 32'd2;

        dut.dp.rf._reg[7] = 32'hfffffff8;
        dut.dp.rf._reg[8] = 32'd2;

        dut.dp.rf._reg[9] = 32'd2;
        dut.dp.rf._reg[10] = 32'd4;

        dut.instr_mem._mem[0] = 32'h0062a233;   // slt     x4, x5, x6
        dut.instr_mem._mem[1] = 32'h0083a233;   // slt     x4, x7, x8
        dut.instr_mem._mem[2] = 32'h00a4a233;   // slt     x4, x9, x10


        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        #20 assert(dut.dp.rf._reg[4] === 32'd0);
        #20 assert(dut.dp.rf._reg[4] === 32'd1);
        #20 assert(dut.dp.rf._reg[4] === 32'd1);

        #5;
        $finish;
    end

endmodule