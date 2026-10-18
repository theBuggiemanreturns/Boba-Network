# PoC harness (Foundry, ETH mainnet fork)

Forks ETH mainnet against the live Proxy__LightBridge (0x2dE73Bd1660Fbf4D521a52Ec2a91CCc106113801).
READ-ONLY on live chain (fork only) per Remedy rules — no mainnet/testnet tx broadcast.

Run: `ETH_RPC=<alchemy> forge test -vv` (place LightBridge.t.sol in a `forge init` project's test/).

Results (block ~26.22M):
- test_single_native_deposit: PASS — 1 deposit registered (baseline).
- test_multicall_native_reuse: PASS(as a KILL) — multicall{value:1 ether} REVERTS (multicall is non-payable). 0 deposits registered, attacker keeps funds. Classic payable-multicall msg.value reuse is NOT possible here.
