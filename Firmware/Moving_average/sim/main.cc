#include "verilated.h"
#include <math.h>
#include <stdio.h>
#include "Vmoving_average.h"

void wait_n_cycles(int n);

// Keep track of simulation time (64-bit unsigned)
vluint64_t main_time = 0;

// Called by $time in Verilog an needed to trace waveforms
double sc_time_stamp() {
    return main_time;  // Note does conversion to real, to match SystemC
}

int main(int argc, char ** argv) {

  Verilated::commandArgs(argc, argv);

  Verilated::traceEverOn(true);

  Vmoving_average* top = new Vmoving_average();
  top->rst_active_low = 1;

  // double values[4000];
  // get_values(values);
  // Simulate 20 clock cycles

  for (int idx = 0; idx < 128; idx += 1) {
    top->data_in = idx;
    top->clk = 0;
    // wait_n_cycles(1);
    top->eval(); 

    top->clk = 1;
    wait_n_cycles(1);
    top->eval(); 

    main_time++;  
  }

  delete top;

  exit(0);

}

void wait_n_cycles(int n) {
  for (int i = 0; i < n; i++) { 
    main_time++;
  }
}
