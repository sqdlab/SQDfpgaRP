# ==================================================================================================
# make.tcl - This script will recreate a Vivado project by commands for creating a project, filesets, 
# runs, adding/importing sources and setting properties on various objects.
#
# This script must be run as "source make.tcl" under the base SQDfpgaRP/Working_version folder inside
#  Vivado tcl console.
#
# This script is modification of Anton Potocnik's make_project.tcl files by Junjia Yang, 08/02/2023
# ==================================================================================================

set project_name trigger_adc_to_bram
set part_name xc7z010clg400-1
set bd_path tmp/$project_name/$project_name.srcs/sources_1/bd/system

file delete -force tmp/$project_name

create_project $project_name tmp/$project_name -part $part_name

# ===================================================================================================
# General prepare settings

#  Create a new, empty block design within the current project, naming it "system" （acts as a canvas）
create_bd_design system

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
# Import local files from the original project
set files [list \
 [file normalize "./sources/BRAM_Store.v"]\
 [file normalize "./sources/trigger_FSM.v"]\
 [file normalize "./sources/cpu_trig.v"]\
 [file normalize "./sources/controller.v"]\
]

set imported_files ""
foreach f $files {
  lappend imported_files [import_files -fileset sources_1 $f]
}

#  include additional IP cores located in the tmp/cores directory, expanding its library of usable components
set_property IP_REPO_PATHS tmp/cores [current_project]
update_ip_catalog

# Load any additional Verilog files in the project folder
set files [glob -nocomplain projects/$project_name/*.v projects/$project_name/*.sv]
if {[llength $files] > 0} {
  add_files -norecurse $files
}

# ==========================================================================================================
# IP cores

# Create interface ports
set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]

set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]


# Create ports
set led_o [ create_bd_port -dir O -from 7 -to 0 led_o ]
set exp_p_tri_io [ create_bd_port -dir I -from 7 -to 0 exp_p_tri_io ]
set adc_dat_a_in [ create_bd_port -dir I -from 13 -to 0 adc_dat_a_in ]
set adc_dat_b_in [ create_bd_port -dir I -from 13 -to 0 adc_dat_b_in ]

# Create instance: processing_system7_0
set processing_system7_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0]

# Set essential properties
set_property -dict {
    CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {666.666687}
    CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {50}
    CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000}
    CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {111.111115}
    CONFIG.PCW_ACT_USB0_PERIPHERAL_FREQMHZ {60}
    CONFIG.PCW_EN_DDR {1}
    CONFIG.PCW_EN_CLK0_PORT {1}
    CONFIG.PCW_PACKAGE_NAME {clg400}
    CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {DDR 3}
    CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41J128M8 JP-125}
    CONFIG.PCW_USE_M_AXI_GP0 {1}
    CONFIG.PCW_USE_M_AXI_GP1 {1}
} $processing_system7_0

# ----- axi_bram_ctrl_0 -----
set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0 ]
    set_property -dict [list \
    CONFIG.READ_LATENCY {2} \
    CONFIG.SINGLE_PORT_BRAM {1} \
] $axi_bram_ctrl_0

# ----- axi_interconnect_0 -----
set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
    set_property -dict [list \
    CONFIG.NUM_SI {2} \
    CONFIG.STRATEGY {1} \
] $axi_interconnect_0

# ----- rst_ps7_0_50M -----
set rst_ps7_0_50M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ps7_0_50M ]

# ----- blk_mem_gen_0 -----
set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0 ]
    set_property -dict [list \
    CONFIG.Assume_Synchronous_Clk {false} \
    CONFIG.Memory_Type {True_Dual_Port_RAM} \
] $blk_mem_gen_0

# ----- trigger_FSM_0 -----
set block_name trigger_FSM
set block_cell_name trigger_FSM_0
if { [catch {set trigger_FSM_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
    return 1
} elseif { $trigger_FSM_0 eq "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
    return 1
}

# ----- BRAM_Store_0 -----
set block_name BRAM_Store
set block_cell_name BRAM_Store_0
if { [catch {set BRAM_Store_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
    return 1
} elseif { $BRAM_Store_0 eq "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
    return 1
}

# ----- xlslice_0 -----
set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
set_property CONFIG.DIN_WIDTH {8} $xlslice_0

# ----- axi_gpio_1 -----
set axi_gpio_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_1 ]
    set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_IS_DUAL {0} \
] $axi_gpio_1

# ----- xlconstant_0 -----
set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]

# ----- cpu_trig_0 -----
set block_name cpu_trig
set block_cell_name cpu_trig_0
if { [catch {set cpu_trig_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
    return 1
} elseif { $cpu_trig_0 eq "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
    return 1
}

# ----- controller_0-----
set block_name controller
set block_cell_name controller_0
if { [catch {set controller_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
    return 1
} elseif { $controller_0 eq "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
    return 1
}

# ====================================================================================
# Connections

# Create interface connections
connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA]
connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_pins axi_interconnect_0/M01_AXI] [get_bd_intf_pins axi_gpio_1/S_AXI]
connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins axi_interconnect_0/S00_AXI]
connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP1 [get_bd_intf_pins processing_system7_0/M_AXI_GP1] [get_bd_intf_pins axi_interconnect_0/S01_AXI]

# Create port connections
connect_bd_net -net BRAM_Store_0_BRAM_wren [get_bd_pins BRAM_Store_0/BRAM_wren] [get_bd_pins blk_mem_gen_0/web]
connect_bd_net -net BRAM_Store_0_BRAM_write_address [get_bd_pins BRAM_Store_0/BRAM_write_address] [get_bd_pins blk_mem_gen_0/addrb]
connect_bd_net -net BRAM_Store_0_BRAM_write_data [get_bd_pins BRAM_Store_0/BRAM_write_data] [get_bd_pins blk_mem_gen_0/dinb]
connect_bd_net -net adc_dat_a_in_1 [get_bd_ports adc_dat_a_in] [get_bd_pins trigger_FSM_0/adc_A]
connect_bd_net -net adc_dat_b_in_1 [get_bd_ports adc_dat_b_in] [get_bd_pins trigger_FSM_0/adc_B]
connect_bd_net -net axi_gpio_1_gpio_io_o [get_bd_pins axi_gpio_1/gpio_io_o] [get_bd_pins controller_0/data_input]
connect_bd_net -net controller_0_cpu_trig [get_bd_pins controller_0/cpu_trig] [get_bd_pins cpu_trig_0/CPU_trig]
connect_bd_net -net controller_0_led_o [get_bd_pins controller_0/led_o] [get_bd_ports led_o]
connect_bd_net -net controller_0_repetitions [get_bd_pins controller_0/repetitions] [get_bd_pins trigger_FSM_0/max_repetition_cnt]
connect_bd_net -net controller_0_samples [get_bd_pins controller_0/samples] [get_bd_pins trigger_FSM_0/max_sample_cnt]
connect_bd_net -net cpu_trig_0_cpu_flag [get_bd_pins cpu_trig_0/cpu_flag] [get_bd_pins trigger_FSM_0/sniff_trig]
connect_bd_net -net exp_p_tri_io_1 [get_bd_ports exp_p_tri_io] [get_bd_pins xlslice_0/Din]
connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins axi_gpio_1/s_axi_aclk] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins blk_mem_gen_0/clkb] [get_bd_pins rst_ps7_0_50M/slowest_sync_clk] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/M_AXI_GP1_ACLK] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins axi_interconnect_0/S01_ACLK] [get_bd_pins controller_0/clk] [get_bd_pins cpu_trig_0/clk] [get_bd_pins trigger_FSM_0/clk]
connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_ps7_0_50M/ext_reset_in]
connect_bd_net -net rst_ps7_0_50M_peripheral_aresetn [get_bd_pins rst_ps7_0_50M/peripheral_aresetn] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins axi_gpio_1/s_axi_aresetn] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins axi_interconnect_0/S01_ARESETN]
connect_bd_net -net trigger_FSM_0_data_out_A [get_bd_pins trigger_FSM_0/data_out_A] [get_bd_pins BRAM_Store_0/data_out_A]
connect_bd_net -net trigger_FSM_0_data_out_B [get_bd_pins trigger_FSM_0/data_out_B] [get_bd_pins BRAM_Store_0/data_out_B]
connect_bd_net -net trigger_FSM_0_write_address [get_bd_pins trigger_FSM_0/write_address] [get_bd_pins BRAM_Store_0/write_address]
connect_bd_net -net trigger_FSM_0_write_enable [get_bd_pins trigger_FSM_0/write_enable] [get_bd_pins BRAM_Store_0/write_enable]
connect_bd_net -net xlconstant_0_dout [get_bd_pins xlconstant_0/dout] [get_bd_pins blk_mem_gen_0/enb]
connect_bd_net -net xlslice_0_Dout [get_bd_pins xlslice_0/Dout] [get_bd_pins trigger_FSM_0/trig]

# Create address segments
assign_bd_address -offset 0x40000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] -force
assign_bd_address -offset 0x7FFFF000 -range 0x00001000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_1/S_AXI/Reg] -force

# ====================================================================================
# Generate output products and wrapper, add constraint

generate_target all [get_files  $bd_path/system.bd]

make_wrapper -files [get_files $bd_path/system.bd] -top
add_files -norecurse $bd_path/hdl/system_wrapper.v

# temporarily disable the IDR flow property constraints in Vivado
set idrFlowPropertiesConstraints ""
catch {
 set idrFlowPropertiesConstraints [get_param runs.disableIDRFlowPropertyConstraints]
 set_param runs.disableIDRFlowPropertyConstraints 1
}

# Load RedPitaya constraint files
set files [glob -nocomplain cfg/*.xdc]
if {[llength $files] > 0} {
  add_files -norecurse -fileset constrs_1 $files
}

#set_property top system_wrapper [current_fileset]

set_property VERILOG_DEFINE {TOOL_VIVADO} [current_fileset]
set_property STRATEGY Flow_PerfOptimized_High [get_runs synth_1]
set_property STRATEGY Performance_NetDelay_high [get_runs impl_1]
