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
import "../Random/randomBox.sol";

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
        uint256 issueAmount;
        uint256 issueMarketing;
        uint256[] limitType;
        uint256[] amountType;
    }

    // Detail of token id
    struct GeneralDetail {
        uint256 tokenId;
        Group group;
        uint256 species;
        uint256 timesRegeneration;
    }

    enum Group {
        GROUP_A,
        GROUP_B, 
        GROUP_C,
        GROUP_D,
        GROUP_E
    }

    // Count token Id
    Counters.Counter private _tokenIds;
    bytes32 public constant MANAGEMENT_ROLE = keccak256("MANAGEMENT_ROLE");
    // Base URI
    string private _baseURIextended;
    // set value group
    uint256[] public listGroup;
    // NFT detail: Season => (tokenId => number Of Regenerations))
    mapping(uint256 =>  mapping(uint256 => uint256)) public _numberOfRegenerations;
    //=======================================MAPPING=======================================//
    // Mapping tokenId detail
    mapping(uint256 => GeneralDetail) public generalDetail;
    // Mapping list token of address
    mapping(address => EnumerableSet.UintSet) listTokensOfAddress;
    // Detail of group
    mapping(Group => GroupDetail) public groupDetail;
    // Number box of group
    mapping(address => mapping(Group => uint256)) public boxOfAddress;

    //
    constructor() ERC721("General Hash", "GeneralHash") {
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());

        groupDetail[Group.GROUP_A].totalSupply = 400;
        groupDetail[Group.GROUP_A].issueMarketing = 80;
        groupDetail[Group.GROUP_A].limitType = [100, 100, 100, 100];
        groupDetail[Group.GROUP_A].amountType = [0, 0, 0, 0];

        groupDetail[Group.GROUP_B].totalSupply = 400;
        groupDetail[Group.GROUP_B].issueMarketing = 80;
        groupDetail[Group.GROUP_B].limitType = [100, 100, 100, 100];
        groupDetail[Group.GROUP_B].amountType = [0, 0, 0, 0];
        
        groupDetail[Group.GROUP_C].totalSupply = 500;
        groupDetail[Group.GROUP_C].issueMarketing = 100;
        groupDetail[Group.GROUP_C].limitType = [100, 100, 100, 100, 100];
        groupDetail[Group.GROUP_C].amountType = [0, 0, 0, 0, 0];

        groupDetail[Group.GROUP_D].totalSupply = 400;
        groupDetail[Group.GROUP_D].issueMarketing = 80;
        groupDetail[Group.GROUP_D].limitType = [100, 100, 100, 100];
        groupDetail[Group.GROUP_D].amountType = [0, 0, 0, 0];

        groupDetail[Group.GROUP_E].totalSupply = 400;
        groupDetail[Group.GROUP_E].issueMarketing = 80;
        groupDetail[Group.GROUP_E].limitType = [100, 100, 100, 100];
        groupDetail[Group.GROUP_E].amountType = [0, 0, 0, 0];
    }

    //=======================================EVENT=======================================//
    // Event create box
    event createBoxs(address _address, uint256 number, Group group);
    // Event random type of Group
    event openBoxs(uint256 tokenId, Group group, uint256 _type);

    //=======================================FUNCTION=======================================//
    // Get list Tokens of address
    function getListTokensOfAddress(
        address _address
    ) public view returns (uint256[] memory) {
        return listTokensOfAddress[_address].values();
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
        listTokensOfAddress[to].add(firstTokenId);
        listTokensOfAddress[from].remove(firstTokenId);
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
     * mint a box
     * @param _address: owner of NFT
     * @param _type: group of general hash
     */
    function createBox(
        address _address,
        uint8 _type
    ) external nonReentrant whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        Group newGroup;
        if(_type == 0) {
            newGroup = Group.GROUP_A;
        }else if(_type == 1) {
            newGroup = Group.GROUP_B;
        }else if(_type == 2) {
            newGroup = Group.GROUP_C;
        }else if(_type == 3) {
            newGroup = Group.GROUP_D;
        }else if(_type == 4) {
            newGroup = Group.GROUP_E;
        }else {
            revert("Unsupported group");
        }
        uint256 remainingGroup = groupDetail[newGroup].totalSupply - groupDetail[newGroup].issueAmount;
        require(remainingGroup > 0, "Exceeding");
        groupDetail[newGroup].issueAmount++;
        boxOfAddress[_address][newGroup]++;
        emit createBoxs(_address, 1, newGroup);
    }

    /*
     * claim Maketing Box
     * @param _address: owner of NFT
     * @param _group: group of general hash
     */
    function claimMaketingBox(
        address _address,
        Group group
    ) external nonReentrant whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        uint256 amount = groupDetail[group].issueMarketing;
        require(amount > 0, "Exceeding limit marketing");
        groupDetail[group].issueAmount += amount;
        boxOfAddress[_address][group] += amount;
        groupDetail[group].issueMarketing = 0;
        emit createBoxs(_address, amount, group);
    }

    // send group maketing by admin
    function sendGroup(address to, Group group, uint256 number) external whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        require(boxOfAddress[msg.sender][group] > number, "Exceeding group");
        boxOfAddress[msg.sender][group] -= number;
        boxOfAddress[to][group] += number;
    }
    
    // get type random
    function _getTypeOfGroup(Group group) private returns (uint256) {
        uint256 limit1 = groupDetail[group].limitType[0];
        uint256 remaining1 = groupDetail[group].limitType[0] - groupDetail[group].amountType[0];
        uint256 limit2 = groupDetail[group].limitType[1];
        uint256 remaining2 = groupDetail[group].limitType[1] - groupDetail[group].amountType[1];
        uint256 limit3 = groupDetail[group].limitType[2];
        uint256 remaining3 = groupDetail[group].limitType[2] - groupDetail[group].amountType[2];
        uint256 limit4 = groupDetail[group].limitType[3];
        uint256 remaining4 = groupDetail[group].limitType[3] - groupDetail[group].amountType[3];
        uint256 limit5 = 0;
        uint256 remaining5 = 0;
        if(group == Group.GROUP_C) {
            limit5 = groupDetail[group].limitType[4];
            remaining5 = groupDetail[group].limitType[4] - groupDetail[group].amountType[4];
        }

        uint256 _type = openBox(
            limit1,
            remaining1,
            limit2,
            remaining2,
            limit3,
            remaining3,
            limit4,
            remaining4,
            limit5,
            remaining5
        );
        return _type;
    }

    /*
     * open box
     * @param _group: group of Box
     */
    function openGeneralBox(
        Group group
    ) external whenNotPaused nonReentrant {
        require(
            boxOfAddress[msg.sender][group] > 0,
            "Exceeding box"
        );
        uint256 _type = _getTypeOfGroup(group);
        uint256 tokenId = _tokenIds.current();
        _mint(msg.sender, tokenId);
        _tokenIds.increment();

        generalDetail[tokenId].group = group;
        generalDetail[tokenId].species = _type;
        generalDetail[tokenId].tokenId = tokenId;

        groupDetail[group].amountType[_type] += 1;
        boxOfAddress[msg.sender][group]--;
        emit openBoxs(tokenId, group, _type);
    }

    /*
     * burn tokenId
     * @param _tokenId: tokenId burn
     */
    function burn(
        uint256 _tokenId
    ) external nonReentrant whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        uint256 _type = generalDetail[_tokenId].species;
        Group group = generalDetail[_tokenId].group;
        groupDetail[group].amountType[_type]--;
        groupDetail[group].issueAmount--;
        delete generalDetail[_tokenId];
        _burn(_tokenId);
    }

    // get listBox, list Token of address
    function getDetailAddress(address _address) public view returns(uint256[] memory, uint256[] memory) {
        uint256[] memory listBox = new uint256[](5);
        listBox[0] = boxOfAddress[_address][Group.GROUP_A];
        listBox[1] = boxOfAddress[_address][Group.GROUP_B];
        listBox[2] = boxOfAddress[_address][Group.GROUP_C];
        listBox[3] = boxOfAddress[_address][Group.GROUP_D];
        listBox[4] = boxOfAddress[_address][Group.GROUP_E];
        return (listBox, listTokensOfAddress[_address].values());
    }

    // get type of list Token
    function getTypeOfListToken(uint256[] memory _listToken) public view returns(GeneralDetail[] memory) {
        GeneralDetail[] memory listTypes = new GeneralDetail[](_listToken.length);
        for(uint256 i=0; i< _listToken.length; i++) {
            listTypes[i] = generalDetail[_listToken[i]];
        }
        return listTypes;
    }
    //get group detail
    function getDetailGroup(uint256 _group) external view returns(GroupDetail memory group) {
        if (_group == 0) {
            group = groupDetail[Group.GROUP_A];
        }
        if (_group == 1) {
            group = groupDetail[Group.GROUP_B];
        }
        if (_group == 2) {
            group = groupDetail[Group.GROUP_C];
        }
        if (_group == 3) {
            group = groupDetail[Group.GROUP_D];
        }
        if (_group == 4) {
            group = groupDetail[Group.GROUP_E];
        }
    }
     function setTimesOfRegeneration(uint256 season, uint256 tokenId, uint256 times) external onlyRole(MANAGEMENT_ROLE) {
        _numberOfRegenerations[season][tokenId] = times;
        generalDetail[tokenId].timesRegeneration =times;
    }
}
