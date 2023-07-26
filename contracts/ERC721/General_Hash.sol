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

contract GeneralHash is
    Ownable,
    ERC721Enumerable,
    AccessControl,
    Pausable,
    ReentrancyGuard,
    RandomBox
{
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
    struct GeneralDetail {
        uint256 group;
        uint256 species;
    }
    // Count token Id
    Counters.Counter private _tokenIds;
    bytes32 public constant MANAGEMENT_ROLE = keccak256("MANAGEMENT_ROLE");
    // Base URI
    string private _baseURIextended;

    constructor() ERC721("General Hash", "GeneralHash") {
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
    }

    //=======================================MAPPING=======================================//
    // Mapping SpeciesDetail (group => (type => SpeciesDetail))
    mapping(uint256 => mapping(uint256 => SpeciesDetail)) public _species;
    // Mapping tokenId detail
    mapping(uint256 => GeneralDetail) public _generalDetail;
    // Mapping list token of address
    mapping(address => EnumerableSet.UintSet) _listTokensOfAddress;
    // Detail of group
    mapping(uint256 => GroupDetail) public _groupDetail;
    // Number box of group
    mapping(address => mapping(uint256 => uint256)) public _boxOfAddress;

    //=======================================EVENT=======================================//
    // Event create General hash with group
    event createGeneralBoxs(address _address, uint256 number, uint256 group);
    // Event random type of Group
    event openGeneralBox(uint256 tokenId, uint256 group, uint256 _type);
    // Event create multiple General hash
    event createMultipleGeneral(
        address _address,
        uint256[] listToken,
        uint256 group
    );

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

    // set detail type of group
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

    // Get base uri
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
     * mint a General hash
     * @param _address: owner of NFT
     * @param _group: group of general hash
     */
    function createGeneralBox(
        address _address,
        uint256 _group
    ) external nonReentrant whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        require(
            _groupDetail[_group].remaining > 0,
            "General_Hash::createGeneralBox: Exceeding"
        );
        _groupDetail[_group].remaining--;
        _boxOfAddress[_address][_group]++;
        emit createGeneralBoxs(_address, 1, _group);
    }

    /*
     * create NFT marketing
     * @param _address: owner of NFT
     * @param _group: group of general hash
     * @param _number: _number
     */
    function createMultipleGeneralBox(
        address _address,
        uint256 _number,
        uint256 _group
    ) external nonReentrant whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        require(
            _number <= _groupDetail[_group].remaining,
            "General_Hash::createMultipleNFT: Exceeding"
        );
        _groupDetail[_group].remaining =
            _groupDetail[_group].remaining -
            _number;
        _boxOfAddress[_address][_group] =
            _boxOfAddress[_address][_group] +
            _number;
        emit createGeneralBoxs(_address, _number, _group);
    }

    function createNFTWithType(
        uint256 _group,
        uint256 _type,
        uint256 _number
    ) external whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        require(
            _number <= _groupDetail[_group].remaining,
            "General_Hash::createMultipleNFT: Exceeding"
        );
        _groupDetail[_group].remaining -=_number;
        _boxOfAddress[msg.sender][_group] +=_number;
        for(uint256 i=0; i<_number;i++) {
            uint256 tokenId = _tokenIds.current();
            _mint(msg.sender, tokenId);
            _tokenIds.increment();
            _generalDetail[tokenId].group = _group;
            _generalDetail[tokenId].species = _type;
        }
        _species[_group][_type].issueAmount += _number;
        _species[_group][_type].remaining =
            _species[_group][_type].issueLimit -
            _species[_group][_type].issueAmount;
    }

    // get type random
    function getTypeOfGroup(uint256 _group) private returns (uint256) {
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
     * random Species of general hash
     * @param _group: group of Box
     */
    function openBoxGeneral(
        uint256 _group
    ) external whenNotPaused nonReentrant {
        require(
            _boxOfAddress[msg.sender][_group] > 0,
            "General Hash:: openBoxGeneral: Exceeding box"
        );
        uint256 _type = getTypeOfGroup(_group);
        require(_type > 0, "General Hash:: openBoxGeneral: Type not exits");

        uint256 tokenId = _tokenIds.current();
        _mint(msg.sender, tokenId);
        _tokenIds.increment();

        _generalDetail[tokenId].group = _group;
        _generalDetail[tokenId].species = _type;

        _species[_group][_type].issueAmount += 1;
        _species[_group][_type].remaining =
            _species[_group][_type].issueLimit -
            _species[_group][_type].issueAmount;
        emit openGeneralBox(tokenId, _group, _type);
    }

    /*
     * burn a General hash
     * @param _tokenId: tokenId burn
     */
    function burn(
        uint256 _tokenId
    ) external nonReentrant whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        uint256 _type = _generalDetail[_tokenId].species;
        uint256 _group = _generalDetail[_tokenId].group;
        _species[_group][_type].issueAmount--;
        _species[_group][_type].remaining++;
        _groupDetail[_group].remaining++;
        _burn(_tokenId);
    }
}
