`timescale 1ns/1ps
module uart_tb;
  localparam CLK_FREQ  = 10_000_000;
  localparam BAUD_RATE = 115200;

  reg        clk=0, rst=1;
  reg  [7:0] tx_data;
  reg        tx_start=0;
  wire       tx_line, tx_busy;
  wire [7:0] rx_data;
  wire       rx_valid;

  // Latch received data when rx_valid pulses
  reg [7:0] received_data;
  reg       got_data;

  always #50 clk=~clk;

  uart_tx #(.CLK_FREQ(CLK_FREQ),.BAUD_RATE(BAUD_RATE)) DUT_TX (
    .clk(clk),.rst(rst),.data_in(tx_data),
    .tx_start(tx_start),.tx(tx_line),.tx_busy(tx_busy)
  );

  uart_rx #(.CLK_FREQ(CLK_FREQ),.BAUD_RATE(BAUD_RATE)) DUT_RX (
    .clk(clk),.rst(rst),.rx(tx_line),
    .data_out(rx_data),.data_valid(rx_valid)
  );

  // Catch the rx_valid pulse and latch the data
  always @(posedge clk) begin
    if (rx_valid) begin
      received_data <= rx_data;
      got_data      <= 1;
    end
  end

  integer pass_count=0, fail_count=0;

  task send_and_check;
    input [7:0] byte_val;
    begin
      got_data = 0;
      tx_data  = byte_val;
      tx_start = 1;
      @(posedge clk); tx_start = 0;
      // Wait until RX latches the data
      wait(got_data == 1);
      @(posedge clk);
      if (received_data == byte_val) begin
        $display("PASS: Sent 0x%h, Received 0x%h", byte_val, received_data);
        pass_count = pass_count + 1;
      end else begin
        $display("FAIL: Sent 0x%h, Received 0x%h", byte_val, received_data);
        fail_count = fail_count + 1;
      end
      // Gap between bytes
      repeat(100) @(posedge clk);
    end
  endtask

  initial begin
    $dumpfile("uart_tb.vcd");
    $dumpvars(0, uart_tb);
    rst = 1; got_data = 0;
    repeat(5) @(posedge clk);
    rst = 0;
    repeat(5) @(posedge clk);

    send_and_check(8'h41); // 'A'
    send_and_check(8'hFF);
    send_and_check(8'h00);

    $display("Results: %0d passed, %0d failed", pass_count, fail_count);
    $finish;
  end
endmodule
