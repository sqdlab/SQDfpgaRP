`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SQD Lab
// Engineer: Junjia Yang
//
// Create Date: 02/27/2024 9:41:35 AM
// Design Name:
// Module Name: controller_FSM
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


module controller_FSM(
    input clk,
    input [31:0] data_input,
    output reg cpu_trig,
    output reg [23:0] repetitions,
    output reg [23:0] samples,
    output reg [23:0] generator_hops);

reg state;
reg prev_new_data_flag;

initial begin
	$dumpfile("waves.vcd");
	$dumpvars();
    state = 1'd0;
    prev_new_data_flag = 0;
    cpu_trig = 0;
    repetitions = 24'd0;
    samples = 24'd0;
    generator_hops = 24'd0;
end

always @(posedge clk) begin
    prev_new_data_flag <= data_input[31];
    case (state)
        1'b0://Idle
            begin 
                cpu_trig <= 0;             
                if (data_input[31] != prev_new_data_flag) //if msb is different, then there's new data
                    state <=  1'b1;               
                else                
                    state <= 1'b0;               
            end
        1'b1://Check new data input
            begin
                if (data_input[30:25] == 0 && data_input[24] == 1) // data address is 0 and cpu ctrl bit is 1
                    begin
                    cpu_trig <= 1;
                    state <= 1'b0;
                    end
                else if (data_input[30:25] == 6'b111111 && data_input[24] == 0) // data address refer to repetition
                    begin
                    cpu_trig <= 0;
                    repetitions <= data_input[23:0];
                    state <= 1'b0;
                    end
                else if (data_input[30:25] == 6'b111110 && data_input[24] == 0) // data address refer to sample num
                    begin
                    cpu_trig <= 0;
                    samples <= data_input[23:0];
                    state <= 1'b0;
                    end
                else if (data_input[30:25] == 6'b111101 && data_input[24] == 0) // data address refer to hops
                    begin
                    cpu_trig <= 0; 
                    generator_hops <= data_input[23:0];
                    state <= 1'b0;
                    end
                else //reset to idle state if the input is not valid
                    begin
                    state <= 1'b0; 
                    end
            end
    endcase
end
endmodule
