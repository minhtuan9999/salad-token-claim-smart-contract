// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Random/randomBox.sol";

contract GenesisHash is Ownable, ERC721Enumerable, AccessControl, Pausable, ReentrancyGuard, RandomBox {
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;

    // Detail of Group
    struct GroupDetail {
        uint256 totalSupply;
        uint256 remaining;
    }
    // Detail type of Group
    struct SpeciesDetail {
        uint256 issueLimit;
        uint256 issueAmount;
        uint256 remaining;
    }
    // Detail of token id
    struct GenesisDetail {
        uint256 group;
        uint256 species;
    }
    // Count token Id
    Counters.Counter private _tokenIds;
    bytes32 public constant MANAGEMENT_ROLE = keccak256("MANAGEMENT_ROLE");
    // Base URI
    string private _baseURIextended;
    // set value group
    uint256[] public listGroup;
    uint256[] public typeOfGroup;
    // maketing group
    uint256[] _marketingLimit1;
    uint256 _marketingLimit2;
    
    constructor() ERC721("Genesis Hash", "GenesisHash") {
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
        listGroup = [1,2,3,4,5];
        typeOfGroup = [4,4,5,4,4];
        _marketingLimit1 = [120, 120, 150, 120, 120];
        _marketingLimit2 = 20;
    }

    //=======================================MAPPING=======================================//
    // Mapping SpeciesDetail (group => (type => SpeciesDetail))
    mapping(uint256 => mapping(uint256 => SpeciesDetail)) public _species;
    // Mapping tokenId detail
    mapping(uint256 => GenesisDetail) public _genesisDetail;
    // Mapping list token of address
    mapping(address => EnumerableSet.UintSet) private _listTokensOfAddress;
    // Mint limit of group
    mapping(uint256 => GroupDetail) public _groupDetail;
    // Number box of group
    mapping(address => mapping(uint256 => uint256)) public _boxOfAddress;
    mapping(uint256 => bool) public _marketing;

    //=======================================EVENT=======================================//
    // Event create Genesishash with group
    event createGenesisBoxs(address _address, uint256 number, uint256 group);
    // Event random type of Group
    event openGenesisBox(uint256 tokenId, uint256 group, uint256 _type);
    // Event create Genesishash for marketing
    event createMultipleGenesisHashwithType(address _address, uint256 group);

    //=======================================FUNCTION=======================================//
    // Get list Tokens of address
    function getListTokensOfAddress(
        address _address
    ) public view returns (uint256[] memory) {
        return _listTokensOfAddress[_address].values();
    }

    //set initialization limit of group
    function initSetDetailGroup(
        uint256 _group,
        uint256 _limit
    ) external whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        _groupDetail[_group].totalSupply = _limit;
        _groupDetail[_group].remaining = _limit;
    }

    /*
     * set detail type of group
     * @param _group: group
     * @param _specie: type of group
     * @param _limit: isueLimit of type
     */
    function initSetSpecieDetail(
        uint256 _group,
        uint256 _specie,
        uint256 _limit
    ) external whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        _species[_group][_specie].issueLimit = _limit;
        _species[_group][_specie].remaining =
            _limit -
            _species[_group][_specie].issueAmount;
    }

    /**
     *@dev See {ERC721-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
        _listTokensOfAddress[to].add(firstTokenId);
        _listTokensOfAddress[from].remove(firstTokenId);
    }

    // Set base uri
    function initSetBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    // get base uri
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(AccessControl, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function pause() public onlyRole(MANAGEMENT_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(MANAGEMENT_ROLE) {
        _unpause();
    }

    /*
     * create genesis box
     * @param _address: owner of NFT
     * @param _group: group of genesis hash
     */
    function createGenesisBox(
        address _address,
        uint256 _group
    ) external nonReentrant whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        require(
            _groupDetail[_group].remaining > 0,
            "Genesis Hash::createGenesisBox: Exceeding"
        );
        _groupDetail[_group].remaining--;
        _boxOfAddress[_address][_group]++;
        emit createGenesisBoxs(_address, 1, _group);
    }

    function _createMarketingBoxWithType(
        address _address,
        uint256 _group,
        uint256 _type
    ) private {
        for (uint8 i = 0; i < _marketingLimit2; i++) {
            uint256 tokenId = _tokenIds.current();
            _mint(_address, tokenId);
            _tokenIds.increment();
            _genesisDetail[tokenId].group = _group;
            _genesisDetail[tokenId].species = _type;
        }
        _species[_group][_type].issueAmount = _species[_group][_type].issueAmount + _marketingLimit2;
        _species[_group][_type].remaining = _species[_group][_type].remaining - _marketingLimit2;
        _groupDetail[_group].remaining = _groupDetail[_group].remaining - _marketingLimit2;
    }
    /*
     * create Multiple NFT with Type
     * @param _address: owner of NFT
     * @param _number: number 
     * @param _group: group of genesis hash
     * @param _type: type of group
     */
    function createMarketingBoxWithType(address _address, uint256 _group) public{
        require(!_marketing[_group], "Genesis Hash::createMarketingBoxWithType: created marketing box");
        uint256 _type = typeOfGroup[_group - 1];
        for(uint256 i = 1; i <= _type ; i++ ) {
            _createMarketingBoxWithType(_address, _group, i );
        }
        _marketing[_group] = true;
        emit createMultipleGenesisHashwithType(_address,_group);
    }

    /*
     * create Multiple NFT
     * @param _address: owner of NFT
     * @param _group: group of genesis hash
     */
    function createMarketingBox(
        address _address,
        uint256 _group
    ) external nonReentrant whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        uint256 number = _marketingLimit1[_group - 1];
        require(number > 0, "Genesis Hash::createMarketingBox: Exceeding marketing box");
        _groupDetail[_group].remaining =
            _groupDetail[_group].remaining -
            number;
        _boxOfAddress[_address][_group] += number;
        _marketingLimit1[_group - 1] = 0;
        emit createGenesisBoxs(_address, number, _group);
    }

    // get type random
    function _getTypeOfGroup(uint256 _group) private returns (uint256) {
        uint256 _type = openBox(
            _species[_group][1].issueLimit,
            _species[_group][1].remaining,
            _species[_group][2].issueLimit,
            _species[_group][2].remaining,
            _species[_group][3].issueLimit,
            _species[_group][3].remaining,
            _species[_group][4].issueLimit,
            _species[_group][4].remaining,
            _species[_group][5].issueLimit,
            _species[_group][5].remaining
        );
        return _type;
    }

    /*
     * random Species of genesis hash
     * @param _group: group 
     */
    function openBoxGenesis(uint256 _group) external nonReentrant whenNotPaused {
        require(
            _boxOfAddress[msg.sender][_group] > 0,
            "General Hash:: openBoxGeneral: Exceeding box"
        );
        uint256 _type = _getTypeOfGroup(_group);
        require(
            _species[_group][_type].remaining > 0,
            "Genesis Hash::openBoxGenesis: Maxsupply of type"
        );
        
        uint256 tokenId = _tokenIds.current();
        _mint(msg.sender, tokenId);
        _tokenIds.increment();

        _genesisDetail[tokenId].group = _group;
        _genesisDetail[tokenId].species = _type;

        _species[_group][_type].issueAmount += 1;
        _species[_group][_type].remaining =
            _species[_group][_type].issueLimit -
            _species[_group][_type].issueAmount;
        _boxOfAddress[msg.sender][_group]--;
        emit openGenesisBox(tokenId, _group, _type);
    }

    /*
     * burn a Genesishash
     * @param _tokenId: tokenId burn
     */
    function burn(
        uint256 _tokenId
    ) external nonReentrant whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        _burn(_tokenId);
    }

    // get listBox, list Token of address
    function getDetailAddress(address _address) public view returns(uint256[] memory, uint256[] memory) {
        uint256[] memory listBox = new uint256[](listGroup.length);
        for(uint256 i=0; i < listGroup.length; i++){
            listBox[i] = _boxOfAddress[_address][listGroup[i]];
        }
        return (listBox, _listTokensOfAddress[_address].values());
    }

    // get type of list Token
    function getTypeOfListToken(uint256[] memory _listToken) public view returns(uint256[] memory,uint256[] memory) {
        uint256[] memory listTypes = new uint256[](_listToken.length);
        for(uint256 i=0; i< _listToken.length; i++) {
            listTypes[i] = _genesisDetail[_listToken[i]].species;
        }
        return (_listToken,listTypes);
    }
    //get group detail
    function getDetailGroup(uint256 group) external view returns(GroupDetail memory) {
        return _groupDetail[group];
    }
}
