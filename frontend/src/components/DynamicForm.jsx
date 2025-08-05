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
