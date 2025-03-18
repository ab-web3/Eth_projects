//Below is the smart contract for handling energy trading and customer data.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract EnergyTrading {
    address public owner;
    
    struct EnergyOffer {
        address prosumer;
        uint256 energyAmount;
        uint256 pricePerKWh;
        bool isActive;
    }
    
    mapping(uint256 => EnergyOffer) public offers;
    mapping(address => uint256) public frequency;
    uint256 public offerCounter;
    
    event OfferCreated(uint256 indexed offerId, address indexed prosumer, uint256 energyAmount, uint256 pricePerKWh);
    event OfferAccepted(uint256 indexed offerId, address indexed consumer);
    event FrequencyError(address indexed sender);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function createEnergyOffer(uint256 _energyAmount, uint256 _pricePerKWh, uint256 _frequency) external {
        require(msg.sender == owner, "Only owner can create offers");
        require(_frequency == 50, "Frequency must be 50Hz");
        
        offerCounter++;
        offers[offerCounter] = EnergyOffer(msg.sender, _energyAmount, _pricePerKWh, true);
        
        emit OfferCreated(offerCounter, msg.sender, _energyAmount, _pricePerKWh);
    }
    
    function acceptOffer(uint256 _offerId) external payable {
        EnergyOffer storage offer = offers[_offerId];
        require(offer.isActive, "Offer is not active");
        require(msg.value >= offer.energyAmount * offer.pricePerKWh, "Insufficient payment");
        
        offer.isActive = false;
        payable(offer.prosumer).transfer(msg.value);
        
        emit OfferAccepted(_offerId, msg.sender);
    }
    
    function recordFrequencyError(address _sender) internal {
        emit FrequencyError(_sender);
    }
}
