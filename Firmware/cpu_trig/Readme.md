# cpu_trig

This module is a simple FSM that handles handshaking with cpu
```
module cpu_trig(
    clk, // synchronized clock input
    write_finished, // input flag that indicate it's ready for new data
    CPU_trig, // input trig that indicate the ctrl bit of cpu is high
    cpu_flag // output as the sniff trig
    );
```
