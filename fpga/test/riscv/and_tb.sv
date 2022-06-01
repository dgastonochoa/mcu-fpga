`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`ifndef VCD
    `define VCD "and_tb.vcd"
`endif

module and_tb;
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

    wire [31:0] addr1, addr3;
    assign addr1 = dut.dp.rf.addr1;
    assign addr3 = dut.dp.rf.addr3;

    wire [31:0] mem5, mem10, mem11;
    assign mem5 = dut.data_mem._mem[5];
    assign mem10 = dut.data_mem._mem[10];
    assign mem11 = dut.data_mem._mem[11];


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, and_tb);

        dut.dp.rf._reg[0] = 32'd00;
        dut.dp.rf._reg[4] = 32'd00;
        dut.dp.rf._reg[5] = 32'h01;
        dut.dp.rf._reg[6] = 32'hff;

        dut.instr_mem._mem[0] = 32'h00627033;           // and x0, x4, x6
        dut.instr_mem._mem[1] = 32'h0062f233;           // and x4, x5, x6
        dut.instr_mem._mem[2] = 32'h00637233;           // and x4, x6, x6

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        #11 assert(dut.dp.rf._reg[0] === 32'h00);
        #20 assert(dut.dp.rf._reg[4] === 32'h01);
        #20 assert(dut.dp.rf._reg[4] === 32'hff);

        #5;
        $finish;
    end

endmodule
