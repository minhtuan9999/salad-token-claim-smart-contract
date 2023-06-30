// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract GeneralHash is Ownable, ERC721Enumerable, AccessControl, Pausable {
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;

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
    bytes32 public constant MANAGERMENT_ROLE = keccak256("MANAGERMENT_ROLE");
    // Base URI
    string private _baseURIextended;
    // Validator signtransaction
    address public validator;
    //limit regeneration
    uint256 limitRegeneration;
    
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        _setRoleAdmin(MANAGERMENT_ROLE, MANAGERMENT_ROLE);
        _setupRole(MANAGERMENT_ROLE, _msgSender());
        validator = _msgSender();
    }

    //=======================================MAPPING=======================================//
    // Mapping SpeciesDetail (group => (type => SpeciesDetail))
    mapping (uint256 => mapping (uint256 => SpeciesDetail)) public _species;
    // Mapping tokenId detail
    mapping (uint256 => GeneralDetail ) public _generalDetail;
    // Mapping list token of address
    mapping(address => EnumerableSet.UintSet) private _listTokensOfAddress;
    // Status of signature code
    mapping(bytes => bool) public _signed;
    // Mint limit of group
    mapping (uint256 => uint256) public _mintLimitOfGroup;
    // Status mint nft marketing of group
    mapping (uint256 => mapping (uint256 => bool)) public _isRealdyMarketing;
    // Mapping index of token ID
    mapping(uint256 => uint256) public indexTokenId;

    //=======================================EVENT=======================================//
    // Event create Genesishash with group
    event createGenesisHash(address _address, uint256 _tokenId, uint256 _group);
    // Event random type of Group 
    event openGenesisBox(uint256 _tokenId, uint256 _group, uint256 _type);
    // Event create Genesishash for marketing
    event generalForMarketing(address _address, uint256[] _listToken, uint256 _group);
    //=======================================FUNCTION=======================================//
    // Get list Tokens of address
    function getListTokensOfAddress(
        address _address
    ) public view returns (uint256[] memory) {
        return _listTokensOfAddress[_address].values();
    }
    // Get index of token ID
    function getIndexOfTokenID(
        uint256 tokenId
    ) external view returns (uint256) {
        return indexTokenId[tokenId];
    }

    //set initialization limit of group
    function initSetMintLimitOfGroup(uint256 _group, uint256 _limit) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        _mintLimitOfGroup[_group] = _limit;
    }
    // Set Validator
    function initSetValidator(address _address) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        validator = _address;
    }

    //Set limit Regeneration
    function initSetRegenerationLimit(uint256 _limit) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        limitRegeneration = _limit;
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

    function pause() public onlyRole(MANAGERMENT_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(MANAGERMENT_ROLE) {
        _unpause();
    }

    /*
     * base mint a Genesishash
     * @param _address: owner of NFT
     * @param _group: group of NFT
     */
    function _createNFT(address _address, uint256 _group) private returns (uint256) {
        require(_mintLimitOfGroup[_group] > 0, "General_Hash::_createNFT: Exceeding");
        uint256 tokenId = _tokenIds.current();
        _mint(_address, tokenId);
        _tokenIds.increment();
        _listTokensOfAddress[_address].add(tokenId);
        _generalDetail[tokenId].group = _group;
        _mintLimitOfGroup[_group]--;
        return tokenId;
    }

    /*
     * random Species of general hash
     * @param _tokenId: tokenid
     * @param _type: Species of general hash
     * @param deadline: deadline using signature
     * @param sig: signature
     */
    function randomSpecies(uint256 _tokenId, uint256 _type,uint256 deadline, bytes calldata sig ) external {
        require(deadline > block.timestamp, "General Hash:: randomSpecies:Deadline exceeded");
        require(!_signed[sig], "General Hash:: randomSpecies: Signature has been used");
        uint256 group = _generalDetail[_tokenId].group;

        address signer = recoverBridge(
            _tokenId,
            group,
            _type,
            block.chainid,
            deadline,
            sig
        );
        require(signer == validator, "General Hash:: randomSpecies:Validator fail signature");
        require(_species[group][_type].remaining > 0, "General Hash:: randomSpecies: Exceeding");

        _generalDetail[_tokenId].species = _type;
        _species[group][_type].issueAmount += 1;
        _species[group][_type].remaining = _species[group][_type].issueLimit - _species[group][_type].issueAmount;
        _signed[sig] = true;
        emit openGenesisBox(_tokenId, group, _type);
    }

    /*
     * mint a Genesishash
     * @param _address: owner of NFT
     * @param _group: group of general hash
     */
    function createNFT(
        address _address,
        uint256 _group
    ) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        uint256 tokenId = _createNFT(_address, _group);
        emit createGenesisHash(_address, tokenId, _group);
    }

    /*
     * create NFT marketing
     * @param _address: owner of NFT
     * @param _group: group of general hash
     * @param _type: type of group
     */
    function createMultipleGenesisHash(address _address, uint256 _number, uint256 _group) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        require(_number <= _mintLimitOfGroup[_group], "Genesis Hash::createMultipleNFT: Exceeding");
        uint256[] memory listToken = new uint256[](_number);
        for(uint256 i=0; i < _number;i++){
            uint256 tokenId = _createNFT(_address, _group);
            listToken[i] = tokenId;
        }
        _mintLimitOfGroup[_group] = _mintLimitOfGroup[_group] - _number;
        emit generalForMarketing(_address, listToken,_group);
    }
    /*
     * burn a Genesishash
     * @param _tokenId: tokenId burn
     */
    function burn(
        uint256 _tokenId
    ) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        _burn(_tokenId);
        uint256 _type = _generalDetail[_tokenId].species;
        uint256 _group = _generalDetail[_tokenId].group;
        _species[_group][_type].issueAmount--;
        _species[_group][_type].remaining++;
    }

    // set detail type of group
    function setGroupDetail(uint256 _group,uint256 _specie, uint256 _limit) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        _species[_group][_specie].issueLimit = _limit;
        _species[_group][_specie].remaining = _limit - _species[_group][_specie].issueAmount;
    }
    
    /*
     * Increased Index
     * @param tokenId: tokenId of NFT
     */
    function increasedIndex(
        uint256 tokenId
    ) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        indexTokenId[tokenId]++;
        if(indexTokenId[tokenId] >= limitRegeneration) {
            _burn(tokenId);
        }
    }

    function encodeBridge(
        uint256 _tokenId,
        uint256 _group,
        uint256 _type,
        uint256 _chainId,
        uint256 _deadline
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_tokenId, _group, _type, _chainId, _deadline));
    }

    function recoverBridge(
        uint256 _tokenId,
        uint256 _group,
        uint256 _type,
        uint256 _chainId,
        uint256 _deadline,
        bytes calldata _sig
    ) public pure returns (address) {
        return
            ECDSA.recover(
                ECDSA.toEthSignedMessageHash(
                    encodeBridge(_tokenId, _group, _type, _chainId, _deadline)
                ),
                _sig
            );
    }

}
