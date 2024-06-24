#include "verilated.h"
#include "Vsine_and_cosine_generator.h"

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

  Vsine_and_cosine_generator* top = new Vsine_and_cosine_generator();
  top->hop_amount = 7;
  top->rst_active_low = 1;

  // Simulate 20 clock cycles
  for (int n = 0; n < 128; n++) {
    top->gen_clk = 1;
    wait_n_cycles(1000);
    top->eval(); 

    top->gen_clk = 0;
    wait_n_cycles(1000);
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