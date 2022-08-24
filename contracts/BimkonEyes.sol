// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interface/ISignatureChecker.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "erc721a/contracts/ERC721A.sol";

/// @title  NFT Contract with Access Management Control

contract BimkonEyes is ERC721A, Ownable, AccessControl {
  ISignatureChecker public signatureCheckerContract;
  uint256 public constant MAX_SUPPLY = 2000;
  uint256 public constant MAX_PUBLIC_MINT = 10;
  uint256 public constant MAX_WHITELIST_MINT = 3;
  uint256 public constant MAX_AIRDROP_MINT = 2;
  uint256 public publicSalePrice = 1 ether;
  uint256 public whiteListSalePrice = 0.5 ether;
  bytes32 public constant PRICE_MANAGER_ROLE = keccak256("PRICE_MANAGER_ROLE");
  bytes32 public constant SELL_PHASE_MANAGER_ROLE =
    keccak256("SELL_PHASE_MANAGER_ROLE");
  bytes32 public constant WHITE_LIST_MANAGER_ROLE =
    keccak256("WHITE_LIST_MANAGER_ROLE");

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

  constructor(
    address priceManager,
    address sellManager,
    address whiteListManager,
    address _signatureCheckerContract
  ) ERC721A("BimkonEyes", "BYS") {
    signatureCheckerContract = ISignatureChecker(_signatureCheckerContract);
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

  ///@notice it show supported interfaces
  ///@param interfaceId interface id
  ///@dev external contracts can check if some interface is supported
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

  ///@notice it show supported interfaces
  ///@param _quantity NFT quantity to mint
  ///@dev can mint only when publicSale true
  function mint(uint256 _quantity, bytes calldata _signature)
    external
    payable
    isBeyondMaxSupply(_quantity)
  {
    require(publicSale, "BimkonEyes :: Not Yet Active.");
    require(
      signatureCheckerContract.isValidSignature(_signature, msg.sender),
      "BimkonEyes :: Invalid Signature."
    );
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

  ///@notice mint token to whitelisted addresses
  ///@param _merkleProof proof that user in whiteList
  ///@param _quantity quantity to mint
  ///@dev only whitelisted can do it
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

  ///@notice claim air drop
  ///@param _merkleProof proof that user in whiteList
  ///@param _quantity quantity to mint
  ///@dev only whitelisted can do it
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

  ///@notice check if user can claim airdrop
  ///@param _merkleProof proof that user in whiteList for airdrop
  ///@dev using merkleProof to verify user
  ///@return bool that indicated if user can claim Airdrop
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

  ///@notice check if user in whitelist
  ///@param _merkleProof proof that user in whiteLis for whitelistSale
  ///@dev using merkleProof to verify user
  ///@return bool that indicated if user can claim Airdrop
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

  ///@notice check mint amount for airdrop left
  ///@return uint256 amount for airdrop left
  function allowedToClaimDropAmount(address _account) external view returns (uint256) {
    return MAX_AIRDROP_MINT - totalAirdropMint[_account];
  }

  ///@notice check mint amount for whiteList left
  ///@return uint256 amount for whiteList left
  function allowedToWhiteListMintAmount(address _account) external view returns (uint256) {
    return MAX_WHITELIST_MINT - totalWhitelistMint[_account];
  }

  ///@notice check mint amount for publicSale left
  ///@return uint256 amount for publicSake left
  function allowedToPublicMintAmount(address _account) external view returns (uint256) {
    return MAX_PUBLIC_MINT - totalPublicMint[_account];
  }

  ///@notice team mint nft for themselfs
  ///@dev can only mint once
  function teamMint() external onlyOwner {
    require(!teamMinted, "BimkonEyes :: Team already minted");
    teamMinted = true;
    _safeMint(msg.sender, 200);
  }

  function _baseURI() internal view override returns (string memory) {
    return _baseTokenUri;
  }

  ///@notice return token URI
  ///@param _tokenId tokenId
  ///@dev if not revealed - return placeholder token URI
  ///@return string token URI
  function tokenURI(uint256 _tokenId)
    public
    view
    override
    returns (string memory)
  {
    require(
      _exists(_tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    uint256 trueId = _tokenId + 1;

    if (!isRevealed) {
      return placeholderTokenUri;
    }

    return
      bytes(_baseTokenUri).length > 0
        ? string(abi.encodePacked(_baseTokenUri, _toString(trueId), ".json"))
        : "";
  }

  ///@notice set publicSalePrice
  ///@param _price price for sale
  ///@dev only priceManager can call this
  function setPublicSalePrice(uint256 _price) external onlyPriceManager {
    publicSalePrice = _price;
  }

  ///@notice set whiteListSalePrice
  ///@param _price price for sale
  ///@dev only priceManager can call this
  function setWhiteListSalePrice(uint256 _price) external onlyPriceManager {
    whiteListSalePrice = _price;
  }

  ///@notice set base token URI
  ///@param baseTokenUri_ base token URI
  ///@dev only owner can do this
  function setTokenUri(string memory baseTokenUri_) external onlyOwner {
    _baseTokenUri = baseTokenUri_;
  }

  ///@notice set placeholder token URI
  ///@param _placeholderTokenUri placeholder token URI
  ///@dev only owner can do this
  function setPlaceHolderUri(string memory _placeholderTokenUri)
    external
    onlyOwner
  {
    placeholderTokenUri = _placeholderTokenUri;
  }

  ///@notice set merkle root for whitelist
  ///@param merkleRoot_ merkle root
  ///@dev only whiteList manager can do this
  function setMerkleRootWhiteList(bytes32 merkleRoot_)
    external
    onlyWhiteListManager
  {
    _merkleRootWhiteList = merkleRoot_;
  }

  ///@notice set merkle root for whitelist
  ///@param merkleRoot_ merkle root
  ///@dev only whiteList manager can do this
  function setMerkleRootAirDrop(bytes32 merkleRoot_)
    external
    onlyWhiteListManager
  {
    _merkleRootAirDrop = merkleRoot_;
  }

  ///@notice get merkle root for whitelist
  function getMerkleRootWhiteList() external view returns (bytes32) {
    return _merkleRootWhiteList;
  }

  ///@notice get merkle root for airdrop
  function getMerkleRootAirDrop() external view returns (bytes32) {
    return _merkleRootAirDrop;
  }

  ///@notice toggle whiteListSale
  ///@dev only sellPhaseManager can do it
  function toggleWhiteListSale() external onlySellPhaseManager {
    whiteListSale = !whiteListSale;
  }

  ///@notice toggle AirDrop phase
  ///@dev only sellPhaseManager can do it
  function toggleAirDrop() external onlySellPhaseManager {
    airDrop = !airDrop;
  }

  ///@notice toggle PublicSale phase
  ///@dev only sellPhaseManager can do it
  function togglePublicSale() external onlySellPhaseManager {
    publicSale = !publicSale;
  }

  ///@notice toggle reveal
  ///@dev only sellPhaseManager can do it
  function toggleReveal() external onlySellPhaseManager {
    isRevealed = !isRevealed;
  }

  ///@notice this let multiSend 721 tokens
  ///@param _token token address
  ///@param _to to array
  ///@param _id token id array
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

  ///@notice it withdraw assets from contract
  ///@param _to withdraw to
  ///@param _value value to withdraw
  ///@dev only owner can do this
  function withdraw(address _to, uint256 _value) external onlyOwner {
    (bool success, ) = _to.call{value: _value}("");
    require(success, "Failed to send native assets");
  }
}
