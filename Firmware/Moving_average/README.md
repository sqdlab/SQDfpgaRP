# Moving Average

This module takes in n number of values and takes the average of those values.
```
module moving_average #(
    parameter INPUT_WIDTH = 16, // input width of the values
    parameter AVERAGE_INPUTS = 4, // number of inputs to average, and directly impacts the size of the value buffer
    parameter MULTIPLICATIVE_INVERSE = 2'b01, // multiplicative inverse that is used to divide the inputs. It is assumed at all bits are fractional, and therefore the number of fractional bits corresponds to the number of leftwards shifts in the binary point
    parameter INVERSE_WIDTH = 2 // number of bits needed to store the multiplicative inverse 
) (
    input clk, // synchronised clock input
    input rst_active_low, // active low reset input that should clear the buffer. It has not yet been implemented
    input signed [INPUT_WIDTH-1:0] data_in, // data input
    output signed [INPUT_WIDTH-1:0] data_out, // nth last data input, where n is the number of inputs to average by. This is where the data input exits once out of the buffer
    output signed [INPUT_WIDTH+AVERAGE_INPUTS+INVERSE_WIDTH-1:0] average_out // the average of the nth last inputs, where n is the number of inputs to average by
);
```

As a comment above states, the reset mechanism has not been implemented yet.