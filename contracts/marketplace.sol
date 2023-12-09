// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//Logic imppl

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SkillTokenMarketplace {
    address public admin;

    // Struct to represent a skill listing
    struct SkillListing {
        address seller;
        string skill;
        uint256 price;
        bool isActive;
        uint256 totalKudos;
    }

    // Struct to represent user profiles
    struct UserProfile {
        uint256 totalKudosReceived;
    }

    // Mapping to store skill listings
    mapping(uint256 => SkillListing) public skillListings;

    // Mapping to store user profiles
    mapping(address => UserProfile) public userProfiles;

    // Counter for generating unique listing IDs
    uint256 public listingIdCounter;

    // Skill token contract address
    address public skillTokenAddress;

    // Event emitted when a new skill listing is created
    event SkillListingCreated(uint256 indexed listingId, address indexed seller, string skill, uint256 price);

    // Event emitted when a skill listing is removed
    event SkillListingRemoved(uint256 indexed listingId);

    // Event emitted when a skill exchange occurs
    event SkillExchange(uint256 indexed listingId, address indexed buyer);

    // Event emitted when a user gives kudos
    event KudosGiven(address indexed giver, address indexed receiver);

    constructor(address _skillTokenAddress) {
        admin = msg.sender;
        skillTokenAddress = _skillTokenAddress;
    }

    // Admin function to add a new skill listing
    function createSkillListing(string memory skill, uint256 price) external onlyAdmin {
        uint256 listingId = listingIdCounter++;
        skillListings[listingId] = SkillListing({
            seller: msg.sender,
            skill: skill,
            price: price,
            isActive: true,
            totalKudos: 0
        });

        emit SkillListingCreated(listingId, msg.sender, skill, price);
    }

    // User function to remove their own skill listing
    function removeSkillListing(uint256 listingId) external onlyActiveListing(listingId) {
        require(msg.sender == skillListings[listingId].seller, "Not the listing owner");
        skillListings[listingId].isActive = false;

        emit SkillListingRemoved(listingId);
    }

    // User function to exchange skill tokens for a listed skill
    function exchangeSkill(uint256 listingId) external onlyActiveListing(listingId) {
        SkillListing storage listing = skillListings[listingId];
        require(IERC20(skillTokenAddress).transferFrom(msg.sender, listing.seller, listing.price), "Token transfer failed");

        // Deactivate the skill listing after exchange
        listing.isActive = false;

        // Increase total kudos for the seller
        listing.totalKudos++;

        // Increase total kudos received for the buyer
        userProfiles[msg.sender].totalKudosReceived++;

        emit SkillExchange(listingId, msg.sender);
    }

    // User function to give kudos to another user
    function giveKudos(address receiver) external {
        require(receiver != msg.sender, "Cannot give kudos to yourself");

        // Increase total kudos for the receiver
        userProfiles[receiver].totalKudosReceived++;

        emit KudosGiven(msg.sender, receiver);
    }

    // Modifier to ensure that a skill listing is active
    modifier onlyActiveListing(uint256 listingId) {
        require(skillListings[listingId].isActive, "Skill listing is not active");
        _;
    }

    // Modifier to ensure that only the admin can execute certain functions
    modifier onlyAdmin() {
        require(msg.sender == admin, "Not the admin");
        _;
    }
}
