#include "verilated.h"
#include "VTRIGFSM.h"
#include <stdio.h>

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

  VTRIGFSM* top = new VTRIGFSM();


  int num_TCY = 0;
  

  for (int n = 0; n < 300; n++)
  {
    top->clk = 1;
    wait_n_cycles(1000);
    top->eval(); 

    top->clk = 0;
    wait_n_cycles(1000);
    top->eval(); 

    num_TCY++;

    top->max_sample_cnt = 10;
    top->max_repetition_cnt = 2;
    
    if (num_TCY == 24 || num_TCY == 115)
      top->sniff_trig = 1;
    else
      top->sniff_trig = 0;

    if (num_TCY == 12 || num_TCY == 29 || num_TCY == 51 || num_TCY == 71 || num_TCY == 91 || num_TCY == 121 || num_TCY == 141 || num_TCY == 161)
    {
      top->trig = 1;
      printf("It's working!");
    }
    else
      top->trig = 0;

    top->adc_A = num_TCY;
    top->adc_B = num_TCY+128;



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
