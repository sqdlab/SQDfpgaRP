# User Documentation

## Connect with the Red Pitaya board (Linux)

Start the terminal and type in commands below:
```ssh root@[Red_Pitaya_IP_Address]```

Note: Replace [Red_Pitaya_IP_Address] with the IP address of your board. The steps to find the address can be found in Developer Doc

## Run the script 

Load the Led_blink.bit to xdevcfg with

```redpitaya> cat Led_blink.bit > /dev/xdevcfg```

## Settings

run the python command in User_Interface/setting_wrapper.py as shown in the exmaple:

```
if __name__ == '__main__':   
   monitor = MemoryMonitor(base_addr=0x7FFFF000) # Setting address
 
   # Set repetitions to 2   
   monitor.set_repetition(value=2)
   # Set samples to 4095   
   monitor.set_samples(value=4095)
   # Set hops to 1   
   monitor.set_hops(value=1)
   # Trigger settings independently   
   monitor.trigger_settings(cpu_trig=1)
```

Note: 

- The setting base address must be set as 0x7FFFF000  (If want to change it, then it shall be modified  from the tcl file's address segments part)

- The cpu_trig can be set as 1 after deciding the repetition num, sample num and hop num. 

- The setting_wrapper.py can also be found on the lab's RP-STEM 125-10 board under pc_control folder.

## Plot the result

Run the ~/trigger/a.out on the RP-STEM 125-10 board to read the captured signal into numbers.txt: ```redpitaya> ./a.out```

Copy the numbers.txt result to the PC via scp command:                                                                           
```redpitaya> scp root@<RP-board-ID>:~/trigger/a.out .```

Visualize the result via plt command, for example:
```
import numpy as np
import matplotlib.pyplot as plt

data = np.loadtxt('numbers.txt')
plt.plot(data[:1000], '-o')
```
