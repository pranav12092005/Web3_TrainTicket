const contractAddress = "0xFD1d23258F4a0cfffc98Ff815934a21378209Bba"; 
const contractABI = [
	{
		"inputs": [],
		"name": "cancelEligibility",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "clickKey",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "closeRegistration",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "openRegistration",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "userAddress",
				"type": "address"
			}
		],
		"name": "releaseSlot",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_totalTickets",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [],
		"name": "RegistrationClosed",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [],
		"name": "RegistrationOpened",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "user",
				"type": "address"
			}
		],
		"name": "SlotReleased",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "user",
				"type": "address"
			}
		],
		"name": "UserCancelled",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			}
		],
		"name": "UserClickedKey",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "user",
				"type": "address"
			}
		],
		"name": "WaitlistPromoted",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "eligibleUsers",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getEligibleUsers",
		"outputs": [
			{
				"internalType": "address[]",
				"name": "",
				"type": "address[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getWaitlist",
		"outputs": [
			{
				"components": [
					{
						"internalType": "address",
						"name": "userAddress",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "timestamp",
						"type": "uint256"
					}
				],
				"internalType": "struct FairTicketBooking.WaitlistEntry[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "registrationOpen",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "totalTickets",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "users",
		"outputs": [
			{
				"internalType": "address",
				"name": "userAddress",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			},
			{
				"internalType": "bool",
				"name": "isEligible",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "waitlist",
		"outputs": [
			{
				"internalType": "address",
				"name": "userAddress",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
];

let web3;
let contract;
let userAddress;

document.getElementById("connectWallet").onclick = async () => {
  if (window.ethereum) {
    try {
      
      await window.ethereum.request({ method: "eth_requestAccounts" });
      web3 = new Web3(window.ethereum);

     
      const accounts = await web3.eth.getAccounts();
      userAddress = accounts[0];
      document.getElementById("walletAddress").innerText = `Wallet Address: ${userAddress}`;

      
      contract = new web3.eth.Contract(contractABI, contractAddress);
      console.log("Contract initialized:", contract);
    } catch (error) {
      console.error("Error connecting to wallet:", error);
      alert("Failed to connect wallet. Please try again.");
    }
  } else {
    alert("MetaMask is not installed. Please install it to interact with this application!");
  }
};

// Handle "Click to Register" button
document.getElementById("clickKey").onclick = async () => {
  if (!contract || !userAddress) {
    alert("Connect your wallet first!");
    return;
  }

  try {
    await contract.methods.clickKey().send({ from: userAddress });
    document.getElementById("clickKeyStatus").innerText = "Successfully registered!";
  } catch (error) {
    document.getElementById("clickKeyStatus").innerText = `Error: ${error.message}`;
    console.error("Error executing clickKey:", error);
  } 
}


// Fetch eligible users
document.getElementById("getEligibleUsers").onclick = async () => {
  if (!contract) {
    alert("Connect your wallet first!");
    return;
  }

  try {
    const eligibleUsers = await contract.methods.getEligibleUsers().call();
    const eligibleList = document.getElementById("eligibleUsersList");
    eligibleList.innerHTML = "";

    eligibleUsers.forEach(user => {
      const listItem = document.createElement("li");
      listItem.textContent = user;
      eligibleList.appendChild(listItem);
	  const paymentgate = document.getElementById("paymentgate");
	  paymentgate.innerHTML="<a href='payment.html'>Click here to book</a>";
    });
  } catch (error) {
    console.error("Error fetching eligible users:", error);
  }
};

// Fetch waitlist
document.getElementById("getWaitlist").onclick = async () => {
  if (!contract) {
    alert("Connect your wallet first!");
    return;
  }

  try {
    const waitlist = await contract.methods.getWaitlist().call();
    const waitlistList = document.getElementById("waitlistList");
    waitlistList.innerHTML = "";

    waitlist.forEach(entry => {
      const listItem = document.createElement("li");
      listItem.textContent = `Address: ${entry.userAddress}, Timestamp: ${entry.timestamp}`;
      waitlistList.appendChild(listItem);
    });
  } catch (error) {
    console.error("Error fetching waitlist:", error);
  }
};
document.getElementById("cancelTicket").onclick = async () => {
	if (!contract || !userAddress) {
	  alert("Connect your wallet first!");
	  return;
	}
  
	try {
	  await contract.methods.releaseSlot(userAddress).send({ from: userAddress });
	  document.getElementById("cancelTicketStatus").innerText = "Ticket successfully canceled!";
	} catch (error) {
	  document.getElementById("cancelTicketStatus").innerText = `Error; ${error.message}`;
	  console.error("Error executing cancel ticket:", error);
	}
  };

