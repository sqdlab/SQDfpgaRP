# Repetition_trig

This module is a simple FSM that handles the external trigger logic with determined number of sampels and repetitions
```
module Repetition_trig(
    clk, // synchronized clock input
    adc_A, // ADC input from the "IN1" channel on the board
    adc_B, // ADC input from the "IN2" channel on the board
    trig, // external trigger input
    sniff_trig, // cpu trigger provided by the cpu_trig module
    data_out_A, // ADC output obtained from "IN1" channel on the board
    data_out_B, // ADC output obtained from "IN2" channel on the board
    write_enable, // output flag to control the write behavior to BRAM
    write_address); // the output address to write to in BRAM
```
Note that both 125-10 and 125-14 has 14 bit ADC input. For 125-10, only 10 of the 14 bits are valid [the bits 0 (LSB) to 3 of the ADC output bus connected to ground, and therefore can be ignored]. For 125-14, all 14 bits are valid.