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

module moving_average #(
    parameter INPUT_WIDTH = 16,
    parameter AVERAGE_INPUTS = 4,
    // It is assumed at all bits are fractional
    parameter MULTIPLICATIVE_INVERSE = 2'b01,
    parameter INVERSE_WIDTH = 2
) (
    input clk,
    input rst_active_low,
    input signed [INPUT_WIDTH-1:0] data_in,
    output signed [INPUT_WIDTH-1:0] data_out,
    output signed [INPUT_WIDTH+AVERAGE_INPUTS+INVERSE_WIDTH-1:0] average_out
);


reg signed [INPUT_WIDTH-1:0] buffer [0:AVERAGE_INPUTS];
// Adds first value to sum buffer and removes last value from sum buffer,
// effectively leaving registers 0 to AVERAGE_INPUT-1 for averaging
reg signed [INPUT_WIDTH+AVERAGE_INPUTS-1:0] sum_buffer;

integer idx;
initial begin
    $dumpfile("waves.vcd");
    $dumpvars();
    
    for (idx = 0; idx < INPUT_WIDTH; idx = idx + 1) begin
        buffer[idx] = {INPUT_WIDTH{1'b0}};
    end
end

always @(posedge clk) begin
	sum_buffer <= sum_buffer + $signed({{(AVERAGE_INPUTS){buffer[0][INPUT_WIDTH-1]}}, buffer[0]}) - $signed({{(AVERAGE_INPUTS){buffer[AVERAGE_INPUTS][INPUT_WIDTH-1]}}, buffer[AVERAGE_INPUTS]});
	buffer[0] <= data_in;
	for (idx = 1; idx < AVERAGE_INPUTS + 1; idx = idx + 1) begin
		buffer[idx] <= buffer[idx-1];		
	end
end

assign average_out = sum_buffer * MULTIPLICATIVE_INVERSE;
assign data_out = buffer[AVERAGE_INPUTS];

endmodule
