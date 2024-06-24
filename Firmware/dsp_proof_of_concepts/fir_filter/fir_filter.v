`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.02.2024 23:45:08
// Design Name: 
// Module Name: fir_filter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module fir_filter #(
    parameter INPUT_WIDTH = 30,
    parameter INPUT_FRACTION_BITS = INPUT_WIDTH - 3, // 27 fractional bits
    parameter TAPS_WIDTH = 16, // To ensure no loss of precision with 32 bit inputs
    // The author has tested to ensure that no loss of precision is likely
    // to occur with 16 bits, although 17 bits is ideal for certain cutoff frequencies
    parameter TAPS_FRACTIONAL_BITS = TAPS_WIDTH - 0,
    parameter TAPS_COUNT = 40, // This is halved if folding is used
//    parameter OUTPUT_WIDTH = 43 // Output of the multiplier in the DSP block
    parameter ADDITIONAL_MULTIPLIER_BITS = 5,
    parameter ADDITIONAL_ADDER_BITS = 5
) (
    input fir_clk,
    input rst_active_low,
    // MSB = -1, remainder of bits are fractional
    input signed [INPUT_WIDTH-1:0] data_in,
    output signed [INPUT_WIDTH+TAPS_WIDTH+$clog2(TAPS_COUNT)+ADDITIONAL_MULTIPLIER_BITS+ADDITIONAL_ADDER_BITS-1:0] data_out
);


reg signed [INPUT_WIDTH-1:0] initial_delay;
localparam MULTIPLIER_WIDTH = INPUT_WIDTH+TAPS_WIDTH+ADDITIONAL_MULTIPLIER_BITS;
reg signed [MULTIPLIER_WIDTH-1:0] multiplier_delay [0:TAPS_COUNT-1];
localparam ADDER_WIDTH = MULTIPLIER_WIDTH+$clog2(TAPS_COUNT)+ADDITIONAL_ADDER_BITS;
reg signed [ADDER_WIDTH-1:0] adder_delay [0:TAPS_COUNT-2];

reg signed [TAPS_WIDTH-1:0] coefficient_values [0:TAPS_COUNT-1];

integer idx;
initial begin
    $dumpfile("waves2.vcd");
    $dumpvars();
    $readmemh("fir_values.mem", coefficient_values);
    
    initial_delay = {INPUT_WIDTH{1'b0}};
    for (idx = 0; idx < TAPS_COUNT; idx = idx + 1) begin
        multiplier_delay[idx] = {MULTIPLIER_WIDTH{1'b0}};
    end
    for (idx = 0; idx < TAPS_COUNT - 1; idx = idx + 1) begin
        adder_delay[idx] = {ADDER_WIDTH{1'b0}};
    end
end

always @(posedge fir_clk) begin
initial_delay <= data_in;
for (idx = 0; idx < TAPS_COUNT; idx = idx + 1) begin
    multiplier_delay[idx] <= $signed(initial_delay) * $signed(coefficient_values[idx]);  
end
adder_delay[0] <= {{(ADDER_WIDTH-MULTIPLIER_WIDTH){multiplier_delay[0][MULTIPLIER_WIDTH-1]}}, multiplier_delay[0]} + {{(ADDER_WIDTH-MULTIPLIER_WIDTH){multiplier_delay[1][MULTIPLIER_WIDTH-1]}}, multiplier_delay[1]};
	for (idx = 1; idx < TAPS_COUNT - 1; idx = idx + 1) begin
		adder_delay[idx] <= $signed(adder_delay[idx-1]) + $signed({{(ADDER_WIDTH-MULTIPLIER_WIDTH){multiplier_delay[idx+1][MULTIPLIER_WIDTH-1]}}, multiplier_delay[idx+1]});
	end
end

assign data_out = adder_delay[TAPS_COUNT-2];

endmodule