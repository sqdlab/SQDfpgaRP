# clock input
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports adc_clk_p_in]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports adc_clk_n_in]
set_property PACKAGE_PIN U18 [get_ports adc_clk_p_in]
set_property PACKAGE_PIN U19 [get_ports adc_clk_n_in]

create_clock -period 8.000 -name adc_clk [get_ports adc_clk_p_in]

set_input_delay -max 3.400 -clock adc_clk [get_ports adc_dat_a_in[*]]
set_input_delay -max 3.400 -clock adc_clk [get_ports adc_dat_b_in[*]]

# clock output

set_property IOSTANDARD LVCMOS18 [get_ports {adc_clk_source[*]}]
set_property SLEW FAST [get_ports {adc_clk_source[*]}]
set_property DRIVE 8 [get_ports {adc_clk_source[*]}]

set_property PACKAGE_PIN N20 [get_ports {adc_clk_source[0]}]
set_property PACKAGE_PIN P20 [get_ports {adc_clk_source[1]}]

# clock duty cycle stabilizer (CSn)

set_property IOSTANDARD LVCMOS18 [get_ports adc_cdcs_out]
set_property PACKAGE_PIN V18 [get_ports adc_cdcs_out]
set_property SLEW FAST [get_ports adc_cdcs_out]
set_property DRIVE 8 [get_ports adc_cdcs_out]