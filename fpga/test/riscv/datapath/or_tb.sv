`timescale 10ps/1ps

`include "alu.vh"
`include "riscv/datapath.vh"

`ifndef VCD
    `define VCD "or_tb.vcd"
`endif

module or_tb;
    reg reg_we, imm_src, mem_we, alu_src, res_src;
    reg [1:0] alu_ctrl;

    wire [31:0] pc, alu_out, wdata;
    wire [31:0] instr, mem_rd_data, mem_wd_data;

    reg clk = 0, rst;

    riscv_single_top dut(
        reg_we,
        mem_we,
        imm_src,
        alu_ctrl,
        alu_src,
        res_src,
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
        $dumpvars(1, or_tb);

        dut.dp.rf._reg[0] = 32'd00;
        dut.dp.rf._reg[4] = 32'd00;
        dut.dp.rf._reg[5] = 32'h01;
        dut.dp.rf._reg[6] = 32'hff;

        dut.instr_mem._mem[0] = 32'h0062e233;           // or x4, x5, x6

        // Set control signals for sw
        reg_we = 1'b0;
        imm_src = 1'b1;
        mem_we = 1'b1;
        alu_ctrl = alu_op_add;
        alu_src = alu_src_ext_imm;
        res_src = res_src_read_data;

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        #11 assert(dut.data_mem._mem[5] === 32'hdeadc0de);
        #20 assert(dut.data_mem._mem[10] === 32'hdeadbeef);
        #20 assert(dut.data_mem._mem[11] === 32'hc001c0de);
        #20 assert(dut.data_mem._mem[11] === 32'h00);

        #5;
        $finish;
    end

endmodule
