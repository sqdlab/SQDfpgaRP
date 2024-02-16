`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 13.02.2024 15:59:13
// Design Name:
// Module Name: axi_to_modules
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


module axi_to_modules #(
    parameter BASE_COEFFICIENT_ADDR = 6'b000_000,
    parameter COEFFICIENT_COUNT = 'd40,
    parameter REPETITIONS_ADDR = 6'b111_111,
    parameter SAMPLES_ADDR = REPETITIONS_ADDR - 'd1,
    parameter HOPS_ADDR = SAMPLES_ADDR - 'd1
) (
    input clk,
    input rst_active_low,
    input [31:0] control_bus,
    output reg [31:0] fir_data_write, // Split bus between data values and mulitplier assignment
    // Address bits from 31 downto $clog2(COEFFICIENT_COUNT)-1, remainder bits are for data
    output reg [24:0] trigger_repetitions_write,
    output reg [24:0] trigger_samples_write,
    output reg [24:0] trig_generator_hops_write,
    output reg write_finished
);

localparam READY_IDX = 31;
localparam HIGH_DESTINATION_IDX = 30;
localparam BASE_DESTINATION_IDX = 25;
localparam HIGH_DATA_IDX = 24;
localparam BASE_DATA_IDX = 0;

reg last_write_finished = 1'b0;

initial begin
    fir_data_write <= {32{1'b1}};
    trigger_repetitions_write <= {25{1'b0}};
    trigger_samples_write <= {25{1'b0}};
    trig_generator_hops_write <= {25{1'b0}};
    write_finished <= 1'b0;
end

always @(posedge clk) begin
    if (rst_active_low == 1'b0) begin
        fir_data_write <= {32{1'b1}};
        trigger_repetitions_write <= {25{1'b0}};
        trigger_samples_write <= {25{1'b0}};
        trig_generator_hops_write <= {25{1'b0}};
        write_finished <= 1'b1;
    end else if (control_bus[READY_IDX] == 1'b1 && write_finished == 1'b0) begin
        if (control_bus[HIGH_DESTINATION_IDX:BASE_DESTINATION_IDX] <= BASE_COEFFICIENT_ADDR + COEFFICIENT_COUNT - 1) begin
            fir_data_write[31:31-$clog2(COEFFICIENT_COUNT)+1] <= control_bus[HIGH_DESTINATION_IDX:BASE_DESTINATION_IDX];
            fir_data_write[31-$clog2(COEFFICIENT_COUNT):0] <= {{31-$clog2(COEFFICIENT_COUNT)-HIGH_DATA_IDX{1'b0}}, control_bus[HIGH_DATA_IDX:BASE_DATA_IDX]};
        end else begin
            case (control_bus[HIGH_DESTINATION_IDX:BASE_DESTINATION_IDX])
                REPETITIONS_ADDR: begin
                    trigger_repetitions_write <= {control_bus[HIGH_DATA_IDX:BASE_DATA_IDX]};
                end
                SAMPLES_ADDR: begin
                    trigger_samples_write <= {control_bus[HIGH_DATA_IDX:BASE_DATA_IDX]};
                end
                HOPS_ADDR: begin
                    trig_generator_hops_write <= {control_bus[HIGH_DATA_IDX:BASE_DATA_IDX]};
                end
            endcase
        end
        write_finished <= 1'b1;
    end else if (write_finished == 1'b1) begin
        write_finished <= 1'b0;
    end
end
endmodule