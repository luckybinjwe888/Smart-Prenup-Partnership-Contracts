// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract BondChain {
    enum Status {Active, Terminated}

    struct Partnership {
        address partner1;
        address partner2;
        uint256 startTimestamp;
        Status status;
        string termsHash; // IPFS or off-chain storage hash of prenup terms
    }

    mapping(bytes32 => Partnership) public partnerships;

    event PartnershipCreated(bytes32 indexed partnershipId, address partner1, address partner2, string termsHash);
    event PartnershipTerminated(bytes32 indexed partnershipId);

    modifier onlyPartner(bytes32 partnershipId) {
        Partnership storage p = partnerships[partnershipId];
        require(msg.sender == p.partner1 || msg.sender == p.partner2, "Not a partner");
        _;
    }

    function createPartnership(address partner2, string calldata termsHash) external returns (bytes32) {
        require(msg.sender != partner2, "Cannot partner with self");

        bytes32 partnershipId = keccak256(abi.encodePacked(msg.sender, partner2, block.timestamp));
        partnerships[partnershipId] = Partnership({
            partner1: msg.sender,
            partner2: partner2,
            startTimestamp: block.timestamp,
            status: Status.Active,
            termsHash: termsHash
        });

        emit PartnershipCreated(partnershipId, msg.sender, partner2, termsHash);
        return partnershipId;
    }

    function terminatePartnership(bytes32 partnershipId) external onlyPartner(partnershipId) {
        Partnership storage p = partnerships[partnershipId];
        require(p.status == Status.Active, "Already terminated");

        p.status = Status.Terminated;
        emit PartnershipTerminated(partnershipId);
    }

    function getPartnership(bytes32 partnershipId) external view returns (
        address partner1, address partner2, uint256 startTimestamp, Status status, string memory termsHash
    ) {
        Partnership storage p = partnerships[partnershipId];
        return (p.partner1, p.partner2, p.startTimestamp, p.status, p.termsHash);
    }
}
