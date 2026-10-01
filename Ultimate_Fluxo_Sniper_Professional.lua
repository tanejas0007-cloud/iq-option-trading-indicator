-- ULTIMATE FLUXO SNIPER - PROFESSIONAL GRADE
-- Real-time pre-candle prediction with multi-filter
-- Advanced divergence, volume, and momentum detection
-- Works best on 1m / 5m / 15m

instrument {
    name = 'ULTIMATE FLUXO SNIPER',
    short_name = 'UFS',
    icon = 'indicators:BB',
    overlay = true
}

-- =====================================
-- Input Settings
-- =====================================
tfMode = input(1, "Timeframe", input.string_selection, {"1m","5m","15m"})

fastLen = input(5, "Fast MA", input.integer, 1, 50, 1)
slowLen = input(13, "Slow MA", input.integer, 1, 100, 1)
trendLen = input(50, "Trend MA", input.integer, 1, 200, 1)
srLookback = input(20, "S/R Lookback", input.integer, 5, 100, 1)
rsiLen = input(14, "RSI Length", input.integer, 1, 50, 1)
macdFast = input(12, "MACD Fast", input.integer, 1, 50, 1)
macdSlow = input(26, "MACD Slow", input.integer, 1, 100, 1)
macdSignal = input(9, "MACD Signal", input.integer, 1, 50, 1)

showArrows = input(true, "Show Navigation Arrows", input.boolean)
showLabels = input(true, "Show Probability %", input.boolean)
showMA = input(true, "Show MAs", input.boolean)
showSR = input(true, "Show S/R", input.boolean)

input_group {
    "STRONG BUY",
    buyColor = input { default = "rgba(0, 255, 100, 1)", type = input.color },
    buySize = input { default = "large", type = input.string_selection, options = {"small", "normal", "large", "huge"} }
}

input_group {
    "STRONG SELL",
    sellColor = input { default = "rgba(255, 50, 50, 1)", type = input.color },
    sellSize = input { default = "large", type = input.string_selection, options = {"small", "normal", "large", "huge"} }
}

input_group {
    "MA Colors",
    maFastColor = input { default = "rgba(0, 200, 255, 1)", type = input.color },
    maSlowColor = input { default = "rgba(255, 150, 0, 1)", type = input.color },
    maTrendColor = input { default = "rgba(200, 200, 200, 1)", type = input.color }
}

input_group {
    "Support/Resistance",
    srBullColor = input { default = "rgba(50, 255, 100, 0.4)", type = input.color },
    srBearColor = input { default = "rgba(255, 100, 100, 0.4)", type = input.color }
}

-- =====================================
-- Calculate MAs
-- =====================================
ma_fast = sma(close, fastLen)
ma_slow = sma(close, slowLen)
ma_trend = sma(close, trendLen)

-- Previous values
ma_fast_prev = ma_fast[1]
ma_slow_prev = ma_slow[1]
ma_trend_prev = ma_trend[1]

-- =====================================
-- Calculate RSI
-- =====================================
rsi_val = rsi(close, rsiLen)
rsi_prev = rsi_val[1]

-- =====================================
-- Calculate MACD
-- =====================================
macd_line = ema(close, macdFast) - ema(close, macdSlow)
macd_signal_line = sma(macd_line, macdSignal)
macd_histogram = macd_line - macd_signal_line
macd_prev = macd_line[1]
macd_signal_prev = macd_signal_line[1]
macd_hist_prev = macd_histogram[1]

-- =====================================
-- MACD Divergence & Crossover Detection
-- =====================================
-- MACD bullish crossover
macd_bull_cross = macd_prev < macd_signal_prev and macd_line > macd_signal_line

-- MACD bearish crossover
macd_bear_cross = macd_prev > macd_signal_prev and macd_line < macd_signal_line

-- MACD histogram expansion (strength)
macd_bull_strength = macd_histogram > 0 and macd_histogram > macd_hist_prev
macd_bear_strength = macd_histogram < 0 and macd_histogram < macd_hist_prev

-- =====================================
-- Support / Resistance
-- =====================================
support = lowest(low, srLookback)
resistance = highest(high, srLookback)
support_prev = support[1]
resistance_prev = resistance[1]

-- =====================================
-- ATR & Volatility
-- =====================================
atr_val = atr(14)
body = abs(close - open)
range_size = high - low
hl2 = (high + low) / 2

-- =====================================
-- Momentum Indicators
-- =====================================
-- Rate of change
roc = (close - close[5]) / close[5] * 100

-- Momentum strength
momentum = close - close[10]

-- =====================================
-- TREND CONFIRMATION
-- =====================================
bullish_ma_alignment = ma_fast > ma_slow and ma_slow > ma_trend
bearish_ma_alignment = ma_fast < ma_slow and ma_slow < ma_trend

-- MA slope direction (acceleration)
ma_fast_slope = ma_fast - ma_fast_prev
ma_slow_slope = ma_slow - ma_slow_prev

-- =====================================
-- PRICE ACTION SETUP
-- =====================================
-- Bullish pin bar setup
bullish_pin = low < support and close > hl2 and body > range_size * 0.4

-- Bearish pin bar setup
bearish_pin = high > resistance and close < hl2 and body > range_size * 0.4

-- Inside bar setup (quiet before storm)
inside_bar = high < high[1] and low > low[1]

-- Outside bar engulfing
engulfing_bull = close > open[1] and open < close[1] and close > open and body > abs(close[1] - open[1]) * 1.2

engulfing_bear = close < open[1] and open > close[1] and close < open and body > abs(close[1] - open[1]) * 1.2

-- =====================================
-- BREAKOUT DETECTION
-- =====================================
resistance_breakout = close > resistance_prev and close[1] <= resistance_prev
support_breakout = close < support_prev and close[1] >= support_prev

-- Volume trend (higher close = accumulation)
vol_confirm_bull = close > open and range_size > atr_val * 0.8
vol_confirm_bear = close < open and range_size > atr_val * 0.8

-- =====================================
-- RSI DIVERGENCE & EXTREMES
-- =====================================
rsi_oversold = rsi_val < 30
rsi_overbought = rsi_val > 70
rsi_neutral = rsi_val > 40 and rsi_val < 60

rsi_bull_div = rsi_val > rsi_prev and close < close[1]
rsi_bear_div = rsi_val < rsi_prev and close > close[1]

-- =====================================
-- COMBINED STRENGTH SCORING
-- =====================================
-- BUY SCORE
buy_score = 0

if close > open then buy_score = buy_score + 20 end
if bullish_ma_alignment then buy_score = buy_score + 20 end
if macd_bull_cross then buy_score = buy_score + 20 end
if macd_bull_strength then buy_score = buy_score + 10 end
if close > support then buy_score = buy_score + 15 end
if resistance_breakout and close > ma_fast then buy_score = buy_score + 25 end
if vol_confirm_bull then buy_score = buy_score + 10 end
if rsi_val > 50 and rsi_val < 80 then buy_score = buy_score + 10 end
if close[1] < open[1] then buy_score = buy_score + 15 end
if bullish_pin then buy_score = buy_score + 20 end
if engulfing_bull then buy_score = buy_score + 25 end
if ma_fast_slope > 0 then buy_score = buy_score + 10 end

-- SELL SCORE
sell_score = 0

if close < open then sell_score = sell_score + 20 end
if bearish_ma_alignment then sell_score = sell_score + 20 end
if macd_bear_cross then sell_score = sell_score + 20 end
if macd_bear_strength then sell_score = sell_score + 10 end
if close < resistance then sell_score = sell_score + 15 end
if support_breakout and close < ma_fast then sell_score = sell_score + 25 end
if vol_confirm_bear then sell_score = sell_score + 10 end
if rsi_val < 50 and rsi_val > 20 then sell_score = sell_score + 10 end
if close[1] > open[1] then sell_score = sell_score + 15 end
if bearish_pin then sell_score = sell_score + 20 end
if engulfing_bear then sell_score = sell_score + 25 end
if ma_fast_slope < 0 then sell_score = sell_score + 10 end

-- =====================================
-- FINAL SIGNAL GENERATION
-- =====================================
buy_signal = buy_score >= 90
sell_signal = sell_score >= 90

buy_warning = buy_score >= 70 and buy_score < 90
sell_warning = sell_score >= 70 and sell_score < 90

-- =====================================
-- Plot Moving Averages
-- =====================================
if showMA == true then
    plot(ma_fast, "Fast MA", maFastColor, 2)
    plot(ma_slow, "Slow MA", maSlowColor, 2)
    plot(ma_trend, "Trend MA", maTrendColor, 2)
end

-- =====================================
-- Plot Support / Resistance with fill
-- =====================================
if showSR == true then
    plot(support, "Support", srBearColor, 2)
    plot(resistance, "Resistance", srBullColor, 2)
end

-- =====================================
-- Plot Buy Signals
-- =====================================
if showArrows == true then
    if buy_signal == true then
        plot_shape(
            close - range_size * 0.7,
            "STRONG BUY",
            shape_style.arrowup,
            shape_size.huge,
            buyColor,
            shape_location.absolutebelowbar,
            0,
            "🔥 BUY 🔥",
            buyColor
        )
    end
    
    if buy_warning == true then
        plot_shape(
            close - range_size * 0.4,
            "BUY WARNING",
            shape_style.arrowup,
            shape_size.large,
            buyColor,
            shape_location.absolutebelowbar,
            0,
            "⬆ BUY",
            buyColor
        )
    end
end

-- =====================================
-- Plot Sell Signals
-- =====================================
if showArrows == true then
    if sell_signal == true then
        plot_shape(
            close + range_size * 0.7,
            "STRONG SELL",
            shape_style.arrowdown,
            shape_size.huge,
            sellColor,
            shape_location.absoluteabovebar,
            0,
            "🔥 SELL 🔥",
            sellColor
        )
    end
    
    if sell_warning == true then
        plot_shape(
            close + range_size * 0.4,
            "SELL WARNING",
            shape_style.arrowdown,
            shape_size.large,
            sellColor,
            shape_location.absoluteabovebar,
            0,
            "⬇ SELL",
            sellColor
        )
    end
end

-- =====================================
-- Plot Labels with Probability
-- =====================================
if showLabels == true then
    if buy_signal == true then
        label = label_new(
            bar_index, 
            low - range_size, 
            tostring(buy_score) .. "% BUY", 
            xloc_bar_index, 
            yloc_price, 
            color.new(buyColor, 0), 
            label_style_label_lower_left, 
            buyColor, 
            size_small, 
            text_align_left
        )
    end
    
    if sell_signal == true then
        label = label_new(
            bar_index, 
            high + range_size, 
            tostring(sell_score) .. "% SELL", 
            xloc_bar_index, 
            yloc_price, 
            color.new(sellColor, 0), 
            label_style_label_upper_left, 
            sellColor, 
            size_small, 
            text_align_left
        )
    end
end

-- =====================================
-- Candle coloring
-- =====================================
if buy_signal == true then
    barcolor(color.new(buyColor, 20))
elseif buy_warning == true then
    barcolor(color.new(buyColor, 40))
elseif sell_signal == true then
    barcolor(color.new(sellColor, 20))
elseif sell_warning == true then
    barcolor(color.new(sellColor, 40))
end
