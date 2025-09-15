module top_tb;

    logic clk, rst_n;
    logic [15:0] divizor;
    logic [7:0] data_in;
    logic write_en, stop_bit, parity_type, parity_en, read_en;
    logic [7:0] data_out;
    logic txd, rxd;
    logic tx_busy, rx_busy, rx_ready, parity_error, frame_error;

    // Instanțiere DUT
    top_uart uut (
        .clk(clk),
        .rst_n(rst_n),
        .divizor(divizor),
        .data_in(data_in),
        .write_en(write_en),
        .stop_bit(stop_bit),
        .parity_type(parity_type),
        .parity_en(parity_en),
        .read_en(read_en),
        .data_out(data_out),
        .txd(txd),
        .rxd(rxd),
        .tx_busy(tx_busy),
        .rx_busy(rx_busy),
        .rx_ready(rx_ready),
        .parity_error(parity_error),
        .frame_error(frame_error)
    );

    // Task pentru trimitere pachet UART pe rxd
    task uart_rx_byte(input [7:0] data);
        integer i;
        begin
            rxd = 0; #100; // start bit (delay = perioada unui bit UART)
            for (i = 0; i < 8; i = i+1) begin
                rxd = data[i]; #100;
            end
            rxd = 1; #100; // stop bit
        end
    endtask

    // Clock generator
    initial clk = 0;
    always #5 clk = ~clk; // 100MHz

    initial begin
        // Inițializare
        rxd = 1; // Linie RX inactivă
        rst_n = 0;
        divizor = 16'd10;
        stop_bit = 1;
        parity_type = 0;
        parity_en = 0;
        data_in = 8'hA5;
        write_en = 0;
        read_en = 0;

        // Reset
        #20 rst_n = 1;

        // Simulează primirea unui byte pe RX
        #30 uart_rx_byte(8'hA5);

        // Scriere byte (transmitere TX)
        #50 write_en = 1;
        #10 write_en = 0;

        // Citire byte recepționat
        #200 read_en = 1;
        #10 read_en = 0;

        // Continua simularea
        #500;

        $stop;
    end

endmodule