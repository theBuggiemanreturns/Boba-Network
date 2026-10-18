# AGENT HANDOFF — read me first

You are auditing Boba Network's LightBridge for the Remedy bounty (hunt mode, v2 pipeline).
1. Read audit-log/scope.md (what pays, what's OOS, PoC rules — LOCAL FORK ONLY).
2. Read STATUS.md (where we are), primitives.md (the ledger), killed.md (dead ends — don't re-walk them).
3. Target = Proxy__LightBridge = renamed Teleportation.sol. Source in ../src (pull fresh from explorer to be safe).
4. Trust model: off-chain disburser (KMS key) reads AssetReceived and calls disburseAsset on dest. On-chain enforces strict sequential depositId (idempotent vs replay). External attacker only touches teleportAsset.
5. Non-negotiables: witness every hypothesis, prove on a fork, record the kill, class must be one the program pays. Never push a CONFIRMED finding while this repo is public.
6. Next actions are in STATUS.md "Open / next".
