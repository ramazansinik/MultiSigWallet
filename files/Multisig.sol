// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.5;

contract Multisig {
    address[] public approvers;
    uint public quorum;
    
    struct Transfer {
        uint id;
        uint amount;
        address payable to;
        uint approvals;
        bool sent;
    }
    
    Transfer[] public transfers;
    
    mapping(address => mapping(uint => bool)) public approvals;
    
    constructor(address[] memory _approvers, uint _quorum) {
        approvers = _approvers;
        quorum =    _quorum;
    }
    
    function getApprovers() external view returns (address[] memory) {
        return approvers;
    }

    function getTransfers() external view returns (Transfer[] memory) {
        return transfers;
    }

    function createTransfer(uint amount, address payable to) external onlyApprover() {
        transfers.push(Transfer(
            transfers.length,
            amount,
            to,
            0,
            false
        ));
    }
    
    function approveTransfer(uint id) external onlyApprover() {
        require(transfers[id].sent == false, 'Transfer has already been sent!');
        require(approvals[msg.sender][id] == false, 'You have already approved this transfer');
        
        approvals[msg.sender][id] = true;
        transfers[id].approvals++;
        
        if(transfers[id].approvals >= quorum) {
            transfers[id].sent = true;
            address payable to = transfers[id].to; 
            uint amount = transfers[id].amount;
            to.transfer(amount);
        }
    }
    
    receive() external payable {}
    
    
    modifier onlyApprover () {
        bool allowed = false;
        for(uint i; i < approvers.length; i++){
            if(approvers[i] == msg.sender){
                allowed = true;
            }
        }
        require(allowed == true, 'Only Approvers can use this function');
        _;
    }
    
}
