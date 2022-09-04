`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "ctrl_hazards_tb.vcd"
`endif

module ctrl_hazards_tb;
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
        $dumpvars(1, ctrl_hazards_tb);

        //
        // beq correctly flushes if required
        //
        #2  rst = 1;
            dut.rv.c.dp.rf._reg[1] = 32'h01;
            dut.rv.c.dp.rf._reg[2] = 32'd01;
            dut.rv.c.dp.rf._reg[3] = 32'd04;
            dut.rv.c.dp.rf._reg[4] = 32'd25;
            dut.rv.c.dp.rf._reg[5] = 32'd7;

            `SET_MEM_I(0, 32'h00208a63); //         beq x1, x2, .L1
            `SET_MEM_I(1, 32'h401201b3); //         sub x3, x4, x1
            `SET_MEM_I(2, 32'h0020e233); //         or  x4, x1, x2
            `SET_MEM_I(3, 32'h00000013); //         nop
            `SET_MEM_I(4, 32'h00000013); //         nop
            `SET_MEM_I(5, 32'h001281b3); // .L1:    add x3, x5, x1
        #2  rst = 0;

        `WAIT_CLKS(clk, 5); assert(dut.rv.c.dp.rf._reg[1] === 32'd1);
                            assert(dut.rv.c.dp.rf._reg[2] === 32'd1);
                            assert(dut.rv.c.dp.rf._reg[3] === 32'd4);
                            assert(dut.rv.c.dp.rf._reg[4] === 32'd25);
                            assert(dut.rv.c.dp.rf._reg[5] === 32'd7);

        `WAIT_CLKS(clk, 1); assert(dut.rv.c.dp.rf._reg[1] === 32'd1);
                            assert(dut.rv.c.dp.rf._reg[2] === 32'd1);
                            assert(dut.rv.c.dp.rf._reg[3] === 32'd4);
                            assert(dut.rv.c.dp.rf._reg[4] === 32'd25);
                            assert(dut.rv.c.dp.rf._reg[5] === 32'd7);

        `WAIT_CLKS(clk, 1); assert(dut.rv.c.dp.rf._reg[1] === 32'd1);
                            assert(dut.rv.c.dp.rf._reg[2] === 32'd1);
                            assert(dut.rv.c.dp.rf._reg[3] === 32'd4);
                            assert(dut.rv.c.dp.rf._reg[4] === 32'd25);
                            assert(dut.rv.c.dp.rf._reg[5] === 32'd7);

        `WAIT_CLKS(clk, 1); assert(dut.rv.c.dp.rf._reg[1] === 32'd1);
                            assert(dut.rv.c.dp.rf._reg[2] === 32'd1);
                            assert(dut.rv.c.dp.rf._reg[3] === 32'd8);
                            assert(dut.rv.c.dp.rf._reg[4] === 32'd25);
                            assert(dut.rv.c.dp.rf._reg[5] === 32'd7);


        //
        // beq correctly flushes if required 2
        //
        #2  rst = 1;
            dut.rv.c.dp.rf._reg[1] = 32'h01;
            dut.rv.c.dp.rf._reg[2] = 32'd01;
            dut.rv.c.dp.rf._reg[3] = 32'd04;
            dut.rv.c.dp.rf._reg[4] = 32'd25;
            dut.rv.c.dp.rf._reg[5] = 32'd7;

            `SET_MEM_I(0, 32'h00208a63); //         beq x1, x2, .L1
            `SET_MEM_I(1, 32'h401201b3); //         sub x3, x4, x1
            `SET_MEM_I(2, 32'h0020e233); //         or  x4, x1, x2
            `SET_MEM_I(3, 32'h00000013); //         nop
            `SET_MEM_I(4, 32'h00000013); //         nop
            `SET_MEM_I(5, 32'h003280b3); // .L1:    add x1, x5, x3
        #2  rst = 0;

        `WAIT_CLKS(clk, 5); assert(dut.rv.c.dp.rf._reg[1] === 32'd1);
                            assert(dut.rv.c.dp.rf._reg[2] === 32'd1);
                            assert(dut.rv.c.dp.rf._reg[3] === 32'd4);
                            assert(dut.rv.c.dp.rf._reg[4] === 32'd25);
                            assert(dut.rv.c.dp.rf._reg[5] === 32'd7);

        `WAIT_CLKS(clk, 1); assert(dut.rv.c.dp.rf._reg[1] === 32'd1);
                            assert(dut.rv.c.dp.rf._reg[2] === 32'd1);
                            assert(dut.rv.c.dp.rf._reg[3] === 32'd4);
                            assert(dut.rv.c.dp.rf._reg[4] === 32'd25);
                            assert(dut.rv.c.dp.rf._reg[5] === 32'd7);

        `WAIT_CLKS(clk, 1); assert(dut.rv.c.dp.rf._reg[1] === 32'd1);
                            assert(dut.rv.c.dp.rf._reg[2] === 32'd1);
                            assert(dut.rv.c.dp.rf._reg[3] === 32'd4);
                            assert(dut.rv.c.dp.rf._reg[4] === 32'd25);
                            assert(dut.rv.c.dp.rf._reg[5] === 32'd7);

        `WAIT_CLKS(clk, 1); assert(dut.rv.c.dp.rf._reg[1] === 32'd11);
                            assert(dut.rv.c.dp.rf._reg[2] === 32'd1);
                            assert(dut.rv.c.dp.rf._reg[3] === 32'd4);
                            assert(dut.rv.c.dp.rf._reg[4] === 32'd25);
                            assert(dut.rv.c.dp.rf._reg[5] === 32'd7);


        //
        // beq does not flush if not required
        //
        #2  rst = 1;
            dut.rv.c.dp.rf._reg[1] = 32'h01;
            dut.rv.c.dp.rf._reg[2] = 32'd01;
            dut.rv.c.dp.rf._reg[3] = 32'd04;
            dut.rv.c.dp.rf._reg[4] = 32'd25;
            dut.rv.c.dp.rf._reg[5] = 32'd7;

            `SET_MEM_I(0, 32'h00308a63); //         beq x1, x3, .L1
            `SET_MEM_I(1, 32'h401201b3); //         sub x3, x4, x1
            `SET_MEM_I(2, 32'h0020e233); //         or  x4, x1, x2
            `SET_MEM_I(3, 32'h00000013); //         nop
            `SET_MEM_I(4, 32'h00000013); //         nop
            `SET_MEM_I(5, 32'h003280b3); // .L1:    add x1, x5, x3
        #2  rst = 0;

        `WAIT_CLKS(clk, 5); assert(dut.rv.c.dp.rf._reg[1] === 32'd1);
                            assert(dut.rv.c.dp.rf._reg[2] === 32'd1);
                            assert(dut.rv.c.dp.rf._reg[3] === 32'd4);
                            assert(dut.rv.c.dp.rf._reg[4] === 32'd25);
                            assert(dut.rv.c.dp.rf._reg[5] === 32'd7);

        `WAIT_CLKS(clk, 1); assert(dut.rv.c.dp.rf._reg[1] === 32'd1);
                            assert(dut.rv.c.dp.rf._reg[2] === 32'd1);
                            assert(dut.rv.c.dp.rf._reg[3] === 32'd24);
                            assert(dut.rv.c.dp.rf._reg[4] === 32'd25);
                            assert(dut.rv.c.dp.rf._reg[5] === 32'd7);

        `WAIT_CLKS(clk, 1); assert(dut.rv.c.dp.rf._reg[1] === 32'd1);
                            assert(dut.rv.c.dp.rf._reg[2] === 32'd1);
                            assert(dut.rv.c.dp.rf._reg[3] === 32'd24);
                            assert(dut.rv.c.dp.rf._reg[4] === 32'd1);
                            assert(dut.rv.c.dp.rf._reg[5] === 32'd7);

        #20;
        $finish;
    end
endmodule
