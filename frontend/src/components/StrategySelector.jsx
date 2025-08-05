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
