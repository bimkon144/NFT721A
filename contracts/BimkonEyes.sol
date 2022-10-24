// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "erc721a/contracts/ERC721A.sol";

error WhiteListSaleNotAvailable();
error ArraysAreDifferentLength();
error YouAlreadyMintedForTeam();
error PublicSaleNotAvailable();
error AirDropNotAvailable();
error YouAreNotWhiteList();
error FailedToSendAssets();
error InvalidSignature();
error BeyondMaxSupply();
error TokenNotExist();
error CantMintMore();
error LowSentEther();

/// @title  NFT Contract with Access Management Control
contract BimkonEyes is ERC721A, AccessControl {
    using ECDSA for bytes32;
    uint256 public constant TEAM_MINT_AMOUNT = 200;
    uint256 public constant MAX_SUPPLY = 2000;
    uint256 public constant MAX_PUBLIC_MINT = 10;
    uint256 public constant MAX_WHITELIST_MINT = 3;
    uint256 public constant MAX_AIRDROP_MINT = 2;
    bytes32 public constant CAT = keccak256("Cat");
    bytes32 public constant PRICE_MANAGER_ROLE = keccak256("PRICE_MANAGER_ROLE");
    bytes32 public constant SELL_PHASE_MANAGER_ROLE = keccak256("SELL_PHASE_MANAGER_ROLE");
    bytes32 public constant WHITE_LIST_MANAGER_ROLE = keccak256("WHITE_LIST_MANAGER_ROLE");
    uint256 public publicSalePrice = 1 ether;
    uint256 public whiteListSalePrice = 0.5 ether;
    bool public isRevealed;
    bool public teamMinted;
    SalePhase public publicSale;
    SalePhase public whiteListSale;
    SalePhase public airDrop;
    bytes32 private _merkleRootWhiteList;
    bytes32 private _merkleRootAirDrop;
    string public placeholderTokenUri;
    string private _baseTokenUri;

    enum SalePhase {
        Soon,
        Available,
        Finished
    }

    mapping(address => uint256) public totalPublicMint;
    mapping(address => uint256) public totalWhitelistMint;
    mapping(address => uint256) public totalAirdropMint;

    event SentNFT(address indexed _token, address indexed _sender, uint256[] indexed _tokenIds);
    event SetPublicSalePrice(uint256 indexed _price);
    event SetWhiteListSalePrice(uint256 indexed _price);
    event SetTokenUri(string indexed _baseTokenUri);
    event SetPlaceHolderUri(string indexed _placeholderTokenUri);
    event SetMerkleRootWhiteList(bytes32 indexed _merkleRoot);
    event SetMerkleRootAirDrop(bytes32 indexed _merkleRoot);
    event SetWhiteListSaleState(SalePhase indexed _status);
    event SetAirDropState(SalePhase indexed _status);
    event SetPublicSaleState(SalePhase indexed _status);
    event ToggleReveal(bool indexed _state);
    event ClaimAirdrop(address indexed _claimer, uint256 indexed quantity);
    event WhiteListMint(address indexed _claimer, uint256 indexed quantity);
    event Mint(address indexed _claimer, uint256 indexed quantity);
    event Withdraw(address indexed _to, uint256 indexed _value);

    modifier isBeyondMaxSupply(uint256 _quantity) {
        if ((totalSupply() + _quantity) >= MAX_SUPPLY) {
            revert BeyondMaxSupply();
        }
        _;
    }

    constructor(
        address priceManager,
        address sellManager,
        address whiteListManager
    ) ERC721A("BimkonEyes", "BYS") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PRICE_MANAGER_ROLE, priceManager);
        _setupRole(SELL_PHASE_MANAGER_ROLE, sellManager);
        _setupRole(WHITE_LIST_MANAGER_ROLE, whiteListManager);
    }

    ///@notice it show supported interfaces
    ///@param _quantity NFT quantity to mint
    ///@dev can mint only when publicSale true
    function mint(uint256 _quantity, bytes calldata _signature) external payable isBeyondMaxSupply(_quantity) {
        if (publicSale != SalePhase.Available) {
            revert PublicSaleNotAvailable();
        }
        if (!isValidSignature(_signature, msg.sender)) {
            revert InvalidSignature();
        }
        if ((totalPublicMint[msg.sender] + _quantity) >= MAX_PUBLIC_MINT) {
            revert CantMintMore();
        }
        if (!(msg.value == (publicSalePrice * _quantity))) {
            revert LowSentEther();
        }
        totalPublicMint[msg.sender] += _quantity;
        _safeMint(msg.sender, _quantity);
        emit Mint(msg.sender, _quantity);
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
        if (whiteListSale != SalePhase.Available) {
            revert WhiteListSaleNotAvailable();
        }
        if ((totalWhitelistMint[msg.sender] + _quantity) >= MAX_WHITELIST_MINT) {
            revert CantMintMore();
        }
        if (!(msg.value == (whiteListSalePrice * _quantity))) {
            revert LowSentEther();
        }

        if (!_isVerify(_merkleProof, _merkleRootWhiteList, msg.sender)) {
            revert YouAreNotWhiteList();
        }
        totalWhitelistMint[msg.sender] += _quantity;
        _safeMint(msg.sender, _quantity);
        emit WhiteListMint(msg.sender, _quantity);
    }

    ///@notice team mint nft for themselfs
    ///@dev can only mint once
    function teamMint() external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (teamMinted) {
            revert YouAlreadyMintedForTeam();
        }
        teamMinted = true;
        _safeMint(msg.sender, TEAM_MINT_AMOUNT);
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
        if (_to.length != _id.length) {
            revert ArraysAreDifferentLength();
        }
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
    function withdraw(address _to, uint256 _value) external onlyRole(DEFAULT_ADMIN_ROLE) {
        (bool success, ) = _to.call{value: _value}("");
        if (!success) {
            revert FailedToSendAssets();
        }
        emit Withdraw(_to, _value);
    }

    ///@notice claim air drop
    ///@param _merkleProof proof that user in whiteList
    ///@param _quantity quantity to mint
    ///@dev only whitelisted can do it
    function claimAirdrop(bytes32[] memory _merkleProof, uint256 _quantity) external isBeyondMaxSupply(_quantity) {
        if (airDrop != SalePhase.Available) {
            revert AirDropNotAvailable();
        }
        if ((totalAirdropMint[msg.sender] + _quantity) >= MAX_AIRDROP_MINT) {
            revert CantMintMore();
        }

        if (!_isVerify(_merkleProof, _merkleRootAirDrop, msg.sender)) {
            revert YouAreNotWhiteList();
        }

        totalAirdropMint[msg.sender] += _quantity;
        _safeMint(msg.sender, _quantity);
        emit ClaimAirdrop(msg.sender, _quantity);
    }

    ///@notice set publicSalePrice
    ///@param _price price for sale
    ///@dev only priceManager can call this
    function setPublicSalePrice(uint256 _price) external onlyRole(PRICE_MANAGER_ROLE) {
        publicSalePrice = _price;
        emit SetPublicSalePrice(_price);
    }

    ///@notice set whiteListSalePrice
    ///@param _price price for sale
    ///@dev only priceManager can call this
    function setWhiteListSalePrice(uint256 _price) external onlyRole(PRICE_MANAGER_ROLE) {
        whiteListSalePrice = _price;
        emit SetWhiteListSalePrice(_price);
    }

    ///@notice set base token URI
    ///@param baseTokenUri_ base token URI
    ///@dev only owner can do this
    function setTokenUri(string memory baseTokenUri_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _baseTokenUri = baseTokenUri_;
        emit SetTokenUri(baseTokenUri_);
    }

    ///@notice set placeholder token URI
    ///@param _placeholderTokenUri placeholder token URI
    ///@dev only owner can do this
    function setPlaceHolderUri(string memory _placeholderTokenUri) external onlyRole(DEFAULT_ADMIN_ROLE) {
        placeholderTokenUri = _placeholderTokenUri;
        emit SetPlaceHolderUri(_placeholderTokenUri);
    }

    ///@notice set merkle root for whitelist
    ///@param merkleRoot_ merkle root
    ///@dev only whiteList manager can do this
    function setMerkleRootWhiteList(bytes32 merkleRoot_) external onlyRole(WHITE_LIST_MANAGER_ROLE) {
        _merkleRootWhiteList = merkleRoot_;
        emit SetMerkleRootWhiteList(merkleRoot_);
    }

    ///@notice set merkle root for whitelist
    ///@param merkleRoot_ merkle root
    ///@dev only whiteList manager can do this
    function setMerkleRootAirDrop(bytes32 merkleRoot_) external onlyRole(WHITE_LIST_MANAGER_ROLE) {
        _merkleRootAirDrop = merkleRoot_;
        emit SetMerkleRootAirDrop(merkleRoot_);
    }

    ///@notice toggle whiteListSale
    ///@dev only sellPhaseManager can do it
    function toggleWhiteListSale(SalePhase _status) external onlyRole(SELL_PHASE_MANAGER_ROLE) {
        whiteListSale = _status;
        emit SetWhiteListSaleState(_status);
    }

    ///@notice toggle AirDrop phase
    ///@dev only sellPhaseManager can do it
    function toggleAirDrop(SalePhase _status) external onlyRole(SELL_PHASE_MANAGER_ROLE) {
        airDrop = _status;
        emit SetAirDropState(_status);
    }

    ///@notice toggle PublicSale phase
    ///@dev only sellPhaseManager can do it
    function togglePublicSale(SalePhase _status) external onlyRole(SELL_PHASE_MANAGER_ROLE) {
        publicSale = _status;
        emit SetPublicSaleState(_status);
    }

    ///@notice toggle reveal
    ///@dev only sellPhaseManager can do it
    function toggleReveal() external onlyRole(SELL_PHASE_MANAGER_ROLE) {
        isRevealed = !isRevealed;
        emit ToggleReveal(isRevealed);
    }

    ///@notice check if user can claim airdrop
    ///@param _merkleProof proof that user in whiteList for airdrop
    ///@dev using merkleProof to verify user
    ///@return bool that indicated if user can claim Airdrop
    function canClaimAirDrop(bytes32[] memory _merkleProof, address _account) external view returns (bool) {
        return _isVerify(_merkleProof, _merkleRootAirDrop, _account);
    }

    ///@notice check mint amount for airdrop left
    ///@return uint256 amount for airdrop left
    function allowedToClaimDropAmount(address _account) external view returns (uint256) {
        return MAX_AIRDROP_MINT - totalAirdropMint[_account];
    }

    ///@notice check if user in whitelist
    ///@param _merkleProof proof that user in whiteLis for whitelistSale
    ///@dev using merkleProof to verify user
    ///@return bool that indicated if user can claim Airdrop
    function isWhiteListed(bytes32[] memory _merkleProof, address _account) external view returns (bool) {
        return _isVerify(_merkleProof, _merkleRootWhiteList, _account);
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

    ///@notice get merkle root for whitelist
    function getMerkleRootWhiteList() external view returns (bytes32) {
        return _merkleRootWhiteList;
    }

    ///@notice get merkle root for airdrop
    function getMerkleRootAirDrop() external view returns (bytes32) {
        return _merkleRootAirDrop;
    }

    ///@notice it show supported interfaces
    ///@param interfaceId interface id
    ///@dev external contracts can check if some interface is supported
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A, AccessControl) returns (bool) {
        return ERC721A.supportsInterface(interfaceId) || AccessControl.supportsInterface(interfaceId);
    }

    ///@notice return token URI
    ///@param _tokenId tokenId
    ///@dev if not revealed - return placeholder token URI
    ///@return string token URI
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        if (!_exists(_tokenId)) {
            revert TokenNotExist();
        }

        if (!isRevealed) {
            return placeholderTokenUri;
        }

        return
            bytes(_baseTokenUri).length > 0
                ? string(abi.encodePacked(_baseTokenUri, _toString(_tokenId), ".json"))
                : "";
    }

    function isValidSignature(bytes calldata _signature, address _sender) public pure returns (bool) {
        return CAT.toEthSignedMessageHash().recover(_signature) == _sender;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenUri;
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function _isVerify(
        bytes32[] memory _merkleProof,
        bytes32 _merkleRoot,
        address _account
    ) private pure returns (bool) {
        return MerkleProof.verify(_merkleProof, _merkleRoot, keccak256(abi.encodePacked(_account)));
    }
}
