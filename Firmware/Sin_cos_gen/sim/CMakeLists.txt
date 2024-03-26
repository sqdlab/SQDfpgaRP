cmake_minimum_required(VERSION 3.15)

project(trig_test)
find_package(verilator HINTS $ENV{VERILATOR_ROOT})

add_executable(VTRIG main.cc)

verilate(VTRIG SOURCES ../sine_and_cosine_generator.v TOP_MODULE sine_and_cosine_generator VERILATOR_ARGS --trace)