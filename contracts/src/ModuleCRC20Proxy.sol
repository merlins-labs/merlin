pragma solidity ^0.6.8;

import "ds-math/math.sol";
import "./ModuleCRC20.sol";

contract ModuleCRC20Proxy is DSMath {
    // sha256('merlin-evm')[:20]
    address constant module_address = 0x89A7EF2F08B1c018D5Cc88836249b84Dd5392905;
    ModuleCRC20 crc20Contract;
    bool isSource;

    event __MerlinSendToEvmChain(address indexed sender, address indexed recipient, uint256 indexed chain_id, uint256 amount, uint256 bridge_fee, bytes extraData);
    event __MerlinCancelSendToEvmChain(address indexed sender, uint256 id);

    /**
        Instantiate a ModuleCRC20Proxy contract. Need to set manually the crc20 contract authority to be the proxy
        like the following call:
        crc20Contract.setAuthority(DSAuthority(address(new ModuleCRC20ProxyAuthority(address(this)))));
    **/
    constructor(address crc20Contract_, bool isSource_) public {
        crc20Contract = ModuleCRC20(crc20Contract_);
        isSource = isSource_;
    }

    /**
        views
    **/
    function crc20() public view returns (address) {
        return address(crc20Contract);
    }

    function is_source() public view returns (bool) {
        return isSource;
    }


    /**
        Internal functions to be called by merlin module.
    **/
    function mint_by_merlin_module(address addr, uint amount) public {
        require(msg.sender == module_address);
        crc20Contract.mint(addr, amount);
    }

    function burn_by_merlin_module(address addr, uint amount) public {
        require(msg.sender == module_address);
        crc20_burn(addr, amount);
    }

    function transfer_by_merlin_module(address addr, uint amount) public {
        require(msg.sender == module_address);
        crc20Contract.move(addr, module_address, amount);
    }

    function transfer_from_merlin_module(address addr, uint amount) public {
        require(msg.sender == module_address);
        crc20Contract.move(module_address, addr, amount);
    }


    /**
        Evm hooks functions
    **/

    // send to another chain through gravity bridge, require approval for the burn.
    function send_to_evm_chain(address recipient, uint amount, uint chain_id, uint bridge_fee, bytes calldata extraData) external {
        // transfer back the token to the proxy account
        if (isSource) {
            crc20Contract.move(msg.sender, module_address, amount);
        } else {
            crc20_burn(msg.sender, amount);
        }
        emit __MerlinSendToEvmChain(msg.sender, recipient, chain_id, amount, bridge_fee, extraData);
    }

    // cancel a send to chain transaction considering if it hasnt been batched yet.
    function cancel_send_to_evm_chain(uint256 id) external {
        emit __MerlinCancelSendToEvmChain(msg.sender, id);
    }

    /**
        Internal functions
    **/

    // burn the token on behalf of the user. requires approval
    function crc20_burn(address addr, uint amount) internal {
        crc20Contract.move(addr, address(this), amount);
        crc20Contract.burn(amount);
    }
}