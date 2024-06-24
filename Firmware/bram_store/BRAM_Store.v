`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/07/2024 03:44:51 PM
// Design Name: 
// Module Name: BRAM_Store
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


module BRAM_Store(
    input clk,
    input [31:0] data_in,
    input write_enable,
    
    output reg [31:0] BRAM_write_address,
    output [31:0] BRAM_write_data,
    output [3:0] BRAM_wren
);

initial begin
    BRAM_write_address = 32'd0 - 32'd4;
end

always @(posedge clk) begin
    if (write_enable == 1'b1) begin
        BRAM_write_address <= BRAM_write_address + 32'd4;
    end else begin
        BRAM_write_address <= 32'd0 - 32'd4;
    end 
end

    assign BRAM_write_data = data_in;

    assign BRAM_wren[0] = write_enable;
    assign BRAM_wren[1] = write_enable;
    assign BRAM_wren[2] = write_enable;
    assign BRAM_wren[3] = write_enable;
endmodule
