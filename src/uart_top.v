//=============================================================================
// Module: uart_top
// Description: Top-level wrapper connecting UART TX and RX into one complete
//              UART controller. Exposes a clean interface for integration
//              into any SoC or FPGA design.
//
// Architecture:
//   uart_top
//   ├── uart_tx  (serializes parallel data onto TX line)
//   └── uart_rx  (deserializes RX line into parallel data)
//
// Parameters:
//   CLK_FREQ  - System clock frequency in Hz (default: 100 MHz)
//   BAUD_RATE - UART baud rate in bps       (default: 9600)
//
// Memory Map / Port Description:
//   clk          - System clock (active rising edge)
//   rst          - Active-high synchronous reset
//   tx_data      - 8-bit data to transmit
//   tx_start     - Pulse high for 1 cycle to begin transmission
//   tx           - Serial TX output line (idle HIGH)
//   tx_busy      - HIGH while transmitter is busy
//   rx           - Serial RX input line
//   rx_data      - 8-bit received data output
//   rx_data_valid- Pulses HIGH for 1 cycle when a byte is received
//=============================================================================

module uart_top #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 9600
)(
    // Global
    input  wire       clk,
    input  wire       rst,

    // TX interface
    input  wire [7:0] tx_data,
    input  wire       tx_start,
    output wire       tx,
    output wire       tx_busy,

    // RX interface
    input  wire       rx,
    output wire [7:0] rx_data,
    output wire       rx_data_valid
);

//-----------------------------------------------------------------------------
// TX Instance
//-----------------------------------------------------------------------------
uart_tx #(
    .CLK_FREQ  (CLK_FREQ),
    .BAUD_RATE (BAUD_RATE)
) u_uart_tx (
    .clk      (clk),
    .rst      (rst),
    .data_in  (tx_data),
    .tx_start (tx_start),
    .tx       (tx),
    .tx_busy  (tx_busy)
);

//-----------------------------------------------------------------------------
// RX Instance
//-----------------------------------------------------------------------------
uart_rx #(
    .CLK_FREQ  (CLK_FREQ),
    .BAUD_RATE (BAUD_RATE)
) u_uart_rx (
    .clk        (clk),
    .rst        (rst),
    .rx         (rx),
    .data_out   (rx_data),
    .data_valid (rx_data_valid)
);

endmodule
