#include <stdio.h>
#include <math.h>
#include <stdint.h>

// Credit to https://github.com/embeddedartistry/embedded-resources/
// blob/master/examples/c/fixed_point/simple_fixed_point.c

// If a signed type is used, sign extension may occur, and mess with the
// output of the .hex file
typedef uint16_t fixed_point_t;

#define FIXED_POINT_FRACTIONAL_BITS 14

fixed_point_t double_to_fixed(double input);

inline fixed_point_t double_to_fixed(double input) {
    return (fixed_point_t)(round(input * (1 << FIXED_POINT_FRACTIONAL_BITS)));
}

int main() {
    // Remove the b to prevent accidental overwriting
    FILE* values = fopen("values.hex", "wb");

    fprintf(values, "@0000");

    // A better approach to generating values within each quadrant of a unit
    // circle should be implemented later on, to ensure that a guaranteed number
    // of values are generated per quadrant

    // theta = 0
    fprintf(values, "\n%04x", double_to_fixed(0));
    // 0 < theta < pi/2
    for (double theta = 0.1; theta < M_PI_2; theta += 0.1) {
        fprintf(values, "\n%04x", double_to_fixed(sin(theta)));
    }

    // theta = pi/2
    fprintf(values, "\n%04x", double_to_fixed(1));
    // pi/2 < theta < pi
    for (double theta = M_PI_2 + 0.1; theta < M_PI; theta += 0.1) {
        fprintf(values, "\n%04x", double_to_fixed(sin(theta)));
    }

    // theta = pi
    fprintf(values, "\n%04x", double_to_fixed(0));
    // pi < theta < pi + pi/2
    for (double theta = M_PI + 0.1; theta < M_PI + M_PI_2; theta += 0.1) {
        fprintf(values, "\n%04x", double_to_fixed(sin(theta)));
    }

    // theta = pi + pi/2
    fprintf(values, "\n%04x", double_to_fixed(-1));
    // pi + pi/2 < theta < 2*pi
    for (double theta = M_PI + M_PI_2 + 0.1; theta < 2*M_PI; theta += 0.1) {
        fprintf(values, "\n%04x", double_to_fixed(sin(theta)));
    }

    // theta = 2*pi
    fprintf(values, "\n%04x", double_to_fixed(0));

    return 0;
}
