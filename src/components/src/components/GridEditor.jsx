import React from 'react'

export default function GridEditor({ grid, onUpdate, onAddRow, onDeleteRow }) {
  return (
    <div className="overflow-auto border rounded">
      <table className="min-w-full table-auto">
        <thead>
          <tr>
            <th>#</th>
            {grid[0].map((_, ci) => (
              <th key={ci}>{String.fromCharCode(65 + ci)}</th>
            ))}
            <th>حذف</th>
          </tr>
        </thead>

        <tbody>
          {grid.map((row, ri) => (
            <tr key={ri}>
              <td>{ri + 1}</td>

              {row.map((cell, ci) => (
                <td key={ci}>
                  <input
                    className="cell-input"
                    value={cell.f ? "=" + cell.f : cell.v || ""}
                    onChange={(e) => onUpdate(ri, ci, e.target.value)}
                  />
                </td>
              ))}

              <td>
                <button onClick={() => onDeleteRow(ri)}>✖</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      <button onClick={onAddRow} className="button-primary" style={{ marginTop: "12px" }}>
        إضافة صف
      </button>
    </div>
  )
}
