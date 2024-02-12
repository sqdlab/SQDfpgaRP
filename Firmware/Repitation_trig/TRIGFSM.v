`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SQD Lab
// Engineer: Junjia Yang
// 
// Create Date: 02/09/2024 02:11:35 PM
// Design Name: 
// Module Name: trigger_FSM
// Project Name: Repitition_trigger
// Target Devices: Red-pitaya 125-10
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
    input sniff_trig,
    output reg [13:0] data_out_A,
    output reg [13:0] data_out_B,
    output reg write_enable,
    output reg [31:0] write_address);

reg [1:0] state;
reg last_trig;
reg [7:0] sample_cnt;
reg [23:0] rep_cnt;

initial begin
	$dumpfile("waves.vcd");
	$dumpvars();
    state = 2'd0;
end

always @(posedge clk) begin
    last_trig <= trig;    
    case (state)
        2'b0:
            begin
                rep_cnt <= 24'd2;
                if (sniff_trig == 1)
                    state <=  2'b1;
                else
                    state <= 2'b0;
            end  
        2'b1:
            begin
                sample_cnt <= 8'd5;
                write_enable <= 1'b0;
                if (trig == 1'b1 && last_trig == 1'b0 && rep_cnt > 0)
                    state <= 2'b10;
                else
                    state <= 2'b1;
                write_address <= 32'hxxxxxxxx;
            end    
        2'b10: 
            begin
                if (sample_cnt == 8'd0) 
                    begin
                    state <= 2'b11; //modified
                    sample_cnt <= 8'd6;
                    data_out_A <= adc_A;
                    data_out_B <= adc_B;
                    write_address <= 32'h40000000;
                    write_enable <= 1'b1;
                    end
                else
                    begin
                    state <= 2'b10;
                    sample_cnt <= sample_cnt - 8'd1;
                    write_enable <= 1'b0;
                    write_address <= 32'hxxxxxxxx;
                    end
            end
        2'b11:
            begin
            if (sample_cnt == 8'd0)
                begin
                state <= 2'b1;
                write_enable <= 1'b0;
                write_address <= 32'hxxxxxxxx;
                rep_cnt <= rep_cnt - 24'd1;
                end
            else
                begin
                state <= 2'b11;
                data_out_A <= adc_A;
                data_out_B <= adc_B;
                write_enable <= 1'b1;
                sample_cnt <= sample_cnt - 8'd1;
                write_address <= write_address + 32'd1;
                end
            end
    endcase
end
endmodule
