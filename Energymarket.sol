// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract EnergyMarket {
    address public owner;

    struct EnergyOffer {
        uint amount;  // Energy amount in kWh
        uint price;   // Price per kWh in wei
        bool isActive;
        address producer;
    }

    mapping(address => uint) public frequencyMap; // Store frequency data
    mapping(uint => EnergyOffer) public energyOffers; // Store energy offers
    uint public offerCounter;

    event EnergyOfferCreated(uint indexed offerId, address indexed producer, uint amount, uint price);
    event EnergyPurchased(uint indexed offerId, address indexed buyer, uint amount, uint totalPrice);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setFrequency(address producer, uint frequency) external onlyOwner {
        frequencyMap[producer] = frequency;
    }

    function createEnergyOffer(uint amount, uint price) external {
        require(frequencyMap[msg.sender] == 50, "Frequency must be 50Hz");
        require(amount > 0 && price > 0, "Amount and price must be greater than zero");

        energyOffers[offerCounter] = EnergyOffer(amount, price, true, msg.sender);
        emit EnergyOfferCreated(offerCounter, msg.sender, amount, price);
        offerCounter++;
    }

    function purchaseEnergy(uint offerId, uint amount) external payable {
        EnergyOffer storage offer = energyOffers[offerId];
        require(offer.isActive, "Offer is not active");
        require(amount > 0 && amount <= offer.amount, "Invalid amount requested");
        uint totalPrice = offer.price * amount;
        require(msg.value >= totalPrice, "Insufficient funds");

        offer.amount -= amount;
        if (offer.amount == 0) {
            offer.isActive = false;
        }

        payable(offer.producer).transfer(totalPrice);
        emit EnergyPurchased(offerId, msg.sender, amount, totalPrice);
    }
}
