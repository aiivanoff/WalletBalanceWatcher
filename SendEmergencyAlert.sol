// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SendEmergencyAlert {
    event EmergencyTriggered(string message);

    function handleAnomaly(string calldata message) external {
        emit EmergencyTriggered(message);
    }
}
