pragma solidity ^0.4.18;

// File: contracts/land/LANDStorage.sol

contract LANDStorage {

  mapping (address => uint) public latestPing;

  uint256 constant clearLow = 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000;
  uint256 constant clearHigh = 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;
  uint256 constant factor = 0x100000000000000000000000000000000;

  mapping (address => bool) public authorizedDeploy;

  mapping (uint256 => address) public updateOperator;
}

// File: contracts/upgradable/OwnableStorage.sol

contract OwnableStorage {

  address public owner;

  function OwnableStorage() internal {
    owner = msg.sender;
  }

}

// File: contracts/upgradable/ProxyStorage.sol

contract ProxyStorage {

  /**
   * Current contract to which we are proxing
   */
  address public currentContract;
  address public proxyOwner;
}

// File: erc821/contracts/AssetRegistryStorage.sol

contract AssetRegistryStorage {

  string internal _name;
  string internal _symbol;
  string internal _description;

  /**
   * Stores the total count of assets managed by this registry
   */
  uint256 internal _count;

  /**
   * Stores an array of assets owned by a given account
   */
  mapping(address => uint256[]) internal _assetsOf;

  /**
   * Stores the current holder of an asset
   */
  mapping(uint256 => address) internal _holderOf;

  /**
   * Stores the index of an asset in the `_assetsOf` array of its holder
   */
  mapping(uint256 => uint256) internal _indexOfAsset;

  /**
   * Stores the data associated with an asset
   */
  mapping(uint256 => string) internal _assetData;

  /**
   * For a given account, for a given operator, store whether that operator is
   * allowed to transfer and modify assets on behalf of them.
   */
  mapping(address => mapping(address => bool)) internal _operators;

  /**
   * Approval array
   */
  mapping(uint256 => address) internal _approval;
}

// File: contracts/Storage.sol

contract Storage is ProxyStorage, OwnableStorage, AssetRegistryStorage, LANDStorage {
}

// File: contracts/upgradable/IApplication.sol

contract IApplication {
  function initialize(bytes data) public;
}

// File: contracts/upgradable/Ownable.sol

contract Ownable is Storage {

  event OwnerUpdate(address _prevOwner, address _newOwner);

  function bytesToAddress (bytes b) pure public returns (address) {
    uint result = 0;
    for (uint i = b.length-1; i+1 > 0; i--) {
      uint c = uint(b[i]);
      uint to_inc = c * ( 16 ** ((b.length - i-1) * 2));
      result += to_inc;
    }
    return address(result);
  }

  modifier onlyOwner {
    assert(msg.sender == owner);
    _;
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != owner);
    owner = _newOwner;
  }
}

// File: contracts/land/ILANDRegistry.sol

interface ILANDRegistry {

  // LAND can be assigned by the owner
  function assignNewParcel(int x, int y, address beneficiary) public;
  function assignMultipleParcels(int[] x, int[] y, address beneficiary) public;

  // After one year, land can be claimed from an inactive public key
  function ping() public;

  // LAND-centric getters
  function encodeTokenId(int x, int y) view public returns (uint256);
  function decodeTokenId(uint value) view public returns (int, int);
  function exists(int x, int y) view public returns (bool);
  function ownerOfLand(int x, int y) view public returns (address);
  function ownerOfLandMany(int[] x, int[] y) view public returns (address[]);
  function landOf(address owner) view public returns (int[], int[]);
  function landData(int x, int y) view public returns (string);

  // Transfer LAND
  function transferLand(int x, int y, address to) public;
  function transferManyLand(int[] x, int[] y, address to) public;

  // Update LAND
  function updateLandData(int x, int y, string data) public;
  function updateManyLandData(int[] x, int[] y, string data) public;

  // Events

  event Update(  
    uint256 indexed assetId, 
    address indexed holder,  
    address indexed operator,  
    string data  
  );
}

// File: erc821/contracts/IERC721Base.sol

interface IERC721Base {
  function totalSupply() public view returns (uint256);

  // function exists(uint256 assetId) public view returns (bool);
  function ownerOf(uint256 assetId) public view returns (address);

  function balanceOf(address holder) public view returns (uint256);

  function safeTransferFrom(address from, address to, uint256 assetId) public;
  function safeTransferFrom(address from, address to, uint256 assetId, bytes userData) public;

  function transferFrom(address from, address to, uint256 assetId) public;

  function approve(address operator, uint256 assetId) public;
  function setApprovalForAll(address operator, bool authorized) public;

  function getApprovedAddress(uint256 assetId) public view returns (address);
  function isApprovedForAll(address operator, address assetOwner) public view returns (bool);

  function isAuthorized(address operator, uint256 assetId) public view returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 indexed assetId,
    address operator,
    bytes userData
  );
  event ApprovalForAll(
    address indexed operator,
    address indexed holder,
    bool authorized
  );
  event Approval(
    address indexed owner,
    address indexed operator,
    uint256 indexed assetId
  );
}

// File: erc821/contracts/IERC721Receiver.sol

interface IERC721Receiver {
  function onERC721Received(
    uint256 _tokenId,
    address _oldOwner,
    bytes   _userData
  ) public returns (bytes4);
}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: erc821/contracts/ERC721Base.sol

interface ERC165 {
  function supportsInterface(bytes4 interfaceID) public view returns (bool);
}

contract ERC721Base is AssetRegistryStorage, IERC721Base, ERC165 {
  using SafeMath for uint256;

  //
  // Global Getters
  //

  /**
   * @dev Gets the total amount of assets stored by the contract
   * @return uint256 representing the total amount of assets
   */
  function totalSupply() public view returns (uint256) {
    return _count;
  }

  //
  // Asset-centric getter functions
  //

  /**
   * @dev Queries what address owns an asset. This method does not throw.
   * In order to check if the asset exists, use the `exists` function or check if the
   * return value of this call is `0`.
   * @return uint256 the assetId
   */
  function ownerOf(uint256 assetId) public view returns (address) {
    return _holderOf[assetId];
  }

  //
  // Holder-centric getter functions
  //
  /**
   * @dev Gets the balance of the specified address
   * @param owner address to query the balance of
   * @return uint256 representing the amount owned by the passed address
   */
  function balanceOf(address owner) public view returns (uint256) {
    return _assetsOf[owner].length;
  }

  //
  // Authorization getters
  //

  /**
   * @dev Query whether an address has been authorized to move any assets on behalf of someone else
   * @param operator the address that might be authorized
   * @param assetHolder the address that provided the authorization
   * @return bool true if the operator has been authorized to move any assets
   */
  function isApprovedForAll(address operator, address assetHolder)
    public view returns (bool)
  {
    return _operators[assetHolder][operator];
  }

  /**
   * @dev Query what address has been particularly authorized to move an asset
   * @param assetId the asset to be queried for
   * @return bool true if the asset has been approved by the holder
   */
  function getApprovedAddress(uint256 assetId) public view returns (address) {
    return _approval[assetId];
  }

  /**
   * @dev Query if an operator can move an asset.
   * @param operator the address that might be authorized
   * @param assetId the asset that has been `approved` for transfer
   * @return bool true if the asset has been approved by the holder
   */
  function isAuthorized(address operator, uint256 assetId)
    public view returns (bool)
  {
    require(operator != 0);
    address owner = ownerOf(assetId);
    if (operator == owner) {
      return true;
    }
    return isApprovedForAll(operator, owner) || getApprovedAddress(assetId) == operator;
  }

  //
  // Authorization
  //

  /**
   * @dev Authorize a third party operator to manage (send) msg.sender's asset
   * @param operator address to be approved
   * @param authorized bool set to true to authorize, false to withdraw authorization
   */
  function setApprovalForAll(address operator, bool authorized) public {
    if (authorized) {
      require(!isApprovedForAll(operator, msg.sender));
      _addAuthorization(operator, msg.sender);
    } else {
      require(isApprovedForAll(operator, msg.sender));
      _clearAuthorization(operator, msg.sender);
    }
    ApprovalForAll(operator, msg.sender, authorized);
  }

  /**
   * @dev Authorize a third party operator to manage one particular asset
   * @param operator address to be approved
   * @param assetId asset to approve
   */
  function approve(address operator, uint256 assetId) public {
    address holder = ownerOf(assetId);
    require(operator != holder);
    if (getApprovedAddress(assetId) != operator) {
      _approval[assetId] = operator;
      Approval(holder, operator, assetId);
    }
  }

  function _addAuthorization(address operator, address holder) private {
    _operators[holder][operator] = true;
  }

  function _clearAuthorization(address operator, address holder) private {
    _operators[holder][operator] = false;
  }

  //
  // Internal Operations
  //

  function _addAssetTo(address to, uint256 assetId) internal {
    _holderOf[assetId] = to;

    uint256 length = balanceOf(to);

    _assetsOf[to].push(assetId);

    _indexOfAsset[assetId] = length;

    _count = _count.add(1);
  }

  function _removeAssetFrom(address from, uint256 assetId) internal {
    uint256 assetIndex = _indexOfAsset[assetId];
    uint256 lastAssetIndex = balanceOf(from).sub(1);
    uint256 lastAssetId = _assetsOf[from][lastAssetIndex];

    _holderOf[assetId] = 0;

    // Insert the last asset into the position previously occupied by the asset to be removed
    _assetsOf[from][assetIndex] = lastAssetId;

    // Resize the array
    _assetsOf[from][lastAssetIndex] = 0;
    _assetsOf[from].length--;

    // Remove the array if no more assets are owned to prevent pollution
    if (_assetsOf[from].length == 0) {
      delete _assetsOf[from];
    }

    // Update the index of positions for the asset
    _indexOfAsset[assetId] = 0;
    _indexOfAsset[lastAssetId] = assetIndex;

    _count = _count.sub(1);
  }

  function _clearApproval(address holder, uint256 assetId) internal {
    if (ownerOf(assetId) == holder && _approval[assetId] != 0) {
      _approval[assetId] = 0;
      Approval(holder, 0, assetId);
    }
  }

  //
  // Supply-altering functions
  //

  function _generate(uint256 assetId, address beneficiary) internal {
    require(_holderOf[assetId] == 0);

    _addAssetTo(beneficiary, assetId);

    Transfer(0, beneficiary, assetId, msg.sender, '');
  }

  function _destroy(uint256 assetId) internal {
    address holder = _holderOf[assetId];
    require(holder != 0);

    _removeAssetFrom(holder, assetId);

    Transfer(holder, 0, assetId, msg.sender, '');
  }

  //
  // Transaction related operations
  //

  modifier onlyHolder(uint256 assetId) {
    require(_holderOf[assetId] == msg.sender);
    _;
  }

  modifier onlyAuthorized(uint256 assetId) {
    require(isAuthorized(msg.sender, assetId));
    _;
  }

  modifier isCurrentOwner(address from, uint256 assetId) {
    require(_holderOf[assetId] == from);
    _;
  }

  modifier isDestinataryDefined(address destinatary) {
    require(destinatary != 0);
    _;
  }

  modifier destinataryIsNotHolder(uint256 assetId, address to) {
    require(_holderOf[assetId] != to);
    _;
  }

  /**
   * @dev Alias of `safeTransferFrom(from, to, assetId, '')`
   *
   * @param from address that currently owns an asset
   * @param to address to receive the ownership of the asset
   * @param assetId uint256 ID of the asset to be transferred
   */
  function safeTransferFrom(address from, address to, uint256 assetId) public {
    return _doTransferFrom(from, to, assetId, '', msg.sender, true);
  }

  /**
   * @dev Securely transfers the ownership of a given asset from one address to
   * another address, calling the method `onNFTReceived` on the target address if
   * there's code associated with it
   *
   * @param from address that currently owns an asset
   * @param to address to receive the ownership of the asset
   * @param assetId uint256 ID of the asset to be transferred
   * @param userData bytes arbitrary user information to attach to this transfer
   */
  function safeTransferFrom(address from, address to, uint256 assetId, bytes userData) public {
    return _doTransferFrom(from, to, assetId, userData, msg.sender, true);
  }

  /**
   * @dev Transfers the ownership of a given asset from one address to another address
   * Warning! This function does not attempt to verify that the target address can send
   * tokens.
   *
   * @param from address sending the asset
   * @param to address to receive the ownership of the asset
   * @param assetId uint256 ID of the asset to be transferred
   */
  function transferFrom(address from, address to, uint256 assetId) public {
    return _doTransferFrom(from, to, assetId, '', msg.sender, false);
  }

  function _doTransferFrom(
    address from,
    address to,
    uint256 assetId,
    bytes userData,
    address operator,
    bool doCheck
  )
    isDestinataryDefined(to)
    destinataryIsNotHolder(assetId, to)
    isCurrentOwner(from, assetId)
    onlyAuthorized(assetId)
    internal
  {
    address holder = _holderOf[assetId];
    _removeAssetFrom(holder, assetId);
    _clearApproval(holder, assetId);
    _addAssetTo(to, assetId);

    if (doCheck && _isContract(to)) {
      // Equals to bytes4(keccak256("onERC721Received(address,uint256,bytes)"))
      bytes4 ERC721_RECEIVED = bytes4(0xf0b9e5ba);
      require(
        IERC721Receiver(to).onERC721Received(
          assetId, holder, userData
        ) == ERC721_RECEIVED
      );
    }

    Transfer(holder, to, assetId, operator, userData);
  }

  /**
   * @dev Returns `true` if the contract implements `interfaceID` and `interfaceID` is not 0xffffffff, `false` otherwise
   * @param  _interfaceID The interface identifier, as specified in ERC-165
   */
  function supportsInterface(bytes4 _interfaceID) public view returns (bool) {

    if (_interfaceID == 0xffffffff) {
      return false;
    }
    return _interfaceID == 0x01ffc9a7 || _interfaceID == 0x7c0633c6;
  }

  //
  // Utilities
  //

  function _isContract(address addr) internal view returns (bool) {
    uint size;
    assembly { size := extcodesize(addr) }
    return size > 0;
  }
}

// File: erc821/contracts/IERC721Enumerable.sol

contract IERC721Enumerable {

  /**
   * @notice Enumerate active tokens
   * @dev Throws if `index` >= `totalSupply()`, otherwise SHALL NOT throw.
   * @param index A counter less than `totalSupply()`
   * @return The identifier for the `index`th asset, (sort order not
   *  specified)
   */
  // TODO (eordano): Not implemented
  // function tokenByIndex(uint256 index) public view returns (uint256 _assetId);

  /**
   * @notice Count of owners which own at least one asset
   *  Must not throw.
   * @return A count of the number of owners which own asset
   */
  // TODO (eordano): Not implemented
  // function countOfOwners() public view returns (uint256 _count);

  /**
   * @notice Enumerate owners
   * @dev Throws if `index` >= `countOfOwners()`, otherwise must not throw.
   * @param index A counter less than `countOfOwners()`
   * @return The address of the `index`th owner (sort order not specified)
   */
  // TODO (eordano): Not implemented
  // function ownerByIndex(uint256 index) public view returns (address owner);

  /**
   * @notice Get all tokens of a given address
   * @dev This is not intended to be used on-chain
   * @param owner address of the owner to query
   * @return a list of all assetIds of a user
   */
  function tokensOf(address owner) public view returns (uint256[]);

  /**
   * @notice Enumerate tokens assigned to an owner
   * @dev Throws if `index` >= `balanceOf(owner)` or if
   *  `owner` is the zero address, representing invalid assets.
   *  Otherwise this must not throw.
   * @param owner An address where we are interested in assets owned by them
   * @param index A counter less than `balanceOf(owner)`
   * @return The identifier for the `index`th asset assigned to `owner`,
   *   (sort order not specified)
   */
  function tokenOfOwnerByIndex(
    address owner, uint256 index
  ) public view returns (uint256 tokenId);
}

// File: erc821/contracts/ERC721Enumerable.sol

contract ERC721Enumerable is AssetRegistryStorage, IERC721Enumerable {

  /**
   * @notice Get all tokens of a given address
   * @dev This is not intended to be used on-chain
   * @param owner address of the owner to query
   * @return a list of all assetIds of a user
   */
  function tokensOf(address owner) public view returns (uint256[]) {
    return _assetsOf[owner];
  }

  /**
   * @notice Enumerate tokens assigned to an owner
   * @dev Throws if `index` >= `balanceOf(owner)` or if
   *  `owner` is the zero address, representing invalid assets.
   *  Otherwise this must not throw.
   * @param owner An address where we are interested in assets owned by them
   * @param index A counter less than `balanceOf(owner)`
   * @return The identifier for the `index`th asset assigned to `owner`,
   *   (sort order not specified)
   */
  function tokenOfOwnerByIndex(
    address owner, uint256 index
    ) public view returns (uint256 assetId)
  {
    require(index < _assetsOf[owner].length);
    require(index < (1<<127));
    return _assetsOf[owner][index];
  }

}

// File: erc821/contracts/IERC721Metadata.sol

contract IERC721Metadata {

  /**
   * @notice A descriptive name for a collection of NFTs in this contract
   */
  function name() public view returns (string);

  /**
   * @notice An abbreviated name for NFTs in this contract
   */
  function symbol() public view returns (string);

  /**
   * @notice A description of what this DAR is used for
   */
  function description() public view returns (string);

  /**
   * Stores arbitrary info about a token
   */
  function tokenMetadata(uint256 assetId) public view returns (string);
}

// File: erc821/contracts/ERC721Metadata.sol

contract ERC721Metadata is AssetRegistryStorage, IERC721Metadata {
  function name() public view returns (string) {
    return _name;
  }
  function symbol() public view returns (string) {
    return _symbol;
  }
  function description() public view returns (string) {
    return _description;
  }
  function tokenMetadata(uint256 assetId) public view returns (string) {
    return _assetData[assetId];
  }
  function _update(uint256 assetId, string data) internal {
    _assetData[assetId] = data;
  }
}

// File: erc821/contracts/FullAssetRegistry.sol

contract FullAssetRegistry is ERC721Base, ERC721Enumerable, ERC721Metadata {
  function FullAssetRegistry() public {
  }

  /**
   * @dev Method to check if an asset identified by the given id exists under this DAR.
   * @return uint256 the assetId
   */
  function exists(uint256 assetId) public view returns (bool) {
    return _holderOf[assetId] != 0;
  }

  function decimals() public pure returns (uint256) {
    return 0;
  }
}

// File: contracts/land/LANDRegistry.sol

contract LANDRegistry is Storage,
  Ownable, FullAssetRegistry,
  ILANDRegistry
{

  function initialize(bytes) public {
    _name = 'Decentraland LAND';
    _symbol = 'LAND';
    _description = 'Contract that stores the Decentraland LAND registry';
  }

  modifier onlyProxyOwner() {
    require(msg.sender == proxyOwner);
    _;
  }

  //
  // LAND Create and destroy
  //

  modifier onlyOwnerOf(uint256 assetId) {
    require(msg.sender == ownerOf(assetId));
    _;
  }

  modifier onlyUpdateAuthorized(uint256 tokenId) {
    require(msg.sender == ownerOf(tokenId) || isUpdateAuthorized(msg.sender, tokenId));
    _;
  }

  function isUpdateAuthorized(address operator, uint256 assetId) public view returns (bool) {
    return operator == ownerOf(assetId) || updateOperator[assetId] == operator;
  }

  function authorizeDeploy(address beneficiary) public onlyProxyOwner {
    authorizedDeploy[beneficiary] = true;
  }
  function forbidDeploy(address beneficiary) public onlyProxyOwner {
    authorizedDeploy[beneficiary] = false;
  }

  function assignNewParcel(int x, int y, address beneficiary) public onlyProxyOwner {
    _generate(encodeTokenId(x, y), beneficiary);
  }

  function assignMultipleParcels(int[] x, int[] y, address beneficiary) public onlyProxyOwner {
    for (uint i = 0; i < x.length; i++) {
      _generate(encodeTokenId(x[i], y[i]), beneficiary);
    }
  }

  //
  // Inactive keys after 1 year lose ownership
  //

  function ping() public {
    latestPing[msg.sender] = now;
  }

  function setLatestToNow(address user) public {
    require(msg.sender == proxyOwner || isApprovedForAll(msg.sender, user));
    latestPing[user] = now;
  }

  //
  // LAND Getters
  //

  function encodeTokenId(int x, int y) view public returns (uint) {
    return ((uint(x) * factor) & clearLow) | (uint(y) & clearHigh);
  }

  function decodeTokenId(uint value) view public returns (int, int) {
    uint x = (value & clearLow) >> 128;
    uint y = (value & clearHigh);
    return (expandNegative128BitCast(x), expandNegative128BitCast(y));
  }

  function expandNegative128BitCast(uint value) pure internal returns (int) {
    if (value & (1<<127) != 0) {
      return int(value | clearLow);
    }
    return int(value);
  }

  function exists(int x, int y) view public returns (bool) {
    return exists(encodeTokenId(x, y));
  }

  function ownerOfLand(int x, int y) view public returns (address) {
    return ownerOf(encodeTokenId(x, y));
  }

  function ownerOfLandMany(int[] x, int[] y) view public returns (address[]) {
    require(x.length > 0);
    require(x.length == y.length);

    address[] memory addrs = new address[](x.length);
    for (uint i = 0; i < x.length; i++) {
      addrs[i] = ownerOfLand(x[i], y[i]);
    }

    return addrs;
  }

  function landOf(address owner) public view returns (int[], int[]) {
    uint256 len = _assetsOf[owner].length;
    int[] memory x = new int[](len);
    int[] memory y = new int[](len);

    int assetX;
    int assetY;
    for (uint i = 0; i < len; i++) {
      (assetX, assetY) = decodeTokenId(_assetsOf[owner][i]);
      x[i] = assetX;
      y[i] = assetY;
    }

    return (x, y);
  }

  function landData(int x, int y) view public returns (string) {
    return tokenMetadata(encodeTokenId(x, y));
  }

  //
  // LAND Transfer
  //

  function transferLand(int x, int y, address to) public {
    uint256 tokenId = encodeTokenId(x, y);
    safeTransferFrom(ownerOf(tokenId), to, tokenId);
  }

  function transferManyLand(int[] x, int[] y, address to) public {
    require(x.length > 0);
    require(x.length == y.length);

    for (uint i = 0; i < x.length; i++) {
      uint256 tokenId = encodeTokenId(x[i], y[i]);
      safeTransferFrom(ownerOf(tokenId), to, tokenId);
    }
  }

  function setUpdateOperator(uint256 assetId, address operator) public onlyOwnerOf(assetId) {
    updateOperator[assetId] = operator;
  }

  //
  // LAND Update
  //

  function updateLandData(int x, int y, string data) public onlyUpdateAuthorized (encodeTokenId(x, y)) {
    uint256 assetId = encodeTokenId(x, y);
    _update(assetId, data);

    Update(assetId, _holderOf[assetId], msg.sender, data);
  }

  function updateManyLandData(int[] x, int[] y, string data) public {
    require(x.length > 0);
    require(x.length == y.length);
    for (uint i = 0; i < x.length; i++) {
      updateLandData(x[i], y[i], data);
    }
  }

  function _doTransferFrom(
    address from,
    address to,
    uint256 assetId,
    bytes userData,
    address operator,
    bool doCheck
  ) internal {
    updateOperator[assetId] = address(0);
    super._doTransferFrom(from, to, assetId, userData, operator, doCheck);
  }
}
