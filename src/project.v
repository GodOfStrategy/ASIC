
`default_nettype none

module tt_um_godofstrategy_tiny8 (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       ena,

    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,

    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe
);

    wire [7:0] debug_pc;
    wire [15:0] debug_ir;
    wire [3:0] debug_state;
    wire [3:0] debug_flags;
    wire debug_halted;

    // Tiny8 processor
    // The CPU uses an active-high reset.
    tiny8_top cpu (
        .clk(clk),
        .rst((~rst_n) | (~ena)),
        .port_in(ui_in),
        .port_out(uo_out),
        .debug_pc(debug_pc),
        .debug_ir(debug_ir),
        .debug_state(debug_state),
        .debug_flags(debug_flags),
        .debug_halted(debug_halted)
    );

    // Expose the program counter for debugging.
    assign uio_out = debug_pc;
    assign uio_oe  = 8'hFF;

    // Unused input and debug signals.
    wire unused_signals = ^{
        uio_in,
        debug_ir,
        debug_state,
        debug_flags,
        debug_halted
    };

endmodule

`default_nettype wire
