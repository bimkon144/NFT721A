// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "hardhat/console.sol";

contract BimkonEyes is ERC721A, Ownable {
  uint256 public constant MAX_SUPPLY = 2000;
  uint256 public constant MAX_PUBLIC_MINT = 10;
  uint256 public constant MAX_WHITELIST_MINT = 3;
  uint256 public constant MAX_AIRDROP_MINT = 2;
  uint256 public publicSalePrice = 1 ether;
  uint256 public whiteListSalePrice = 0.5 ether;

  string private _baseTokenUri;
  string public placeholderTokenUri;

  //deploy smart contract, toggle WL, toggle WL when done, toggle publicSale
  //2 days later toggle reveal
  bool public isRevealed;
  bool public publicSale;
  bool public whiteListSale;
  bool public airDrop;
  // bool public teamMinted;

  bytes32 private _merkleRootWhiteList;
  bytes32 private _merkleRootAirDrop;

  mapping(address => uint256) public totalPublicMint;
  mapping(address => uint256) public totalWhitelistMint;
  mapping(address => uint256) public totalAirdropMint;

  event SentNFT(address _token, address _sender, uint256[] _tokenIds);

  constructor() ERC721A("BimkonEyes", "BYS") {}

  modifier callerIsUser() {
    require(
      tx.origin == msg.sender,
      "BimkonEyes :: Cannot be called by a contract"
    );
    _;
  }

  modifier isBeyondMaxSupply(uint256 _quantity) {
    require(
      (totalSupply() + _quantity) <= MAX_SUPPLY,
      "BimkonEyes :: Beyond Max Supply"
    );
    _;
  }

  function mint(uint256 _quantity)
    external
    payable
    callerIsUser
    isBeyondMaxSupply(_quantity)
  {
    require(publicSale, "BimkonEyes :: Not Yet Active.");

    require(
      (totalPublicMint[msg.sender] + _quantity) <= MAX_PUBLIC_MINT,
      "BimkonEyes :: Cant mint more!"
    );
    require(
      msg.value >= (publicSalePrice * _quantity),
      "BimkonEyes :: low sent ether"
    );
    //todo use aux for track limits
    totalPublicMint[msg.sender] += _quantity;
    _safeMint(msg.sender, _quantity);
  }

  function whitelistMint(bytes32[] memory _merkleProof, uint256 _quantity)
    external
    payable
    callerIsUser
    isBeyondMaxSupply(_quantity)
  {
    require(whiteListSale, "BimkonEyes :: Minting is on Pause");

    require(
      (totalWhitelistMint[msg.sender] + _quantity) <= MAX_WHITELIST_MINT,
      "BimkonEyes :: Cannot mint beyond whitelist max mint!"
    );
    require(
      msg.value >= (whiteListSalePrice * _quantity),
      "BimkonEyes :: Payment is below the price"
    );
    //create leaf node
    bytes32 sender = keccak256(abi.encodePacked(msg.sender));
    require(
      MerkleProof.verify(_merkleProof, _merkleRootWhiteList, sender),
      "BimkonEyes :: You are not whitelisted"
    );
    //todo use aux for track limits
    totalWhitelistMint[msg.sender] += _quantity;
    _safeMint(msg.sender, _quantity);
  }

  function claimAirdrop(bytes32[] memory _merkleProof, uint256 _quantity)
    external
    isBeyondMaxSupply(_quantity)
  {
    require(airDrop, "BimkonEyes :: airDrop is on Pause");
    require(
      (totalAirdropMint[msg.sender] + _quantity) <= MAX_AIRDROP_MINT,
      "BimkonEyes :: Cannot mint beyond airdrop max mint!"
    );
    //create leaf node
    bytes32 sender = keccak256(abi.encodePacked(msg.sender));
    require(
      MerkleProof.verify(_merkleProof, _merkleRootAirDrop, sender),
      "BimkonEyes :: You are not allowed to claim DROP"
    );
    //todo use aux for track limits
    totalAirdropMint[msg.sender] += _quantity;
    _safeMint(msg.sender, _quantity);
  }

  function canClaimAirDrop(bytes32[] memory _merkleProof)
    external
    view
    returns (bool)
  {
    return
      MerkleProof.verify(
        _merkleProof,
        _merkleRootAirDrop,
        keccak256(abi.encodePacked(msg.sender))
      );
  }

  function isWhiteListed(bytes32[] memory _merkleProof)
    external
    view
    returns (bool)
  {
    return
      MerkleProof.verify(
        _merkleProof,
        _merkleRootWhiteList,
        keccak256(abi.encodePacked(msg.sender))
      );
  }

  function allowedToClaimDropAmount() external view returns (uint256) {
    return MAX_AIRDROP_MINT - totalAirdropMint[msg.sender];
  }

  function allowedToWhiteListMintAmount() external view returns (uint256) {
    return MAX_WHITELIST_MINT - totalWhitelistMint[msg.sender];
  }

  function allowedToPublicMintAmount() external view returns (uint256) {
    return MAX_PUBLIC_MINT - totalPublicMint[msg.sender];
  }

  function teamMint(uint256 _quantity) external onlyOwner {
    // require(!teamMinted, "BimkonEyes :: Team already minted");
    // teamMinted = true;
    _safeMint(msg.sender, _quantity);
  }

  function _baseURI() internal view override returns (string memory) {
    return _baseTokenUri;
  }

  //return uri for certain token
  function tokenURI(uint256 tokenId)
    public
    view
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    uint256 trueId = tokenId + 1;

    if (!isRevealed) {
      return placeholderTokenUri;
    }

    return
      bytes(_baseTokenUri).length > 0
        ? string(abi.encodePacked(_baseTokenUri, _toString(trueId), ".json"))
        : "";
  }

  function setPublicSalePrice(uint256 _price) external onlyOwner {
    publicSalePrice = _price;
  }

  function setWhiteListSalePrice(uint256 _price) external onlyOwner {
    whiteListSalePrice = _price;
  }

  function setTokenUri(string memory baseTokenUri_) external onlyOwner {
    _baseTokenUri = baseTokenUri_;
  }

  function setPlaceHolderUri(string memory _placeholderTokenUri)
    external
    onlyOwner
  {
    placeholderTokenUri = _placeholderTokenUri;
  }

  function setMerkleRootWhiteList(bytes32 merkleRoot_) external onlyOwner {
    _merkleRootWhiteList = merkleRoot_;
  }

  function setMerkleRootAirDrop(bytes32 merkleRoot_) external onlyOwner {
    _merkleRootAirDrop = merkleRoot_;
  }

  function getMerkleRootWhiteList() external view returns (bytes32) {
    return _merkleRootWhiteList;
  }

  function getMerkleRootAirDrop() external view returns (bytes32) {
    return _merkleRootAirDrop;
  }

  function toggleWhiteListSale() external onlyOwner {
    whiteListSale = !whiteListSale;
  }

  function toggleAirDrop() external onlyOwner {
    airDrop = !airDrop;
  }

  function togglePublicSale() external onlyOwner {
    publicSale = !publicSale;
  }

  function toggleReveal() external onlyOwner {
    isRevealed = !isRevealed;
  }

  function multiSendERC721(
    IERC721A _token,
    address[] calldata _to,
    uint256[] calldata _id
  ) external {
    require(_to.length == _id.length, "the arrays are different length");
    uint256 currentIndex = 0;
    uint256[] memory _transferredTokenIds = new uint256[](_id.length);
    for (uint256 i = 0; i < _to.length; i++) {
      if (_to[i] != address(0)) {
        IERC721A(_token).safeTransferFrom(msg.sender, _to[i], _id[i]);
        _transferredTokenIds[currentIndex] = _id[i];
        currentIndex += 1;
      }
    }
    emit SentNFT(address(_token), msg.sender, _transferredTokenIds);
  }

  function withdraw(address _to, uint256 _value) external onlyOwner {
    (bool success, ) = _to.call{value: _value}("");
    require(success, "Failed to send native assets");
  }
}
