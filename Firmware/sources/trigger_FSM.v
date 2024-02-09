`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/07/2024 02:11:35 PM
// Design Name: 
// Module Name: trigger_FSM
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


module trigger_FSM(
    input clk,
    input [13:0] adc_A,
    input [13:0] adc_B,
    input trig,
    output reg [13:0] data_out_A,
    output reg [13:0] data_out_B,
    output reg write_enable,
    output reg [31:0] write_address);

reg [1:0] state;
reg last_trig;
reg [9:0] sample_cnt;

initial begin
	$dumpfile("waves.vcd");
	$dumpvars();
    state = 2'd0;
end

always @(posedge clk) begin
    last_trig <= trig;    
    case (state)
        2'd0:
            begin
                sample_cnt <= 10'd5;
                write_enable <= 1'b0;
                if (trig == 1'b1 && last_trig == 1'b0)
                    state <= 2'd1;
                else
                    state <= 2'd0;
                write_address <= 32'hxxxxxxxx;
            end
        2'd1:
            begin
                if (sample_cnt == 10'd0) 
                    begin
                    state <= 2'd2; //modified
                    sample_cnt <= 10'd1000;
                    data_out_A <= adc_A;
                    data_out_B <= adc_B;
                    write_address <= 32'h40000000;
                    write_enable <= 1'b1;
                    end
                else
                    begin
                    state <= 2'd1;
                    sample_cnt <= sample_cnt - 10'd1;
                    write_enable <= 1'b0;
                    write_address <= 32'hxxxxxxxx;
                    end
            end
        2'b10: //don't care --> default?
             begin
                if (sample_cnt == 10'd0)
                    begin
                    state <= 2'd0;
                    write_enable <= 1'b0;
                    write_address <= 32'hxxxxxxxx;
                    end
                else
                    begin
                    state <= 2'd2;
                    data_out_A <= adc_A;
                    data_out_B <= adc_B;
                    write_enable <= 1'b1;
                    sample_cnt <= sample_cnt - 10'd1;
                    write_address <= write_address + 32'd1;
                    end
             end
        2'b11: //don't care --> default?
             begin
                state <= 2'd0;
                write_enable <= 1'b0;
                write_address <= 32'hxxxxxxxx;
             end
    endcase
end
endmodule
