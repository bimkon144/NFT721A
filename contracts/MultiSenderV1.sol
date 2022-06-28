// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "hardhat/console.sol";

contract MultiSenderV1 {
  using SafeERC20 for IERC20;

  event Sent(address _token, address _sender, uint256 _totalAmount);
  event SentNative(address _sender, uint256 _totalAmount);
  event SentNFT(address _token, address _sender, uint256[] _tokenIds);

  modifier onlySameArrayLength(
    address[] calldata _accounts,
    uint256[] calldata _amounts
  ) {
    require(
      _accounts.length == _amounts.length,
      "the arrays are different length"
    );
    _;
  }

  function multiSendToken(
    address _token,
    address[] calldata _accounts,
    uint256[] calldata _amounts
  ) external onlySameArrayLength(_accounts, _amounts) {
    uint256 _transferredTokens;
    for (uint256 i = 0; i < _accounts.length; i++) {
      if (_accounts[i] != address(0) && _amounts[i] > 0) {
        IERC20(_token).safeTransferFrom(msg.sender, _accounts[i], _amounts[i]);
        _transferredTokens += _amounts[i];
      }
    }
    emit Sent(_token, msg.sender, _transferredTokens);
  }

  function multiSendNativeToken(
    address[] calldata _accounts,
    uint256[] calldata _amounts
  ) external payable onlySameArrayLength(_accounts, _amounts) {
    uint256 _transferredETH;
    for (uint256 i = 0; i < _accounts.length; i++) {
      if (_accounts[i] != address(0) && _amounts[i] > 0) {
        _safeTransferETH(_accounts[i], _amounts[i]);
        _transferredETH += _amounts[i];
      }
    }
    uint256 change = msg.value - _transferredETH;

    if (change > 0) {
      _safeTransferETH(msg.sender, change);
    }
    emit SentNative(msg.sender, _transferredETH);
  }

  function multiSendERC721(
    IERC721 _token,
    address[] calldata _to,
    uint256[] calldata _id
  ) external onlySameArrayLength(_to, _id) {
    uint256 currentIndex = 0;
    uint256[] memory _transferredTokenIds = new uint256[](_id.length);
    for (uint256 i = 0; i < _to.length; i++) {
      if (_to[i] != address(0)) {
        IERC721(_token).safeTransferFrom(msg.sender, _to[i], _id[i]);
        _transferredTokenIds[currentIndex] = _id[i];
        currentIndex += 1;
      }
    }
    emit SentNFT(address(_token), msg.sender, _transferredTokenIds);
  }

  function multiSendERC1155(
    IERC1155 _token,
    address[] calldata _to,
    uint256[] calldata _id,
    uint256[] calldata _amount
  ) external onlySameArrayLength(_to, _id) {
    require(
      _to.length == _amount.length,
      "Receivers and amounts are different length"
    );
    uint256 currentIndex = 0;
    uint256[] memory _transferredTokenIds = new uint256[](_id.length);
    for (uint256 i = 0; i < _to.length; i++) {
      if (_to[i] != address(0) && _amount[i] > 0) {
        IERC1155(_token).safeTransferFrom(
          msg.sender,
          _to[i],
          _id[i],
          _amount[i],
          ""
        );
        _transferredTokenIds[currentIndex] = _id[i];
        currentIndex += 1;
      }
    }
    emit SentNFT(address(_token), msg.sender, _transferredTokenIds);
  }

  function _safeTransferETH(address to, uint256 value) private {
    (bool success, ) = to.call{value: value}("");
    require(success, "Failed to send native assets");
  }
}
