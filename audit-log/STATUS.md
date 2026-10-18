# STATUS — Boba LightBridge audit (hunt mode)

As of 2026-10-19. NO Critical/High found so far. On-chain external attack surface = teleportAsset only; it records 1:1 faithful deposits for standard tokens → no value asymmetry.

Done:
- Scope read (Remedy): only Proxy__LightBridge proxies in scope; PoC required all severities; local-devnet only.
- Pulled deployed impl (0x3f7Da9…6b9 on ETH; identical source on Boba 0x670b…c3ee). Compiler 0.8.9. = renamed legacy Teleportation.sol.
- Read off-chain disburser service (boba_legacy teleportation/src/service.ts) for trust model.
- Live state (ETH): disburser 0x2d02…5CcE, owner 0x5612…9bC4, unpaused. Whitelist: native→288 (cap 6/day), BOBA→288 (cap 1e6/day). Holds 704k BOBA, 0.18 ETH.
- Fork harness built; baseline deposit PASS; multicall-reuse KILL confirmed at runtime.
- Primitives ledger + guard audit + kills recorded.

Open / next:
- Per-chain whitelists DONE: only native ETH and BOBA everywhere; no exotic tokens.
- 20-family crossref + prior-audit overlap DONE (crossref.md): every reachable class is either disclosed (OOS) or carved out.
- If whitelist is clean everywhere → honest empty report (same posture as Tokemak).

## Verdict of pass 1 (contract layer)
No payable on-chain bug in LightBridge. Contract is ~500 lines, trusted-relayer design, heavily audited (QS x2, Zokyo, PeckShield) and every class we can reach is already disclosed.
Where a win could still live (pass 2 ideas):
1. Off-chain disburser service (Crit/High impacts on Boba assets are accepted): event parsing, reorg handling (service disburses at latestBlock with NO confirmation depth -> source-chain reorg after disbursement = double-spend? needs reorg on L2s/ETH; check current service, not legacy).
2. In-scope websites: gateway.boba.network (web paid tier, Crit up to $3k), RPC endpoints.
3. Watch for impl upgrades (future impls are in scope) — diff each new impl on deploy.

## Pass 2 (Oct 19 2026)
- Relayer reorg lead PARKED: no confirmation depth in public code, but needs an attacker-uncontrollable reorg and the live backend is private. See killed.md H-REORG.
- Contract + relayer layers exhausted without a payable finding. Remaining options: gateway.boba.network web tier (max $3k crit), or monitor for LightBridge impl upgrades (future impls in scope).
