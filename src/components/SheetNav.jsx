import React from 'react'

export default function SheetNav({ sheets, active, onChange }) {
  return (
    <div className="mb-3">
      {sheets.map(sheet => (
        <button
          key={sheet}
          onClick={() => onChange(sheet)}
          className={sheet === active ? "tab active" : "tab"}
        >
          {sheet}
        </button>
      ))}
    </div>
  )
}
