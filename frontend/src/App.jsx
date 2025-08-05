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
