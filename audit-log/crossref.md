# Cross-reference vs prior audits (boba_legacy/boba_audits — ALL OUT OF SCOPE)

LightBridge = Teleportation.sol. Prior reports already cover the obvious classes:
- Quantstamp #1: hardcoded `call{gas:3000}` for native disbursement (smart-wallet recipients fail). -> OOS (disclosed).
- Quantstamp #2/#3 BOBA-1: failed disbursements can't be retried across chains with current id tracking. -> OOS (disclosed) + Remedy carve-out for failed-disbursement bookkeeping.
- Quantstamp #2/#3: "A DOS Attack Can Prevent Teleports" — global daily cap can be filled by one actor (griefing). -> OOS (disclosed).
- Zokyo Aug 2023: fee-on-transfer tokens over-credited by `_amount`. -> OOS (disclosed); also no FoT token whitelisted anywhere live.

## Live whitelist (read-only, Oct 19 2026)
- ETH proxy: native->288 (0.01-2, 6/day), BOBA 0x42bb…Efbc ->288.
- Boba proxy 0x0dfF…7FF5: native->1,10,42161; L2 BOBA 0xa18b…20d7 ->1,56,56288 (56288 removed then re-added).
- OP & Arb proxies: native->288 supported. Balances: OP ~24.9 ETH, Arb ~41.4 ETH, Boba ~2.13 ETH, ETH 0.18 ETH + 704k BOBA.
- All whitelisted assets are plain 18-dec ETH/BOBA -> no decimals mismatch, no FoT/rebase/777 hooks.
- Implementations are initialized (owner/disburser = deployer 0x351f…aFDa), so no uninitialized-impl takeover; impl holds 0 funds; multicall only delegatecalls self.

## Remaining surface by family (20-family sweep)
oracle: none | 4626: none | reentrancy: gas-starved/role-gated | access-control/init: initialized, roles correct | signatures: none | rounding: none (1:1) | token integration: whitelist clean | DoS: cap-griefing disclosed | cross-chain: trust = disburser key (centralization OOS); sequential ids prevent replay | accounting desync: failed-disbursement map (carved out) | boundary: daily-window reset correct | incomplete paths: none found.
