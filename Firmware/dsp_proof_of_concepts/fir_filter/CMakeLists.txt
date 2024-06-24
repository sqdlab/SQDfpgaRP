cmake_minimum_required(VERSION 3.15)

project(fir_test)
find_package(verilator HINTS $ENV{VERILATOR_ROOT})

add_executable(VFIR main.cc)

verilate(VFIR SOURCES fir_filter.v TOP_MODULE fir_filter VERILATOR_ARGS --trace)