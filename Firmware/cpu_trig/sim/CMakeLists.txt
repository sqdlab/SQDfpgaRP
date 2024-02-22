cmake_minimum_required(VERSION 3.15)

project(trig_fsm_tb)
find_package(verilator HINTS $ENV{VERILATOR_ROOT})

add_executable(VTRIGFSM trig_fsm.cc)

verilate(VTRIGFSM SOURCES ../TRIGFSM.v VERILATOR_ARGS --trace)
