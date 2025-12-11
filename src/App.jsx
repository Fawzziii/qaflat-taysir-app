import React, { useState } from 'react'
import * as XLSX from 'xlsx'
import { saveAs } from 'file-saver'
import Splash from './components/Splash'
import SheetNav from './components/SheetNav'
import GridEditor from './components/GridEditor'
import { sheetToGrid } from './utils/excelUtils'
import './index.css'

export default function App() {

  const [showSplash, setSplash] = useState(true)
  const [sheets, setSheets] = useState([])
  const [active, setActive] = useState(null)
  const [grid, setGrid] = useState([])

  if (showSplash)
    return <Splash onFinish={() => setSplash(false)} />

  function handleFile(e) {
    const f = e.target.files[0]
    if (!f) return

    const reader = new FileReader()

    reader.onload = (ev) => {
      const data = new Uint8Array(ev.target.result)
      const wb = XLSX.read(data, { cellFormula: true })

      setSheets(wb.SheetNames)

      const first = wb.SheetNames[0]
      setActive(first)
      setGrid(sheetToGrid(wb.Sheets[first]))
    }

    reader.readAsArrayBuffer(f)
  }

  function changeSheet(name) {
    setActive(name)
  }

  function updateCell(ri, ci, val) {
    const newGrid = [...grid]
    if (val.startsWith('=')) {
      newGrid[ri][ci].f = val.slice(1)
      newGrid[ri][ci].v = ''
    } else {
      newGrid[ri][ci].f = null
      newGrid[ri][ci].v = val
    }
    setGrid(newGrid)
  }

  function addRow() {
    const cols = grid[0].length
    const newRow = Array(cols).fill({ v: "", f: null })
    setGrid([...grid, newRow])
  }

  function deleteRow(ri) {
    const newGrid = grid.filter((_, i) => i !== ri)
    setGrid(newGrid)
  }

  function exportExcel() {
    const ws = XLSX.utils.aoa_to_sheet(
      grid.map(row =>
        row.map(cell => cell.f ? "=" + cell.f : cell.v)
      )
    )

    const wb = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(wb, ws, active)

    const blob = XLSX.write(wb, { bookType: "xlsx", type: "array" })
    saveAs(new Blob([blob]), "qaflat-export.xlsx")
  }

  return (
    <div className="container">

      <h1>قافلة التيسير — إدارة القافلة الطبية</h1>

      <input type="file" onChange={handleFile} style={{ margin: "12px 0" }} />

      <SheetNav sheets={sheets} active={active} onChange={changeSheet} />

      {grid.length > 0 && (
        <GridEditor
          grid={grid}
          onUpdate={updateCell}
          onAddRow={addRow}
          onDeleteRow={deleteRow}
        />
      )}

      <button
        onClick={exportExcel}
        className="button-primary button-large"
        style={{ marginTop: "16px" }}
      >
        تصدير الملف
      </button>
    </div>
  )
}
