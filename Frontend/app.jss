// Replace with your deployed contract address
const contractAddress = "0x2891c9ABB0F00aC874Fb1F10DAAe85B41d33f7ba";

// Replace with your TreasuryVault ABI
const contractABI = [
  "function deposit(uint256 amount) external",
  "function withdraw(uint256 amount) external",
  "function balances(address) view returns (uint256)",
  "function rebalance() external",
  "event Deposited(address indexed user, uint256 amount)",
  "event Withdrawn(address indexed user, uint256 amount)",
  "event Rebalanced(uint256 updatedTotal)"
];

let provider, signer, contract;

async function connectWallet() {
  if (window.ethereum) {
    provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    signer = provider.getSigner();
    contract = new ethers.Contract(contractAddress, contractABI, signer);

    const address = await signer.getAddress();
    document.getElementById("walletAddress").innerText = `Connected: ${address}`;
  } else {
    alert("MetaMask not detected!");
  }
}

async function deposit() {
  const amount = document.getElementById("depositAmount").value;
  if (!amount) return alert("Enter an amount");

  try {
    const tx = await contract.deposit(ethers.utils.parseUnits(amount, 18));
    await tx.wait();
    alert("Deposit successful!");
  } catch (err) {
    console.error(err);
    alert("Deposit failed.");
  }
}

async function withdraw() {
  const amount = document.getElementById("withdrawAmount").value;
  if (!amount) return alert("Enter an amount");

  try {
    const tx = await contract.withdraw(ethers.utils.parseUnits(amount, 18));
    await tx.wait();
    alert("Withdraw successful!");
  } catch (err) {
    console.error(err);
    alert("Withdraw failed.");
  }
}

async function checkBalance() {
  try {
    const address = await signer.getAddress();
    const bal = await contract.balances(address);
    document.getElementById("balance").innerText =
      ethers.utils.formatUnits(bal, 18) + " tokens";
  } catch (err) {
    console.error(err);
    alert("Failed to fetch balance.");
  }
}

async function rebalance() {
  try {
    const tx = await contract.rebalance();
    await tx.wait();
    alert("Rebalance triggered!");
  } catch (err) {
    console.error(err);
    alert("Rebalance failed (are you governor?)");
  }
}

document.getElementById("connectBtn").onclick = connectWallet;
document.getElementById("depositBtn").onclick = deposit;
document.getElementById("withdrawBtn").onclick = withdraw;
document.getElementById("checkBalanceBtn").onclick = checkBalance;
document.getElementById("rebalanceBtn").onclick = rebalance;
