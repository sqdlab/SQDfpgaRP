`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2024 11:55:07 AM
// Design Name: 
// Module Name: multiplier_wrapper
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


module multiplier_wrapper(
    input clk,
    input write_enable_in,
    input [13:0] adc_in,
    input [15:0] trigonometry_in,
    output [31:0] product,
    output write_enable_out
);

// Currently configured to use 1 clock cycle to output
mult_gen_0 u0 (clk, {adc_in[13], ~adc_in[12:0]}, trigonometry_in, product);

assign write_enable_out = write_enable_in;

endmodule
