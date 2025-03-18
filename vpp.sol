
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VPPGridInteraction {
    address public vppOwner;

    struct DemandResponseEvent {
        uint256 id;
        uint256 duration;
        uint256 reductionPercentage;
        bool isActive;
        uint256 startTime;
    }

    uint256 public eventCount;
    mapping(uint256 => DemandResponseEvent) public demandResponseEvents;

    event DemandResponseInitiated(uint256 indexed eventId, uint256 duration, uint256 reductionPercentage);
    event DemandResponseEnded(uint256 indexed eventId);

    modifier onlyOwner() {
        require(msg.sender == vppOwner, "Not the VPP owner");
        _;
    }

    constructor(address _vppOwner) {
        vppOwner = _vppOwner;
    }

    function initiateDemandResponse(uint256 _duration, uint256 _reductionPercentage) public onlyOwner {
        require(_reductionPercentage > 0 && _reductionPercentage <= 100, "Invalid reduction percentage");

        eventCount++;
        demandResponseEvents[eventCount] = DemandResponseEvent({
            id: eventCount,
            duration: _duration,
            reductionPercentage: _reductionPercentage,
            isActive: true,
            startTime: block.timestamp
        });

        emit DemandResponseInitiated(eventCount, _duration, _reductionPercentage);
    }

    function participateInDemandResponse(uint256 _eventId) public {
        DemandResponseEvent storage eventDetails = demandResponseEvents[_eventId];
        require(eventDetails.isActive, "Demand response event is not active");
        
        // Logic for aggregators and smart meters to curtail energy consumption
        // (Implementation details depend on specific application)
        
        // Example:
        // uint256 curtailmentAmount = calculateCurtailment(eventDetails.reductionPercentage);
    }

    function adjustEnergyProduction(uint256 _eventId) public {
        DemandResponseEvent storage eventDetails = demandResponseEvents[_eventId];
        require(eventDetails.isActive, "Demand response event is not active");
        
        // Logic for prosumers to adjust energy production
        // (Implementation details depend on specific application)
        
        // Example:
        // increaseSolarGeneration(eventDetails.reductionPercentage);
    }

    function endDemandResponse(uint256 _eventId) public onlyOwner {
        DemandResponseEvent storage eventDetails = demandResponseEvents[_eventId];
        require(eventDetails.isActive, "Demand response event is not active");
        
        eventDetails.isActive = false;

        emit DemandResponseEnded(_eventId);
    }
}
