# Scope — Boba Network (Remedy / hunt.r.xyz)

Program: https://r.xyz/bug-bounty/programs/boba-network  | Active, non-expiring | KYC required | Max $100k
Mode: hunt (bounty, depth-first, extract-only)
Authorization: public Remedy bounty. ALL testing on private testnet / local devnet ONLY. Mainnet + public testnet PROHIBITED. No testing against live oracles/third-party contracts.

## In-scope smart contracts (ONLY these)
Target = Proxy__LightBridge (LightBridge = renamed Teleportation.sol). Current implementation + any future impl updates are in scope.
- ETH mainnet:  0x2dE73Bd1660Fbf4D521a52Ec2a91CCc106113801  (etherscan)
- Boba:         0x0dfFd3Efe9c3237Ad7bf94252296272c96237FF5  (bobascan)
- Boba:         0x670b130112C6f03E17192e63c67866e67D77c3ee  (bobascan)
- Optimism:     0x2dE73Bd1660Fbf4D521a52Ec2a91CCc106113801
- Arbitrum:     0x2dE73Bd1660Fbf4D521a52Ec2a91CCc106113801
NOTE: L1 Bridge REMOVED from scope 10 May 2026. General OP Stack / BOBA token / L2 governance NOT in scope.
Impacts on other Boba-managed assets accepted ONLY for Critical/High if impact is in Impacts-in-Scope.

## Websites in scope
mainnet.boba.network (RPC), gateway.boba.network, wss ws.mainnet.boba.network, wss wss.bnb.boba.network

## Rewards (USD, paid directly; USDC possible)
Smart contracts: Critical $10k–100k (=10% of funds affected, min $10k) | High up to $8k | Medium up to $3k | Low up to $1k | Info NOT eligible
Websites/apps:   Critical up to $3k | High up to $2k | Medium up to $1.5k | Low up to $1k | Info NOT eligible

## PoC
Runnable PoC REQUIRED at EVERY paid severity. Submit via Remedy platform.

## Critical impacts in scope (SC)
Direct theft of user funds (at-rest/in-motion), permanent freezing of funds, protocol insolvency, governance manipulation, NFT theft/mint.
## High: temporary freezing of funds (any duration), theft of unclaimed yield.

## Out of scope (key)
- Contracts are upgradable (not a bug). Fraud proofs not running. Lib_MerkleTrie withdrawal bug (workaround). Lib_ResolvedDelegateProxy collision (Boba not affected). OVM_GasPriceOracle owner-set L1 gas. Fake-ERC20 L2 withdraw blocked by L1StandardBridge (bypass IS rewarded).
- All vulns in bobanetwork/boba_legacy/tree/develop/boba_audits (previously disclosed).
- Oracle data correctness (does NOT exclude oracle manipulation / flash-loan). 51% / governance econ, liquidity, sybil, centralization, best-practice.
- Failed-disbursement bookkeeping collisions impacting only privileged retry/recovery flows w/o fund access/loss.

## Testing env
Boba-Eth migrated to Anchorage (v3), differs from Boba-BNB (v2). Cross-domain: Boba-Eth local devnet stack; Boba-BNB dockerized services + modified integration tests.

## Target source
LightBridge == Teleportation.sol (legacy: bobanetwork/boba_legacy packages/boba/contracts/contracts/Teleportation.sol, 500 lines). Must pull the ACTUAL deployed impl source from explorers to audit current in-scope bytecode.
