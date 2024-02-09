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
    input [31:0] write_address,
    input [13:0] data_out_A,
    input [13:0] data_out_B,
    input write_enable,
    
    output [31:0] BRAM_write_address,
    output [31:0] BRAM_write_data,
    output [3:0] BRAM_wren
    );
    
    assign BRAM_write_address = write_address;
    
    // assign BRAM_write_data[13:0] = data_out_A;
    // assign BRAM_write_data[31:14] = 18'd0;
    
    assign BRAM_write_data[31:9] = {23{data_out_A[13]}};
    assign BRAM_write_data[8:0] = ~data_out_A[12:4];

    assign BRAM_wren[0] = write_enable;
    assign BRAM_wren[1] = write_enable;
    assign BRAM_wren[2] = write_enable;
    assign BRAM_wren[3] = write_enable;
endmodule
