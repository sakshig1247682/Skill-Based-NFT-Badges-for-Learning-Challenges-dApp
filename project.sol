// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SkillBadgeNFT is ERC721, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Badge {
        string skillName;
        string description;
        string badgeLevel;
        uint256 mintedAt;
    }

    mapping(uint256 => Badge) private _badges;

    event BadgeMinted(
        address indexed recipient, 
        uint256 indexed tokenId, 
        string skillName, 
        string badgeLevel,
        uint256 timestamp
    );

    constructor() ERC721("SkillBadgeNFT", "SBNFT") Ownable(msg.sender) {}

    function mintBadge(
        address recipient,
        string memory skillName,
        string memory description,
        string memory badgeLevel
    ) 
        public 
        onlyOwner 
        nonReentrant 
        returns (uint256) 
    {
        require(recipient != address(0), "Invalid recipient address");
        require(bytes(skillName).length > 0, "Skill name cannot be empty");
        require(bytes(description).length > 0, "Description cannot be empty");
        require(bytes(badgeLevel).length > 0, "Badge level cannot be empty");

        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _safeMint(recipient, newTokenId);

        _badges[newTokenId] = Badge({
            skillName: skillName,
            description: description,
            badgeLevel: badgeLevel,
            mintedAt: block.timestamp
        });

        emit BadgeMinted(
            recipient, 
            newTokenId, 
            skillName, 
            badgeLevel,
            block.timestamp
        );

        return newTokenId;
    }

    function getBadgeDetails(uint256 tokenId)
        public
        view
        returns (
            string memory skillName,
            string memory description,
            string memory badgeLevel,
            uint256 mintedAt
        )
    {
        require(ownerOf(tokenId) != address(0), "Token ID does not exist");
        Badge memory badge = _badges[tokenId];
        return (
            badge.skillName,
            badge.description,
            badge.badgeLevel,
            badge.mintedAt
        );
    }
}