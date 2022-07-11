// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "erc721a/contracts/ERC721A.sol";

contract BimkonEyes is ERC721A, Ownable, AccessControl {
  uint256 public constant MAX_SUPPLY = 2000;
  uint256 public constant MAX_PUBLIC_MINT = 10;
  uint256 public constant MAX_WHITELIST_MINT = 3;
  uint256 public constant MAX_AIRDROP_MINT = 2;
  uint256 public publicSalePrice = 1 ether;
  uint256 public whiteListSalePrice = 0.5 ether;
  bytes32 public constant PRICE_MANAGER_ROLE = keccak256("PRICE_MANAGER_ROLE");
  bytes32 public constant SELL_PHASE_MANAGER_ROLE = keccak256("SELL_PHASE_MANAGER_ROLE");
  bytes32 public constant WHITE_LIST_MANAGER_ROLE = keccak256("WHITE_LIST_MANAGER_ROLE");

  string private _baseTokenUri;
  string public placeholderTokenUri;

  //deploy smart contract, toggle WL, toggle WL when done, toggle publicSale
  //2 days later toggle reveal
  bool public isRevealed;
  bool public publicSale;
  bool public whiteListSale;
  bool public airDrop;
  bool public teamMinted;

  bytes32 private _merkleRootWhiteList;
  bytes32 private _merkleRootAirDrop;

  mapping(address => uint256) public totalPublicMint;
  mapping(address => uint256) public totalWhitelistMint;
  mapping(address => uint256) public totalAirdropMint;

  event SentNFT(address _token, address _sender, uint256[] _tokenIds);

  constructor(address priceManager, address sellManager, address whiteListManager) ERC721A("BimkonEyes", "BYS") {
    _setupRole(PRICE_MANAGER_ROLE, priceManager);
    _setupRole(SELL_PHASE_MANAGER_ROLE, sellManager);
    _setupRole(WHITE_LIST_MANAGER_ROLE, whiteListManager);
  }

  modifier isBeyondMaxSupply(uint256 _quantity) {
    require(
      (totalSupply() + _quantity) <= MAX_SUPPLY,
      "BimkonEyes :: Beyond Max Supply"
    );
    _;
  }
  modifier onlyPriceManager() {
    require(
     hasRole(PRICE_MANAGER_ROLE, msg.sender),
      "BimkonEyes :: Caller is not price manager"
    );
    _;
  }

  modifier onlySellPhaseManager() {
    require(
     hasRole(SELL_PHASE_MANAGER_ROLE, msg.sender),
      "BimkonEyes :: Caller is not phase sell manager"
    );
    _;
  }

  modifier onlyWhiteListManager() {
    require(
     hasRole(WHITE_LIST_MANAGER_ROLE, msg.sender),
      "BimkonEyes :: Caller is not whitelist manager"
    );
    _;
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC721A, AccessControl)
    returns (bool)
  {
    return
      ERC721A.supportsInterface(interfaceId) ||
      AccessControl.supportsInterface(interfaceId);
  }

  function mint(uint256 _quantity)
    external
    payable
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
    totalPublicMint[msg.sender] += _quantity;
    _safeMint(msg.sender, _quantity);
  }

  function whitelistMint(bytes32[] memory _merkleProof, uint256 _quantity)
    external
    payable
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

    bytes32 sender = keccak256(abi.encodePacked(msg.sender));
    require(
      MerkleProof.verify(_merkleProof, _merkleRootWhiteList, sender),
      "BimkonEyes :: You are not whitelisted"
    );

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

    bytes32 sender = keccak256(abi.encodePacked(msg.sender));
    require(
      MerkleProof.verify(_merkleProof, _merkleRootAirDrop, sender),
      "BimkonEyes :: You are not allowed to claim DROP"
    );

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

  function teamMint() external onlyOwner {
    require(!teamMinted, "BimkonEyes :: Team already minted");
    teamMinted = true;
    _safeMint(msg.sender, 200);
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

  function setPublicSalePrice(uint256 _price) external onlyPriceManager {
    publicSalePrice = _price;
  }

  function setWhiteListSalePrice(uint256 _price) external onlyPriceManager {
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

  function setMerkleRootWhiteList(bytes32 merkleRoot_) external onlyWhiteListManager {
    _merkleRootWhiteList = merkleRoot_;
  }

  function setMerkleRootAirDrop(bytes32 merkleRoot_) external onlyWhiteListManager {
    _merkleRootAirDrop = merkleRoot_;
  }

  function getMerkleRootWhiteList() external view returns (bytes32) {
    return _merkleRootWhiteList;
  }

  function getMerkleRootAirDrop() external view returns (bytes32) {
    return _merkleRootAirDrop;
  }

  function toggleWhiteListSale() external onlySellPhaseManager {
    whiteListSale = !whiteListSale;
  }

  function toggleAirDrop() external onlySellPhaseManager {
    airDrop = !airDrop;
  }

  function togglePublicSale() external onlySellPhaseManager {
    publicSale = !publicSale;
  }

  function toggleReveal() external onlySellPhaseManager {
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
