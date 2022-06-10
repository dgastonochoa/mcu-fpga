`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`ifndef VCD
    `define VCD "lbu_tb.vcd"
`endif

module lbu_tb;
    wire reg_we, mem_we;
    res_src_e res_src;
    pc_src_e pc_src;
    alu_src_e alu_src;
    imm_src_e imm_src;
    alu_op_e alu_ctrl;

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

    //
    // Debug signals
    //
    wire [31:0] x6, x9;
    assign x6 = dut.dp.rf._reg[6];
    assign x9 = dut.dp.rf._reg[9];


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, lbu_tb);

        // Set register init. vals
        dut.dp.rf._reg[0] = 32'd0;
        dut.dp.rf._reg[6] = 32'd0;
        dut.dp.rf._reg[9] = 32'd8;

        // Set mem. init. vals
        dut.data_mem._mem._mem[1] = 32'hdeadc0de;
        dut.data_mem._mem._mem[2] = 32'hdeadbeef;
        dut.data_mem._mem._mem[3] = 32'hc001c0de;

        // Load words with different addresses
        // Last instr. is to try to load word into x0
        dut.instr_mem._mem._mem[0] = 32'hffc4c303;           // lbu x6, -4(x9)
        dut.instr_mem._mem._mem[1] = 32'h0004c303;           // lbu x6, 0(x9)
        dut.instr_mem._mem._mem[2] = 32'h0044c303;           // lbu x6, 4(x9)
        dut.instr_mem._mem._mem[3] = 32'h0044c003;           // lbu x0, 4(x9)

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        #11 assert(dut.dp.rf._reg[6] === 32'h000000de);
        #20 assert(dut.dp.rf._reg[6] === 32'h000000ef);
        #20 assert(dut.dp.rf._reg[6] === 32'h000000de);
        #20 assert(dut.dp.rf._reg[0] === 32'h00000000);

        #20;
        $finish;
    end
endmodule