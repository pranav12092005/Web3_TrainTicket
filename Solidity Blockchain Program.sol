// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract FairTicketBooking {
    address public owner;
    uint256 public totalTickets;
    uint256 public ticketPrice;
    bool public registrationOpen;

    struct User {
        address userAddress;
        uint256 timestamp;
        bool isEligible;
        bool hasPaid;
        bool isConfirmed;
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
    event PaymentReceived(address indexed user, uint256 amount);
    event RefundIssued(address indexed user, uint256 amount);
    event ConfirmedForBankTransfer(address indexed user);

    constructor(uint256 _totalTickets, uint256 _ticketPriceInWei) {
        owner = msg.sender;
        totalTickets = _totalTickets;
        ticketPrice = _ticketPriceInWei;
        registrationOpen = false;
    }

    function clickKey() external registrationActive {
        require(users[msg.sender].timestamp == 0, "Already clicked");

        uint256 currentTimestamp = block.timestamp;
        users[msg.sender] = User({
            userAddress: msg.sender,
            timestamp: currentTimestamp,
            isEligible: false,
            hasPaid: false,
            isConfirmed: false
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

    function payForTicket() external payable {
        require(!users[msg.sender].hasPaid, "Already paid");
        require(users[msg.sender].timestamp != 0, "Not registered");
        require(msg.value == ticketPrice, "Incorrect payment");

        users[msg.sender].hasPaid = true;
        emit PaymentReceived(msg.sender, msg.value);
    }

    function cancelEligibility() external {
        _handleCancellation(msg.sender);
        emit UserCancelled(msg.sender);
    }

    function releaseSlot(address userAddress) external onlyOwner {
        _handleCancellation(userAddress);
    }

    function _handleCancellation(address userAddress) internal {
        User storage user = users[userAddress];
        require(user.isEligible || _isInWaitlist(userAddress), "Not eligible or waitlisted");

        if (user.hasPaid && !user.isConfirmed) {
            user.hasPaid = false;
            payable(userAddress).transfer(ticketPrice);
            emit RefundIssued(userAddress, ticketPrice);
        }

        if (user.isEligible) {
            user.isEligible = false;
            _removeFromEligible(userAddress);
            emit SlotReleased(userAddress);
        }

        _removeFromWaitlist(userAddress);

        _promoteWaitlist();
    }

    function _promoteWaitlist() internal {
        if (waitlist.length > 0) {
            WaitlistEntry memory nextInLine = waitlist[0];
            address nextUser = nextInLine.userAddress;
            users[nextUser].isEligible = true;
            eligibleUsers.push(nextUser);

            if (users[nextUser].hasPaid) {
                users[nextUser].isConfirmed = true;
                emit ConfirmedForBankTransfer(nextUser); // IRCTC backend will monitor this event
            }

            _shiftWaitlist();
            emit WaitlistPromoted(nextUser);
        }
    }
    function _shiftWaitlist() internal {
    for (uint256 i = 0; i < waitlist.length - 1; i++) {
        waitlist[i] = waitlist[i + 1];
    }
    waitlist.pop();
}


    function _removeFromEligible(address userAddress) internal {
        for (uint256 i = 0; i < eligibleUsers.length; i++) {
            if (eligibleUsers[i] == userAddress) {
                eligibleUsers[i] = eligibleUsers[eligibleUsers.length - 1];
                eligibleUsers.pop();
                break;
            }
        }
    }

    function _removeFromWaitlist(address userAddress) internal {
        for (uint256 i = 0; i < waitlist.length; i++) {
            if (waitlist[i].userAddress == userAddress) {
                for (uint256 j = i; j < waitlist.length - 1; j++) {
                    waitlist[j] = waitlist[j + 1];
                }
                waitlist.pop();
                break;
            }
        }
    }

    function _isInWaitlist(address userAddress) internal view returns (bool) {
        for (uint256 i = 0; i < waitlist.length; i++) {
            if (waitlist[i].userAddress == userAddress) {
                return true;
            }
        }
        return false;
    }

    function openRegistration() external onlyOwner {
        require(!registrationOpen, "Already open");
        registrationOpen = true;
        emit RegistrationOpened();
    }

    function closeRegistration() external onlyOwner {
        require(registrationOpen, "Already closed");
        registrationOpen = false;
        emit RegistrationClosed();
    }

    function getEligibleUsers() external view returns (address[] memory) {
        return eligibleUsers;
    }

    function getWaitlist() external view returns (WaitlistEntry[] memory) {
        return waitlist;
    }

    function withdrawForIRCTC(address[] calldata confirmedUsers) external onlyOwner {
        uint256 total = 0;
        for (uint i = 0; i < confirmedUsers.length; i++) {
            address u = confirmedUsers[i];
            if (users[u].isConfirmed && users[u].hasPaid) {
                users[u].hasPaid = false; // prevent re-use
                total += ticketPrice;
            }
        }

        payable(owner).transfer(total); // IRCTC backend will handle bank transfer off-chain
    }

    receive() external payable {}
}
