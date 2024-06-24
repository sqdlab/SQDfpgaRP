# ==================================================================================================
# make.tcl - This script will recreate a Vivado project by commands for creating a project, filesets, 
# runs, adding/importing sources and setting properties on various objects.
#
# This script must be run as "source make.tcl" under the base SQDfpgaRP/Working_version folder inside
#  Vivado tcl console.
#
# This script is modification of Anton Potocnik's make_project.tcl files by Junjia Yang, 08/02/2023
# ==================================================================================================

set project_name iq_demodulation_hdl
set part_name xc7z010clg400-1
set bd_path results/$project_name/$project_name.srcs/sources_1/bd/system

file delete -force results/$project_name

create_project $project_name results/$project_name -part $part_name

# ===================================================================================================
# General prepare settings

#  Create a new, empty block design within the current project, naming it "system" （acts as a canvas）
create_bd_design system

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
# Import local files from the original project
set files [list \
 [file normalize "./bram_store/BRAM_Store.v"]\
 [file normalize "./multiplier/multiplier_wrapper.v"]\
 [file normalize "./multiplier/mult_gen_0.xci"]\
 [file normalize "./Repetition_trig/TRIGFSM.v"]\
 [file normalize "./Controller_FSM/TRIGFSM.v"]\
 [file normalize "./Sin_cos_gen/sin_cos_gen.v"]\
 [file normalize "./values.hex"]\
 [file normalize "./main.v"]\
]

# Save current instance; Restore later
set oldCurInst [current_bd_instance .]
# CHANGE DESIGN NAME HERE
set design_name system

set imported_files ""
foreach f $files {
  lappend imported_files [import_files -fileset sources_1 $f]
}

#  include additional IP cores located in the results/cores directory, expanding its library of usable components
set_property IP_REPO_PATHS results/cores [current_project]
update_ip_catalog

# Load any additional Verilog files in the project folder
set files [glob -nocomplain projects/$project_name/*.v projects/$project_name/*.sv]
if {[llength $files] > 0} {
  add_files -norecurse $files
}

# ==========================================================================================================
# IP cores

# Create interface ports
set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]

set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]

set AXI_TO_GPIO [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 AXI_TO_GPIO ]

set BRAM_PORTB [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:bram_rtl:1.0 BRAM_PORTB ]
set_property -dict [ list \
CONFIG.MASTER_TYPE {BRAM_CTRL} \
CONFIG.READ_WRITE_MODE {READ_WRITE} \
] $BRAM_PORTB

# Create ports
set sys_clk [ create_bd_port -dir O -type clk sys_clk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {50000000} \
 ] $sys_clk
  set sys_aresetn [ create_bd_port -dir O -from 0 -to 0 -type rst sys_aresetn ]


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

# ----- axi_gpio_1 -----
set axi_gpio_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_1 ]
    set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_IS_DUAL {0} \
] $axi_gpio_1

# ====================================================================================
# Connections

# Create interface connections
connect_bd_intf_net -intf_net BRAM_PORTB_1 [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTB] [get_bd_intf_ports BRAM_PORTB]
connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA]
connect_bd_intf_net -intf_net axi_gpio_1_GPIO [get_bd_intf_pins axi_gpio_1/GPIO] [get_bd_intf_ports AXI_TO_GPIO]
connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_pins axi_interconnect_0/M01_AXI] [get_bd_intf_pins axi_gpio_1/S_AXI]
connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins axi_interconnect_0/S00_AXI]
connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP1 [get_bd_intf_pins processing_system7_0/M_AXI_GP1] [get_bd_intf_pins axi_interconnect_0/S01_AXI]

# Create port connections
connect_bd_net -net ACLK_1 [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins axi_gpio_1/s_axi_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins axi_interconnect_0/S01_ACLK] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins rst_ps7_0_50M/slowest_sync_clk] [get_bd_pins processing_system7_0/M_AXI_GP1_ACLK] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_ports sys_clk]
connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_ps7_0_50M/ext_reset_in]
connect_bd_net -net rst_ps7_0_50M_peripheral_aresetn [get_bd_pins rst_ps7_0_50M/peripheral_aresetn] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins axi_gpio_1/s_axi_aresetn] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins axi_interconnect_0/S01_ARESETN] [get_bd_ports sys_aresetn]

# Create address segments
assign_bd_address -offset 0x40000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] -force
assign_bd_address -offset 0x7FFFF000 -range 0x00001000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_1/S_AXI/Reg] -force

# Restore current instance
current_bd_instance $oldCurInst

validate_bd_design
save_bd_design
close_bd_design $design_name 
# ====================================================================================
# Generate output wrapper, add constraint
# Create the directory if it doesn't exist
# file mkdir $bd_path

generate_target all [get_files  $bd_path/system.bd]

# make_wrapper -files [get_files $bd_path/system.bd] -top
# add_files -norecurse $bd_path/hdl/system_wrapper.v

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
# set_property VERILOG_DEFINE {TOOL_VIVADO} [current_fileset]
# set_property STRATEGY Flow_PerfOptimized_High [get_runs synth_1]
# set_property STRATEGY Performance_NetDelay_high [get_runs impl_1]

# Create HDL wrapper for the block design
if { [get_property IS_LOCKED [get_files -norecurse [list $bd_path/system.bd]]] == 1 } {
  import_files -fileset sources_1 [file normalize "${bd_path}/hdl/system_wrapper.v"]
} else {
  set wrapper_path [make_wrapper -fileset sources_1 -files [get_files -norecurse [list $bd_path/system.bd]] -top]
  add_files -norecurse -fileset sources_1 $wrapper_path
}


