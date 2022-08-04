// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "hardhat/console.sol";

contract SignatureChecker {
    using ECDSA for bytes32;

    bytes32 public constant CAT = keccak256("Cat");

    function isValidSignature(bytes calldata _signature, address _sender)
        public
        pure
        returns (bool)
    {   
        return CAT.toEthSignedMessageHash().recover(_signature) == _sender;
    }

}