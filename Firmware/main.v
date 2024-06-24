`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2024 04:46:50 PM
// Design Name: 
// Module Name: main
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


module main #(
    parameter TRIGONOMETRY_GENERATOR_OUTPUT_WIDTH = 16   
) (
    DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    adc_dat_a_in,
    exp_p_tri_io,
    led_o
    );
    inout [14:0]DDR_addr;
    inout [2:0]DDR_ba;
    inout DDR_cas_n;
    inout DDR_ck_n;
    inout DDR_ck_p;
    inout DDR_cke;
    inout DDR_cs_n;
    inout [3:0]DDR_dm;
    inout [31:0]DDR_dq;
    inout [3:0]DDR_dqs_n;
    inout [3:0]DDR_dqs_p;
    inout DDR_odt;
    inout DDR_ras_n;
    inout DDR_reset_n;
    inout DDR_we_n;
    inout FIXED_IO_ddr_vrn;
    inout FIXED_IO_ddr_vrp;
    inout [53:0]FIXED_IO_mio;
    inout FIXED_IO_ps_clk;
    inout FIXED_IO_ps_porb;
    inout FIXED_IO_ps_srstb;
    input [13:0]adc_dat_a_in;
    input [7:0]exp_p_tri_io;
    output [7:0]led_o;
    
    wire sys_clk;
    wire sys_aresetn;
    wire [31:0] axi_gpio_to_controller;
    wire controller_trigger_to_trigger_fsm;
    wire [23:0] sample_cnt;
    wire [23:0] repetition_cnt;
    wire [23:0] trigonometry_sample_hop_cnt;
    wire trigger_fsm_wr_en_to_muliplier;
    wire [13:0] trigger_fsm_adc_dat_to_multiplier;
    wire [TRIGONOMETRY_GENERATOR_OUTPUT_WIDTH-1:0] sine_value;
    wire [31:0] value_to_bram;
    wire muliplier_wr_en_to_bram_store_controller;
    
    wire [31:0] BRAM_write_address;
    wire [31:0] BRAM_write_data;
    wire [3:0] BRAM_wren;

    
    system_wrapper (
        .sys_clk(sys_clk),
        .sys_aresetn(sys_aresetn),
        
        .AXI_TO_GPIO_tri_o(axi_gpio_to_controller),
        
        .BRAM_PORTB_addr(BRAM_write_address),
        .BRAM_PORTB_clk(sys_clk),
        .BRAM_PORTB_din(BRAM_write_data),
        .BRAM_PORTB_dout(),
        .BRAM_PORTB_en(1'b1),
        .BRAM_PORTB_rst(),
        .BRAM_PORTB_we(BRAM_wren),
        
        .DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb)
    );
    
    controller (
        .clk(sys_clk),
        .data_input(axi_gpio_to_controller),
        .cpu_trig(controller_trigger_to_trigger_fsm),
        .repetitions(repetition_cnt),
        .samples(sample_cnt),
        .generator_hops(trigonometry_sample_hop_cnt),
        .led_o()
    );
    
    trigger_FSM (
        .clk(sys_clk),
        .adc_A(adc_dat_a_in),
        .trig(exp_p_tri_io[0]),
        .sniff_trig(controller_trigger_to_trigger_fsm),
        .max_sample_cnt(sample_cnt),
        .max_repetition_cnt(repetition_cnt),
        
        .data_out_A(trigger_fsm_adc_dat_to_multiplier),
        .write_enable(trigger_fsm_wr_en_to_muliplier),
        .led(led_o)
    );
    
    sin_cos_gen #(
        .OUTPUT_WIDTH(TRIGONOMETRY_GENERATOR_OUTPUT_WIDTH),
        .lut_path("values.hex")
    ) (
        .gen_clk(sys_clk),
        .hop_amount(trigonometry_sample_hop_cnt[5:0]),
        .rst_active_low(sys_aresetn),
        .sine_value(sine_value),
        .cosine_value()
    );
    
    multiplier_wrapper(
        .clk(sys_clk),
        .write_enable_in(trigger_fsm_wr_en_to_muliplier),
        .adc_in(trigger_fsm_adc_dat_to_multiplier),
        .trigonometry_in(sine_value),
        .product(value_to_bram),
        .write_enable_out(muliplier_wr_en_to_bram_store_controller)
    );
    
    BRAM_Store(
        .clk(sys_clk),
        .data_in(value_to_bram),
        .write_enable(muliplier_wr_en_to_bram_store_controller),
       
        .BRAM_write_address(BRAM_write_address),
        .BRAM_write_data(BRAM_write_data),
        .BRAM_wren(BRAM_wren)
    );

endmodule
