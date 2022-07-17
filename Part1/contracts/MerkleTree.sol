//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        for (uint256 i = 0; i < 8; i++) { 
            hashes.push(0); // level 3 (leaves)
        }

        for (uint256 pos = 0; pos < 13; pos = pos + 2) {
            hashes.push(PoseidonT3.poseidon([hashes[pos], hashes[pos+1]])); 
        }

        root = hashes[14];
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        require(index < 8, "Merkle tree is full");

        hashes[index] = hashedLeaf;

        // This is easy (same as above) but inneficient:
        // for (i = 0; i < 7; i++) {
        //     hashes.pop();
        // }
        // for (uint256 pos = 0; pos < 13; pos = pos + 2) {
        //     hashes.push(PoseidonT3.poseidon([hashes[pos], hashes[pos+1]])); 
        // }

        uint256 newIndex = index + 1;
        for (uint256 updates = 0; updates < 3; updates++) {
            uint256 next_pos = index / 2 + 8;
            if (index % 2 == 0) {
                hashes[next_pos] = PoseidonT3.poseidon([hashes[index], hashes[index+1]]);
            } else {
                hashes[next_pos] = PoseidonT3.poseidon([hashes[index-1], hashes[index]]);
            }
            index = next_pos;
        }

        index = newIndex;

        root = hashes[14];

        return root; // what should the return be? new root or new index?
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root

        // function verifyProof(
        //     uint[2] memory a,
        //     uint[2][2] memory b,
        //     uint[2] memory c,
        //     uint[1] memory input
        // ) public view returns (bool r) {
        //          ...
        // if (verify(inputValues, proof) == 0) {
        //     return true;
        // } else {
        //     return false;
        // }

        return verifyProof(a, b, c, input);
    }
}
