
# WalletBalanceWatcher & SendEmergencyAlert  
**Wallet Balance Watcher — Drosera Trap SERGEANT**

# Objective

Create a functional and deployable Drosera trap that:

- Monitors ETH balance anomalies of a specific wallet,

- Uses the standard collect() / shouldRespond() interface,

- Triggers a response when balance deviation exceeds a given threshold (1%),

- Integrates with a separate alert contract to handle responses.

---

# Problem

Ethereum wallets involved in DAO treasury, DeFi protocol management, or vesting operations must maintain a consistent balance. Any unexpected change — loss or gain — could indicate compromise, human error, or exploit.

Solution: _Monitor ETH balance of a wallet across blocks. Trigger a response if there's a significant deviation in either direction._

---

# Trap Logic Summary

_Trap Contract: WalletBalanceWatcher.sol_

_Pay attention to this string "address public constant target = 0x006dFDD9F1645eAB33f46dCD69ff34640Aa05426; // change to your own wallet address"_

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}

contract WalletBalanceWatcher is ITrap {
    address public constant target = 0x006dFDD9F1645eAB33f46dCD69ff34640Aa05426; // change to your own wallet address
    uint256 public constant thresholdPercent = 1;

    function collect() external view override returns (bytes memory) {
        return abi.encode(target.balance);
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) return (false, "Insufficient data");

        uint256 current = abi.decode(data[0], (uint256));
        uint256 previous = abi.decode(data[1], (uint256));

        uint256 diff = current > previous ? current - previous : previous - current;
        uint256 percent = (diff * 100) / previous;

        if (percent >= thresholdPercent) {
            return (true, abi.encode("Balance anomaly detected"));
        }

        return (false, "");
    }
}
```

# Response Contract: SendEmergencyAlert.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SendEmergencyAlert {
    event EmergencyTriggered(string message);

    function handleAnomaly(string calldata message) external {
        emit EmergencyTriggered(message);
    }
}
```

---

# What It Solves

- Detects suspicious ETH flows from monitored addresses,

- Provides an automated alerting mechanism,

- Can integrate with automation logic (e.g., freezing funds, emergency DAO alerts).

---

# Deployment & Setup Instructions

1. ## _Deploy Contracts (e.g., via Foundry)_

```bash
forge create src/WalletBalanceWatcher.sol:WalletBalanceWatcher \
  --rpc-url https://ethereum-hoodi-rpc.publicnode.com \
  --private-key 0x...
```

```bash
forge create src/SendEmergencyAlert.sol:SendEmergencyAlert \
  --rpc-url https://ethereum-hoodi-rpc.publicnode.com \
  --private-key 0x...
```

2. ## _Update drosera.toml_

```toml
[traps.mytrap]
path = "out/WalletBalanceWatcher.sol/WalletBalanceWatcher.json"
response_contract = "<SendEmergencyAlert address>"
response_function = "handleAnomaly(string)"
```

3. ## _Apply changes_

```bash
DROSERA_PRIVATE_KEY=0x... drosera apply
```

---

# Testing the Trap

1. Send ETH to/from target address on Ethereum Hoodi testnet.

2. Wait 1-3 blocks.

3. Observe logs from Drosera operator:

4. get ShouldRespond='true' in logs and Drosera dashboard

---

# Extensions & Improvements

- Allow dynamic threshold setting via setter,

- Track ERC-20 balances in addition to native ETH,

- Chain multiple traps using a unified collector.

---

# Date & Author

_First created: July 29, 2025_

## Author: aiivanoff  
Discord: ironivanoff  
Telegram: [@aiivanoff](https://t.me/aiivanoff)
