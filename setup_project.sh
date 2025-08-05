#!/usr/bin/env bash
set -e

# 1. Create folder structure
mkdir -p frontend/src/components
mkdir -p strategies
mkdir -p public

# 2. Scaffold App.jsx
cat > frontend/src/App.jsx << 'EOF'
import React, { useEffect, useState } from 'react'
import StrategySelector from './components/StrategySelector'
import DynamicForm from './components/DynamicForm'
import TickerLoader from './components/TickerLoader'
import strategies from '../../strategies/index.json'

function App() {
  const [selectedStrategy, setSelectedStrategy] = useState(null)
  const [config, setConfig] = useState({})
  const [tickers, setTickers] = useState([])

  useEffect(() => {
    if (selectedStrategy) {
      // Deep clone default config
      setConfig(JSON.parse(JSON.stringify(selectedStrategy)))
    }
  }, [selectedStrategy])

  const runScan = () => {
    console.log('Running scan with:', { config, tickers })
    // call your backend here...
  }

  return (
    <div className="p-8 bg-gray-100 min-h-screen">
      <h1 className="text-2xl font-bold mb-4">Options Strategy Scanner</h1>
      <div className="flex space-x-4">
        <div className="w-1/4">
          <StrategySelector
            strategies={strategies}
            onSelect={setSelectedStrategy}
          />
          <TickerLoader onLoad={setTickers} />
        </div>
        <div className="w-3/4">
          {selectedStrategy && (
            <>
              <h2 className="text-xl font-semibold mb-2">
                {selectedStrategy.strategy_name}
              </h2>
              <DynamicForm
                config={config}
                uiMeta={selectedStrategy.ui_metadata}
                onChange={setConfig}
              />
              <button
                className="mt-4 px-4 py-2 bg-blue-600 text-white rounded"
                onClick={runScan}
              >
                Run Scan
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  )
}

export default App
EOF

# 3. Scaffold StrategySelector.jsx
cat > frontend/src/components/StrategySelector.jsx << 'EOF'
import React from 'react'

export default function StrategySelector({ strategies, onSelect }) {
  return (
    <div>
      <label className="block font-medium mb-1">Select Strategy</label>
      <select
        className="w-full border p-2 rounded"
        onChange={e => {
          const id = e.target.value
          const strat = strategies.find(s => s.strategy_id === id)
          onSelect(strat)
        }}
      >
        <option value="">-- choose --</option>
        {strategies.map(s => (
          <option key={s.strategy_id} value={s.strategy_id}>
            {s.strategy_name}
          </option>
        ))}
      </select>
    </div>
  )
}
EOF

# 4. Scaffold DynamicForm.jsx
cat > frontend/src/components/DynamicForm.jsx << 'EOF'
import React from 'react'
import get from 'lodash.get'
import set from 'lodash.set'

export default function DynamicForm({ config, uiMeta, onChange }) {
  const renderField = (path, meta) => {
    const value = get(config, path)
    const handleChange = v => {
      const copy = { ...config }
      set(copy, path, v)
      onChange(copy)
    }

    if (meta.visible === false) return null

    return (
      <div key={path} className="mb-4">
        <label className="block font-medium">
          {path.split('.').slice(-1)[0]}{' '}
          {meta.tooltip && (
            <span title={meta.tooltip} className="cursor-help">ℹ️</span>
          )}
        </label>
        {meta.editable ? (
          meta.type === 'range' ? (
            <input
              type="range"
              min={meta.min}
              max={meta.max}
              value={value}
              onChange={e => handleChange(Number(e.target.value))}
            />
          ) : (
            <input
              type={meta.type || 'text'}
              min={meta.min}
              max={meta.max}
              step={meta.step}
              value={value}
              onChange={e => handleChange(e.target.value)}
              className="w-full border p-2 rounded"
            />
          )
        ) : (
          <div className="p-2 bg-gray-200 rounded">{String(value)}</div>
        )}
      </div>
    )
  }

  return (
    <div>
      {Object.entries(uiMeta).map(([path, meta]) => renderField(path, meta))}
    </div>
  )
}
EOF

# 5. Scaffold TickerLoader.jsx
cat > frontend/src/components/TickerLoader.jsx << 'EOF'
import React, { useEffect } from 'react'

export default function TickerLoader({ onLoad }) {
  useEffect(() => {
    fetch('/tickers.txt')
      .then(res => res.text())
      .then(text => {
        const lines = text
          .split('\\n')
          .map(l => l.trim().split('#')[0].trim())
          .filter(l => l)
        onLoad(lines)
      })
  }, [onLoad])

  return (
    <div className="mt-4">
      <label className="block font-medium mb-1">Tickers Loaded</label>
      <textarea
        readOnly
        value={lines => lines.join(', ')}
        rows={5}
        className="w-full border p-2 rounded bg-gray-50"
      />
    </div>
  )
}
EOF

# 6. Bundle all strategies/*.json into strategies/index.json
echo "[" > strategies/index.json
first=true
for f in strategies/*.json; do
  if [[ "$f" == *"index.json"* ]]; then continue; fi
  if [ "$first" = true ]; then
    first=false
  else
    echo "," >> strategies/index.json
  fi
  cat "$f" >> strategies/index.json
done
echo "]" >> strategies/index.json

# 7. Create tickers.txt
cat > public/tickers.txt << 'EOF'
# ETFs - Exchange Traded Funds with High Options Liquidity
SPY   # SPDR S&P 500 ETF Trust
QQQ   # Invesco QQQ Trust
IWM   # iShares Russell 2000 ETF
DIA   # SPDR Dow Jones Industrial Average ETF

# Sector ETFs
XLK XLF XLE XLV XLI XLY XLP XLU XLB XLRE

# Commodity & Bond ETFs
GLD TLT USO VIX
EOF

echo "✅ Project scaffold complete! \\
- frontend/src/App.jsx \\
- frontend/src/components/{{StrategySelector,DynamicForm,TickerLoader}}.jsx \\
- strategies/index.json \\
- public/tickers.txt"
::contentReference[oaicite:0]{index=0}
