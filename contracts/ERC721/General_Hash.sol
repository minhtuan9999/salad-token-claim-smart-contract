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
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract GeneralHash is Ownable, ERC721Enumerable, AccessControl, Pausable, ReentrancyGuard {
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
    // Validator signtransaction
    address public validator;
    // Number type of group
    uint256[] typeOfGruop = [0,4,4,4,4];

    constructor() ERC721("General Hash", "GeneralHash") {
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
        validator = _msgSender();
    }

    //=======================================MAPPING=======================================//
    // Mapping SpeciesDetail (group => (type => SpeciesDetail))
    mapping(uint256 => mapping(uint256 => SpeciesDetail)) public _species;
    // Mapping tokenId detail
    mapping(uint256 => GeneralDetail) public _generalDetail;
    // Mapping list token of address
    mapping(address => EnumerableSet.UintSet) _listTokensOfAddress;
    // Status of signature code
    mapping(bytes => bool) public _signed;
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

    // Set Validator
    function initSetValidator(
        address _address
    ) external whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        validator = _address;
    }
    
    // Set type of group
    function setTypeOfGroup(
        uint256 group,
        uint256 number
    ) external whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        typeOfGruop[group] = number;
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
        _boxOfAddress[_address][_group] = _boxOfAddress[_address][_group] + _number;
        emit createGeneralBoxs(_address, _number, _group);
    }
    
    // get type random
    function getTypeOfGroup(
        uint256 _group,
        uint256 deadline,
        bytes calldata sig
    ) internal view returns(uint256) {
        uint256 _type;
        uint256 totalTypes = typeOfGruop[_group];
        for (uint256 i = 1; i <= totalTypes; i++) {
            address signer = recoverBridge(
                _group,
                i,
                block.chainid,
                deadline,
                sig
            );
            if(signer == validator) {
                _type = i;
                break;
            }
        }
        return _type;
    }

    /*
     * random Species of general hash
     * @param _tokenId: tokenid
     * @param deadline: deadline using signature
     * @param sig: signature
     */
    function openBoxGeneral(
        uint256 _group,
        uint256 deadline,
        bytes calldata sig
    ) external whenNotPaused nonReentrant {
        require(
            deadline > block.timestamp,
            "General Hash:: openBoxGeneral:Deadline exceeded"
        );
        require(
            !_signed[sig],
            "General Hash:: openBoxGeneral: Signature has been used"
        );
        require(
            _boxOfAddress[msg.sender][_group] > 0,
            "General Hash:: openBoxGeneral: Exceeding box"
        );
        uint256 _type = getTypeOfGroup(_group, deadline, sig);
        require(_type > 0, "General Hash:: openBoxGeneral: Type not exits");
        require(
            _species[_group][_type].remaining > 0,
            "General Hash:: openBoxGeneral: Maxsupply  of type"
        );
        uint256 tokenId = _tokenIds.current();
        _mint(msg.sender, tokenId);
        _tokenIds.increment();

        _generalDetail[tokenId].group = _group;
        _generalDetail[tokenId].species = _type;

        _species[_group][_type].issueAmount += 1;
        _species[_group][_type].remaining =
            _species[_group][_type].issueLimit -
            _species[_group][_type].issueAmount;

        _signed[sig] = true;
        
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

    function encodeBridge(
        uint256 _group,
        uint256 _type,
        uint256 _chainId,
        uint256 _deadline
    ) public pure returns (bytes32) {
        return
            keccak256(abi.encode(_group, _type, _chainId, _deadline));
    }

    function recoverBridge(
        uint256 _group,
        uint256 _type,
        uint256 _chainId,
        uint256 _deadline,
        bytes calldata _sig
    ) public pure returns (address) {
        return
            ECDSA.recover(
                ECDSA.toEthSignedMessageHash(
                    encodeBridge(_group, _type, _chainId, _deadline)
                ),
                _sig
            );
    }
}
