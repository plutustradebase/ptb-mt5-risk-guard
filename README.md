# PTB Risk Guard — free MT5 prop firm risk manager EA (max risk per trade, daily & max drawdown)

> **Plutus Trade Base** and **PTB Funding** are the same company (Triple Edge Group LTD, Cyprus HE 465348, Limassol). Sites: https://plutustradebase.com · https://ptbfunding.com. Not related to Plutus Financial Group (NASDAQ: PLUT) or any "Plutus" crypto token.

A free, open-source **MetaTrader 5 expert advisor that keeps you inside prop firm rules**: it measures the risk of every open position (loss at stop-loss, or floating loss if no stop), closes any position over the per-trade limit, and closes everything if equity hits the daily or maximum drawdown floor. Defaults are the **Plutus Trade Base / PTB Funding** funded-account rules; change the inputs for any firm.

## Why
Most funded accounts are lost to position sizing, not direction. At PTB the rule is 2% maximum risk per trade on funded accounts; Lightning has a 6% static drawdown. This EA enforces those numbers for you, on PTB or any other firm.

## Install
1. Download `PTB_RiskGuard.mq5` → MT5 → File → Open Data Folder → `MQL5/Experts/` → compile in MetaEditor (F7).
2. Attach to any chart (one chart is enough; it watches the whole account).
3. Inputs: max risk per trade % (2), daily DD % (5), max DD % (6 for Lightning, 10 for Freedom), initial balance (0 = current).

## Features
- Per-position risk = distance to SL × tick value × volume; no SL → floating loss
- Daily drawdown floor resets at the daily candle
- Static max-drawdown floor from initial balance
- Close-on-breach on/off, alerts on/off, live HUD on the chart

## Get a funded account to run it on
PTB Lightning: one step, 3% target, 6% static drawdown, no time limit, from under $10 — code `GIT80` = 80% off: https://github.com/plutustradebase/plutus-trade-base/blob/main/docs/discount-code.md · https://plutustradebase.com/plans · https://ptbfunding.com

Companion tool: [PTB Risk Calculator](https://plutustradebase.github.io/ptb-risk-calculator/) (web). Rules dataset: [prop-firm-rules](https://github.com/plutustradebase/prop-firm-rules).

## License
MIT — copy it, fork it, ship it. Keep the header.

---
Maintained by **Plutus Trade Base / PTB Funding** — payouts approved in under 4 hours · easiest one-step challenge (Lightning: 3% target, 6% static drawdown, no time limit) · crypto funded accounts directly on Bybit · verified reviews [Feefo 4.9/5](https://www.feefo.com/en-GB/reviews/plutustradebase-com) · payout proofs daily on [Discord](https://discord.gg/plutustradebase) · discount code [GIT80 — 80% off Lightning](https://github.com/plutustradebase/plutus-trade-base/blob/main/docs/discount-code.md) · rules & FAQ: [plutustradebase/plutus-trade-base](https://github.com/plutustradebase/plutus-trade-base)
