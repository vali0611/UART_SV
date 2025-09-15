module top_uart(
    input logic clk, rst_n,
    input  logic [15:0] divizor,
    input logic [7:0] data_in,
    input logic write_en,
    input logic stop_bit,
    input logic parity_type,
    input logic parity_en,
    input logic read_en,
    output logic [7:0] data_out,
    output logic txd,
    input logic rxd,
    output logic tx_busy,
    output logic rx_busy,
    output logic rx_ready,
    output logic parity_error,
    output logic frame_error
);
logic tick_baud_out;
baud_rate baud_rate0(

    .clk(clk),
    .rst_n(rst_n),
    .divizor(divizor),
    .tick_baud(tick_baud_out)
);
logic tx_empty;
transmitter transmitter0(
    .clk(clk),
    .rst_n(rst_n),
    .tick_baud(tick_baud_out),
    .data_in(data_in),
    .write_en(write_en),
    .parity_en(parity_en),
    .parity_type(parity_type),
    .stop_bit(stop_bit),
    .txd(txd),
    .tx_empty(tx_empty),
    .tx_busy(tx_busy)
);
receiver receiver0(
    . rst_n(rst_n),
    . clk(clk),
    . rxd(rxd),
    . tick_baud(tick_baud_out),
    . parity_en(parity_en),
    . parity_type(parity_type),
    . stop_bit(stop_bit),
    . read_en(read_en),
    . data_out(data_out),
    . rx_ready(rx_ready),
    . rx_busy(rx_busy),
    . parity_error(parity_error),
    . frame_error(frame_error)
);

endmodule