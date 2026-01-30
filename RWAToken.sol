// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IIdentityRegistry {
    function isVerified(address _user) external view returns (bool);
}

contract RWAToken is ERC20, Ownable {
    IIdentityRegistry public identityRegistry;
    bool public complianceEnabled = true;

    event IdentityRegistryUpdated(address indexed newRegistry);

    constructor(
        string memory name,
        string memory symbol,
        address _identityRegistry
    ) ERC20(name, symbol) Ownable(msg.sender) {
        identityRegistry = IIdentityRegistry(_identityRegistry);
    }

    function setIdentityRegistry(address _newRegistry) external onlyOwner {
        identityRegistry = IIdentityRegistry(_newRegistry);
        emit IdentityRegistryUpdated(_newRegistry);
    }

    function toggleCompliance(bool _status) external onlyOwner {
        complianceEnabled = _status;
    }

    /**
     * @dev Hook that is called before any transfer of tokens.
     * Checks if both sender and receiver are verified in the Identity Registry.
     */
    function _update(address from, address to, uint256 value) internal virtual override {
        if (complianceEnabled && from != address(0) && to != address(0)) {
            require(identityRegistry.isVerified(from), "Sender not KYC verified");
            require(identityRegistry.isVerified(to), "Receiver not KYC verified");
        }
        super._update(from, to, value);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        require(identityRegistry.isVerified(to), "Recipient not KYC verified");
        _mint(to, amount);
    }
}
