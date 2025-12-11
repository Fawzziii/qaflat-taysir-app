import FormulaParser from 'hot-formula-parser'
import * as XLSX from 'xlsx'

export function sheetToGrid(ws) {
  const range = ws['!ref'] || 'A1:A1'
  const decoded = XLSX.utils.decode_range(range)
  const rows = []

  for (let r = decoded.s.r; r <= decoded.e.r; r++) {
    const row = []
    for (let c = decoded.s.c; c <= decoded.e.c; c++) {
      const addr = XLSX.utils.encode_cell({ r, c })
      const cell = ws[addr]

      row.push({
        v: cell ? cell.v : "",
        f: cell ? cell.f || null : null
      })
    }
    rows.push(row)
  }
  return rows
}
