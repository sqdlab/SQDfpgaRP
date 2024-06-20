`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SQD Lab
// Engineer: Junjia Yang
//
// Create Date: 02/09/2024 10:48:39 AM
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
    input [13:0] adc_A, //the bus width of adc is 14
    input trig,
    input sniff_trig,
    input [23:0] max_sample_cnt, //NOTE: Number of Samples = sample_cnt + 1...
    input [23:0] max_repetition_cnt,

    output reg [13:0] data_out_A,
    output reg write_enable,
    output [7:0] led
);

reg [1:0] state;
reg last_trig;
reg [23:0] sample_cnt;
reg [23:0] rep_cnt;


initial begin
	$dumpfile("waves.vcd");
	$dumpvars();
    state = 2'd0;
    sample_cnt = 24'd0;
    rep_cnt = 24'd0;
    data_out_A = 14'd0;
    write_enable = 1'd0;
end
assign led[1:0] = state; 

always @(posedge clk) begin
    last_trig <= trig;
    case (state)
        2'b0://Idle
            begin
                rep_cnt <= max_repetition_cnt;
                if (sniff_trig == 1)
                begin
                    state <=  2'b1;
                end
                else
                begin
                    state <= 2'b0;
                end
                write_enable <= 1'b0;
            end
        2'b1://Wait for trigger
            begin
                sample_cnt <= 24'd5;    //Wait 6 TCY to sync with ADC delay...
                write_enable <= 1'b0;
                if (rep_cnt == 0)
                    state <= 2'b0;
                else if (trig == 1'b1 && last_trig == 1'b0)
                    state <= 2'b10;
                else
                    state <= 2'b1;
            end
        2'b10:
            begin//Begin sampling after waiting for the initial 6 ticks
                if (sample_cnt == 24'd0)
                    begin
                    state <= 2'b11; //modified
                    sample_cnt <= max_sample_cnt;
                    data_out_A <= adc_A;
                    write_enable <= 1'b1;
                    end
                else
                    begin
                    state <= 2'b10;
                    sample_cnt <= sample_cnt - 24'd1;
                    write_enable <= 1'b0;
                    end
            end
        2'b11:
            begin//Finish sampling
            if (sample_cnt == 24'd0)
                begin
                state <= 2'b1;
                write_enable <= 1'b0;
                rep_cnt <= rep_cnt - 24'd1;
                end
            else
                begin
                state <= 2'b11;
                sample_cnt <= sample_cnt - 24'd1;
                write_enable <= 1'b1;
                end
            data_out_A <= adc_A;
            end
    endcase
end
endmodule
