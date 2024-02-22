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
  

  for (int n = 0; n < 100; n++)
  {
    top->clk = 1;
    wait_n_cycles(1000);
    top->eval(); 

    top->clk = 0;
    wait_n_cycles(1000);
    top->eval(); 

    num_TCY++;
    
    if ((num_TCY > 23 && num_TCY < 25)|| (num_TCY > 5 && num_TCY < 7) || (num_TCY > 50 && num_TCY < 52) || (num_TCY > 70 && num_TCY < 72) || (num_TCY > 90 && num_TCY < 92))
    {
      top->write_finished = 1;
    }
    else
      top->write_finished = 0;

    if ((num_TCY > 11 && num_TCY < 13) || (num_TCY > 23 && num_TCY < 28)|| (num_TCY > 50 && num_TCY < 52) || (num_TCY > 70 && num_TCY < 72) || (num_TCY > 90 && num_TCY < 92))
    {
      top->CPU_trig = 1;
      printf("It's working!");
    }
    else
      top->CPU_trig= 0;

    //top->adc_A = num_TCY;
    //top->adc_B = num_TCY+128;



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
