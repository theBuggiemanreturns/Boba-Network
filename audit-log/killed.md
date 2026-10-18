# Killed hypotheses — LightBridge

- H-S4 payable-multicall msg.value reuse (native double-count). KILLED (RUNTIME, fork @26.22M).
  multicall(bytes[]) in OZ MulticallUpgradeable is NOT payable. Calling it with value reverts; inside a 0-value multicall, teleportAsset native requires _amount==msg.value==0 which fails minDeposit. ERC20 path pulls real tokens per subcall (safeTransferFrom msg.sender) → no free mint. poc/LightBridge.t.sol::test_multicall_native_reuse.

- H-S2 fee-on-transfer / rebasing token over-credit. KILLED (config). On ETH only native(→288) and BOBA(→288) are whitelisted. BOBA is a plain OZ ERC20Votes (no transfer fee, no rebase). No FoT token in the live whitelist on ETH. (Re-check per-chain whitelists on Boba/Arb/Op before final.)

- H-C failedNativeDisbursements depositId collision across source chains. OUT OF SCOPE per Remedy: "Failed-disbursement bookkeeping collisions or overwrites that only impact privileged retry or manual recovery flows, without enabling unauthorized fund access or permanent loss of funds." Overwrite only breaks owner/disburser manual retry; owner withdrawBalance can still recover. No unauthorized access, no permanent loss → excluded. Documented, not submitted.

- Reentrancy (disburseAsset / retryDisburseNative). KILLED (source). Native call capped at gas:3000 (reentrancy-starved). ERC20 safeTransfer could reenter but onlyDisburser gates all paths; per-iteration state (totalDisbursements) updated before transfer. No external-attacker reentrancy.

- Daily-cap bypass via memory struct. KILLED (source). supToken memory copy written back wholesale; transferredAmount monotonic within a fixed 24h window; attacker cannot advance block.timestamp. No bypass.

- Sequential-queue DoS (undisbursable deposit bricks source queue). Owner-config dependent (needs asymmetric whitelist); not attacker-triggerable under symmetric config. Centralization/config → not a payable bug.

- H-REORG relayer disburses with no confirmation depth (pass 2, Oct 19 2026). PARKED / NOT SUBMITTABLE.
  Evidence: legacy service (boba_legacy teleportation/src/service.ts) and the public fork tovanpanet/light-bridge (Nov 2023) both read events up to provider.getBlockNumber() (latest) with no confirmation buffer; current service (per Wavect case study) polls a subgraph every 60s, batch<=10, KMS-signed. Current backend repo bobanetwork/light-bridge is now PRIVATE/404 -> live code unverifiable.
  Why not a bounty: exploit needs a source-chain reorg that removes the deposit AFTER disbursement. Attacker cannot cause one: ETH post-merge >1-block reorgs need proposer collusion; OP/Arb/Boba unsafe-head reorgs need sequencer fault. That is consensus/51%-class (OOS "basic economic governance attacks"), and a devnet PoC would only show an artificial reorg against old code, not the deployed system. Worth a hardening note to Boba at most (Info = unpaid).
