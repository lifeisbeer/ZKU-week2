pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

// template test() {
//     signal input vals[2];
//     signal input choice;
//     signal output res;

//     component p = Poseidon(2);

//     if (choice == 0) {
//         p.inputs[0] <-- vals[0];   
//         p.inputs[1] <-- vals[1]; 
//     } else {
//         p.inputs[0] <-- vals[1];
//         p.inputs[1] <-- vals[0];
//     } 

//     p.inputs[0] <-- choice == 0? vals[0] : vals[1];  
//     p.inputs[1] <-- choice == 1? vals[0] : vals[1];  
// }

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves

    // template Poseidon(nInputs) {  
    //    signal input inputs[nInputs];
    //    signal output out;
    // ...

    component p[2**(n)-1]; // will need 2**(n)-1 Poseidon hashes

    // calculate all the hashes from leaves (level n-1)
    for (var i = 0; i < 2**(n-1); i++) {
        p[i] = Poseidon(2);
        p[i].inputs[0] <== leaves[2*i]; // 0, 2, 4, ...
        p[i].inputs[1] <== leaves[2*i+1]; // 1, 3, 5, ...
    }

    // calculate all other levels of the tree (level n-2, n-3, ..., 0)
    var c = 0;
    for (var pos = 2**(n-1); pos < 2**(n)-1; pos++) {
        p[pos] = Poseidon(2);
        p[pos].inputs[0] <== p[c].out;
        p[pos].inputs[1] <== p[c + 1].out;
        c = c + 2;
    }

    root <== p[2**n-2].out;


    // First attempt where I didn't notice that theleaves are already hashed, please ignore - keeping here for future reference
    // component p[2**(n+1)-1]; // will need 2**(n+1)-1 Poseidon hashes

    // // calculate all the leave hashes
    // for (var i = 0; i < 2**n; i++) {
    //     p[i] = Poseidon(1);
    //     p[i].inputs[0] <== leaves[i];
    // }

    // // calculate each level of the tree
    // var c = 0;
    // for (var level = n; level > 0; level--) {
    //     for (var i = 0; i < 2**(level-1); i++) {
    //         p[2**level + i] = Poseidon(2);
    //         p[2**level + i].inputs[0] <== p[c].out;
    //         p[2**level + i].inputs[1] <== p[c + 1].out;
    //         c = c + 2;
    //     }
    // }

    // root <== p[2**(n+1)-2].out;
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path

    component p[n]; // will need n Poseidon hashes

    // deal with the leaf
    p[0] = Poseidon(2);
    p[0].inputs[0] <-- path_index[0] == 0? path_elements[0] : leaf; // "Non quadratic constraints are not allowed!": must be only assignment (<--), not assignment and constraint (<==)
    p[0].inputs[1] <-- path_index[0] == 1? path_elements[0] : leaf;

    for (var i = 1; i < n; i++) { // for every level of the tree
        p[i] = Poseidon(2);
        p[i].inputs[0] <-- path_index[i] == 0? path_elements[i] : p[i-1].out;
        p[i].inputs[1] <-- path_index[i] == 1? path_elements[i] : p[i-1].out;
    }

    root <== p[n-1].out;

    // First attempt which doesn't work, please ignore

    // p[0] = Poseidon(2);
            
    // if (path_index[0] == 0) { // if the path element is on the left
    //     p[0].inputs[0] <== path_elements[0];   
    //     p[0].inputs[1] <== leaf; 
    // } else { // if the path element is on the right
    //     p[0].inputs[0] <== leaf;
    //     p[0].inputs[1] <== path_elements[0];
    // }

    // for (var i = 1; i < n; i++) { // for every level of the tree
    //     p[i] = Poseidon(2);
        
    //     if (path_index[i] == 0) { // if the path element is on the left
    //         p[i].inputs[0] <== path_elements[i];   
    //         p[i].inputs[1] <== p[i-1].out; 
    //     } else { // if the path element is on the right
    //         p[i].inputs[0] <== p[i-1].out;
    //         p[i].inputs[1] <== path_elements[i];
    //     }
    // }
}