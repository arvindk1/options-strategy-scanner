#!/usr/bin/env bash
set -e

# Create the strategies folder
mkdir -p strategies

# 1. Butterfly Spread
cat > strategies/butterfly_spread.json << 'EOF'
{
  "strategy_id": "butterfly_spread",
  "module": "strategies.butterfly_plugin",
  "strategy_name": "Butterfly Spread",
  "strategy_type": "BUTTERFLY",
  "description": "Long 1 ITM, short 2 ATM, long 1 OTM (or vice versa) - profit from low volatility and precise price targeting",
  "universe": {
    "symbol_types": ["STOCK", "ETF"],
    "min_market_cap": 10000000000,
    "min_avg_volume": 5000000,
    "min_avg_option_volume": 1500,
    "low_volatility_preferred": true,
    "stable_underlyings": true,
    "include_symbols": [],
    "exclude_symbols": []
  },
  "position_parameters": {
    "max_net_debit_dollars": 0.02,
    "max_opportunities": 3,
    "max_position_cost": 1000
  },
  "entry_signals": {
    "allowed_bias": ["NEUTRAL"],
    "volatility_max": 0.30,
    "implied_volatility_rank_max": 60,
    "price_consolidation_required": true
  },
  "strike_selection": {
    "wing_structure": "SYMMETRIC",
    "strike_spacing_rules": [
      { "price_lt": 50,  "spacing": 2.5 },
      { "price_lt": 200, "spacing": 5   },
      { "default": 10 }
    ],
    "center_strike": "ATM",
    "max_wing_width": 15,
    "min_wing_width": 5
  },
  "timing": {
    "dte_range": [14, 45],
    "optimal_dte": [21, 35],
    "avoid_earnings": true,
    "avoid_high_volatility_events": true
  },
  "exit_rules": {
    "profit_targets": [
      { "level": 0.75, "action": "CLOSE_CENTER", "priority": 90, "description": "Close center shorts at 75% profit" },
      { "level": 0.50, "action": "CLOSE_ALL",    "priority": 85, "description": "Close entire butterfly at 50% profit" }
    ],
    "stop_loss_rules": [
      { "type": "PERCENTAGE", "trigger": -0.25, "action": "CLOSE_ALL", "priority": 100, "description": "Close at 25% of max loss" }
    ],
    "time_exits": [
      { "condition": "dte_less_than", "value": 7, "action": "CLOSE_ALL", "priority": 80, "description": "Close 7 days before expiration" }
    ],
    "volatility_exits": [
      { "condition": "iv_spike", "threshold": 1.5, "action": "CLOSE_ALL", "priority": 95, "description": "Close if IV spikes 50%" }
    ]
  },
  "scoring": {
    "profit_zone_weight": 0.5,
    "cost_weight": 0.5,
    "volatility_stability_bonus": 0.3,
    "liquidity_weight": 0.2,
    "price_positioning_multiplier": {
      "center_zone": 1.5,
      "wing_zone": 1.0,
      "outside_wings": 0.3
    },
    "score_floor": 1.0,
    "score_ceiling": 10.0,
    "round_decimals": 1
  },
  "risk_management": {
    "max_allocation_percentage": 8,
    "max_single_butterfly_cost": 1000,
    "concentration_limit": 2,
    "volatility_risk_threshold": 0.35
  },
  "profit_zone_analysis": {
    "optimal_zone_width": 0.05,
    "current_price_proximity_bonus": true,
    "time_decay_acceleration_zone": 0.03
  },
  "educational_content": {
    "best_for": "Precise price targeting with limited risk and defined profit zone",
    "when_to_use": "Neutral outlook with expectation of low volatility and range-bound movement",
    "profit_mechanism": "Maximum profit when underlying closes exactly at center strike",
    "risk_level": "LOW-MEDIUM",
    "typical_duration": "21–35 days",
    "max_profit": "Center strike minus wing strike minus net debit",
    "max_loss": "Net debit paid (limited risk)",
    "profit_zone": "Between wing strikes with peak at center strike"
  },
  "ui_metadata": {
    "position_parameters.max_net_debit_dollars": {
      "editable": true, 
      "tooltip": "Max premium you'll pay per butterfly",
      "type": "number",
      "min": 0.01,
      "max": 0.10,
      "step": 0.01
    },
    "position_parameters.max_opportunities": {
      "editable": true, 
      "tooltip": "Max number of simultaneous butterflies",
      "type": "number",
      "min": 1,
      "max": 10
    },
    "strike_selection.wing_structure": {
      "editable": false, 
      "tooltip": "Butterfly wing symmetry - always symmetric for basic butterfly"
    },
    "timing.dte_range": {
      "editable": true, 
      "tooltip": "Allowed expiration window",
      "type": "range",
      "min": 7,
      "max": 90
    },
    "exit_rules.profit_targets": {
      "editable": false, 
      "tooltip": "Auto-close center or full butterfly at profit targets"
    },
    "exit_rules.volatility_exits": {
      "editable": false, 
      "tooltip": "Auto-close on IV spike to protect against volatility expansion"
    },
    "profit_zone_analysis.optimal_zone_width": {
      "editable": true,
      "tooltip": "Target profit zone width as percentage of underlying price",
      "type": "number",
      "min": 0.02,
      "max": 0.15,
      "step": 0.01
    }
  },
  "tags": {
    "risk_level": "LOW-MEDIUM",
    "profit_potential": "MODERATE",
    "ideal_dte": [21, 35],
    "market_outlook": "NEUTRAL",
    "volatility_preference": "LOW",
    "complexity": "INTERMEDIATE"
  }
}
EOF

# 2. Calendar Spread
cat > strategies/calendar_spread.json << 'EOF'
{
  "strategy_id": "calendar_spread",
  "module": "strategies.calendar_spread_plugin",
  "strategy_name": "Calendar Spread",
  "strategy_type": "CALENDAR_SPREAD",
  "description": "Sell short-dated option, buy longer-dated at same strike - profit from time decay differential and volatility expansion",
  "universe": {
    "symbol_types": ["STOCK", "ETF"],
    "min_market_cap": 5000000000,
    "min_avg_volume": 2000000,
    "min_option_volume": 1000,
    "stable_underlyings_preferred": true,
    "multiple_expirations_required": true
  },
  "position_parameters": {
    "max_net_debit": 0.025,
    "max_opportunities": 3,
    "position_size_limit": 1200
  },
  "entry_signals": {
    "volatility_expectation": "RISE",
    "bias": ["NEUTRAL","SLIGHTLY_BEARISH","SLIGHTLY_BULLISH"],
    "implied_volatility_skew": "FAVORABLE",
    "time_decay_opportunity": true
  },
  "strike_selection": {
    "moneyness": "ATM",
    "max_strike_offset": 0.02,
    "prefer_highest_gamma": true,
    "avoid_dividend_dates": true
  },
  "timing": {
    "dte_short": [7,14],
    "dte_long": [30,60],
    "optimal_dte_ratio": 3.0,
    "avoid_earnings_in_short_leg": true
  },
  "exit_rules": {
    "profit_targets":[
      {"level":0.50,"action":"ROLL_SHORT","priority":90,"description":"Roll short leg when 50% profit achieved"},
      {"level":0.25,"action":"CLOSE_ALL","priority":85,"description":"Close at 25% total profit"}
    ],
    "stop_loss_rules":[
      {"type":"PERCENTAGE","trigger":-0.50,"action":"CLOSE_ALL","priority":100,"description":"Close at 50% loss"}
    ],
    "time_exits":[
      {"condition":"short_dte_less_than","value":2,"action":"CLOSE_SHORT","priority":95,"description":"Close short leg 2 days before expiration"}
    ],
    "volatility_exits":[
      {"condition":"iv_crush_short_leg","threshold":0.25,"action":"CLOSE_SHORT","priority":90,"description":"Close short leg if IV drops 25%"}
    ]
  },
  "scoring":{
    "time_decay_weight":0.6,
    "volatility_weight":0.4,
    "iv_skew_bonus":0.3,
    "strike_positioning_weight":0.2,
    "calendar_efficiency_multiplier":{"high":1.4,"medium":1.0,"low":0.6},
    "score_floor":1.0,
    "score_ceiling":10.0,
    "round_decimals":1
  },
  "risk_management":{
    "max_allocation_percentage":10,
    "max_single_calendar_cost":1200,
    "pin_risk_management":true,
    "early_assignment_protection":true
  },
  "educational_content":{
    "best_for":"Time decay arbitrage and volatility expansion plays",
    "when_to_use":"Neutral outlook with expectation of rising volatility in longer-term options",
    "profit_mechanism":"Short-term option decays faster than long-term option",
    "risk_level":"MEDIUM",
    "typical_duration":"Rolling strategy - continuous management",
    "max_profit":"Long option value minus short option value at short expiration",
    "max_loss":"Net debit paid plus potential assignment costs",
    "optimal_outcome":"Stock stays near strike through short expiration"
  }
}
EOF

# 3. Collar
cat > strategies/collar.json << 'EOF'
{
  "strategy_id": "collar",
  "module": "strategies.collar_plugin",
  "strategy_name": "Collar",
  "strategy_type": "COLLAR",
  "description": "Own stock, sell a call, buy a put - protective strategy with income generation",
  "universe": {
    "symbol_types":["STOCK"],
    "min_market_cap":2000000000,
    "min_avg_volume":1000000,
    "min_option_volume":500,
    "dividend_paying_preferred":true,
    "owned_stocks_only":true
  },
  "position_parameters":{
    "shares_per_contract":100,
    "max_cost_pct_equity":0.02,
    "min_protection_level":0.90,
    "income_target_pct":0.015
  },
  "entry_signals":{
    "bias":["NEUTRAL","SLIGHTLY_BULLISH"],
    "max_cost_pct_equity":0.02,
    "volatility_protection_needed":true,
    "existing_stock_position_required":true
  },
  "strike_selection":{
    "call_delta_max":0.30,
    "put_delta_target":0.30,
    "collar_width_limits":{"min_width":5,"max_width":25},
    "cost_optimization":"MINIMIZE_NET_COST"
  },
  "timing":{
    "dte_range":[7,60],
    "optimal_dte":[30,45],
    "earnings_consideration":"ALLOW",
    "dividend_timing":"OPTIMIZE_FOR_DIVIDENDS"
  },
  "exit_rules":{
    "profit_targets":[{"level":0.50,"action":"CLOSE_PUT","priority":90,"description":"Close put when 50% profit achieved"}],
    "stop_loss_rules":[{"type":"PERCENTAGE","trigger":-0.50,"action":"CLOSE_PUT","priority":100,"description":"Close put at 50% loss"}],
    "time_exits":[{"condition":"dte_less_than","value":3,"action":"CLOSE_ALL","priority":80,"description":"Close options 3 days before expiration"}],
    "assignment_management":[{"condition":"call_assignment_risk","action":"ROLL_CALL_UP","priority":85,"description":"Roll call up if assignment likely"},{"condition":"put_assignment_opportunity","action":"ACCEPT_ASSIGNMENT","priority":75,"description":"Accept put assignment to increase position"}]
  },
  "scoring":{
    "protection_cost_weight":0.7,
    "income_weight":0.3,
    "dividend_capture_bonus":0.2,
    "cost_efficiency_multiplier":{"zero_cost":2.0,"low_cost":1.5,"moderate_cost":1.0,"high_cost":0.5},
    "score_floor":1.0,
    "score_ceiling":10.0,
    "round_decimals":1
  },
  "risk_management":{"max_allocation_percentage":30,"max_collar_cost":500,"upside_cap_acceptance":0.15,"downside_protection_minimum":0.10},
  "educational_content":{
    "best_for":"Protecting long stock positions while generating income",
    "when_to_use":"Neutral to slightly bullish with downside protection needs",
    "profit_mechanism":"Collect call premium, pay for put protection, keep dividends",
    "risk_level":"LOW",
    "typical_duration":"30-45 days",
    "max_profit":"Call strike - stock cost + call premium - put premium + dividends",
    "max_loss":"Stock cost - put strike + put premium - call premium",
    "trade_offs":"Limited upside for downside protection and income"
  }
}
EOF

# 4. Covered Call
cat > strategies/covered_call.json << 'EOF'
{
  "strategy_id": "covered_call",
  "module": "strategies.covered_call_plugin",
  "strategy_name": "Covered Call",
  "strategy_type": "COVERED_CALL",
  "description": "Own 100 shares and sell 1 call against it for income generation with limited upside",
  "universe": {
    "symbol_types":["STOCK","ETF"],
    "min_market_cap":1000000000,
    "min_avg_volume":1000000,
    "min_option_volume":500,
    "dividend_paying_preferred":true,
    "exclude_high_volatility":true
  },
  "position_parameters":{
    "shares_per_contract":100,
    "max_position_pct_equity":0.10,
    "min_expected_return":0.02,
    "max_volatility":0.30
  },
  "entry_signals":{
    "allowed_bias":["NEUTRAL","MILDLY_BULLISH"],
    "min_expected_return":0.02,
    "max_volatility":0.30,
    "min_stock_ownership_days":30
  },
  "strike_selection":{
    "premium_target_pct":0.02,
    "delta_max":0.30,
    "preferred_moneyness":"OTM",
    "min_time_value":0.50
  },
  "exit_rules":{
    "profit_targets":[{"level":0.50,"action":"ROLL_UP","priority":90,"description":"Roll up and out when 50% profit achieved"}],
    "stop_loss_rules":[{"type":"PERCENTAGE","trigger":-0.20,"action":"CLOSE_ALL","priority":100,"description":"Close if underlying drops 20%"}],
    "time_exits":[{"condition":"dte_less_than","value":3,"action":"ROLL_DOWN","priority":80,"description":"Roll down and out 3 days before expiration"}],
    "assignment_management":[{"condition":"itm_by_percent","threshold":0.05,"action":"PREPARE_ASSIGNMENT","priority":85}]
  },
  "scoring":{
    "premium_yield_weight":0.6,
    "volatility_weight":0.4,
    "dividend_bonus":0.2,
    "liquidity_weight":0.3,
    "score_floor":1.0,
    "score_ceiling":10.0,
    "round_decimals":1
  },
  "risk_management":{"max_allocation_percentage":40,"max_single_position_size":10,"sector_concentration_limit":0.3,"correlation_limit":0.6},
  "educational_content":{
    "best_for":"Conservative income generation on owned stocks",
    "when_to_use":"Neutral to mildly bullish outlook on owned shares",
    "profit_mechanism":"Collect call premium while retaining stock ownership",
    "risk_level":"LOW-MEDIUM",
    "typical_duration":"30-45 days",
    "max_profit":"Call premium + any stock appreciation up to strike",
    "max_loss":"Stock can decline to zero minus call premium collected",
    "assignment_risk":"HIGH - be prepared to sell shares at strike price"
  }
}
EOF

# 5. Credit Spread
cat > strategies/credit_spread.json << 'EOF'
{
  "strategy_id": "credit_spread",
  "module": "strategies.credit_spread_plugin",
  "strategy_name": "Credit Spread",
  "strategy_type": "CREDIT_SPREAD",
  "description":"Income generation through credit spreads with defined risk and high probability of profit",
  "universe":{"symbol_types":["STOCK","ETF"],"min_market_cap":5000000000,"min_avg_volume":2000000,"min_option_volume":500,"liquid_underlyings_only":true},
  "position_parameters":{"delta_targets":[0.05,0.10,0.15,0.20],"min_dte":14,"max_dte":45,"min_credit":0.05,"preferred_strikes":[5,10],"expiration_limit":4,"max_opportunities":6},
  "strike_selection":{"strike_spacing_rules":[{"price_lt":50,"spacing":2.5},{"price_lt":100,"spacing":5},{"price_lt":200,"spacing":5},{"price_lt":1000,"spacing":10},{"default":25}],"spread_widths":[5,10,15,20],"min_credit_to_width_ratio":0.20},
  "entry_signals":{"allowed_bias":["BULLISH","NEUTRAL","BEARISH"],"allowed_strength":["MODERATE","STRONG","WEAK"],"allowed_volatility":["NORMAL","HIGH"],"forbidden_combinations":[{"bias":"NEUTRAL","volatility":"HIGH"}]},
  "scoring":{"probability_weight":3.0,"ev_multiplier":10.0,"risk_reward_multiplier":4.0,"risk_reward_cap":2.0,"time_decay_weight":1.0,"signal_strength_multiplier":{"STRONG":1.2,"MODERATE":1.0,"WEAK":0.8},"volatility_multiplier":{"HIGH":1.1,"NORMAL":1.0,"LOW":0.9},"score_floor":1.0,"score_ceiling":10.0,"round_decimals":1},
  "risk_management":{"max_allocation_percentage":25,"max_single_position_size":5,"correlation_limit":0.8,"sector_concentration_limit":0.4},
  "exit_rules":{"profit_targets":[{"level":0.25,"action":"CLOSE_HALF","percentage":0.5,"priority":75},{"level":0.50,"action":"CLOSE_ALL","percentage":1.0,"priority":85}],"stop_loss_rules":[{"type":"PERCENTAGE","trigger":-2.0,"action":"CLOSE_ALL","priority":100}],"time_exits":[{"condition":"dte_less_than","value":7,"action":"CLOSE_ALL","priority":90}],"delta_management":[{"condition":"delta_breach","threshold":0.30,"action":"CLOSE_ALL","priority":95}]},
  "educational_content":{"best_for":"Income generation with defined risk","when_to_use":"Neutral to mildly directional markets with elevated volatility","profit_mechanism":"Collect premium and benefit from time decay","risk_profile":"Medium – limited defined risk","duration_days":[14,45],"max_profit":"Premium collected","max_loss":"Spread width minus premium collected","breakeven":"Short strike +/- premium collected"}
}
EOF

# 6. Iron Condor
cat > strategies/iron_condor.json << 'EOF'
{
  "strategy_id": "iron_condor",
  "module": "strategies.iron_condor_plugin",
  "strategy_name": "Iron Condor",
  "strategy_type": "IRON_CONDOR",
  "description":"Sell an OTM call spread and an OTM put spread to profit from time decay in range-bound markets.",
  "universe":{"symbol_types":["ETF","LARGE_CAP_STOCK"],"min_market_cap":10000000000,"min_avg_volume":5000000,"min_option_volume":2000,"preferred_symbols":["SPY","QQQ","IWM","AAPL","MSFT"],"exclude_earnings":true},
  "position_parameters":{"delta_target":0.20,"min_dte":21,"max_dte":35,"min_total_credit":0.15,"max_wing_width":10,"expiration_limit":3,"max_opportunities":3,"symmetric_wings":true},
  "strike_selection":{"strike_spacing_rules":[{"price_lt":50,"spacing":2.5},{"price_lt":100,"spacing":5},{"price_lt":200,"spacing":5},{"price_lt":1000,"spacing":5},{"default":10}],"wing_widths":[5,10,15],"min_credit_to_width_ratio":0.15},
  "entry_signals":{"required_bias":["NEUTRAL"],"forbidden_volatility":["HIGH"],"allowed_strength":["WEAK","MODERATE"],"volatility_requirements":{"iv_rank":{"min":25,"max":75},"iv_percentile":{"min":30,"max":70}}},
  "scoring":{"probability_weight":4.0,"premium_weight":2.5,"ev_multiplier":8.0,"zone_width_multiplier":10.0,"zone_width_cap":1.5,"signal_multiplier":{"WEAK":1.1,"MODERATE":1.0,"STRONG":0.85},"volatility_multiplier":{"LOW":1.2,"NORMAL":1.0,"HIGH":0.8},"score_floor":1.0,"score_ceiling":10.0,"round_decimals":1},
  "risk_management":{"max_allocation_percentage":30,"max_correlated_positions":2,"profit_zone_width_min":0.10,"max_portfolio_delta":0.05},
  "exit_rules":{"profit_targets":[{"level":0.25,"action":"CLOSE_HALF","percentage":0.5,"priority":75},{"level":0.50,"action":"CLOSE_ALL","percentage":1.0,"priority":85}],"stop_loss_rules":[{"type":"PERCENTAGE","trigger":-2.5,"action":"CLOSE_ALL","priority":100}],"time_exits":[{"condition":"dte_less_than","value":7,"action":"CLOSE_ALL","priority":90}],"volatility_exits":[{"condition":"iv_spike","threshold":1.5,"action":"CLOSE_ALL","priority":95}],"delta_management":[{"condition":"net_delta_abs","threshold":0.10,"action":"ADJUST","priority":80},{"condition":"net_delta_abs","threshold":0.25,"action":"CLOSE_ALL","priority":95}]},
  "adjustment_rules":{"delta_adjustment":{"threshold":0.10,"methods":["ROLL_UNTESTED_SIDE","CLOSE_TESTED_SIDE"]},"volatility_adjustment":{"iv_expansion_threshold":1.3,"action":"CLOSE_EARLY"}},
  "educational_content":{"best_for":"Neutral markets with range-bound price action","when_to_use":"Low to normal volatility, no strong directional bias","profit_mechanism":"Collect premium from both put and call spreads, benefit from time decay","risk_level":"Medium - Defined risk with good probability of profit","typical_duration":"21-35 days to expiration","max_profit":"Total premium collected","max_loss":"Width of widest spread minus total premium","breakevens":["Put short strike - total credit","Call short strike + total credit"],"profit_zone":"Between the two short strikes"}
}
EOF

# 7. Protective Put
cat > strategies/protective_put.json << 'EOF'
{
  "strategy_id": "protective_put",
  "module":"strategies.protective_put_plugin",
  "strategy_name":"Protective Put",
  "strategy_type":"PROTECTIVE_PUT",
  "description":"Own stock and buy a put for downside protection - insurance strategy",
  "universe":{"primary_symbols":["AAPL","MSFT","GOOGL","AMZN","NVDA"],"symbol_types":["STOCK","ETF"],"min_market_cap":2000000000,"min_avg_volume":1000000,"min_option_volume":500,"volatile_stocks_preferred":true,"exclude_low_beta":false},
  "position_parameters":{"target_dtes":[30,45,60],"protection_level":0.95,"max_opportunities":3,"contracts_per_100_shares":1,"max_premium_pct_equity":0.02,"min_protection_level":0.90,"max_protection_cost":0.05},
  "entry_signals":{"min_bias":"BULLISH","max_drawdown_pct":0.05,"volatility_spike_protection":true,"earnings_protection":true},
  "put_selection":{"delta_target":0.30,"min_dte":7,"max_dte":60,"preferred_moneyness":"OTM","protection_levels":[0.85,0.90,0.95]},
  "exit_rules":{"profit_targets":[{"level":0.50,"action":"CLOSE_PUT","priority":90,"description":"Close put when 50% loss recovered"}],"stop_loss_rules":[{"type":"PERCENTAGE","trigger":-0.50,"action":"CLOSE_PUT","priority":100,"description":"Close put if it loses 50% of value"}],"time_exits":[{"condition":"dte_less_than","value":3,"action":"CLOSE_PUT","priority":80,"description":"Close put 3 days before expiration"}],"protection_achieved":[{"condition":"stock_above_strike_plus_premium","action":"CLOSE_PUT","priority":75,"description":"Close when stock well above breakeven"}]},
  "scoring":{"cost_protection_weight":0.7,"time_decay_weight":0.3,"volatility_protection_bonus":0.2,"liquidity_weight":0.2,"score_floor":1.0,"score_ceiling":10.0,"round_decimals":1},
  "risk_management":{"max_allocation_percentage":20,"max_insurance_cost_percentage":3,"portfolio_correlation_limit":0.8},
  "educational_content":{"best_for":"Downside protection on long stock positions","when_to_use":"Before earnings, market uncertainty, or volatility spikes","profit_mechanism":"Put gains offset stock losses below strike price","risk_level":"LOW","typical_duration":"30-60 days","max_profit":"Unlimited stock upside minus put premium","max_loss":"Stock value down to put strike minus premium paid","insurance_cost":"Put premium acts as insurance premium"}
}
EOF

# 8. RSI Coupon Strategy
cat > strategies/rsi_coupon.json << 'EOF'
{
  "strategy_id": "rsi_coupon",
  "module": "strategies.rsi_coupon_plugin",
  "strategy_name": "RSI Coupon Strategy",
  "strategy_type": "RSI_COUPON",
  "description": "Funnel: screen oversold equities (RSI) + sentiment filter, then overlay high-probability options plays",
  "universe": {"symbol_for_full_universe":"SPY","max_universe_symbols":10,"min_market_cap":1000000000,"min_avg_volume":1000000,"exclude_earnings_days":3},
  "technical_indicators":{"rsi_thresholds":{"min_rsi":30,"max_rsi":45},"rsi_period":14,"additional_filters":{"bollinger_position":{"max":0.3},"volume_ratio":{"min":1.2}}},
  "position_parameters":{"target_dtes":[20,30,45],"max_opportunities":5,"preferred_delta_range":[0.25,0.40],"min_probability_profit":0.65},
  "entry_signals":{"rsi_below":45,"allow_bias":["BULLISH","NEUTRAL","SLIGHTLY_BEARISH"],"required_oversold_confirmation":true,"min_signal_strength":"MODERATE"},
  "scoring":{"base_probability_weight":5.0,"rsi_bonus":[{"rsi_lt":25,"bonus":2.0},{"rsi_lt":30,"bonus":1.5},{"rsi_lt":35,"bonus":1.0},{"default":0.5}],"risk_reward_bonus":{"multiplier":0.5,"cap":1.5},"score_ceiling":10.0,"score_floor":2.0,"round_decimals":1},
  "trade_setup_mapping":{"oversold":"BULLISH_REVERSAL","deeply_oversold":"STRONG_BULLISH_REVERSAL","default":"NEUTRAL"},
  "risk_management":{"max_allocation_percentage":20,"max_correlation":0.6,"position_sizing":{"base_size_per_3k":1,"rsi_size_multiplier":{"rsi_lt_25":1.5,"rsi_lt_30":1.2,"default":1.0}}},
  "exit_rules":{"profit_targets":[{"level":0.60,"action":"CLOSE_HALF","percentage":0.5,"priority":80},{"level":0.80,"action":"CLOSE_ALL","percentage":1.0,"priority":85}],"stop_loss_rules":[{"type":"PERCENTAGE","trigger":-0.40,"action":"CLOSE_ALL","priority":100}],"technical_exits":[{"condition":"rsi_above","value":70,"action":"CLOSE_ALL","priority":90}],"time_exits":[{"condition":"dte_less_than","value":7,"action":"CLOSE_ALL","priority":85}]},
  "educational_content":{"best_for":"Mean reversion trades on oversold conditions","when_to_use":"RSI below 45 with additional oversold confirmation","profit_mechanism":"Bounce from oversold levels combined with options premium decay","risk_level":"MEDIUM","typical_duration":"20-45 days","max_profit":"Strike price - premium paid (puts) or premium collected (calls)","max_loss":"Premium paid or collected"}
}
EOF

# 9. Single Option
cat > strategies/single_option.json << 'EOF'
{
  "strategy_id":"single_option",
  "module":"strategies.single_option_plugin",
  "strategy_name":"Single Option",
  "strategy_type":"NAKED_OPTION",
  "description":"Single leg option trades based on strong directional signals with high premium capture",
  "universe":{"symbol_types":["STOCK","ETF"],"min_volume":500000,"min_option_volume":1000,"exclude_earnings":true},
  "position_parameters":{"delta_targets":[0.30,0.40,0.50],"min_dte":7,"max_dte":30,"min_premium":0.50,"max_opportunities":4,"expiration_limit":3,"position_size_per_3k":1},
  "strike_selection":{"strike_spacing_rules":[{"price_lt":50,"spacing":2.5},{"price_lt":200,"spacing":5},{"default":10}]},
  "entry_signals":{"required_signal_strength":["STRONG"],"forbidden_bias":["NEUTRAL"],"allowed_bias":["BULLISH","BEARISH"],"min_conviction_score":7.0},
  "scoring":{"signal_strength_weights":{"STRONG":4.0,"MODERATE":2.0,"WEAK":0.5},"ev_multiplier":2.0,"prob_multiplier":2.0,"volatility_bonus":{"HIGH":1.0,"NORMAL":0.5,"LOW":0.0},"score_floor":1.0,"score_ceiling":10.0,"round_decimals":1},
  "risk_management":{"risk_level":"HIGH","max_allocation_percentage":10,"stop_loss_percentage":50,"profit_target_percentage":75,"max_single_position_risk":500},
  "exit_rules":{"profit_targets":[{"level":0.75,"action":"CLOSE_ALL","percentage":1.0,"priority":85}],"stop_loss_rules":[{"type":"PERCENTAGE","trigger":-0.50,"action":"CLOSE_ALL","priority":100}],"time_exits":[{"condition":"dte_less_than","value":2,"action":"CLOSE_ALL","priority":90}]},
  "educational_content":{"best_for":"High conviction directional trades with significant premium","when_to_use":"Strong technical or fundamental signals with elevated volatility","profit_mechanism":"Directional movement in underlying asset","risk_level":"HIGH","typical_duration":"7-30 days","max_profit":"Unlimited (calls) or substantial (puts)","max_loss":"Total premium paid"}
}
EOF

# 10. Straddle
cat > strategies/straddle.json << 'EOF'
{
  "strategy_id":"straddle",
  "module":"strategies.straddle_plugin",
  "strategy_name":"Straddle",
  "strategy_type":"STRADDLE",
  "description":"Buy a call and a put at the same strike - profit from large moves in either direction",
  "universe":{"symbol_types":["STOCK","ETF"],"min_market_cap":10000000000,"min_avg_volume":5000000,"min_option_volume":2000,"high_volatility_candidates":true,"earnings_plays_preferred":true},
  "position_parameters":{"max_premium_cost":0.05,"max_opportunities":3,"position_size_limit":2000},
  "entry_signals":{"volatility_min":0.40,"bias":"ANY","implied_volatility_rank_min":50,"expected_move_threshold":0.08},
  "strike_selection":{"moneyness":"ATM","max_strike_offset":0.01,"prefer_highest_volume":true,"min_open_interest":100},
  "timing":{"dte_range":[7,60],"optimal_dte":[14,30],"earnings_timing":{"days_before_earnings":[1,7],"avoid_post_earnings":true}},
  "exit_rules":{"profit_targets":[{"level":1.00,"action":"CLOSE_ALL","priority":90,"description":"Close when doubled investment"},{"level":0.50,"action":"CLOSE_HALF","priority":80,"description":"Take partial profits at 50% gain"}],"stop_loss_rules":[{"type":"PERCENTAGE","trigger":-0.50,"action":"CLOSE_ALL","priority":100,"description":"Close at 50% loss"}],"time_exits":[{"condition":"dte_less_than","value":3,"action":"CLOSE_ALL","priority":85,"description":"Close 3 days before expiration"}],"volatility_exits":[{"condition":"iv_crush","threshold":0.30,"action":"CLOSE_ALL","priority":95,"description":"Close immediately if IV drops 30%"}]},
  "scoring":{"volatility_weight":0.6,"expected_move_weight":0.4,"earnings_proximity_bonus":1.5,"liquidity_weight":0.3,"iv_rank_multiplier":{"high":1.3,"medium":1.0,"low":0.6},"score_floor":1.0,"score_ceiling":10.0,"round_decimals":1},
  "risk_management":{"max_allocation_percentage":15,"max_single_straddle_cost":2000,"volatility_risk_limit":0.6,"time_decay_protection":true},
  "educational_content":{"best_for":"Large directional moves in either direction","when_to_use":"Before earnings, major events, or high volatility periods","profit_mechanism":"Large price movement overcomes time decay and volatility crush","risk_level":"HIGH","typical_duration":"7-30 days","max_profit":"Unlimited in either direction","max_loss":"Total premium paid for both options","breakevens":["Strike - total premium","Strike + total premium"]}
}
EOF

# 11. Strangle
cat > strategies/strangle.json << 'EOF'
{
  "strategy_id":"strangle",
  "module":"strategies.strangle_plugin",
  "strategy_name":"Strangle",
  "strategy_type":"STRANGLE",
  "description":"Buy an OTM call and an OTM put at different strikes - lower cost alternative to straddle",
  "universe":{"symbol_types":["STOCK","ETF"],"min_market_cap":5000000000,"min_avg_volume":3000000,"min_option_volume":1000,"high_volatility_candidates":true,"earnings_candidates":true},
  "position_parameters":{"max_premium_cost":0.03,"max_opportunities":3,"position_size_limit":1500},
  "entry_signals":{"volatility_min":0.35,"bias":"ANY","implied_volatility_rank_min":40,"expected_move_threshold":0.06},
  "strike_selection":{"call_percent_otm":0.02,"put_percent_otm":0.02,"delta_targets":{"call_delta":0.25,"put_delta":-0.25},"strike_spacing_rules":[{"price_lt":50,"spacing":2.5},{"price_lt":200,"spacing":5},{"default":10}]},
  "timing":{"dte_range":[7,60],"optimal_dte":[21,35],"earnings_timing":{"days_before_earnings":[1,7],"avoid_post_earnings":true}},
  "exit_rules":{"profit_targets":[{"level":1.00,"action":"CLOSE_ALL","priority":90,"description":"Close when doubled investment"},{"level":0.50,"action":"CLOSE_HALF","priority":80,"description":"Take partial profits at 50% gain"}],"stop_loss_rules":[{"type":"PERCENTAGE","trigger":-0.50,"action":"CLOSE_ALL","priority":100,"description":"Close at 50% loss"}],"time_exits":[{"condition":"dte_less_than","value":5,"action":"CLOSE_ALL","priority":85,"description":"Close 5 days before expiration"}],"single_leg_management":[{"condition":"one_leg_itm","action":"CLOSE_WINNING_LEG","priority":75,"description":"Close profitable leg if one side moves ITM"}]},
  "scoring":{"volatility_weight":0.5,"strike_offset_weight":0.5,"cost_efficiency_bonus":0.3,"liquidity_weight":0.2,"earnings_proximity_bonus":1.2,"score_floor":1.0,"score_ceiling":10.0,"round_decimals":1},
  "risk_management":{"max_allocation_percentage":12,"max_single_strangle_cost":1500,"volatility_risk_limit":0.5,"strike_width_limits":{"min_width":5,"max_width":25}},
  "educational_content":{"best_for":"Large directional moves with lower cost than straddle","when_to_use":"High volatility expectation but want lower premium cost","profit_mechanism":"Large price movement beyond strike prices plus premium","risk_level":"HIGH","typical_duration":"21-35 days","max_profit":"Unlimited in either direction","max_loss":"Total premium paid for both options","breakevens":["Put strike - total premium","Call strike + total premium"]}
}
EOF

# 12. Vertical Spread
cat > strategies/vertical_spread.json << 'EOF'
{
  "strategy_id":"vertical_spread",
  "module":"strategies.vertical_spread_plugin",
  "strategy_name":"Vertical Spread",
  "strategy_type":"VERTICAL_SPREAD",
  "description":"Buy one option and sell another at a different strike - directional strategy with defined risk",
  "subtypes":{"available":["BULL_CALL","BEAR_PUT","BULL_PUT","BEAR_CALL"],"preferred":["BULL_CALL","BEAR_PUT"]},
  "universe":{"symbol_types":["STOCK","ETF"],"min_market_cap":5000000000,"min_avg_volume":2000000,"min_option_volume":1000,"liquid_strikes_required":true},
  "position_parameters":{"max_debit_pct_equity":0.03,"min_width":5,"max_width":20,"max_opportunities":5},
  "entry_signals":{"min_bias_strength":"MODERATE","max_volatility":0.35,"allowed_bias":["BULLISH","BEARISH"],"forbidden_bias":["NEUTRAL"]},
  "strike_selection":{"delta_buy":0.25,"delta_sell":0.15,"spread_widths":[5,10,15,20],"min_risk_reward_ratio":1.5,"max_risk_reward_ratio":4.0},
  "timing":{"dte_range":[7,45],"optimal_dte":[21,35],"avoid_earnings":true},
  "exit_rules":{"profit_targets":[{"level":0.50,"action":"CLOSE_SPREAD","priority":90,"description":"Close at 50% of max profit"},{"level":0.75,"action":"CLOSE_SPREAD","priority":85,"description":"Close at 75% of max profit if close to expiration"}],"stop_loss_rules":[{"type":"PERCENTAGE","trigger":-0.50,"action":"CLOSE_SPREAD","priority":100,"description":"Close at 50% of max loss"}],"time_exits":[{"condition":"dte_less_than","value":2,"action":"CLOSE_SPREAD","priority":80,"description":"Close 2 days before expiration"}],"technical_exits":[{"condition":"bias_reversal","action":"CLOSE_SPREAD","priority":95,"description":"Close if directional bias reverses"}]},
  "scoring":{"risk_reward_weight":0.5,"probability_weight":0.3,"cost_weight":0.2,"bias_strength_multiplier":{"STRONG":1.3,"MODERATE":1.0,"WEAK":0.7},"score_floor":1.0,"score_ceiling":10.0,"round_decimals":1},
  "risk_management":{"max_allocation_percentage":25,"max_single_spread_cost":1000,"correlation_limit":0.7,"sector_concentration_limit":0.4},
  "educational_content":{"best_for":"Directional trades with limited risk and defined profit potential","when_to_use":"Moderate to strong directional bias with controlled risk","profit_mechanism":"Benefit from directional movement while limiting downside","risk_level":"MEDIUM","typical_duration":"21-35 days","max_profit":"Spread width minus net debit paid","max_loss":"Net debit paid (limited risk)","breakeven":"Long strike ± net debit (calls/puts)"}
}
EOF

echo "✅ All 12 strategy JSON files have been generated in ./strategies/"
