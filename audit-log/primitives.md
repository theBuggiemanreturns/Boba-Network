# Primitives ledger — LightBridge (Teleportation renamed)

Source: deployed impl 0x3f7Da9C51138E0475aA26E80677d27A568cFD6b9 (ETH), identical bytecode-source on Boba 0x670b…c3ee (only trailing newline differs). Compiler 0.8.9, optimizer on. Impl verified.
Architecture: Lib_ResolvedDelegateProxy -> addressManager['proxyTarget']. Lock-and-emit bridge; off-chain disburser service mints on dest via disburseAsset. NO on-chain proof of source deposit — trust = disburser key.

## Roles / live state (ETH mainnet, read-only fork)
- disburser 0x2d02ce7eF2f359bdcF86E44f66345660725e5CcE
- owner     0x56121a8612474C3eB65D69a3b871f284705b9bC4
- paused    false
- supportedTokens[native][288]: supported, min 0.01, max 2, dailyCap 6 ETH

## Permissionless entry points
- P1 teleportAsset(token, amount, toChainId) payable whenNotPaused — only user-facing deposit.
- P2 multicall(bytes[]) — delegatecall to self, batches any external fns (inherited OZ MulticallUpgradeable v<=4.2, NO payable guard on multicall).

## Disburser-gated
- P3 disburseAsset(Disbursement[]) payable onlyDisburser whenNotPaused — releases funds on dest.
- P4 retryDisburseNative(uint256[]) payable onlyDisburser whenNotPaused.

## Owner-gated
- addSupportedToken/removeSupportedToken/setMin/setMax/setMaxTransferPerDay/pause/unpause/withdrawBalance/transferDisburser/transferOwnership.

## Primitives (sub-critical observations; chain fuel)
- A. teleportAsset daily-limit accounting operates on a MEMORY copy `supToken` then writes back the whole struct. The 24h-window branch: if within window, transferredAmount += amount & checked; else reset to amount, checkpoint=now. The checkpoint reset path does NOT re-add prior transferred => standard. [source-verified]
- B. disburseAsset: native branch uses `.call{gas:3000, value:_amount}` — fixed 3000 gas. If recipient is a contract whose receive costs >3000, call fails -> recorded in failedNativeDisbursements[_depositId] (keyed by depositId only, NOT by sourceChainId). [source-verified] -> PRIMITIVE: depositId collision across source chains.
- C. failedNativeDisbursements mapping keyed by `_depositId` alone. teleportAsset depositId sequence is per (toChainId) via totalDeposits[toChainId]; disburse expects per-sourceChainId via totalDisbursements[sourceChainId]. Two different source chains can produce the SAME depositId. A failed native disbursement from chain X at depositId N is overwritten by a failed one from chain Y at depositId N. [source-verified] NOTE: Remedy OOS explicitly excludes "Failed-disbursement bookkeeping collisions ... that only impact privileged retry or manual recovery flows, without enabling unauthorized fund access or permanent loss of funds." -> this exact primitive is OOS unless it enables fund access/loss.
- D. disburseAsset ERC20 branch: `safeTransferFrom(msg.sender, address(this), _amount)` then `safeTransfer(_addr, _amount)` — disburser must hold/approve tokens; net-zero to contract. For native, funds come from msg.value / contract balance.
- E. disburseAsset native: `require(_amount <= remainingValue)` and decrements remainingValue. remainingValue starts at msg.value. Leftover msg.value (if sum < msg.value) stays in contract (no refund). [source-verified]
- F. No reentrancy guard anywhere. teleportAsset does external token transfer AFTER state writes (CEI ok). disburse native uses 3000 gas (reentrancy-starved). ERC20 safeTransfer to _addr could reenter but all state already updated per-iteration; totalDisbursements incremented before transfer. [source-verified]
- G. teleportAsset supports arbitrary whitelisted ERC20. Fee-on-transfer / rebasing token: contract records `_amount` but may receive less. Off-chain service likely credits `_amount` on dest -> over-credit. But token must be owner-whitelisted (addSupportedToken). [primitive]
- H. multicall is non-payable but calls _functionDelegateCall with msg.value forwarded implicitly? OZ multicall delegatecalls self; msg.value is shared across all subcalls (classic double-spend-msg.value bug in payable-multicall). HERE multicall itself is NOT payable (no `payable`), so msg.value must be 0 when calling multicall -> teleportAsset native inside multicall would require _amount==0. Low risk but verify. [to-verify]
- I. depositId emitted in AssetReceived = totalDeposits[toChainId]-1, monotonic per destination. disburseAsset requires depositId == totalDisbursements[sourceChainId] strictly sequential -> a skipped/failed deposit cannot be processed out of order (DoS vector if one id is unprocessable? No — disburser constructs the list). [primitive]

## Seams to chain (composition targets)
- S1 (C+B): depositId collision -> can a user cause a failed native disbursement whose record is later overwritten such that funds get double-released or stuck? Guard-audit the retry path. (watch OOS carve-out)
- S2 (G): fee-on-transfer/rebase whitelisted token -> deposit records more than received; mirror-side over-credit. Needs: does any supported token have transfer fee? (owner-controlled whitelist)
- S3 (A): daily transfer cap bypass via the memory-struct write-back ordering or the else-branch reset. Re-derive.
- S4 (H): payable multicall msg.value reuse — confirm non-payable blocks it.
