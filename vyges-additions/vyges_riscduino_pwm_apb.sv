// Vyges integration facade for the riscduino PWM (pwm_top).
//
// Bridges the SoC-standard peripheral surface — clk_i / rst_ni + APB4 slave +
// PWM waveform / GPIO pads + IRQ — to pwm_top's native riscduino register bus.
// Keeps the soc-generator wiring generic (no riscduino-reg-specific handling).
//
// Register-bus mapping (PREADY follows reg_ack handshake):
//   reg_cs   <- PSEL & PENABLE     reg_addr <- PADDR[6:2]     reg_wr  <- PWRITE
//   reg_wdata<- PWDATA             reg_be   <- 4'hF           PRDATA  <- reg_rdata
//   PREADY   <- reg_ack
// h_reset_n is active-low -> rst_ni connects directly.
//
// SPDX-License-Identifier: Apache-2.0

module vyges_riscduino_pwm_apb (
  input  wire        clk_i,
  input  wire        rst_ni,
  // APB4 slave
  input  wire [31:0] PADDR,
  input  wire        PWRITE,
  input  wire [31:0] PWDATA,
  input  wire        PSEL,
  input  wire        PENABLE,
  output wire        PREADY,
  output wire [31:0] PRDATA,
  // PWM / GPIO pads
  input  wire [7:0]  pad_gpio,
  output wire [5:0]  pwm_wfm,
  // Interrupt
  output wire        IRQ
);

  pwm_top u_pwm_top (
    .mclk      (clk_i),
    .h_reset_n (rst_ni),               // active-low, direct
    .reg_cs    (PSEL & PENABLE),
    .reg_wr    (PWRITE),
    .reg_addr  (PADDR[6:2]),
    .reg_wdata (PWDATA),
    .reg_be    (4'hF),
    .reg_rdata (PRDATA),
    .reg_ack   (PREADY),
    .pad_gpio  (pad_gpio),
    .pwm_wfm   (pwm_wfm),
    .pwm_intr  (IRQ)
  );

endmodule
