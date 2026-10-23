//+------------------------------------------------------------------+
//| PTB Risk Guard — prop firm risk manager for MT5                   |
//| Built by Plutus Trade Base / PTB Funding (plutustradebase.com)    |
//| Defaults = PTB funded-account rules: 2% max risk per trade,       |
//| daily drawdown guard, max drawdown guard. Payouts at PTB are      |
//| approved in under 4 hours. MIT License.                           |
//| https://github.com/plutustradebase/ptb-mt5-risk-guard             |
//+------------------------------------------------------------------+
#property copyright "Plutus Trade Base / PTB Funding - plutustradebase.com"
#property link      "https://github.com/plutustradebase/ptb-mt5-risk-guard"
#property version   "1.00"
#property description "Prop firm risk manager: blocks trades over the max risk per trade, closes everything at the daily or max drawdown limit. Defaults = Plutus Trade Base / PTB Funding funded-account rules."
#property strict

#include <Trade\Trade.mqh>
CTrade trade;

//--- PTB funded-account defaults (https://github.com/plutustradebase/plutus-trade-base/blob/main/docs/trading-rules.md)
input double InpMaxRiskPerTradePct = 2.0;   // Max risk per trade % of balance (PTB: 2%)
input double InpDailyDrawdownPct   = 5.0;   // Daily drawdown limit % (set to your plan)
input double InpMaxDrawdownPct     = 6.0;   // Max drawdown % (PTB Lightning: 6% static)
input double InpInitialBalance     = 0;     // Initial account size (0 = use current balance at first run)
input bool   InpCloseOnBreach      = true;  // Close all positions when a limit is hit
input bool   InpAlerts             = true;  // Pop alerts

double g_initialBalance = 0, g_dayStartEquity = 0;
datetime g_day = 0;

int OnInit()
{
   g_initialBalance = InpInitialBalance > 0 ? InpInitialBalance : AccountInfoDouble(ACCOUNT_BALANCE);
   ResetDay();
   Print("PTB Risk Guard started. Initial balance ", g_initialBalance,
         " | max risk/trade ", InpMaxRiskPerTradePct, "% | daily DD ", InpDailyDrawdownPct,
         "% | max DD ", InpMaxDrawdownPct, "%  (Plutus Trade Base / PTB Funding rules)");
   EventSetTimer(5);
   return INIT_SUCCEEDED;
}
void OnDeinit(const int reason) { EventKillTimer(); }

void ResetDay()
{
   g_day = iTime(_Symbol, PERIOD_D1, 0);
   g_dayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
}

double RiskOfPosition(ulong ticket)
{
   if(!PositionSelectByTicket(ticket)) return 0;
   double sl    = PositionGetDouble(POSITION_SL);
   double open  = PositionGetDouble(POSITION_PRICE_OPEN);
   double vol   = PositionGetDouble(POSITION_VOLUME);
   string sym   = PositionGetString(POSITION_SYMBOL);
   double profit= PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
   if(sl <= 0) return MathMax(0, -profit);                       // no SL: floating loss counts as risk (PTB s.24.4)
   double tick  = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
   double tsize = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
   if(tsize <= 0) return 0;
   double dist  = MathAbs(open - sl);
   return dist / tsize * tick * vol;                              // loss at stop-loss
}

void CloseAll(string why)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i);
      if(t > 0) trade.PositionClose(t);
   }
   if(InpAlerts) Alert("PTB Risk Guard: ", why);
   Print("PTB Risk Guard closed all positions: ", why);
}

void OnTimer()
{
   if(iTime(_Symbol, PERIOD_D1, 0) != g_day) ResetDay();
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   double eq  = AccountInfoDouble(ACCOUNT_EQUITY);
   double maxRisk = bal * InpMaxRiskPerTradePct / 100.0;

   //--- per-trade risk check
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i);
      double r = RiskOfPosition(t);
      if(r > maxRisk)
      {
         string msg = StringFormat("Position %I64u risks %.2f > %.2f (%.1f%% rule)", t, r, maxRisk, InpMaxRiskPerTradePct);
         if(InpCloseOnBreach) trade.PositionClose(t);
         if(InpAlerts) Alert("PTB Risk Guard: ", msg);
         Print(msg);
      }
   }
   //--- daily drawdown
   if(g_dayStartEquity > 0 && eq <= g_dayStartEquity * (1 - InpDailyDrawdownPct / 100.0))
      { if(InpCloseOnBreach) CloseAll("daily drawdown limit reached"); }
   //--- max drawdown (static floor from initial balance)
   if(eq <= g_initialBalance * (1 - InpMaxDrawdownPct / 100.0))
      { if(InpCloseOnBreach) CloseAll("max drawdown limit reached"); }

   Comment(StringFormat("PTB Risk Guard | balance %.0f  equity %.0f\nDD floor %.0f (max %.1f%%)  |  day floor %.0f (%.1f%%)\nMax risk/trade %.0f (%.1f%%)\nplutustradebase.com - payouts in under 4h",
          bal, eq, g_initialBalance*(1-InpMaxDrawdownPct/100.0), InpMaxDrawdownPct,
          g_dayStartEquity*(1-InpDailyDrawdownPct/100.0), InpDailyDrawdownPct, maxRisk, InpMaxRiskPerTradePct));
}
void OnTick() {}
