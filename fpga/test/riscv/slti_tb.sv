`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "slti_tb.vcd"
`endif

module slti_tb;
    reg clk = 0, rst;

    always #10 clk = ~clk;


    wire [31:0] instr, d_rd, d_addr, d_wd, pc;
    wire d_we;
    mem_dt_e d_dt;

    cpu dut(instr, d_rd, d_addr, d_we, d_wd, d_dt, pc, rst, clk);


    errno_e  err;

    cpu_mem cm(
        pc, d_addr, d_wd, d_we, d_dt, instr, d_rd, err, clk);

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, slti_tb);

        `CPU_SET_R(dut, 4, 32'b00);
        `CPU_SET_R(dut, 5, 32'h08);
        `CPU_SET_R(dut, 6, 32'd2);
        `CPU_SET_R(dut, 7, 32'hfffffff8);
        `CPU_SET_R(dut, 8, 32'd2);
        `CPU_SET_R(dut, 9, 32'd2);
        `CPU_SET_R(dut, 10, 32'd4);

        `CPU_MEM_SET_W(cm, 0, 32'h0022a213);   // slti    x4, x5, x6
        `CPU_MEM_SET_W(cm, 1, 32'h0023a213);   // slti    x4, x7, x8
        `CPU_MEM_SET_W(cm, 2, 32'h0044a213);   // slti    x4, x9, x10

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        `WAIT_INIT_CYCLES(clk);
        `WAIT_CLKS(clk, `I_I_CYC) assert(`CPU_GET_R(dut, 4) === 32'd0);
        `WAIT_CLKS(clk, `I_I_CYC) assert(`CPU_GET_R(dut, 4) === 32'd1);
        `WAIT_CLKS(clk, `I_I_CYC) assert(`CPU_GET_R(dut, 4) === 32'd1);

        #5;
        $finish;
    end

endmodule
