`timescale 1 ps / 1 ps

module top (
    // make sure matches .xdc constraints
    input  logic [4:0]  okUH,
    output logic [2:0]  okHU,
    inout  logic [31:0] okUHU,
    inout  logic        okAA,
    input  logic        fixed_200mhz_clk_n,
    input  logic        fixed_200mhz_clk_p,
    output logic [7:0]  led_tri_o,
    input  logic        reset_rtl
);

    logic        okClk;
    logic [112:0] okHE;
    logic [64:0]  okEH;

    okHost host (
        .okUH(okUH),
        .okHU(okHU),
        .okUHU(okUHU),
        .okAA(okAA),
        .okClk(okClk),
        .okHE(okHE),
        .okEH(okEH)
    );

    logic [31:0] fp_usb_data;

    okWireIn wireIn00 (
        .okHE(okHE),
        .ep_addr(8'h00), // some endpoint address in Wire In address range (see user manual)
        .ep_dataout(fp_usb_data)
    );

    mb_wrapper mb (
        .fixed_200mhz_clk_n(fixed_200mhz_clk_n),
        .fixed_200mhz_clk_p(fixed_200mhz_clk_p),
        .GPIO_1_tri_o(led_tri_o),
        .reset_rtl(reset_rtl),
        .GPIO_0_tri_i(fp_usb_data)
    );

endmodule