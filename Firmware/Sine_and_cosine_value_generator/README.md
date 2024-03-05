# Sine and cosine value generator

This module outputs sine and cosine values starting from 0 and 1 respectively. The angular frequency of sine and cosine are affected by the ```hop_amount`` input, which has a direct proportionality to the angular frequency of sine and cosine.
```
module sine_and_cosine_generator #(
    parameter OUTPUT_WIDTH = 16 // The output width of the sine and cosine values. This is dependent on the width of the samples used.
) (
    input gen_clk, // synchronised clock input
    input [5:0] hop_amount, // the increment between the samples outputted every clock cycle, which directly impacts the angular frquency of the sine and cosine output
    input rst_active_low, // resets sine to 0 and cosine to 1, thus starting them back to sin(0) and cos(0) respectively
    output reg [OUTPUT_WIDTH-1:0] sine_value, // the output of sine at a given clock cycle
    output reg [OUTPUT_WIDTH-1:0] cosine_value // the output of sine at a given clock cycle
);
```

Both sine and cosine are functions of time with respect to the clock cycle, meaning that a faster FPGA clock will lead to sine and cosine having a higher angular frequency. This should be kept in mind when setting the ```hop_amount`` input.

```sine_and_cosine_generator.v``` depends directly on a .hex file that contains the samples to store. This .hex file can be generated with ```trigonometry_value_generator.c``` found at the path ```..\..\utilities\Trigonometry_value_generator\trigonometry_value_generator.c```, which is relative to the path of this file. However, for your convenience a samples .hex file has been provided within this folder.