#include "verilated.h"
#include <math.h>
#include <stdio.h>
#include "Vfir_filter.h"

typedef uint32_t fixed_point_t;

#define FIXED_POINT_FRACTIONAL_BITS 27

fixed_point_t double_to_fixed(double input);

inline fixed_point_t double_to_fixed(double input) {
    return (fixed_point_t)(round(input * (1 << FIXED_POINT_FRACTIONAL_BITS)));
}

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

  Vfir_filter* top = new Vfir_filter();
  top->rst_active_low = 1;

  // double values[4000];
  // get_values(values);
  // Simulate 20 clock cycles
  
  int x, r;
  int y, q;
  for (double n = 0; n < 100*M_PI; n += 5) {
    struct { signed int x : FIXED_POINT_FRACTIONAL_BITS + 2; } s;
    r = s.x = x = double_to_fixed( sin(remainder(n, 2*M_PI)) );
    top->data_in = r;
    top->fir_clk = 0;
    // wait_n_cycles(1);
    top->eval(); 

    top->fir_clk = 1;
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