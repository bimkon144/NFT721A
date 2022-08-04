// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface ISignatureChecker {

  function isValidSignature(bytes calldata signature, address sender) external view returns (bool);

}
