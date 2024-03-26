`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.02.2024 22:57:37
// Design Name: 
// Module Name: sine_and_cosine_generator
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


module sin_cos_gen #(
    parameter OUTPUT_WIDTH = 16,
    parameter lut_path = "../../values.hex"
) (
    input gen_clk,
    input [5:0] hop_amount,
    input rst_active_low,
    output reg [OUTPUT_WIDTH-1:0] sine_value,
    output reg [OUTPUT_WIDTH-1:0] cosine_value
);

reg [5:0] sine_phase = 6'd0;
reg [5:0] cosine_phase = 6'd17;
reg [OUTPUT_WIDTH-1:0] trig_table [0:63];
initial	begin
	$dumpfile("waves.vcd");
    $dumpvars();
	$readmemh(lut_path, trig_table);
end

always @(posedge gen_clk) begin
    if (rst_active_low != 0) begin
        sine_phase <= sine_phase + hop_amount;
        cosine_phase <= cosine_phase + hop_amount;
    end else begin
        sine_phase <= 6'd0;
        cosine_phase <= 6'd17;
    end
    sine_value <= trig_table[sine_phase];
    cosine_value <= trig_table[cosine_phase];
end
endmodule
