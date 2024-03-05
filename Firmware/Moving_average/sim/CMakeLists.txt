cmake_minimum_required(VERSION 3.15)

project(moving_average)
find_package(verilator HINTS $ENV{VERILATOR_ROOT})

add_executable(VAVERAGE main.cc)

verilate(VAVERAGE SOURCES ../moving_average.v TOP_MODULE moving_average VERILATOR_ARGS --trace)
