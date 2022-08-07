`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "pipeline_jalr_tb.vcd"
`endif

module pipeline_jalr_tb;
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

    wire [31:0] x0;
    wire [31:0] x1;
    wire [31:0] x2;
    wire [31:0] x3;
    wire [31:0] x4;
    wire [31:0] x5;
    wire [31:0] x6;

    assign x0 = dut.rv.dp.rf._reg[0];
    assign x1 = dut.rv.dp.rf._reg[1];
    assign x2 = dut.rv.dp.rf._reg[2];
    assign x3 = dut.rv.dp.rf._reg[3];
    assign x4 = dut.rv.dp.rf._reg[4];
    assign x5 = dut.rv.dp.rf._reg[5];
    assign x6 = dut.rv.dp.rf._reg[6];


    wire [31:0] pc_reg_plus_off_e, i_e;

    assign pc_reg_plus_off_e = dut.rv.dp.pc_reg_plus_off_e;
    assign i_e = dut.rv.dp.i_e;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, pipeline_jalr_tb);

        dut.rv.dp.rf._reg[0] = 32'd00;
        dut.rv.dp.rf._reg[1] = 32'd00;
        dut.rv.dp.rf._reg[2] = 32'd2;
        dut.rv.dp.rf._reg[3] = 32'd3;
        dut.rv.dp.rf._reg[4] = 32'd4;
        dut.rv.dp.rf._reg[5] = 32'd5;
        dut.rv.dp.rf._reg[6] = 32'd6;
        dut.rv.dp.rf._reg[7] = 32'd4;

        `SET_MEM_I(0, 32'h00c380e7); // jalr    x1, x7, 12
        `SET_MEM_I(1, 32'h00510113); // addi    x2, x2, 5
        `SET_MEM_I(2, 32'h00518193); // addi    x3, x3, 5
        `SET_MEM_I(3, 32'h00520213); // addi    x4, x4, 5
        `SET_MEM_I(4, 32'h00a28293); // addi    x5, x5, 10
        `SET_MEM_I(5, 32'hffc38367); // jalr    x6, x7, -4
        `SET_MEM_I(6, 32'h00000013); // nop
        `SET_MEM_I(7, 32'h00000013); // nop


        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 32'd00);

        `WAIT_CLKS(clk, 3) assert(pc === 32'd16);
        `WAIT_CLKS(clk, 2) assert(dut.rv.dp.rf._reg[1] === 32'd4);
        `WAIT_CLKS(clk, 2) assert(pc === 32'd0);
        `WAIT_CLKS(clk, 1) assert(dut.rv.dp.rf._reg[2] === 32'd2);
                           assert(dut.rv.dp.rf._reg[3] === 32'd3);
                           assert(dut.rv.dp.rf._reg[5] === 32'd15);


        // This first wait must be only 2 because of the last wait in the
        // above section
        `WAIT_CLKS(clk, 2) assert(pc === 32'd16);
        `WAIT_CLKS(clk, 2) assert(dut.rv.dp.rf._reg[1] === 32'd4);
        `WAIT_CLKS(clk, 2) assert(pc === 32'd0);
        `WAIT_CLKS(clk, 1) assert(dut.rv.dp.rf._reg[2] === 32'd2);
                           assert(dut.rv.dp.rf._reg[3] === 32'd3);
                           assert(dut.rv.dp.rf._reg[5] === 32'd25);

        // Same as above
        `WAIT_CLKS(clk, 2) assert(pc === 32'd16);
        `WAIT_CLKS(clk, 2) assert(dut.rv.dp.rf._reg[1] === 32'd4);
        `WAIT_CLKS(clk, 2) assert(pc === 32'd0);
        `WAIT_CLKS(clk, 1) assert(dut.rv.dp.rf._reg[2] === 32'd2);
                           assert(dut.rv.dp.rf._reg[3] === 32'd3);
                           assert(dut.rv.dp.rf._reg[5] === 32'd35);

        #5;
        $finish;
    end

endmodule
