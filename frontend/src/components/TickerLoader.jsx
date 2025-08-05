import React, { useEffect } from 'react'

export default function TickerLoader({ onLoad }) {
  useEffect(() => {
    fetch('/tickers.json')
      .then(res => res.json())
      .then(data => {
        // data is an array of { symbol, name, category }
        onLoad(data.map(item => item.symbol))
      })
  }, [onLoad])

  return null
}
