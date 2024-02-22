`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2024 04:38:00 PM
// Design Name: 
// Module Name: cpu_trig
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


module cpu_trig(
    input clk,
    input write_finished,
    input CPU_trig,
    output reg cpu_flag
    );

reg state;

initial begin
	$dumpfile("waves.vcd");
	$dumpvars();
    state = 1'd0;
    cpu_flag = 1'd0;
end

always @(posedge clk) begin
    case (state)
    1'd0:
        begin
            if (write_finished == 1'd1 && CPU_trig == 1'd1)
                begin
                state <= 1'd1;
                cpu_flag <= 1'd1;
                end
            else 
                begin
                state <= 1'd0;
                cpu_flag <= 1'd0;
                end
        end
    1'd1:
        begin
            if (write_finished == 1'd0 || CPU_trig == 1'd0)
                begin
                state <= 1'd0;
                cpu_flag <= 1'd0;
                end
        end
    endcase
end

endmodule

