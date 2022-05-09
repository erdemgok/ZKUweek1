
pragma circom 2.0.3;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib-matrix/circuits/matElemSum.circom"; // hint: you can use more than one templates in circomlib-matrix to help you


// scalar multiplication of matrix
// I modified this template from circomlib-matrix since needing array type of scalar 
template matScalarMul (m,n) {
    signal input a[m][n];
    signal input s[n];
    signal output out[m][n];
    
    for (var i=0; i < m; i++) {
        for (var j=0; j < n; j++) {
            out[i][j] <== a[i][j] * s[j]; // multiply correct elements.
        }
    }
}


// sum of elements of array
template sum(n) {
    signal input in[n];
    signal output out;

    var sum;

    for(var i=0; i<n; i++) {
        sum += in[i];
    }

    out <-- sum;
}


template SystemOfEquations(n) { // n is the number of variables in the system of equations
    signal input x[n]; // this is the solution to the system of equations
    signal input A[n][n]; // this is the coefficient matrix
    signal input b[n]; // this are the constants in the system of equations
    signal output out; // 1 for correct solution, 0 for incorrect solution

    // [bonus] insert your code here
    signal sum1; // intermediate signal sum of b[n]
    signal matout[n][n]; //intermeadiate signal x[n] * A[n][n]

    component mul = matScalarMul(n,n);
    component bsum = sum(n);

    for(var i=0; i<n; i++){

        bsum.in[i] <== b[i];
        mul.s[i] <== x[i];
        
        for(var j=0; j<n; j++){
            mul.a[i][j] <== A[i][j];     
        }
    }
    
    sum1 <== bsum.out;
    
    for (var i=0; i<n; i++) {
        for(var j=0; j<n; j++) {          
            matout[i][j] <== mul.out[i][j];
        }
    }

    component sum = matElemSum (n,n); // sum of elements of a matrix
    signal finalsum;

    for (var i=0; i<n; i++) {
        for(var j=0; j<n; j++) {
            matout[i][j] ==> sum.a[i][j];
        }
    }

    

    sum.out ==> finalsum;

    component equal = IsEqual(); // check sum of b[n] is equal to sum of matrix

    equal.in[0] <== finalsum;
    equal.in[1] <== sum1;

    out <== equal.out; 


}

component main {public [A, b]} = SystemOfEquations(3);