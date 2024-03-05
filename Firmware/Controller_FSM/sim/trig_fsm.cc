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
    

    if (num_TCY == 29)
    {
      top->data_input = 0xfe000002; //32'b1111_1110_0000_0000_0000_0000_0000_0010
      printf("MSB=1, REP=2\n");
    } else if (num_TCY == 58)
    {
      top->data_input =0x7C000064; //32'b0111_1100_0000_0000_0000_0000_0110_0100
      printf("MSB=0, SAMP=100\n");
      top->clk = 1;
      wait_n_cycles(1000);
      top->eval(); 

      top->clk = 0;
      wait_n_cycles(1000);
      top->eval(); 
      num_TCY++;
    } else if (num_TCY == 79)
    {
      top->data_input = 0b01111100000000000000000001100101; //32'b0111_1100_0000_0000_0000_0000_0110_0101
      printf("MSB=0, SAMP=101\n");
    } else if (num_TCY == 116)
    {
      top->data_input = 0x81000065; //32'b1000_0001_0000_0000_0000_0000_0110_0101
      printf("MSB=1, CPU=1\n");
    }




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
