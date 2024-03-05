import fxpmath
import scipy as sc
import sys
import matplotlib.pyplot as plt
from fxpmath import Fxp
import numpy as np

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: coefficient_generator.py normalised_cutoff_frequency\n")
    else:
        try:
            float(sys.argv[1])
            coefficients = sc.signal.firwin(40, float(sys.argv[1]), window="hamming", pass_zero="lowpass")
        except ValueError:
            print("normalised_cutoff_frequency must be a number.")
            sys.exit(1)

    # hex_values = [x for x in coefficients if "a" in x]

    hex_values = []
    for coefficient in coefficients:
        hex_values.append(fxpmath.Fxp(coefficient, signed=True, n_word=16, n_frac=16).hex(prefix=""))

    with open("fir_values.mem", "w") as values:
        values.write("\n".join(hex_values))

    sys.exit(0)