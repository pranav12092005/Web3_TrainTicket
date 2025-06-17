// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract FairTicketBooking {
    address public owner;
    uint256 public totalTickets;
    bool public registrationOpen;

    struct User {
        address userAddress;
        uint256 timestamp;
        bool isEligible;
    }

    struct WaitlistEntry {
        address userAddress;
        uint256 timestamp;
    }

    mapping(address => User) public users;
    address[] public eligibleUsers;
    WaitlistEntry[] public waitlist;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier registrationActive() {
        require(registrationOpen, "Registration is not open");
        _;
    }

    event RegistrationOpened();
    event RegistrationClosed();
    event UserClickedKey(address indexed user, uint256 timestamp);
    event SlotReleased(address indexed user);
    event WaitlistPromoted(address indexed user);
    event UserCancelled(address indexed user);

    constructor(uint256 _totalTickets) {
        owner = msg.sender;
        totalTickets = _totalTickets;
        registrationOpen = false;
    }

    
    function clickKey() external registrationActive {
        require(users[msg.sender].timestamp == 0, "User already clicked the key");

        uint256 currentTimestamp = block.timestamp;
        users[msg.sender] = User({
            userAddress: msg.sender,
            timestamp: currentTimestamp,
            isEligible: false
        });

        emit UserClickedKey(msg.sender, currentTimestamp);

        if (eligibleUsers.length < totalTickets) {
            users[msg.sender].isEligible = true;
            eligibleUsers.push(msg.sender);
        } else {
            waitlist.push(WaitlistEntry({
                userAddress: msg.sender,
                timestamp: currentTimestamp
            }));
        }
    }

    
    function releaseSlot(address userAddress) external onlyOwner {
        _removeUserFromEligible(userAddress);
    }


    function cancelEligibility() external {
        require(users[msg.sender].isEligible, "User is not eligible");
        _removeUserFromEligible(msg.sender);
        emit UserCancelled(msg.sender);
    }

    function _removeUserFromEligible(address userAddress) internal {
        require(users[userAddress].isEligible, "User is not eligible");

        users[userAddress].isEligible = false;

      
        for (uint256 i = 0; i < eligibleUsers.length; i++) {
            if (eligibleUsers[i] == userAddress) {
                eligibleUsers[i] = eligibleUsers[eligibleUsers.length - 1];
                eligibleUsers.pop();
                break;
            }
        }

        emit SlotReleased(userAddress);

        
        if (waitlist.length > 0) {
            WaitlistEntry memory nextInLine = waitlist[0];
            users[nextInLine.userAddress].isEligible = true;
            eligibleUsers.push(nextInLine.userAddress);

            
            for (uint256 i = 0; i < waitlist.length - 1; i++) {
                waitlist[i] = waitlist[i + 1];
            }
            waitlist.pop();

            emit WaitlistPromoted(nextInLine.userAddress);
        }
    }

   
    function openRegistration() external onlyOwner {
        require(!registrationOpen, "Registration is already open");
        registrationOpen = true;
        emit RegistrationOpened();
    }

   
    function closeRegistration() external onlyOwner {
        require(registrationOpen, "Registration is already closed");
        registrationOpen = false;
        emit RegistrationClosed();
    }

    
    function getEligibleUsers() external view returns (address[] memory) {
        return eligibleUsers;
    }

   
    function getWaitlist() external view returns (WaitlistEntry[] memory) {
        return waitlist;
    }
}